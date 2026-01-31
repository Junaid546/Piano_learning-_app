import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../firebase_options.dart';

final firebaseInitializerProvider = FutureProvider<void>((ref) async {
  await FirebaseService.init();
});

class FirebaseService {
  static Future<void> init() async {
    if (Platform.isAndroid) {
      // Use native configuration from google-services.json
      await Firebase.initializeApp();
    } else {
      // Use Dart-based configuration for other platforms
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }
}
