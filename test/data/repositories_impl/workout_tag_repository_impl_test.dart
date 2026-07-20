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
}
