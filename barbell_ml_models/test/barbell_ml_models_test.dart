import 'package:flutter_test/flutter_test.dart';
import 'package:barbell_ml_models/barbell_ml_models.dart';

void main() {
  group('BarbellModelConfig', () {
    test('has correct input size', () {
      expect(BarbellModelConfig.inputSize, 640);
    });

    test('has correct number of classes', () {
      expect(BarbellModelConfig.numClasses, 1);
    });

    test('has barbell label', () {
      expect(BarbellModelConfig.labels, contains('barbell'));
    });

    test('has valid confidence threshold', () {
      expect(BarbellModelConfig.defaultConfidenceThreshold, greaterThan(0));
      expect(BarbellModelConfig.defaultConfidenceThreshold, lessThan(1));
    });
  });

  group('BarbellDetection', () {
    test('creates from constructor', () {
      final det = BarbellDetection(
        x: 0.5,
        y: 0.5,
        width: 0.1,
        height: 0.05,
        confidence: 0.9,
      );
      expect(det.x, 0.5);
      expect(det.confidence, 0.9);
    });

    test('converts to and from map', () {
      final det = BarbellDetection(
        x: 0.3,
        y: 0.7,
        width: 0.2,
        height: 0.1,
        confidence: 0.85,
      );
      final map = det.toMap();
      final restored = BarbellDetection.fromMap(map);
      expect(restored.x, det.x);
      expect(restored.y, det.y);
      expect(restored.confidence, det.confidence);
    });

    test('calculates IoU correctly', () {
      final a = BarbellDetection(x: 0.5, y: 0.5, width: 0.2, height: 0.2, confidence: 0.9);
      final b = BarbellDetection(x: 0.5, y: 0.5, width: 0.2, height: 0.2, confidence: 0.8);
      expect(a.iou(b), closeTo(1.0, 0.001));

      final c = BarbellDetection(x: 0.9, y: 0.9, width: 0.1, height: 0.1, confidence: 0.7);
      expect(a.iou(c), closeTo(0.0, 0.001));
    });

    test('calculates bbox correctly', () {
      final det = BarbellDetection(x: 0.5, y: 0.5, width: 0.2, height: 0.1, confidence: 0.9);
      expect(det.bbox[0], closeTo(0.4, 0.001)); // left
      expect(det.bbox[1], closeTo(0.45, 0.001)); // top
      expect(det.bbox[2], closeTo(0.6, 0.001)); // right
      expect(det.bbox[3], closeTo(0.55, 0.001)); // bottom
    });
  });

  group('NMS', () {
    test('removes overlapping detections', () {
      final detections = [
        BarbellDetection(x: 0.5, y: 0.5, width: 0.2, height: 0.2, confidence: 0.9),
        BarbellDetection(x: 0.51, y: 0.51, width: 0.2, height: 0.2, confidence: 0.8),
        BarbellDetection(x: 0.52, y: 0.52, width: 0.2, height: 0.2, confidence: 0.7),
      ];
      final result = nms(detections);
      expect(result.length, 1);
      expect(result.first.confidence, 0.9);
    });

    test('keeps non-overlapping detections', () {
      final detections = [
        BarbellDetection(x: 0.2, y: 0.2, width: 0.1, height: 0.1, confidence: 0.9),
        BarbellDetection(x: 0.8, y: 0.8, width: 0.1, height: 0.1, confidence: 0.85),
      ];
      final result = nms(detections);
      expect(result.length, 2);
    });

    test('filters by confidence threshold', () {
      final detections = [
        BarbellDetection(x: 0.5, y: 0.5, width: 0.2, height: 0.2, confidence: 0.1),
        BarbellDetection(x: 0.3, y: 0.3, width: 0.2, height: 0.2, confidence: 0.05),
      ];
      final result = nms(detections, confidenceThreshold: 0.25);
      expect(result.length, 0);
    });
  });
}
