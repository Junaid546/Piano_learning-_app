import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'services/firebase_service.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite database
  await DatabaseHelper.getInstance().initDatabase();

  // Initialize Firebase
  await FirebaseService.init();

  runApp(const ProviderScope(child: PianoApp()));
}
