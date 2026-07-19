import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// S-11 "Ещё" placeholder (04_UI_UX_SPEC.md, section 5) — menu to
/// templates/measurements/import-export/settings. Real content lands with
/// Stages 5, 6, 8, 9.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabMore)),
      body: Center(child: Text(l10n.tabMore)),
    );
  }
}
