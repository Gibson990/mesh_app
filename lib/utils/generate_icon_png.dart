import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import 'package:path_provider/path_provider.dart';

/// Generate PNG icon from custom painter
class IconGenerator {
  static Future<void> generateIcons() async {
    // Generate 1024x1024 for app icon
    await _generateIcon(1024, 'app_icon.png');
    
    // Generate 512x512 for splash
    await _generateIcon(512, 'splash_icon.png');
    
    print('✅ Icons generated successfully!');
  }

  static Future<void> _generateIcon(int size, String filename) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Draw icon
    _drawMeshIcon(canvas, Size(size.toDouble(), size.toDouble()));
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    
    // Save to assets folder
    final appDir = Directory.current;
    final iconDir = Directory('${appDir.path}/assets/icon');
    final splashDir = Directory('${appDir.path}/assets/splash');
    
    if (!iconDir.existsSync()) iconDir.createSync(recursive: true);
    if (!splashDir.existsSync()) splashDir.createSync(recursive: true);
    
    final file = filename.contains('splash')
        ? File('${splashDir.path}/$filename')
        : File('${iconDir.path}/$filename');
    
    await file.writeAsBytes(bytes);
    print('✅ Generated: ${file.path}');
  }

  static void _drawMeshIcon(Canvas canvas, Size size) {
    // Background gradient
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, size.height),
        [
          const Color(0xFF6C63FF),
          const Color(0xFF5B52E8),
          const Color(0xFF4834DF),
        ],
      );
    
    // Draw rounded rectangle background
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.width * 0.22),
    );
    canvas.drawRRect(bgRect, bgPaint);
    
    // Draw mesh network
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;
    
    // Connection paint
    final connectionPaint = Paint()
      ..color = const Color(0xFF00D9FF).withOpacity(0.6)
      ..strokeWidth = size.width * 0.006
      ..style = PaintingStyle.stroke;
    
    // Node paints
    final nodePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final nodeInnerPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, size.height),
        [
          const Color(0xFF00D9FF),
          const Color(0xFF00B8D4),
        ],
      );
    
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
        ..strokeWidth = size.width * 0.004
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(center, radius * 0.35 * i, wavePaint);
    }
    
    // Draw outer nodes
    final nodeSize = size.width * 0.027;
    final nodeInnerSize = size.width * 0.02;
    for (final node in nodes) {
      canvas.drawCircle(node, nodeSize, nodePaint);
      canvas.drawCircle(node, nodeInnerSize, nodeInnerPaint);
    }
    
    // Draw center node (larger)
    final centerNodeSize = size.width * 0.043;
    final centerNodeInnerSize = size.width * 0.033;
    canvas.drawCircle(center, centerNodeSize, nodePaint);
    canvas.drawCircle(center, centerNodeInnerSize, nodeInnerPaint);
  }
}
