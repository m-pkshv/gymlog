import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/models/body_measurement.dart';
import 'package:gymlog/domain/models/measurement_type.dart';
import 'package:gymlog/services/export/measurements_csv.dart';

final _epoch = DateTime(2026, 1, 1);

BodyMeasurement _measurement({
  required String id,
  required String measurementTypeId,
  required DateTime date,
  required double valueMetric,
}) {
  return BodyMeasurement(
    id: id,
    measurementTypeId: measurementTypeId,
    date: date,
    valueMetric: valueMetric,
    source: MeasurementSource.manual,
    createdAt: _epoch,
    updatedAt: _epoch,
    isDeleted: false,
  );
}

void main() {
  test(
    'golden dataset: built-in vs custom type slug, unit mapping, date '
    'sorting, and RFC 4180 escaping in a custom type name',
    () {
      final bodyWeight = const MeasurementType(
        id: 'body_weight',
        unitKind: MeasurementUnitKind.mass,
        isBuiltIn: true,
        isArchived: false,
        sortOrder: 0,
      );
      final customWrist = const MeasurementType(
        id: 'custom-1',
        nameCustom: 'Wrist, left',
        unitKind: MeasurementUnitKind.length,
        isBuiltIn: false,
        isArchived: false,
        sortOrder: 0,
      );

      final csv = buildMeasurementsCsv(
        [
          _measurement(
            id: 'm1',
            measurementTypeId: 'body_weight',
            date: DateTime(2026, 7, 2),
            valueMetric: 82.4,
          ),
          _measurement(
            id: 'm2',
            measurementTypeId: 'custom-1',
            date: DateTime(2026, 7, 1),
            valueMetric: 15.2,
          ),
        ],
        {'body_weight': bodyWeight, 'custom-1': customWrist},
      );

      expect(
        csv,
        'date,type,custom_type_name,value,unit,source\r\n'
        '2026-07-01,custom,"Wrist, left",15.2,cm,manual\r\n'
        '2026-07-02,body_weight,,82.4,kg,manual\r\n',
      );
    },
  );

  test('percent unitKind maps to "percent"', () {
    final bodyFat = const MeasurementType(
      id: 'body_fat',
      unitKind: MeasurementUnitKind.percent,
      isBuiltIn: true,
      isArchived: false,
      sortOrder: 1,
    );
    final csv = buildMeasurementsCsv(
      [
        _measurement(
          id: 'm1',
          measurementTypeId: 'body_fat',
          date: DateTime(2026, 7, 1),
          valueMetric: 18.5,
        ),
      ],
      {'body_fat': bodyFat},
    );

    expect(csv, contains(',percent,'));
  });
}
