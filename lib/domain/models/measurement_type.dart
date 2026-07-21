import '../enums.dart';

/// A body measurement type — built-in or user-created (06_DATA_MODEL.md,
/// section 5.3). Built-in rows have [nameCustom] == null; their display name
/// comes from ARB (`measurementType.<id>`) instead. [isArchived] only
/// applies to user-created types in practice (built-in types have no
/// archive UI, DM 5.3/04 S-14 — "Управление пользовательскими типами").
class MeasurementType {
  const MeasurementType({
    required this.id,
    required this.unitKind,
    required this.isBuiltIn,
    required this.isArchived,
    required this.sortOrder,
    this.nameCustom,
  });

  final String id;
  final String? nameCustom;
  final MeasurementUnitKind unitKind;
  final bool isBuiltIn;
  final bool isArchived;
  final int sortOrder;

  MeasurementType copyWith({String? nameCustom, bool? isArchived}) {
    return MeasurementType(
      id: id,
      nameCustom: nameCustom ?? this.nameCustom,
      unitKind: unitKind,
      isBuiltIn: isBuiltIn,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder,
    );
  }
}
