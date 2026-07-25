import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';

/// A titled card for one S-09/S-10 stats section (Stage 10 redesign,
/// AUDIT.md section 1.4: "no visual separation between cards besides
/// padding -- hard to tell where one block ends and the next begins on
/// scroll"). An explicit outline reads clearly regardless of the default
/// Material 3 `Card`'s low-contrast elevation tint in dark mode (the same
/// gap AUDIT.md section 1.8 names project-wide) -- scoped to this screen's
/// cards rather than a global `CardTheme` change, which would ripple
/// through every `Card` in the app, well beyond this pass. Every S-09/S-10
/// section (`_DynamicsCard`, `_ExerciseProgressEntryCard`,
/// `MeasurementTypeDynamicsCard`, `WorkoutStatsCard`,
/// `ExerciseProgressChart`, and the reps-at-weight/records sections on
/// S-10) shares this one widget instead of each repeating its own
/// `Card(child: Padding(...))`.
class StatsSectionCard extends StatelessWidget {
  const StatsSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.titleTrailing,
  });

  final String title;
  final Widget child;

  /// e.g. the "«расчётный»" badge next to a 1RM chart's title
  /// (`ExerciseProgressChart`).
  final Widget? titleTrailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ?titleTrailing,
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}
