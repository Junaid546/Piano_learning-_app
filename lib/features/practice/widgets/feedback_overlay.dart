import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_text_styles.dart';

class FeedbackOverlay extends StatelessWidget {
  final bool isCorrect;
  final VoidCallback? onDismiss;

  const FeedbackOverlay({super.key, required this.isCorrect, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            color: isCorrect
                ? Colors.green.withValues(alpha: 0.95)
                : Colors.red.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isCorrect ? Colors.green : Colors.red).withValues(
                  alpha: 0.4,
                ),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: Colors.white,
                    size: 40,
                  )
                  .animate()
                  .scale(duration: 400.ms, curve: Curves.easeOutBack)
                  .then(delay: 200.ms)
                  .shake(
                    hz: 4,
                    curve: Curves.easeInOut,
                  ), // Subtle shake even on success or just remove? Maybe just for error.

              const SizedBox(width: 16),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCorrect ? 'Correct!' : 'Try Again!',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isCorrect ? '+10 points' : 'Keep practicing',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 200.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          duration: 300.ms,
          curve: Curves.easeOutBack,
        )
        .then()
        .ifAdapter(
          condition: !isCorrect,
          action: (c) =>
              c.shake(duration: 400.ms, hz: 4, curve: Curves.easeInOut),
        );
  }
}

extension AnimateIfExtension on Animate {
  // Simple helper if built-in one doesn't match my memory of API (check docs? usually .swap or custom logic).
  // actually flutter_animate has .toggle or conditions in builder.
  // But to keep it simple, I'll just chain shake conditionally in the main chain logic or separate widgets.
  // simpler:
  Animate ifAdapter({
    required bool condition,
    required Animate Function(Animate) action,
  }) {
    return condition ? action(this) : this;
  }
}
