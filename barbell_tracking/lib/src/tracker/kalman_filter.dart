import 'dart:math';

/// 2D Kalman Filter for position and velocity tracking
/// State: [x, y, vx, vy] (position and velocity)
class KalmanFilter2D {
  List<double> _state;
  List<List<double>> _covariance;

  final double _processNoise;
  final double _measurementNoise;
  final double _dt;

  KalmanFilter2D({
    double dt = 1.0 / 30.0,
    double processNoise = 0.01,
    double measurementNoise = 0.1,
  })  : _dt = dt,
        _processNoise = processNoise,
        _measurementNoise = measurementNoise,
        _state = [0, 0, 0, 0],
        _covariance = _identityMatrix(4, scale: 1.0);

  /// Initialize with first measurement
  void init(double x, double y) {
    _state = [x, y, 0, 0];
    _covariance = _identityMatrix(4, scale: 1.0);
  }

  /// Predict next state
  List<double> predict() {
    final x = _state[0] + _state[2] * _dt;
    final y = _state[1] + _state[3] * _dt;
    final vx = _state[2];
    final vy = _state[3];
    _state = [x, y, vx, vy];

    final F = [
      [1.0, 0.0, _dt, 0.0],
      [0.0, 1.0, 0.0, _dt],
      [0.0, 0.0, 1.0, 0.0],
      [0.0, 0.0, 0.0, 1.0],
    ];

    final Q = _identityMatrix(4, scale: _processNoise);
    _covariance = _addMatrix(
      _multiplyMatrix(_multiplyMatrix(F, _covariance), _transposeMatrix(F)),
      Q,
    );

    return [_state[0], _state[1]];
  }

  /// Update with measurement
  void update(double x, double y) {
    final residual = [x - _state[0], y - _state[1]];

    final S = [
      [_covariance[0][0] + _measurementNoise, _covariance[0][1]],
      [_covariance[1][0], _covariance[1][1] + _measurementNoise],
    ];

    final sInv = _invertMatrix2x2(S);
    final pHt = [
      [_covariance[0][0], _covariance[0][1]],
      [_covariance[1][0], _covariance[1][1]],
      [_covariance[2][0], _covariance[2][1]],
      [_covariance[3][0], _covariance[3][1]],
    ];
    final K = _multiplyMatrix(pHt, sInv);

    _state[0] += K[0][0] * residual[0] + K[0][1] * residual[1];
    _state[1] += K[1][0] * residual[0] + K[1][1] * residual[1];
    _state[2] += K[2][0] * residual[0] + K[2][1] * residual[1];
    _state[3] += K[3][0] * residual[0] + K[3][1] * residual[1];

    final kh = [
      [K[0][0], K[0][1], 0.0, 0.0],
      [K[1][0], K[1][1], 0.0, 0.0],
      [K[2][0], K[2][1], 0.0, 0.0],
      [K[3][0], K[3][1], 0.0, 0.0],
    ];
    final iMinusKH = _subtractMatrix(_identityMatrix(4), kh);
    _covariance = _multiplyMatrix(iMinusKH, _covariance);
  }

  /// Current estimated position
  List<double> get position => [_state[0], _state[1]];

  /// Current estimated velocity
  List<double> get velocity => [_state[2], _state[3]];

  /// Speed magnitude
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
      return [[1, 0], [0, 1]];
    }
    return [
      [m[1][1] / det, -m[0][1] / det],
      [-m[1][0] / det, m[0][0] / det],
    ];
  }
}
