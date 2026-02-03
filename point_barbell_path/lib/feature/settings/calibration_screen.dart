import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:point_barbell_path/core/l10n/generated/app_localizations.dart';

import '../../core/constants/app_constants.dart';
import '../../data/local/preferences/app_preferences.dart';

class CalibrationScreen extends ConsumerStatefulWidget {
  const CalibrationScreen({super.key});

  @override
  ConsumerState<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends ConsumerState<CalibrationScreen> {
  late double _distance;

  @override
  void initState() {
    super.initState();
    _distance = AppPreferences.cameraDistance;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.calibration)),
      body: Padding(
        padding: AppConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              l10n.cameraDistance,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.calibrationDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                l10n.metersAway(_distance.toStringAsFixed(1)),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppConstants.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Slider(
              value: _distance,
              min: 1.0,
              max: 5.0,
              divisions: 40,
              label: '${_distance.toStringAsFixed(1)}m',
              onChanged: (value) => setState(() => _distance = value),
              onChangeEnd: (value) => AppPreferences.setCameraDistance(value),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1.0m', style: theme.textTheme.bodySmall),
                Text('5.0m', style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PresetTile(label: l10n.squat, distance: 2.5, onTap: () => _setDistance(2.5)),
                    _PresetTile(label: l10n.benchPress, distance: 2.0, onTap: () => _setDistance(2.0)),
                    _PresetTile(label: l10n.overheadPress, distance: 2.5, onTap: () => _setDistance(2.5)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setDistance(double distance) {
    setState(() => _distance = distance);
    AppPreferences.setCameraDistance(distance);
  }
}

class _PresetTile extends StatelessWidget {
  final String label;
  final double distance;
  final VoidCallback onTap;

  const _PresetTile({
    required this.label,
    required this.distance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: TextButton(
        onPressed: onTap,
        child: Text('${distance}m'),
      ),
    );
  }
}
