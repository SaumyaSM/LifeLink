# Lifelink – Mobile App (Flutter)

**Lifelink** is a cross-platform mobile application that connects organ donors and recipients through a secure, structured, and medically guided platform. It combines user-centered design, a smart organ matching algorithm, and Firebase backend services to improve transplant matching processes.

## 🚀 Features

- Donor and recipient registration
- Secure storage of medical information (e.g., HLA markers, blood type)
- Matching algorithm with real-time compatibility scoring
- Educational resources and organ donation event updates
- Notifications and profile management
- Intuitive navigation and user experience

## 🧠 Matching Algorithm

The organ matching system ranks candidates based on:

- **Blood Group Compatibility**
- **HLA Mismatch Scoring** (A, B, C, DRB1, DQB1)
- **Waiting Time Priority**
- **Age Difference Penalty**:  
  `Score -= 0.5 × (donor age − recipient age)²`
- **Regional Proximity Bonus**

Top-scoring recipients are shortlisted, and a probabilistic selection simulates real-world acceptance behavior.

## 🛠️ Technologies Used

- **Framework**: Flutter (Dart)
- **Backend**: Firebase (Firestore, Auth, Storage)
- **Packages**:
  - `firebase_auth`, `cloud_firestore`, `firebase_storage`
  - `google_places_flutter`, `geolocator`
  - `http`, `image_picker`, `flutter_pdfview`
  - `google_fonts`, `loading_animation_widget`, `modal_progress_hud_nsn`

## 📁 Project Structure

/lib/
├── main.dart
├── firebase_options.dart
├── constants/
├── models/
├── screens/
├── services/
├── utils/
└── widgets/

## 🧪 Setup & Run

1. Extract the ZIP folder containing the project.
2. Open the project in Android Studio or VS Code.
3. Run `flutter pub get`.
4. Add Firebase config files:
   - `google-services.json` → `/android/app`
   - `GoogleService-Info.plist` → `/ios/Runner`
5. Launch the app using:
6. flutter run

## 📱 Testing

Manually tested on:
- Android Emulator (Pixel series)
- Xcode iOS Simulator (iPhone)

## 📄 License

This application is for educational and academic purposes only. It is not approved for clinical or production use without regulatory clearance.
