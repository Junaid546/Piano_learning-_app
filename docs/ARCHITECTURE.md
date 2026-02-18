# Melodify Architecture Documentation

This document provides a detailed explanation of Melodify's architecture, design patterns, and implementation details.

## 📋 Table of Contents

1. [Overview](#overview)
2. [Architecture Pattern](#architecture-pattern)
3. [Folder Structure](#folder-structure)
4. [State Management](#state-management)
5. [Data Flow](#data-flow)
6. [Firebase Integration](#firebase-integration)
7. [Audio Handling](#audio-handling)
8. [Navigation Structure](#navigation-structure)
9. [Data Storage Strategy](#data-storage-strategy)
10. [Security Considerations](#security-considerations)

---

## Overview

Melodify is a cross-platform piano learning application built with Flutter. It follows modern architectural best practices to ensure scalability, maintainability, and testability.

### Key Design Goals

| Goal | Description |
|------|-------------|
| **Separation of Concerns** | Clear separation between UI, business logic, and data layers |
| **Testability** | Architecture designed for easy unit and widget testing |
| **Scalability** | Feature-based structure allowing easy addition of new features |
| **Performance** | Optimized for smooth performance on all platforms |
| **Maintainability** | Clean code with consistent patterns and documentation |

---

## Architecture Pattern

### Feature-Based Architecture

Melodify uses a **Feature-Based Architecture** where the app is divided into independent features. Each feature is self-contained and includes all necessary components:

```
┌─────────────────────────────────────────────────────────────┐
│                      Feature Module                          │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Screens/     Widgets/      Providers/      Models/  │
│  │  Views         UI Components  State Mgmt     Data     │
│  └─────────────────────────────────────────────────────┘    │
│                          │                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Services/      Utils/         Data/        ...      │
│  │  Business Logic  Helpers       Sources               │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### Why Feature-Based?

1. **Modularity**: Each feature can be developed, tested, and maintained independently
2. **Reusability**: Components within a feature can be reused across the feature
3. **Scalability**: Easy to add new features without affecting existing code
4. **Team Collaboration**: Multiple developers can work on different features simultaneously

### Layered Architecture

Within each feature and at the app level, Melodify follows a layered approach:

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌───────────────────────────────────────────────────┐  │
│  │              Screens & View Models                │  │
│  │              (Flutter Widgets)                   │  │
│  └───────────────────────────────────────────────────┘  │
│                          │                              │
├─────────────────────────────────────────────────────────┤
│                    Business Logic Layer                  │
│  ┌───────────────────────────────────────────────────┐  │
│  │               Use Cases / Providers              │  │
│  │               (Riverpod StateNotifiers)          │  │
│  └───────────────────────────────────────────────────┘  │
│                          │                              │
├─────────────────────────────────────────────────────────┤
│                    Data Layer                            │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Services/    Repositories/    Data Sources      │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## Folder Structure

### Root Level

```
melodify/
├── android/          # Android native configuration
├── assets/           # Static assets (audio, images, animations)
├── docs/             # Documentation files
├── ios/              # iOS native configuration
├── lib/              # Main Flutter application code
└── [config files]    # pubspec.yaml, analysis_options.yaml, etc.
```

### Lib Directory Structure

```
lib/
├── main.dart                    # App entry point
├── app/                         # App configuration & routing
│   ├── app.dart                 # Main app widget
│   ├── routes.dart              # Route definitions
│   └── navigation_extensions.dart
├── core/                        # Core/shared components
│   ├── constants/               # App constants
│   ├── data/                    # Sample/seeding data
│   ├── models/                  # Shared data models
│   ├── providers/               # Global providers
│   ├── services/                # Global services
│   ├── theme/                   # App theme
│   ├── utils/                   # Utility functions
│   └── widgets/                 # Shared UI widgets
├── database/                    # Local database
├── features/                    # Feature modules
└── services/                    # Global services
```

### Feature Structure

Each feature follows this structure:

```
features/[feature_name]/
├── [feature_name]_screen.dart   # Main screen/widget
├── models/                      # Feature-specific models
│   └── [model_name].dart
├── providers/                   # Feature-specific providers
│   └── [feature]_provider.dart
├── screens/                     # Feature screens
│   ├── screen1.dart
│   └── screen2.dart
├── widgets/                     # Feature-specific widgets
│   ├── widget1.dart
│   └── widget2.dart
├── data/                        # Feature data (seed data, etc.)
│   └── [data_files]
└── utils/                       # Feature utilities
    └── [utility_files]
```

---

## State Management

### Riverpod Implementation

Melodify uses **Riverpod 2.4.0** for state management. Riverpod was chosen for its:

- **Compile-time safety**: No runtime errors from missing providers
- **Testability**: Easy to mock and test providers
- **No BuildContext dependency**: Providers can be accessed anywhere
- **Better separation**: Clear distinction between read-only and mutable state

### Provider Types Used

#### 1. StateNotifierProvider (Most Common)

Used for complex state that requires mutation:

```dart
// Example: Piano state management
final pianoProvider = StateNotifierProvider<PianoNotifier, PianoState>((ref) {
  return PianoNotifier();
});

class PianoNotifier extends StateNotifier<PianoState> {
  PianoNotifier() : super(const PianoState());
  
  void playNote(Note note) {
    // Update state
  }
  
  void stopNote(Note note) {
    // Update state
  }
}
```

#### 2. StateProvider (Simple State)

Used for simple state like UI states:

```dart
// Example: Theme state
final themeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});
```

#### 3. FutureProvider (Async Data)

Used for fetching async data:

```dart
// Example: User data
final userProvider = FutureProvider<User>((ref) async {
  final userService = ref.read(userServiceProvider);
  return await userService.getUser();
});
```

#### 4. StreamProvider (Real-time Data)

Used for real-time data from Firebase:

```dart
// Example: Progress stream
final progressStreamProvider = StreamProvider<UserProgress>((ref) {
  final progressService = ref.read(progressServiceProvider);
  return progressService.getProgressStream();
});
```

### Provider Scope

| Provider Type | Scope | Usage |
|---------------|-------|-------|
| **Global** | App-wide | Auth state, theme, app config |
| **Feature** | Single feature | Feature-specific state |
| **Local** | Single screen | Screen-specific UI state |

### State Management Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                      User Action                             │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│                  UI Component (Widget)                       │
│  • Button press                                                │
│  • Text input                                                  │
│  • Gesture detection                                           │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼ (ref.read/watch)
┌──────────────────────────────────────────────────────────────┐
│                  Riverpod Provider                           │
│  • StateNotifier                                              │
│  • StateProvider                                              │
│  • FutureProvider                                             │
│  • StreamProvider                                             │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼ (async/sync call)
┌──────────────────────────────────────────────────────────────┐
│                    Service Layer                             │
│  • AudioService                                               │
│  • FirebaseService                                            │
│  • StorageService                                             │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼ (CRUD operations)
┌──────────────────────────────────────────────────────────────┐
│                    Data Source                               │
│  • Local (Hive, SQLite, SharedPrefs)                         │
│  • Remote (Firebase Firestore, Storage)                      │
└──────────────────────────────────────────────────────────────┘
```

---

## Data Flow

### Unidirectional Data Flow

Melodify follows unidirectional data flow for predictable state management:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Action    │────▶│  Provider   │────▶│  Service    │────▶│  Data Store │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
      ▲                                            │
      │                                            │
      └────────────────────────────────────────────┘
                     (State Update)
```

### Example: Playing a Note

1. **User Action**: User taps a piano key
2. **UI Event**: Widget calls `ref.read(pianoProvider).playNote(note)`
3. **State Update**: Provider updates state with pressed key
4. **UI Rebuild**: Widget rebuilds with new state
5. **Audio Trigger**: Audio service plays the note
6. **Feedback**: Visual feedback is shown

### Data Synchronization

```
┌─────────────────────────────────────────────────────────┐
│                   Local Data Store                       │
│  (Hive, SQLite, SharedPreferences)                      │
└─────────────────────┬───────────────────────────────────┘
                      │ Write
                      │ Read
                      ▼
┌─────────────────────────────────────────────────────────┐
│                  Sync Service                            │
│  • Detects changes                                       │
│  • Manages conflict resolution                           │
│  • Handles offline/online states                         │
└─────────────────────┬───────────────────────────────────┘
                      │ Write
                      │ Read
                      ▼
┌─────────────────────────────────────────────────────────┐
│                  Firebase Cloud                          │
│  (Firestore, Storage)                                    │
└─────────────────────────────────────────────────────────┘
```

---

## Firebase Integration

### Firebase Services Used

| Service | Purpose | Data Flow |
|---------|---------|-----------|
| **Firebase Auth** | User authentication | Read/Write |
| **Cloud Firestore** | User data & progress | Read/Write (Real-time) |
| **Firebase Storage** | User images & files | Read/Write |

### Authentication Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    Authentication Flow                       │
│                                                              │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐  │
│  │  Login  │───▶│ Firebase│───▶│  Token  │───▶│  App    │  │
│  │  Screen │    │   Auth  │    │  Stored │    │  State  │  │
│  └─────────┘    └─────────┘    └─────────┘    └─────────┘  │
│       ▲                                           │        │
│       │                                           │        │
│       └───────────────────────────────────────────┘        │
│                   (User Session)                          │
└─────────────────────────────────────────────────────────────┘
```

### Firestore Data Model

```
users/{userId}/
├── profile/
│   ├── displayName: string
│   ├── email: string
│   ├── avatarUrl: string
│   └── createdAt: timestamp
├── progress/
│   ├── currentLevel: number
│   ├── totalPoints: number
│   ├── streak: number
│   ├── lastPracticeDate: timestamp
│   └── completedLessons: array
├── achievements/
│   ├── unlockedIds: array
│   └── unlockedAt: map
└── settings/
    ├── notificationsEnabled: boolean
    └── preferredTheme: string
```

### Real-time Listeners

```dart
// Example: Listening to user progress in real-time
final progressStreamProvider = StreamProvider<UserProgress>((ref) {
  final userId = ref.watch(authProvider).currentUser?.uid;
  if (userId == null) return Stream.value(null);
  
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('progress')
      .doc('main')
      .snapshots()
      .map((snapshot) {
        if (snapshot.exists) {
          return UserProgress.fromFirestore(snapshot.data()!);
        }
        return UserProgress.initial();
      });
});
```

---

## Audio Handling

### Audio Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Audio Architecture                        │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                  UI Layer                           │    │
│  │  PianoKeyboardWidget ──▶ Key Press Detection       │    │
│  └────────────────────────────┬────────────────────────┘    │
│                               │                              │
│                               ▼                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │               Audio Service Provider                │    │
│  │  • Manages audio state                              │    │
│  │  • Coordinates multiple players                     │    │
│  │  • Handles audio focus                              │    │
│  └────────────────────────────┬────────────────────────┘    │
│                               │                              │
│                               ▼                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Audio Player Service                   │    │
│  │  • Low-level audio playback                         │    │
│  │  • Pre-loaded samples                               │    │
│  │  • Volume & pitch control                           │    │
│  └────────────────────────────┬────────────────────────┘    │
│                               │                              │
│                               ▼                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                Audio Files (Assets)                 │    │
│  │  piano/A0.mp3, piano/A1.mp3, ..., piano/C8.mp3     │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### Audio Player Service

```dart
/// Service responsible for playing piano audio samples.
/// Uses audioplayers for cross-platform audio playback.
class AudioPlayerService {
  /// Map of note names to their corresponding AudioPlayer instances.
  /// Pre-creating players improves response time.
  final Map<String, AudioPlayer> _players = {};
  
  /// Initializes all audio players with pre-loaded samples.
  Future<void> initialize() async {
    for (final note in pianoNotes) {
      final player = AudioPlayer();
      await player.setSource(AssetSource('audio/piano/$note.mp3'));
      _players[note] = player;
    }
  }
  
  /// Plays a specific note with minimal latency.
  Future<void> playNote(String note) async {
    final player = _players[note];
    if (player != null) {
      await player.seek(Duration.zero);
      await player.resume();
    }
  }
}
```

### Audio Pre-loading Strategy

| Strategy | Benefit |
|----------|---------|
| **Pre-load all notes** | Instant playback, no network latency |
| **Use AssetSource** | No network dependency, consistent quality |
| **Multiple players** | Support for chords (multiple notes simultaneously) |

### Audio File Format

- **Format**: MP3
- **Sample Rate**: 44.1 kHz (standard audio CD quality)
- **Bitrate**: 192 kbps (balanced quality/size)
- **Duration**: 2-3 seconds per note (enough for sustain)

---

## Navigation Structure

### Routing with go_router

Melodify uses **go_router** for declarative routing:

```dart
// routes.dart
final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'piano',
          builder: (context, state) => const PianoTestScreen(),
        ),
        GoRoute(
          path: 'lessons',
          builder: (context, state) => const LessonsScreen(),
        ),
        GoRoute(
          path: 'progress',
          builder: (context, state) => const ProgressScreen(),
        ),
      ],
    ),
  ],
);
```

### Navigation Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Navigation Structure                      │
│                                                              │
│  splash (/)                                                 │
│     │                                                       │
│     ▼                                                       │
│  login (/login) ─────────────────────────────────────────┐  │
│     │                                                       │  │
│     ▼                                                       │  │
│  home (/home) ──────┬─────────────┬─────────────┐          │  │
│                     │             │             │          │  │
│                     ▼             ▼             ▼          │  │
│               piano       lessons      profile             │  │
│               (/home/     (/home/      (/home/             │  │
│                piano)      lessons)     profile)           │  │
│                     │             │             │          │  │
│                     ▼             ▼             ▼          │  │
│               practice    lesson     settings              │  │
│               mode        detail                    ◀──────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Deep Linking

go_router supports deep linking out of the box:

```dart
// Android deep link
Intent intent = Intent()
  ..action = Intent.ACTION_VIEW
  ..data = Uri.parse('melodify://home/piano');

// Web URL
// https://melodify.com/home/piano
```

---

## Data Storage Strategy

### Multi-Layer Storage

Melodify uses multiple storage solutions based on data characteristics:

```
┌─────────────────────────────────────────────────────────────┐
│                    Storage Strategy                          │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Shared Preferences                      │    │
│  │  • Simple key-value pairs                           │    │
│  │  • App settings, flags, small data                  │    │
│  │  • Example: theme_mode, notification_enabled        │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                    Hive                             │    │
│  │  • NoSQL document store                             │    │
│  │  • User preferences, cached data                    │    │
│  │  • Fast read/write, type-safe                       │    │
│  │  • Example: user_preferences, lesson_progress       │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                  SQLite (sqflite)                   │    │
│  │  • Relational database                              │    │
│  │  • Complex queries, relationships                   │    │
│  │  • Example: practice_sessions, lesson_history       │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Firebase Firestore                     │    │
│  │  • Cloud database                                   │    │
│  │  • User data sync, real-time updates                │    │
│  │  • Example: user_profile, achievements, leaderboard │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### Storage Selection Guidelines

| Data Type | Recommended Storage | Reason |
|-----------|---------------------|--------|
| **Settings/Flags** | Shared Preferences | Simple, fast, small data |
| **User Preferences** | Hive | Type-safe, fast, offline-first |
| **Session Data** | SQLite | Complex queries, relationships |
| **User Profile** | Firestore + Hive | Cloud sync, offline access |
| **Progress** | Firestore + SQLite | Real-time sync, complex queries |
| **Achievements** | Firestore + Hive | Cloud sync, offline viewing |

### Database Schema

#### SQLite Tables

```sql
-- Practice sessions table
CREATE TABLE practice_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  lesson_id TEXT,
  start_time DATETIME NOT NULL,
  end_time DATETIME,
  score INTEGER,
  notes_played INTEGER,
  accuracy REAL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Lesson progress table
CREATE TABLE lesson_progress (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  lesson_id TEXT NOT NULL,
  status TEXT NOT NULL, -- 'not_started', 'in_progress', 'completed'
  score INTEGER,
  attempts INTEGER DEFAULT 0,
  completed_at DATETIME,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, lesson_id)
);
```

---

## Security Considerations

### Authentication Security

| Measure | Implementation |
|---------|---------------|
| **Password Requirements** | Minimum 8 characters, complexity validation |
| **Session Management** | Firebase Auth with automatic token refresh |
| **Password Reset** | Secure email-based reset flow |
| **Account Lockout** | After multiple failed attempts |

### Data Security

| Measure | Implementation |
|---------|---------------|
| **Firestore Rules** | User can only read/write their own data |
| **Storage Rules** | Authenticated access only |
| **Data Validation** | Server-side validation with model validation |
| **Encryption** | HTTPS for all network requests |

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Progress data
    match /users/{userId}/progress/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Achievements
    match /users/{userId}/achievements/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Local Storage Security

| Measure | Implementation |
|---------|---------------|
| **Keystore** | Android Keystore for sensitive data |
| **Encryption** | Hive encrypted boxes for sensitive data |
| **Keychain** | iOS Keychain for credentials |

---

## Performance Optimizations

### Audio Performance

| Optimization | Implementation |
|--------------|----------------|
| **Pre-loading** | All audio samples loaded at app start |
| **Audio Pooling** | Reuse AudioPlayer instances |
| **Low Latency** | Asset-based audio for instant playback |

### UI Performance

| Optimization | Implementation |
|--------------|----------------|
| **Lazy Loading** | Lessons loaded on demand |
| **Caching** | Cached images and data |
| **Animation Optimization** | Use `RepaintBoundary` for complex animations |
| **List Optimization** | ListView.builder for large lists |

### Network Performance

| Optimization | Implementation |
|--------------|----------------|
| **Offline First** | Local data prioritized |
| **Background Sync** | Sync in background when online |
| **Batch Operations** | Batch Firestore writes |

---

## Testing Strategy

### Unit Tests

Test providers and services:

```dart
void main() {
  test('PianoNotifier playNote updates state', () {
    // Create provider
    final pianoNotifier = PianoNotifier();
    
    // Verify initial state
    expect(pianoNotifier.state.pressedKeys, isEmpty);
    
    // Play a note
    pianoNotifier.playNote(Note('C4'));
    
    // Verify state updated
    expect(pianoNotifier.state.pressedKeys, contains('C4'));
  });
}
```

### Widget Tests

Test UI components:

```dart
void main() {
  testWidgets('PianoKey shows feedback when pressed', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: PianoKey(note: Note('C4')),
        ),
      ),
    );
    
    // Find the key widget
    final keyFinder = find.byType(PianoKey);
    
    // Verify key exists
    expect(keyFinder, findsOneWidget);
  });
}
```

---

## Conclusion

Melodify's architecture is designed for:

1. **Scalability**: Easy to add new features
2. **Maintainability**: Clean, well-organized code
3. **Testability**: Comprehensive testing support
4. **Performance**: Optimized for smooth user experience
5. **Security**: Built-in security best practices

For more information, see:
- [README.md](../README.md)
- [SETUP.md](SETUP.md)
- [TODO.md](TODO.md)
