import 'package:flutter/material.dart';
import 'package:point_barbell_path/core/l10n/generated/app_localizations.dart';

import '../../../core/constants/app_constants.dart';

class QuickStartCard extends StatelessWidget {
  final void Function(String exerciseType) onExerciseSelected;

  const QuickStartCard({super.key, required this.onExerciseSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppConstants.primaryColor,
              AppConstants.primaryColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.quickStart,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ExerciseChip(
                    label: l10n.squat,
                    onTap: () => onExerciseSelected('squat'),
                  ),
                  _ExerciseChip(
                    label: l10n.benchPress,
                    onTap: () => onExerciseSelected('benchPress'),
                  ),
                  _ExerciseChip(
                    label: l10n.deadlift,
                    onTap: () => onExerciseSelected('deadlift'),
                  ),
                  _ExerciseChip(
                    label: l10n.overheadPress,
                    onTap: () => onExerciseSelected('overheadPress'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ExerciseChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
