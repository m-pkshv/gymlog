import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// S-06 "Упражнения" placeholder (04_UI_UX_SPEC.md, section 5). Real
/// content (catalog list, search, filters) lands with the Stage 1 vertical
/// slice and Stage 2.
class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabExercises)),
      body: Center(child: Text(l10n.tabExercises)),
    );
  }
}
