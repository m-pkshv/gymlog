import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// S-01 "Сегодня" placeholder (04_UI_UX_SPEC.md, section 5). Real content
/// (next/active workout card, quick actions) lands with the Stage 1
/// vertical slice.
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabToday)),
      body: Center(child: Text(l10n.tabToday)),
    );
  }
}
