from django.http import JsonResponse
from django.core.paginator import Paginator
from django.views.decorators.http import require_http_methods
import requests
from ..services.makeup_api import fetch_products_by_category
from django.contrib.auth.models import User
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.exceptions import ValidationError
from api.models import Pengguna
from api.models import SkinTone
from api.views.user_views import token_required 
from math import sqrt

@require_http_methods(["GET"])
def fetch_filtered_makeup_products(request):
    api_url = "http://makeup-api.herokuapp.com/api/v1/products.json"
    product_type = request.GET.get("product_type")
    product_name = request.GET.get("name")
    product_id = request.GET.get("product_id")
    # page = int(request.GET.get("page",1))
    try:
        response = requests.get(api_url)
        response.raise_for_status()
        
        makeup_data = response.json()
        # makeup_data = makeup_data[:5]
        # Untuk filter tiap kategori
        if product_type:
            makeup_data = [
                product for product in makeup_data
                if product.get("product_type") == product_type
            ]
        
        if product_name:
            product_name = product_name.lower()
            makeup_data = [
                product for product in makeup_data
                if product.get("name") and product_name in product.get("name").lower()
            ]
        
        if product_id:
            makeup_data = [
                product for product in makeup_data
                if str(product.get("id")) == product_id  # Cocokkan ID sebagai string
            ]

        # paginator = Paginator(makeup_data, 10)  # 50 produk per halaman
        # current_page = paginator.get_page(page)
        
        filtered_data = []
        for product in makeup_data:
            filtered_product = {
                "id": product.get("id"),
                "brand": product.get("brand"),
                "name": product.get("name"),
                "price": product.get("price"),
                "price_sign": product.get("price_sign"),
                "currency": product.get("currency"),
                "image_link": product.get("image_link"),
                "description": product.get("description"),
                "product_type": product.get("product_type"),
                "product_colors": product.get("product_colors")
            }
            filtered_data.append(filtered_product)
        
        # filtered_data = filtered_data[:1]
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
    try:
        user = request.user
        skintone = user.skintone
        
        if not skintone:
            return Response(
                {"error":"Skintone Anda belum diatur"},
                status = status.HTTP_400_BAD_REQUEST
                )
        
        skintone_start_rgb = hex_to_rgb(skintone.hex_range_start)
        skintone_end_rgb = hex_to_rgb(skintone.hex_range_end)
        
        response = requests.get('http://makeup-api.herokuapp.com/api/v1/products.json')
        products = response.json()
        
        recommendations = []
        
        for product in products:
            if 'product_type' in product and product['product_type'] == 'foundation':
                product_colors = product.get('product_colors', [])
                for color in product_colors:
                    try:
                        product_rgb = hex_to_rgb(color['hex_value'])

                        # Hitung jarak warna ke skin tone
                        distance_start = color_distance(product_rgb, skintone_start_rgb)
                        distance_end = color_distance(product_rgb, skintone_end_rgb)

                        # Jika warna berada dalam range skin tone, tambahkan ke rekomendasi
                        if distance_start < 50 or distance_end < 50:
                            recommendations.append({
                                "product_name": product['name'],
                                "product_type": product['product_type'],
                                "brand": product['brand'],
                                "colour_name": color['colour_name'],
                                "hex_value": color['hex_value'],
                                # "description":product['description']
                            })
                    except ValueError as ve:
                        continue

        return Response(
            {"recommendations": recommendations}, status=status.HTTP_200_OK)
    
    except Exception as e:
        return Response(
            {"error": str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
        