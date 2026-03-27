# 🎹 Melodify

A feature-rich piano learning application built with Flutter and Riverpod for state management. This app provides an interactive piano experience with audio feedback, lesson progression, achievement systems, and gamification elements to make learning piano fun and engaging.

![Flutter](https://img.shields.io/badge/Flutter-3.10.4-blue?logo=flutter)
![Riverpod](https://img.shields.io/badge/Riverpod-2.4.0-green)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange)
![License](https://img.shields.io/badge/License-MIT-blue)

---

## 📱 App Overview

Melodify is designed to help users learn piano in an interactive and gamified way. Whether you're a complete beginner or an advanced player looking to practice, Melodify provides the tools you need to succeed.

### 🎯 Target Audience
- **Beginners**: Starting their piano journey with structured lessons
- **Intermediate Players**: Looking to improve their skills
- **Teachers**: Using the app as a supplementary teaching tool
- **Hobbyists**: Enjoying casual piano practice

---

## ✨ Features Overview

### Core Features
| Feature | Description |
|---------|-------------|
| **Interactive Piano** | Full 88-key piano with realistic audio samples |
| **Multiple Octaves** | Complete piano range from A0 to C8 |
| **Visual Feedback** | Keys light up when pressed or during lessons |
| **Touch & Click Support** | Play using touch screen or mouse |

### Learning Features
| Feature | Description |
|---------|-------------|
| **Structured Lessons** | Progressive lessons for all skill levels |
| **Practice Mode** | Practice specific notes and chords |
| **Progress Tracking** | Track your learning journey |
| **Achievement System** | Unlock achievements as you progress |

### Gamification
| Feature | Description |
|---------|-------------|
| **Level System** | Complete lessons to level up |
| **Points & Rewards** | Earn points for correct notes |
| **Streak Counter** | Track daily practice streaks |

### User Features
| Feature | Description |
|---------|-------------|
| **Authentication** | Secure sign up and login |
| **Profile Management** | Manage your settings |
| **Cloud Sync** | Sync progress across devices |
| **Offline Support** | Local data persistence |

---

## 📸 Screenshots

> **Note**: Add your screenshots to the `assets/screenshots/` directory and reference them below.

### 1. Home Screen
![Home Screen](assets/screenshots/home_screen.png)
The main dashboard showing your progress, quick stats, and navigation to all features.

### 2. Piano Practice
![Piano Screen](assets/screenshots/piano_practice.png)
Interactive 88-key piano with visual feedback and real-time audio.

### 3. Lessons Screen
![Lessons Screen](assets/screenshots/lessons_screen.png)
Browse and start structured lessons tailored to your skill level.

### 4. Lesson Detail
![Lesson Detail](assets/screenshots/lesson_detail.png)
View lesson content, theory, and practice exercises.

### 5. Progress Tracking
![Progress Screen](assets/screenshots/progress_screen.png)
Visualize your learning progress with charts and statistics.

### 6. Achievements
![Achievements](assets/screenshots/achievements.png)
Unlock and view your achievements as you progress.

---

## 🛠️ Tech Stack

### Frontend
```
Flutter 3.10.4     →  Cross-platform UI framework
Dart 3.0+          →  Programming language
```

### State Management
```
Riverpod 2.4.0     →  Modern, reactive state management
```

### Backend & Database
```
Firebase Auth      →  User authentication
Cloud Firestore    →  Real-time database
Firebase Storage   →  File storage
```

### Local Storage
```
Shared Preferences →  Simple key-value storage
Hive 2.2.3         →  Fast NoSQL database
SQLite (sqflite)   →  Relational database
```

### Audio
```
audioplayers 5.2.1 →  Low-latency audio playback
```

### UI/UX
```
flutter_svg        →  SVG rendering
Lottie             →  JSON animations
shimmer            →  Loading effects
google_fonts       →  Typography
flutter_animate    →  Animations
confetti           →  Celebration effects
```

### Navigation & Routing
```
go_router 13.0     →  Declarative routing
```

### Charts & Visualization
```
fl_chart 0.66      →  Beautiful charts
table_calendar     →  Calendar widget
```

### Utilities
```
intl               →  Internationalization
equatable          →  Value equality
package_info_plus  →  App info
```

### Image & Notifications
```
image_picker       →  Image selection
image_cropper      →  Image cropping
share_plus         →  Content sharing
flutter_local_notifications →  Reminders
```

---

## 🏗️ Architecture

### Project Structure

```
melodify/
├── android/                  # Android native code
│   ├── app/
│   │   ├── build.gradle.kts # App-level build configuration
│   │   ├── google-services.json
│   │   └── src/
│   ├── keystore.properties  # Keystore configuration
│   └── build.gradle.kts     # Project-level build configuration
├── assets/
│   ├── audio/
│   │   ├── piano/          # Piano sound samples (A0-C8)
│   │   │   ├── A0.mp3, A1.mp3, ..., C8.mp3
│   │   └── feedback/       # Feedback sounds
│   │       ├── correct.mp3
│   │       └── incorrect.mp3
│   ├── lottie/             # Lottie animation files
│   │   ├── achievement_unlock.json
│   │   ├── level_up.json
│   │   ├── Loading_animation.json
│   │   └── Success.json
│   └── screenshots/        # App screenshots for README
├── ios/                     # iOS native code
├── lib/
│   ├── main.dart           # App entry point
│   ├── app/                # App configuration
│   │   ├── app.dart        # Main app widget
│   │   ├── routes.dart     # Route definitions
│   │   └── navigation_extensions.dart
│   ├── core/               # Core utilities and configs
│   │   ├── constants/      # App constants
│   │   │   ├── app_colors.dart
│   │   │   ├── app_dimensions.dart
│   │   │   ├── app_text_styles.dart
│   │   │   └── asset_paths.dart
│   │   ├── data/           # Sample data
│   │   ├── models/         # Data models
│   │   │   ├── lesson_model.dart
│   │   │   ├── practice_session_model.dart
│   │   │   ├── progress_model.dart
│   │   │   └── user_model.dart
│   │   ├── providers/      # Global providers
│   │   │   └── theme_provider.dart
│   │   ├── services/       # Service layer
│   │   │   ├── notification_service.dart
│   │   │   ├── firebase_service.dart
│   │   │   ├── audio_service.dart
│   │   │   └── storage_service.dart
│   │   ├── theme/          # App theming
│   │   ├── utils/          # Utility functions
│   │   │   ├── animations.dart
│   │   │   ├── error_handler.dart
│   │   │   ├── helpers.dart
│   │   │   └── validators.dart
│   │   └── widgets/        # Shared UI components
│   │       ├── animated_background.dart
│   │       ├── custom_button.dart
│   │       ├── custom_card.dart
│   │       ├── custom_text_field.dart
│   │       ├── empty_state.dart
│   │       ├── glass_container.dart
│   │       ├── loading_indicator.dart
│   │       ├── premium_button.dart
│   │       ├── progress_ring.dart
│   │       └── shimmer_widgets.dart
│   ├── database/           # Local database
│   │   ├── database_helper.dart
│   │   ├── database_tables.dart
│   │   └── sync_service.dart
│   ├── features/           # Feature-based modules
│   │   ├── auth/           # Authentication feature
│   │   │   ├── auth_screen.dart
│   │   │   ├── models/
│   │   │   │   └── auth_state.dart
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart
│   │   │   └── screens/
│   │   │       ├── login_screen.dart
│   │   │       ├── onboarding_screen.dart
│   │   │       ├── signup_screen.dart
│   │   │       └── splash_screen.dart
│   │   ├── home/           # Home/Dashboard feature
│   │   │   ├── home_screen.dart
│   │   │   ├── main_scaffold.dart
│   │   │   ├── models/
│   │   │   │   └── progress_summary.dart
│   │   │   ├── providers/
│   │   │   │   └── home_provider.dart
│   │   │   └── widgets/
│   │   │       ├── action_card.dart
│   │   │       ├── bottom_nav_bar.dart
│   │   │       ├── progress_overview_card.dart
│   │   │       ├── quick_stats_row.dart
│   │   │       └── welcome_header.dart
│   │   ├── lessons/        # Lessons feature
│   │   │   ├── lessons_screen.dart
│   │   │   ├── data/
│   │   │   │   ├── lessons_seed_data.json
│   │   │   │   ├── README.md
│   │   │   │   └── seed_lessons.dart
│   │   │   ├── models/
│   │   │   │   ├── lesson_content.dart
│   │   │   │   └── lesson.dart
│   │   │   ├── providers/
│   │   │   │   └── lessons_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── lesson_detail_screen.dart
│   │   │   │   └── lessons_list_screen.dart
│   │   │   └── widgets/
│   │   │       ├── lesson_card.dart
│   │   │       ├── lesson_demo_section.dart
│   │   │       └── lesson_theory_section.dart
│   │   ├── piano/          # Piano feature
│   │   │   ├── piano_test_screen.dart
│   │   │   ├── models/
│   │   │   │   ├── note.dart
│   │   │   │   └── piano_key.dart
│   │   │   ├── providers/
│   │   │   │   └── audio_service_provider.dart
│   │   │   ├── services/
│   │   │   │   └── audio_player_service.dart
│   │   │   └── widgets/
│   │   │       ├── black_key.dart
│   │   │       ├── piano_keyboard.dart
│   │   │       └── white_key.dart
│   │   ├── practice/       # Practice feature
│   │   │   ├── practice_screen.dart
│   │   │   ├── models/
│   │   │   │   ├── practice_challenge.dart
│   │   │   │   └── practice_session.dart
│   │   │   ├── providers/
│   │   │   │   └── practice_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── practice_mode_screen.dart
│   │   │   │   └── practice_results_screen.dart
│   │   │   └── widgets/
│   │   │       ├── challenge_card.dart
│   │   │       ├── feedback_overlay.dart
│   │   │       └── score_display.dart
│   │   ├── profile/        # Profile feature
│   │   │   ├── profile_screen.dart
│   │   │   ├── models/
│   │   │   │   └── user_preferences.dart
│   │   │   ├── providers/
│   │   │   │   └── profile_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── edit_profile_screen.dart
│   │   │   │   └── profile_screen.dart
│   │   │   └── widgets/
│   │   │       ├── profile_header.dart
│   │   │       ├── settings_section.dart
│   │   │       └── settings_tile.dart
│   │   └── progress/       # Progress feature
│   │       ├── progress_screen.dart
│   │       ├── data/
│   │       │   └── achievements_data.dart
│   │       ├── models/
│   │       │   ├── achievement.dart
│   │       │   └── user_progress.dart
│   │       ├── providers/
│   │       │   └── progress_provider.dart
│   │       ├── screens/
│   │       │   └── progress_screen.dart
│   │       ├── utils/
│   │       │   └── progress_initializer.dart
│   │       └── widgets/
│   │           ├── achievement_grid.dart
│   │           ├── progress_chart.dart
│   │           └── stats_overview.dart
│   └── services/           # Global services
│       ├── audio_service.dart
│       ├── firebase_service.dart
│       └── storage_service.dart
├── pubspec.yaml            # Flutter dependencies
└── README.md               # This file
```

### Architecture Pattern

This app follows the **Feature-Based Architecture** with **Riverpod** for state management:

```
┌─────────────────────────────────────────────────────────┐
│                      Presentation Layer                  │
│  ┌───────────────────────────────────────────────────┐  │
│  │                   UI Widgets                      │  │
│  │  (Screens, Buttons, Cards, Custom Components)    │  │
│  └───────────────────────────────────────────────────┘  │
│                          │                              │
│                          ▼                              │
│  ┌───────────────────────────────────────────────────┐  │
│  │                State Management                   │  │
│  │              (Riverpod Providers)                 │  │
│  └───────────────────────────────────────────────────┘  │
│                          │                              │
│                          ▼                              │
├─────────────────────────────────────────────────────────┤
│                      Business Logic                      │
│  ┌───────────────────────────────────────────────────┐  │
│  │                   Use Cases                       │  │
│  │         (Feature-specific logic & rules)         │  │
│  └───────────────────────────────────────────────────┘  │
│                          │                              │
│                          ▼                              │
├─────────────────────────────────────────────────────────┤
│                      Data Layer                          │
│  ┌───────────────────┐    ┌─────────────────────────┐  │
│  │   Local Storage   │    │    Remote Storage       │  │
│  │  (Hive, SQLite,   │    │  (Firebase Firestore,   │  │
│  │   SharedPrefs)    │    │   Firebase Storage)    │  │
│  └───────────────────┘    └─────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### State Management Strategy

**Riverpod** is used with a multi-level approach:

1. **Global Providers**: App-wide state (theme, auth state)
2. **Feature Providers**: Feature-specific state (piano, lessons, progress)
3. **View Models**: UI state for screens

```dart
// Example: Global provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// Example: Feature provider
final pianoProvider = StateNotifierProvider<PianoNotifier, PianoState>((ref) {
  return PianoNotifier();
});
```

### Data Flow

```
User Action → UI Widget → Riverpod Provider → Service → Data Source
              ←           ←                 ←          ←
           State Update   UI BUILD        Response   Result
```

---

## 🎨 Design Decisions

### Why Riverpod?

| Decision | Reasoning |
|----------|-----------|
| **Riverpod over Bloc** | Simpler learning curve, better testability, no BuildContext required |
| **Riverpod over Provider** | Better dependency management, compile-time safety |
| **StateNotifier** | Immutable state updates, easier debugging |

### Why Multi-Layer Storage?

| Storage | Use Case | Reasoning |
|---------|----------|-----------|
| **Shared Preferences** | Simple settings | Fast, easy to use for small data |
| **Hive** | User preferences, cached data | Fast NoSQL, type-safe with Hive Generators |
| **SQLite (sqflite)** | Structured relational data | Complex queries, relationships |

### Audio Handling

| Decision | Reasoning |
|----------|-----------|
| **Pre-loaded samples** | Low latency, instant feedback |
| **audioplayers** | Cross-platform, good performance |
| **Asset-based audio** | Consistent quality, no network dependency |

### Navigation

| Decision | Reasoning |
|----------|-----------|
| **go_router** | Declarative, type-safe, deep linking support |
| **Nested navigation** | Better state management per tab |

---

## 🚀 Setup Instructions

### Prerequisites

| Requirement | Version | Notes |
|-------------|---------|-------|
| Flutter SDK | 3.10.4+ | Use `flutter --version` to check |
| Dart SDK | 3.0.0+ | Included with Flutter |
| Android Studio | 2022.0+ | For Android development |
| Xcode | 14.0+ | For iOS development (Mac only) |
| Node.js | 18.0+ | For Firebase CLI (optional) |

### Step 1: Install Flutter

```bash
# Verify installation
flutter --version

# Check for any missing dependencies
flutter doctor
```

### Step 2: Clone and Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/melodify.git
cd melodify

# Install dependencies
flutter pub get

# Generate Hive adapters (if using build_runner)
flutter pub run build_runner build
```

### Step 3: Firebase Setup

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Add project" and follow the wizard

2. **Add Android App**
   - Click the Android icon to add an Android app
   - Enter your package name: `com.example.melodify`
   - Download `google-services.json` and place it in `android/app/`

3. **Add iOS App** (Mac only)
   - Click the iOS icon to add an iOS app
   - Enter your bundle ID: `com.example.melodify`
   - Download `GoogleService-Info.plist` and place it in `ios/Runner/`

4. **Enable Authentication**
   - Go to "Authentication" in Firebase Console
   - Enable "Email/Password" sign-in method

5. **Enable Firestore**
   - Go to "Firestore Database" in Firebase Console
   - Create a database in test mode (for development) or production mode (for production)

6. **Enable Storage**
   - Go to "Storage" in Firebase Console
   - Enable storage for storing user images and files

### Step 4: Run the App

```bash
# Run in debug mode
flutter run

# Run in release mode
flutter run --release

# Build for Android
flutter build apk

# Build for iOS
flutter build ios
```

---

## 📁 Project Structure Overview

### Core Layer (`lib/core/`)

The core layer contains shared utilities and configurations:

```
lib/core/
├── constants/     # App-wide constants (colors, dimensions, text styles)
├── data/         # Sample data and seed data
├── models/       # Shared data models
├── providers/    # Global providers (theme, app config)
├── services/     # Global services (notifications, Firebase)
├── theme/        # App theming
├── utils/        # Utility functions (helpers, validators)
└── widgets/      # Shared/custom UI components
```

### Features Layer (`lib/features/`)

Each feature is a self-contained module:

```
lib/features/
├── auth/         # Authentication (login, signup, splash)
├── home/         # Home screen and dashboard
├── lessons/      # Lessons and tutorials
├── piano/        # Piano keyboard and audio
├── practice/     # Practice modes and exercises
├── profile/      # User profile and settings
└── progress/     # Progress tracking and achievements
```

### Database Layer (`lib/database/`)

Local data storage:

```
lib/database/
├── database_helper.dart   # Main database interface
├── database_tables.dart   # Table definitions
└── sync_service.dart      # Cloud sync service
```

### Services Layer (`lib/services/`)

Global services:

```
lib/services/
├── audio_service.dart     # Audio playback
├── firebase_service.dart   # Firebase operations
└── storage_service.dart    # File storage
```

---

## 🧪 Testing

### Unit Testing

```bash
# Run unit tests
flutter test

# Run unit tests with coverage
flutter test --coverage
```

### Widget Testing

```bash
# Run widget tests
flutter test
```

### Integration Testing

```bash
# Run integration tests
flutter test integration_test/
```

---

## 📦 Building for Release

### Android

```bash
# Generate keystore (first time only)
keytool -genkey -v -keystore android/app/melodify-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias melodify-key

# Build release APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### iOS

```bash
# Build for release
flutter build ipa

# Or build for simulator testing
flutter build ios --simulator
```

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

### Development
- **Lead Developer**: Junaid Tahir
- **UI/UX Design**: Junaid Tahir


### Open Source Libraries

| Library | Version | License |
|---------|---------|---------|
| flutter_riverpod | 2.4.0 | MIT |
| firebase_core | 2.24.0 | Apache 2.0 |
| audioplayers | 5.2.1 | MIT |
| go_router | 13.0.0 | MIT |
| fl_chart | 0.66.0 | MIT |

---

## 📞 Support

If you have any questions or need help, please:

1. Check the [Documentation](docs/)
2. Open an [Issue](https://github.com/Junaid546/Piano_learning-_app/issues)
3. Email: junaidt950@gmail.com

---

<p align="center">
  Made with ❤️ for piano learners everywhere
</p>
