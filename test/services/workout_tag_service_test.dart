import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/app_error.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/workout_tag_repository_impl.dart';
import 'package:gymlog/services/workout_tag_service.dart';

void main() {
  late AppDatabase db;
  late WorkoutTagRepositoryImpl repository;
  late WorkoutTagService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = WorkoutTagRepositoryImpl(db);
    service = WorkoutTagService(repository);
  });

  tearDown(() async {
    await db.close();
  });

  test('create trims the name and persists it', () async {
    final result = await service.create(
      name: '  Leg day  ',
      colorHex: '#4C7BD9',
    );

    expect(result.isOk, isTrue);
    expect(result.getOrNull()!.name, 'Leg day');
    expect(await repository.getAll(), hasLength(1));
  });

  test('rejects an empty (or whitespace-only) name (DM 6.3)', () async {
    final result = await service.create(name: '   ', colorHex: '#4C7BD9');

    expect(result.errorOrNull(), isA<ValidationError>());
    expect(await repository.getAll(), isEmpty);
  });

  test('rejects a name longer than 30 characters (DM 6.3)', () async {
    final result = await service.create(name: 'a' * 31, colorHex: '#4C7BD9');

    expect(result.errorOrNull(), isA<ValidationError>());
    expect(await repository.getAll(), isEmpty);
  });

  test('accepts a name of exactly 30 characters', () async {
    final result = await service.create(name: 'a' * 30, colorHex: '#4C7BD9');

    expect(result.isOk, isTrue);
  });

  test(
    'rejects a duplicate name, case-insensitively, among non-deleted tags '
    '(DM 6.3)',
    () async {
      await service.create(name: 'Leg day', colorHex: '#4C7BD9');

      final result = await service.create(
        name: 'LEG DAY',
        colorHex: '#2E9E6B',
      );

      expect(result.errorOrNull(), isA<ValidationError>());
      expect(await repository.getAll(), hasLength(1));
    },
  );

  test('allows a different name reusing the same color', () async {
    await service.create(name: 'Leg day', colorHex: '#4C7BD9');
    final result = await service.create(name: 'Push', colorHex: '#4C7BD9');

    expect(result.isOk, isTrue);
    expect(await repository.getAll(), hasLength(2));
  });
}
