from django.urls import path
from api.views.user_views import register_user, login_user, get_user_profile, verify_email
from api.machine_learning.ml_model import predict_skin_tone_view
from api.views.recomendation_views import recommend_foundation_by_skin_tone
from api.views.makeup_product import fetch_filtered_makeup_products, fetch_makeup_products
urlpatterns = [
    path('register/', register_user, name='register'),
    path('login/', login_user, name='login'),
    path('profile/', get_user_profile, name='get-user'),
    path('verify-email/<str:token>/', verify_email, name='verify_email'),
    path('makeup-products/', fetch_filtered_makeup_products, name='makeup-products'),
    path('all-makeup-products/', fetch_makeup_products, name='all-makeup-products'),
    path('predict/', predict_skin_tone_view, name='predict-skin-tone'),
    path('recomendations/', recommend_foundation_by_skin_tone, name='foundation-recommendation'),
]
