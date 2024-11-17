from django.contrib.auth import authenticate
from django.contrib.auth.hashers import make_password
from django.contrib.auth.hashers import check_password
from django.core.mail import send_mail
from django.conf import settings
from django.urls import reverse
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from rest_framework.exceptions import ValidationError
from api.models import Pengguna
from api.models import Role
import jwt
import requests
import random
import string

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
        
        # Cek apakah email sudah digunakan
        if Pengguna.objects.filter(email=email).exists():
            return Response({"error": "Email already used"}, status=status.HTTP_400_BAD_REQUEST)

        # Membuat pengguna baru
        role = Role.objects.get(role_id = '1')
        token = ''.join(random.choices(string.ascii_letters + string.digits, k=20))
        pengguna = Pengguna.objects.create(
            username=username, 
            password=make_password(password), 
            email=email,
            role_id=role,
            # verification_token = token,
            is_verified = False
        )

        # Generate verification token
        verification_link = f"http://localhost:8000/api/verify/{token}"
        # Kirim Email Verifikasi
        send_mail(
            'Verifikasi Akun Anda',
            f'Klik link berikut untuk verifikasi akun Anda: {verification_link}',
            settings.DEFAULT_FROM_EMAIL,
            [email],
            fail_silently=False,
        )
        # Kembalikan response sukses dengan data pengguna
        return Response({
            'username': pengguna.username,
            'email': pengguna.email,
            'role': pengguna.role_id,
            'message': 'User berhasil dibuat. Tolong verifikasi email'
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
    
@api_view(['GET'])
def verify_email(request, token):
    try:
        user = Pengguna.objects.get(verification_token=token)
        if user.is_verified:
            return Response({'message': 'Account already verified'}, status=status.HTTP_400_BAD_REQUEST)
        
        user.is_verified = True
        user.save()
        return Response({'message': 'Account verified successfully'}, status=status.HTTP_200_OK)
    except Pengguna.DoesNotExist:
        return Response({'error': 'Invalid token'}, status=status.HTTP_400_BAD_REQUEST)
