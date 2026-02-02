import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../progress/providers/progress_provider.dart';
import '../models/lesson.dart';
import '../../../database/sync_service.dart';
import '../../../core/utils/error_handler.dart';

// Provider to fetch all lessons with user-specific completion status
final lessonsProvider = StreamProvider.autoDispose<List<Lesson>>((ref) async* {
  final syncService = SyncService();

  // Get user's completed lesson IDs from progress
  final progress = ref.watch(userProgressProvider);
  final completedLessonIds = progress.maybeWhen(
    data: (p) => p.completedLessonIds,
    orElse: () => <String>[],
  );

  try {
    // 1. Load from cache first (instant UI)
    final cachedLessons = await syncService.loadLessonsFromCache();
    if (cachedLessons.isNotEmpty) {
      // Merge cached lessons with user's completion status
      final lessonsWithStatus = cachedLessons.map((lesson) {
        final isCompleted = completedLessonIds.contains(lesson.id);
        return lesson.copyWith(isCompleted: isCompleted);
      }).toList();
      yield lessonsWithStatus;
    }

    // 2. Stream from Firebase and update cache in background
    await for (final snapshot
        in FirebaseFirestore.instance
            .collection('lessons')
            .orderBy('order')
            .snapshots()) {
      final lessons = snapshot.docs.map((doc) {
        return Lesson.fromJson({...doc.data(), 'id': doc.id});
      }).toList();

      // Update cache silently in background
      for (final lesson in lessons) {
        syncService.updateLessonInCache(lesson);
      }

      // Merge with user's completion status
      final lessonsWithStatus = lessons.map((lesson) {
        final isCompleted = completedLessonIds.contains(lesson.id);
        return lesson.copyWith(isCompleted: isCompleted);
      }).toList();

      yield lessonsWithStatus;
    }
  } catch (e) {
    // Log error and rethrow with user-friendly message
    print('Error loading lessons: $e');
    throw Exception(ErrorHandler.getErrorMessage(e));
  }
});

// Provider to filter lessons by category
final lessonsByCategoryProvider =
    Provider.family<AsyncValue<List<Lesson>>, String>((ref, category) {
      final lessonsAsync = ref.watch(lessonsProvider);
      return lessonsAsync.whenData((lessons) {
        return lessons.where((lesson) => lesson.category == category).toList();
      });
    });

// Provider for lesson categories
final lessonCategoriesProvider = Provider<List<String>>((ref) {
  final lessonsAsync = ref.watch(lessonsProvider);
  return lessonsAsync.when(
    data: (lessons) {
      final categories = lessons.map((l) => l.category).toSet().toList();
      // Sort categories by the order of first lesson in each category
      categories.sort((a, b) {
        final aOrder = lessons.firstWhere((l) => l.category == a).order;
        final bOrder = lessons.firstWhere((l) => l.category == b).order;
        return aOrder.compareTo(bOrder);
      });
      return categories;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider for completion statistics
final lessonStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final lessonsAsync = ref.watch(lessonsProvider);
  return lessonsAsync.when(
    data: (lessons) {
      final total = lessons.length;
      final completed = lessons.where((l) => l.isCompleted).length;
      final percentage = total > 0 ? (completed / total * 100).round() : 0;
      return {
        'total': total,
        'completed': completed,
        'percentage': percentage,
        'inProgress': total - completed,
      };
    },
    loading: () => {
      'total': 0,
      'completed': 0,
      'percentage': 0,
      'inProgress': 0,
    },
    error: (_, __) => {
      'total': 0,
      'completed': 0,
      'percentage': 0,
      'inProgress': 0,
    },
  );
});

// Provider to mark lesson as completed
final lessonActionsProvider = Provider<LessonActions>((ref) {
  return LessonActions(ref);
});

class LessonActions {
  final Ref _ref;

  LessonActions(this._ref);

  Future<void> markAsCompleted(String lessonId) async {
    try {
      await ErrorHandler.retry(
        operation: () async {
          final user = _ref.read(authProvider).firebaseUser;
          if (user == null) throw Exception('User not authenticated');

          // Update user progress with lesson completion (per-user, not global)
          final progressActions = _ref.read(progressActionsProvider);
          await progressActions.markLessonCompleted(lessonId);
        },
        maxAttempts: 3,
      );
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<void> unlockLesson(String lessonId) async {
    try {
      // Unlock is global (admin action), not per-user
      await FirebaseFirestore.instance
          .collection('lessons')
          .doc(lessonId)
          .update({'isLocked': false});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetProgress(String lessonId) async {
    try {
      // Reset is per-user, not global
      final progressActions = _ref.read(progressActionsProvider);
      await progressActions.resetLessonProgress(lessonId);
    } catch (e) {
      rethrow;
    }
  }
}
