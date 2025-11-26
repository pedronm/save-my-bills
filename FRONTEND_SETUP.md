# Frontend Setup Guide

## Prerequisites

Before running the Flutter frontend, ensure you have:

1. **Flutter SDK 3.0.0 or higher** - [Install Flutter](https://flutter.dev/docs/get-started/install)
2. **Android Studio** (for Android development) or **Xcode** (for iOS development)
3. **A physical device or emulator/simulator**
4. **Running backend server** - See BACKEND_SETUP.md

## Step 1: Install Flutter

### macOS
```bash
# Download Flutter SDK
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.x.x-stable.zip
unzip flutter_macos_3.x.x-stable.zip
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

### Linux
```bash
# Download Flutter SDK
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.x.x-stable.tar.xz
tar xf flutter_linux_3.x.x-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

### Windows
1. Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
2. Extract the zip file
3. Add `flutter\bin` to your PATH
4. Run `flutter doctor` in Command Prompt

## Step 2: Set Up IDE

### Android Studio (Recommended)
1. Download and install [Android Studio](https://developer.android.com/studio)
2. Open Android Studio
3. Go to **Preferences** > **Plugins**
4. Search for and install **Flutter** and **Dart** plugins
5. Restart Android Studio

### VS Code (Alternative)
1. Download and install [VS Code](https://code.visualstudio.com/)
2. Install the **Flutter** extension
3. Install the **Dart** extension

## Step 3: Create Virtual Device (Optional)

### For Android:
1. Open Android Studio
2. Go to **Tools** > **Device Manager**
3. Click **Create Device**
4. Select a device (e.g., Pixel 5)
5. Select a system image (e.g., Android 13)
6. Click **Finish**

### For iOS (macOS only):
```bash
# List available simulators
xcrun simctl list devices

# Create a simulator if needed
xcrun simctl create "iPhone 14" "iPhone 14"
```

## Step 4: Install Dependencies

```bash
cd frontend
flutter pub get
```

This will download all packages specified in `pubspec.yaml`.

## Step 5: Configure Backend URL

The app needs to know where your backend is running. Update the URLs in the following files:

### For Android Emulator

Edit `lib/services/graphql_service.dart`:
```dart
static const String _apiUrl = 'http://10.0.2.2:8080/graphql';
```

Edit `lib/services/upload_service.dart`:
```dart
static const String baseUrl = 'http://10.0.2.2:8080/api/screenshots';
```

**Note:** `10.0.2.2` is the special IP address to reach the host machine from Android emulator.

### For iOS Simulator

Edit `lib/services/graphql_service.dart`:
```dart
static const String _apiUrl = 'http://localhost:8080/graphql';
```

Edit `lib/services/upload_service.dart`:
```dart
static const String baseUrl = 'http://localhost:8080/api/screenshots';
```

### For Physical Device

Find your computer's IP address:

**macOS/Linux:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**Windows:**
```cmd
ipconfig
```

Then update the files with your IP:
```dart
static const String _apiUrl = 'http://192.168.1.XXX:8080/graphql';
static const String baseUrl = 'http://192.168.1.XXX:8080/api/screenshots';
```

## Step 6: Run the App

### Using Command Line

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in debug mode (default)
flutter run

# Run in release mode
flutter run --release
```

### Using Android Studio

1. Open the `frontend` folder in Android Studio
2. Wait for indexing to complete
3. Select a device from the dropdown in the toolbar
4. Click the **Run** button (green play icon) or press **Shift+F10**

### Using VS Code

1. Open the `frontend` folder in VS Code
2. Press **F5** or go to **Run** > **Start Debugging**
3. Select the device when prompted

## Step 7: Verify Installation

Once the app is running:

1. **Home Screen** should appear (might be empty initially)
2. Tap the **camera button** in the bottom-right
3. Try capturing or selecting an image
4. Fill in the form and tap **Upload**
5. Return to the home screen to see the uploaded screenshot

## Features Overview

### Home Screen
- **Cloud View**: Shows screenshots from backend (via GraphQL)
- **Local View**: Shows cached screenshots from SQLite
- **Toggle Icon**: Switch between cloud and local data
- **Pull to Refresh**: Update data from server
- **Tap Item**: View details

### Upload Screen
- **Camera Button**: Capture photo using device camera
- **Gallery Button**: Select image from gallery
- **Form Fields**:
  - Title (required)
  - Description
  - User ID
  - Category
  - Vendor
  - Amount and Currency
  - Bill Date
- **Upload Button**: Send to backend

### Detail Screen
- View complete screenshot information
- File details
- Bill information
- Timestamps
- Google Drive link
- Delete functionality

## Troubleshooting

### Flutter Doctor Issues

**Problem:** `Android license status unknown`

**Solution:**
```bash
flutter doctor --android-licenses
```
Accept all licenses.

**Problem:** `Xcode not installed` (macOS)

**Solution:**
Install Xcode from App Store, then:
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### Build Errors

**Problem:** `Gradle build failed`

**Solutions:**
```bash
# Clear build cache
flutter clean
flutter pub get
flutter build apk
```

**Problem:** `CocoaPods not installed` (iOS)

**Solution:**
```bash
sudo gem install cocoapods
cd ios
pod install
```

### Runtime Errors

**Problem:** `Cannot connect to backend`

**Solutions:**
1. Ensure backend is running: `curl http://localhost:8080/graphql`
2. Check IP address configuration (especially for physical devices)
3. Ensure firewall allows connections
4. For Android emulator, use `10.0.2.2` instead of `localhost`

**Problem:** `SQLite database error`

**Solutions:**
1. Uninstall and reinstall the app
2. Clear app data:
   ```bash
   flutter clean
   flutter run
   ```

**Problem:** `Camera not working`

**Solutions:**
1. Grant camera permissions in device settings
2. For iOS simulator, camera is not available (use gallery instead)
3. For Android, ensure permissions are declared in `AndroidManifest.xml`

### Permission Issues

**Android:**

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

**iOS:**

Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to capture bill receipts</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select bill receipts</string>
```

## Building for Release

### Android APK

```bash
# Build APK
flutter build apk --release

# The APK will be at: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

### iOS

```bash
# Build iOS app (macOS only)
flutter build ios --release

# Then open Xcode to archive and distribute:
open ios/Runner.xcworkspace
```

## Development Tips

### Hot Reload

While the app is running:
- Press `r` in the terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Debugging

1. **Enable Debug Mode**: Run with `flutter run` (default)
2. **DevTools**: 
   ```bash
   flutter pub global activate devtools
   flutter pub global run devtools
   ```
3. **Print Statements**: Use `print()` or `debugPrint()`
4. **Breakpoints**: Set in IDE and run in debug mode

### Useful Commands

```bash
# Check for issues
flutter doctor -v

# Clean build artifacts
flutter clean

# Update dependencies
flutter pub upgrade

# Analyze code
flutter analyze

# Format code
flutter format lib/

# Run tests
flutter test

# Generate app icons
flutter pub run flutter_launcher_icons:main
```

## Project Structure

```
frontend/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   └── screenshot.dart       # Data model
│   ├── services/
│   │   ├── graphql_service.dart  # GraphQL queries/mutations
│   │   ├── database_service.dart # SQLite operations
│   │   └── upload_service.dart   # File upload
│   └── screens/
│       ├── home_screen.dart      # Main screen
│       ├── upload_screen.dart    # Upload UI
│       └── screenshot_detail_screen.dart
├── pubspec.yaml                   # Dependencies
├── android/                       # Android-specific code
└── ios/                          # iOS-specific code
```

## Performance Optimization

### Reduce App Size
```bash
# Build with size optimization
flutter build apk --split-per-abi --release
```

### Optimize Images
- Use appropriate image sizes
- Consider using cached_network_image package
- Compress images before upload

### Improve Startup Time
- Lazy load heavy widgets
- Use const constructors where possible
- Minimize initial database queries

## Testing

### Unit Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/models/screenshot_test.dart
```

### Widget Tests
Create widget tests in `test/` directory to test UI components.

### Integration Tests
Create integration tests in `integration_test/` directory to test complete flows.

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)
- [GraphQL Flutter](https://pub.dev/packages/graphql_flutter)
- [SQLite Flutter](https://pub.dev/packages/sqflite)
- [Image Picker](https://pub.dev/packages/image_picker)

## Next Steps

1. Customize the UI to match your branding
2. Add user authentication
3. Implement data synchronization
4. Add offline mode support
5. Implement analytics and crash reporting
6. Set up CI/CD pipeline
7. Prepare for app store submission
