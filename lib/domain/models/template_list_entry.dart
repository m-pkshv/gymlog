import 'workout_template.dart';

/// A template plus its exercise count — the read shape the template list
/// (S-12, "имя, число упражнений") needs, mirroring `WorkoutHistoryEntry`'s
/// role for S-02.
class TemplateListEntry {
  const TemplateListEntry({
    required this.template,
    required this.exerciseCount,
  });

  final WorkoutTemplate template;
  final int exerciseCount;
}
