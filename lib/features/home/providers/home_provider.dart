import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/models/progress_model.dart';
import '../models/progress_summary.dart';

final homeProvider = StreamProvider.autoDispose<ProgressSummary>((ref) {
  final authState = ref.watch(authProvider);
  final user = authState.firebaseUser;

  if (user == null) {
    return Stream.value(ProgressSummary.initial());
  }

  // Listen to the progress document for the current user
  return FirebaseFirestore.instance
      .collection('progress')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) {
          return ProgressSummary.initial();
        }

        try {
          final data = snapshot.data()!;
          // Use the core ProgressModel to parse data safely, then map to View Model
          final progressModel = ProgressModel.fromJson(data);

          // Calculate level based on practice time (Example logic: 1 level per 60 mins)
          final int calculatedLevel =
              1 + (progressModel.totalPracticeTime / 60).floor();

          return ProgressSummary(
            lessonsCompletedCount: progressModel.lessonsCompleted.length,
            totalLessons: 50,
            practiceSessionsCount: progressModel.practiceAttempts,
            totalPracticeTimeMinutes: progressModel.totalPracticeTime,
            currentStreak: progressModel.currentStreak,
            currentLevel: calculatedLevel,
            recentAchievements: progressModel.achievements.take(3).toList(),
          );
        } catch (e) {
          // If parsing fails, return initial state
          return ProgressSummary.initial();
        }
      });
});
