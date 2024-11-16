from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import numpy as np
import cv2
import joblib
from sklearn.preprocessing import StandardScaler
from PIL import Image
import os
from django.conf import settings
from django.views.decorators.http import require_POST

# Mendapatkan path file model dan scaler
MODEL_PATH = os.path.join(settings.BASE_DIR, 'api/machine_learning/knn_skin_tone_model_hsv_optimized_smote.pkl')
SCALER_PATH = os.path.join(settings.BASE_DIR, 'api/machine_learning/scaler_model_hsv_optimized_smote.pkl')
HAARCASCADE = os.path.join(settings.BASE_DIR, 'api/machine_learning/haarcascade_frontalface_default.xml')

# Load model dan scaler
knn_model = joblib.load(MODEL_PATH)
scaler = joblib.load(SCALER_PATH)

# Mapping hasil prediksi ke kategori skin tone
fitzpatrick_map_reverse = {
    1: "Very Light",
    2: "Light",
    3: "Medium",
    4: "Olive",
    5: "Brown",
    6: "Dark"
}
face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')

# Fungsi untuk prediksi skin tone
def predict_skin_tone(image):
    # Menggunakan Haar Cascade untuk mendeteksi wajah
    gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray_image, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))

    if len(faces) == 0:
        return "No face detected"

    # Jika wajah ditemukan, ambil wajah pertama yang terdeteksi
    (x, y, w, h) = faces[0]
    face_region = image[y:y+h, x:x+w]  # Ambil area wajah
    
    hsv_image = cv2.cvtColor(face_region, cv2.COLOR_BGR2HSV)
    
    h_mean = np.mean(hsv_image[:, :, 0])
    s_mean = np.mean(hsv_image[:, :, 1])
    v_mean = np.mean(hsv_image[:, :, 2])
    
    features = np.array([[h_mean, s_mean, v_mean]])
    features_scaled = scaler.transform(features)
    
    prediction = knn_model.predict(features_scaled)
    predicted_label = int(prediction[0])
    
    skin_tone = fitzpatrick_map_reverse.get(predicted_label, "Unknown")
    
    return skin_tone

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
