import 'package:flutter/material.dart';
import 'package:barbell_tracking/barbell_tracking.dart';

class TrackingOverlay extends StatelessWidget {
  final List<TrackPoint> path;
  final ScaleConfig scaleConfig;
  final List<double>? currentPosition;

  const TrackingOverlay({
    super.key,
    required this.path,
    required this.scaleConfig,
    this.currentPosition,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _TrackingPathPainter(
        path: path,
        scaleConfig: scaleConfig,
        currentPosition: currentPosition,
      ),
    );
  }
}

class _TrackingPathPainter extends CustomPainter {
  final List<TrackPoint> path;
  final ScaleConfig scaleConfig;
  final List<double>? currentPosition;

  _TrackingPathPainter({
    required this.path,
    required this.scaleConfig,
    this.currentPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) {
      // Draw current position dot even with no path
      if (currentPosition != null) {
        _drawCurrentDot(canvas, size);
      }
      return;
    }

    // Draw path
    final pathPaint = Paint()
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 1; i < path.length; i++) {
      final prev = path[i - 1];
      final curr = path[i];

      // Velocity-based color
      final speed = scaleConfig.normalizedToMps(
        ((curr.x - prev.x) * (curr.x - prev.x) +
                (curr.y - prev.y) * (curr.y - prev.y))
            .abs(),
      );
      final zone = VelocityZoneExtension.fromMps(speed);
      pathPaint.color = zone.color.withValues(alpha: 0.9);

      canvas.drawLine(
        Offset(prev.x * size.width, prev.y * size.height),
        Offset(curr.x * size.width, curr.y * size.height),
        pathPaint,
      );
    }

    // Glow effect for path
    final glowPaint = Paint()
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    if (path.length >= 2) {
      final lastTwo = path.sublist(path.length - 2);
      glowPaint.color = Colors.white.withValues(alpha: 0.3);
      canvas.drawLine(
        Offset(lastTwo[0].x * size.width, lastTwo[0].y * size.height),
        Offset(lastTwo[1].x * size.width, lastTwo[1].y * size.height),
        glowPaint,
      );
    }

    // Draw current position
    if (currentPosition != null) {
      _drawCurrentDot(canvas, size);
    }
  }

  void _drawCurrentDot(Canvas canvas, Size size) {
    final pos = currentPosition!;
    final center = Offset(pos[0] * size.width, pos[1] * size.height);

    // Outer glow
    canvas.drawCircle(
      center,
      16,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Inner circle
    canvas.drawCircle(
      center,
      8,
      Paint()..color = Colors.white,
    );

    // Center dot
    canvas.drawCircle(
      center,
      4,
      Paint()..color = Colors.red,
    );
  }

  @override
  bool shouldRepaint(covariant _TrackingPathPainter oldDelegate) {
    return path.length != oldDelegate.path.length ||
        currentPosition != oldDelegate.currentPosition;
  }
}
