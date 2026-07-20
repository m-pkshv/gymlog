import '../enums.dart';

/// S-06 search + filters (04_UI_UX_SPEC.md, section 5): free-text name
/// search (matches both the canonical and localized exercise names,
/// 06_DATA_MODEL.md section 12) plus type/muscle group/equipment/archived/
/// user-created filters — all combinable (Stage 2 acceptance criteria,
/// 02_DEVELOPMENT_PLAN.md). A record so it works directly as a Riverpod
/// `family` key (structural equality) without hand-written
/// `==`/`hashCode`.
typedef ExerciseCatalogFilter = ({
  String query,
  ExerciseType? type,
  String? muscleGroupId,
  String? equipmentId,
  bool includeArchived,
  bool onlyUserCreated,
});

const emptyExerciseCatalogFilter = (
  query: '',
  type: null,
  muscleGroupId: null,
  equipmentId: null,
  includeArchived: false,
  onlyUserCreated: false,
);
