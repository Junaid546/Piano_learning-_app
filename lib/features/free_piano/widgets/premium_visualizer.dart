import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/piano_controller_provider.dart';

/// Visualizer type options
enum VisualizerType {
  spectrum,
  circularWave,
  bars,
}

/// Premium sound visualizer with stunning glow effects and multiple visualization types.
class PremiumVisualizer extends ConsumerStatefulWidget {
  final double height;
  final bool enabled;
  final VisualizerType type;

  const PremiumVisualizer({
    super.key,
    this.height = 100,
    this.enabled = true,
    this.type = VisualizerType.spectrum,
  });

  @override
  ConsumerState<PremiumVisualizer> createState() => _PremiumVisualizerState();
}

class _PremiumVisualizerState extends ConsumerState<PremiumVisualizer> {
  VisualizerType _currentType = VisualizerType.spectrum;

  @override
  Widget build(BuildContext context) {
    final activeKeysCount = ref.watch(activeKeysCountProvider);
    final pianoState = ref.watch(pianoControllerProvider);

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
            const Color(0xFF6B4CE6).withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          // Toggle visualizer type
          _buildTypeSelector(),
          
          // Visualizer
          Expanded(
            child: RepaintBoundary(
              child: _buildVisualizer(activeKeysCount, pianoState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return PopupMenuButton<VisualizerType>(
      icon: Icon(
        Icons.graphic_eq,
        color: Colors.white.withOpacity(0.5),
        size: 20,
      ),
      onSelected: (type) => setState(() => _currentType = type),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: VisualizerType.spectrum,
          child: Text('Spectrum', style: TextStyle(color: Colors.white)),
        ),
        const PopupMenuItem(
          value: VisualizerType.circularWave,
          child: Text('Circular', style: TextStyle(color: Colors.white)),
        ),
        const PopupMenuItem(
          value: VisualizerType.bars,
          child: Text('Bars', style: TextStyle(color: Colors.white)),
        ),
      ],
      color: Colors.black87,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildVisualizer(int activeKeysCount, PianoControllerState state) {
    switch (_currentType) {
      case VisualizerType.spectrum:
        return _SpectrumVisualizer(
          activeKeys: activeKeysCount,
          intensity: activeKeysCount > 0 ? 1.0 : 0.0,
        );
      case VisualizerType.circularWave:
        return _CircularWaveVisualizer(
          activeKeys: activeKeysCount,
          intensity: activeKeysCount > 0 ? 1.0 : 0.0,
        );
      case VisualizerType.bars:
        return _PremiumBarsVisualizer(
          activeKeys: activeKeysCount,
          intensity: activeKeysCount > 0 ? 1.0 : 0.0,
        );
    }
  }
}

/// Spectrum visualizer with glow effects.
class _SpectrumVisualizer extends StatefulWidget {
  final int activeKeys;
  final double intensity;

  const _SpectrumVisualizer({
    required this.activeKeys,
    required this.intensity,
  });

  @override
  State<_SpectrumVisualizer> createState() => _SpectrumVisualizerState();
}

class _SpectrumVisualizerState extends State<_SpectrumVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<double> _barHeights;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _barHeights = List.generate(32, (index) => 0);
  }

  @override
  void didUpdateWidget(_SpectrumVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateBarHeights();
  }

  void _updateBarHeights() {
    if (widget.activeKeys > 0) {
      for (int i = 0; i < _barHeights.length; i++) {
        final randomFactor = 0.3 + (i % 5) * 0.15;
        final positionFactor = 1 - (i / _barHeights.length);
        _barHeights[i] = positionFactor * randomFactor * widget.intensity;
      }
      _controller.forward(from: 0);
    } else {
      _controller.reverse();
    }
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
          size: Size.infinite,
          painter: _SpectrumPainter(
            barHeights: _barHeights,
            intensity: _controller.value,
          ),
        );
      },
    );
  }
}

class _SpectrumPainter extends CustomPainter {
  final List<double> barHeights;
  final double intensity;

  _SpectrumPainter({
    required this.barHeights,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = barHeights.length;
    final barWidth = size.width / barCount - 2;
    final maxBarHeight = size.height * 0.9;

    // Glow effect
    if (intensity > 0.1) {
      final glowPaint = Paint()
        ..color = const Color(0xFF7C4DFF).withOpacity(0.1 * intensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        glowPaint,
      );
    }

    for (int i = 0; i < barCount; i++) {
      final barHeight = maxBarHeight * barHeights[i] * intensity;
      if (barHeight < 2) continue;

      // Gradient colors based on position
      final colors = [
        const Color(0xFF6B4CE6), // Purple
        const Color(0xFF9D50FF), // Light purple
        const Color(0xFFFF4081), // Pink
        const Color(0xFFFF6B9D), // Light pink
        const Color(0xFFFFD700), // Gold
      ];
      
      final colorIndex = (i / barCount * (colors.length - 1)).floor();
      final t = (i / barCount * (colors.length - 1)) - colorIndex;
      final color = Color.lerp(colors[colorIndex], 
          colorIndex < colors.length - 1 ? colors[colorIndex + 1] : colors[colorIndex], t)!;

      final paint = Paint()
        ..color = color.withOpacity(0.8 + 0.2 * intensity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 * intensity);

      final x = i * (barWidth + 2) + 1;
      final y = size.height - barHeight;

      // Draw bar with rounded top
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Circular wave visualizer.
class _CircularWaveVisualizer extends StatefulWidget {
  final int activeKeys;
  final double intensity;

  const _CircularWaveVisualizer({
    required this.activeKeys,
    required this.intensity,
  });

  @override
  State<_CircularWaveVisualizer> createState() => _CircularWaveVisualizerState();
}

class _CircularWaveVisualizerState extends State<_CircularWaveVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(_CircularWaveVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeKeys > 0) {
      _controller.forward(from: 0);
    } else {
      _controller.reverse();
    }
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
          size: Size.infinite,
          painter: _CircularWavePainter(intensity: _controller.value),
        );
      },
    );
  }
}

class _CircularWavePainter extends CustomPainter {
  final double intensity;

  _CircularWavePainter({required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.height * 0.4;

    // Outer glow
    if (intensity > 0.1) {
      final glowPaint = Paint()
        ..color = const Color(0xFF7C4DFF).withOpacity(0.15 * intensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

      canvas.drawCircle(center, maxRadius * 1.5, glowPaint);
    }

    // Draw concentric circles
    for (int i = 0; i < 3; i++) {
      final baseRadius = maxRadius * (0.3 + i * 0.2);
      final pulseRadius = baseRadius * (1 + intensity * 0.1);
      
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + intensity * 2
        ..color = [
          const Color(0xFF6B4CE6),
          const Color(0xFFFF4081),
          const Color(0xFFFFD700),
        ][i].withOpacity(0.5 + 0.5 * intensity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * intensity);

      canvas.drawCircle(center, pulseRadius, paint);
    }

    // Center glow
    final centerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF6B4CE6).withOpacity(0.6 * intensity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius * 0.3));

    canvas.drawCircle(center, maxRadius * 0.3, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Premium bars visualizer with enhanced visuals.
class _PremiumBarsVisualizer extends StatefulWidget {
  final int activeKeys;
  final double intensity;

  const _PremiumBarsVisualizer({
    required this.activeKeys,
    required this.intensity,
  });

  @override
  State<_PremiumBarsVisualizer> createState() => _PremiumBarsVisualizerState();
}

class _PremiumBarsVisualizerState extends State<_PremiumBarsVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<double> _barHeights;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _barHeights = List.generate(20, (index) => 0);
  }

  @override
  void didUpdateWidget(_PremiumBarsVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateBarHeights();
  }

  void _updateBarHeights() {
    if (widget.activeKeys > 0) {
      for (int i = 0; i < _barHeights.length; i++) {
        final randomFactor = 0.5 + (i % 3) * 0.2;
        final positionFactor = 1 - (i / _barHeights.length);
        _barHeights[i] = positionFactor * randomFactor * widget.intensity;
      }
      _controller.forward(from: 0);
    } else {
      _controller.reverse();
    }
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
          size: Size.infinite,
          painter: _PremiumBarsPainter(
            barHeights: _barHeights,
            intensity: _controller.value,
          ),
        );
      },
    );
  }
}

class _PremiumBarsPainter extends CustomPainter {
  final List<double> barHeights;
  final double intensity;

  _PremiumBarsPainter({
    required this.barHeights,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = barHeights.length;
    final barWidth = size.width / barCount - 4;
    final maxBarHeight = size.height * 0.8;

    // Reflection effect
    if (intensity > 0.1) {
      final reflectionPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF7C4DFF).withOpacity(0.05 * intensity),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2));

      canvas.drawRect(
        Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2),
        reflectionPaint,
      );
    }

    for (int i = 0; i < barCount; i++) {
      final barHeight = maxBarHeight * barHeights[i] * intensity;
      if (barHeight < 2) continue;

      // Gradient colors
      final colors = [
        const Color(0xFF7C4DFF),
        const Color(0xFFFF4081),
        const Color(0xFFFFD700),
      ];
      
      final colorIndex = (i / barCount * (colors.length - 1)).floor();
      final color = colors[colorIndex].withOpacity(0.8 + 0.2 * intensity);

      // Glow
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3 * intensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      final x = i * (barWidth + 4) + 2;
      final y = size.height - barHeight;

      canvas.drawRect(
        Rect.fromLTWH(x - 2, y - 2, barWidth + 4, barHeight + 4),
        glowPaint,
      );

      // Main bar
      final paint = Paint()..color = color;
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
