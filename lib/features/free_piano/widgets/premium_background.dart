import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Floating dust particle for ambient effects.
class DriftParticle {
  double x;
  double y;
  double speed;
  double size;
  double opacity;
  double driftOffset;

  DriftParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.driftOffset,
  });
}

/// Premium concert hall style background with ambient lighting and particles.
class PremiumBackground extends StatefulWidget {
  final Widget child;
  final bool showParticles;

  const PremiumBackground({
    super.key,
    required this.child,
    this.showParticles = true,
  });

  @override
  State<PremiumBackground> createState() => _PremiumBackgroundState();
}

class _PremiumBackgroundState extends State<PremiumBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _particleController;
  late List<DriftParticle> _particles;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _particles = List.generate(25, (index) {
      return DriftParticle(
        x: math.Random().nextDouble(),
        y: math.Random().nextDouble(),
        speed: 0.05 + math.Random().nextDouble() * 0.1,
        size: 1 + math.Random().nextDouble() * 2,
        opacity: 0.1 + math.Random().nextDouble() * 0.2,
        driftOffset: math.Random().nextDouble() * 2 * 3.14159,
      );
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [
                  const Color(0xFF0D0A14),
                  const Color(0xFF1A1425),
                  const Color(0xFF0D0A14),
                ]
              : [
                  const Color(0xFF2C1810),
                  const Color(0xFF1A1412),
                ],
        ),
      ),
      child: Stack(
        children: [
          // Ambient lighting layer
          _buildAmbientLighting(context),
          
          // Floating dust particles
          if (widget.showParticles) _buildParticles(),
          
          // Keyboard shadow/reflection
          _buildKeyboardShadow(),
          
          // Main content
          widget.child,
        ],
      ),
    );
  }

  Widget _buildAmbientLighting(BuildContext context) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _AmbientLightingPainter(
            animationValue: _particleController.value,
          ),
        );
      },
    );
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ParticlePainter(
            particles: _particles,
            animationValue: _particleController.value,
          ),
        );
      },
    );
  }

  Widget _buildKeyboardShadow() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 40,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black54,
              Colors.black87,
            ],
          ),
        ),
      ),
    );
  }
}

class _AmbientLightingPainter extends CustomPainter {
  final double animationValue;

  _AmbientLightingPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Spotlight effect behind keyboard area
    final spotlightRect = Rect.fromLTWH(0, 0, size.width, size.height * 0.5);
    final spotlightPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 0.8,
        colors: [
          const Color(0xFF6B4CE6).withOpacity(0.08),
          const Color(0xFF6B4CE6).withOpacity(0.03),
          Colors.transparent,
        ],
      ).createShader(spotlightRect);

    canvas.drawRect(spotlightRect, spotlightPaint);

    // Subtle ambient glow spots
    for (int i = 0; i < 3; i++) {
      final offset = (animationValue + i * 0.33) % 1.0;
      final x = size.width * (0.2 + offset * 0.6);
      final y = size.height * 0.15 + math.sin(offset * 2 * 3.14159) * 20;
      final radius = 150 + math.sin(offset * 2 * 3.14159) * 30;

      final glowPaint = Paint()
        ..shader = RadialGradient(
          center: Alignment(x / size.width - 1, y / size.height * 2 - 1),
          radius: radius / size.width,
          colors: [
            Colors.purple.withOpacity(0.05),
            Colors.pink.withOpacity(0.03),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawCircle(Offset(x, y), radius, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ParticlePainter extends CustomPainter {
  final List<DriftParticle> particles;
  final double animationValue;

  _ParticlePainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      // Calculate particle position with slow drift
      final progress = (animationValue * particle.speed + particle.driftOffset) % 1.0;
      final x = particle.x * size.width + math.sin(progress * 2 * 3.14159) * 20;
      final y = (particle.y - progress * 0.3).clamp(0.0, 1.0) * size.height;
      final opacity = particle.opacity * (0.5 + 0.5 * math.sin(progress * 2 * 3.14159));

      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Shimmer effect that sweeps across the keyboard when idle.
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(period: const Duration(seconds: 3));
    
    _shimmerAnimation = Tween<double>(begin: -0.3, end: 1.3).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(_shimmerAnimation.value - 0.3, 0),
              end: Alignment(_shimmerAnimation.value + 0.3, 0),
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.1),
                Colors.transparent,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Piano keyboard base/frame with wood grain texture.
class PianoKeyboardBase extends StatelessWidget {
  final double width;
  final double height;
  final bool isDarkMode;

  const PianoKeyboardBase({
    super.key,
    required this.width,
    required this.height,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [
                  const Color(0xFF1A1A1A),
                  const Color(0xFF0D0D0D),
                  const Color(0xFF050505),
                ]
              : [
                  const Color(0xFF3D2817),
                  const Color(0xFF2A1A0F),
                  const Color(0xFF1A0F08),
                ],
        ),
      ),
      child: CustomPaint(
        size: Size(width, height),
        painter: _KeyboardBasePainter(isDarkMode: isDarkMode),
      ),
    );
  }
}

class _KeyboardBasePainter extends CustomPainter {
  final bool isDarkMode;

  _KeyboardBasePainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw subtle wood grain texture
    final paint = Paint()..color = Colors.black.withOpacity(0.1);

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Top edge highlight
    canvas.drawLine(
      const Offset(0, 0),
      Offset(size.width, 0),
      Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..strokeWidth = 1,
    );

    // Bottom shadow
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      Paint()
        ..color = Colors.black.withOpacity(0.5)
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dynamic lighting that reacts to key presses.
class DynamicLighting extends StatefulWidget {
  final Widget child;
  final List<String> activeNotes;

  const DynamicLighting({
    super.key,
    required this.child,
    this.activeNotes = const [],
  });

  @override
  State<DynamicLighting> createState() => _DynamicLightingState();
}

class _DynamicLightingState extends State<DynamicLighting>
    with SingleTickerProviderStateMixin {
  late AnimationController _lightingController;
  late Animation<double> _lightingAnimation;

  @override
  void initState() {
    super.initState();
    _lightingController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _lightingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _lightingController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(DynamicLighting oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeNotes.isNotEmpty) {
      _lightingController.forward();
    } else {
      _lightingController.reverse();
    }
  }

  @override
  void dispose() {
    _lightingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _lightingAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _DynamicLightingPainter(
            intensity: _lightingAnimation.value,
            activeNotes: widget.activeNotes,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _DynamicLightingPainter extends CustomPainter {
  final double intensity;
  final List<String> activeNotes;

  _DynamicLightingPainter({
    required this.intensity,
    required this.activeNotes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;

    // Background pulse on key press
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.5,
        colors: [
          Colors.purple.withOpacity(0.05 * intensity),
          Colors.pink.withOpacity(0.03 * intensity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.largest, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
