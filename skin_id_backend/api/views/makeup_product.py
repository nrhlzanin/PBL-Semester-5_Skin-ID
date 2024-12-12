import random
import requests
from django.http import JsonResponse
from django.core.paginator import Paginator
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt
import requests
from ..services.makeup_api import fetch_products_by_category
from django.contrib.auth.models import User
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.exceptions import ValidationError
from api.models import Pengguna, SkinTone, Product, ProductColor, Recommendation
from api.views.user_views import token_required 
from math import sqrt
from collections import defaultdict


def is_valid_image_url(url):
    try:
        response = requests.head(url, timeout=5)
        return response.status_code == 200
    except requests.RequestException:
        return False
    
def scrape_and_save():
    api_url = "http://makeup-api.herokuapp.com/api/v1/products.json"
    try:
        response = requests.get(api_url)
        response.raise_for_status()
        makeup_data = response.json()
        if len(makeup_data) > 10:
                makeup_data = random.sample(makeup_data, 200)

        for product_data in makeup_data:
            image_link = product_data.get("image_link")
            if image_link and not is_valid_image_url(image_link):
                image_link = None
            
            product, created = Product.objects.update_or_create(
                product_id=product_data.get("id"),
                defaults={
                    "product_name": product_data.get("name"),
                    "brand": product_data.get("brand"),
                    "product_type": product_data.get("product_type"),
                    "description": product_data.get("description"),
                    "image_url": image_link,
                    "price": product_data.get("price"),
                    "price_sign": product_data.get("price_sign"),
                    "currency": product_data.get("currency"),
                    "product_link": product_data.get("product_link"),
                },
            )

            # Simpan warna produk
            product_colors = product_data.get("product_colors", [])
            for color_data in product_colors:
                hex_value = color_data.get("hex_value")
                if hex_value and len(hex_value) <= 7:  # Validasi panjang hex_value
                    ProductColor.objects.update_or_create(
                        product=product,
                        hex_value=hex_value,
                        defaults={
                            "color_name": color_data.get("colour_name"),
                        },
                    )
                else:
                    print(f"Skipping invalid hex_value: {hex_value}")

        return True  # Sukses
    except requests.exceptions.RequestException as e:
        print(f"Error scraping products: {e}")
        return False  # Gagal

@csrf_exempt
@require_http_methods(["POST"])
def scrape_products(request):
    success = scrape_and_save()
    if success:
        return JsonResponse({"message": "Scraping successful"}, status=200)
    return JsonResponse({"message": "Scraping failed"}, status=500)


@require_http_methods(["GET"])
def fetch_filtered_makeup_products(request):
    # api_url = "http://makeup-api.herokuapp.com/api/v1/products.json"
    product_type = request.GET.get("product_type")
    product_name = request.GET.get("name")
    product_id = request.GET.get("product_id")
    
    try:
        products = Product.objects.all()
    
        if product_type:
            products = products.filter(product_type__iexact=product_type)

        if product_name:
            product_name = product_name.lower()
            products = products.filter(name__icontains=product_name)

        if product_id:
            products = products.filter(product_id=product_id)

            
        filtered_data = []
        for product in products:
            filtered_product = {
                "product_id": product.product_id,
                "brand": product.brand,
                "name": product.product_name,
                "price": product.price,
                "price_sign": product.price_sign,
                "currency": product.currency,
                "image_link": product.image_url,
                "product_link": product.product_link,
                "description": product.description,
                "product_type": product.product_type,
                "product_colors": [
                    {
                        "hex_value":color.hex_value,
                        "color_name":color.color_name,
                    }
                    for color in product.colors.all()
                ]
            }
            filtered_data.append(filtered_product)

        return JsonResponse(filtered_data, safe=False, status=200)        
    except requests.exceptions.RequestException as e:
        return JsonResponse({"error": str(e)}, status = 500)
    
def fetch_makeup_products(request):
    url = "http://makeup-api.herokuapp.com/api/v1/products.json"
    
    # Memanggil API eksternal
    try:
        response = requests.get(url)
        response.raise_for_status()  # Cek apakah permintaan berhasil
        
        # Mendapatkan data produk dari response API
        data = response.json()
        
        # Mengembalikan data dalam bentuk JSON response
        return JsonResponse(data, safe=False)
    
    except requests.exceptions.RequestException as e:
        return JsonResponse({"error": str(e)}, status=500)
    
def hex_to_rgb(hex_color):
    if not hex_color or not hex_color.startswith("#") or len(hex_color) != 7:
        raise ValueError(f"Invalid HEX color: {hex_color}")
    hex_color = hex_color.lstrip("#")
    try:
        return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
    except ValueError:
        raise ValueError(f"Invalid HEX color: {hex_color}")

def color_distance(color1, color2):
    r1,g1,b1 = color1
    r2,g2,b2 = color2
    return sqrt((r1-r2)**2 + (g1-g2)**2)

@api_view(['GET'])
@token_required
def recommend_product(request):
    user = request.user
    skintone = user.skintone
        
    if not skintone:
        return Response(
            {"error":"Skintone Anda belum diatur"},
            status = status.HTTP_400_BAD_REQUEST
            )
    
    try:
        Recommendation.objects.filter(user=user).delete()
        skintone_start_rgb = hex_to_rgb(skintone.hex_range_start)
        skintone_end_rgb = hex_to_rgb(skintone.hex_range_end)
        
        # response = requests.get('http://makeup-api.herokuapp.com/api/v1/products.json')
        # products = response.json()
        products = Product.objects.filter(product_type='foundation').prefetch_related('colors')
        
        recommendations = []
        
        for product in products:
            # product_colors = product.get('product_colors', [])
            for color in product.colors.all():
                try:
                    product_rgb = hex_to_rgb(color.hex_value)

                    # Hitung jarak warna ke skin tone
                    distance_start = color_distance(product_rgb, skintone_start_rgb)
                    distance_end = color_distance(product_rgb, skintone_end_rgb)

                    # Jika warna berada dalam range skin tone, tambahkan ke rekomendasi
                    if distance_start < 50 or distance_end < 50:
                        Recommendation.objects.get_or_create(
                            user=user,
                            skintone=skintone,
                            product=product,
                            color=color,
                        )
                        recommendations.append({
                            "product_id": product.product_id,
                            "brand": product.brand,
                            "name": product.product_name,
                            "price": product.price,
                            "price_sign": product.price_sign,
                            "currency": product.currency,
                            "image_link": product.image_url,
                            "product_link": product.product_link,
                            "description": product.description,
                            "product_type": product.product_type,
                            "product_colors": [
                                {
                                    "hex_value":color.hex_value,
                                    "color_name":color.color_name,
                                }
                                for color in product.colors.all()
                            ]
                        })
                except ValueError as ve:
                    continue

        return Response(
            {"message": "Rekomendasi berhasil dibuat dan disimpan", "recommendation":recommendations}, status=status.HTTP_201_CREATED)
    
    except Exception as e:
        return Response(
            {"error": str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

@api_view(['GET'])
@token_required
def get_recommendations(request):
    user = request.user
    recommendations = Recommendation.objects.filter(user=user).all()
    
    if not recommendations.exists():
        return Response(
            {"message":"Belum ada rekomendasi untuk pengguna ini."},status=status.HTTP_404_NOT_FOUND,
            )
    
    # PAKAI DICTIONARY PENGELOMPOKAN
    grouped_data = defaultdict(lambda:{
        "user_skintone":None,
        "product_name":None,
        "brand": None,
        "price": None,
        "image_link": None,
        "product_link": None,
        "description": None,
        "product_type": None,
        "recommended_colors": []
    })
    
    for rec in recommendations:
        key = rec.product.product_id
        if not grouped_data[key]["user_skintone"]:
            grouped_data[key].update({
                "user_skintone": rec.skintone.skintone_name,
                "product_name": rec.product.product_name,
                "brand": rec.product.brand,
                "price": rec.product.price,
                "image_link": rec.product.image_url,
                "product_link": rec.product.product_link,
                "description": rec.product.description,
                "product_type": rec.product.product_type,
            })
        grouped_data[key]["recommended_colors"].append({
            "hex_value":rec.color.hex_value,
            "color_name":rec.color.color_name
        })
    
    # MENGUBAH DEFAULTDICT KE LIST
    result = list(grouped_data.values())
    # data = [
    #     {
    #         "user_skintone": rec.skintone.skintone_name,
    #         "product_name": rec.product.product_name,
    #         "brand": rec.product.brand,
    #         "price": rec.product.price,
    #         "image_link": rec.product.image_url,
    #         "product_link": rec.product.product_link,
    #         "description": rec.product.description,
    #         "product_type": rec.product.product_type,
    #         "recommended_color":{
    #             "hex_value": rec.color.hex_value,
    #             "color_name": rec.color.color_name,
    #         },
    #     }
    #     for rec in recommendations
    # ]
    return Response({"recommendations": result}, status=status.HTTP_200_OK)