import 'dart:math';

import 'package:flutter/material.dart';

import '../scale/scale_config.dart';
import 'vbt_zones.dart';

/// Movement phase for rep detection
enum MovementPhase {
  idle,
  descending,
  ascending,
  atBottom,
  atTop,
}

/// Extension for MovementPhase display properties
extension MovementPhaseExtension on MovementPhase {
  /// Display name in English
  String get displayName {
    switch (this) {
      case MovementPhase.idle:
        return 'Idle';
      case MovementPhase.ascending:
        return 'Ascending (Concentric)';
      case MovementPhase.descending:
        return 'Descending (Eccentric)';
      case MovementPhase.atTop:
        return 'At Top';
      case MovementPhase.atBottom:
        return 'At Bottom';
    }
  }

  /// Display name in Korean
  String get displayNameKo {
    switch (this) {
      case MovementPhase.idle:
        return '정지';
      case MovementPhase.ascending:
        return '상승 (컨센트릭)';
      case MovementPhase.descending:
        return '하강 (이센트릭)';
      case MovementPhase.atTop:
        return '최고점';
      case MovementPhase.atBottom:
        return '최저점';
    }
  }

  /// Phase color for UI
  Color get color {
    switch (this) {
      case MovementPhase.idle:
        return Colors.grey;
      case MovementPhase.ascending:
        return Colors.green;
      case MovementPhase.descending:
        return Colors.orange;
      case MovementPhase.atTop:
        return Colors.cyan;
      case MovementPhase.atBottom:
        return Colors.purple;
    }
  }

  /// Whether this phase represents active movement
  bool get isMoving => this == MovementPhase.ascending || this == MovementPhase.descending;
}

/// Information about a single rep
class RepInfo {
  final DateTime startTime;
  final DateTime endTime;
  final double duration;
  final double highY;
  final double lowY;
  final double romNormalized;
  final double peakVelocity;
  final double meanVelocity;
  final double eccentricTime;
  final double concentricTime;
  final double pathDeviation;
  final double avgX;

  const RepInfo({
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

  double getRomCm(ScaleConfig config) {
    return config.normalizedToCm(romNormalized);
  }

  double getPeakVelocityMps(ScaleConfig config) {
    return config.normalizedToMps(peakVelocity);
  }

  double getMeanVelocityMps(ScaleConfig config) {
    return config.normalizedToMps(meanVelocity);
  }

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
    return (firstVel - lastVel) / firstVel * 100;
  }

  void finish() {
    endTime = DateTime.now();
  }
}

/// Exercise statistics
class ExerciseStats {
  final int repCount;
  final double? lastRepDuration;
  final double? avgRepDuration;
  final double highestY;
  final double lowestY;
  final double romNormalized;
  final double currentSpeed;
  final double currentVelocityY;
  final double maxSpeed;
  final double acceleration;
  final MovementPhase phase;
  final List<RepInfo> repHistory;
  final double pathDeviation;
  final double avgPathX;
  final double? currentRepPeakVelocity;
  final double? currentRepMeanVelocity;
  final double? eccentricTime;
  final double? concentricTime;

  const ExerciseStats({
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

  factory ExerciseStats.empty() => const ExerciseStats(
    repCount: 0,
    highestY: 1,
    lowestY: 0,
    romNormalized: 0,
    currentSpeed: 0,
    currentVelocityY: 0,
    maxSpeed: 0,
    acceleration: 0,
    phase: MovementPhase.idle,
    repHistory: [],
    pathDeviation: 0,
    avgPathX: 0.5,
  );

  double getRomCm(ScaleConfig config) {
    return config.normalizedToCm(romNormalized);
  }

  double getSpeedMps(ScaleConfig config) {
    return config.normalizedToMps(currentSpeed);
  }

  double getVelocityYMps(ScaleConfig config) {
    return config.normalizedToMps(currentVelocityY);
  }

  double getMaxSpeedMps(ScaleConfig config) {
    return config.normalizedToMps(maxSpeed);
  }

  double getAccelerationMps2(ScaleConfig config) {
    return config.normalizedToMps2(acceleration);
  }

  VelocityZone getVelocityZone(ScaleConfig config) {
    final mps = getVelocityYMps(config).abs();
    return VelocityZoneExtension.fromMps(mps);
  }

  double getPathDeviationCm(ScaleConfig config) {
    return config.normalizedToCm(pathDeviation);
  }
}

/// Exercise analyzer for rep counting and stats
class ExerciseAnalyzer {
  final double minRepAmplitude;
  final double phaseChangeThreshold;
  final double idleThreshold;

  MovementPhase _phase = MovementPhase.idle;
  double _highestY = 1;
  double _lowestY = 0;
  double _currentHighY = 1;
  double _currentLowY = 0;
  DateTime? _repStartTime;
  DateTime? _phaseStartTime;
  DateTime? _eccentricStartTime;
  DateTime? _concentricStartTime;
  double _eccentricTime = 0;

  final List<RepInfo> _repHistory = [];
  double _maxSpeed = 0;
  double _lastSpeed = 0;
  double _currentRepPeakVelocity = 0;
  final List<double> _currentRepVelocities = [];
  final List<double> _currentRepXPositions = [];
  final List<double> _velocityHistory = [];
  static const int velocityHistorySize = 5;

  final List<SetInfo> _sets = [];
  SetInfo? _currentSet;

  ExerciseAnalyzer({
    this.minRepAmplitude = 0.08,
    this.phaseChangeThreshold = 0.002,
    this.idleThreshold = 0.0008,
  });

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

  void finishSet() {
    _currentSet?.finish();
    _currentSet = null;
  }

  ExerciseStats update(double x, double y, double vy, double speed) {
    // Guard against invalid input values
    if (x.isNaN || x.isInfinite) x = 0.5;
    if (y.isNaN || y.isInfinite) y = 0.5;
    if (vy.isNaN || vy.isInfinite) vy = 0;
    if (speed.isNaN || speed.isInfinite || speed < 0) speed = 0;

    final now = DateTime.now();

    if (_currentSet == null && speed > idleThreshold) {
      startNewSet();
    }

    _velocityHistory.add(vy);
    if (_velocityHistory.length > velocityHistorySize) {
      _velocityHistory.removeAt(0);
    }

    final smoothedVy = _velocityHistory.isNotEmpty
        ? _velocityHistory.reduce((a, b) => a + b) / _velocityHistory.length
        : 0.0;

    if (speed > _maxSpeed) _maxSpeed = speed;

    if (_repStartTime != null) {
      _currentRepVelocities.add(vy.abs());
      _currentRepXPositions.add(x);
      if (vy.abs() > _currentRepPeakVelocity) {
        _currentRepPeakVelocity = vy.abs();
      }
    }

    final acceleration = (speed - _lastSpeed) * 30;
    _lastSpeed = speed;

    if (y < _highestY) _highestY = y;
    if (y > _lowestY) _lowestY = y;
    if (y < _currentHighY) _currentHighY = y;
    if (y > _currentLowY) _currentLowY = y;

    final previousPhase = _phase;

    if (speed < idleThreshold) {
      if (_currentHighY < 1 && (y - _currentHighY).abs() < 0.02) {
        _phase = MovementPhase.atTop;
      } else if (_currentLowY > 0 && (y - _currentLowY).abs() < 0.02) {
        _phase = MovementPhase.atBottom;
      } else {
        _phase = MovementPhase.idle;
      }
    } else if (smoothedVy > phaseChangeThreshold) {
      _phase = MovementPhase.descending;
      if (y > _currentLowY) _currentLowY = y;
    } else if (smoothedVy < -phaseChangeThreshold) {
      _phase = MovementPhase.ascending;
      if (y < _currentHighY) _currentHighY = y;
    }

    if (previousPhase != _phase) {
      if (_phase == MovementPhase.descending) {
        _eccentricStartTime = now;
      } else if (_phase == MovementPhase.ascending && _eccentricStartTime != null) {
        _eccentricTime = now.difference(_eccentricStartTime!).inMilliseconds / 1000.0;
        _concentricStartTime = now;
      }
    }

    if (previousPhase == MovementPhase.ascending &&
        (_phase == MovementPhase.atTop || _phase == MovementPhase.descending || _phase == MovementPhase.idle)) {
      final amplitude = _currentLowY - _currentHighY;
      if (amplitude >= minRepAmplitude && _repStartTime != null) {
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

        double pathDeviation = 0;
        if (_currentRepXPositions.length > 1) {
          final variance = _currentRepXPositions.map((px) => pow(px - avgX, 2)).reduce((a, b) => a + b) / _currentRepXPositions.length;
          pathDeviation = variance > 0 ? sqrt(variance) : 0;
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

        _currentHighY = y;
        _currentLowY = y;
        _repStartTime = now;
        _currentRepPeakVelocity = 0;
        _currentRepVelocities.clear();
        _currentRepXPositions.clear();
      }
    }

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

    if (_phase != previousPhase) {
      _phaseStartTime = now;
    }

    double? avgDuration;
    if (_repHistory.isNotEmpty) {
      avgDuration = _repHistory.map((r) => r.duration).reduce((a, b) => a + b) / _repHistory.length;
    }

    double currentPathDeviation = 0;
    double currentAvgX = 0.5;
    if (_currentRepXPositions.isNotEmpty) {
      currentAvgX = _currentRepXPositions.reduce((a, b) => a + b) / _currentRepXPositions.length;
      if (_currentRepXPositions.length > 1) {
        final variance = _currentRepXPositions.map((px) => pow(px - currentAvgX, 2)).reduce((a, b) => a + b) / _currentRepXPositions.length;
        currentPathDeviation = variance > 0 ? sqrt(variance) : 0;
      }
    }

    final currentMeanVelocity = _currentRepVelocities.isNotEmpty
        ? _currentRepVelocities.reduce((a, b) => a + b) / _currentRepVelocities.length
        : null;

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

  MovementPhase get phase => _phase;
  int get repCount => _repHistory.length;
  List<SetInfo> get sets => List.from(_sets);
  SetInfo? get currentSet => _currentSet;
  DateTime? get phaseStartTime => _phaseStartTime;
}
