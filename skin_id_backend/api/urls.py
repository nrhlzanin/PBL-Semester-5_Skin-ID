from django.contrib import admin
from django.urls import path, include
from . import views
from .ml_model import predict_skin_tone_view
from .makeup_product import fetch_filtered_makeup_products

urlpatterns = [
    path('admin/', admin.site.urls),
    path('makeup-products/', fetch_filtered_makeup_products, name='makeup-products'),
    path('predict/', predict_skin_tone_view, name='predict-skin-tone')
]
