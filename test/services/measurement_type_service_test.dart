import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/app_error.dart';
import 'package:gymlog/data/database.dart' hide MeasurementType;
import 'package:gymlog/data/repositories_impl/body_measurement_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/measurement_type_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/models/measurement_type.dart';
import 'package:gymlog/services/measurement_type_service.dart';

void main() {
  late AppDatabase db;
  late MeasurementTypeRepositoryImpl repository;
  late BodyMeasurementRepositoryImpl measurements;
  late MeasurementTypeService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = MeasurementTypeRepositoryImpl(db);
    measurements = BodyMeasurementRepositoryImpl(db);
    service = MeasurementTypeService(repository);
  });

  tearDown(() async {
    await db.close();
  });

  test('create trims the name and persists it', () async {
    final result = await service.create(
      nameCustom: '  Neck circumference  ',
      unitKind: MeasurementUnitKind.length,
    );

    expect(result.isOk, isTrue);
    expect(result.getOrNull()!.nameCustom, 'Neck circumference');
    expect(await repository.getAll(), hasLength(1));
  });

  test('rejects an empty (or whitespace-only) name (DM 5.3)', () async {
    final result = await service.create(
      nameCustom: '   ',
      unitKind: MeasurementUnitKind.length,
    );

    expect(result.errorOrNull(), isA<ValidationError>());
    expect(await repository.getAll(), isEmpty);
  });

  test('rejects a name longer than 60 characters (DM 5.3)', () async {
    final result = await service.create(
      nameCustom: 'a' * 61,
      unitKind: MeasurementUnitKind.length,
    );

    expect(result.errorOrNull(), isA<ValidationError>());
    expect(await repository.getAll(), isEmpty);
  });

  test('accepts a name of exactly 60 characters', () async {
    final result = await service.create(
      nameCustom: 'a' * 60,
      unitKind: MeasurementUnitKind.mass,
    );

    expect(result.isOk, isTrue);
  });

  test(
    'rejects a duplicate name, case-insensitively, among non-archived types '
    '(DM 5.3)',
    () async {
      await service.create(
        nameCustom: 'Neck',
        unitKind: MeasurementUnitKind.length,
      );

      final result = await service.create(
        nameCustom: 'NECK',
        unitKind: MeasurementUnitKind.length,
      );

      expect(result.errorOrNull(), isA<ValidationError>());
      expect(await repository.getAll(), hasLength(1));
    },
  );

  test('allows reusing a name once the original is archived', () async {
    final first = (await service.create(
      nameCustom: 'Neck',
      unitKind: MeasurementUnitKind.length,
    )).getOrNull()!;
    await repository.setArchived(first.id, archived: true);

    final result = await service.create(
      nameCustom: 'Neck',
      unitKind: MeasurementUnitKind.length,
    );

    expect(result.isOk, isTrue);
  });

  test('archive rejects built-in types (ASSUMPTION(builtin-types-not-archivable))', () async {
    const builtIn = _fakeBuiltInType;
    final result = await service.archive(builtIn);

    expect(result.errorOrNull(), isA<ValidationError>());
  });

  test('archive/unarchive a custom type', () async {
    final type = (await service.create(
      nameCustom: 'Neck',
      unitKind: MeasurementUnitKind.length,
    )).getOrNull()!;

    final archived = await service.archive(type);
    expect(archived.getOrNull()!.isArchived, isTrue);
    expect((await repository.getById(type.id))!.isArchived, isTrue);

    final unarchived = await service.unarchive(archived.getOrNull()!);
    expect(unarchived.getOrNull()!.isArchived, isFalse);
    expect((await repository.getById(type.id))!.isArchived, isFalse);
  });

  test('canDelete is false for built-in types', () async {
    expect(await service.canDelete(_fakeBuiltInType), isFalse);
  });

  test('canDelete is true for an unused custom type, false once used', () async {
    final type = (await service.create(
      nameCustom: 'Neck',
      unitKind: MeasurementUnitKind.length,
    )).getOrNull()!;
    expect(await service.canDelete(type), isTrue);

    await measurements.create(
      measurementTypeId: type.id,
      date: DateTime(2026, 7, 21),
      valueMetric: 40,
    );
    expect(await service.canDelete(type), isFalse);
  });

  test('delete rejects built-in types', () async {
    final result = await service.delete(_fakeBuiltInType);
    expect(result.errorOrNull(), isA<ValidationError>());
  });

  test('delete rejects a custom type with entries, archiving is the way out', () async {
    final type = (await service.create(
      nameCustom: 'Neck',
      unitKind: MeasurementUnitKind.length,
    )).getOrNull()!;
    await measurements.create(
      measurementTypeId: type.id,
      date: DateTime(2026, 7, 21),
      valueMetric: 40,
    );

    final result = await service.delete(type);

    expect(result.errorOrNull(), isA<ValidationError>());
    expect(await repository.getById(type.id), isNotNull);
  });

  test('delete removes an unused custom type', () async {
    final type = (await service.create(
      nameCustom: 'Neck',
      unitKind: MeasurementUnitKind.length,
    )).getOrNull()!;

    final result = await service.delete(type);

    expect(result.isOk, isTrue);
    expect(await repository.getById(type.id), isNull);
  });
}

const _fakeBuiltInType = MeasurementType(
  id: 'body_weight',
  unitKind: MeasurementUnitKind.mass,
  isBuiltIn: true,
  isArchived: false,
  sortOrder: 0,
);
