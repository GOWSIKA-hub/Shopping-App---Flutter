# Flutter E-Commerce App

This project is a Flutter-based E-Commerce mobile app with Firebase backend for user authentication, product listing, search, cart, and payment flows.

## Features
- User Authentication (Login, Signup)
- Product Listing with Firestore backend
- Product Search with live filtering
- Shopping Cart saved to Firestore per user
- Add Products page to add new products
- Product Details with Add to Cart and Buy Now
- Payment flow (dummy placeholder)

## Prerequisites
- Flutter SDK installed (https://flutter.dev/docs/get-started/install)
- Firebase project set up with Firestore and Authentication enabled
- Your Firebase config in `main.dart` matches your Firebase project credentials

## Getting Started

### 1. Clone the repository

git clone https://github.com/GOWSIKA-hub/Shopping-App---Flutter

### 2. Install dependencies

Since `.dart_tool/`, `.idea/`, and `build/` folders are deleted, run:

flutter pub get

This will download all required Flutter packages and recreate essential build files.

### 3. Configure Firebase

Make sure your Firebase project is properly configured with your Flutter app by following:
https://firebase.flutter.dev/docs/overview/

Update Firebase API keys and options in your `main.dart` accordingly.

### 4. Run the app

To run on an emulator or connected device:

flutter run

For Flutter web:

flutter run -d chrome

### 5. Build APK (optional)

To build a release APK:

flutter build apk --release

## Project Structure Overview

- `lib/main.dart` — App entry point with routing and Firebase initialization
- `lib/home.dart` — Main home page with bottom navigation and product grid
- `lib/search_page.dart` — Product search page with live filtering
- `lib/cart_page.dart` — User cart page fetching cart items from Firestore
- `lib/details.dart` — Product details page with Add to Cart and Buy Now
- `lib/add_products_page.dart` — Page to add new products to Firestore
- Other files as per modular structure

## Notes

- Make sure your Firestore security rules allow reading/writing cart items and products for authenticated users
- User must be logged in to add to cart and view their cart
- Firestore paths:
  - Products: `products` collection
  - Cart: `carts/{userId}/items` subcollection

## Troubleshooting

- If you face issues with Flutter SDK after cleaning folders, run:

flutter clean
flutter pub get

- For Firebase errors, double-check your `GoogleService-Info.plist` (iOS) or `google-services.json` (Android) and Firebase project settings.

## License

This project is open-source and available under the MIT license.

Happy coding with your Flutter E-Commerce app!
