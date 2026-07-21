import 'package:flutter/material.dart';

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
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final preset in _presets)
          ChoiceChip(
            label: Text(_label(l10n, preset)),
            selected: period.preset == preset,
            onSelected: (_) => onChanged(StatsPeriod.preset(preset)),
          ),
        ChoiceChip(
          label: Text(_label(l10n, StatsPeriodPreset.custom)),
          selected: period.preset == StatsPeriodPreset.custom,
          onSelected: (_) => _pickCustomRange(context),
        ),
      ],
    );
  }
}
