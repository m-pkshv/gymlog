import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

/// S-11 "Ещё" placeholder (04_UI_UX_SPEC.md, section 5) — menu to
/// templates/measurements/import-export/settings. All four destinations
/// exist now (Stages 5, 6, 8, 9); this screen itself stays a plain menu, as
/// 04 describes S-11.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabMore)),
      body: ListView(
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
          ListTile(
            leading: const Icon(Icons.import_export_outlined),
            title: Text(l10n.exportScreenTitle),
            onTap: () => context.push('/more/export'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(l10n.settingsTitle),
            onTap: () => context.push('/more/settings'),
          ),
        ],
      ),
    );
  }
}
