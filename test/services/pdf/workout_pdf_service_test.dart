import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/models/exercise.dart';
import 'package:gymlog/domain/models/exercise_set.dart';
import 'package:gymlog/domain/models/personal_record.dart';
import 'package:gymlog/domain/models/user_profile.dart';
import 'package:gymlog/domain/models/workout.dart';
import 'package:gymlog/domain/models/workout_details.dart';
import 'package:gymlog/domain/models/workout_exercise.dart';
import 'package:gymlog/domain/models/workout_tag.dart';
import 'package:gymlog/l10n/app_localizations_en.dart';
import 'package:gymlog/services/pdf/workout_pdf_service.dart';

/// The smallest well-formed PNG (1x1, single pixel) -- same fixture already
/// used by `test/features/profile/profile_screen_test.dart`'s avatar tests;
/// `pw.MemoryImage` genuinely decodes the bytes (via `package:image`), so a
/// real image is required, not just any file.
final _tinyPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY'
  '42YAAAAASUVORK5CYII=',
);

Workout _workout({
  String? name,
  String? comment,
  int? actualDurationSec,
}) {
  return Workout(
    id: 'w1',
    date: DateTime(2026, 7, 30),
    status: WorkoutStatus.completed,
    name: name,
    comment: comment,
    actualDurationSec: actualDurationSec,
    createdAt: DateTime.utc(2026, 7, 30),
    updatedAt: DateTime.utc(2026, 7, 30),
    isDeleted: false,
  );
}

WorkoutExerciseDetails _exerciseDetails({
  String exerciseId = 'squat',
  String exerciseName = 'Squat',
  String? comment,
  List<ExerciseSet> sets = const [],
}) {
  return WorkoutExerciseDetails(
    workoutExercise: WorkoutExercise(
      id: 'we1',
      workoutId: 'w1',
      exerciseId: exerciseId,
      orderIndex: 0,
      comment: comment,
      progressionDecision: ProgressionDecision.none,
      createdAt: DateTime.utc(2026, 7, 30),
      updatedAt: DateTime.utc(2026, 7, 30),
      isDeleted: false,
    ),
    exercise: Exercise(
      id: exerciseId,
      name: exerciseName,
      exerciseType: ExerciseType.strength,
      effortMetric: EffortMetric.none,
      isBuiltIn: true,
      isArchived: false,
      secondaryMuscleGroupIds: const [],
      createdAt: DateTime.utc(2026, 7, 30),
      updatedAt: DateTime.utc(2026, 7, 30),
      isDeleted: false,
    ),
    sets: sets,
  );
}

ExerciseSet _set({
  int setNumber = 1,
  double? plannedWeightKg,
  int? plannedReps,
  double? actualWeightKg,
  int? actualReps,
  bool isCompleted = false,
}) {
  return ExerciseSet(
    id: 's$setNumber',
    workoutExerciseId: 'we1',
    setNumber: setNumber,
    isCompleted: isCompleted,
    side: BodySide.none,
    plannedWeightKg: plannedWeightKg,
    plannedReps: plannedReps,
    actualWeightKg: actualWeightKg,
    actualReps: actualReps,
    createdAt: DateTime.utc(2026, 7, 30),
    updatedAt: DateTime.utc(2026, 7, 30),
    isDeleted: false,
  );
}

final _emptyProfile = UserProfile(
  nickname: null,
  firstName: null,
  lastName: null,
  avatarPath: null,
  updatedAt: DateTime.utc(2026, 7, 30),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final l10n = AppLocalizationsEn();
  const service = WorkoutPdfService();

  test('produces valid PDF bytes for a full workout with exercise, sets, '
      'tags, comment and a new record', () async {
    final details = WorkoutDetails(
      workout: _workout(
        name: 'Leg day',
        comment: 'Felt strong today',
        actualDurationSec: 3661,
      ),
      exercises: [
        _exerciseDetails(
          comment: 'Go heavy',
          sets: [
            _set(
              setNumber: 1,
              plannedWeightKg: 100,
              plannedReps: 5,
              actualWeightKg: 102.5,
              actualReps: 5,
              isCompleted: true,
            ),
          ],
        ),
      ],
      tags: [
        WorkoutTag(
          id: 'legs',
          name: 'Legs',
          colorHex: '#4C7BD9',
          isHidden: false,
          createdAt: DateTime.utc(2026, 7, 30),
          updatedAt: DateTime.utc(2026, 7, 30),
          isDeleted: false,
        ),
      ],
    );
    final profile = UserProfile(
      nickname: 'maks',
      firstName: 'Maksim',
      lastName: 'Pekshev',
      avatarPath: null,
      updatedAt: DateTime.utc(2026, 7, 30),
    );
    final newRecords = {
      'squat': [
        PersonalRecord(
          exerciseId: 'squat',
          recordType: RecordType.maxWeight,
          value: 102.5,
          workoutId: 'w1',
          achievedAt: DateTime(2026, 7, 30),
          computedAt: DateTime.utc(2026, 7, 30),
        ),
      ],
    };

    final bytes = await service.buildWorkoutPdf(
      details: details,
      profile: profile,
      newRecordsByExerciseId: newRecords,
      l10n: l10n,
    );

    expect(bytes.length, greaterThan(500));
    expect(utf8.decode(bytes.sublist(0, 5), allowMalformed: true), '%PDF-');
  });

  test('produces valid PDF bytes for a workout with no exercises', () async {
    final details = WorkoutDetails(
      workout: _workout(),
      exercises: const [],
    );

    final bytes = await service.buildWorkoutPdf(
      details: details,
      profile: _emptyProfile,
      newRecordsByExerciseId: const {},
      l10n: l10n,
    );

    expect(bytes.length, greaterThan(200));
    expect(utf8.decode(bytes.sublist(0, 5), allowMalformed: true), '%PDF-');
  });

  test('does not crash when the profile has no name fields set', () async {
    final details = WorkoutDetails(
      workout: _workout(),
      exercises: [_exerciseDetails()],
    );

    final bytes = await service.buildWorkoutPdf(
      details: details,
      profile: _emptyProfile,
      newRecordsByExerciseId: const {},
      l10n: l10n,
    );

    expect(utf8.decode(bytes.sublist(0, 5), allowMalformed: true), '%PDF-');
  });

  test('embeds a real avatar image without crashing', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'gymlog_pdf_test_',
    );
    addTearDown(() async {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });
    final avatarFile = File(
      '${tempDir.path}${Platform.pathSeparator}avatar.png',
    );
    await avatarFile.writeAsBytes(_tinyPng);

    final details = WorkoutDetails(
      workout: _workout(),
      exercises: [_exerciseDetails()],
    );
    final profile = UserProfile(
      nickname: null,
      firstName: 'Max',
      lastName: null,
      avatarPath: avatarFile.path,
      updatedAt: DateTime.utc(2026, 7, 30),
    );

    final bytes = await service.buildWorkoutPdf(
      details: details,
      profile: profile,
      newRecordsByExerciseId: const {},
      l10n: l10n,
    );

    expect(utf8.decode(bytes.sublist(0, 5), allowMalformed: true), '%PDF-');
  });

  test(
    'handles Cyrillic workout/exercise names, comments, and profile name '
    'without crashing (the whole reason a bundled Roboto font was needed)',
    () async {
      final details = WorkoutDetails(
        workout: _workout(
          name: 'Тренировка ног',
          comment: 'Отличная тренировка, устал как собака!',
        ),
        exercises: [
          _exerciseDetails(
            exerciseName: 'Приседания со штангой',
            comment: 'Работать над техникой',
            sets: [
              _set(
                setNumber: 1,
                plannedWeightKg: 100,
                plannedReps: 5,
                actualWeightKg: 100,
                actualReps: 5,
                isCompleted: true,
              ),
            ],
          ),
        ],
        tags: [
          WorkoutTag(
            id: 'legs',
            name: 'Ноги',
            colorHex: '#4C7BD9',
            isHidden: false,
            createdAt: DateTime.utc(2026, 7, 30),
            updatedAt: DateTime.utc(2026, 7, 30),
            isDeleted: false,
          ),
        ],
      );
      final profile = UserProfile(
        nickname: null,
        firstName: 'Максим',
        lastName: 'Пекшев',
        avatarPath: null,
        updatedAt: DateTime.utc(2026, 7, 30),
      );

      final bytes = await service.buildWorkoutPdf(
        details: details,
        profile: profile,
        newRecordsByExerciseId: const {},
        l10n: l10n,
      );

      expect(bytes.length, greaterThan(500));
      expect(utf8.decode(bytes.sublist(0, 5), allowMalformed: true), '%PDF-');
    },
  );
}
