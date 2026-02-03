import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:point_barbell_path/core/l10n/generated/app_localizations.dart';

import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../data/repository/session_repository.dart';

class SessionReviewScreen extends ConsumerWidget {
  final Map<String, dynamic>? sessionData;

  const SessionReviewScreen({super.key, this.sessionData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final totalReps = sessionData?['totalReps'] as int? ?? 0;
    final totalSets = sessionData?['totalSets'] as int? ?? 0;
    final avgVelocity = sessionData?['avgVelocity'] as double? ?? 0.0;
    final peakVelocity = sessionData?['peakVelocity'] as double? ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sessionReview),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: AppConstants.screenPadding,
        child: Column(
          children: [
            const SizedBox(height: 24),
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: AppConstants.secondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.sessionSummary,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 32),
            _StatCard(label: l10n.totalReps, value: '$totalReps'),
            const SizedBox(height: 12),
            _StatCard(label: l10n.totalSets, value: '$totalSets'),
            const SizedBox(height: 12),
            _StatCard(
              label: l10n.avgVelocity,
              value: '${avgVelocity.toStringAsFixed(2)} m/s',
            ),
            const SizedBox(height: 12),
            _StatCard(
              label: l10n.peakVelocity,
              value: '${peakVelocity.toStringAsFixed(2)} m/s',
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go(AppRoutes.home),
                    child: Text(l10n.discardSession),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      final repo = ref.read(sessionRepositoryProvider);
                      final exerciseType =
                          sessionData?['exerciseType'] as String? ?? 'squat';
                      final videoPath =
                          sessionData?['videoPath'] as String?;

                      try {
                        final uuid = await repo.createSession(
                          exerciseType: exerciseType,
                        );
                        await repo.endSession(
                          uuid: uuid,
                          totalReps: totalReps,
                          totalSets: totalSets,
                          avgVelocity: avgVelocity,
                          peakVelocity: peakVelocity,
                          videoPath: videoPath,
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.saveSession)),
                          );
                          context.go(AppRoutes.home);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${l10n.error}: $e')),
                          );
                        }
                      }
                    },
                    child: Text(l10n.saveSession),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyLarge),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
