from django.contrib.auth import authenticate
from api.models import Pengguna
import requests
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from rest_framework.exceptions import ValidationError
from django.contrib.auth.hashers import make_password
from django.contrib.auth.hashers import check_password
import jwt
from django.conf import settings

@api_view(['POST'])
def register_user(request):
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

@api_view(['POST'])
def login_user(request):
    username = request.data.get('username')
    password = request.data.get('password')

    if not username or not password:
        raise ValidationError("Username dan password diperlukan")
    
    try:
        pengguna = Pengguna.objects.filter(username=username).first()
        # cek pengguna apakah sudah ada di database
        if pengguna is None:
            return Response({'Error':'Username dengan nama tersebut tidak ditemukan'}, status=status.HTTP_404_NOT_FOUND)
        # verifikasi password
        if not check_password(password, pengguna.password):
            return Response({'Error':'Password salah'}, status=status.HTTP_400_BAD_REQUEST)
        
        payload = {
            'user_id': pengguna.user_id,
            'username': pengguna.username,
            'email': pengguna.email,
        }
        
        token = jwt.encode(payload, settings.SECRET_KEY, algorithm='HS256')
        
        return Response({
            'message': 'Login berhasil',
            'token': token,
            'user': {
                'id': pengguna.user_id,
                'username': pengguna.username,
                'email': pengguna.email
            }
        }, status=status.HTTP_200_OK)
    
    except Exception as e:
        return Response({'error':str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)