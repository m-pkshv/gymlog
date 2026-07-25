import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';
import '../../domain/enums.dart';
import '../../features/workout_editor/status_labels.dart';
import '../../l10n/app_localizations.dart';

/// A workout status chip, color-coded per [workoutStatusColors] (Stage 10
/// redesign, AUDIT.md section 1.8: the 6 statuses used to be visually
/// indistinguishable text-only chips). Self-contained like
/// [ErrorRetryState] -- reads localization itself, so call sites don't
/// have to thread an `AppLocalizations` through just to render a chip.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final WorkoutStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = workoutStatusColors(context, status);
    return DecoratedBox(
      key: const ValueKey('status-badge-decoration'),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: colors.onContainer,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs + 1),
            Text(
              workoutStatusLabel(l10n, status),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.onContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
