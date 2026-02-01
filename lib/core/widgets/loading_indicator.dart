import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/app_colors.dart';

enum LoadingIndicatorType { spinner, fullScreen, musical }

class LoadingIndicator extends StatelessWidget {
  final LoadingIndicatorType type;
  final double? size;
  final Color? color;
  final String? message;

  const LoadingIndicator({
    super.key,
    this.type = LoadingIndicatorType.spinner,
    this.size,
    this.color,
    this.message,
  });

  const LoadingIndicator.spinner({super.key, this.size, this.color})
    : type = LoadingIndicatorType.spinner,
      message = null;

  const LoadingIndicator.fullScreen({super.key, this.message})
    : type = LoadingIndicatorType.fullScreen,
      size = null,
      color = null;

  const LoadingIndicator.musical({super.key, this.size, this.color})
    : type = LoadingIndicatorType.musical,
      message = null;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case LoadingIndicatorType.fullScreen:
        return _buildFullScreen(context);
      case LoadingIndicatorType.musical:
        return _buildMusical(context);
      case LoadingIndicatorType.spinner:
        return _buildSpinner(context);
    }
  }

  Widget _buildSpinner(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size ?? 40,
        height: size ?? 40,
        child: CircularProgressIndicator(
          color: color ?? AppColors.primaryPurple,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildFullScreen(BuildContext context) {
    return Stack(
      children: [
        // Backdrop filter for blur effect
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(color: Colors.black.withValues(alpha: 0.3)),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMusical(context),
              if (message != null) ...[
                const SizedBox(height: 24),
                Text(
                  message!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Placeholder for Musical Note Animation
  // In a real app, use Lottie or a complicated CustomPainter
  Widget _buildMusical(BuildContext context) {
    return Container(
      width: size ?? 60,
      height: size ?? 60,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            color: AppColors.primaryPurple,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}
