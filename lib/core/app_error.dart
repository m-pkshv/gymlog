/// Typed application error surfaced by services instead of raw exceptions
/// (03_TECHNICAL_SPEC.md, section 4). Screens map each variant to a
/// localized ARB string (04_UI_UX_SPEC.md, section 6); [message] is only an
/// English fallback for logs/tests until that mapping exists.
sealed class AppError {
  const AppError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Database/storage exception caught and converted in the Data layer.
final class StorageError extends AppError {
  const StorageError([super.message = 'Storage operation failed']);
}

/// Hard validation rule violation that blocks the write: range, required
/// field, illegal status transition (06_DATA_MODEL.md, section 9).
final class ValidationError extends AppError {
  const ValidationError(super.message);
}

/// Anything unexpected that doesn't fit the categories above.
final class UnknownError extends AppError {
  const UnknownError([super.message = 'Unknown error', this.cause]);

  final Object? cause;
}
