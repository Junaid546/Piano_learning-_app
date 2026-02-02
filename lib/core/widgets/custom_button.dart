import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

enum CustomButtonVariant { primary, secondary, text }

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final CustomButtonVariant variant;
  final Widget? icon;
  final double? width;
  final double height;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.variant = CustomButtonVariant.primary,
    this.icon,
    this.width,
    this.height = 56.0,
    this.borderRadius = 16.0,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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

  void _onTapDown(TapDownDetails details) {
    if (!widget.isLoading && !widget.isDisabled) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isLoading && !widget.isDisabled) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (!widget.isLoading && !widget.isDisabled) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled =
        !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: _getDecoration(isEnabled),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTapDown: isEnabled ? _onTapDown : null,
            onTapUp: isEnabled ? _onTapUp : null,
            onTapCancel: isEnabled ? _onTapCancel : null,
            onTap: isEnabled ? widget.onPressed : null,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Center(
              child:
                  widget.isLoading ? _buildLoader() : _buildContent(isEnabled),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getDecoration(bool isEnabled) {
    if (widget.variant == CustomButtonVariant.primary) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: isEnabled
            ? const LinearGradient(
                colors: [AppColors.primaryPurple, AppColors.secondaryPink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isEnabled
            ? null
            : AppColors.textTertiary.withAlpha(100), // Disabled color
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      );
    } else if (widget.variant == CustomButtonVariant.secondary) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: isEnabled ? AppColors.primaryPurple : AppColors.textTertiary,
          width: 2,
        ),
        color: Colors.transparent,
      );
    } else {
      // Text variant
      return BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: Colors.transparent,
      );
    }
  }

  Widget _buildContent(bool isEnabled) {
    final Color textColor = _getTextColor(isEnabled);
    final TextStyle style = AppTextStyles.titleSmall.copyWith(color: textColor);

    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconTheme(
            data: IconThemeData(color: textColor, size: 20),
            child: widget.icon!,
          ),
          const SizedBox(width: 8),
          Text(widget.text, style: style),
        ],
      );
    }

    return Text(widget.text, style: style);
  }

  Widget _buildLoader() {
    return SizedBox(
      height: 24,
      width: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: _getTextColor(true),
      ),
    );
  }

  Color _getTextColor(bool isEnabled) {
    if (!isEnabled) return Colors.white; // Or tertiary for disabled

    switch (widget.variant) {
      case CustomButtonVariant.primary:
        return Colors.white;
      case CustomButtonVariant.secondary:
        return AppColors.primaryPurple;
      case CustomButtonVariant.text:
        return AppColors.primaryPurple;
    }
  }
}
