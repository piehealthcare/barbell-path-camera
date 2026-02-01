import 'dart:math';

import 'kalman_filter.dart';
import '../scale/scale_config.dart';
import '../analysis/vbt_zones.dart';
import '../analysis/exercise_analyzer.dart';

/// Detection result from YOLO model
class Detection {
  final double x;  // Center x (normalized 0-1)
  final double y;  // Center y (normalized 0-1)
  final double width;
  final double height;
  final double confidence;

  const Detection({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.confidence,
  });

  /// Calculate IoU with another detection
  double iou(Detection other) {
    final x1 = max(x - width / 2, other.x - other.width / 2);
    final y1 = max(y - height / 2, other.y - other.height / 2);
    final x2 = min(x + width / 2, other.x + other.width / 2);
    final y2 = min(y + height / 2, other.y + other.height / 2);

    if (x2 <= x1 || y2 <= y1) return 0.0;

    final intersection = (x2 - x1) * (y2 - y1);
    final area1 = width * height;
    final area2 = other.width * other.height;
    final union = area1 + area2 - intersection;

    return union > 0 ? intersection / union : 0.0;
  }

  /// Calculate distance to another point
  double distanceTo(double ox, double oy) {
    return sqrt((x - ox) * (x - ox) + (y - oy) * (y - oy));
  }
}

/// Track state
enum TrackState { tracked, lost, removed }

/// Single track representation (STrack in ByteTrack)
class STrack {
  final KalmanFilter2D _kalman;
  TrackState state = TrackState.tracked;
  int lostFrames = 0;
  int trackedFrames = 0;
  double lastWidth = 0.05;
  double lastHeight = 0.05;
  double lastConfidence = 0.0;

  // Last known detected position
  double _lastDetectedX = 0;
  double _lastDetectedY = 0;

  static const int maxLostFrames = 30;

  STrack() : _kalman = KalmanFilter2D();

  /// Initialize track with first detection
  void activate(Detection det) {
    _kalman.init(det.x, det.y);
    lastWidth = det.width;
    lastHeight = det.height;
    lastConfidence = det.confidence;
    _lastDetectedX = det.x;
    _lastDetectedY = det.y;
    state = TrackState.tracked;
    lostFrames = 0;
    trackedFrames = 1;
  }

  /// Predict next position
  List<double> predict() {
    return _kalman.predict();
  }

  /// Update with new detection
  void update(Detection det) {
    _kalman.update(det.x, det.y);
    lastWidth = det.width;
    lastHeight = det.height;
    lastConfidence = det.confidence;
    _lastDetectedX = det.x;
    _lastDetectedY = det.y;
    state = TrackState.tracked;
    lostFrames = 0;
    trackedFrames++;
  }

  /// Mark as lost (no detection this frame)
  void markLost() {
    lostFrames++;
    if (lostFrames > maxLostFrames) {
      state = TrackState.removed;
    } else {
      state = TrackState.lost;
    }
  }

  List<double> get position => _kalman.position;
  List<double> get velocity => _kalman.velocity;
  double get speed => _kalman.speed;
  List<double> get lastDetectedPosition => [_lastDetectedX, _lastDetectedY];

  double get predictionDistance {
    final pos = position;
    final dx = pos[0] - _lastDetectedX;
    final dy = pos[1] - _lastDetectedY;
    return sqrt(dx * dx + dy * dy);
  }

  bool get isActive => state != TrackState.removed;

  Detection get predictedDetection => Detection(
    x: position[0],
    y: position[1],
    width: lastWidth,
    height: lastHeight,
    confidence: lastConfidence * 0.8,
  );
}

/// Single point in track path
class TrackPoint {
  final double x;
  final double y;
  final double confidence;
  final bool isPredicted;
  final DateTime timestamp;

  const TrackPoint({
    required this.x,
    required this.y,
    required this.confidence,
    required this.isPredicted,
    required this.timestamp,
  });
}

/// Tracking result with real-world unit support
class TrackResult {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final double speed;
  final double confidence;
  final bool isDetected;
  final bool isPredicted;
  final int lostFrames;
  final List<TrackPoint> path;
  final bool hasTrack;
  final ExerciseStats exerciseStats;
  final ScaleConfig scaleConfig;

  TrackResult({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.speed,
    required this.confidence,
    required this.isDetected,
    required this.isPredicted,
    required this.lostFrames,
    required this.path,
    ExerciseStats? exerciseStats,
    this.scaleConfig = const ScaleConfig(),
  }) : hasTrack = true,
       exerciseStats = exerciseStats ?? ExerciseStats.empty();

  TrackResult.empty()
      : x = 0,
        y = 0,
        vx = 0,
        vy = 0,
        speed = 0,
        confidence = 0,
        isDetected = false,
        isPredicted = false,
        lostFrames = 0,
        path = const [],
        hasTrack = false,
        exerciseStats = ExerciseStats.empty(),
        scaleConfig = const ScaleConfig();

  /// Get speed in m/s
  double get speedMps => scaleConfig.normalizedToMps(speed);

  /// Get vertical velocity in m/s (negative = upward)
  double get velocityYMps => scaleConfig.normalizedToMps(vy);

  /// Get velocity zone
  VelocityZone get velocityZone => VelocityZoneExtension.fromMps(velocityYMps);
}
