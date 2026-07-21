import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/models/exercise.dart';
import 'package:gymlog/domain/models/exercise_set.dart';
import 'package:gymlog/domain/models/workout.dart';
import 'package:gymlog/domain/models/workout_details.dart';
import 'package:gymlog/domain/models/workout_exercise.dart';
import 'package:gymlog/domain/models/workout_tag.dart';
import 'package:gymlog/services/export/csv_format.dart';
import 'package:gymlog/services/export/workouts_csv.dart';

final _epoch = DateTime(2026, 1, 1);

Exercise _exercise({
  required String id,
  required String name,
  ExerciseType type = ExerciseType.strength,
}) {
  return Exercise(
    id: id,
    name: name,
    exerciseType: type,
    effortMetric: EffortMetric.none,
    isBuiltIn: true,
    isArchived: false,
    secondaryMuscleGroupIds: const [],
    createdAt: _epoch,
    updatedAt: _epoch,
    isDeleted: false,
  );
}

ExerciseSet _set({
  required String id,
  required int setNumber,
  required bool isWarmup,
  required bool isCompleted,
  double? plannedWeightKg,
  int? plannedReps,
  double? actualWeightKg,
  int? actualReps,
  double? rpe,
  int? rir,
  String? comment,
}) {
  return ExerciseSet(
    id: id,
    workoutExerciseId: 'we',
    setNumber: setNumber,
    isWarmup: isWarmup,
    isCompleted: isCompleted,
    side: BodySide.none,
    createdAt: _epoch,
    updatedAt: _epoch,
    isDeleted: false,
    plannedWeightKg: plannedWeightKg,
    plannedReps: plannedReps,
    actualWeightKg: actualWeightKg,
    actualReps: actualReps,
    rpe: rpe,
    rir: rir,
    comment: comment,
  );
}

/// Builds a full 31-column row by column name, defaulting every unmentioned
/// column to an empty cell -- self-consistent against [workoutsCsvHeader]
/// regardless of column order, and much less error-prone than hand-counting
/// 31 positional commas.
List<String> _cells(Map<String, String> overrides) {
  return [for (final column in workoutsCsvHeader) overrides[column] ?? ''];
}

void main() {
  test(
    'golden dataset: full field mapping, workout_date/workout_id sorting, '
    'the empty-workout and empty-exercise row rules, and RFC 4180 escaping',
    () {
      final squat = _exercise(id: 'squat', name: 'Squat');
      final bench = _exercise(id: 'bench', name: 'Bench Press');

      final w1 = WorkoutDetails(
        workout: Workout(
          id: 'w1',
          date: DateTime(2026, 7, 1),
          name: 'Leg day',
          status: WorkoutStatus.completed,
          comment: 'Great session, "felt strong"',
          actualDurationSec: 2700,
          createdAt: _epoch,
          updatedAt: _epoch,
          isDeleted: false,
        ),
        tags: [
          WorkoutTag(
            id: 't1',
            name: 'Leg',
            colorHex: '#123456',
            isHidden: false,
            createdAt: _epoch,
            updatedAt: _epoch,
            isDeleted: false,
          ),
        ],
        exercises: [
          WorkoutExerciseDetails(
            exercise: squat,
            workoutExercise: WorkoutExercise(
              id: 'we1',
              workoutId: 'w1',
              exerciseId: 'squat',
              orderIndex: 0,
              comment: 'focus on depth',
              progressionDecision: ProgressionDecision.increase,
              createdAt: _epoch,
              updatedAt: _epoch,
              isDeleted: false,
            ),
            sets: [
              _set(
                id: 's1',
                setNumber: 1,
                isWarmup: true,
                isCompleted: true,
                plannedWeightKg: 40,
                plannedReps: 10,
                actualWeightKg: 40,
                actualReps: 10,
              ),
              _set(
                id: 's2',
                setNumber: 2,
                isWarmup: false,
                isCompleted: true,
                plannedWeightKg: 100,
                plannedReps: 5,
                actualWeightKg: 102.5,
                actualReps: 5,
                rpe: 8.5,
                rir: 2,
                comment: 'New PR!\nFelt easy',
              ),
            ],
          ),
        ],
      );

      // No exercises at all -- "Тренировка без упражнений — одна строка с
      // пустыми полями подхода" (TS 10.3).
      final w2 = WorkoutDetails(
        workout: Workout(
          id: 'w2',
          date: DateTime(2026, 7, 2),
          status: WorkoutStatus.draft,
          createdAt: _epoch,
          updatedAt: _epoch,
          isDeleted: false,
        ),
        exercises: const [],
      );

      // An exercise with zero sets -- same rule extended one level deeper.
      final w3 = WorkoutDetails(
        workout: Workout(
          id: 'w3',
          date: DateTime(2026, 7, 3),
          name: 'Bench day',
          status: WorkoutStatus.planned,
          createdAt: _epoch,
          updatedAt: _epoch,
          isDeleted: false,
        ),
        exercises: [
          WorkoutExerciseDetails(
            exercise: bench,
            workoutExercise: WorkoutExercise(
              id: 'we3',
              workoutId: 'w3',
              exerciseId: 'bench',
              orderIndex: 0,
              progressionDecision: ProgressionDecision.none,
              createdAt: _epoch,
              updatedAt: _epoch,
              isDeleted: false,
            ),
            sets: const [],
          ),
        ],
      );

      // Passed out of date order to also exercise the workout_date sort
      // rule (TS 10.3).
      final csv = buildWorkoutsCsv([w3, w1, w2]);

      final expected = StringBuffer()
        ..write(csvRow(workoutsCsvHeader))
        ..write(
          csvRow(
            _cells({
              'exercise_name': 'Squat',
              'exercise_id': 'squat',
              'exercise_type': 'strength',
              'workout_id': 'w1',
              'workout_date': '2026-07-01',
              'workout_name': 'Leg day',
              'workout_status': 'completed',
              'workout_tags': 'Leg',
              'workout_comment': 'Great session, "felt strong"',
              'workout_duration_sec': '2700',
              'exercise_order': '0',
              'exercise_comment': 'focus on depth',
              'progression_decision': 'increase',
              'set_number': '1',
              'is_warmup': 'true',
              'is_completed': 'true',
              'planned_weight_kg': '40.0',
              'planned_reps': '10',
              'actual_weight_kg': '40.0',
              'actual_reps': '10',
              'side': 'none',
            }),
          ),
        )
        ..write(
          csvRow(
            _cells({
              'exercise_name': 'Squat',
              'exercise_id': 'squat',
              'exercise_type': 'strength',
              'workout_id': 'w1',
              'workout_date': '2026-07-01',
              'workout_name': 'Leg day',
              'workout_status': 'completed',
              'workout_tags': 'Leg',
              'workout_comment': 'Great session, "felt strong"',
              'workout_duration_sec': '2700',
              'exercise_order': '0',
              'exercise_comment': 'focus on depth',
              'progression_decision': 'increase',
              'set_number': '2',
              'is_warmup': 'false',
              'is_completed': 'true',
              'planned_weight_kg': '100.0',
              'planned_reps': '5',
              'actual_weight_kg': '102.5',
              'actual_reps': '5',
              'rpe': '8.5',
              'rir': '2',
              'side': 'none',
              'set_comment': 'New PR!\nFelt easy',
            }),
          ),
        )
        ..write(
          csvRow(
            _cells({'workout_id': 'w2', 'workout_date': '2026-07-02', 'workout_status': 'draft'}),
          ),
        )
        ..write(
          csvRow(
            _cells({
              'exercise_name': 'Bench Press',
              'exercise_id': 'bench',
              'exercise_type': 'strength',
              'workout_id': 'w3',
              'workout_date': '2026-07-03',
              'workout_name': 'Bench day',
              'workout_status': 'planned',
              'exercise_order': '0',
              'progression_decision': 'none',
            }),
          ),
        );

      expect(csv, expected.toString());
    },
  );

  test('a workout with two exercises orders rows by exercise_order', () {
    final a = _exercise(id: 'a', name: 'A');
    final b = _exercise(id: 'b', name: 'B');
    final workout = Workout(
      id: 'w',
      date: DateTime(2026, 7, 1),
      status: WorkoutStatus.completed,
      createdAt: _epoch,
      updatedAt: _epoch,
      isDeleted: false,
    );

    final details = WorkoutDetails(
      workout: workout,
      exercises: [
        // Second in the list but orderIndex 0 -- should still come first.
        WorkoutExerciseDetails(
          exercise: b,
          workoutExercise: WorkoutExercise(
            id: 'we-b',
            workoutId: 'w',
            exerciseId: 'b',
            orderIndex: 1,
            progressionDecision: ProgressionDecision.none,
            createdAt: _epoch,
            updatedAt: _epoch,
            isDeleted: false,
          ),
          sets: const [],
        ),
        WorkoutExerciseDetails(
          exercise: a,
          workoutExercise: WorkoutExercise(
            id: 'we-a',
            workoutId: 'w',
            exerciseId: 'a',
            orderIndex: 0,
            progressionDecision: ProgressionDecision.none,
            createdAt: _epoch,
            updatedAt: _epoch,
            isDeleted: false,
          ),
          sets: const [],
        ),
      ],
    );

    final csv = buildWorkoutsCsv([details]);
    final lines = csv.split('\r\n');
    // lines[0] = header, lines[1] = exercise a's row, lines[2] = exercise
    // b's row, lines[3] = trailing empty split artifact.
    expect(lines[1], startsWith('A,a,strength'));
    expect(lines[2], startsWith('B,b,strength'));
  });
}
