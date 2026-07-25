import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';

/// A labeled group of rows in an outlined card (Stage 10 redesign,
/// AUDIT.md sections 1.4/1.5: cards need a visible boundary beyond the
/// default Material 3 `Card`'s low-contrast elevation tint, and related
/// settings/menu rows read better grouped under a title than as one flat
/// list). [title] is optional -- omit it when the card holds a single,
/// already self-titled row (e.g. a notifications status row) and a
/// redundant group title would just repeat it.
class GroupedSection extends StatelessWidget {
  const GroupedSection({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final card = Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(children: children),
    );
    final title = this.title;
    if (title == null) return card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.xs,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        card,
      ],
    );
  }
}
