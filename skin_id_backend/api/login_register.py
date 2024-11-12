from api.models import Pengguna
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
import requests
from django.contrib.auth.hashers import make_password
from .services.makeup_api import fetch_products_by_category
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.exceptions import ValidationError

@api_view(['POST'])
def register_user(request):
    """
    Endpoint untuk registrasi pengguna baru
    """
    if request.method == 'POST':
        # Ambil data dari request
        username = request.data.get('username')
        password = request.data.get('password')
        email = request.data.get('email')

        # Validasi input
        if not username or not password or not email:
            raise ValidationError("Username, email, dan password diperlukan")

        # Cek apakah username sudah ada
        if Pengguna.objects.filter(username=username).exists():
            return Response({'error': 'Username sudah digunakan'}, status=status.HTTP_400_BAD_REQUEST)

        # Membuat pengguna baru
        pengguna = Pengguna.objects.create(
            username=username, 
            password=make_password(password), 
            email=email)

        # Kembalikan response sukses dengan data pengguna
        return Response({
            'username': pengguna.username,
            'email': pengguna.email,
            'message': 'User berhasil dibuat'
        }, status=status.HTTP_201_CREATED)
        