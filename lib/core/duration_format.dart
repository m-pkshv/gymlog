/// `H:MM:SS` (or `MM:SS` under an hour) — the workout timer display (S-03,
/// TS 7.1). Locale-independent by design, same rationale as
/// `core/date_format.dart`: a running clock has no locale-specific format.
String formatElapsedTime(int totalSeconds) {
  final seconds = totalSeconds < 0 ? 0 : totalSeconds;
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final secs = seconds % 60;
  final mm = minutes.toString().padLeft(2, '0');
  final ss = secs.toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$mm:$ss' : '$mm:$ss';
}
