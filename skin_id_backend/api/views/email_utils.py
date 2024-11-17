from django.core.mail import send_mail, EmailMessage
from django.conf import settings
from django.utils.http import urlsafe_base64_encode
from django.utils.encoding import force_bytes
from django.template.loader import render_to_string
from django.contrib.auth.tokens import default_token_generator
from api.models import Pengguna
from django.urls import reverse

# Fungsi untuk mengirim email verifikasi
def send_verification_email(user):
    # Mendapatkan email pengguna
    user_email = user.email

    # Membuat token verifikasi
    token = default_token_generator.make_token(user)
    uid = urlsafe_base64_encode(force_bytes(user.pk))
    
    # URL untuk link verifikasi
    verification_link = f"http://localhost:8000/api/verify-email/{uid}/{token}/"

    # Subjek dan isi email
    subject = 'Verifikasi Akun Anda'
    message = f'''
    Halo {user.username},
    Terima kasih telah mendaftar. Silakan klik link berikut untuk verifikasi akun Anda:
    {verification_link}
    '''

    # Mengirim email
    send_mail(
        subject,
        message,
        settings.DEFAULT_FROM_EMAIL,
        [user_email],
        fail_silently=False,
    )
