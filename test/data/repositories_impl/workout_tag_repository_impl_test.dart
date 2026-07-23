import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/workout_tag_repository_impl.dart';

void main() {
  late AppDatabase db;
  late WorkoutTagRepositoryImpl tags;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    tags = WorkoutTagRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('create persists a tag with the given name and color', () async {
    final tag = await tags.create(name: 'Leg day', colorHex: '#4C7BD9');

    expect(tag.name, 'Leg day');
    expect(tag.colorHex, '#4C7BD9');
    expect(tag.isHidden, isFalse);
    expect(tag.isDeleted, isFalse);
  });

  test('getAll and watchAll both list created, non-deleted tags', () async {
    await tags.create(name: 'Leg day', colorHex: '#4C7BD9');
    await tags.create(name: 'Push', colorHex: '#2E9E6B');

    final all = await tags.getAll();
    expect(all.map((t) => t.name), containsAll(['Leg day', 'Push']));

    final watched = await tags.watchAll().first;
    expect(watched.map((t) => t.name), containsAll(['Leg day', 'Push']));
  });

  test('getAll on an empty catalog returns an empty list', () async {
    expect(await tags.getAll(), isEmpty);
  });

  Future<void> seedWorkout(String id, {bool isDeleted = false}) {
    final now = DateTime.now().toUtc().toIso8601String();
    return db
        .into(db.workouts)
        .insert(
          WorkoutsCompanion.insert(
            id: id,
            date: '2026-07-01',
            isDeleted: Value(isDeleted),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  test(
    'countWorkoutsUsingTag counts only non-deleted workouts (Stage 10, DM 10)',
    () async {
      final tag = await tags.create(name: 'Leg day', colorHex: '#4C7BD9');
      await seedWorkout('w1');
      await seedWorkout('w2');
      await seedWorkout('w3', isDeleted: true);
      for (final workoutId in ['w1', 'w2', 'w3']) {
        await db
            .into(db.workoutTagLinks)
            .insert(
              WorkoutTagLinksCompanion.insert(
                workoutId: workoutId,
                tagId: tag.id,
              ),
            );
      }

      expect(await tags.countWorkoutsUsingTag(tag.id), 2);
    },
  );

  test(
    'countWorkoutsUsingTag returns 0 for a tag assigned to nothing',
    () async {
      final tag = await tags.create(name: 'Leg day', colorHex: '#4C7BD9');
      expect(await tags.countWorkoutsUsingTag(tag.id), 0);
    },
  );

  test(
    'delete soft-deletes the tag and removes its WorkoutTagLink rows '
    '(Stage 10, DM 10 -- no Undo, owner-confirmed)',
    () async {
      final tag = await tags.create(name: 'Leg day', colorHex: '#4C7BD9');
      await seedWorkout('w1');
      await db
          .into(db.workoutTagLinks)
          .insert(
            WorkoutTagLinksCompanion.insert(workoutId: 'w1', tagId: tag.id),
          );

      await tags.delete(tag.id);

      expect(await tags.getAll(), isEmpty);
      final links = await db.select(db.workoutTagLinks).get();
      expect(links, isEmpty);
    },
  );
}
