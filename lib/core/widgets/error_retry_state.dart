import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// "Не удалось загрузить" + "Повторить" (04_UI_UX_SPEC.md, section 6: the
/// storage-error pattern every screen-level `AsyncValue.when` error branch
/// should use). [onRetry] re-fetches -- typically
/// `() => ref.invalidate(someProvider)`, not just a rebuild, since the
/// underlying stream/future already failed and won't retry itself.
class ErrorRetryState extends StatelessWidget {
  const ErrorRetryState({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: Text(l10n.retryAction)),
          ],
        ),
      ),
    );
  }
}
