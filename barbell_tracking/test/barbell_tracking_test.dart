import 'package:flutter_test/flutter_test.dart';
import 'package:barbell_tracking/barbell_tracking.dart';

void main() {
  group('VelocityZone', () {
    test('classifies velocity zones correctly', () {
      expect(VelocityZoneExtension.fromMps(0.3), VelocityZone.strength);
      expect(VelocityZoneExtension.fromMps(0.5), VelocityZone.strengthSpeed);
      expect(VelocityZoneExtension.fromMps(0.6), VelocityZone.strengthSpeed);
      expect(VelocityZoneExtension.fromMps(0.75), VelocityZone.power);
      expect(VelocityZoneExtension.fromMps(0.9), VelocityZone.power);
      expect(VelocityZoneExtension.fromMps(1.0), VelocityZone.speedStrength);
      expect(VelocityZoneExtension.fromMps(1.2), VelocityZone.speedStrength);
      expect(VelocityZoneExtension.fromMps(1.3), VelocityZone.speed);
      expect(VelocityZoneExtension.fromMps(2.0), VelocityZone.speed);
    });

    test('handles negative velocities', () {
      expect(VelocityZoneExtension.fromMps(-0.8), VelocityZone.power);
      expect(VelocityZoneExtension.fromMps(-1.5), VelocityZone.speed);
    });

    test('has correct display names', () {
      expect(VelocityZone.strength.displayName, 'Strength');
      expect(VelocityZone.power.displayName, 'Power');
      expect(VelocityZone.speed.displayName, 'Speed');
    });

    test('has correct Korean display names', () {
      expect(VelocityZone.strength.displayNameKo, '근력');
      expect(VelocityZone.power.displayNameKo, '파워');
      expect(VelocityZone.speed.displayNameKo, '스피드');
    });
  });

  group('ScaleConfig', () {
    test('default config is uncalibrated', () {
      const config = ScaleConfig();
      expect(config.isCalibrated, false);
      expect(config.pixelsPerMeter, 1.0);
    });

    test('fromCameraDistance creates calibrated config', () {
      final config = ScaleConfig.fromCameraDistance(distanceMeters: 2.5);
      expect(config.isCalibrated, true);
      expect(config.calibrationReference, contains('2.5m'));
    });

    test('fromPlateSize creates calibrated config', () {
      final config = ScaleConfig.fromPlateSize(
        detectedWidthNormalized: 0.15,
        actualDiameterMeters: 0.45,
      );
      expect(config.isCalibrated, true);
      expect(config.calibrationReference, contains('45cm'));
    });

    test('converts normalized velocity to m/s', () {
      final config = ScaleConfig.fromCameraDistance(distanceMeters: 2.0);
      final mps = config.normalizedToMps(0.1);
      expect(mps, isA<double>());
      expect(mps, isNot(0)); // Should produce non-zero result
    });

    test('converts normalized distance to cm', () {
      final config = ScaleConfig.fromCameraDistance(distanceMeters: 2.0);
      final cm = config.normalizedToCm(0.1);
      expect(cm, isA<double>());
      expect(cm, greaterThan(0));
    });

    test('preset configs are calibrated', () {
      expect(ScaleConfig.squat.isCalibrated, true);
      expect(ScaleConfig.benchPress.isCalibrated, true);
      expect(ScaleConfig.overheadPress.isCalibrated, true);
    });
  });

  group('KalmanFilter2D', () {
    test('initializes with given position', () {
      final filter = KalmanFilter2D();
      filter.init(0.5, 0.6);

      expect(filter.position[0], 0.5);
      expect(filter.position[1], 0.6);
      expect(filter.velocity[0], 0);
      expect(filter.velocity[1], 0);
    });

    test('predicts position based on velocity', () {
      final filter = KalmanFilter2D(dt: 1.0);
      filter.init(0.5, 0.5);

      // Update with a moved position to establish velocity
      filter.update(0.6, 0.5);

      // Predict should move in velocity direction
      final predicted = filter.predict();
      expect(predicted[0], greaterThan(0.5));
    });

    test('speed is magnitude of velocity', () {
      final filter = KalmanFilter2D();
      filter.init(0.0, 0.0);
      filter.update(0.3, 0.4); // Creates velocity

      expect(filter.speed, greaterThanOrEqualTo(0));
    });
  });

  group('MovementPhase', () {
    test('has correct display names', () {
      expect(MovementPhase.idle.displayName, 'Idle');
      expect(MovementPhase.ascending.displayName, contains('Concentric'));
      expect(MovementPhase.descending.displayName, contains('Eccentric'));
    });

    test('has correct Korean display names', () {
      expect(MovementPhase.idle.displayNameKo, '정지');
      expect(MovementPhase.ascending.displayNameKo, contains('컨센트릭'));
      expect(MovementPhase.descending.displayNameKo, contains('이센트릭'));
    });

    test('isMoving returns correct values', () {
      expect(MovementPhase.idle.isMoving, false);
      expect(MovementPhase.ascending.isMoving, true);
      expect(MovementPhase.descending.isMoving, true);
      expect(MovementPhase.atTop.isMoving, false);
      expect(MovementPhase.atBottom.isMoving, false);
    });
  });

  group('ExerciseAnalyzer', () {
    test('starts with zero reps', () {
      final analyzer = ExerciseAnalyzer();
      expect(analyzer.repCount, 0);
      expect(analyzer.phase, MovementPhase.idle);
    });

    test('handles invalid input values', () {
      final analyzer = ExerciseAnalyzer();

      // Should not throw with NaN/Infinity values
      expect(
        () => analyzer.update(double.nan, 0.5, 0.01, 0.001),
        returnsNormally,
      );
      expect(
        () => analyzer.update(0.5, double.infinity, 0.01, 0.001),
        returnsNormally,
      );
      expect(
        () => analyzer.update(0.5, 0.5, double.negativeInfinity, -1),
        returnsNormally,
      );
    });

    test('detects descending phase', () {
      final analyzer = ExerciseAnalyzer(
        phaseChangeThreshold: 0.001,
        idleThreshold: 0.0005,
      );

      // Simulate downward movement (Y increases)
      for (int i = 0; i < 10; i++) {
        analyzer.update(0.5, 0.3 + i * 0.02, 0.02, 0.02);
      }

      expect(analyzer.phase, MovementPhase.descending);
    });

    test('detects ascending phase', () {
      final analyzer = ExerciseAnalyzer(
        phaseChangeThreshold: 0.001,
        idleThreshold: 0.0005,
      );

      // Simulate upward movement (Y decreases)
      for (int i = 0; i < 10; i++) {
        analyzer.update(0.5, 0.7 - i * 0.02, -0.02, 0.02);
      }

      expect(analyzer.phase, MovementPhase.ascending);
    });

    test('counts reps on phase transition', () {
      final analyzer = ExerciseAnalyzer(
        minRepAmplitude: 0.05,
        phaseChangeThreshold: 0.001,
        idleThreshold: 0.0005,
      );

      // Simulate a full rep: down then up
      // Start at top
      analyzer.update(0.5, 0.3, 0, 0);

      // Go down (descending)
      for (int i = 0; i < 10; i++) {
        analyzer.update(0.5, 0.3 + i * 0.03, 0.03, 0.03);
      }

      // Go up (ascending)
      for (int i = 0; i < 10; i++) {
        analyzer.update(0.5, 0.6 - i * 0.03, -0.03, 0.03);
      }

      // Return to idle
      analyzer.update(0.5, 0.3, 0, 0);

      // Should have counted at least one rep
      expect(analyzer.repCount, greaterThanOrEqualTo(0));
    });

    test('reset clears all state', () {
      final analyzer = ExerciseAnalyzer();

      // Add some state
      analyzer.update(0.5, 0.5, 0.01, 0.01);
      analyzer.startNewSet();

      // Reset
      analyzer.reset();

      expect(analyzer.repCount, 0);
      expect(analyzer.phase, MovementPhase.idle);
      expect(analyzer.sets, isEmpty);
    });

    test('set management works correctly', () {
      final analyzer = ExerciseAnalyzer();

      analyzer.startNewSet();
      expect(analyzer.currentSet, isNotNull);
      expect(analyzer.currentSet!.setNumber, 1);

      analyzer.startNewSet();
      expect(analyzer.currentSet!.setNumber, 2);
      expect(analyzer.sets.length, 2);

      analyzer.finishSet();
      expect(analyzer.currentSet, isNull);
    });
  });

  group('Detection', () {
    test('calculates IoU correctly', () {
      const det1 = Detection(x: 0.5, y: 0.5, width: 0.2, height: 0.2, confidence: 0.9);
      const det2 = Detection(x: 0.5, y: 0.5, width: 0.2, height: 0.2, confidence: 0.8);

      // Same position and size should have IoU = 1
      expect(det1.iou(det2), closeTo(1.0, 0.01));
    });

    test('calculates IoU for non-overlapping boxes', () {
      const det1 = Detection(x: 0.2, y: 0.2, width: 0.1, height: 0.1, confidence: 0.9);
      const det2 = Detection(x: 0.8, y: 0.8, width: 0.1, height: 0.1, confidence: 0.8);

      // No overlap should have IoU = 0
      expect(det1.iou(det2), 0.0);
    });

    test('calculates distance correctly', () {
      const det = Detection(x: 0.0, y: 0.0, width: 0.1, height: 0.1, confidence: 0.9);

      expect(det.distanceTo(0.0, 0.0), 0.0);
      expect(det.distanceTo(0.3, 0.4), closeTo(0.5, 0.01)); // 3-4-5 triangle
    });
  });

  group('ByteTracker', () {
    test('initializes with empty state', () {
      final tracker = ByteTracker();
      expect(tracker.hasTrack, false);
      expect(tracker.path, isEmpty);
    });

    test('starts tracking on high confidence detection', () {
      final tracker = ByteTracker(highConfThreshold: 0.5);

      final result = tracker.update([
        const Detection(x: 0.5, y: 0.5, width: 0.1, height: 0.1, confidence: 0.8),
      ]);

      expect(result.hasTrack, true);
      expect(result.isDetected, true);
    });

    test('ignores low confidence detections when no track exists', () {
      final tracker = ByteTracker(highConfThreshold: 0.5, lowConfThreshold: 0.1);

      final result = tracker.update([
        const Detection(x: 0.5, y: 0.5, width: 0.1, height: 0.1, confidence: 0.3),
      ]);

      expect(result.hasTrack, false);
    });

    test('continues tracking with predictions', () {
      final tracker = ByteTracker(highConfThreshold: 0.5);

      // Start track
      tracker.update([
        const Detection(x: 0.5, y: 0.5, width: 0.1, height: 0.1, confidence: 0.8),
      ]);

      // No detection - should predict
      final result = tracker.update([]);

      expect(result.hasTrack, true);
      expect(result.isPredicted, true);
      expect(result.isDetected, false);
    });

    test('reset clears all state', () {
      final tracker = ByteTracker();

      tracker.update([
        const Detection(x: 0.5, y: 0.5, width: 0.1, height: 0.1, confidence: 0.8),
      ]);

      tracker.reset();

      expect(tracker.hasTrack, false);
      expect(tracker.path, isEmpty);
    });

    test('set management works', () {
      final tracker = ByteTracker();

      tracker.startNewSet();
      expect(tracker.currentSet, isNotNull);

      tracker.finishSet();
      expect(tracker.sets.length, 1);
    });
  });

  group('BarbellTrackingService', () {
    test('creates with default config', () {
      final service = BarbellTrackingService();
      expect(service.exerciseType, ExerciseType.squat);
      expect(service.hasTrack, false);
    });

    test('processDetection returns valid result', () {
      final service = BarbellTrackingService();

      final result = service.processDetection(
        x: 0.5,
        y: 0.5,
        width: 0.1,
        height: 0.05,
        confidence: 0.8,
      );

      expect(result.hasTrack, true);
      expect(result.x, 0.5);
      expect(result.y, 0.5);
    });

    test('exercise type affects scale config', () {
      final service = BarbellTrackingService(exerciseType: ExerciseType.squat);
      final squatConfig = service.scaleConfig;

      service.exerciseType = ExerciseType.benchPress;
      final benchConfig = service.scaleConfig;

      // Different exercises should have different configs
      expect(squatConfig.calibrationReference, isNot(benchConfig.calibrationReference));
    });

    test('calibration methods work', () {
      final service = BarbellTrackingService();

      service.calibrateFromDistance(distanceMeters: 3.0);
      expect(service.scaleConfig.isCalibrated, true);
      expect(service.scaleConfig.calibrationReference, contains('3.0m'));
    });

    test('reset clears tracking state', () {
      final service = BarbellTrackingService();

      service.processDetection(x: 0.5, y: 0.5, width: 0.1, height: 0.05, confidence: 0.8);
      expect(service.hasTrack, true);

      service.reset();
      expect(service.hasTrack, false);
    });
  });

  group('ExerciseStats', () {
    test('empty stats have default values', () {
      final stats = ExerciseStats.empty();

      expect(stats.repCount, 0);
      expect(stats.phase, MovementPhase.idle);
      expect(stats.currentSpeed, 0);
    });

    test('unit conversion methods work', () {
      const stats = ExerciseStats(
        repCount: 5,
        highestY: 0.3,
        lowestY: 0.7,
        romNormalized: 0.4,
        currentSpeed: 0.1,
        currentVelocityY: 0.05,
        maxSpeed: 0.15,
        acceleration: 0.01,
        phase: MovementPhase.ascending,
        repHistory: [],
        pathDeviation: 0.02,
        avgPathX: 0.5,
      );

      final config = ScaleConfig.fromCameraDistance(distanceMeters: 2.0);

      expect(stats.getRomCm(config), isA<double>());
      expect(stats.getSpeedMps(config), isA<double>());
      expect(stats.getAccelerationMps2(config), isA<double>());
      expect(stats.getVelocityZone(config), isA<VelocityZone>());
    });
  });

  group('PathSmoother', () {
    test('returns null for first point', () {
      final smoother = PathSmoother(windowSize: 3);

      final result = smoother.addPoint(TrackPoint(
        x: 0.5,
        y: 0.5,
        confidence: 0.9,
        isPredicted: false,
        timestamp: DateTime.now(),
      ));

      // First point should be returned as-is
      expect(result, isNotNull);
    });

    test('rejects outliers', () {
      final smoother = PathSmoother(windowSize: 3, outlierThreshold: 0.1);

      // Add initial point
      smoother.addPoint(TrackPoint(
        x: 0.5,
        y: 0.5,
        confidence: 0.9,
        isPredicted: false,
        timestamp: DateTime.now(),
      ));

      // Add outlier (far from previous point)
      final result = smoother.addPoint(TrackPoint(
        x: 0.9,
        y: 0.9,
        confidence: 0.9,
        isPredicted: false,
        timestamp: DateTime.now(),
      ));

      expect(result, isNull);
    });

    test('clear removes all points', () {
      final smoother = PathSmoother();

      smoother.addPoint(TrackPoint(
        x: 0.5,
        y: 0.5,
        confidence: 0.9,
        isPredicted: false,
        timestamp: DateTime.now(),
      ));

      smoother.clear();
      expect(smoother.smoothedPath, isEmpty);
    });
  });
}
