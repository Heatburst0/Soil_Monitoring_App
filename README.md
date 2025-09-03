# Soil Monitoring App

A Flutter-based mobile application that monitors **soil conditions** using a sensor device.  
The app collects **temperature** and **moisture** readings via Bluetooth (mocked for now), stores them in **Firebase Firestore**, and displays them in **graph** and **list** formats.



https://github.com/user-attachments/assets/6e8d9faf-d9a2-4ccf-80cb-6628be4c6832

## 🔧 Assumptions

### Bluetooth
- The app currently uses a **mock Bluetooth service** (`bluetooth_service.dart`).  
  - It simulates:
    - Scanning for a soil sensor (`SoilSensor-01`)
    - Connecting to it
    - Generating random temperature & moisture readings  

- This mock implementation ensures the app works **without actual hardware**.

### Replacing with Real Bluetooth
To connect with a real sensor:
1. Replace the mock service with a package like [`flutter_blue_plus`](https://pub.dev/packages/flutter_blue_plus).
2. Implement:
   - Device scanning (with permissions)
   - Real device connection
   - Reading temperature & moisture data from sensor characteristics
3. The rest of the app (Firestore sync, graph, list views) will work unchanged.
## 🚀 Setup Instructions

### 1. Prerequisites
- Install [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable).
- Install Android Studio or VS Code with Flutter plugin.
- Set up a Firebase project with **Cloud Firestore** enabled.




### 2. Clone or Download
```
git clone https://github.com/Heatburst0/Soil_Monitoring_App.git
cd soil_monitoring_app
```
### 3. Configure Firebase
- Download your **google-services.json** file from the Firebase Console.  
- Place it inside:
```
android/app/google-services.json
```
- Ensure Firestore rules allow read/write for testing, or configure security rules appropriately.

### 4. Install & Run
Run on a connected Android device/emulator:
```
flutter run
```

Build a release APK:
```
flutter build apk --release
```

The release build will be available at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📂 Project Structure
```
lib/
 ┣ services/
 ┃ ┗ bluetooth_service.dart   # Mock Bluetooth implementation
 ┣ screens/
 ┃ ┗ history_page.dart        # Graph + List views
 ┣ main.dart                  # App entry point
```



## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
