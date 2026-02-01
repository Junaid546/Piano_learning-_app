import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'services/firebase_service.dart';
import 'database/database_helper.dart';
import 'features/piano/providers/audio_service_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite database
  await DatabaseHelper.getInstance().initDatabase();

  // Initialize Firebase
  await FirebaseService.init();

  // Create ProviderContainer for audio initialization
  final container = ProviderContainer();

  // Initialize audio service
  try {
    await container.read(audioInitializationProvider.future);
  } catch (e) {
    debugPrint('Error initializing audio: $e');
  }

  runApp(
    UncontrolledProviderScope(container: container, child: const PianoApp()),
  );
}
