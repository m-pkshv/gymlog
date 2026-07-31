import '../../domain/models/workout.dart';

/// `ironbook_workout_YYYY-MM-DD.pdf`, from the workout's own calendar date --
/// locale-independent, mirroring `services/export/export_file_name.dart`'s
/// naming style. Prefix renamed from `gymlog_` (Q-2, owner-confirmed
/// 2026-07-31) -- user-visible.
String workoutPdfFileName(Workout workout) {
  final date = workout.date;
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return 'ironbook_workout_$y-$m-$d.pdf';
}
