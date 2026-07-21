import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/app_error.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/workout_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_template_repository_impl.dart';
import 'package:gymlog/services/workout_template_service.dart';

void main() {
  late AppDatabase db;
  late WorkoutTemplateRepositoryImpl repository;
  late WorkoutRepositoryImpl workouts;
  late WorkoutTemplateService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = WorkoutTemplateRepositoryImpl(db);
    workouts = WorkoutRepositoryImpl(db);
    service = WorkoutTemplateService(repository);
  });

  tearDown(() async {
    await db.close();
  });

  test('create trims the name and persists it', () async {
    final result = await service.create(name: '  Leg day  ');

    expect(result.isOk, isTrue);
    expect(result.getOrNull()!.name, 'Leg day');
    expect(await repository.watchAll().first, hasLength(1));
  });

  test('rejects an empty (or whitespace-only) name (DM 6.8)', () async {
    final result = await service.create(name: '   ');

    expect(result.errorOrNull(), isA<ValidationError>());
    expect(await repository.watchAll().first, isEmpty);
  });

  test('rejects a name longer than 80 characters (DM 6.8)', () async {
    final result = await service.create(name: 'a' * 81);

    expect(result.errorOrNull(), isA<ValidationError>());
    expect(await repository.watchAll().first, isEmpty);
  });

  test('accepts a name of exactly 80 characters', () async {
    final result = await service.create(name: 'a' * 80);

    expect(result.isOk, isTrue);
  });

  test('does not require unique names, unlike tags (DM 6.8)', () async {
    await service.create(name: 'Leg day');
    final result = await service.create(name: 'Leg day');

    expect(result.isOk, isTrue);
    expect(await repository.watchAll().first, hasLength(2));
  });

  group('createFromWorkout (TS 8 section 8)', () {
    test('trims the name and delegates to the repository', () async {
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 20));

      final result = await service.createFromWorkout(
        workoutId: workout.id,
        name: '  Leg day  ',
      );

      expect(result.isOk, isTrue);
      expect(result.getOrNull()!.name, 'Leg day');
    });

    test('rejects an empty name without touching the repository', () async {
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 20));

      final result = await service.createFromWorkout(
        workoutId: workout.id,
        name: '   ',
      );

      expect(result.errorOrNull(), isA<ValidationError>());
      expect(await repository.watchAll().first, isEmpty);
    });
  });

  group('duplicate (04_UI_UX_SPEC.md section 5)', () {
    test('trims the name and delegates to the repository', () async {
      final source = await service.create(name: 'Leg day');

      final result = await service.duplicate(
        templateId: source.getOrNull()!.id,
        name: '  Leg day copy  ',
      );

      expect(result.isOk, isTrue);
      expect(result.getOrNull()!.name, 'Leg day copy');
      expect(await repository.watchAll().first, hasLength(2));
    });

    test('rejects an empty name without touching the repository', () async {
      final source = await service.create(name: 'Leg day');

      final result = await service.duplicate(
        templateId: source.getOrNull()!.id,
        name: '   ',
      );

      expect(result.errorOrNull(), isA<ValidationError>());
      expect(await repository.watchAll().first, hasLength(1));
    });
  });
}
