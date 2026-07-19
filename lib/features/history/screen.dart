import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// S-02 "История" placeholder (04_UI_UX_SPEC.md, section 5). Real content
/// (workout list, filters, calendar view) lands with the Stage 1 vertical
/// slice and Stage 3.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabHistory)),
      body: Center(child: Text(l10n.tabHistory)),
    );
  }
}
