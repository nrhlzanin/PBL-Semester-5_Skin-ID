
from django.contrib.auth.hashers import make_password
from django.contrib.auth.hashers import check_password
from django.contrib.auth import authenticate
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
from django.utils import timezone
from django.http import JsonResponse
from functools import wraps
from datetime import datetime, timedelta
import uuid
import jwt
import requests
import random
import secrets

# Pembuatan untuk verifikasi token pengguna/user
def token_required(f):
    @wraps(f)
    def decorated_function(request, *args, **kwargs):
        token = request.headers.get('Authorization')
        if token:
            token = token.replace('Bearer ','', 1)
        if not token:
            return Response({"error":"Token is required"},status=status.HTTP_401_UNAUTHORIZED)
        user = Pengguna.objects.filter(token=token).first()
        if not user:
            return Response({"error":"Token invalid atau kadaluarsa"},status=status.HTTP_401_UNAUTHORIZED)
        
        print(f"Received token: {token}")
        print(f"Database token: {user.token}")

        request.user = user
        return f(request, *args, **kwargs)
    return decorated_function
    
@api_view(['POST'])
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

        # role = Role.objects.get(role_id = 1)  # Pastikan role_name sudah benar

        pengguna = Pengguna.objects.create(
            username=username,
            password=make_password(password),
            email=email,
            role_id=1,
        )

        return Response({
                'message': 'Pendaftaran berhasil',
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
    email = request.data.get('email')
    password = request.data.get('password')

    if not email or not password:
        return Response({"error": "Username dan password diperlukan"}, status=status.HTTP_400_BAD_REQUEST)

    try:
        pengguna = Pengguna.objects.filter(email=email).first()
        if pengguna is None:
            return Response({'Error': 'Email tidak ditemukan'}, status=status.HTTP_404_NOT_FOUND)

        # Menggunakan check_password untuk memverifikasi hash password
        if not check_password(password, pengguna.password):
            return Response({'Error': 'Password salah'}, status=status.HTTP_400_BAD_REQUEST)

        # Jika password benar, lanjutkan pembuatan token JWT
        header = {
            "alg": "HS256",
            "typ": "JWT"
        }

        payload = {
            'id': pengguna.user_id,
            'username': pengguna.username,
            'email': pengguna.email,
            'exp': datetime.utcnow() + timedelta(hours=1),
        }

        token = jwt.encode(payload, settings.SECRET_KEY, algorithm='HS256', headers=header)

        pengguna.token = token
        pengguna.last_login = timezone.now()
        pengguna.save()

        return Response({
            'message': 'Login berhasil',
            'token': token,
            'user': {
                'id pengguna': pengguna.user_id,
                'username': pengguna.username,
                'email': pengguna.email
            }
        }, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['PUT'])
@token_required
def edit_profile(request):
    pengguna = request.user
    data = request.data
    try:
        print("Request data:", request.data)
        print("Request files:", request.FILES)
        
        if 'username' in data:
            pengguna.username = data['username']
        
        if 'email' in data:
            email = data['email']
            if Pengguna.objects.filter(email=email).exclude(pk=pengguna.pk).exists():
                return Response (
                    {
                    "error":"Email sudah digunakan oleh pengguna lain."
                },status=status.HTTP_400_BAD_REQUEST
                                 )
            pengguna.email = email
        
        if 'jenis_kelamin' in data:
            pengguna.jenis_kelamin = data['jenis_kelamin']
        
        if 'old_password' in data and 'new_password' in data:
            old_password = data['old_password']
            new_password = data['new_password']
            
            if not check_password(old_password, pengguna.password):
                return Response({
                    "error": "Password lama tidak sesuai."
                }, status=status.HTTP_400_BAD_REQUEST)
            
            pengguna.password = make_password(new_password)
        
        if 'profile_picture' in request.FILES:
            profile_picture = request.FILES['profile_picture']
            pengguna.profile_picture = profile_picture
        
            MAX_FILE_SIZE = 5 * 1024 * 1024  # 5 MB
            if profile_picture.size > MAX_FILE_SIZE:
                return Response({"error": "Ukuran gambar terlalu besar. Maksimal 5 MB."}, status=status.HTTP_400_BAD_REQUEST)

        pengguna.save()
        return Response({
            'message':'Data pengguna berhasil diperbarui',
            'data': {
                'username' : pengguna.username,
                'email' : pengguna.email,
                'jenis_kelamin' : pengguna.jenis_kelamin,
                'profile_picture_url': pengguna.profile_picture.url if pengguna.profile_picture else None
            }
        }, status=status.HTTP_200_OK)
        
    except Pengguna.DoesNotExist:
        print('An exception occurred in edit profile')
        return Response({"error":"Pengguna tidak ditemukan"}, status=status.HTTP_404_NOT_FOUND)
    
    except Exception as e:
        return Response({"error": str(e)},status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
@token_required
def user_logout(request):
    try:
        token = request.data.get('token')
        if not token:
            return Response({"message": "Token dibutuhan"}, status=status.HTTP_400_BAD_REQUEST)
    
        pengguna = Pengguna.objects.filter(token=token).first()
        if not pengguna:
            return Response({"error":"Token is required"},status=status.HTTP_400_BAD_REQUEST)
        
        pengguna.token = None
        pengguna.save()
        
        return Response({"message":"Logout berhasil!"}, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['GET'])
@token_required
def get_user_profile(request):
    try:
        pengguna = request.user
        profile_picture_url = request.build_absolute_uri(pengguna.profile_picture.url) if pengguna.profile_picture else "https://www.example.com/default-profile-pic.jpg"
        return Response({
            'id': pengguna.user_id,
            'username': pengguna.username,
            'email': pengguna.email,
            'jenis kelamin': pengguna.jenis_kelamin,
            'skintone': pengguna.skintone_id if pengguna.skintone_id else "Not Set",
            'role': pengguna.role_id if pengguna.role_id else "Not Set",
            'profile_picture': profile_picture_url,
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
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
