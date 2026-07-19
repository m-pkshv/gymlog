import '../enums.dart';
import '../models/exercise.dart';

/// Storage contract for the exercise catalog (06_DATA_MODEL.md, section
/// 6.1). Implemented in the Data layer (D-13); services/UI depend only on
/// this interface, never on `AppDatabase` directly.
abstract class ExerciseRepository {
  /// Non-archived, non-deleted exercises. Stage 1's catalog list (S-06)
  /// has no search/filters yet — those arrive in Stage 2.
  Stream<List<Exercise>> watchAll();

  Future<Exercise?> getById(String id);

  /// Creates a user-created exercise with just a name and type (S-08,
  /// Stage 1 scope — the full form with muscles/equipment/description
  /// lands in Stage 2).
  Future<Exercise> create({
    required String name,
    required ExerciseType exerciseType,
  });
}
