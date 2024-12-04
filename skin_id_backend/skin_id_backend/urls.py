from django.conf import settings
from django.contrib import admin
from django.urls import path, include
from django.conf.urls.static import static

urlpatterns = [
    path('api/user/', include('api.url.user_urls')),
    path('api/admin/', include('api.url.admin_urls')),
    
]+ static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
