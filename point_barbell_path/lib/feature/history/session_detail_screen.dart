import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:point_barbell_path/core/l10n/generated/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/exercise_utils.dart';
import '../../data/local/database/app_database.dart';
import '../../data/repository/session_repository.dart';

final sessionDetailProvider =
    FutureProvider.family<Session?, int>((ref, id) async {
  return ref.watch(sessionRepositoryProvider).getSession(id);
});

final sessionSetsProvider =
    FutureProvider.family<List<SessionSet>, int>((ref, sessionId) async {
  return ref.watch(sessionRepositoryProvider).getSetsForSession(sessionId);
});

class SessionDetailScreen extends ConsumerWidget {
  final String sessionId;

  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final id = int.tryParse(sessionId) ?? 0;

    final sessionAsync = ref.watch(sessionDetailProvider(id));
    final setsAsync = ref.watch(sessionSetsProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sessionSummary),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareSession(context, ref, id),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref, id),
          ),
        ],
      ),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('${l10n.error}: $error')),
        data: (session) {
          if (session == null) {
            return Center(child: Text(l10n.noData));
          }

          return SingleChildScrollView(
            padding: AppConstants.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise type & date header
                _HeaderCard(session: session, l10n: l10n, theme: theme),
                const SizedBox(height: 16),

                // Stats grid
                _StatsGrid(session: session, l10n: l10n),
                const SizedBox(height: 24),

                // Sets list
                Text(
                  l10n.sets,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                setsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text('${l10n.error}: $error'),
                  data: (sets) {
                    if (sets.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text(l10n.noData)),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sets.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return _SetCard(
                          set_: sets[index],
                          l10n: l10n,
                          theme: theme,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _shareSession(
      BuildContext context, WidgetRef ref, int id) async {
    final l10n = AppLocalizations.of(context)!;
    final session = await ref.read(sessionDetailProvider(id).future);
    if (session == null) return;

    final text = '${ExerciseUtils.displayName(session.exerciseType, l10n)}\n'
        '${l10n.totalReps}: ${session.totalReps}\n'
        '${l10n.totalSets}: ${session.totalSets}\n'
        '${l10n.avgVelocity}: ${session.avgVelocity.toStringAsFixed(2)} m/s\n'
        '${l10n.peakVelocity}: ${session.peakVelocity.toStringAsFixed(2)} m/s\n'
        '\n- PoinT Barbell Path';

    await Share.share(text);
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, int id) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(sessionRepositoryProvider).deleteSession(id);
      if (context.mounted) {
        context.pop();
      }
    }
  }
}

class _HeaderCard extends StatelessWidget {
  final Session session;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _HeaderCard({
    required this.session,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd().add_Hm();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.fitness_center,
              size: 40,
              color: AppConstants.secondaryColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ExerciseUtils.displayName(session.exerciseType, l10n),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(session.startedAt),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _StatsGrid extends StatelessWidget {
  final Session session;
  final AppLocalizations l10n;

  const _StatsGrid({required this.session, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: [
        _StatTile(label: l10n.totalReps, value: '${session.totalReps}'),
        _StatTile(label: l10n.totalSets, value: '${session.totalSets}'),
        _StatTile(
          label: l10n.avgVelocity,
          value: '${session.avgVelocity.toStringAsFixed(2)} m/s',
        ),
        _StatTile(
          label: l10n.peakVelocity,
          value: '${session.peakVelocity.toStringAsFixed(2)} m/s',
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 4),
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

class _SetCard extends StatelessWidget {
  final SessionSet set_;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _SetCard({
    required this.set_,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.sets} ${set_.setNumber}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _SetStat(
                  label: l10n.reps,
                  value: '${set_.repCount}',
                  theme: theme,
                ),
                const SizedBox(width: 24),
                _SetStat(
                  label: l10n.avgVelocity,
                  value: '${set_.avgVelocity.toStringAsFixed(2)} m/s',
                  theme: theme,
                ),
                const SizedBox(width: 24),
                _SetStat(
                  label: l10n.peakVelocity,
                  value: '${set_.peakVelocity.toStringAsFixed(2)} m/s',
                  theme: theme,
                ),
                const SizedBox(width: 24),
                _SetStat(
                  label: l10n.rom,
                  value: '${set_.rom.toStringAsFixed(1)} cm',
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SetStat extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _SetStat({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
