import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../../../core/stats_period.dart';
import '../../../l10n/app_localizations.dart';

/// Per-chart period switcher (S-09: "Нед/Мес/3М/Год/Всё/Свой — range
/// picker"), 03_TECHNICAL_SPEC.md section 9.
class PeriodSelector extends StatelessWidget {
  const PeriodSelector({super.key, required this.period, required this.onChanged});

  final StatsPeriod period;
  final ValueChanged<StatsPeriod> onChanged;

  static const _presets = [
    StatsPeriodPreset.week,
    StatsPeriodPreset.month,
    StatsPeriodPreset.threeMonths,
    StatsPeriodPreset.year,
    StatsPeriodPreset.allTime,
  ];

  String _label(AppLocalizations l10n, StatsPeriodPreset preset) {
    switch (preset) {
      case StatsPeriodPreset.week:
        return l10n.statsPeriodWeek;
      case StatsPeriodPreset.month:
        return l10n.statsPeriodMonth;
      case StatsPeriodPreset.threeMonths:
        return l10n.statsPeriodThreeMonths;
      case StatsPeriodPreset.year:
        return l10n.statsPeriodYear;
      case StatsPeriodPreset.allTime:
        return l10n.statsPeriodAllTime;
      case StatsPeriodPreset.custom:
        return l10n.statsPeriodCustom;
    }
  }

  Future<void> _pickCustomRange(BuildContext context) async {
    final now = DateTime.now();
    final initial = period.preset == StatsPeriodPreset.custom
        ? DateTimeRange(start: period.customFrom!, end: period.customTo!)
        : null;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDateRange: initial,
    );
    if (picked != null) {
      onChanged(StatsPeriod.custom(from: picked.start, to: picked.end));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Stage 10 redesign, AUDIT.md section 1.4: the previous default-sized
    // chips wrapped onto two rows ("Нед/Мес/3М/Год" then "Всё/Свой"),
    // "eating vertical space for navigation, not data". A compact density
    // + tighter label padding shrinks each chip enough that all 6 stay on
    // one row for the labels this app actually ships (RU: Нед/Мес/3М/Год/
    // Всё/Свой; EN: Week/Month/3M/Year/All/Custom) -- kept as a `Wrap`
    // rather than a horizontally scrollable row so every chip stays fully
    // laid out and tappable (a scrolled-away chip would need
    // `scrollUntilVisible` to reach both for a user and for tests) even in
    // the rare case a very narrow screen still forces a second row.
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final preset in _presets)
          _PeriodChip(
            label: _label(l10n, preset),
            selected: period.preset == preset,
            onSelected: () => onChanged(StatsPeriod.preset(preset)),
          ),
        _PeriodChip(
          label: _label(l10n, StatsPeriodPreset.custom),
          selected: period.preset == StatsPeriodPreset.custom,
          onSelected: () => _pickCustomRange(context),
        ),
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    // `VisualDensity.compact` only shrinks the chip's own padding, not the
    // platform's minimum tap target (UX 11: every control stays >= 48dp)
    // -- unlike `MaterialTapTargetSize.shrinkWrap`, which was deliberately
    // not used here for that reason.
    return ChoiceChip(
      label: Text(label),
      labelStyle: Theme.of(context).textTheme.labelSmall,
      labelPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      visualDensity: VisualDensity.compact,
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}
