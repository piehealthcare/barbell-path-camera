import 'package:flutter/material.dart';

/// Velocity zone for VBT (Velocity Based Training)
enum VelocityZone {
  /// < 0.5 m/s - Heavy, strength focus
  strength,
  /// 0.5 - 0.75 m/s - Strength with speed component
  strengthSpeed,
  /// 0.75 - 1.0 m/s - Power zone
  power,
  /// 1.0 - 1.3 m/s - Speed with strength component
  speedStrength,
  /// > 1.3 m/s - Explosive, speed focus
  speed,
}

/// VBT Zone utilities
extension VelocityZoneExtension on VelocityZone {
  /// Get zone from velocity in m/s
  static VelocityZone fromMps(double mps) {
    final absMps = mps.abs();
    if (absMps < 0.5) return VelocityZone.strength;
    if (absMps < 0.75) return VelocityZone.strengthSpeed;
    if (absMps < 1.0) return VelocityZone.power;
    if (absMps < 1.3) return VelocityZone.speedStrength;
    return VelocityZone.speed;
  }

  /// Zone display name
  String get displayName {
    switch (this) {
      case VelocityZone.strength:
        return 'Strength';
      case VelocityZone.strengthSpeed:
        return 'Strength-Speed';
      case VelocityZone.power:
        return 'Power';
      case VelocityZone.speedStrength:
        return 'Speed-Strength';
      case VelocityZone.speed:
        return 'Speed';
    }
  }

  /// Zone display name in Korean
  String get displayNameKo {
    switch (this) {
      case VelocityZone.strength:
        return '근력';
      case VelocityZone.strengthSpeed:
        return '근력-스피드';
      case VelocityZone.power:
        return '파워';
      case VelocityZone.speedStrength:
        return '스피드-근력';
      case VelocityZone.speed:
        return '스피드';
    }
  }

  /// Zone color
  Color get color {
    switch (this) {
      case VelocityZone.strength:
        return Colors.blue;
      case VelocityZone.strengthSpeed:
        return Colors.lightGreen;
      case VelocityZone.power:
        return Colors.yellow;
      case VelocityZone.speedStrength:
        return Colors.orange;
      case VelocityZone.speed:
        return Colors.red;
    }
  }

  /// Velocity range description
  String get rangeDescription {
    switch (this) {
      case VelocityZone.strength:
        return '< 0.5 m/s';
      case VelocityZone.strengthSpeed:
        return '0.5 - 0.75 m/s';
      case VelocityZone.power:
        return '0.75 - 1.0 m/s';
      case VelocityZone.speedStrength:
        return '1.0 - 1.3 m/s';
      case VelocityZone.speed:
        return '> 1.3 m/s';
    }
  }

  /// Typical training goal for this zone
  String get trainingGoal {
    switch (this) {
      case VelocityZone.strength:
        return 'Maximum strength, heavy loads';
      case VelocityZone.strengthSpeed:
        return 'Strength with speed development';
      case VelocityZone.power:
        return 'Power output optimization';
      case VelocityZone.speedStrength:
        return 'Speed with strength maintenance';
      case VelocityZone.speed:
        return 'Explosive power, light loads';
    }
  }

  /// Typical %1RM range for this zone
  String get typicalLoadRange {
    switch (this) {
      case VelocityZone.strength:
        return '85-100% 1RM';
      case VelocityZone.strengthSpeed:
        return '70-85% 1RM';
      case VelocityZone.power:
        return '55-70% 1RM';
      case VelocityZone.speedStrength:
        return '40-55% 1RM';
      case VelocityZone.speed:
        return '< 40% 1RM';
    }
  }
}

/// VBT Zone configuration for target training
class VbtConfig {
  /// Target velocity zone
  final VelocityZone targetZone;

  /// Minimum acceptable velocity (m/s)
  final double minVelocity;

  /// Maximum acceptable velocity (m/s)
  final double maxVelocity;

  /// Velocity loss threshold (%) to stop set
  final double velocityLossThreshold;

  const VbtConfig({
    required this.targetZone,
    required this.minVelocity,
    required this.maxVelocity,
    this.velocityLossThreshold = 20.0,
  });

  /// Check if velocity is within target zone
  bool isInTargetZone(double velocityMps) {
    final absVel = velocityMps.abs();
    return absVel >= minVelocity && absVel <= maxVelocity;
  }

  /// Preset for strength training
  static const strength = VbtConfig(
    targetZone: VelocityZone.strength,
    minVelocity: 0.0,
    maxVelocity: 0.5,
    velocityLossThreshold: 20.0,
  );

  /// Preset for power training
  static const power = VbtConfig(
    targetZone: VelocityZone.power,
    minVelocity: 0.75,
    maxVelocity: 1.0,
    velocityLossThreshold: 15.0,
  );

  /// Preset for speed training
  static const speed = VbtConfig(
    targetZone: VelocityZone.speed,
    minVelocity: 1.3,
    maxVelocity: double.infinity,
    velocityLossThreshold: 10.0,
  );
}
