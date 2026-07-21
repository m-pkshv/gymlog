import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/models/exercise.dart';
import 'package:gymlog/services/export/exercises_csv.dart';

final _epoch = DateTime(2026, 1, 1);

void main() {
  test(
    'golden dataset: full field mapping (including archived built-ins), '
    'secondary_muscles joined by ";", id sorting, and RFC 4180 escaping',
    () {
      final benchPress = Exercise(
        id: 'bench_press',
        name: 'Bench Press',
        exerciseType: ExerciseType.strength,
        effortMetric: EffortMetric.rpe,
        isBuiltIn: true,
        isArchived: false,
        primaryMuscleGroupId: 'chest',
        equipmentId: 'barbell',
        secondaryMuscleGroupIds: const ['triceps', 'shoulders'],
        description: 'A compound press, "great" for chest',
        createdAt: _epoch,
        updatedAt: _epoch,
        isDeleted: false,
      );
      final customExercise = Exercise(
        id: 'custom_ex',
        name: 'My exercise',
        exerciseType: ExerciseType.reps,
        effortMetric: EffortMetric.none,
        isBuiltIn: false,
        // Archived exercises are still exported (TS 10.1: "история на них
        // ссылается").
        isArchived: true,
        secondaryMuscleGroupIds: const [],
        youtubeUrl: 'https://youtube.com/x',
        createdAt: _epoch,
        updatedAt: _epoch,
        isDeleted: false,
      );

      // Passed out of id order to also exercise the id sort.
      final csv = buildExercisesCsv([customExercise, benchPress]);

      expect(
        csv,
        'exercise_id,name,type,is_built_in,is_archived,primary_muscle,'
        'secondary_muscles,equipment,description,youtube_url\r\n'
        'bench_press,Bench Press,strength,true,false,chest,'
        'triceps;shoulders,barbell,"A compound press, ""great"" for chest",'
        '\r\n'
        'custom_ex,My exercise,reps,false,true,,,,,https://youtube.com/x\r\n',
      );
    },
  );
}
