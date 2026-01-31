import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/piano_key.dart';

class WhiteKey extends StatefulWidget {
  final PianoKey pianoKey;
  final VoidCallback onPressed;
  final VoidCallback onReleased;
  final bool showLabel;
  final double width;
  final double height;

  const WhiteKey({
    super.key,
    required this.pianoKey,
    required this.onPressed,
    required this.onReleased,
    this.showLabel = true,
    this.width = 60,
    this.height = 200,
  });

  @override
  State<WhiteKey> createState() => _WhiteKeyState();
}

class _WhiteKeyState extends State<WhiteKey>
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
      return Colors.grey.shade300;
    }
    if (widget.pianoKey.isHighlighted &&
        widget.pianoKey.highlightColor != null) {
      return widget.pianoKey.highlightColor!.withOpacity(0.3);
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
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
              width: widget.width,
              height: widget.height,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: _getKeyColor(),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                border: Border.all(
                  color: widget.pianoKey.isHighlighted
                      ? (widget.pianoKey.highlightColor ?? Colors.blue)
                      : Colors.black,
                  width: widget.pianoKey.isHighlighted ? 3 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                  if (widget.pianoKey.isHighlighted)
                    BoxShadow(
                      color: (widget.pianoKey.highlightColor ?? Colors.blue)
                          .withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_getKeyColor(), _getKeyColor().withOpacity(0.9)],
                ),
              ),
              child: widget.showLabel
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          widget.pianoKey.note.displayName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.6),
                            fontFamily: 'Inter',
                          ),
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
