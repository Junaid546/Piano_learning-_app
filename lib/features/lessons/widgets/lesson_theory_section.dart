import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/glass_container.dart';

class LessonTheorySection extends StatefulWidget {
  final String theoryText;
  final List<String> tips;
  final String? illustrationUrl;

  const LessonTheorySection({
    super.key,
    required this.theoryText,
    required this.tips,
    this.illustrationUrl,
  });

  @override
  State<LessonTheorySection> createState() => _LessonTheorySectionState();
}

class _LessonTheorySectionState extends State<LessonTheorySection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (_isExpanded) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return GlassContainer(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.zero,
      opacity: isDark ? 0.12 : 0.08,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          // Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpanded,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.school, color: AppColors.primaryPurple, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Theory & Concepts',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    RotationTransition(
                      turns: _rotationAnimation,
                      child: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryPurple, size: 24),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: AppColors.primaryPurple.withOpacity(0.2)),
                  const SizedBox(height: 12),
                  // Theory text
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark.withOpacity(0.5)
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primaryPurple.withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      widget.theoryText,
                      style: TextStyle(color: textPrimary, height: 1.6),
                    ),
                  ),
                  if (widget.tips.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.warningOrange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lightbulb, color: AppColors.warningOrange, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                'Tips',
                                style: TextStyle(
                                  color: AppColors.warningOrange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...widget.tips.map(
                      (tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryPurple,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                tip,
                                style: TextStyle(color: textSecondary, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
