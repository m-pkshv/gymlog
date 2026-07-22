import '../core/app_error.dart';
import '../core/constants.dart';
import '../core/result.dart';
import '../domain/repositories/app_settings_repository.dart';

/// The single point of truth for `AppSettings` values that need validation
/// beyond "it's a valid enum/bool" (06_DATA_MODEL.md, section 6.12) — only
/// [defaultRestTimerSec] qualifies so far (Q-4: 10-600 seconds). The other
/// setters (`showTags`, `unitSystem`, `theme`, `locale`, `restTimerAutoStart`)
/// have no business rule beyond "it's one of the enum's/bool's values", so
/// the UI calls `AppSettingsRepository` for those directly, same as
/// `WorkoutTagService`'s doc comment explains for tag assignment.
class AppSettingsService {
  AppSettingsService(this._repository);

  final AppSettingsRepository _repository;

  /// DM 6.12, Q-4: 10-600 seconds.
  Future<Result<int, AppError>> setDefaultRestTimerSec(int seconds) async {
    if (seconds < RestTimerRules.minSeconds ||
        seconds > RestTimerRules.maxSeconds) {
      return Err(
        ValidationError(
          'Rest timer must be ${RestTimerRules.minSeconds}-'
          '${RestTimerRules.maxSeconds} seconds',
        ),
      );
    }
    await _repository.setDefaultRestTimerSec(seconds);
    return Ok(seconds);
  }
}
