import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/body_measurement_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/measurement_type_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';

void main() {
  late AppDatabase db;
  late MeasurementTypeRepositoryImpl types;
  late BodyMeasurementRepositoryImpl measurements;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    types = MeasurementTypeRepositoryImpl(db);
    measurements = BodyMeasurementRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('create persists a user-created type', () async {
    final type = await types.create(
      nameCustom: 'Neck circumference',
      unitKind: MeasurementUnitKind.length,
    );

    expect(type.nameCustom, 'Neck circumference');
    expect(type.unitKind, MeasurementUnitKind.length);
    expect(type.isBuiltIn, isFalse);
    expect(type.isArchived, isFalse);
  });

  test('getAll and watchAll both list created types', () async {
    await types.create(
      nameCustom: 'Left calf',
      unitKind: MeasurementUnitKind.length,
    );

    final all = await types.getAll();
    expect(all.map((t) => t.nameCustom), contains('Left calf'));

    final watched = await types.watchAll().first;
    expect(watched.map((t) => t.nameCustom), contains('Left calf'));
  });

  test('watchAll hides archived types unless includeArchived', () async {
    final type = await types.create(
      nameCustom: 'Wrist',
      unitKind: MeasurementUnitKind.length,
    );
    await types.setArchived(type.id, archived: true);

    final defaultView = await types.watchAll().first;
    expect(defaultView.where((t) => t.id == type.id), isEmpty);

    final withArchived = await types.watchAll(includeArchived: true).first;
    expect(withArchived.where((t) => t.id == type.id), hasLength(1));
    expect(withArchived.firstWhere((t) => t.id == type.id).isArchived, isTrue);
  });

  test('getById returns null for an unknown id', () async {
    expect(await types.getById('does-not-exist'), isNull);
  });

  test('setArchived can also unarchive', () async {
    final type = await types.create(
      nameCustom: 'Ankle',
      unitKind: MeasurementUnitKind.length,
    );
    await types.setArchived(type.id, archived: true);
    await types.setArchived(type.id, archived: false);

    final reloaded = await types.getById(type.id);
    expect(reloaded!.isArchived, isFalse);
  });

  test('hasMeasurements is false until an entry is logged', () async {
    final type = await types.create(
      nameCustom: 'Chest',
      unitKind: MeasurementUnitKind.length,
    );
    expect(await types.hasMeasurements(type.id), isFalse);

    await measurements.create(
      measurementTypeId: type.id,
      date: DateTime(2026, 7, 21),
      valueMetric: 100,
    );
    expect(await types.hasMeasurements(type.id), isTrue);
  });

  test('delete physically removes an unused user-created type', () async {
    final type = await types.create(
      nameCustom: 'Unused',
      unitKind: MeasurementUnitKind.mass,
    );
    await types.delete(type.id);

    expect(await types.getById(type.id), isNull);
  });
}
