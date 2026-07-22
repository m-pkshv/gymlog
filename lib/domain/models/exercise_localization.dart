/// A user-editable translation of an exercise's name/description into one
/// locale (`'ru'`/`'en'`) (06_DATA_MODEL.md, section 12: `ExerciseL10n`).
/// Distinct from `Exercise.name`/`description`, which always stay
/// canonical -- this is the override `ExerciseRepository.watchAll`/`getById`
/// substitute in when read with a matching `locale`.
class ExerciseLocalization {
  const ExerciseLocalization({
    required this.exerciseId,
    required this.locale,
    required this.name,
    this.description,
  });

  final String exerciseId;
  final String locale;
  final String name;
  final String? description;
}
