import '../../domain/models/measurement_type.dart';

/// First `MeasurementType` in [types] matching [test], or `null`. Shared by
/// `MeasurementsScreen` (S-14), `MeasurementFormScreen` (S-15), and the S-09
/// stats cards — all need to pick a specific built-in type (weight/body
/// fat/a girth) out of the full type list without a dedicated provider per
/// lookup.
MeasurementType? firstMeasurementTypeWhere(
  List<MeasurementType> types,
  bool Function(MeasurementType) test,
) {
  for (final type in types) {
    if (test(type)) return type;
  }
  return null;
}
