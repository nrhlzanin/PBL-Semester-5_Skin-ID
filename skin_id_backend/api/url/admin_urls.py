from django.urls import path
from api.views.admin_views import dashboard

urlpatterns = [
    path('dashboard/', dashboard, name='dashboard')
]
