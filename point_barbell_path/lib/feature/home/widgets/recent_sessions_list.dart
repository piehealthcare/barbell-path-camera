import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:point_barbell_path/core/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/exercise_utils.dart';
import '../../../data/repository/session_repository.dart';
import '../../../data/local/database/app_database.dart';

final recentSessionsProvider = StreamProvider<List<Session>>((ref) {
  return ref.watch(sessionRepositoryProvider).watchAllSessions();
});

class RecentSessionsList extends ConsumerWidget {
  const RecentSessionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final sessionsAsync = ref.watch(recentSessionsProvider);

    return sessionsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Center(
        child: Text('${l10n.error}: $error'),
      ),
      data: (sessions) {
        if (sessions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 48,
                    color: theme.colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.noSessions,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final displaySessions = sessions.take(5).toList();

        return Column(
          children: displaySessions.map((session) {
            final dateFormat = DateFormat.yMd().add_Hm();
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      theme.colorScheme.primaryContainer,
                  child: Icon(
                    ExerciseUtils.icon(session.exerciseType),
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(
                  ExerciseUtils.displayName(session.exerciseType, l10n),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  dateFormat.format(session.startedAt),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.repCount(session.totalReps),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      l10n.setCount(session.totalSets),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                onTap: () {
                  context.push('/history/${session.id}');
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

}
