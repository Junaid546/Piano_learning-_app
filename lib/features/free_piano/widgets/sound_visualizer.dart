import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/piano_controller_provider.dart';

/// Visualizer type options
enum VisualizerType {
  wave,
  bars,
}

/// Sound visualizer widget that displays audio reactivity.
/// Supports multiple visualization types with smooth animations.
class SoundVisualizer extends ConsumerStatefulWidget {
  final double height;
  final bool enabled;

  const SoundVisualizer({
    super.key,
    this.height = 80,
    this.enabled = true,
  });

  @override
  ConsumerState<SoundVisualizer> createState() => _SoundVisualizerState();
}

class _SoundVisualizerState extends ConsumerState<SoundVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  VisualizerType _currentType = VisualizerType.wave;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeKeysCount = ref.watch(activeKeysCountProvider);

    // Animate based on active keys
    if (activeKeysCount > 0) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    if (!widget.enabled) {
      return const SizedBox.shrink();
    }

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.purple.withOpacity(0.1),
          ],
        ),
      ),
      child: Row(
        children: [
          // Toggle visualizer type
          PopupMenuButton<VisualizerType>(
            icon: const Icon(Icons.graphic_eq, color: Colors.white54, size: 20),
            onSelected: (type) => setState(() => _currentType = type),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: VisualizerType.wave,
                child: Text('Wave'),
              ),
              const PopupMenuItem(
                value: VisualizerType.bars,
                child: Text('Bars'),
              ),
            ],
          ),
          // Visualizer
          Expanded(
            child: _currentType == VisualizerType.wave
                ? _WaveVisualizer(animation: _animationController)
                : _BarsVisualizer(animation: _animationController),
          ),
        ],
      ),
    );
  }
}

/// Wave form visualizer using CustomPainter.
class _WaveVisualizer extends StatelessWidget {
  final Animation<double> animation;

  const _WaveVisualizer({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _WavePainter(animation.value),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double intensity;

  _WavePainter(this.intensity);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xFF7C4DFF).withOpacity(0.8),
          const Color(0xFFFF4081).withOpacity(0.8),
          const Color(0xFFFFD700).withOpacity(0.6),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = Path();
    final baseLine = size.height / 2;
    final amplitude = size.height * 0.3 * intensity;

    path.moveTo(0, baseLine);

    for (double x = 0; x <= size.width; x += 2) {
      final y = baseLine +
          amplitude *
              (0.5 * (1 + (x / size.width) * 4 + intensity * 2)) *
              (0.5 + 0.5 * intensity) *
              (0.5 + 0.5 * (1 - (x / size.width))) *
              0.8; // Dampen edges
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // Second wave (subtle)
    if (intensity > 0.3) {
      final paint2 = Paint()
        ..color = const Color(0xFFFF4081).withOpacity(0.3 * intensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      final path2 = Path();
      path2.moveTo(0, baseLine + 10);

      for (double x = 0; x <= size.width; x += 3) {
        final y = baseLine +
            10 +
            amplitude *
                0.7 *
                (0.5 + 0.5 * intensity) *
                (0.5 + 0.5 * (1 - (x / size.width))) *
                0.6;
        path2.lineTo(x, y);
      }

      canvas.drawPath(path2, paint2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Frequency bars visualizer.
class _BarsVisualizer extends StatelessWidget {
  final Animation<double> animation;

  const _BarsVisualizer({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _BarsPainter(animation.value),
        );
      },
    );
  }
}

class _BarsPainter extends CustomPainter {
  final double intensity;

  _BarsPainter(this.intensity);

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 20;
    final barWidth = size.width / barCount - 4;
    final maxBarHeight = size.height * 0.8;

    for (int i = 0; i < barCount; i++) {
      // Calculate bar height based on position and intensity
      final positionFactor = 1 - (i / barCount);
      final randomFactor = 0.5 + (i % 3) * 0.2;
      final barHeight = maxBarHeight * intensity * positionFactor * randomFactor;

      if (barHeight < 2) continue;

      // Gradient colors based on position
      final colors = [
        const Color(0xFF7C4DFF),
        const Color(0xFFFF4081),
        const Color(0xFFFFD700),
      ];
      final colorIndex = (i / barCount * (colors.length - 1)).floor();
      final color = colors[colorIndex].withOpacity(0.8 + 0.2 * intensity);

      final paint = Paint()..color = color;

      final x = i * (barWidth + 4) + 2;
      final y = size.height - barHeight;

      // Draw bar with rounded top
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
