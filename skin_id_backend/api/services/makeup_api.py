import requests

BASE_URL = "http://makeup-api.herokuapp.com/api/v1/products.json"

def fetch_products_by_category(category):
    try:
        response = requests.get(BASE_URL, params={"product_type": category})
        response.raise_for_status()  # Cek jika ada error HTTP
        products = response.json()
        return products
    except requests.exceptions.RequestException as e:
        print(f"Error fetching products: {e}")
        return []
