import 'exercise.dart';
import 'template_exercise.dart';
import 'template_set.dart';
import 'workout_template.dart';

/// One exercise entry of a template together with its catalog [Exercise]
/// and its [sets], ordered by `setNumber` — the read shape the template
/// editor (S-13) needs. Not a persisted entity by itself.
class TemplateExerciseDetails {
  const TemplateExerciseDetails({
    required this.templateExercise,
    required this.exercise,
    required this.sets,
  });

  final TemplateExercise templateExercise;
  final Exercise exercise;
  final List<TemplateSet> sets;
}

/// A [WorkoutTemplate] with its exercises and their sets loaded, ordered by
/// `orderIndex` — the read shape the template list (S-12, exercise count)
/// and editor (S-13) need.
class TemplateDetails {
  const TemplateDetails({required this.template, required this.exercises});

  final WorkoutTemplate template;
  final List<TemplateExerciseDetails> exercises;
}
