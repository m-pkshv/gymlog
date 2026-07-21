import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';

/// S-11 "Ещё" placeholder (04_UI_UX_SPEC.md, section 5) — menu to
/// templates/measurements/import-export/settings. Real content lands with
/// Stages 5, 6, 8, 9.
///
/// ASSUMPTION(temp-show-tags-toggle): the full S-17 settings screen
/// (unit system, theme, language, rest timer, ...) is Stage 9 scope. Stage
/// 3 only needs the `showTags` flag to exist somewhere reachable, so a
/// single switch is added directly to this placeholder — same pattern as
/// the temporary "New workout" FAB on the History placeholder in Stage 1
/// (`ASSUMPTION(temp-new-workout-entry)`, since replaced). This switch moves
/// into the real settings screen at Stage 9.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(appSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabMore)),
      body: settingsAsync.when(
        data: (settings) => ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.copy_all_outlined),
              title: Text(l10n.templatesTitle),
              onTap: () => context.push('/more/templates'),
            ),
            ListTile(
              leading: const Icon(Icons.monitor_weight_outlined),
              title: Text(l10n.measurementsTitle),
              onTap: () => context.push('/more/measurements'),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: Text(l10n.settingsShowTagsLabel),
              value: settings.showTags,
              onChanged: (value) =>
                  ref.read(appSettingsRepositoryProvider).setShowTags(value),
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
