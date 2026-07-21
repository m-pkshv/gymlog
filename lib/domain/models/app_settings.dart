import '../../core/units/unit_converter.dart';

/// The singleton app settings row (06_DATA_MODEL.md, section 6.12).
/// Deliberately minimal for now — [showTags] (Stage 3), the rest-timer
/// defaults (Stage 4: [defaultRestTimerSec]/[restTimerAutoStart]) and
/// [unitSystem] (Stage 6, D-5: S-14/S-15 need to know which unit to
/// show/accept) are read-only here since nothing yet needs to *change*
/// them — there's no unit-system toggle UI before Stage 9. theme/locale
/// still get their own domain fields once a feature needs them (Stage 9,
/// full settings screen).
class AppSettings {
  const AppSettings({
    required this.showTags,
    required this.defaultRestTimerSec,
    required this.restTimerAutoStart,
    required this.unitSystem,
    required this.updatedAt,
  });

  final bool showTags;

  /// Seconds, 10-600 (Q-4, default 120).
  final int defaultRestTimerSec;
  final bool restTimerAutoStart;
  final UnitSystem unitSystem;
  final DateTime updatedAt;
}
