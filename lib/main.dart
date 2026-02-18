import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// App entry point and core initialization
import 'app/app.dart';
import 'services/firebase_service.dart';
import 'database/database_helper.dart';
import 'features/piano/providers/audio_service_provider.dart';

/// Main entry point for the Melodify application.
///
/// This function initializes all required services before starting the app:
/// 1. Database initialization (SQLite for local storage)
/// 2. Firebase initialization (authentication and cloud storage)
/// 3. Audio service initialization (piano sound samples)
///
/// The app uses Riverpod for state management, so we create a
/// [ProviderContainer] to initialize providers before running the app.
void main() async {
  // Ensure Flutter binding is initialized before async operations
  // This is required for plugins that use platform channels
  WidgetsFlutterBinding.ensureInitialized();

  // Step 1: Initialize SQLite database for local data persistence
  // This stores lesson progress, practice sessions, and user preferences
  await DatabaseHelper.getInstance().initDatabase();

  // Step 2: Initialize Firebase for cloud services
  // This enables authentication, Firestore database, and cloud storage
  await FirebaseService.init();

  // Step 3: Create ProviderContainer for Riverpod
  // This allows us to initialize providers before the app starts
  // We need this for the audio service which requires pre-loading samples
  final container = ProviderContainer();

  // Initialize audio service in the background
  // This pre-loads all piano sound samples for low-latency playback
  // Using try-catch to handle cases where audio might not be available
  try {
    await container.read(audioInitializationProvider.future);
  } catch (e) {
    // Log error but don't crash - audio is not critical for app startup
    debugPrint('Error initializing audio: $e');
  }

  // Run the app with Riverpod provider scope
  // UncontrolledProviderScope allows the container to be managed by the widget tree
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MelodifyApp(),
    ),
  );
}
