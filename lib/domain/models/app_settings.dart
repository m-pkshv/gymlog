/// The singleton app settings row (06_DATA_MODEL.md, section 6.12).
/// Deliberately minimal for now — [showTags] (Stage 3) and the rest-timer
/// defaults (Stage 4: [defaultRestTimerSec]/[restTimerAutoStart], read-only
/// here since nothing yet needs to *change* them — Q-4's accepted default
/// of 120s/autostart-on already covers that). unitSystem/theme/locale still
/// get their own domain fields once a feature needs them (Stage 9, full
/// settings screen).
class AppSettings {
  const AppSettings({
    required this.showTags,
    required this.defaultRestTimerSec,
    required this.restTimerAutoStart,
    required this.updatedAt,
  });

  final bool showTags;

  /// Seconds, 10-600 (Q-4, default 120).
  final int defaultRestTimerSec;
  final bool restTimerAutoStart;
  final DateTime updatedAt;
}
