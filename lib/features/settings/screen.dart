import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/units/unit_converter.dart';
import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';

/// S-17 settings screen (04_UI_UX_SPEC.md, section 5). Stage 9, step 1:
/// unit system + "show tags" (moved here from the temporary switches on the
/// "More" placeholder, `ASSUMPTION(temp-show-tags-toggle)` /
/// `ASSUMPTION(temp-unit-system-toggle)`, both now resolved) plus the new
/// theme selector. Language, rest-timer defaults, notifications status and
/// "About" land in later steps of this stage.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(appSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: settingsAsync.when(
        data: (settings) => ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.settingsThemeLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<AppTheme>(
                segments: [
                  ButtonSegment(
                    value: AppTheme.system,
                    label: Text(l10n.settingsThemeSystem),
                  ),
                  ButtonSegment(
                    value: AppTheme.light,
                    label: Text(l10n.settingsThemeLight),
                  ),
                  ButtonSegment(
                    value: AppTheme.dark,
                    label: Text(l10n.settingsThemeDark),
                  ),
                ],
                selected: {settings.theme},
                showSelectedIcon: false,
                onSelectionChanged: (selected) => ref
                    .read(appSettingsRepositoryProvider)
                    .setTheme(selected.first),
              ),
            ),
            const Divider(height: 33),
            SwitchListTile(
              title: Text(l10n.settingsShowTagsLabel),
              value: settings.showTags,
              onChanged: (value) =>
                  ref.read(appSettingsRepositoryProvider).setShowTags(value),
            ),
            SwitchListTile(
              title: Text(l10n.settingsUnitSystemLabel),
              subtitle: Text(
                settings.unitSystem == UnitSystem.imperial
                    ? l10n.settingsUnitSystemImperial
                    : l10n.settingsUnitSystemMetric,
              ),
              value: settings.unitSystem == UnitSystem.imperial,
              onChanged: (imperial) => ref
                  .read(appSettingsRepositoryProvider)
                  .setUnitSystem(
                    imperial ? UnitSystem.imperial : UnitSystem.metric,
                  ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text(l10n.settingsLoadError)),
      ),
    );
  }
}
