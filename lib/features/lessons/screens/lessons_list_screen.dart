import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/utils/error_handler.dart';
import '../providers/lessons_provider.dart';
import '../widgets/lesson_card.dart';
import 'lesson_detail_screen.dart';
import '../data/seed_lessons.dart';

class LessonsListScreen extends ConsumerWidget {
  const LessonsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsProvider);
    final stats = ref.watch(lessonStatsProvider);
    final categories = ref.watch(lessonCategoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryPurple, AppColors.primaryLight],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.music_note, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Piano Lessons',
              style: AppTextStyles.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: lessonsAsync.when(
        data: (lessons) {
          if (lessons.isEmpty) {
            return NoLessonsEmptyState(
              onRefresh: () async {
                try {
                  await seedLessons();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 12),
                            Text('Lessons loaded!'),
                          ],
                        ),
                        backgroundColor: AppColors.successGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ErrorHandler.getErrorMessage(e)),
                        backgroundColor: AppColors.errorRed,
                      ),
                    );
                  }
                }
              },
            );
          }

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                // Progress Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryPurple, Color(0xFF9D84F5)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Your Progress',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${stats['completed']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ' / ${stats['total']} lessons',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (stats['percentage'] as int) / 100,
                          minHeight: 8,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${stats['percentage']}% Complete',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Lessons by Category
                ...categories.map((category) {
                  final categoryLessons = lessons
                      .where((l) => l.category == category)
                      .toList();

                  return _CategorySection(
                    category: category,
                    lessons: categoryLessons,
                  );
                }),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple)),
        error: (error, stack) => Center(
          child: GlassContainer(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            opacity: 0.1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.errorRed),
                const SizedBox(height: 16),
                Text('Error loading lessons', style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(lessonsProvider),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String category;
  final List lessons;

  const _CategorySection({required this.category, required this.lessons});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    Color getCategoryColor(String cat) {
      switch (cat.toLowerCase()) {
        case 'basics':
          return AppColors.successGreen;
        case 'scales':
          return AppColors.infoBlue;
        case 'chords':
          return AppColors.primaryPurple;
        case 'songs':
          return AppColors.warningOrange;
        case 'techniques':
          return AppColors.secondaryPink;
        default:
          return AppColors.primaryPurple;
      }
    }

    final categoryColor = getCategoryColor(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                category,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${lessons.length}',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        ...lessons.map(
          (lesson) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LessonCard(
              lesson: lesson,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LessonDetailScreen(lesson: lesson),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
