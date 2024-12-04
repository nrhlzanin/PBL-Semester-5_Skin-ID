from api.models import Pengguna, SkinTone
from api.views.user_views import token_required
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from django.conf import settings
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from rest_framework.exceptions import ValidationError
from sklearn.preprocessing import StandardScaler
from PIL import Image
import numpy as np
import cv2
import joblib
import os
import mediapipe as mp

# Mendapatkan path file model dan scaler
MODEL_PATH = os.path.join(settings.BASE_DIR, 'api/machine_learning/knn_skin_tone_model_hsv_optimized_smote.pkl')
SCALER_PATH = os.path.join(settings.BASE_DIR, 'api/machine_learning/scaler_model_hsv_optimized_smote.pkl')
HAARCASCADE = os.path.join(settings.BASE_DIR, 'api/machine_learning/haarcascade_frontalface_default.xml')

# Load model dan scaler
knn_model = joblib.load(MODEL_PATH)
scaler = joblib.load(SCALER_PATH)

# Mapping hasil prediksi ke kategori skin tone
fitzpatrick_map_reverse = {
    1: "very_light",
    2: "light",
    3: "medium",
    4: "brown",
    5: "dark"
}
face_cascade = cv2.CascadeClassifier(HAARCASCADE)

# Fungsi untuk prediksi skin tone
def predict_skin_tone(image):
    gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray_image, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))

    if len(faces) == 0:
        return "No face detected"

    (x, y, w, h) = faces[0]
    face_region = image[y:y+h, x:x+w]  
    
    hsv_image = cv2.cvtColor(face_region, cv2.COLOR_BGR2HSV)
    
    h_mean = np.mean(hsv_image[:, :, 0])
    s_mean = np.mean(hsv_image[:, :, 1])
    v_mean = np.mean(hsv_image[:, :, 2])
    
    features = np.array([[h_mean, s_mean, v_mean]])
    features_scaled = scaler.transform(features)
    
    prediction = knn_model.predict(features_scaled)
    predicted_label = int(prediction[0])
    print(f"Prediction result: {predicted_label}")
    
    return fitzpatrick_map_reverse.get(predicted_label,"Unknown")
    
           
@api_view(['POST'])
@token_required
def update_skintone(request):
    user = request.user
    image_file = request.FILES.get('image')
    
    if image_file is None:
        return Response({"error":"No image provided"},status=status.HTTP_400_BAD_REQUEST)
    
    try:
        image = Image.open(image_file)
        image = cv2.cvtColor(np.array(image), cv2.COLOR_RGB2BGR)
        skin_tone_name = predict_skin_tone(image)
        print(f"Predicted skin tone: {skin_tone_name}")  # Log output untuk debugging

        if skin_tone_name == "No face detected":
            return Response(
                {"error": "No face detected in the image. Please try again with a clear face image."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if skin_tone_name == "Unknown":
            return Response(
                {"error": "The predicted skin tone is unknown. Please try again."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        skin_tone = SkinTone.objects.filter(skintone_name=skin_tone_name).first()
        if not skin_tone:
            return Response(
                {"error": f"Skin tone '{skin_tone_name}' not found in database"}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Update skintone
        # skintone_id = prediction["skintone_id"]
        # skintone = SkinTone.objects.get(pk=skintone_id)
        user.skintone = skin_tone
        user.save()

        return Response({
            "message": "Skin tone berhasil diperbarui.",
            "skintone_name": skin_tone.skintone_name,
            "skintone_id": skin_tone.skintone_id,
        }, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({"error try": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@require_POST
@csrf_exempt
def predict_skin_tone_view(request):
    print(f"Received request method: {request.method}")
    if request.method == 'POST':
        image_file = request.FILES.get('image')
        if image_file is None:
            return JsonResponse({'error': 'No image file provided'}, status=400)
        
        # Membaca gambar dari request
        image = Image.open(image_file)
        image = cv2.cvtColor(np.array(image), cv2.COLOR_RGB2BGR)
        
        # Prediksi warna kulit
        skin_tone = predict_skin_tone(image)
        
        return JsonResponse({'skin_tone': skin_tone})
    elif request.method=='GET':
        return JsonResponse({'message':'Endpoint ini hanya menerima POST request'})
    
    return JsonResponse({'error': 'Invalid request method bang'}, status=405)
