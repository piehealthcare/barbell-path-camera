import 'package:flutter/material.dart';
import 'package:point_barbell_path/core/l10n/generated/app_localizations.dart';

/// Utility for exercise type display names and icons.
class ExerciseUtils {
  ExerciseUtils._();

  static String displayName(String type, AppLocalizations l10n) {
    switch (type) {
      case 'squat':
        return l10n.squat;
      case 'benchPress':
        return l10n.benchPress;
      case 'deadlift':
        return l10n.deadlift;
      case 'overheadPress':
        return l10n.overheadPress;
      default:
        return l10n.custom;
    }
  }

  static IconData icon(String type) {
    switch (type) {
      case 'squat':
        return Icons.fitness_center;
      case 'benchPress':
        return Icons.airline_seat_flat;
      case 'deadlift':
        return Icons.fitness_center;
      case 'overheadPress':
        return Icons.arrow_upward;
      default:
        return Icons.fitness_center;
    }
  }

  static const List<String> allTypes = [
    'squat',
    'benchPress',
    'deadlift',
    'overheadPress',
    'custom',
  ];
}
