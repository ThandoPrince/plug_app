# Plug Client Setup

## Prerequisites

Before running the Plug Client, make sure the following are configured:

* **Plug Backend** is running and accessible.
* A **Google Cloud project** is configured with the required Google Maps APIs.
* **Firebase** is configured for push notifications.

The client application communicates with the backend API for authentication, services, bookings, service providers, notifications, and other functionality.

### Google Maps Configuration

The Plug Client requires a Google Maps API key with the required Google Maps services enabled:

* **Maps SDK**
* **Places API**
* **Directions API**

Make sure the API key is configured correctly for the Android/iOS application and that the required APIs are enabled in the Google Cloud project.

The Google Maps configuration is required for functionality such as:

* Displaying maps
* Selecting locations
* Address/place searches
* Location selection
* Directions and route information
* Service provider location-related functionality

### Firebase Configuration

The Plug Client uses **Firebase Cloud Messaging (FCM)** for push notifications.

Make sure the Firebase project is configured for the application and that the appropriate Firebase configuration files are included in the project.

Firebase is required for functionality such as:

* Push notifications
* Booking notifications
* Service request notifications
* Other real-time application notifications

### 1. Navigate to the Plug Client

```powershell
cd D:\plug\flutter_application_1
```

If a Python virtual environment is active, you can deactivate it:

```powershell
deactivate
```

### 2. Install Flutter Dependencies

Run:

```powershell
flutter pub get
```

### 3. Generate App Icons

The project uses `flutter_launcher_icons` to generate the application icons.

Make sure the following configuration is present in `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/plug_icon.png"
  adaptive_icon_foreground: "assets/icons/plug_icon_foreground.png"
  adaptive_icon_background: "#0F172A"
  min_sdk_android: 21
```

Generate the launcher icons:

```powershell
dart run flutter_launcher_icons
```

### 4. Generate the Native Splash Screen

The project uses `flutter_native_splash` for the Android and iOS splash screens.

Make sure the following configuration is present in `pubspec.yaml`:

```yaml
flutter_native_splash:
  color: "#3EC5FF"
  image: assets/icons/plug_icon.png

  android_12:
    color: "#3EC5FF"
    image: assets/icons/plug_icon.png
```

Generate the splash screen:

```powershell
dart run flutter_native_splash:create
```

### 5. Run the Client Application

Once the backend, Google Maps, and Firebase configuration are ready, start the Flutter application:

```powershell
flutter run
```

### Important

The **Plug Backend must be running before starting the Plug Client**.

Google Maps and Firebase must also be configured correctly. If any of these dependencies are unavailable or incorrectly configured, features such as:

* Login and registration
* Service listing
* Service provider discovery
* Maps
* Places/address search
* Directions
* Bookings
* Notifications
* Other API-dependent functionality

may not work correctly.

### Complete Client Setup

For a fresh setup:

```powershell
cd D:\plug\flutter_application_1

flutter pub get

dart run flutter_launcher_icons

dart run flutter_native_splash:create

flutter run

