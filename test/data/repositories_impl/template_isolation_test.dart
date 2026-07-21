import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/workout_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_template_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';

/// D-16 / 02_DEVELOPMENT_PLAN.md Stage 5 acceptance criterion: "шаблон не
/// появляется в истории и не влияет на статистику/рекорды". Templates are
/// isolated from workouts *by construction* -- separate tables
/// (`WorkoutTemplates`/`TemplateExercises`/`TemplateSets` vs.
/// `Workouts`/`WorkoutExercises`/`ExerciseSets`), so no query over one can
/// ever return rows from the other. Statistics (S-09/S-10) don't exist yet
/// (Stage 7), so only the history/workout side of this claim is testable
/// right now; this test exists to *fix* that architectural guarantee with
/// a regression test rather than leave it as an unverified assumption
/// (Stage 5's own risk note in `02_DEVELOPMENT_PLAN.md` calls for exactly
/// this: "тест изоляции ... по построению, но тест фиксирует").
void main() {
  late AppDatabase db;
  late WorkoutRepositoryImpl workouts;
  late WorkoutTemplateRepositoryImpl templates;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    workouts = WorkoutRepositoryImpl(db);
    templates = WorkoutTemplateRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('creating a template never creates a workout', () async {
    await templates.create(name: 'Leg day');

    expect(await workouts.watchHistory().first, isEmpty);
    expect(await workouts.getInProgressWorkout(), isNull);
  });

  test('creating a workout never creates a template', () async {
    final workout = await workouts.createDraft(date: DateTime(2026, 7, 20));
    await workouts.updateWorkout(workout.copyWith(status: WorkoutStatus.completed));

    expect(await templates.watchAll(includeArchived: true).first, isEmpty);
  });

  test(
    'a template does not appear in the workout history list, whatever its '
    'name or "status" would otherwise suggest',
    () async {
      // A template deliberately named to look like a workout, to make sure
      // isolation holds by table, not by any content-based filtering.
      await templates.create(name: 'Workout 20.07.2026');

      final history = await workouts.watchHistory().first;
      expect(history, isEmpty);
    },
  );
}
