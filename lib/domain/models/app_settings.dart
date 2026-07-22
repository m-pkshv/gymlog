import '../../core/units/unit_converter.dart';
import '../enums.dart';

/// The singleton app settings row (06_DATA_MODEL.md, section 6.12).
/// [showTags] (Stage 3), [unitSystem] (Stage 6, D-5), [theme] and [locale]
/// (Stage 9) each got their own field once a feature needed to read/change
/// them.
class AppSettings {
  const AppSettings({
    required this.showTags,
    required this.defaultRestTimerSec,
    required this.restTimerAutoStart,
    required this.unitSystem,
    required this.theme,
    required this.locale,
    required this.updatedAt,
  });

  final bool showTags;

  /// Seconds, 10-600 (Q-4, default 120).
  final int defaultRestTimerSec;
  final bool restTimerAutoStart;
  final UnitSystem unitSystem;
  final AppTheme theme;
  final AppLocale locale;
  final DateTime updatedAt;
}
