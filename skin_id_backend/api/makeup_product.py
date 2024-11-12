from api.models import User
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
import requests
from .services.makeup_api import fetch_products_by_category
from django.contrib.auth.models import User
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.exceptions import ValidationError

# @api_view(['POST'])
@require_http_methods(["GET"])
def fetch_filtered_makeup_products(request):
    api_url = "http://makeup-api.herokuapp.com/api/v1/products.json"
    
    try:
        response = requests.get(api_url)
        response.raise_for_status()
        
        makeup_data = response.json()
        
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
        
        filtered_data = filtered_data[:5]
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
        data = []
        
        # Mengembalikan data dalam bentuk JSON response
        return JsonResponse(data, safe=False)
    
    except requests.exceptions.RequestException as e:
        return JsonResponse({"error": str(e)}, status=500)

