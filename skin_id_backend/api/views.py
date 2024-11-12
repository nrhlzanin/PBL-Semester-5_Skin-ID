from api.models import User
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
import requests
from .services.makeup_api import fetch_products_by_category
from django.contrib.auth.models import User
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.exceptions import ValidationError
