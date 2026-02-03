import 'package:flutter/material.dart';
import 'package:barbell_tracking/barbell_tracking.dart';

class TrackingStatsPanel extends StatelessWidget {
  final ExerciseStats exerciseStats;
  final double speedMps;
  final VelocityZone velocityZone;

  const TrackingStatsPanel({
    super.key,
    required this.exerciseStats,
    required this.speedMps,
    required this.velocityZone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rep count
          _StatRow(
            label: 'REPS',
            value: '${exerciseStats.repCount}',
            large: true,
          ),
          const SizedBox(height: 8),

          // Phase
          _StatRow(
            label: 'PHASE',
            value: exerciseStats.phase.displayName,
          ),
          const SizedBox(height: 8),

          // Velocity
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: velocityZone.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${speedMps.toStringAsFixed(2)} m/s',
                style: TextStyle(
                  color: velocityZone.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            velocityZone.displayName,
            style: TextStyle(
              color: velocityZone.color.withValues(alpha: 0.8),
              fontSize: 11,
            ),
          ),

          // Last rep duration
          if (exerciseStats.lastRepDuration != null) ...[
            const SizedBox(height: 8),
            _StatRow(
              label: 'LAST REP',
              value:
                  '${exerciseStats.lastRepDuration!.toStringAsFixed(1)}s',
            ),
          ],
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final bool large;

  const _StatRow({
    required this.label,
    required this.value,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: large ? 24 : 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
