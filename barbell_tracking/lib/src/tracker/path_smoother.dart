import 'dart:math';

import 'track_models.dart';

/// Path smoother using moving average and outlier detection
class PathSmoother {
  final int windowSize;
  final double outlierThreshold;
  final double minMovementThreshold;

  final List<TrackPoint> _rawPoints = [];
  final List<TrackPoint> _smoothedPoints = [];

  /// Count consecutive outliers to detect legitimate fast motion
  int _consecutiveOutliers = 0;

  PathSmoother({
    this.windowSize = 5,
    this.outlierThreshold = 0.35,
    this.minMovementThreshold = 0.001,
  });

  /// Add a new point and get smoothed result.
  /// Always returns a non-null point to ensure the path is always drawn.
  TrackPoint addPoint(TrackPoint point) {
    if (_rawPoints.isNotEmpty) {
      final last = _rawPoints.last;
      final distance = sqrt(pow(point.x - last.x, 2) + pow(point.y - last.y, 2));

      // Outlier handling: if too far from last point, check if it's
      // a legitimate fast motion (consecutive outliers = real movement)
      if (distance > outlierThreshold) {
        _consecutiveOutliers++;
        if (_consecutiveOutliers >= 2) {
          // Consecutive outliers = legitimate fast motion, accept and reset
          _rawPoints.clear();
          _rawPoints.add(point);
          _consecutiveOutliers = 0;
          _smoothedPoints.add(point);
          return point;
        }
        // Single outlier: return last known position to maintain continuity
        return _smoothedPoints.isNotEmpty ? _smoothedPoints.last : point;
      }

      _consecutiveOutliers = 0;

      // Small movement: still add to raw points and return smoothed
      if (distance < minMovementThreshold && !point.isPredicted) {
        _rawPoints.add(point);
        if (_rawPoints.length > windowSize * 2) {
          _rawPoints.removeAt(0);
        }
        return _smoothedPoints.isNotEmpty ? _smoothedPoints.last : point;
      }
    }

    _rawPoints.add(point);

    if (_rawPoints.length > windowSize * 2) {
      _rawPoints.removeAt(0);
    }

    // Apply moving average smoothing
    if (_rawPoints.length >= windowSize) {
      double sumX = 0, sumY = 0, sumConf = 0;
      int predCount = 0;

      final startIdx = _rawPoints.length - windowSize;
      for (int i = startIdx; i < _rawPoints.length; i++) {
        sumX += _rawPoints[i].x;
        sumY += _rawPoints[i].y;
        sumConf += _rawPoints[i].confidence;
        if (_rawPoints[i].isPredicted) predCount++;
      }

      final smoothed = TrackPoint(
        x: sumX / windowSize,
        y: sumY / windowSize,
        confidence: sumConf / windowSize,
        isPredicted: predCount > windowSize ~/ 2,
        timestamp: point.timestamp,
      );

      _smoothedPoints.add(smoothed);
      return smoothed;
    }

    _smoothedPoints.add(point);
    return point;
  }

  List<TrackPoint> get smoothedPath => List.from(_smoothedPoints);

  void clear() {
    _rawPoints.clear();
    _smoothedPoints.clear();
    _consecutiveOutliers = 0;
  }

  void limitLength(int maxLength) {
    while (_smoothedPoints.length > maxLength) {
      _smoothedPoints.removeAt(0);
    }
  }
}
