import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

/// Seeds the initial lessons data to Firestore
/// This should only be called ONCE to populate the database
Future<void> seedLessons() async {
  try {
    // Load the JSON file
    final jsonString = await rootBundle.loadString(
      'lib/features/lessons/data/lessons_seed_data.json',
    );

    // Parse JSON
    final data = json.decode(jsonString);
    final lessons = data['lessons'] as List;

    // Get Firestore instance
    final firestore = FirebaseFirestore.instance;

    // Use batch for efficient writes
    final batch = firestore.batch();

    // Add each lesson to Firestore
    for (final lesson in lessons) {
      final docRef = firestore.collection('lessons').doc(lesson['id']);
      batch.set(docRef, lesson);
    }

    // Commit the batch
    await batch.commit();

    print('✅ Successfully seeded ${lessons.length} lessons to Firestore!');
  } catch (e) {
    print('❌ Error seeding lessons: $e');
    rethrow;
  }
}
