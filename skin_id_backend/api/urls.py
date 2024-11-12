from django.contrib import admin
from django.urls import path, include
from . import views
from .ml_model import predict_skin_tone_view
from .views import fetch_makeup_products
from .views import fetch_filtered_makeup_products
from .login_register import register_user

urlpatterns = [
    path('admin/', admin.site.urls),
    path('register/',register_user, name='register-user'),
    path('makeup-products/', fetch_makeup_products, name='makeup-products'),
    path('filtered-makeup-products/', fetch_filtered_makeup_products, name='filtered-makeup-products'),
    path('predict/', predict_skin_tone_view, name='predict-skin-tone')
]
