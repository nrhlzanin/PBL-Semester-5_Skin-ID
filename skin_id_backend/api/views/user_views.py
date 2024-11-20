from django.contrib.auth.hashers import make_password
from django.contrib.auth.hashers import check_password
from django.contrib.auth import authenticate
from rest_framework.response import Response
from django.core.mail import send_mail
from django.conf import settings
from django.views.decorators.csrf import csrf_exempt
from rest_framework.decorators import api_view
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.response import Response
from rest_framework import status
from rest_framework.exceptions import ValidationError
from api.models import Pengguna
from api.models import Role
import uuid
import jwt
import requests
import random
import string

@api_view(['POST'])
@csrf_exempt
def register_user(request):
    username = request.data.get('username')
    password = request.data.get('password')
    email = request.data.get('email')

    if not username or not password or not email:
        return Response({"error": "Username, email, dan password diperlukan"}, status=status.HTTP_400_BAD_REQUEST)
    try:    
        if Pengguna.objects.filter(username=username).exists():
            return Response({"error": "Username sudah digunakan"}, status=status.HTTP_400_BAD_REQUEST)

        if Pengguna.objects.filter(email=email).exists():
            return Response({"error": "Email sudah digunakan"}, status=status.HTTP_400_BAD_REQUEST)

        role = Role.objects.get(role_id = 1)  # Pastikan role_name sudah benar

        pengguna = Pengguna.objects.create(
            username=username,
            password=make_password(password),
            email=email,
            role_id=role,
        )

        # Buat token JWT
        payload = {
            'user_id': pengguna.user_id,
            'username': pengguna.username,
            'email': pengguna.email,
        }
        token = jwt.encode(payload, settings.SECRET_KEY, algorithm='HS256')

        return Response({
                'message': 'Pendaftaran berhasil',
                'token': token,
                'user': {
                    'id': pengguna.user_id,
                    'username': pengguna.username,
                    'email': pengguna.email
                }
            }, status=status.HTTP_201_CREATED)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

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
        user.verification_token = None
        user.save()
        
        refresh = RefreshToken.for_user(user)
        return Response({
            'message': 'Account verified successfully',
            'access_token': str(refresh.access_token),
            'refresh_token': str(refresh),
            'user': {
                'id': user.user_id,
                'username': user.username,
                'email': user.email,
                'skintone': user.skintone_id if user.skintone else None
            }
        }, status=status.HTTP_200_OK)        
    except Pengguna.DoesNotExist:
        return Response({'error': 'Invalid token'}, status=status.HTTP_400_BAD_REQUEST)

def send_verification_email(user):
    """
    Fungsi untuk mengirim email verifikasi ke pengguna
    """
    # Ambil email pengguna
    user_email = user.email

    # Buat token verifikasi
    token = user.verification_token
    # uid = urlsafe_base64_encode(force_bytes(user.pk))

    # Buat URL untuk link verifikasi
    # verification_link = f"http://192.168.1.7:8000/api/user/verify-email/{uid}/{token}/"
    verification_link = f"http://192.168.56.217:8000/api/user/verify-email/{token}/"

    # Subjek dan isi email
    subject = 'Verifikasi Akun Skin-ID'
    message = f'''
    Halo {user.username},
    Berikut adalah kode verifikasi untuk mengubah password akun Anda:
    {verification_link}

    Jika Anda tidak merasa mendaftar di aplikasi ini, abaikan pesan ini.
    '''

    # Kirim email
    send_mail(
        subject,
        message,
        settings.DEFAULT_FROM_EMAIL,  # Email pengirim (default di settings.py)
        [user_email],                # Email penerima
        fail_silently=False          # Jika ada error, jangan abaikan
    )