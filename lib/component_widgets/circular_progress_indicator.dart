import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Standalone custom Circular Progress Arc Indicator per Figma spec:
/// Outer diameter: ~48-52px, stroke width: ~4.5px, rounded stroke caps.
class CustomCircularProgressIndicator extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color activeColor;
  final Color baseColor;

  const CustomCircularProgressIndicator({
    super.key,
    required this.progress,
    this.size = 50.0,
    this.strokeWidth = 4.5,
    required this.activeColor,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CircularArcPainter(
          progress: progress.clamp(0.0, 1.0),
          strokeWidth: strokeWidth,
          activeColor: activeColor,
          baseColor: baseColor,
        ),
      ),
    );
  }
}

class _CircularArcPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color activeColor;
  final Color baseColor;

  _CircularArcPainter({
    required this.progress,
    required this.strokeWidth,
    required this.activeColor,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. Draw base background ring
    final basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, basePaint);

    // 2. Draw active progress arc if progress > 0
    if (progress > 0) {
      final activePaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2; // Top center
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircularArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
