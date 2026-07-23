import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/app_error.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/body_measurement_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/measurement_type_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/services/body_measurement_service.dart';

void main() {
  late AppDatabase db;
  late BodyMeasurementRepositoryImpl measurements;
  late MeasurementTypeRepositoryImpl types;
  late BodyMeasurementService service;
  late String massTypeId;
  late String percentTypeId;
  late String lengthTypeId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    measurements = BodyMeasurementRepositoryImpl(db);
    types = MeasurementTypeRepositoryImpl(db);
    service = BodyMeasurementService(measurements, types);
    massTypeId = (await types.create(
      nameCustom: 'Weight (test)',
      unitKind: MeasurementUnitKind.mass,
    )).id;
    percentTypeId = (await types.create(
      nameCustom: 'Body fat (test)',
      unitKind: MeasurementUnitKind.percent,
    )).id;
    lengthTypeId = (await types.create(
      nameCustom: 'Neck (test)',
      unitKind: MeasurementUnitKind.length,
    )).id;
  });

  tearDown(() async {
    await db.close();
  });

  test('create persists a value within the mass range (20-400 kg)', () async {
    final result = await service.create(
      measurementTypeId: massTypeId,
      date: DateTime(2026, 7, 21),
      valueMetric: 82.5,
    );

    expect(result.isOk, isTrue);
    expect(await measurements.watchByType(massTypeId).first, hasLength(1));
  });

  test('create rejects a mass value below 20 kg', () async {
    final result = await service.create(
      measurementTypeId: massTypeId,
      date: DateTime(2026, 7, 21),
      valueMetric: 19.9,
    );

    expect(result.errorOrNull(), isA<ValidationError>());
    expect(await measurements.watchByType(massTypeId).first, isEmpty);
  });

  test('create rejects a mass value above 400 kg', () async {
    final result = await service.create(
      measurementTypeId: massTypeId,
      date: DateTime(2026, 7, 21),
      valueMetric: 400.1,
    );

    expect(result.errorOrNull(), isA<ValidationError>());
  });

  test('create accepts the percent range boundaries (1-75)', () async {
    final low = await service.create(
      measurementTypeId: percentTypeId,
      date: DateTime(2026, 7, 21),
      valueMetric: 1,
    );
    final high = await service.create(
      measurementTypeId: percentTypeId,
      date: DateTime(2026, 7, 22),
      valueMetric: 75,
    );

    expect(low.isOk, isTrue);
    expect(high.isOk, isTrue);
  });

  test('create rejects a percent value outside 1-75', () async {
    final result = await service.create(
      measurementTypeId: percentTypeId,
      date: DateTime(2026, 7, 21),
      valueMetric: 76,
    );

    expect(result.errorOrNull(), isA<ValidationError>());
  });

  test('create accepts the length range boundaries (1-300 cm)', () async {
    final low = await service.create(
      measurementTypeId: lengthTypeId,
      date: DateTime(2026, 7, 21),
      valueMetric: 1,
    );
    final high = await service.create(
      measurementTypeId: lengthTypeId,
      date: DateTime(2026, 7, 22),
      valueMetric: 300,
    );

    expect(low.isOk, isTrue);
    expect(high.isOk, isTrue);
  });

  test('create rejects a length value outside 1-300 cm', () async {
    final result = await service.create(
      measurementTypeId: lengthTypeId,
      date: DateTime(2026, 7, 21),
      valueMetric: 301,
    );

    expect(result.errorOrNull(), isA<ValidationError>());
  });

  test('create rejects an unknown measurement type', () async {
    final result = await service.create(
      measurementTypeId: 'does-not-exist',
      date: DateTime(2026, 7, 21),
      valueMetric: 80,
    );

    expect(result.errorOrNull(), isA<ValidationError>());
  });

  test('findExistingForDay is null with no entry, non-null once one exists', () async {
    expect(
      await service.findExistingForDay(
        measurementTypeId: massTypeId,
        date: DateTime(2026, 7, 21),
      ),
      isNull,
    );

    await service.create(
      measurementTypeId: massTypeId,
      date: DateTime(2026, 7, 21),
      valueMetric: 80,
    );

    expect(
      await service.findExistingForDay(
        measurementTypeId: massTypeId,
        date: DateTime(2026, 7, 21),
      ),
      isNotNull,
    );
  });

  test('update replaces the same-day entry (DM 6.9 "Заменить...?")', () async {
    final created = (await service.create(
      measurementTypeId: massTypeId,
      date: DateTime(2026, 7, 21),
      valueMetric: 80,
    )).getOrNull()!;

    final result = await service.update(existing: created, valueMetric: 81.2);

    expect(result.isOk, isTrue);
    final reloaded = await service.findExistingForDay(
      measurementTypeId: massTypeId,
      date: DateTime(2026, 7, 21),
    );
    expect(reloaded!.valueMetric, 81.2);
  });

  test('update rejects a value outside the range for the entry\'s type', () async {
    final created = (await service.create(
      measurementTypeId: massTypeId,
      date: DateTime(2026, 7, 21),
      valueMetric: 80,
    )).getOrNull()!;

    final result = await service.update(existing: created, valueMetric: 5);

    expect(result.errorOrNull(), isA<ValidationError>());
    final reloaded = await service.findExistingForDay(
      measurementTypeId: massTypeId,
      date: DateTime(2026, 7, 21),
    );
    expect(reloaded!.valueMetric, 80);
  });
}
