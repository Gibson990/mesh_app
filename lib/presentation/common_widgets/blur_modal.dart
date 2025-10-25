import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mesh_app/presentation/theme/app_theme.dart';

class BlurModal extends StatelessWidget {
  final Widget child;
  final bool isDismissible;
  final Color? backgroundColor;
  final Duration animationDuration;
  final Curve animationCurve;

  const BlurModal({
    super.key,
    required this.child,
    this.isDismissible = true,
    this.backgroundColor,
    this.animationDuration = AppTheme.mediumAnimation,
    this.animationCurve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop with blur effect
          Positioned.fill(
            child: GestureDetector(
              onTap: isDismissible ? () => Navigator.pop(context) : null,
              child: Container(
                color: backgroundColor ??
                    Colors.black.withAlpha((255 * 0.4).round()),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
          // Modal content
          Center(
            child: AnimatedSlide(
              duration: animationDuration,
              curve: animationCurve,
              offset: const Offset(0, 0.1),
              child: AnimatedOpacity(
                duration: animationDuration,
                curve: animationCurve,
                opacity: 1.0,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BlurModalRoute<T> extends PageRoute<T> {
  final Widget child;
  final bool isDismissible;
  final Color? backgroundColor;
  final Duration animationDuration;
  final Curve animationCurve;

  BlurModalRoute({
    required this.child,
    this.isDismissible = true,
    this.backgroundColor,
    this.animationDuration = AppTheme.mediumAnimation,
    this.animationCurve = Curves.easeOutCubic,
  });

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  String? get barrierLabel => null;

  @override
  bool get barrierDismissible => isDismissible;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return BlurModal(
      isDismissible: isDismissible,
      backgroundColor: backgroundColor,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      child: child,
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => animationDuration;
}

class FullScreenBlurModal extends StatelessWidget {
  final Widget child;
  final bool isDismissible;
  final Color? backgroundColor;
  final Duration animationDuration;
  final Curve animationCurve;

  const FullScreenBlurModal({
    super.key,
    required this.child,
    this.isDismissible = true,
    this.backgroundColor,
    this.animationDuration = AppTheme.mediumAnimation,
    this.animationCurve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop with blur effect
          Positioned.fill(
            child: GestureDetector(
              onTap: isDismissible ? () => Navigator.pop(context) : null,
              child: Container(
                color: backgroundColor ??
                    Colors.black.withAlpha((255 * 0.5).round()),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
          // Modal content
          Positioned.fill(
            child: AnimatedSlide(
              duration: animationDuration,
              curve: animationCurve,
              offset: const Offset(0, 0.05),
              child: AnimatedOpacity(
                duration: animationDuration,
                curve: animationCurve,
                opacity: 1.0,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper functions for showing blur modals
class BlurModalHelper {
  static Future<T?> showBlurModal<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    Color? backgroundColor,
    Duration animationDuration = AppTheme.mediumAnimation,
    Curve animationCurve = Curves.easeOutCubic,
  }) {
    return Navigator.push<T>(
      context,
      BlurModalRoute<T>(
        child: child,
        isDismissible: isDismissible,
        backgroundColor: backgroundColor,
        animationDuration: animationDuration,
        animationCurve: animationCurve,
      ),
    );
  }

  static Future<T?> showFullScreenBlurModal<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    Color? backgroundColor,
    Duration animationDuration = AppTheme.mediumAnimation,
    Curve animationCurve = Curves.easeOutCubic,
  }) {
    return Navigator.push<T>(
      context,
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullScreenBlurModal(
            isDismissible: isDismissible,
            backgroundColor: backgroundColor,
            animationDuration: animationDuration,
            animationCurve: animationCurve,
            child: child,
          );
        },
        transitionDuration: animationDuration,
        reverseTransitionDuration: animationDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}
