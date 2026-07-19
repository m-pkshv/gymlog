import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/app_error.dart';
import 'package:gymlog/core/result.dart';

void main() {
  group('Result', () {
    test('Ok exposes the value and isOk/isErr flags', () {
      const result = Ok<int, AppError>(42);

      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
      expect(result.getOrNull(), 42);
      expect(result.errorOrNull(), isNull);
    });

    test('Err exposes the error and isOk/isErr flags', () {
      const result = Err<int, AppError>(ValidationError('bad input'));

      expect(result.isOk, isFalse);
      expect(result.isErr, isTrue);
      expect(result.getOrNull(), isNull);
      expect(result.errorOrNull(), isA<ValidationError>());
    });

    test('fold calls the matching branch', () {
      const ok = Ok<int, AppError>(10);
      const err = Err<int, AppError>(StorageError());

      expect(ok.fold((value) => value * 2, (_) => -1), 20);
      expect(err.fold((value) => value * 2, (_) => -1), -1);
    });

    test('map transforms the ok value and passes errors through unchanged', () {
      const ok = Ok<int, AppError>(2);
      const err = Err<int, AppError>(StorageError());

      expect(ok.map((value) => value.toString()).getOrNull(), '2');
      expect(
        err.map((value) => value.toString()).errorOrNull(),
        isA<StorageError>(),
      );
    });
  });
}
