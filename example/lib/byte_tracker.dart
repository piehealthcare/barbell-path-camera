/// ByteTrack-style Single Object Tracker for Barbell
///
/// Based on: https://github.com/FoundationVision/ByteTrack
/// Enhanced for barbell tracking with exercise analysis
///
/// Key features:
/// - Kalman filter for position/velocity prediction
/// - Uses low-confidence detections (ByteTrack innovation)
/// - Smooth tracking during detection failures
/// - Rep counting and exercise analysis
/// - Path smoothing and noise filtering
/// - Real-world unit conversion (m/s, m/s²)

library byte_tracker;

import 'dart:math';

/// Real-world scale configuration
/// Used to convert normalized coordinates to actual measurements
class ScaleConfig {
  /// Pixels per meter (calculated from calibration)
  /// This is the key value - how many normalized units = 1 meter
  final double pixelsPerMeter;

  /// Frame rate for velocity calculations
  final double fps;

  /// Whether this config has been calibrated
  final bool isCalibrated;

  /// Reference object used for calibration
  final String? calibrationReference;

  const ScaleConfig({
    this.pixelsPerMeter = 1.0,  // Default: 1 normalized unit = 1 meter (uncalibrated)
    this.fps = 30.0,
    this.isCalibrated = false,
    this.calibrationReference,
  });

  /// Create config from known plate diameter
  /// Standard plate diameters:
  /// - 20kg/45lb: 45cm (0.45m)
  /// - 15kg/35lb: 40cm (0.40m)
  /// - 10kg/25lb: 35cm (0.35m)
  /// - 5kg/10lb: 22.8cm (0.228m)
  factory ScaleConfig.fromPlateSize({
    required double detectedWidthNormalized,
    required double actualDiameterMeters,
    double fps = 30.0,
  }) {
    // pixelsPerMeter = normalized_width / actual_meters
    final ppm = detectedWidthNormalized / actualDiameterMeters;
    return ScaleConfig(
      pixelsPerMeter: ppm,
      fps: fps,
      isCalibrated: true,
      calibrationReference: '${(actualDiameterMeters * 100).round()}cm plate',
    );
  }

  /// Create config from known distance measurement
  /// User marks two points on screen and enters real distance
  factory ScaleConfig.fromDistance({
    required double normalizedDistance,
    required double actualDistanceMeters,
    double fps = 30.0,
  }) {
    final ppm = normalizedDistance / actualDistanceMeters;
    return ScaleConfig(
      pixelsPerMeter: ppm,
      fps: fps,
      isCalibrated: true,
      calibrationReference: '${(actualDistanceMeters * 100).round()}cm reference',
    );
  }

  /// Create config from camera distance (rough estimation)
  /// Assumes typical phone camera FOV (~60-70 degrees)
  factory ScaleConfig.fromCameraDistance({
    required double distanceMeters,
    double fovDegrees = 65.0,
    double fps = 30.0,
  }) {
    // Approximate visible height at given distance
    // visible_height = 2 * distance * tan(fov/2)
    final fovRad = fovDegrees * 3.14159 / 180;
    final visibleHeight = 2 * distanceMeters * tan(fovRad / 2);
    // 1 normalized unit spans visibleHeight meters
    final ppm = 1.0 / visibleHeight;
    return ScaleConfig(
      pixelsPerMeter: ppm,
      fps: fps,
      isCalibrated: true,
      calibrationReference: '${distanceMeters.toStringAsFixed(1)}m distance',
    );
  }

  /// Convert normalized velocity to m/s
  double normalizedToMps(double normalizedVelocity, {bool vertical = true}) {
    // velocity in normalized/frame * frames/second * meters/normalized
    return normalizedVelocity * fps / pixelsPerMeter;
  }

  /// Convert normalized distance to meters
  double normalizedToMeters(double normalizedDistance, {bool vertical = true}) {
    return normalizedDistance / pixelsPerMeter;
  }

  /// Convert normalized distance to centimeters
  double normalizedToCm(double normalizedDistance, {bool vertical = true}) {
    return normalizedToMeters(normalizedDistance, vertical: vertical) * 100;
  }

  /// Convert normalized acceleration to m/s²
  double normalizedToMps2(double normalizedAccel, {bool vertical = true}) {
    // accel in normalized/frame² * (frames/second)² * meters/normalized
    return normalizedAccel * fps * fps / pixelsPerMeter;
  }

  /// Default uncalibrated config
  static const uncalibrated = ScaleConfig(
    pixelsPerMeter: 1.0,
    isCalibrated: false,
  );

  /// Preset for typical squat setup (~2.5m from camera)
  static final squat = ScaleConfig.fromCameraDistance(distanceMeters: 2.5);

  /// Preset for typical bench press setup (~2m from camera)
  static final benchPress = ScaleConfig.fromCameraDistance(distanceMeters: 2.0);

  /// Preset for overhead press (~2.5m from camera)
  static final overheadPress = ScaleConfig.fromCameraDistance(distanceMeters: 2.5);
}

/// Standard weight plate diameters in meters
class PlateSizes {
  static const double kg20 = 0.450; // 45cm - Olympic 20kg
  static const double kg15 = 0.400; // 40cm - Olympic 15kg
  static const double kg10 = 0.350; // 35cm - Olympic 10kg
  static const double kg5 = 0.228;  // 22.8cm - Olympic 5kg
  static const double kg25 = 0.210; // 21cm - Olympic 2.5kg
  static const double kg125 = 0.190; // 19cm - Olympic 1.25kg

  static const Map<String, double> all = {
    '20kg (45cm)': kg20,
    '15kg (40cm)': kg15,
    '10kg (35cm)': kg10,
    '5kg (22.8cm)': kg5,
    '2.5kg (21cm)': kg25,
    '1.25kg (19cm)': kg125,
  };
}

/// Helper for tangent calculation
double tan(double radians) {
  return sin(radians) / cos(radians);
}

double sin(double radians) {
  return _sin(radians);
}

double cos(double radians) {
  return _cos(radians);
}

// Simple sin/cos using Taylor series (avoid dart:math import issues)
double _sin(double x) {
  // Normalize to [-pi, pi]
  while (x > 3.14159) x -= 2 * 3.14159;
  while (x < -3.14159) x += 2 * 3.14159;

  double result = x;
  double term = x;
  for (int i = 1; i <= 10; i++) {
    term *= -x * x / ((2 * i) * (2 * i + 1));
    result += term;
  }
  return result;
}

double _cos(double x) {
  return _sin(x + 3.14159 / 2);
}

/// Velocity zone for VBT (Velocity Based Training)
enum VelocityZone {
  strength,      // < 0.5 m/s (heavy, strength focus)
  strengthSpeed, // 0.5 - 0.75 m/s
  power,         // 0.75 - 1.0 m/s
  speedStrength, // 1.0 - 1.3 m/s
  speed,         // > 1.3 m/s (explosive, speed focus)
}

/// Get velocity zone from m/s
VelocityZone getVelocityZone(double mps) {
  final absMps = mps.abs();
  if (absMps < 0.5) return VelocityZone.strength;
  if (absMps < 0.75) return VelocityZone.strengthSpeed;
  if (absMps < 1.0) return VelocityZone.power;
  if (absMps < 1.3) return VelocityZone.speedStrength;
  return VelocityZone.speed;
}

/// 2D Kalman Filter for position and velocity tracking
/// State: [x, y, vx, vy] (position and velocity)
class KalmanFilter {
  // State vector [x, y, vx, vy]
  List<double> _state;

  // State covariance matrix (4x4)
  List<List<double>> _P;

  // Process noise
  final double _processNoise;

  // Measurement noise
  final double _measurementNoise;

  // Time step
  final double _dt;

  KalmanFilter({
    double dt = 1.0 / 30.0, // 30 FPS
    double processNoise = 0.01,
    double measurementNoise = 0.1,
  })  : _dt = dt,
        _processNoise = processNoise,
        _measurementNoise = measurementNoise,
        _state = [0, 0, 0, 0],
        _P = _identityMatrix(4, scale: 1.0);

  /// Initialize with first detection
  void init(double x, double y) {
    _state = [x, y, 0, 0];
    _P = _identityMatrix(4, scale: 1.0);
  }

  /// Predict next state (call every frame)
  List<double> predict() {
    // Predict state: x' = F * x
    final x = _state[0] + _state[2] * _dt;
    final y = _state[1] + _state[3] * _dt;
    final vx = _state[2];
    final vy = _state[3];
    _state = [x, y, vx, vy];

    // Predict covariance: P' = F * P * F^T + Q
    final F = [
      [1.0, 0.0, _dt, 0.0],
      [0.0, 1.0, 0.0, _dt],
      [0.0, 0.0, 1.0, 0.0],
      [0.0, 0.0, 0.0, 1.0],
    ];

    final Q = _identityMatrix(4, scale: _processNoise);
    _P = _addMatrix(_multiplyMatrix(_multiplyMatrix(F, _P), _transposeMatrix(F)), Q);

    return [_state[0], _state[1]];
  }

  /// Update with measurement
  void update(double x, double y) {
    // Measurement residual: y = z - H * x
    final residual = [x - _state[0], y - _state[1]];

    // Residual covariance: S = H * P * H^T + R
    final S = [
      [_P[0][0] + _measurementNoise, _P[0][1]],
      [_P[1][0], _P[1][1] + _measurementNoise],
    ];

    // Kalman gain: K = P * H^T * S^(-1)
    final sInv = _invertMatrix2x2(S);
    final pHt = [
      [_P[0][0], _P[0][1]],
      [_P[1][0], _P[1][1]],
      [_P[2][0], _P[2][1]],
      [_P[3][0], _P[3][1]],
    ];
    final K = _multiplyMatrix(pHt, sInv);

    // Update state: x = x + K * y
    _state[0] += K[0][0] * residual[0] + K[0][1] * residual[1];
    _state[1] += K[1][0] * residual[0] + K[1][1] * residual[1];
    _state[2] += K[2][0] * residual[0] + K[2][1] * residual[1];
    _state[3] += K[3][0] * residual[0] + K[3][1] * residual[1];

    // Update covariance: P = (I - K * H) * P
    final kh = [
      [K[0][0], K[0][1], 0.0, 0.0],
      [K[1][0], K[1][1], 0.0, 0.0],
      [K[2][0], K[2][1], 0.0, 0.0],
      [K[3][0], K[3][1], 0.0, 0.0],
    ];
    final iMinusKH = _subtractMatrix(_identityMatrix(4), kh);
    _P = _multiplyMatrix(iMinusKH, _P);
  }

  /// Get current estimated position
  List<double> get position => [_state[0], _state[1]];

  /// Get current estimated velocity
  List<double> get velocity => [_state[2], _state[3]];

  /// Get speed (magnitude of velocity)
  double get speed => sqrt(_state[2] * _state[2] + _state[3] * _state[3]);

  // Matrix operations
  static List<List<double>> _identityMatrix(int n, {double scale = 1.0}) {
    return List.generate(n, (i) => List.generate(n, (j) => i == j ? scale : 0.0));
  }

  static List<List<double>> _multiplyMatrix(List<List<double>> a, List<List<double>> b) {
    final m = a.length;
    final n = b[0].length;
    final p = b.length;
    return List.generate(m, (i) => List.generate(n, (j) {
      double sum = 0;
      for (int k = 0; k < p; k++) {
        sum += a[i][k] * b[k][j];
      }
      return sum;
    }));
  }

  static List<List<double>> _transposeMatrix(List<List<double>> a) {
    final m = a.length;
    final n = a[0].length;
    return List.generate(n, (i) => List.generate(m, (j) => a[j][i]));
  }

  static List<List<double>> _addMatrix(List<List<double>> a, List<List<double>> b) {
    final m = a.length;
    final n = a[0].length;
    return List.generate(m, (i) => List.generate(n, (j) => a[i][j] + b[i][j]));
  }

  static List<List<double>> _subtractMatrix(List<List<double>> a, List<List<double>> b) {
    final m = a.length;
    final n = a[0].length;
    return List.generate(m, (i) => List.generate(n, (j) => a[i][j] - b[i][j]));
  }

  static List<List<double>> _invertMatrix2x2(List<List<double>> m) {
    final det = m[0][0] * m[1][1] - m[0][1] * m[1][0];
    if (det.abs() < 1e-10) {
      return [[1, 0], [0, 1]]; // Return identity if singular
    }
    return [
      [m[1][1] / det, -m[0][1] / det],
      [-m[1][0] / det, m[0][0] / det],
    ];
  }
}

/// Detection result from YOLO
class Detection {
  final double x;  // Center x (normalized 0-1)
  final double y;  // Center y (normalized 0-1)
  final double width;
  final double height;
  final double confidence;

  Detection({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.confidence,
  });

  /// Calculate IoU with another detection or predicted position
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
  final KalmanFilter _kalman;
  TrackState state = TrackState.tracked;
  int lostFrames = 0;
  int trackedFrames = 0;
  double lastWidth = 0.05;
  double lastHeight = 0.05;
  double lastConfidence = 0.0;

  // Last known detected position (for prediction distance limit)
  double _lastDetectedX = 0;
  double _lastDetectedY = 0;

  static const int maxLostFrames = 30; // 1 second at 30fps

  STrack() : _kalman = KalmanFilter();

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

  /// Predict next position (call every frame)
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

  /// Get current position
  List<double> get position => _kalman.position;

  /// Get velocity
  List<double> get velocity => _kalman.velocity;

  /// Get speed
  double get speed => _kalman.speed;

  /// Get last detected position
  List<double> get lastDetectedPosition => [_lastDetectedX, _lastDetectedY];

  /// Get distance from last detected position
  double get predictionDistance {
    final pos = position;
    final dx = pos[0] - _lastDetectedX;
    final dy = pos[1] - _lastDetectedY;
    return sqrt(dx * dx + dy * dy);
  }

  /// Is this track still active?
  bool get isActive => state != TrackState.removed;

  /// Create a pseudo-detection from predicted position
  Detection get predictedDetection => Detection(
    x: position[0],
    y: position[1],
    width: lastWidth,
    height: lastHeight,
    confidence: lastConfidence * 0.8, // Reduce confidence for predictions
  );
}

/// Exercise analysis result with real units
class ExerciseStats {
  final int repCount;
  final double? lastRepDuration; // seconds
  final double? avgRepDuration; // seconds

  // Position stats (in cm using ScaleConfig)
  final double highestY; // normalized 0-1 (top of screen = 0)
  final double lowestY; // normalized 0-1
  final double romNormalized; // Range of motion (normalized)

  // Velocity stats (normalized, convert with ScaleConfig)
  final double currentSpeed; // normalized
  final double currentVelocityY; // normalized (negative = upward)
  final double maxSpeed; // normalized
  final double acceleration; // normalized

  // Phase and timing
  final MovementPhase phase;
  final List<RepInfo> repHistory;

  // Path analysis
  final double pathDeviation; // How straight is the path (0 = perfect vertical, higher = more deviation)
  final double avgPathX; // Average X position during movement

  // Current rep stats
  final double? currentRepPeakVelocity; // Peak velocity in current rep
  final double? currentRepMeanVelocity; // Mean velocity in current rep
  final double? eccentricTime; // Time for downward phase
  final double? concentricTime; // Time for upward phase

  ExerciseStats({
    required this.repCount,
    this.lastRepDuration,
    this.avgRepDuration,
    required this.highestY,
    required this.lowestY,
    required this.romNormalized,
    required this.currentSpeed,
    required this.currentVelocityY,
    required this.maxSpeed,
    required this.acceleration,
    required this.phase,
    required this.repHistory,
    required this.pathDeviation,
    required this.avgPathX,
    this.currentRepPeakVelocity,
    this.currentRepMeanVelocity,
    this.eccentricTime,
    this.concentricTime,
  });

  ExerciseStats.empty()
      : repCount = 0,
        lastRepDuration = null,
        avgRepDuration = null,
        highestY = 1,
        lowestY = 0,
        romNormalized = 0,
        currentSpeed = 0,
        currentVelocityY = 0,
        maxSpeed = 0,
        acceleration = 0,
        phase = MovementPhase.idle,
        repHistory = const [],
        pathDeviation = 0,
        avgPathX = 0.5,
        currentRepPeakVelocity = null,
        currentRepMeanVelocity = null,
        eccentricTime = null,
        concentricTime = null;

  /// Get ROM in cm
  double getRomCm(ScaleConfig config) {
    return config.normalizedToCm(romNormalized, vertical: true);
  }

  /// Get current speed in m/s
  double getSpeedMps(ScaleConfig config) {
    return config.normalizedToMps(currentSpeed);
  }

  /// Get current vertical velocity in m/s
  double getVelocityYMps(ScaleConfig config) {
    return config.normalizedToMps(currentVelocityY, vertical: true);
  }

  /// Get max speed in m/s
  double getMaxSpeedMps(ScaleConfig config) {
    return config.normalizedToMps(maxSpeed);
  }

  /// Get acceleration in m/s²
  double getAccelerationMps2(ScaleConfig config) {
    return config.normalizedToMps2(acceleration);
  }

  /// Get current velocity zone
  VelocityZone getVelocityZone(ScaleConfig config) {
    final mps = getVelocityYMps(config).abs();
    if (mps < 0.5) return VelocityZone.strength;
    if (mps < 0.75) return VelocityZone.strengthSpeed;
    if (mps < 1.0) return VelocityZone.power;
    if (mps < 1.3) return VelocityZone.speedStrength;
    return VelocityZone.speed;
  }

  /// Get path deviation in cm
  double getPathDeviationCm(ScaleConfig config) {
    return config.normalizedToCm(pathDeviation, vertical: false);
  }
}

/// Movement phase for rep detection
enum MovementPhase {
  idle,        // Not moving
  descending,  // Moving down (eccentric)
  ascending,   // Moving up (concentric)
  atBottom,    // At lowest point
  atTop,       // At highest point
}

/// Information about a single rep with detailed metrics
class RepInfo {
  final DateTime startTime;
  final DateTime endTime;
  final double duration; // seconds
  final double highY; // normalized
  final double lowY; // normalized
  final double romNormalized; // Range of motion

  // Velocity metrics (normalized)
  final double peakVelocity;
  final double meanVelocity;

  // Tempo metrics
  final double eccentricTime; // seconds
  final double concentricTime; // seconds

  // Path metrics
  final double pathDeviation;
  final double avgX;

  RepInfo({
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.highY,
    required this.lowY,
    required this.romNormalized,
    required this.peakVelocity,
    required this.meanVelocity,
    required this.eccentricTime,
    required this.concentricTime,
    required this.pathDeviation,
    required this.avgX,
  });

  /// Get ROM in cm
  double getRomCm(ScaleConfig config) {
    return config.normalizedToCm(romNormalized, vertical: true);
  }

  /// Get peak velocity in m/s
  double getPeakVelocityMps(ScaleConfig config) {
    return config.normalizedToMps(peakVelocity, vertical: true);
  }

  /// Get mean velocity in m/s
  double getMeanVelocityMps(ScaleConfig config) {
    return config.normalizedToMps(meanVelocity, vertical: true);
  }

  /// Tempo ratio (eccentric:concentric)
  String get tempoRatio {
    if (concentricTime <= 0) return '-';
    final ratio = eccentricTime / concentricTime;
    return '${ratio.toStringAsFixed(1)}:1';
  }
}

/// Set information for tracking multiple sets
class SetInfo {
  final int setNumber;
  final DateTime startTime;
  DateTime? endTime;
  final List<RepInfo> reps;

  SetInfo({
    required this.setNumber,
    required this.startTime,
  }) : reps = [];

  int get repCount => reps.length;

  double? get avgRepDuration {
    if (reps.isEmpty) return null;
    return reps.map((r) => r.duration).reduce((a, b) => a + b) / reps.length;
  }

  double? get avgPeakVelocity {
    if (reps.isEmpty) return null;
    return reps.map((r) => r.peakVelocity).reduce((a, b) => a + b) / reps.length;
  }

  double? get avgMeanVelocity {
    if (reps.isEmpty) return null;
    return reps.map((r) => r.meanVelocity).reduce((a, b) => a + b) / reps.length;
  }

  double? get velocityLoss {
    if (reps.length < 2) return null;
    final firstVel = reps.first.peakVelocity;
    final lastVel = reps.last.peakVelocity;
    if (firstVel <= 0) return null;
    return (firstVel - lastVel) / firstVel * 100; // Percentage
  }

  void finish() {
    endTime = DateTime.now();
  }
}

/// Exercise analyzer for rep counting and stats
class ExerciseAnalyzer {
  // Rep detection parameters
  final double minRepAmplitude; // Minimum Y movement for a rep (normalized)
  final double phaseChangeThreshold; // Velocity threshold for phase change
  final double idleThreshold; // Speed below this = idle

  // State
  MovementPhase _phase = MovementPhase.idle;
  double _highestY = 1; // Track highest point (smallest Y value)
  double _lowestY = 0; // Track lowest point (largest Y value)
  double _currentHighY = 1;
  double _currentLowY = 0;
  DateTime? _repStartTime;
  DateTime? _phaseStartTime;
  DateTime? _eccentricStartTime;
  DateTime? _concentricStartTime;
  double _eccentricTime = 0;

  // Statistics
  final List<RepInfo> _repHistory = [];
  double _maxSpeed = 0;
  double _lastSpeed = 0;

  // Current rep tracking
  double _currentRepPeakVelocity = 0;
  final List<double> _currentRepVelocities = [];
  final List<double> _currentRepXPositions = [];

  // Velocity history for smoothing
  final List<double> _velocityHistory = [];
  static const int velocityHistorySize = 5;

  // Set tracking
  final List<SetInfo> _sets = [];
  SetInfo? _currentSet;

  ExerciseAnalyzer({
    this.minRepAmplitude = 0.08, // 8% of screen height (~10cm)
    this.phaseChangeThreshold = 0.002, // Velocity threshold
    this.idleThreshold = 0.0008,
  });

  /// Start a new set
  void startNewSet() {
    _currentSet?.finish();
    _currentSet = SetInfo(
      setNumber: _sets.length + 1,
      startTime: DateTime.now(),
    );
    _sets.add(_currentSet!);
    _repHistory.clear();
    _maxSpeed = 0;
    _currentHighY = 1;
    _currentLowY = 0;
  }

  /// Finish current set
  void finishSet() {
    _currentSet?.finish();
    _currentSet = null;
  }

  /// Update with new position and velocity
  ExerciseStats update(double x, double y, double vy, double speed) {
    final now = DateTime.now();

    // Auto-start set if needed
    if (_currentSet == null && speed > idleThreshold) {
      startNewSet();
    }

    // Update velocity history for smoothing
    _velocityHistory.add(vy);
    if (_velocityHistory.length > velocityHistorySize) {
      _velocityHistory.removeAt(0);
    }

    // Smoothed velocity
    final smoothedVy = _velocityHistory.reduce((a, b) => a + b) / _velocityHistory.length;

    // Update max speed
    if (speed > _maxSpeed) _maxSpeed = speed;

    // Track current rep velocities and positions
    if (_repStartTime != null) {
      _currentRepVelocities.add(vy.abs());
      _currentRepXPositions.add(x);
      if (vy.abs() > _currentRepPeakVelocity) {
        _currentRepPeakVelocity = vy.abs();
      }
    }

    // Calculate acceleration
    final acceleration = (speed - _lastSpeed) * 30; // Per second (assuming 30fps)
    _lastSpeed = speed;

    // Update overall high/low
    if (y < _highestY) _highestY = y;
    if (y > _lowestY) _lowestY = y;

    // Update current rep high/low
    if (y < _currentHighY) _currentHighY = y;
    if (y > _currentLowY) _currentLowY = y;

    // Detect phase changes
    final previousPhase = _phase;

    if (speed < idleThreshold) {
      // Check if at extreme position
      if (_currentHighY < 1 && (y - _currentHighY).abs() < 0.02) {
        _phase = MovementPhase.atTop;
      } else if (_currentLowY > 0 && (y - _currentLowY).abs() < 0.02) {
        _phase = MovementPhase.atBottom;
      } else {
        _phase = MovementPhase.idle;
      }
    } else if (smoothedVy > phaseChangeThreshold) {
      // Moving down (Y increases) - eccentric
      _phase = MovementPhase.descending;
      if (y > _currentLowY) _currentLowY = y;
    } else if (smoothedVy < -phaseChangeThreshold) {
      // Moving up (Y decreases) - concentric
      _phase = MovementPhase.ascending;
      if (y < _currentHighY) _currentHighY = y;
    }

    // Track phase timing
    if (previousPhase != _phase) {
      if (_phase == MovementPhase.descending) {
        _eccentricStartTime = now;
      } else if (_phase == MovementPhase.ascending && _eccentricStartTime != null) {
        _eccentricTime = now.difference(_eccentricStartTime!).inMilliseconds / 1000.0;
        _concentricStartTime = now;
      }
    }

    // Detect rep completion
    if (previousPhase == MovementPhase.ascending &&
        (_phase == MovementPhase.atTop || _phase == MovementPhase.descending || _phase == MovementPhase.idle)) {
      // Completed upward phase - check if this was a valid rep
      final amplitude = _currentLowY - _currentHighY;
      if (amplitude >= minRepAmplitude && _repStartTime != null) {
        // Calculate rep metrics
        final duration = now.difference(_repStartTime!).inMilliseconds / 1000.0;
        final concentricTime = _concentricStartTime != null
            ? now.difference(_concentricStartTime!).inMilliseconds / 1000.0
            : duration / 2;

        final meanVelocity = _currentRepVelocities.isNotEmpty
            ? _currentRepVelocities.reduce((a, b) => a + b) / _currentRepVelocities.length
            : 0.0;

        final avgX = _currentRepXPositions.isNotEmpty
            ? _currentRepXPositions.reduce((a, b) => a + b) / _currentRepXPositions.length
            : 0.5;

        // Calculate path deviation (standard deviation of X positions)
        double pathDeviation = 0;
        if (_currentRepXPositions.length > 1) {
          final variance = _currentRepXPositions.map((x) => pow(x - avgX, 2)).reduce((a, b) => a + b) / _currentRepXPositions.length;
          pathDeviation = sqrt(variance);
        }

        final repInfo = RepInfo(
          startTime: _repStartTime!,
          endTime: now,
          duration: duration,
          highY: _currentHighY,
          lowY: _currentLowY,
          romNormalized: amplitude,
          peakVelocity: _currentRepPeakVelocity,
          meanVelocity: meanVelocity,
          eccentricTime: _eccentricTime,
          concentricTime: concentricTime,
          pathDeviation: pathDeviation,
          avgX: avgX,
        );

        _repHistory.add(repInfo);
        _currentSet?.reps.add(repInfo);

        // Reset for next rep
        _currentHighY = y;
        _currentLowY = y;
        _repStartTime = now;
        _currentRepPeakVelocity = 0;
        _currentRepVelocities.clear();
        _currentRepXPositions.clear();
      }
    }

    // Start tracking new rep on descent
    if (previousPhase != MovementPhase.descending && _phase == MovementPhase.descending) {
      if (_repStartTime == null) {
        _repStartTime = now;
        _currentHighY = y;
        _currentLowY = y;
        _currentRepPeakVelocity = 0;
        _currentRepVelocities.clear();
        _currentRepXPositions.clear();
      }
    }

    // Update phase start time
    if (_phase != previousPhase) {
      _phaseStartTime = now;
    }

    // Calculate averages
    double? avgDuration;
    if (_repHistory.isNotEmpty) {
      avgDuration = _repHistory.map((r) => r.duration).reduce((a, b) => a + b) / _repHistory.length;
    }

    // Calculate current path deviation
    double currentPathDeviation = 0;
    double currentAvgX = 0.5;
    if (_currentRepXPositions.isNotEmpty) {
      currentAvgX = _currentRepXPositions.reduce((a, b) => a + b) / _currentRepXPositions.length;
      if (_currentRepXPositions.length > 1) {
        final variance = _currentRepXPositions.map((px) => pow(px - currentAvgX, 2)).reduce((a, b) => a + b) / _currentRepXPositions.length;
        currentPathDeviation = sqrt(variance);
      }
    }

    // Current rep mean velocity
    final currentMeanVelocity = _currentRepVelocities.isNotEmpty
        ? _currentRepVelocities.reduce((a, b) => a + b) / _currentRepVelocities.length
        : null;

    // Concentric time (if in ascending phase)
    double? concentricTime;
    if (_phase == MovementPhase.ascending && _concentricStartTime != null) {
      concentricTime = now.difference(_concentricStartTime!).inMilliseconds / 1000.0;
    }

    return ExerciseStats(
      repCount: _repHistory.length,
      lastRepDuration: _repHistory.isNotEmpty ? _repHistory.last.duration : null,
      avgRepDuration: avgDuration,
      highestY: _highestY,
      lowestY: _lowestY,
      romNormalized: _lowestY - _highestY,
      currentSpeed: speed,
      currentVelocityY: vy,
      maxSpeed: _maxSpeed,
      acceleration: acceleration,
      phase: _phase,
      repHistory: List.from(_repHistory),
      pathDeviation: currentPathDeviation,
      avgPathX: currentAvgX,
      currentRepPeakVelocity: _currentRepPeakVelocity > 0 ? _currentRepPeakVelocity : null,
      currentRepMeanVelocity: currentMeanVelocity,
      eccentricTime: _eccentricTime > 0 ? _eccentricTime : null,
      concentricTime: concentricTime,
    );
  }

  /// Reset all stats
  void reset() {
    _phase = MovementPhase.idle;
    _highestY = 1;
    _lowestY = 0;
    _currentHighY = 1;
    _currentLowY = 0;
    _repStartTime = null;
    _phaseStartTime = null;
    _eccentricStartTime = null;
    _concentricStartTime = null;
    _eccentricTime = 0;
    _repHistory.clear();
    _maxSpeed = 0;
    _lastSpeed = 0;
    _currentRepPeakVelocity = 0;
    _currentRepVelocities.clear();
    _currentRepXPositions.clear();
    _velocityHistory.clear();
    _sets.clear();
    _currentSet = null;
  }

  /// Get current phase
  MovementPhase get phase => _phase;

  /// Get rep count
  int get repCount => _repHistory.length;

  /// Get all sets
  List<SetInfo> get sets => List.from(_sets);

  /// Get current set
  SetInfo? get currentSet => _currentSet;

  /// Get phase start time (for timing displays)
  DateTime? get phaseStartTime => _phaseStartTime;
}

/// Path smoother using moving average
class PathSmoother {
  final int windowSize;
  final double outlierThreshold; // Distance threshold for outlier detection
  final double minMovementThreshold; // Minimum movement to record

  final List<TrackPoint> _rawPoints = [];
  final List<TrackPoint> _smoothedPoints = [];

  PathSmoother({
    this.windowSize = 5,
    this.outlierThreshold = 0.15, // 15% of screen
    this.minMovementThreshold = 0.002, // 0.2% of screen
  });

  /// Add a new point and get smoothed result
  TrackPoint? addPoint(TrackPoint point) {
    // Check for outlier
    if (_rawPoints.isNotEmpty) {
      final last = _rawPoints.last;
      final distance = sqrt(pow(point.x - last.x, 2) + pow(point.y - last.y, 2));

      // Reject outlier (too far from last point in single frame)
      if (distance > outlierThreshold) {
        return null;
      }

      // Reject if movement too small (noise)
      if (distance < minMovementThreshold && !point.isPredicted) {
        // Still add to raw for averaging, but don't create new smoothed point
        _rawPoints.add(point);
        if (_rawPoints.length > windowSize * 2) {
          _rawPoints.removeAt(0);
        }
        return _smoothedPoints.isNotEmpty ? _smoothedPoints.last : null;
      }
    }

    _rawPoints.add(point);

    // Keep raw buffer limited
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

    // Not enough points for smoothing yet
    _smoothedPoints.add(point);
    return point;
  }

  /// Get all smoothed points
  List<TrackPoint> get smoothedPath => List.from(_smoothedPoints);

  /// Clear all points
  void clear() {
    _rawPoints.clear();
    _smoothedPoints.clear();
  }

  /// Limit path length
  void limitLength(int maxLength) {
    while (_smoothedPoints.length > maxLength) {
      _smoothedPoints.removeAt(0);
    }
  }
}

/// ByteTrack-style tracker for single object (barbell)
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

    // Update exercise analyzer with X position too
    final exerciseStats = _exerciseAnalyzer.update(
      _track!.position[0], // X position
      _track!.position[1], // Y position
      _track!.velocity[1], // Y velocity
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

  void reset() {
    _track = null;
    _path.clear();
    _smoother.clear();
    _exerciseAnalyzer.reset();
  }

  List<TrackPoint> get path => List.from(_path);

  void clearPath() {
    _path.clear();
    _smoother.clear();
  }

  void resetExerciseStats() {
    _exerciseAnalyzer.reset();
  }

  void startNewSet() {
    _exerciseAnalyzer.startNewSet();
    clearPath();
  }

  void finishSet() {
    _exerciseAnalyzer.finishSet();
  }

  ExerciseStats get exerciseStats {
    if (_track == null) return ExerciseStats.empty();
    return _exerciseAnalyzer.update(
      _track!.position[0],
      _track!.position[1],
      _track!.velocity[1],
      _track!.speed,
    );
  }

  List<SetInfo> get sets => _exerciseAnalyzer.sets;
  SetInfo? get currentSet => _exerciseAnalyzer.currentSet;
}

/// Single point in track path
class TrackPoint {
  final double x;
  final double y;
  final double confidence;
  final bool isPredicted;
  final DateTime timestamp;

  TrackPoint({
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
  double get velocityYMps => scaleConfig.normalizedToMps(vy, vertical: true);

  /// Get velocity zone
  VelocityZone get velocityZone => getVelocityZone(velocityYMps);
}
