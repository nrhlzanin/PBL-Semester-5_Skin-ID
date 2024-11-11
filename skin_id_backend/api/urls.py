from django.contrib import admin
from django.urls import path, include
from . import views
from .views import fetch_makeup_products
from .views import fetch_filtered_makeup_products
from .login_register import register_user

urlpatterns = [
    path('admin/', admin.site.urls),
    path('register/',register_user, name='register-user'),
    path('makeup-products/', fetch_makeup_products, name='makeup-products'),
    path('fetch_makeup_products/', fetch_filtered_makeup_products, name='filtered-makeup-products')
]
