from django.conf import settings
from django.urls import path
from django.conf.urls.static import static
from api.views.user_views import register_user, login_user, edit_profile, user_logout, get_user_profile, verify_email
from api.machine_learning.ml_model import predict_skin_tone_view, update_skintone
from api.views.makeup_product import fetch_filtered_makeup_products, fetch_makeup_products, recommend_product, get_recommendations
urlpatterns = [
    path('register/', register_user, name='register'),
    path('login/', login_user, name='login'),
    path('profile/', get_user_profile, name='get-user-profile'),
    path('edit-profile/', edit_profile, name='edit-user-profile'),
    path('logout/', user_logout, name='logout'),
    path('verify-email/<str:token>/', verify_email, name='verify_email'),
    path('makeup-products/', fetch_filtered_makeup_products, name='makeup-products'),
    path('all-makeup-products/', fetch_makeup_products, name='all-makeup-products'),
    path('predict/', predict_skin_tone_view, name='predict-skin-tone'),
    path('update-skintone/',update_skintone, name='update-skintone'),
    path('recommendations/', recommend_product, name='make-recommendation'),
    path('get-recommendations/', get_recommendations, name='get-recommendation'),
]