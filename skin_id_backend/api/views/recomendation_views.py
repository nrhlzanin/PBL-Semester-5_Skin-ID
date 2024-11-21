from django.shortcuts import get_object_or_404
from django.http import JsonResponse
from api.models import SkinTone
import requests

def hex_to_rgb(hex_color):
    """
    Mengonversi warna HEX ke RGB.
    """
    hex_color = hex_color.lstrip("#")
    return tuple(int(hex_color[i:i + 2], 16) for i in (0, 2, 4))

def color_distance(rgb1, rgb2):
    return sum((c1 - c2) ** 2 for c1, c2 in zip(rgb1, rgb2)) ** 0.5

def recommend_foundation_by_skin_tone(request, skintone_id):
    # Ambil skin tone yang dipilih
    skin_tone = get_object_or_404(SkinTone, skintone_id=skintone_id)

    # Ambil rentang warna HEX dari skin tone
    hex_start = skin_tone.hex_range_start
    hex_end = skin_tone.hex_range_end

    # Konversi HEX ke RGB
    rgb_start = hex_to_rgb(hex_start)
    rgb_end = hex_to_rgb(hex_end)

    api_url = "http://makeup-api.herokuapp.com/api/v1/products.json"
    response = requests.get(api_url)
    response.raise_for_status()
    makeup_data = response.json()

    recommended_products = []

    for product in makeup_data:
        product_hex = product.get("product_colors", [{}])[0].get("hex")  # Ambil warna HEX pertama
        if product_hex:
            product_rgb = hex_to_rgb(product_hex)
            distance_start = color_distance(product_rgb, rgb_start)
            distance_end = color_distance(product_rgb, rgb_end)

            # Tentukan jika warna produk berada dalam rentang yang diinginkan
            if distance_start < 50 and distance_end < 50:  # Threshold sesuai keinginan
                recommended_products.append({
                    "id": product.get("id"),
                    "name": product.get("name"),
                    "brand": product.get("brand"),
                    "price": product.get("price"),
                    "image_link": product.get("image_link"),
                    "product_type": product.get("product_type"),
                })

    return JsonResponse(recommended_products, safe=False, status=200)
