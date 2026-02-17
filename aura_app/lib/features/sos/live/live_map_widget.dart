import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class LiveMapWidget extends StatelessWidget {
  final List<Map<String, double>> points;
  final double height;

  const LiveMapWidget({super.key, required this.points, this.height = 250});

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_searching,
                size: 40,
                color: AppColors.accent.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 12),
              Text(
                'Acquiring location...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          size: Size.infinite,
          painter: _LiveMapPainter(
            points: points,
            pathColor: AppColors.accent,
            pulseColor: AppColors.error,
          ),
        ),
      ),
    );
  }
}

class _LiveMapPainter extends CustomPainter {
  final List<Map<String, double>> points;
  final Color pathColor;
  final Color pulseColor;

  _LiveMapPainter({
    required this.points,
    required this.pathColor,
    required this.pulseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    double minLat = double.infinity, maxLat = -double.infinity;
    double minLng = double.infinity, maxLng = -double.infinity;

    for (final p in points) {
      minLat = math.min(minLat, p['lat']!);
      maxLat = math.max(maxLat, p['lat']!);
      minLng = math.min(minLng, p['lng']!);
      maxLng = math.max(maxLng, p['lng']!);
    }

    final latRange = maxLat - minLat == 0 ? 0.001 : maxLat - minLat;
    final lngRange = maxLng - minLng == 0 ? 0.001 : maxLng - minLng;

    const padding = 24.0;
    final drawWidth = size.width - padding * 2;
    final drawHeight = size.height - padding * 2;

    Offset toScreen(Map<String, double> p) {
      final x = padding + ((p['lng']! - minLng) / lngRange) * drawWidth;
      final y = padding + (1 - (p['lat']! - minLat) / latRange) * drawHeight;
      return Offset(x, y);
    }

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 6; i++) {
      final y = padding + drawHeight * i / 6;
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
      final x = padding + drawWidth * i / 6;
      canvas.drawLine(
        Offset(x, padding),
        Offset(x, size.height - padding),
        gridPaint,
      );
    }

    final path = Path();
    final firstPoint = toScreen(points.first);
    path.moveTo(firstPoint.dx, firstPoint.dy);

    for (int i = 1; i < points.length; i++) {
      final current = toScreen(points[i]);
      final prev = toScreen(points[i - 1]);
      final midX = (prev.dx + current.dx) / 2;
      final midY = (prev.dy + current.dy) / 2;
      path.quadraticBezierTo(prev.dx, prev.dy, midX, midY);
    }
    path.lineTo(toScreen(points.last).dx, toScreen(points.last).dy);

    final shadowPaint = Paint()
      ..color = pathColor.withValues(alpha: 0.25)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, shadowPaint);

    final linePaint = Paint()
      ..color = pathColor
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);

    final startPos = toScreen(points.first);
    canvas.drawCircle(startPos, 5, Paint()..color = AppColors.success);
    canvas.drawCircle(
      startPos,
      5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final endPos = toScreen(points.last);
    canvas.drawCircle(
      endPos,
      8,
      Paint()..color = pulseColor.withValues(alpha: 0.3),
    );
    canvas.drawCircle(endPos, 5, Paint()..color = pulseColor);
    canvas.drawCircle(
      endPos,
      5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _LiveMapPainter oldDelegate) {
    return oldDelegate.points.length != points.length;
  }
}
