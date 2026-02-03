import 'package:flutter/material.dart';

abstract final class AppConstants {
  // Brand
  static const String appName = 'PoinT 바벨패스';
  static const String appNameEn = 'PoinT Barbell Path';
  static const String brandName = 'PoinT';
  static const String bundleId = 'com.point.barbellpath';

  // Brand Colors
  static const Color primaryColor = Color(0xFF6C5CE7);
  static const Color secondaryColor = Color(0xFF00B894);
  static const Color accentColor = Color(0xFFFD79A8);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFFF8F9FA);

  // VBT Zone Colors (from barbell_tracking)
  static const Color strengthColor = Color(0xFF3498DB);
  static const Color strengthSpeedColor = Color(0xFF2ECC71);
  static const Color powerColor = Color(0xFFF1C40F);
  static const Color speedStrengthColor = Color(0xFFE67E22);
  static const Color speedColor = Color(0xFFE74C3C);

  // Camera
  static const double defaultFrameSkip = 2;
  static const double defaultConfidenceThreshold = 0.5;
  static const int maxPathLength = 500;

  // Recording
  static const int recordingFps = 30;
  static const int recordingBitrate = 8000000; // 8 Mbps

  // Session
  static const int maxSetsPerSession = 20;
  static const Duration sessionTimeout = Duration(minutes: 60);

  // UI
  static const double borderRadius = 16.0;
  static const double cardElevation = 2.0;
  static const EdgeInsets screenPadding = EdgeInsets.all(16.0);

  // Storage keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyDarkMode = 'dark_mode';
  static const String keyLanguage = 'language';
  static const String keyLastExercise = 'last_exercise';
  static const String keyCameraDistance = 'camera_distance';
}
