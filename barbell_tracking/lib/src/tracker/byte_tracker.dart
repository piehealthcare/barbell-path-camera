import 'dart:math';

import 'track_models.dart';
import 'path_smoother.dart';
import '../scale/scale_config.dart';
import '../analysis/exercise_analyzer.dart';

/// ByteTrack-style tracker for single object (barbell)
///
/// Key features:
/// - Kalman filter for position/velocity prediction
/// - Uses low-confidence detections (ByteTrack innovation)
/// - Smooth tracking during detection failures
/// - Rep counting and exercise analysis
/// - Path smoothing and noise filtering
/// - Real-world unit conversion (m/s, m/s²)
class ByteTracker {
  STrack? _track;

  // Confidence thresholds (ByteTrack key innovation)
  final double highConfThreshold;
  final double lowConfThreshold;

  // Association threshold
  final double iouThreshold;
  final double distanceThreshold;

  // Prediction limits
  final int maxPredictionFrames;
  final double maxPredictionDistance;
  final double predictionConfidenceDecay;

  // Scale configuration for real-world units
  ScaleConfig scaleConfig;

  // Path smoother
  final PathSmoother _smoother;

  // Exercise analyzer
  final ExerciseAnalyzer _exerciseAnalyzer;

  // Tracking history for path visualization
  final List<TrackPoint> _path = [];
  static const int maxPathLength = 500;

  ByteTracker({
    this.highConfThreshold = 0.6,
    this.lowConfThreshold = 0.1,
    this.iouThreshold = 0.3,
    this.distanceThreshold = 0.15,
    this.maxPredictionFrames = 15,
    this.maxPredictionDistance = 0.2,
    this.predictionConfidenceDecay = 0.9,
    this.scaleConfig = const ScaleConfig(),
    int smoothingWindow = 3,
    double minRepAmplitude = 0.08,
  }) : _smoother = PathSmoother(windowSize: smoothingWindow),
       _exerciseAnalyzer = ExerciseAnalyzer(minRepAmplitude: minRepAmplitude);

  /// Update tracker with new detections
  TrackResult update(List<Detection> detections) {
    // Sort detections by confidence
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));

    // Separate high and low confidence detections
    final highConfDets = detections.where((d) => d.confidence >= highConfThreshold).toList();
    final lowConfDets = detections.where((d) =>
      d.confidence >= lowConfThreshold && d.confidence < highConfThreshold
    ).toList();

    // No existing track - initialize with best detection
    if (_track == null) {
      if (highConfDets.isNotEmpty) {
        _track = STrack();
        _track!.activate(highConfDets.first);
        _addToPath(_track!.position, highConfDets.first.confidence, false);
        return _createResult(true);
      }
      return TrackResult.empty();
    }

    // Predict new position
    _track!.predict();

    // Try to match with high-confidence detections first
    Detection? matched;
    for (final det in highConfDets) {
      if (_isMatch(det)) {
        matched = det;
        break;
      }
    }

    // If no high-conf match, try low-confidence detections
    if (matched == null && _track!.state == TrackState.lost) {
      for (final det in lowConfDets) {
        if (_isMatch(det)) {
          matched = det;
          break;
        }
      }
    }

    // Update track
    if (matched != null) {
      _track!.update(matched);
      _addToPath(_track!.position, matched.confidence, false);
      return _createResult(true);
    } else {
      _track!.markLost();

      // Check prediction limits
      final withinPredictionLimits =
          _track!.lostFrames <= maxPredictionFrames &&
          _track!.predictionDistance <= maxPredictionDistance;

      if (_track!.isActive && withinPredictionLimits) {
        final decayedConfidence = _track!.lastConfidence *
            pow(predictionConfidenceDecay, _track!.lostFrames);
        _addToPath(_track!.position, decayedConfidence, true);
        return _createResult(false);
      }

      if ((!_track!.isActive || !withinPredictionLimits) && highConfDets.isNotEmpty) {
        _track = STrack();
        _track!.activate(highConfDets.first);
        _addToPath(_track!.position, highConfDets.first.confidence, false);
        return _createResult(true);
      }

      return _createResult(false);
    }
  }

  bool _isMatch(Detection det) {
    if (_track == null) return false;

    final predicted = _track!.predictedDetection;

    final iou = det.iou(predicted);
    if (iou >= iouThreshold) return true;

    final dist = det.distanceTo(predicted.x, predicted.y);
    if (dist <= distanceThreshold) return true;

    return false;
  }

  void _addToPath(List<double> pos, double confidence, bool isPredicted) {
    final rawPoint = TrackPoint(
      x: pos[0],
      y: pos[1],
      confidence: confidence,
      isPredicted: isPredicted,
      timestamp: DateTime.now(),
    );

    final smoothed = _smoother.addPoint(rawPoint);
    if (smoothed != null) {
      _path.add(smoothed);
    }

    if (_path.length > maxPathLength) {
      _path.removeAt(0);
    }
    _smoother.limitLength(maxPathLength);
  }

  TrackResult _createResult(bool detected) {
    if (_track == null || !_track!.isActive) {
      return TrackResult.empty();
    }

    final exerciseStats = _exerciseAnalyzer.update(
      _track!.position[0],
      _track!.position[1],
      _track!.velocity[1],
      _track!.speed,
    );

    return TrackResult(
      x: _track!.position[0],
      y: _track!.position[1],
      vx: _track!.velocity[0],
      vy: _track!.velocity[1],
      speed: _track!.speed,
      confidence: _track!.lastConfidence,
      isDetected: detected,
      isPredicted: !detected && _track!.lostFrames > 0,
      lostFrames: _track!.lostFrames,
      path: List.from(_path),
      exerciseStats: exerciseStats,
      scaleConfig: scaleConfig,
    );
  }

  /// Reset the tracker
  void reset() {
    _track = null;
    _path.clear();
    _smoother.clear();
    _exerciseAnalyzer.reset();
  }

  /// Get current path
  List<TrackPoint> get path => List.from(_path);

  /// Clear path history
  void clearPath() {
    _path.clear();
    _smoother.clear();
  }

  /// Reset exercise statistics
  void resetExerciseStats() {
    _exerciseAnalyzer.reset();
  }

  /// Start a new set
  void startNewSet() {
    _exerciseAnalyzer.startNewSet();
    clearPath();
  }

  /// Finish current set
  void finishSet() {
    _exerciseAnalyzer.finishSet();
  }

  /// Get exercise stats
  ExerciseStats get exerciseStats {
    if (_track == null) return ExerciseStats.empty();
    return _exerciseAnalyzer.update(
      _track!.position[0],
      _track!.position[1],
      _track!.velocity[1],
      _track!.speed,
    );
  }

  /// Get all sets
  List<SetInfo> get sets => _exerciseAnalyzer.sets;

  /// Get current set
  SetInfo? get currentSet => _exerciseAnalyzer.currentSet;

  /// Check if tracking is active
  bool get hasTrack => _track != null && _track!.isActive;

  /// Get current position or null
  List<double>? get currentPosition => _track?.position;

  /// Get current velocity or null
  List<double>? get currentVelocity => _track?.velocity;
}
