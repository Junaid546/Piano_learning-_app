import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/user_progress.dart';
import '../models/achievement.dart';
import '../data/achievements_data.dart';
import '../../../database/sync_service.dart';

// Progress provider with cache-first pattern
final userProgressProvider = StreamProvider<UserProgress>((ref) async* {
  final user = ref.watch(authProvider).firebaseUser;
  if (user == null) {
    yield const UserProgress(userId: '');
    return;
  }

  final syncService = SyncService();

  // 1. Load from cache first (instant UI)
  final cachedProgress = await syncService.loadUserProgressFromCache(user.uid);
  if (cachedProgress != null) {
    yield cachedProgress;
  } else {
    // Yield default progress immediately to prevent loading state
    yield UserProgress(userId: user.uid);
  }

  // 2. Stream from Firebase and update cache in background
  try {
    await for (final snapshot
        in FirebaseFirestore.instance
            .collection('progress')
            .doc(user.uid)
            .snapshots()) {
      final progress = snapshot.exists
          ? UserProgress.fromJson(snapshot.data()!)
          : UserProgress(userId: user.uid);

      // Update cache silently in background
      syncService.updateUserProgressInCache(progress);

      yield progress;
    }
  } catch (e) {
    debugPrint('Error loading progress: $e');
    // Keep showing cached or default progress on error
  }
});

// Achievements provider with progress
final achievementsProvider = StreamProvider<List<Achievement>>((ref) async* {
  final user = ref.watch(authProvider).firebaseUser;
  if (user == null) {
    yield AchievementsData.getAllAchievements();
    return;
  }

  final progressSnapshot = await FirebaseFirestore.instance
      .collection('progress')
      .doc(user.uid)
      .get();

  final progress = progressSnapshot.exists
      ? UserProgress.fromJson(progressSnapshot.data()!)
      : UserProgress(userId: user.uid);

  // Get all achievements and update with user progress
  final allAchievements = AchievementsData.getAllAchievements();
  final updatedAchievements = allAchievements.map((achievement) {
    final isUnlocked = progress.achievementsUnlocked.contains(achievement.id);
    int currentProgress = 0;

    // Calculate current progress based on category
    switch (achievement.category) {
      case 'lessons':
        currentProgress = progress.lessonsCompleted;
        break;
      case 'practice':
        currentProgress = progress.practiceAttempts;
        break;
      case 'streak':
        currentProgress = progress.longestStreak;
        break;
      case 'accuracy':
        currentProgress = progress.accuracy.round();
        break;
      case 'notes':
        // This would need to be tracked separately
        currentProgress = 0;
        break;
      case 'time':
        currentProgress = progress.totalPracticeTime;
        break;
    }

    return achievement.copyWith(
      currentProgress: currentProgress,
      isUnlocked: isUnlocked,
    );
  }).toList();

  yield updatedAchievements;
});

// Progress actions
class ProgressActions {
  final Ref _ref;

  ProgressActions(this._ref);

  Future<void> updateProgress({
    int? lessonsCompleted,
    int? practiceAttempts,
    int? practiceTime,
    double? accuracy,
    int? xpGained,
  }) async {
    final user = _ref.read(authProvider).firebaseUser;
    if (user == null) return;

    final progressRef = FirebaseFirestore.instance
        .collection('progress')
        .doc(user.uid);

    final updates = <String, dynamic>{};

    if (lessonsCompleted != null) {
      updates['lessonsCompleted'] = FieldValue.increment(lessonsCompleted);
    }
    if (practiceAttempts != null) {
      updates['practiceAttempts'] = FieldValue.increment(practiceAttempts);
    }
    if (practiceTime != null) {
      updates['totalPracticeTime'] = FieldValue.increment(practiceTime);

      // Update practice dates
      final today = DateTime.now().toIso8601String().split('T')[0];
      updates['practiceDates.$today'] = FieldValue.increment(practiceTime);
      updates['lastPracticeDate'] = DateTime.now().toIso8601String();
    }
    if (accuracy != null) {
      // Calculate new average accuracy
      final snapshot = await progressRef.get();
      if (snapshot.exists) {
        final current = UserProgress.fromJson(snapshot.data()!);
        final newAccuracy = (current.accuracy + accuracy) / 2;
        updates['accuracy'] = newAccuracy;
      } else {
        updates['accuracy'] = accuracy;
      }
    }
    if (xpGained != null) {
      updates['xp'] = FieldValue.increment(xpGained);
    }

    await progressRef.set(updates, SetOptions(merge: true));

    // Check for new achievements
    await _checkAchievements();
  }

  Future<void> updateStreak() async {
    final user = _ref.read(authProvider).firebaseUser;
    if (user == null) return;

    final progressRef = FirebaseFirestore.instance
        .collection('progress')
        .doc(user.uid);

    final snapshot = await progressRef.get();
    if (!snapshot.exists) {
      await progressRef.set({
        'userId': user.uid,
        'currentStreak': 1,
        'longestStreak': 1,
        'lastPracticeDate': DateTime.now().toIso8601String(),
      });
      return;
    }

    final progress = UserProgress.fromJson(snapshot.data()!);
    final now = DateTime.now();
    final lastPractice = progress.lastPracticeDate;

    if (lastPractice == null) {
      await progressRef.update({'currentStreak': 1, 'longestStreak': 1});
      return;
    }

    final daysSinceLastPractice = now.difference(lastPractice).inDays;

    if (daysSinceLastPractice == 0) {
      // Same day, no change
      return;
    } else if (daysSinceLastPractice == 1) {
      // Consecutive day, increment streak
      final newStreak = progress.currentStreak + 1;
      await progressRef.update({
        'currentStreak': newStreak,
        'longestStreak': newStreak > progress.longestStreak
            ? newStreak
            : progress.longestStreak,
      });
    } else {
      // Streak broken, reset to 1
      await progressRef.update({'currentStreak': 1});
    }
  }

  Future<void> _checkAchievements() async {
    final user = _ref.read(authProvider).firebaseUser;
    if (user == null) return;

    final progressRef = FirebaseFirestore.instance
        .collection('progress')
        .doc(user.uid);

    final snapshot = await progressRef.get();
    if (!snapshot.exists) return;

    final progress = UserProgress.fromJson(snapshot.data()!);
    final allAchievements = AchievementsData.getAllAchievements();
    final newlyUnlocked = <String>[];

    for (final achievement in allAchievements) {
      if (progress.achievementsUnlocked.contains(achievement.id)) {
        continue; // Already unlocked
      }

      bool shouldUnlock = false;

      switch (achievement.category) {
        case 'lessons':
          shouldUnlock = progress.lessonsCompleted >= achievement.requirement;
          break;
        case 'practice':
          shouldUnlock = progress.practiceAttempts >= achievement.requirement;
          break;
        case 'streak':
          shouldUnlock = progress.longestStreak >= achievement.requirement;
          break;
        case 'accuracy':
          shouldUnlock = progress.accuracy >= achievement.requirement;
          break;
        case 'time':
          shouldUnlock = progress.totalPracticeTime >= achievement.requirement;
          break;
      }

      if (shouldUnlock) {
        newlyUnlocked.add(achievement.id);
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      await progressRef.update({
        'achievementsUnlocked': FieldValue.arrayUnion(newlyUnlocked),
      });
    }
  }

  Future<void> unlockAchievement(String achievementId) async {
    final user = _ref.read(authProvider).firebaseUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('progress')
        .doc(user.uid)
        .update({
          'achievementsUnlocked': FieldValue.arrayUnion([achievementId]),
        });
  }
}

final progressActionsProvider = Provider((ref) => ProgressActions(ref));
