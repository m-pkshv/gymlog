import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/units/unit_converter.dart';
import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';

/// S-17 settings screen (04_UI_UX_SPEC.md, section 5). Stage 9, step 2:
/// theme + language selectors, plus unit system/"show tags" (moved here
/// from the temporary switches on the "More" placeholder,
/// `ASSUMPTION(temp-show-tags-toggle)` / `ASSUMPTION(temp-unit-system-toggle)`,
/// both resolved at step 1). Rest-timer defaults, notifications status and
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
            _SegmentedSection<AppTheme>(
              label: l10n.settingsThemeLabel,
              segments: {
                AppTheme.system: l10n.settingsThemeSystem,
                AppTheme.light: l10n.settingsThemeLight,
                AppTheme.dark: l10n.settingsThemeDark,
              },
              selected: settings.theme,
              onChanged: (value) =>
                  ref.read(appSettingsRepositoryProvider).setTheme(value),
            ),
            _SegmentedSection<AppLocale>(
              label: l10n.settingsLanguageLabel,
              segments: {
                AppLocale.system: l10n.settingsLanguageSystem,
                AppLocale.ru: l10n.settingsLanguageRu,
                AppLocale.en: l10n.settingsLanguageEn,
              },
              selected: settings.locale,
              onChanged: (value) =>
                  ref.read(appSettingsRepositoryProvider).setLocale(value),
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

/// A labeled `SegmentedButton` (used for both theme and language on this
/// screen — same shape, different enum). `segments` gives each value its
/// label, in display order.
class _SegmentedSection<T extends Object> extends StatelessWidget {
  const _SegmentedSection({
    required this.label,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final Map<T, String> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<T>(
            segments: [
              for (final entry in segments.entries)
                ButtonSegment(value: entry.key, label: Text(entry.value)),
            ],
            selected: {selected},
            showSelectedIcon: false,
            onSelectionChanged: (selected) => onChanged(selected.first),
          ),
        ),
      ],
    );
  }
}
