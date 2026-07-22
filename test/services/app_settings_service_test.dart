import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/app_error.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/app_settings_repository_impl.dart';
import 'package:gymlog/services/app_settings_service.dart';

void main() {
  late AppDatabase db;
  late AppSettingsRepositoryImpl repository;
  late AppSettingsService service;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = AppSettingsRepositoryImpl(db);
    await repository.ensureInitialized();
    service = AppSettingsService(repository);
  });

  tearDown(() async {
    await db.close();
  });

  test('setDefaultRestTimerSec persists a value within 10-600 (DM 6.12, Q-4)', () async {
    final result = await service.setDefaultRestTimerSec(90);

    expect(result.isOk, isTrue);
    expect(result.getOrNull(), 90);
    expect(
      (await repository.watchSettings().first).defaultRestTimerSec,
      90,
    );
  });

  test('accepts the lower bound (10 seconds)', () async {
    final result = await service.setDefaultRestTimerSec(10);
    expect(result.isOk, isTrue);
  });

  test('accepts the upper bound (600 seconds)', () async {
    final result = await service.setDefaultRestTimerSec(600);
    expect(result.isOk, isTrue);
  });

  test('rejects a value below 10 seconds, without writing it', () async {
    final result = await service.setDefaultRestTimerSec(9);

    expect(result.errorOrNull(), isA<ValidationError>());
    expect(
      (await repository.watchSettings().first).defaultRestTimerSec,
      120,
    );
  });

  test('rejects a value above 600 seconds, without writing it', () async {
    final result = await service.setDefaultRestTimerSec(601);

    expect(result.errorOrNull(), isA<ValidationError>());
    expect(
      (await repository.watchSettings().first).defaultRestTimerSec,
      120,
    );
  });
}
