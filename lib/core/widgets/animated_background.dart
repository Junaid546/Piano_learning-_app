import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Shapes configuration
  final List<_Shape> _shapes = List.generate(5, (_) => _Shape());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Base background color
        Container(
          color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        ),

        // Animated shapes
        ..._shapes.map((shape) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;
              final dx = sin(t * 2 * pi * shape.speedX + shape.offsetX) * 50;
              final dy = cos(t * 2 * pi * shape.speedY + shape.offsetY) * 50;

              return Positioned(
                left: shape.initialLeft + dx,
                top: shape.initialTop + dy,
                child: Opacity(
                  opacity: isDark ? 0.1 : 0.05,
                  child: Container(
                    width: shape.size,
                    height: shape.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [shape.color, shape.color.withOpacity(0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),

        // Blur overlay for smoother effect
        Positioned.fill(
          child: BackdropFilter(
            filter: const ColorFilter.mode(
              Colors.transparent,
              BlendMode.src,
            ), // Just a placeholder, we use Container decoration for blur if needed
            // But here we just want the shapes to be soft.
            // Using a simple blur layer on top:
            child: Container(
              color: Colors.transparent, // Let content shine through
            ),
          ),
        ),

        // Content
        widget.child,
      ],
    );
  }
}

class _Shape {
  final double size = 200.0 + Random().nextInt(200);
  final double initialLeft = -100.0 + Random().nextInt(300);
  final double initialTop = -100.0 + Random().nextInt(600);
  final double speedX = 0.5 + Random().nextDouble();
  final double speedY = 0.5 + Random().nextDouble();
  final double offsetX = Random().nextDouble() * 2 * pi;
  final double offsetY = Random().nextDouble() * 2 * pi;
  final Color color = [
    AppColors.primaryPurple,
    AppColors.secondaryPink,
    AppColors.accentGold,
  ][Random().nextInt(3)];
}
