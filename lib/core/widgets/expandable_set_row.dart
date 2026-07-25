import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';
import '../../l10n/app_localizations.dart';

/// One row in a sets table (S-03/S-13, Stage 10 redesign): collapsed shows
/// a colored status bar, the set number, a plan label, and a big value;
/// tapping the row toggles [expandedChild] open for editing (DESIGN.md,
/// section 1: "тап по строке подхода разворачивает степперы... без
/// отдельных кнопок редактирования"). Purely presentational -- callers
/// (workout editor for fact entry, template editor for plan-only entry)
/// supply the labels, [trailing] indicator (a checkmark circle, or nothing
/// for a template row that has no "done" concept), and [expandedChild].
///
/// Deleting a set is a swipe (the mockup's primary affordance) but the
/// project's own accessibility rule requires a non-gesture alternative for
/// every gesture (already true of drag-reorder's "⋮ → Move up/down") --
/// [onDelete], when supplied, also renders a plain delete icon button, the
/// same one the pre-redesign row already had. Neither path does its own
/// soft-delete/Undo -- that stays screen-side, unchanged from before.
class ExpandableSetRow extends StatelessWidget {
  const ExpandableSetRow({
    required Key key,
    required this.setNumber,
    required this.planLabel,
    required this.valueLabel,
    required this.statusBarColor,
    required this.expanded,
    required this.onToggleExpanded,
    this.trailing,
    this.expandedChild,
    this.onDelete,
    this.valueTextColor,
  }) : super(key: key);

  final int setNumber;
  final String planLabel;
  final String valueLabel;
  final Color statusBarColor;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final Widget? trailing;
  final Widget? expandedChild;
  final VoidCallback? onDelete;
  final Color? valueTextColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final collapsedRow = InkWell(
      onTap: onToggleExpanded,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 4, color: statusBarColor),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 18,
              child: Text(
                '$setNumber',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              planLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                valueLabel,
                textAlign: TextAlign.right,
                style: AppNumberTextStyles.setValue(context).copyWith(
                  color: valueTextColor ?? scheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            ?trailing,
            if (onDelete != null)
              IconButton(
                tooltip: l10n.deleteSetAction,
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 20),
              ),
          ],
        ),
      ),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        collapsedRow,
        if (expanded && expandedChild != null) expandedChild!,
      ],
    );

    if (onDelete == null) return content;

    return Dismissible(
      key: key!,
      direction: DismissDirection.endToStart,
      background: ColoredBox(
        color: scheme.errorContainer,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
          ),
        ),
      ),
      onDismissed: (_) => onDelete!(),
      child: content,
    );
  }
}
