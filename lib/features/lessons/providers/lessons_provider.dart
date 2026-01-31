import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/lesson.dart';

// Provider to fetch all lessons
final lessonsProvider = StreamProvider.autoDispose<List<Lesson>>((ref) {
  return FirebaseFirestore.instance
      .collection('lessons')
      .orderBy('order')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return Lesson.fromJson({...doc.data(), 'id': doc.id});
        }).toList();
      });
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
      final user = _ref.read(authProvider).firebaseUser;
      if (user == null) return;

      // Update lesson completion status
      await FirebaseFirestore.instance
          .collection('lessons')
          .doc(lessonId)
          .update({'isCompleted': true});

      // Update user progress
      final progressRef = FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid);

      final progressDoc = await progressRef.get();
      if (progressDoc.exists) {
        final data = progressDoc.data()!;
        final lessonsCompleted = List<String>.from(
          data['lessonsCompleted'] ?? [],
        );

        if (!lessonsCompleted.contains(lessonId)) {
          lessonsCompleted.add(lessonId);
          await progressRef.update({'lessonsCompleted': lessonsCompleted});
        }
      }
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  Future<void> unlockLesson(String lessonId) async {
    try {
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
      await FirebaseFirestore.instance
          .collection('lessons')
          .doc(lessonId)
          .update({'isCompleted': false});
    } catch (e) {
      rethrow;
    }
  }
}
