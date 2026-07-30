import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/design_tokens.dart';
import '../../l10n/app_localizations.dart';

/// Shown right after a successful backup restore (Stage 11) -- the app's
/// in-memory database connection was closed and the underlying file
/// overwritten while it was closed, so there is no in-app "hot swap": a
/// genuine process restart is required (owner-confirmed 2026-07-30).
/// `PopScope(canPop: false)` blocks the system back button from returning
/// to a screen tree that would try to use the now-closed connection.
class RestartRequiredScreen extends StatelessWidget {
  const RestartRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.backupRestartTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.backupRestartMessage,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: SystemNavigator.pop,
                      child: Text(l10n.backupRestartCloseAppAction),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
