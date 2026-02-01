# Barbell Tracking

Real-time barbell path tracking with ML detection and VBT (Velocity Based Training) metrics calculation.

## Features

- **ByteTrack-based tracking**: Robust single object tracking with Kalman filter
- **Exercise analysis**: Rep counting, ROM measurement, velocity metrics
- **VBT zones**: Automatic velocity zone detection (Strength, Power, Speed)
- **Real-world units**: Convert normalized coordinates to m/s, cm
- **Path visualization**: Customizable path drawing with velocity colors
- **Easy calibration**: Plate size or camera distance based calibration

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  barbell_tracking:
    path: ../barbell_tracking  # or git URL
```

## Quick Start

```dart
import 'package:barbell_tracking/barbell_tracking.dart';

// Create service with exercise type preset
final service = BarbellTrackingService(
  exerciseType: ExerciseType.squat,
);

// Process ML detection result
final result = service.processDetection(
  x: 0.5,      // normalized x (0-1)
  y: 0.6,      // normalized y (0-1)
  width: 0.1,  // bounding box width
  height: 0.05,
  confidence: 0.85,
);

// Access metrics
print('Reps: ${result.exerciseStats.repCount}');
print('Speed: ${result.speedMps.toStringAsFixed(2)} m/s');
print('Zone: ${result.velocityZone.displayName}');

// Get path for visualization
final path = service.path;
```

## Calibration

```dart
// Method 1: From camera distance (estimate)
service.calibrateFromDistance(
  distanceMeters: 2.5,  // camera is 2.5m from barbell
);

// Method 2: From plate size
service.calibrateFromPlate(
  detectedWidthNormalized: 0.15,  // detected plate width in image
  actualDiameterMeters: 0.45,     // 45cm plate
);
```

## VBT Zones

| Zone | Velocity | Training Focus |
|------|----------|----------------|
| Strength | < 0.5 m/s | Maximum strength |
| Strength-Speed | 0.5 - 0.75 m/s | Heavy power |
| Power | 0.75 - 1.0 m/s | Optimal power |
| Speed-Strength | 1.0 - 1.3 m/s | Explosive power |
| Speed | > 1.3 m/s | Speed/Velocity |

## UI Widgets

```dart
// Path overlay
BarbellPathOverlay(
  path: service.path,
  scaleConfig: service.scaleConfig,
  showVelocityColors: true,
);

// VBT zone legend
VbtZoneLegend(
  direction: Axis.horizontal,
);

// Current velocity zone indicator
VelocityZoneIndicator(
  zone: result.velocityZone,
  size: 48,
  showLabel: true,
);
```

## Architecture

```
barbell_tracking/
├── lib/
│   ├── barbell_tracking.dart     # Main exports
│   └── src/
│       ├── barbell_tracking_service.dart  # Main facade
│       ├── tracker/
│       │   ├── byte_tracker.dart    # ByteTrack algorithm
│       │   ├── kalman_filter.dart   # Kalman filter
│       │   ├── path_smoother.dart   # Path smoothing
│       │   └── track_models.dart    # Detection, TrackResult, etc.
│       ├── analysis/
│       │   ├── exercise_analyzer.dart  # Rep counting, stats
│       │   └── vbt_zones.dart          # VBT zone definitions
│       ├── scale/
│       │   └── scale_config.dart    # Calibration & unit conversion
│       └── ui/
│           └── path_painter.dart    # Path visualization widgets
```

## License

MIT
