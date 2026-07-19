/// Typed result of an operation that may fail. Services return this instead
/// of throwing, so controllers/UI always handle both outcomes explicitly
/// (03_TECHNICAL_SPEC.md, section 4).
sealed class Result<T, E> {
  const Result();

  bool get isOk => this is Ok<T, E>;

  bool get isErr => this is Err<T, E>;

  /// Calls [onOk] or [onErr] depending on the variant and returns its result.
  R fold<R>(R Function(T value) onOk, R Function(E error) onErr) {
    return switch (this) {
      Ok<T, E>(value: final value) => onOk(value),
      Err<T, E>(error: final error) => onErr(error),
    };
  }

  T? getOrNull() {
    return switch (this) {
      Ok<T, E>(value: final value) => value,
      Err<T, E>() => null,
    };
  }

  E? errorOrNull() {
    return switch (this) {
      Ok<T, E>() => null,
      Err<T, E>(error: final error) => error,
    };
  }

  /// Transforms the ok value, leaving an error result untouched.
  Result<R, E> map<R>(R Function(T value) transform) {
    return switch (this) {
      Ok<T, E>(value: final value) => Ok<R, E>(transform(value)),
      Err<T, E>(error: final error) => Err<R, E>(error),
    };
  }
}

final class Ok<T, E> extends Result<T, E> {
  const Ok(this.value);

  final T value;
}

final class Err<T, E> extends Result<T, E> {
  const Err(this.error);

  final E error;
}
