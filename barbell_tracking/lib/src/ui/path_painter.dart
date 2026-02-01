import 'package:flutter/material.dart';

import '../tracker/track_models.dart';
import '../scale/scale_config.dart';
import '../analysis/vbt_zones.dart';

/// Custom painter for drawing barbell path with VBT zone colors
class BarbellPathPainter extends CustomPainter {
  final List<TrackPoint> path;
  final ScaleConfig scaleConfig;
  final bool showVelocityColors;
  final double strokeWidth;
  final double dotSize;
  final Color defaultColor;
  final Color predictedColor;

  BarbellPathPainter({
    required this.path,
    this.scaleConfig = const ScaleConfig(),
    this.showVelocityColors = true,
    this.strokeWidth = 3.0,
    this.dotSize = 8.0,
    this.defaultColor = Colors.green,
    this.predictedColor = Colors.orange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) return;

    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw path segments with velocity-based colors
    for (int i = 0; i < path.length - 1; i++) {
      final p1 = path[i];
      final p2 = path[i + 1];

      final offset1 = Offset(p1.x * size.width, p1.y * size.height);
      final offset2 = Offset(p2.x * size.width, p2.y * size.height);

      if (showVelocityColors) {
        // Calculate velocity between points
        final dt = p2.timestamp.difference(p1.timestamp).inMilliseconds / 1000.0;
        if (dt > 0) {
          final dy = (p2.y - p1.y);
          final velocity = dy / dt;
          final velocityMps = scaleConfig.normalizedToMps(velocity).abs();
          final zone = VelocityZoneExtension.fromMps(velocityMps);
          paint.color = zone.color.withValues(alpha:p2.isPredicted ? 0.5 : 0.9);
        } else {
          paint.color = defaultColor;
        }
      } else {
        paint.color = p2.isPredicted ? predictedColor : defaultColor;
      }

      canvas.drawLine(offset1, offset2, paint);
    }

    // Draw current position dot
    if (path.isNotEmpty) {
      final lastPoint = path.last;
      final center = Offset(lastPoint.x * size.width, lastPoint.y * size.height);

      // Outer glow
      final glowPaint = Paint()
        ..color = (lastPoint.isPredicted ? predictedColor : defaultColor).withValues(alpha:0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, dotSize * 1.5, glowPaint);

      // Inner dot
      final dotPaint = Paint()
        ..color = lastPoint.isPredicted ? predictedColor : defaultColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, dotSize, dotPaint);

      // Center highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha:0.7)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, dotSize * 0.4, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BarbellPathPainter oldDelegate) {
    return path != oldDelegate.path ||
        scaleConfig != oldDelegate.scaleConfig ||
        showVelocityColors != oldDelegate.showVelocityColors;
  }
}

/// Widget for displaying barbell path overlay
class BarbellPathOverlay extends StatelessWidget {
  final List<TrackPoint> path;
  final ScaleConfig scaleConfig;
  final bool showVelocityColors;
  final double strokeWidth;
  final double dotSize;

  const BarbellPathOverlay({
    super.key,
    required this.path,
    this.scaleConfig = const ScaleConfig(),
    this.showVelocityColors = true,
    this.strokeWidth = 3.0,
    this.dotSize = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BarbellPathPainter(
        path: path,
        scaleConfig: scaleConfig,
        showVelocityColors: showVelocityColors,
        strokeWidth: strokeWidth,
        dotSize: dotSize,
      ),
      size: Size.infinite,
    );
  }
}

/// Widget for VBT zone legend
class VbtZoneLegend extends StatelessWidget {
  final Axis direction;
  final double spacing;
  final TextStyle? textStyle;

  const VbtZoneLegend({
    super.key,
    this.direction = Axis.horizontal,
    this.spacing = 8.0,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final zones = VelocityZone.values;

    return direction == Axis.horizontal
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: zones
                .map((zone) => _buildZoneItem(zone))
                .expand((item) => [item, SizedBox(width: spacing)])
                .take(zones.length * 2 - 1)
                .toList(),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: zones
                .map((zone) => _buildZoneItem(zone))
                .expand((item) => [item, SizedBox(height: spacing)])
                .take(zones.length * 2 - 1)
                .toList(),
          );
  }

  Widget _buildZoneItem(VelocityZone zone) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: zone.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          zone.rangeDescription,
          style: textStyle ?? const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}

/// Widget for displaying current velocity zone indicator
class VelocityZoneIndicator extends StatelessWidget {
  final VelocityZone zone;
  final double size;
  final bool showLabel;
  final bool useKorean;

  const VelocityZoneIndicator({
    super.key,
    required this.zone,
    this.size = 48.0,
    this.showLabel = true,
    this.useKorean = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: zone.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: zone.color.withValues(alpha:0.4),
                blurRadius: size / 4,
                spreadRadius: size / 8,
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(
            useKorean ? zone.displayNameKo : zone.displayName,
            style: TextStyle(
              fontSize: size / 4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}
