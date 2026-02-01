import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/piano_key.dart';
import '../../../core/constants/app_colors.dart';

class BlackKey extends StatefulWidget {
  final PianoKey pianoKey;
  final VoidCallback onPressed;
  final VoidCallback onReleased;
  final bool showLabel;
  final double whiteKeyWidth;
  final double whiteKeyHeight;

  const BlackKey({
    super.key,
    required this.pianoKey,
    required this.onPressed,
    required this.onReleased,
    this.showLabel = false,
    this.whiteKeyWidth = 60,
    this.whiteKeyHeight = 200,
  });

  @override
  State<BlackKey> createState() => _BlackKeyState();
}

class _BlackKeyState extends State<BlackKey>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
    widget.onPressed();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onReleased();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onReleased();
  }

  Color _getKeyColor() {
    if (widget.pianoKey.isPressed || _isPressed) {
      return Colors.grey.shade700;
    }
    if (widget.pianoKey.isHighlighted &&
        widget.pianoKey.highlightColor != null) {
      return widget.pianoKey.highlightColor!.withValues(alpha: 0.6);
    }
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.whiteKeyWidth * 0.6;
    final height = widget.whiteKeyHeight * 0.6;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: _getKeyColor(),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
                border: Border.all(
                  color: widget.pianoKey.isHighlighted
                      ? (widget.pianoKey.highlightColor ?? Colors.blue)
                      : Colors.grey.shade800,
                  width: widget.pianoKey.isHighlighted ? 2 : 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                  // Glow effect on press or highlight
                  if (widget.pianoKey.isHighlighted || _isPressed)
                    BoxShadow(
                      color:
                          (widget.pianoKey.highlightColor ??
                                  AppColors.primaryPurple)
                              .withValues(alpha: _isPressed ? 0.8 : 0.6),
                      blurRadius: _isPressed ? 16 : 10,
                      spreadRadius: _isPressed ? 3 : 1,
                    ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _getKeyColor(),
                    _getKeyColor().withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: widget.showLabel
                  ? Center(
                      child: Text(
                        widget.pianoKey.note.displayName,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                          fontFamily: 'Inter',
                        ),
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
