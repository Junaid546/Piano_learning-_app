import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_text_styles.dart';
import '../providers/practice_provider.dart';

class FeedbackOverlay extends StatefulWidget {
  final FeedbackType feedbackType;
  final VoidCallback? onDismiss;

  const FeedbackOverlay({
    super.key,
    required this.feedbackType,
    this.onDismiss,
  });

  @override
  State<FeedbackOverlay> createState() => _FeedbackOverlayState();
}

class _FeedbackOverlayState extends State<FeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    ));

    if (widget.feedbackType != FeedbackType.none) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(FeedbackOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.feedbackType != FeedbackType.none &&
        oldWidget.feedbackType == FeedbackType.none) {
      // Show animation
      _controller.forward(from: 0.0);
    } else if (widget.feedbackType == FeedbackType.none &&
        oldWidget.feedbackType != FeedbackType.none) {
      // Hide animation
      _controller.reverse().then((_) {
        widget.onDismiss?.call();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.feedbackType == FeedbackType.none && !_controller.isAnimating) {
      return const SizedBox.shrink();
    }

    final isCorrect = widget.feedbackType == FeedbackType.correct;
    final isIncorrect = widget.feedbackType == FeedbackType.incorrect;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              decoration: BoxDecoration(
                color: (isCorrect
                        ? Colors.green
                        : isIncorrect
                            ? Colors.red
                            : Colors.grey)
                    .withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isCorrect
                            ? Colors.green
                            : isIncorrect
                                ? Colors.red
                                : Colors.grey)
                        .withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCorrect
                        ? Icons.check_circle
                        : isIncorrect
                            ? Icons.cancel
                            : Icons.help,
                    color: Colors.white,
                    size: 40,
                  ).animate().scale(
                      duration: 400.ms, curve: Curves.easeOutBack),

                  const SizedBox(width: 16),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCorrect
                            ? 'Correct!'
                            : isIncorrect
                                ? 'Try Again!'
                                : '',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isCorrect
                            ? '+10 points'
                            : isIncorrect
                                ? 'Keep practicing'
                                : '',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
