import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/exercise_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';

void main() {
  late AppDatabase db;
  late ExerciseRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = ExerciseRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'create stores a user-created exercise with just a name and type (S-08)',
    () async {
      final exercise = await repository.create(
        name: 'Barbell Row',
        exerciseType: ExerciseType.strength,
      );

      expect(exercise.name, 'Barbell Row');
      expect(exercise.exerciseType, ExerciseType.strength);
      expect(exercise.isBuiltIn, isFalse);
      expect(exercise.isArchived, isFalse);
      expect(exercise.secondaryMuscleGroupIds, isEmpty);

      final reloaded = await repository.getById(exercise.id);
      expect(reloaded, isNotNull);
      expect(reloaded!.name, 'Barbell Row');
      expect(reloaded.exerciseType, ExerciseType.strength);
    },
  );

  test('getById returns null for an unknown id', () async {
    expect(await repository.getById('does-not-exist'), isNull);
  });

  test(
    'watchAll emits created exercises and includes secondary muscle groups',
    () async {
      await db
          .into(db.muscleGroups)
          .insert(MuscleGroupsCompanion.insert(id: 'chest', sortOrder: 0));
      await db
          .into(db.muscleGroups)
          .insert(MuscleGroupsCompanion.insert(id: 'triceps', sortOrder: 1));

      final exercise = await repository.create(
        name: 'Bench Press',
        exerciseType: ExerciseType.strength,
      );
      await db
          .into(db.exerciseSecondaryMuscles)
          .insert(
            ExerciseSecondaryMusclesCompanion.insert(
              exerciseId: exercise.id,
              muscleGroupId: 'triceps',
            ),
          );

      final all = await repository.watchAll().first;
      expect(all, hasLength(1));
      expect(all.single.name, 'Bench Press');
      expect(all.single.secondaryMuscleGroupIds, ['triceps']);
    },
  );

  test('watchAll excludes archived exercises', () async {
    final exercise = await repository.create(
      name: 'Old Move',
      exerciseType: ExerciseType.reps,
    );
    await (db.update(db.exercises)..where((e) => e.id.equals(exercise.id)))
        .write(ExercisesCompanion(isArchived: Value(true)));

    final all = await repository.watchAll().first;
    expect(all, isEmpty);
  });
}
