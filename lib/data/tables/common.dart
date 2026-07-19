import 'package:drift/drift.dart';

/// Shared service columns for user-data tables (06_DATA_MODEL.md, section
/// 3): UTC ISO 8601 timestamps and soft delete. Reference/enum tables and
/// cache tables do not use this mixin.
mixin SoftDeleteColumns on Table {
  TextColumn get createdAt => text()();

  TextColumn get updatedAt => text()();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
