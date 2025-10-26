import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Custom splash screen with mesh network animation
class SplashScreen extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashScreen({
    Key? key,
    required this.onInitializationComplete,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // Complete initialization after animation
    Future.delayed(const Duration(seconds: 3), () {
      widget.onInitializationComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6C63FF), // Purple
              Color(0xFF5B52E8),
              Color(0xFF4834DF), // Dark Purple
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Mesh network icon
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: const MeshNetworkIcon(size: 200),
                      ),
                      const SizedBox(height: 40),
                      // App name
                      const Text(
                        'MESH',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 8,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Tagline
                      Text(
                        'Connect Without Limits',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 60),
                      // Loading indicator
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.7),
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Custom mesh network icon widget
class MeshNetworkIcon extends StatelessWidget {
  final double size;

  const MeshNetworkIcon({Key? key, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: MeshNetworkPainter(),
    );
  }
}

/// Custom painter for mesh network visualization
class MeshNetworkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Paint for connections
    final connectionPaint = Paint()
      ..color = const Color(0xFF00D9FF).withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Paint for nodes
    final nodePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final nodeInnerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00D9FF), Color(0xFF00B8D4)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Calculate node positions (hexagon)
    final nodes = <Offset>[];
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * math.pi / 180;
      nodes.add(Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      ));
    }

    // Draw outer ring connections
    for (int i = 0; i < 6; i++) {
      canvas.drawLine(nodes[i], nodes[(i + 1) % 6], connectionPaint);
    }

    // Draw connections to center
    for (final node in nodes) {
      canvas.drawLine(center, node, connectionPaint);
    }

    // Draw signal waves
    for (int i = 1; i <= 3; i++) {
      final wavePaint = Paint()
        ..color = Colors.white.withOpacity(0.3 / i)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(center, radius * 0.4 * i, wavePaint);
    }

    // Draw outer nodes
    for (final node in nodes) {
      canvas.drawCircle(node, 14, nodePaint);
      canvas.drawCircle(node, 10, nodeInnerPaint);
    }

    // Draw center node (larger)
    canvas.drawCircle(center, 22, nodePaint);
    canvas.drawCircle(center, 17, nodeInnerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
