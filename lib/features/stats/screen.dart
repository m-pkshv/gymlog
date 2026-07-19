import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// S-09 "Статистика" placeholder (04_UI_UX_SPEC.md, section 5). Real
/// content (charts, records) lands with Stage 7.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabStats)),
      body: Center(child: Text(l10n.tabStats)),
    );
  }
}
