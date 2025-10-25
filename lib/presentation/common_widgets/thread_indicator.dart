import 'package:flutter/material.dart';
import 'package:mesh_app/presentation/theme/app_theme.dart';

class ThreadIndicator extends StatelessWidget {
  final bool isActive;
  final bool isLast;
  final Color? color;
  final double thickness;

  const ThreadIndicator({
    super.key,
    this.isActive = false,
    this.isLast = false,
    this.color,
    this.thickness = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: thickness,
      height: isLast ? 20 : 40,
      margin: const EdgeInsets.only(left: 17),
      decoration: BoxDecoration(
        color: isActive
            ? (color ?? AppTheme.accentColor)
            : AppTheme.textHint.withAlpha((255 * 0.3).round()),
        borderRadius: BorderRadius.circular(thickness / 2),
      ),
    );
  }
}

class ThreadConnector extends StatelessWidget {
  final List<bool> threadStates;
  final Color? activeColor;
  final Color? inactiveColor;
  final double thickness;

  const ThreadConnector({
    super.key,
    required this.threadStates,
    this.activeColor,
    this.inactiveColor,
    this.thickness = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < threadStates.length; i++)
          ThreadIndicator(
            isActive: threadStates[i],
            isLast: i == threadStates.length - 1,
            color: threadStates[i]
                ? (activeColor ?? AppTheme.accentColor)
                : (inactiveColor ?? AppTheme.textHint),
            thickness: thickness,
          ),
      ],
    );
  }
}

class AnimatedThreadIndicator extends StatefulWidget {
  final bool isActive;
  final bool isLast;
  final Color? color;
  final double thickness;
  final Duration animationDuration;

  const AnimatedThreadIndicator({
    super.key,
    this.isActive = false,
    this.isLast = false,
    this.color,
    this.thickness = 2.0,
    this.animationDuration = AppTheme.shortAnimation,
  });

  @override
  State<AnimatedThreadIndicator> createState() =>
      _AnimatedThreadIndicatorState();
}

class _AnimatedThreadIndicatorState extends State<AnimatedThreadIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _colorAnimation = ColorTween(
      begin: AppTheme.textHint.withAlpha((255 * 0.3).round()),
      end: widget.color ?? AppTheme.accentColor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedThreadIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.thickness,
            height: widget.isLast ? 20 : 40,
            margin: const EdgeInsets.only(left: 17),
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(widget.thickness / 2),
            ),
          ),
        );
      },
    );
  }
}
