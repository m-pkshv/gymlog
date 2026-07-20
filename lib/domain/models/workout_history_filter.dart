import '../enums.dart';

/// S-02 history filters (04_UI_UX_SPEC.md, section 5): date range, text by
/// name, statuses (multi-select), tags (multi-select, OR mode —
/// 02_DEVELOPMENT_PLAN.md Stage 3 acceptance criteria) — all combinable. A
/// record so it works directly as a Riverpod `family` key (structural
/// equality) without hand-written `==`/`hashCode`.
///
/// [statuses] empty means "the Stage 1 default" — only `completed`
/// workouts (owner-confirmed, 2026-07-21); selecting any status explicitly
/// narrows/widens to exactly that set instead.
typedef WorkoutHistoryFilter = ({
  String query,
  DateTime? dateFrom,
  DateTime? dateTo,
  Set<WorkoutStatus> statuses,
  Set<String> tagIds,
});

const emptyWorkoutHistoryFilter = (
  query: '',
  dateFrom: null,
  dateTo: null,
  statuses: <WorkoutStatus>{},
  tagIds: <String>{},
);
