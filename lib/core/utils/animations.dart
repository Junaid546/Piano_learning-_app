import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Centralized configuration for app animations to ensure consistency.
class AppAnimations {
  // Standard Durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 800);
  static const Duration verySlow = Duration(milliseconds: 1200);

  // Standard Curves
  static const Curve defaultCurve = Curves.easeOutQuart;
  static const Curve bounceCurve = Curves.elasticOut;

  // Stagger delays
  static const Duration staggerLow = Duration(milliseconds: 50);
  static const Duration staggerMedium = Duration(milliseconds: 100);
}

/// Extensions to easily apply standard app animations
extension AppAnimationExtensions on Widget {
  /// Standard Fade In animation
  Widget fadeInEffect({
    Duration duration = AppAnimations.medium,
    Duration? delay,
    Curve curve = AppAnimations.defaultCurve,
  }) {
    return animate(delay: delay).fadeIn(duration: duration, curve: curve);
  }

  /// Fade in and Slide up (great for lists and cards)
  Widget slideUpFade({
    Duration duration = AppAnimations.medium,
    Duration? delay,
    double beginY = 20.0, // Pixels to slide
    Curve curve = AppAnimations.defaultCurve,
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration, curve: curve)
        .slideY(begin: 0.1, end: 0, duration: duration, curve: curve);
  }

  /// Scale in animation (great for dialogs, badges)
  Widget scaleIn({
    Duration duration = AppAnimations.medium,
    Duration? delay,
    double beginScale = 0.8,
    Curve curve = AppAnimations.defaultCurve,
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration, curve: curve)
        .scale(
          begin: Offset(beginScale, beginScale),
          duration: duration,
          curve: curve,
        );
  }

  /// Pulse effect (for calling attention)
  Widget pulseEffect({
    Duration duration = AppAnimations.medium,
    Duration? delay,
    bool infinite = false,
  }) {
    var anim =
        animate(
          delay: delay,
          onPlay: (controller) {
            if (infinite) controller.repeat(reverse: true);
          },
        ).scaleXY(
          begin: 1.0,
          end: 1.05,
          duration: duration,
          curve: Curves.easeInOut,
        );
    return anim;
  }

  /// Shake effect (for error states)
  Widget shakeEffect({
    Duration duration = AppAnimations.fast,
    Duration? delay,
  }) {
    return animate(
      delay: delay,
    ).shake(duration: duration, hz: 4, curve: Curves.easeInOut);
  }

  /// Shimmer effect (for loading skeletons)
  Widget shimmerEffect({
    Duration duration = AppAnimations.verySlow,
    Color? color,
  }) {
    return animate(
      onPlay: (controller) => controller.repeat(),
    ).shimmer(duration: duration, color: color);
  }
}

/// A wrapper for button press scale animation
class AnimatedPressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double scale;

  const AnimatedPressScale({
    super.key,
    required this.child,
    this.onPressed,
    this.scale = 0.95,
  });

  @override
  State<AnimatedPressScale> createState() => _AnimatedPressScaleState();
}

class _AnimatedPressScaleState extends State<AnimatedPressScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _animation, child: widget.child),
    );
  }
}
