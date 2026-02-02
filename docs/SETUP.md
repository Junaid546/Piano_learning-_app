# PianoApp Setup Guide

This guide provides step-by-step instructions for setting up the PianoApp development environment.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Flutter Installation](#flutter-installation)
3. [IDE Setup](#ide-setup)
4. [Firebase Configuration](#firebase-configuration)
5. [Running the App](#running-the-app)
6. [Building APK](#building-apk)
7. [Environment Configuration](#environment-configuration)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### System Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| **OS** | Windows 10 | Windows 11 |
| **RAM** | 4 GB | 8 GB+ |
| **Disk Space** | 10 GB | 20 GB+ |
| **Processor** | Dual-core | Quad-core+ |

### Required Software

| Software | Version | Purpose |
|----------|---------|---------|
| **Flutter SDK** | 3.10.4+ | Core framework |
| **Dart SDK** | 3.0.0+ | Programming language |
| **Android Studio** | 2022.0+ | Android development |
| **Java JDK** | 17+ | Android build tools |
| **Git** | 2.0+ | Version control |

### Optional (for iOS Development)

| Software | Version | Purpose |
|----------|---------|---------|
| **Xcode** | 14.0+ | iOS development (Mac only) |
| **CocoaPods** | 1.12.0+ | iOS dependency management |
| **Homebrew** | Latest | Package manager (Mac) |

---

## Flutter Installation

### Step 1: Download Flutter SDK

1. Go to [Flutter SDK releases](https://docs.flutter.dev/development/tools/sdk/releases)
2. Download the latest stable release for Windows
3. Extract the zip file to a desired location (e.g., `C:\src\flutter`)

### Step 2: Add Flutter to PATH

**Option 1: Through System Properties**

1. Press `Windows + R`, type `sysdm.cpl`, press Enter
2. Click "Environment Variables"
3. Under "User variables", find "Path" and click "Edit"
4. Click "New" and add: `C:\src\flutter\bin`
5. Click "OK" to save

**Option 2: Through PowerShell (Admin)**

```powershell
# Add Flutter to PATH permanently
[Environment]::SetEnvironmentVariable(
    "Path",
    $env:Path + ";C:\src\flutter\bin",
    "User"
)
```

### Step 3: Verify Installation

```bash
# Check Flutter version
flutter --version

# Should output something like:
# Flutter 3.10.4 • channel stable • https://github.com/flutter/flutter.git
# Framework • revision 84b2526 (2 weeks ago) • 2023-05-15 00:06:04 +0000
# Engine • revision 0f9c8d18
# Tools • Dart 3.0.4 • DevTools 2.23.1
```

### Step 4: Run Flutter Doctor

```bash
flutter doctor
```

This command checks your environment and displays a report. You should see:

```
[✓] Flutter (Channel stable, 3.10.4, ...)
[✓] Android toolchain - develop for Android devices
[✓] Chrome - develop for the web
[✓] Visual Studio - develop for Windows
[!] Android Studio
[✓] Connected device
[✓] HTTP Host Availability
```

### Step 5: Install Android SDK

If Flutter doctor shows Android toolchain issues:

1. Open Android Studio
2. Go to "More Actions" → "SDK Manager"
3. In "SDK Platforms", check:
   - Android 13 (Tiramisu) - API Level 33
4. In "SDK Tools", check:
   - Android SDK Build-Tools
   - Android SDK Platform-Tools
   - Android SDK Command-line Tools
5. Click "Apply" to install

---

## IDE Setup

### VS Code Setup

1. **Download VS Code**: https://code.visualstudio.com/
2. **Install Flutter Extension**
   - Open VS Code
   - Press `Ctrl+Shift+X`
   - Search for "Flutter"
   - Install the official Flutter extension

3. **Install Additional Extensions** (Recommended)
   - Dart
   - Material Icon Theme
   - Bracket Pair Colorization
   - GitLens

### Android Studio Setup

1. **Download Android Studio**: https://developer.android.com/studio
2. **Install Flutter Plugin**
   - Open Android Studio
   - Go to "Configure" → "Plugins"
   - Search for "Flutter"
   - Install the Flutter plugin
   - Restart Android Studio

3. **Configure Dart SDK**
   - Go to "Configure" → "Settings"
   - Navigate to "Languages & Frameworks" → "Dart"
   - Set Dart SDK path to: `C:\src\flutter\bin\cache\dart-sdk`

---

## Firebase Configuration

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `pianoapp`
4. Disable Google Analytics (optional, for simpler setup)
5. Wait for project creation

### Step 2: Add Android App

1. In Firebase Console, click the Android icon to add an Android app
2. Enter package name: `com.example.pianoapp`
3. (Optional) Enter app nickname
4. Click "Register app"
5. Download `google-services.json`
6. Place it in: `android/app/google-services.json`

### Step 3: Add iOS App (Mac only)

1. In Firebase Console, click the iOS icon to add an iOS app
2. Enter bundle ID: `com.example.pianoapp`
3. (Optional) Enter app nickname
4. Click "Register app"
5. Download `GoogleService-Info.plist`
6. Place it in: `ios/Runner/GoogleService-Info.plist`

### Step 4: Enable Authentication

1. Go to "Authentication" in the left sidebar
2. Click "Get started"
3. Click "Email/Password"
4. Enable "Email/Password"
5. Click "Save"

### Step 5: Enable Firestore Database

1. Go to "Firestore Database" in the left sidebar
2. Click "Create database"
3. Choose location (select closest to your users)
4. Choose "Start in test mode" (for development)
5. Click "Enable"

### Step 6: Enable Storage (Optional)

1. Go to "Storage" in the left sidebar
2. Click "Get started"
3. Choose location
4. Click "Start in test mode" (for development)
5. Click "Done"

---

## Running the App

### Step 1: Clone Repository

```bash
# Clone the repository
git clone https://github.com/yourusername/pianoapp.git
cd pianoapp
```

### Step 2: Install Dependencies

```bash
# Get all dependencies
flutter pub get

# Generate Hive adapters (if applicable)
flutter pub run build_runner build

# If build_runner fails, try:
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 3: Start a Device

**Android Emulator:**
1. Open Android Studio
2. Go to "More Actions" → "Virtual Device Manager"
3. Click "Play" on a device or create a new one

**Physical Device:**
1. Enable USB debugging on your device
2. Connect via USB
3. Accept the USB debugging prompt on your device

**Check connected devices:**
```bash
flutter devices
```

### Step 4: Run the App

```bash
# Run with hot reload
flutter run

# Run in debug mode
flutter run --debug

# Run with specific device
flutter run -d <device_id>

# Run on web
flutter run -d chrome

# Run on Windows
flutter run -d windows
```

### Expected Output

```
Running "flutter pub get" in pianoapp... 2.5s
Running Gradle task 'assembleDebug'...                 10.5s
✓ Built build\app\outputs\flutter-apk\app-debug.apk (21.5MB).
Installing build\app\outputs\flutter-apk\app-debug.apk...  3.2s
Syncing files to device...                              234ms
```

### Hot Reload

When the app is running, you can use:

| Command | Description |
|---------|-------------|
| `r` | Hot reload |
| `R` | Hot restart |
| `h` | Show help |
| `q` | Quit |

---

## Building APK

### Step 1: Clean Previous Builds

```bash
# Clean build artifacts
flutter clean
```

### Step 2: Get Dependencies

```bash
# Get dependencies (after clean)
flutter pub get
```

### Step 3: Build Release APK

```bash
# Build release APK
flutter build apk --release

# Build with specific build mode
flutter build apk --release --obfuscate --split-debug-info=build/debug-info

# Build APK with tree shaking disabled
flutter build apk --release --no-tree-shake-icons
```

### APK Output Location

```
build/app/outputs/flutter-apk/app-release.apk
```

### Build Sizes

| Build Type | Approximate Size |
|------------|------------------|
| Debug APK | 50-70 MB |
| Release APK | 40-60 MB |
| App Bundle | 30-50 MB |

### Building App Bundle (for Play Store)

```bash
# Build release app bundle
flutter build appbundle --release

# Output location: build/app/outputs/bundle/release/app-release.aab
```

---

## Environment Configuration

### Creating .env File

Create a `.env` file in the project root for environment-specific configuration:

```env
# Firebase Configuration
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_APP_ID=your_app_id

# Feature Flags
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true

# API Endpoints (if any)
API_BASE_URL=https://api.pianoapp.com
```

### Configuration Classes

Use the configuration in your app:

```dart
class AppConfig {
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'default_key',
  );
  
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: true,
  );
}
```

### Build Variants

Configure different build variants in `android/app/build.gradle.kts`:

```kotlin
buildTypes {
    release {
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
    debug {
        isMinifyEnabled = false
        applicationIdSuffix = ".debug"
    }
}
```

---

## Troubleshooting

### Common Issues

#### 1. Flutter Doctor Issues

**Problem**: `Flutter command not found`

**Solution**:
```bash
# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Or use full path
C:\src\flutter\bin\flutter doctor
```

#### 2. Android SDK Issues

**Problem**: `Android SDK not found`

**Solution**:
```bash
# Set Android SDK path
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

#### 3. Gradle Build Issues

**Problem**: `Gradle task assembleDebug failed`

**Solution**:
```bash
# Clean and rebuild
flutter clean
flutter pub cache repair
flutter pub get
flutter run
```

#### 4. Dependency Conflicts

**Problem**: `Resolving dependencies... failed`

**Solution**:
```bash
# Delete pubspec.lock and rebuild
rm pubspec.lock
flutter pub get

# Or use dependency overrides
flutter pub upgrade --major-versions
```

#### 5. Firebase Initialization Issues

**Problem**: `Firebase has not been initialized`

**Solution**:
1. Verify `google-services.json` is in `android/app/`
2. Check package name matches in Firebase Console
3. Ensure Firebase initialization code in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
```

#### 6. Audio Playback Issues

**Problem**: No audio or delayed audio

**Solution**:
1. Check audio file paths in `pubspec.yaml`
2. Ensure audio files are in `assets/audio/` directory
3. Run:

```bash
flutter clean
flutter pub get
flutter run
```

#### 7. Hot Reload Not Working

**Problem**: Changes not reflected on hot reload

**Solution**:
1. Save all files
2. Type `R` in terminal for hot restart
3. Check for compilation errors in terminal

### Performance Optimization

#### Android Performance

```kotlin
// android/app/build.gradle.kts
android {
    defaultConfig {
        minSdk = 21
        targetSdk = 33
    }
    
    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }
}
```

#### Flutter Performance

```dart
// Use keys efficiently
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    // Use const constructors where possible
    return const SomeWidget();
  }
}
```

---

## Additional Resources

### Official Documentation

- [Flutter Docs](https://docs.flutter.dev/)
- [Riverpod Docs](https://riverpod.dev/)
- [Firebase Docs](https://firebase.google.com/docs/flutter/setup)
- [go_router Docs](https://gorouter.dev/)

### Useful Commands

```bash
# Check for outdated packages
flutter pub outdated

# Update packages
flutter pub upgrade

# Analyze code
flutter analyze

# Format code
flutter format .

# Run tests
flutter test

# Build web
flutter build web

# Build iOS (Mac only)
flutter build ios
```

### Getting Help

1. Check the [GitHub Issues](https://github.com/yourusername/pianoapp/issues)
2. Search for similar issues
3. Create a new issue with detailed information
4. Include:
   - Flutter version (`flutter --version`)
   - Error message
   - Steps to reproduce
   - Code snippets if relevant

---

## Next Steps

After successful setup:

1. ✅ Complete the setup guide
2. 📖 Read [ARCHITECTURE.md](ARCHITECTURE.md) for architecture details
3. 🎨 Explore the codebase structure
4. 🧪 Run and test the app
5. 📝 Check [TODO.md](TODO.md) for contribution opportunities
