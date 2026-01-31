import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

// Initialize progress document for new users
Future<void> initializeUserProgress(String userId) async {
  final progressRef = FirebaseFirestore.instance
      .collection('progress')
      .doc(userId);

  final doc = await progressRef.get();

  if (!doc.exists) {
    // Get total lessons count
    final lessonsSnapshot = await FirebaseFirestore.instance
        .collection('lessons')
        .get();

    await progressRef.set({
      'userId': userId,
      'lessonsCompleted': 0,
      'totalLessons': lessonsSnapshot.docs.length,
      'practiceAttempts': 0,
      'totalPracticeTime': 0,
      'currentStreak': 0,
      'longestStreak': 0,
      'accuracy': 0.0,
      'level': 1,
      'xp': 0,
      'achievementsUnlocked': [],
      'lastPracticeDate': null,
      'practiceDates': {},
    });
  }
}

// Provider to initialize progress on auth
final progressInitializerProvider = Provider((ref) {
  final user = ref.watch(authProvider).firebaseUser;

  if (user != null) {
    // Initialize progress document if needed
    initializeUserProgress(user.uid);
  }

  return null;
});
