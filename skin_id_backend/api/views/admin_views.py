from django.contrib.auth import authenticate
import requests
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from rest_framework.exceptions import ValidationError
from django.contrib.auth.hashers import make_password
from django.contrib.auth.hashers import check_password
import jwt
from django.conf import settings

@api_view(['GET'])
def dashboard(request):
    return Response({'message': 'Welcome to Admin Dashboard'}, status=200)