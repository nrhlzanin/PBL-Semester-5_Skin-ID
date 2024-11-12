from django.contrib import admin
from django.urls import path, include
from . import views
from .ml_model import predict_skin_tone_view
from .makeup_product import fetch_filtered_makeup_products
from .login_register import register_user
from .login_register import login_user

urlpatterns = [
    path('admin/', admin.site.urls),
    path('login/',login_user, name='login-user'),
    path('register/',register_user, name='register-user'),
    path('makeup-products/', fetch_filtered_makeup_products, name='makeup-products'),
    path('predict/', predict_skin_tone_view, name='predict-skin-tone')
]
