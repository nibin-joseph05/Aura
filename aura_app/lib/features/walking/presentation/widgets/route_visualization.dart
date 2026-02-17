import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/model/walking_session_model.dart';

 
 
class RouteVisualization extends StatelessWidget {
  final List<RoutePoint> routePoints;
  final double height;

  const RouteVisualization({
    super.key,
    required this.routePoints,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    if (routePoints.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Not enough data to show route',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
            ),
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
          painter: _RoutePainter(
            points: routePoints,
            lineColor: AppColors.accent,
            startColor: AppColors.success,
            endColor: AppColors.error,
          ),
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  final List<RoutePoint> points;
  final Color lineColor;
  final Color startColor;
  final Color endColor;

  _RoutePainter({
    required this.points,
    required this.lineColor,
    required this.startColor,
    required this.endColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

     
    double minLat = double.infinity, maxLat = -double.infinity;
    double minLng = double.infinity, maxLng = -double.infinity;

    for (final p in points) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }

     
    final latRange = maxLat - minLat == 0 ? 0.001 : maxLat - minLat;
    final lngRange = maxLng - minLng == 0 ? 0.001 : maxLng - minLng;

    const padding = 20.0;
    final drawWidth = size.width - padding * 2;
    final drawHeight = size.height - padding * 2;

    Offset toScreen(RoutePoint p) {
      final x = padding + ((p.longitude - minLng) / lngRange) * drawWidth;
       
      final y = padding + (1 - (p.latitude - minLat) / latRange) * drawHeight;
      return Offset(x, y);
    }

     
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 4; i++) {
      final y = padding + drawHeight * i / 4;
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
      final x = padding + drawWidth * i / 4;
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
      ..color = lineColor.withValues(alpha: 0.2)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, shadowPaint);

     
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);

     
    final startPos = toScreen(points.first);
    final endPos = toScreen(points.last);

     
    canvas.drawCircle(startPos, 6, Paint()..color = startColor);
    canvas.drawCircle(
      startPos,
      6,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

     
    canvas.drawCircle(endPos, 6, Paint()..color = endColor);
    canvas.drawCircle(
      endPos,
      6,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
