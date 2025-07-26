# RECO - Flutter E-Commerce App

![App Screenshot](assets/screenshots/home.png) <!-- Add your own screenshot later -->

A production-ready e-commerce application built with Flutter and Firebase, implementing clean architecture with BLoC pattern.

## 🔥 Key Features

- **User System**
  - Secure email/password authentication
  - Profile management
  - Password recovery

- **Shopping Flow**
  - Product catalog with categories
  - Cart functionality with quantity control
  - Wishlist/Favorites system
  - Order history

- **Tech Stack**
  - Flutter 3.x + Dart 2.17
  - Firebase Auth & Firestore
  - BLoC state management
  - get_it dependency injection
  - SharedPreferences caching

## 🛠️ Installation

```bash
# 1. Clone repository
git clone https://github.com/YOUR_USERNAME/reco_test.git
cd reco_test

# 2. Install dependencies
flutter pub get

# 3. Set up Firebase:
#    - Create project at firebase.google.com
#    - Add Android/iOS apps and download config files
#    - Enable Email/Password auth

# 4. Run the app
flutter run
