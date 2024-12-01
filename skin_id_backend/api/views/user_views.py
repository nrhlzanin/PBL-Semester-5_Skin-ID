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
        return Response({"error":"Username dan password diperlukan"},status=status.HTTP_400_BAD_REQUEST)
    
    try:
        # pengguna = Pengguna.objects.filter(email=username_or_email).first() or Pengguna.objects.filter(username=username_or_email).first()
        pengguna = Pengguna.objects.filter(email=email).first()
        if pengguna is None:
            return Response({'Error':'Email tidak ditemukan'}, status=status.HTTP_404_NOT_FOUND)
        if not check_password(password, pengguna.password):
            return Response({'Error':'Password salah'}, status=status.HTTP_400_BAD_REQUEST)
        
        header = {
        "alg": "HS256",  # Algoritma untuk tanda tangan
        "typ": "JWT"     # Jenis token
        }
        
        payload = {
            'id': pengguna.user_id,
            'username': pengguna.username,
            'email': pengguna.email,
            'exp': datetime.utcnow() + timedelta(hours=1),
        }
        
        token = jwt.encode(payload, settings.SECRET_KEY, algorithm='HS256', headers=header)
        # decoded_token = jwt.decode(token, settings.SECRET_KEY, algorithms=['HS256'])
        # print(decoded_token)
        
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
        return Response({'error':str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['PUT'])
@token_required
def edit_profile(request):
    pengguna = request.user
    data = request.data
    try:
        # Pembaruan data yg dikirim
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

        if 'profile_picture' in request.FILES:
            # Hapus foto profil lama jika ada
            if pengguna.profile_picture:
                pengguna.profile_picture.delete()
            pengguna.profile_picture = request.FILES['profile_picture']
            
        pengguna.save()
        
        return Response({
            'message':'Data pengguna berhasil diperbarui',
            'data': {
                'username' : pengguna.username,
                'email' : pengguna.email,
                'jenis_kelamin' : pengguna.jenis_kelamin,
                'profile_picture_url': request.build_absolute_uri(pengguna.profile_picture.url) if pengguna.profile_picture else None,
            }
        }, status=status.HTTP_200_OK)
        
    except Pengguna.DoesNotExist:
        print('An exception occurred')
        return Response({"error":"Pengguna tidak ditemukan"}, status=status.HTTP_404_NOT_FOUND)
    
    except Exception as e:
        return Response({"error": str(e)},status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
@token_required
def change_password(request):
    try:
        pengguna = request.user
        data = request.data
        old_password = data.get('old_password')
        new_password = data.get('new_password')

        if not pengguna.check_password(old_password):
            return Response({'error': 'Password lama salah'}, status=status.HTTP_400_BAD_REQUEST)

        # Perbarui password
        pengguna.set_password(new_password)
        pengguna.save()
        return Response({'message': 'Password berhasil diubah'}, status=status.HTTP_200_OK)
    
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


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
        return Response({
            'id': pengguna.user_id,
            'username': pengguna.username,
            'email': pengguna.email,
            'jenis kelamin': pengguna.jenis_kelamin,
            'skintone': pengguna.skintone_id if pengguna.skintone_id else "Not Set",
            'role': pengguna.role_id if pengguna.role_id else "Not Set",
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
@api_view(['GET'])
@token_required
def verify_email(request, token):
    try:
        pengguna = request.user
        if pengguna.is_verified:
            return Response({'message': 'Account already verified'}, status=status.HTTP_400_BAD_REQUEST)
        
        pengguna.is_verified = True
        pengguna.verification_token = None
        pengguna.save()
        
        refresh = RefreshToken.for_user(pengguna)
        return Response({
            'message': 'Account verified successfully',
            'access_token': str(refresh.access_token),
            'refresh_token': str(refresh),
            'user': {
                'id': pengguna.user_id,
                'username': pengguna.username,
                'email': pengguna.email,
                'skintone': pengguna.skintone_id if pengguna.skintone else None
            }
        }, status=status.HTTP_200_OK)        
    except Pengguna.DoesNotExist:
        return Response({'error': 'Invalid token'}, status=status.HTTP_400_BAD_REQUEST)

def send_verification_email(user):
    """
    Fungsi untuk mengirim email verifikasi ke pengguna
    """
    user_email = user.email
    token = user.verification_token
    verification_link = f"http://192.168.56.217:8000/api/user/verify-email/{token}/"

    subject = 'Verifikasi Akun Skin-ID'
    message = f'''
    Halo {user.username},
    Berikut adalah kode verifikasi untuk mengubah password akun Anda:
    {verification_link}

    Jika Anda tidak merasa mendaftar di aplikasi ini, abaikan pesan ini.
    '''

    send_mail(
        subject,
        message,
        settings.DEFAULT_FROM_EMAIL,  # Email pengirim (default di settings.py)
        [user_email],                # Email penerima
        fail_silently=False          # Jika ada error, jangan abaikan
    )
    
@api_view(['POST'])
def send_reset_password_otp(request):
    email = request.data.get('email')
    try:
        pengguna = Pengguna.objects.get(email=email)
        pengguna.set_reset_otp()

        # Kirim OTP melalui email
        send_mail(
            subject='Reset Password OTP',
            message=f"Kode OTP untuk mengatur ulang password Anda adalah: {pengguna.reset_otp}. Berlaku selama 10 menit.",
            from_email='noreply@yourapp.com',
            recipient_list=[email],
        )
        return Response({'message': 'OTP telah dikirim ke email Anda.'}, status=200)
    except Pengguna.DoesNotExist:
        return Response({'error': 'Email tidak ditemukan.'}, status=404)