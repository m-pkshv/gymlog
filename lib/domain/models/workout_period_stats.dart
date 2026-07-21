/// S-09 "Тренировки" card figures for a statistics period (03_TECHNICAL_SPEC.md
/// section 9): completed-workout count and summed tonnage. Frequency isn't
/// stored here — it depends on the period's length, which this aggregate
/// doesn't know about (`StatsPeriod` computes it, UI-side).
class WorkoutPeriodStats {
  const WorkoutPeriodStats({required this.workoutCount, required this.tonnageKg});

  final int workoutCount;
  final double tonnageKg;
}
