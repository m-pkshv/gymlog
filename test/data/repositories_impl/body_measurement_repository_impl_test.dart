import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/body_measurement_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/measurement_type_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';

void main() {
  late AppDatabase db;
  late BodyMeasurementRepositoryImpl measurements;
  late MeasurementTypeRepositoryImpl types;
  late String weightTypeId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    measurements = BodyMeasurementRepositoryImpl(db);
    types = MeasurementTypeRepositoryImpl(db);
    weightTypeId = (await types.create(
      nameCustom: 'Body weight (test)',
      unitKind: MeasurementUnitKind.mass,
    )).id;
  });

  tearDown(() async {
    await db.close();
  });

  test('create persists an entry with manual source', () async {
    final entry = await measurements.create(
      measurementTypeId: weightTypeId,
      date: DateTime(2026, 7, 21),
      valueMetric: 82.5,
      comment: 'After breakfast',
    );

    expect(entry.measurementTypeId, weightTypeId);
    expect(entry.valueMetric, 82.5);
    expect(entry.comment, 'After breakfast');
    expect(entry.source, MeasurementSource.manual);
    expect(entry.isDeleted, isFalse);
  });

  test('watchByType lists entries newest date first', () async {
    await measurements.create(
      measurementTypeId: weightTypeId,
      date: DateTime(2026, 7, 1),
      valueMetric: 80,
    );
    await measurements.create(
      measurementTypeId: weightTypeId,
      date: DateTime(2026, 7, 21),
      valueMetric: 82,
    );

    final entries = await measurements.watchByType(weightTypeId).first;
    expect(entries, hasLength(2));
    expect(entries.first.date, DateTime(2026, 7, 21));
    expect(entries.last.date, DateTime(2026, 7, 1));
  });

  test('getByTypeAndDate finds the same-day entry, null otherwise', () async {
    await measurements.create(
      measurementTypeId: weightTypeId,
      date: DateTime(2026, 7, 21),
      valueMetric: 82,
    );

    final found = await measurements.getByTypeAndDate(
      measurementTypeId: weightTypeId,
      date: DateTime(2026, 7, 21),
    );
    expect(found, isNotNull);
    expect(found!.valueMetric, 82);

    final notFound = await measurements.getByTypeAndDate(
      measurementTypeId: weightTypeId,
      date: DateTime(2026, 7, 20),
    );
    expect(notFound, isNull);
  });

  test('update overwrites value, date and comment', () async {
    final entry = await measurements.create(
      measurementTypeId: weightTypeId,
      date: DateTime(2026, 7, 21),
      valueMetric: 82,
    );

    await measurements.update(
      entry.copyWith(
        date: DateTime(2026, 7, 22),
        valueMetric: 81.5,
        comment: 'Replaced',
      ),
    );

    final reloaded = await measurements.getByTypeAndDate(
      measurementTypeId: weightTypeId,
      date: DateTime(2026, 7, 22),
    );
    expect(reloaded, isNotNull);
    expect(reloaded!.valueMetric, 81.5);
    expect(reloaded.comment, 'Replaced');
  });

  test('delete soft-deletes; restore reverses it within the Undo window', () async {
    final entry = await measurements.create(
      measurementTypeId: weightTypeId,
      date: DateTime(2026, 7, 21),
      valueMetric: 82,
    );

    await measurements.delete(entry.id);
    expect(await measurements.watchByType(weightTypeId).first, isEmpty);

    await measurements.restore(entry.id);
    final restored = await measurements.watchByType(weightTypeId).first;
    expect(restored, hasLength(1));
    expect(restored.single.id, entry.id);
  });

  group('getAllForExport (Stage 8, TS 10.1/10.4)', () {
    test('returns entries across every type, excluding soft-deleted', () async {
      final neckTypeId = (await types.create(
        nameCustom: 'Neck (test)',
        unitKind: MeasurementUnitKind.length,
      )).id;

      final weightEntry = await measurements.create(
        measurementTypeId: weightTypeId,
        date: DateTime(2026, 7, 21),
        valueMetric: 82,
      );
      final neckEntry = await measurements.create(
        measurementTypeId: neckTypeId,
        date: DateTime(2026, 7, 21),
        valueMetric: 38,
      );
      final deleted = await measurements.create(
        measurementTypeId: weightTypeId,
        date: DateTime(2026, 7, 20),
        valueMetric: 83,
      );
      await measurements.delete(deleted.id);

      final all = await measurements.getAllForExport();
      expect(
        all.map((m) => m.id).toSet(),
        {weightEntry.id, neckEntry.id},
      );
    });
  });
}
