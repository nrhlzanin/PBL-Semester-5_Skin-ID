from django.urls import path
from api.views.user_views import register_user, login_user, verify_email
from api.machine_learning.ml_model import predict_skin_tone_view
from api.views.makeup_product import fetch_filtered_makeup_products
urlpatterns = [
    path('register/', register_user, name='register'),
    path('login/', login_user, name='login'),
    path('verify-email/<str:token>/', verify_email, name='verify_email'),
    path('makeup-products/', fetch_filtered_makeup_products, name='makeup-products'),
    path('predict/', predict_skin_tone_view, name='predict-skin-tone'),
]
