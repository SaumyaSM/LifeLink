# Lifelink – Mobile App (Flutter)

**Lifelink** is a cross-platform mobile application that connects organ donors and recipients through a secure, structured, and medically guided platform. It combines user-centered design, a smart organ matching algorithm, and Firebase backend services to improve transplant matching processes.

## 🚀 Features

- Donor and recipient registration
- Secure storage of medical information (e.g., HLA markers, blood type)
- Matching algorithm with real-time compatibility scoring
- Educational resources and organ donation event updates
- Notifications and profile management
- Intuitive navigation and user experience

## 🛠️ Technologies Used

- **Framework**: Flutter (Dart)
- **Backend**: Firebase (Firestore, Auth, Storage)
- **Packages**:
  - `firebase_auth`, `cloud_firestore`, `firebase_storage`
  - `google_places_flutter`, `geolocator`
  - `http`, `image_picker`, `flutter_pdfview`
  - `google_fonts`, `loading_animation_widget`, `modal_progress_hud_nsn`

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
