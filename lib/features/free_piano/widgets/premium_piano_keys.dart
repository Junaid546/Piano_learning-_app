import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/piano_key.dart';
import '../models/piano_settings.dart';
import '../providers/piano_controller_provider.dart';

/// Premium photorealistic white key widget with ivory texture, shadows, and glow effects.
class PremiumWhiteKey extends ConsumerStatefulWidget {
  final PianoKey pianoKey;
  final bool isPressed;
  final double width;
  final double height;
  final bool showLabel;
  final Offset? touchPosition;
  final VoidCallback onTap;
  final VoidCallback onRelease;

  const PremiumWhiteKey({
    super.key,
    required this.pianoKey,
    required this.isPressed,
    required this.width,
    required this.height,
    required this.showLabel,
    this.touchPosition,
    required this.onTap,
    required this.onRelease,
  });

  @override
  ConsumerState<PremiumWhiteKey> createState() => _PremiumWhiteKeyState();
}

class _PremiumWhiteKeyState extends ConsumerState<PremiumWhiteKey>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _brightnessAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _brightnessAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(PremiumWhiteKey oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPressed != oldWidget.isPressed) {
      if (widget.isPressed) {
        _animationController.forward();
        _triggerHapticFeedback();
      } else {
        _animationController.reverse();
      }
    }
  }

  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const highlightColor = Color(0xFF7C4DFF);
    
    return GestureDetector(
      onTapDown: (_) => widget.onTap(),
      onTapUp: (_) => widget.onRelease(),
      onTapCancel: widget.onRelease,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimation,
          _glowAnimation,
          _brightnessAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: CustomPaint(
              size: Size(widget.width, widget.height),
              painter: _WhiteKeyPainter(
                isPressed: widget.isPressed,
                glowIntensity: _glowAnimation.value,
                brightness: _brightnessAnimation.value,
                highlightColor: highlightColor,
                touchPosition: widget.touchPosition,
                width: widget.width,
                height: widget.height,
              ),
              child: widget.showLabel
                  ? _buildNoteLabel()
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoteLabel() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        widget.pianoKey.note,
        style: TextStyle(
          color: widget.isPressed
              ? const Color(0xFF7C4DFF)
              : Colors.black.withOpacity(0.4),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
          shadows: [
            Shadow(
              color: Colors.white.withOpacity(0.8),
              offset: const Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _WhiteKeyPainter extends CustomPainter {
  final bool isPressed;
  final double glowIntensity;
  final double brightness;
  final Color highlightColor;
  final Offset? touchPosition;
  final double width;
  final double height;

  _WhiteKeyPainter({
    required this.isPressed,
    required this.glowIntensity,
    required this.brightness,
    required this.highlightColor,
    this.touchPosition,
    required this.width,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Apply brightness modifier
    final brightnessMatrix = ColorFilter.matrix([
      brightness, 0, 0, 0, 0,
      0, brightness, 0, 0, 0,
      0, 0, brightness, 0, 0,
      0, 0, 0, 1, 0,
    ]);

    // Draw key background with gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isPressed
          ? [
              Color.lerp(const Color(0xFFFFFFFF), highlightColor, 0.15)!,
              Color.lerp(const Color(0xFFF5F5F5), highlightColor, 0.1)!,
            ]
          : [
              const Color(0xFFFFFFFF),
              const Color(0xFFFAFAFA),
              const Color(0xFFF5F5F5),
            ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..colorFilter = brightnessMatrix;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      paint,
    );

    // Draw subtle ivory texture (noise pattern)
    if (!isPressed) {
      _drawIvoryTexture(canvas, size);
    }

    // Draw edge definitions
    _drawEdgeDefinitions(canvas, size);

    // Draw inner shadow for depth
    _drawInnerShadows(canvas, size);

    // Draw pressed glow effect
    if (isPressed && glowIntensity > 0) {
      _drawGlowEffect(canvas, size);
    }

    // Draw ripple effect from touch point
    if (isPressed && touchPosition != null) {
      _drawRippleEffect(canvas, size);
    }
  }

  void _drawIvoryTexture(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw subtle vertical grain lines
    for (double x = 8; x < size.width; x += 12) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  void _drawEdgeDefinitions(Canvas canvas, Size size) {
    // Left edge - subtle highlight
    canvas.drawLine(
      const Offset(0.5, 0),
      Offset(0.5, size.height),
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // Right edge - subtle shadow
    canvas.drawLine(
      Offset(size.width - 0.5, 0),
      Offset(size.width - 0.5, size.height),
      Paint()
        ..color = Colors.black.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  void _drawInnerShadows(Canvas canvas, Size size) {
    // Top inner shadow for recess effect
    canvas.drawLine(
      const Offset(0, 1),
      Offset(size.width, 1),
      Paint()
        ..color = Colors.black.withOpacity(0.03)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  void _drawGlowEffect(Canvas canvas, Size size) {
    // Outer glow
    final glowPaint = Paint()
      ..color = highlightColor.withOpacity(0.4 * glowIntensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-10, -10, size.width + 20, size.height + 20),
        const Radius.circular(6),
      ),
      glowPaint,
    );

    // Inner glow
    final innerGlowPaint = Paint()
      ..color = highlightColor.withOpacity(0.2 * glowIntensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
        const Radius.circular(4),
      ),
      innerGlowPaint,
    );
  }

  void _drawRippleEffect(Canvas canvas, Size size) {
    if (touchPosition == null) return;

    final ripplePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          highlightColor.withOpacity(0.3 * (1 - glowIntensity)),
          highlightColor.withOpacity(0.1 * (1 - glowIntensity)),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: touchPosition!,
          radius: size.width * 0.8,
        ),
      );

    canvas.drawCircle(
      touchPosition!,
      size.width * 0.8,
      ripplePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Premium photorealistic black key widget with ebony finish and reflections.
class PremiumBlackKey extends ConsumerStatefulWidget {
  final PianoKey pianoKey;
  final bool isPressed;
  final double width;
  final double height;
  final bool showLabel;
  final Offset? touchPosition;
  final VoidCallback onTap;
  final VoidCallback onRelease;

  const PremiumBlackKey({
    super.key,
    required this.pianoKey,
    required this.isPressed,
    required this.width,
    required this.height,
    required this.showLabel,
    this.touchPosition,
    required this.onTap,
    required this.onRelease,
  });

  @override
  ConsumerState<PremiumBlackKey> createState() => _PremiumBlackKeyState();
}

class _PremiumBlackKeyState extends ConsumerState<PremiumBlackKey>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 70),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(PremiumBlackKey oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPressed != oldWidget.isPressed) {
      if (widget.isPressed) {
        _animationController.forward();
        _triggerHapticFeedback();
      } else {
        _animationController.reverse();
      }
    }
  }

  void _triggerHapticFeedback() {
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const highlightColor = Color(0xFF7C4DFF);
    
    return GestureDetector(
      onTapDown: (_) => widget.onTap(),
      onTapUp: (_) => widget.onRelease(),
      onTapCancel: widget.onRelease,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimation,
          _glowAnimation,
          _rotateAnimation,
        ]),
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..scale(_scaleAnimation.value)
              ..rotateZ(_rotateAnimation.value * 0.01),
            alignment: Alignment.center,
            child: CustomPaint(
              size: Size(widget.width, widget.height),
              painter: _BlackKeyPainter(
                isPressed: widget.isPressed,
                glowIntensity: _glowAnimation.value,
                highlightColor: highlightColor,
                width: widget.width,
                height: widget.height,
              ),
              child: widget.showLabel
                  ? _buildNoteLabel()
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoteLabel() {
    return Center(
      child: Text(
        widget.pianoKey.note,
        style: TextStyle(
          color: widget.isPressed
              ? const Color(0xFFFFD700)
              : Colors.white.withOpacity(0.6),
          fontSize: 10,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.9),
              offset: const Offset(0, 1),
              blurRadius: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class _BlackKeyPainter extends CustomPainter {
  final bool isPressed;
  final double glowIntensity;
  final Color highlightColor;
  final double width;
  final double height;

  _BlackKeyPainter({
    required this.isPressed,
    required this.glowIntensity,
    required this.highlightColor,
    required this.width,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Draw shadow underneath (creates hovering effect)
    _drawDropShadow(canvas, size);

    // Draw key background with ebony gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isPressed
          ? [
              Color.lerp(const Color(0xFF1A1A1A), highlightColor, 0.2)!,
              const Color(0xFF1A1A1A),
            ]
          : [
              const Color(0xFF2A2A2A),
              const Color(0xFF0A0A0A),
            ],
    );

    final paint = Paint()..shader = gradient.createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(4),
      ),
      paint,
    );

    // Draw polished ebony reflection
    _drawReflection(canvas, size);

    // Draw top highlight (shiny surface)
    _drawTopHighlight(canvas, size);

    // Draw edge bevels
    _drawEdgeBevels(canvas, size);

    // Draw pressed gold glow effect
    if (isPressed && glowIntensity > 0) {
      _drawGoldGlow(canvas, size);
    }
  }

  void _drawDropShadow(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, size.height * 0.35, size.width + 4, 8),
        const Radius.circular(4),
      ),
      shadowPaint,
    );
  }

  void _drawReflection(Canvas canvas, Size size) {
    final reflectionPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.2, 0.25, 1.0],
        colors: [
          Colors.white.withOpacity(0.15),
          Colors.white.withOpacity(0.05),
          Colors.transparent,
          Colors.black.withOpacity(0.3),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.25),
        const Radius.circular(4),
      ),
      reflectionPaint,
    );
  }

  void _drawTopHighlight(Canvas canvas, Size size) {
    // Subtle white highlight at the very top
    canvas.drawLine(
      const Offset(0, 0),
      Offset(size.width, 0),
      Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..strokeWidth = 1,
    );
  }

  void _drawEdgeBevels(Canvas canvas, Size size) {
    // Left edge - slightly lighter
    canvas.drawLine(
      const Offset(0.5, 0),
      Offset(0.5, size.height),
      Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // Right edge - slightly darker
    canvas.drawLine(
      Offset(size.width - 0.5, 0),
      Offset(size.width - 0.5, size.height),
      Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // Bottom edge - darker band
    canvas.drawLine(
      Offset(2, size.height - 2),
      Offset(size.width - 2, size.height - 2),
      Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..strokeWidth = 2,
    );
  }

  void _drawGoldGlow(Canvas canvas, Size size) {
    // Outer metallic glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.5 * glowIntensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-8, -8, size.width + 16, size.height + 16),
        const Radius.circular(6),
      ),
      glowPaint,
    );

    // Inner gold tint
    final innerPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.2 * glowIntensity);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
        const Radius.circular(4),
      ),
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Particle burst effect widget for key presses.
class ParticleBurst extends StatefulWidget {
  final Offset position;
  final Color color;
  final VoidCallback onComplete;

  const ParticleBurst({
    super.key,
    required this.position,
    required this.color,
    required this.onComplete,
  });

  @override
  State<ParticleBurst> createState() => _ParticleBurstState();
}

class _ParticleBurstState extends State<ParticleBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete();
        }
      });

    _particles = List.generate(6, (index) {
      final angle = (index / 6) * 2 * 3.14159 + (DateTime.now().millisecond % 100) / 100;
      return Particle(
        angle: angle,
        speed: 50 + (index % 3) * 20,
        size: 4 + (index % 3) * 2,
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(100, 100),
          painter: _ParticleBurstPainter(
            particles: _particles,
            progress: _controller.value,
            color: widget.color,
            position: widget.position,
          ),
        );
      },
    );
  }
}

class Particle {
  final double angle;
  final double speed;
  final double size;

  Particle({
    required this.angle,
    required this.speed,
    required this.size,
  });
}

class _ParticleBurstPainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final Color color;
  final Offset position;

  _ParticleBurstPainter({
    required this.particles,
    required this.progress,
    required this.color,
    required this.position,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final distance = particle.speed * progress;
      final x = position.dx + distance * math.cos(particle.angle);
      final y = position.dy + distance * math.sin(particle.angle) - (progress * 30);
      final opacity = 1 - progress;
      final particleSize = particle.size * (1 - progress * 0.5);

      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        Paint()
          ..color = color.withOpacity(opacity * 0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
