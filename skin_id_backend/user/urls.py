from django.contrib import admin
from django.urls import path, include
from .login_register import register_user
from .login_register import login_user

urlpatterns = [
    path('admin/', admin.site.urls),
    path('login/',login_user, name='login-user'),
    path('register/',register_user, name='register-user'),
]
