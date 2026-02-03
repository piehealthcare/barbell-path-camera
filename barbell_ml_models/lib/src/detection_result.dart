import 'dart:math';

/// A single barbell detection result.
class BarbellDetection {
  /// Center X (normalized 0-1)
  final double x;

  /// Center Y (normalized 0-1)
  final double y;

  /// Width (normalized 0-1)
  final double width;

  /// Height (normalized 0-1)
  final double height;

  /// Detection confidence (0-1)
  final double confidence;

  /// Class index (0 = barbell)
  final int classIndex;

  const BarbellDetection({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.confidence,
    this.classIndex = 0,
  });

  /// Bounding box as [left, top, right, bottom] normalized.
  List<double> get bbox => [
        x - width / 2,
        y - height / 2,
        x + width / 2,
        y + height / 2,
      ];

  /// Area of the bounding box (normalized).
  double get area => width * height;

  /// Calculate IoU with another detection.
  double iou(BarbellDetection other) {
    final x1 = max(bbox[0], other.bbox[0]);
    final y1 = max(bbox[1], other.bbox[1]);
    final x2 = min(bbox[2], other.bbox[2]);
    final y2 = min(bbox[3], other.bbox[3]);

    if (x2 <= x1 || y2 <= y1) return 0.0;

    final intersection = (x2 - x1) * (y2 - y1);
    final union = area + other.area - intersection;
    return union > 0 ? intersection / union : 0.0;
  }

  /// Convert to Map for MethodChannel transport.
  Map<String, dynamic> toMap() => {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'confidence': confidence,
        'classIndex': classIndex,
      };

  /// Create from Map (e.g., from MethodChannel).
  factory BarbellDetection.fromMap(Map<dynamic, dynamic> map) {
    return BarbellDetection(
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      width: (map['width'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      confidence: (map['confidence'] as num).toDouble(),
      classIndex: (map['classIndex'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  String toString() =>
      'BarbellDetection(x: ${x.toStringAsFixed(3)}, y: ${y.toStringAsFixed(3)}, '
      'w: ${width.toStringAsFixed(3)}, h: ${height.toStringAsFixed(3)}, '
      'conf: ${confidence.toStringAsFixed(3)})';
}

/// Apply Non-Maximum Suppression to a list of detections.
List<BarbellDetection> nms(
  List<BarbellDetection> detections, {
  double iouThreshold = 0.45,
  double confidenceThreshold = 0.25,
}) {
  final filtered = detections
      .where((d) => d.confidence >= confidenceThreshold)
      .toList()
    ..sort((a, b) => b.confidence.compareTo(a.confidence));

  final kept = <BarbellDetection>[];
  final suppressed = List.filled(filtered.length, false);

  for (var i = 0; i < filtered.length; i++) {
    if (suppressed[i]) continue;
    kept.add(filtered[i]);

    for (var j = i + 1; j < filtered.length; j++) {
      if (suppressed[j]) continue;
      if (filtered[i].iou(filtered[j]) > iouThreshold) {
        suppressed[j] = true;
      }
    }
  }

  return kept;
}
