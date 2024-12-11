import numpy as np
import os
import cv2
import matplotlib.pyplot as plt
import random
from sklearn.model_selection import train_test_split, RandomizedSearchCV
from sklearn.preprocessing import MinMaxScaler, LabelEncoder
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import accuracy_score, classification_report, recall_score, f1_score
from sklearn.preprocessing import StandardScaler
import joblib
from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay
from collections import Counter
import mediapipe as mp
from sklearn.impute import SimpleImputer
from sklearn.model_selection import GridSearchCV
from imblearn.over_sampling import SMOTE, ADASYN
import seaborn as sns

# Directory dataset
dataset_dir = r'E:\ML model\mst-e_data'

data = []
labels = []

# Fitzpatrick skin tone mapping
folder_to_fitzpatrick = {
    "brown": "brown", 
    "dark": "dark", 
    "light": "light", 
    "medium": "medium",  
    "very_light": "very_light"
}

fitzpatrick_map = {
    "very_light": 1, "light": 2, "medium": 3, "brown": 4, "dark": 5
}

# MediaPipe Face Detection setup
mp_face_detection = mp.solutions.face_detection

def preprocess_skin(image, visualize=False):
    # Menggunakan deteksi wajah MediaPipe
    with mp_face_detection.FaceDetection(model_selection=1, min_detection_confidence=0.2) as face_detection:
        rgb_image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        results = face_detection.process(rgb_image)
        # Jika wajah terdeteksi, ambil area wajah
        if results.detections:
            for detection in results.detections:
                bboxC = detection.location_data.relative_bounding_box
                h, w, _ = image.shape
                x, y, w_box, h_box = int(bboxC.xmin * w), int(bboxC.ymin * h), int(bboxC.width * w), int(bboxC.height * h)
                face_region = image[y:y+h_box, x:x+w_box]

                if face_region is None or face_region.size == 0:
                    print(f"Warning: Empty face region in image")
                    return None

                face_resized = cv2.resize(face_region, (64, 64)) if w_box > 64 or h_box > 64 else face_region
                hsv_image = cv2.cvtColor(face_resized, cv2.COLOR_BGR2HSV)
                H, S, V = cv2.split(hsv_image)

                # Median brightness untuk menyesuaikan rentang HSV
                median_v = np.median(V)
                if median_v < 50:  # Kondisi gelap
                    lower_skin = np.array([0, 5, 20])
                    upper_skin = np.array([40, 150, 200])
                elif median_v > 200:  # Kondisi terang
                    lower_skin = np.array([0, 20, 60])
                    upper_skin = np.array([35, 170, 255])
                else:  # Kondisi normal
                    lower_skin = np.array([0, 10, 40])
                    upper_skin = np.array([35, 170, 255])

                skin_mask = cv2.inRange(hsv_image, lower_skin, upper_skin)

                # Adaptive thresholding untuk memperbaiki hasil masking
                adaptive_mask = cv2.adaptiveThreshold(
                    V,
                    255,
                    cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
                    cv2.THRESH_BINARY,
                    11,
                    2
                )
                skin_mask = cv2.bitwise_and(skin_mask, adaptive_mask)

                # Proses morfologi untuk memperbaiki hasil segmentasi
                kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (7, 7))
                skin_mask = cv2.morphologyEx(skin_mask, cv2.MORPH_CLOSE, kernel)
                skin_region = cv2.bitwise_and(face_resized, face_resized, mask=skin_mask)

                if visualize:
                    plt.figure(figsize=(10, 5))
                    plt.subplot(1, 3, 1)
                    plt.imshow(cv2.cvtColor(face_resized, cv2.COLOR_BGR2RGB))
                    plt.title("Face Region")
                    plt.subplot(1, 3, 2)
                    plt.imshow(skin_mask, cmap='gray')
                    plt.title("Skin Mask")
                    plt.subplot(1, 3, 3)
                    plt.imshow(cv2.cvtColor(skin_region, cv2.COLOR_BGR2RGB))
                    plt.title("Final Skin Region after Masking")
                    plt.show()

                h_mean = np.mean(H[skin_mask > 0])
                s_mean = np.mean(S[skin_mask > 0])
                v_mean = np.mean(V[skin_mask > 0])
                return [h_mean, s_mean, v_mean]

        # Jika wajah tidak terdeteksi, ekstrak fitur dari gambar keseluruhan
        else:
            hsv_image = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
            H, S, V = cv2.split(hsv_image)

            # Median brightness untuk menyesuaikan rentang HSV
            median_v = np.median(V)
            if median_v < 50:  # Kondisi gelap
                lower_skin = np.array([0, 5, 20])
                upper_skin = np.array([40, 150, 200])
            elif median_v > 200:  # Kondisi terang
                lower_skin = np.array([0, 20, 60])
                upper_skin = np.array([35, 170, 255])
            else:  # Kondisi normal
                lower_skin = np.array([0, 10, 40])
                upper_skin = np.array([35, 170, 255])

            skin_mask = cv2.inRange(hsv_image, lower_skin, upper_skin)

            # Adaptive thresholding untuk memperbaiki hasil masking
            adaptive_mask = cv2.adaptiveThreshold(
                V,
                255,
                cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
                cv2.THRESH_BINARY,
                11,
                2
            )
            skin_mask = cv2.bitwise_and(skin_mask, adaptive_mask)

            # Proses morfologi untuk memperbaiki hasil segmentasi
            kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (7, 7))
            skin_mask = cv2.morphologyEx(skin_mask, cv2.MORPH_CLOSE, kernel)
            skin_region = cv2.bitwise_and(image, image, mask=skin_mask)

            if visualize:
                plt.figure(figsize=(10, 5))
                plt.subplot(1, 3, 1)
                plt.imshow(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))
                plt.title("Whole Image")
                plt.subplot(1, 3, 2)
                plt.imshow(skin_mask, cmap='gray')
                plt.title("Skin Mask")
                plt.subplot(1, 3, 3)
                plt.imshow(cv2.cvtColor(skin_region, cv2.COLOR_BGR2RGB))
                plt.title("Final Skin Region after Masking")
                plt.show()

            h_mean = np.mean(H[skin_mask > 0])
            s_mean = np.mean(S[skin_mask > 0])
            v_mean = np.mean(V[skin_mask > 0])
            return [h_mean, s_mean, v_mean]

    print(f"Warning: No face detected in image")
    return None


# Loop untuk membaca gambar dan mengekstrak fitur hanya jika wajah terdeteksi
for subject_folder in os.listdir(dataset_dir):
    folder_path = os.path.join(dataset_dir, subject_folder)
    if os.path.isdir(folder_path):
        fitzpatrick_label = folder_to_fitzpatrick.get(subject_folder)
        if fitzpatrick_label is None:
            continue
        label = fitzpatrick_map[fitzpatrick_label]
        for image_name in os.listdir(folder_path):
            image_path = os.path.join(folder_path, image_name)
            image = cv2.imread(image_path)
            if image is not None:
                skin_features = preprocess_skin(image)
                # Hanya ditambahkan ketika wajah terdeteksi
                if skin_features is not None:
                    data.append(skin_features)
                    labels.append(label)

# Konversi data dan label ke dalam array
data = np.array(data)
labels = np.array(labels)

# Tangani NaN jika ada
# if np.any(np.isnan(data)):
#     print("Ada nilai NaN pada data. Menangani NaN...")
#     imputer = SimpleImputer(strategy='mean')
#     data = imputer.fit_transform(data)

# Label encoding
label_encoder = LabelEncoder()
labels = label_encoder.fit_transform(labels)

# SMOTE untuk menangani imbalanced class
smote = SMOTE(random_state=42)
X_resampled, y_resampled = smote.fit_resample(data, labels)

# Stratified Split setelah SMOTE
X_train, X_test, y_train, y_test = train_test_split(
    X_resampled, y_resampled, test_size=0.2, stratify=y_resampled, random_state=42
)

# Normalisasi data
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Membuat model KNN
knn = KNeighborsClassifier()
# Daftar hyperparameter untuk GridSearchCV
param_dist = {
    'n_neighbors': [3, 5, 7, 9, 11, 13, 15],
    'leaf_size': [20, 30, 40, 50, 60, 70],
    'metric': ['manhattan', 'euclidean'],
    'weights': ['uniform', 'distance']
}

# GridSearchCV untuk mencari kombinasi terbaik
grid_search = GridSearchCV(
    estimator=knn,
    param_grid=param_dist,
    cv=10,  
    scoring='accuracy',
    verbose=2,
    n_jobs=-1
)

# Fit model dengan GridSearchCV
grid_search.fit(X_train_scaled, y_train)

# Evaluasi model terbaik
best_knn = grid_search.best_estimator_
y_pred = best_knn.predict(X_test_scaled)

accuracy = accuracy_score(y_test, y_pred)
print(f"Accuracy of KNN model after GridSearchCV: {accuracy * 100:.2f}%")
print(f"Best Parameters: {grid_search.best_params_}")
print(f"Best Cross-Validation Score: {grid_search.best_score_ * 100:.2f}%")

# Evaluasi F1 Score dan Recall
f1 = f1_score(y_test, y_pred, average='weighted')
recall = recall_score(y_test, y_pred, average='weighted')
print(f"F1 Score: {f1:.2f}")
print(f"Recall: {recall:.2f}")

# Menampilkan classification report
print("Classification Report:")
print(classification_report(y_test, y_pred))

# Menampilkan jumlah data pelatihan dan pengujian
print(f"Jumlah data pelatihan: {len(X_train)}")
print(f"Jumlah data pengujian: {len(X_test)}")

# Visualisasi confusion matrix
conf_matrix = confusion_matrix(y_test, y_pred)
plt.figure(figsize=(8, 6))
sns.heatmap(conf_matrix, annot=True, fmt='d', cmap='Blues', xticklabels=fitzpatrick_map.keys(), yticklabels=fitzpatrick_map.keys())
plt.title("Confusion Matrix")
plt.xlabel("Predicted")
plt.ylabel("Actual")
plt.show()

# Simpan model dan scaler
joblib.dump(best_knn, 'knn_model_14.joblib')
joblib.dump(scaler, 'scaler_14.joblib')
# Simpan label encoder
joblib.dump(label_encoder, 'label_encoder_14.joblib')
print("Label Encoder telah disimpan.")
