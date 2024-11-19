import numpy as np
import os
import cv2
import matplotlib.pyplot as plt
import random
from sklearn.model_selection import train_test_split, RandomizedSearchCV
from sklearn.preprocessing import MinMaxScaler, LabelEncoder
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import accuracy_score
import joblib
import mediapipe as mp
from sklearn.impute import SimpleImputer
from imblearn.over_sampling import SMOTE
from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay

# Directory dataset
dataset_dir = r'F:\Dataset PBL\mst-e_data\mst-e_data'

data = []
labels = []

# Fitzpatrick skin tone mapping
folder_to_fitzpatrick = {
    "subject_0": "light", "subject_1": "light", "subject_2": "dark",
    "subject_3": "brown", "subject_4": "dark", "subject_5": "brown",
    "subject_6": "olive", "subject_7": "medium", "subject_8": "medium",
    "subject_9": "light", "subject_10": "dark", "subject_11": "olive",
    "subject_12": "dark", "subject_13": "very_light", "subject_14": "light",
    "subject_15": "medium", "subject_16": "very_light", "subject_17": "brown", "subject_18": "very_light"
}

fitzpatrick_map = {
    "very_light": 1, "light": 2, "medium": 3, "olive": 4, "brown": 5, "dark": 6
}

# MediaPipe Face Detection setup
mp_face_detection = mp.solutions.face_detection

def preprocess_skin(image, visualize=False):
    with mp_face_detection.FaceDetection(model_selection=1, min_detection_confidence=0.5) as face_detection:
        rgb_image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        results = face_detection.process(rgb_image)

        if results.detections:
            for detection in results.detections:
                bboxC = detection.location_data.relative_bounding_box
                h, w, _ = image.shape
                x, y, w_box, h_box = int(bboxC.xmin * w), int(bboxC.ymin * h), int(bboxC.width * w), int(bboxC.height * h)
                face_region = image[y:y+h_box, x:x+w_box]

                if face_region is None or face_region.size == 0:
                    print(f"Warning: Empty face region in image {image}")
                    return None

                face_resized = cv2.resize(face_region, (128, 128)) if w_box > 128 or h_box > 128 else face_region
                hsv_image = cv2.cvtColor(face_resized, cv2.COLOR_BGR2HSV)
                H, S, V = cv2.split(hsv_image)

                # Rentang yang menangkap seluruh spektrum warna kulit
                lower_skin = np.array([0, 10, 40])    # Nilai rendah untuk warna hitam/hitam pekat
                upper_skin = np.array([35, 170, 255]) # Nilai tinggi untuk warna sangat terang/putih pucat

                skin_mask = cv2.inRange(hsv_image, lower_skin, upper_skin)
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

    print(f"Warning: No face detected in image")
    return None

# Visualisasikan preprocessing pada gambar acak sebelum training
random_subject = random.choice(list(folder_to_fitzpatrick.keys()))
random_image_path = os.path.join(dataset_dir, random_subject, random.choice(os.listdir(os.path.join(dataset_dir, random_subject))))
random_image = cv2.imread(random_image_path)
print(f"Visualizing preprocessing for random image: {random_image_path}")
preprocessed_features = preprocess_skin(random_image, visualize=True)

# Lanjutkan dengan ekstraksi data untuk pelatihan
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
                if skin_features:
                    data.append(skin_features)
                    labels.append(label)

data = np.array(data)
labels = np.array(labels)

if np.any(np.isnan(data)):
    print("Ada nilai NaN pada data. Menangani NaN...")
    imputer = SimpleImputer(strategy='mean')
    data = imputer.fit_transform(data)

label_encoder = LabelEncoder()
labels = label_encoder.fit_transform(labels)

# SMOTE untuk menangani imbalanced class
smote = SMOTE(random_state=42)
X_resampled, y_resampled = smote.fit_resample(data, labels)

# Split data setelah SMOTE
X_train, X_test, y_train, y_test = train_test_split(X_resampled, y_resampled, test_size=0.2, random_state=42)

scaler = MinMaxScaler()
X_train = scaler.fit_transform(X_train)
X_test = scaler.transform(X_test)

# Definisikan parameter untuk Randomized Search
param_dist_knn = {
    'n_neighbors': list(range(1, 21)),
    'weights': ['uniform', 'distance'],
    'metric': ['euclidean', 'manhattan', 'chebyshev'],
    'leaf_size': list(range(10, 51, 10)),
    'p': [1, 2]
}

# Randomized Search untuk hyperparameter tuning
knn = KNeighborsClassifier()
random_search = RandomizedSearchCV(
    estimator=knn, param_distributions=param_dist_knn, n_iter=30, cv=5, scoring='accuracy', n_jobs=-1, random_state=42
)
random_search.fit(X_train, y_train)

# Dapatkan parameter terbaik dan akurasi
best_params = random_search.best_params_
best_score = random_search.best_score_
print(f"Best Parameters for KNN with Randomized Search: {best_params}")
print(f"Best Cross-Validation Accuracy for KNN with Randomized Search: {best_score * 100:.2f}%")

best_knn = random_search.best_estimator_
y_pred = best_knn.predict(X_test)
final_accuracy = accuracy_score(y_test, y_pred)
print(f"Final Test Accuracy with Best Parameters from Randomized Search: {final_accuracy * 100:.2f}%")

cm = confusion_matrix(y_test, y_pred)

disp = ConfusionMatrixDisplay(confusion_matrix=cm, display_labels=label_encoder.classes_)
disp.plot(cmap='Blues')
plt.title('Confusion Matrix for KNN Skin Tone Model')
plt.show()

joblib.dump(best_knn, 'knn_skin_tone_model_hsv_optimized_smote.pkl')
joblib.dump(scaler, 'scaler_model_hsv_optimized_smote.pkl')
# In your training script, after encoding the labels:
np.save('label_encoder_classes.npy', label_encoder.classes_)
print("Model dan scaler disimpan dengan sukses.")
