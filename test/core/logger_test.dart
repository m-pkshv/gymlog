import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/logger.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('gymlog_logger_test');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('debug/info never throw, regardless of build mode', () {
    final logger = AppLogger(isReleaseBuild: false, logDirectory: () async => tempDir);

    expect(() => logger.debug('hello'), returnsNormally);
    expect(() => logger.info('hello'), returnsNormally);
  });

  test('outside release builds, error does not write a log file', () async {
    final logger = AppLogger(isReleaseBuild: false, logDirectory: () async => tempDir);

    await logger.error('should not persist');

    final file = File('${tempDir.path}/${AppLogger.logFileName}');
    expect(await file.exists(), isFalse);
  });

  test('in release builds, error is appended to the log file', () async {
    final logger = AppLogger(isReleaseBuild: true, logDirectory: () async => tempDir);

    await logger.error('boom', error: Exception('bad'));

    final file = File('${tempDir.path}/${AppLogger.logFileName}');
    expect(await file.exists(), isTrue);
    final content = await file.readAsString();
    expect(content, contains('ERROR boom'));
    expect(content, contains('bad'));
  });

  test('a second error appends rather than overwriting', () async {
    final logger = AppLogger(isReleaseBuild: true, logDirectory: () async => tempDir);

    await logger.error('first');
    await logger.error('second');

    final file = File('${tempDir.path}/${AppLogger.logFileName}');
    final content = await file.readAsString();
    expect(content, contains('first'));
    expect(content, contains('second'));
  });

  test('the log file rotates once it reaches the size cap', () async {
    final logger = AppLogger(isReleaseBuild: true, logDirectory: () async => tempDir);
    final file = File('${tempDir.path}/${AppLogger.logFileName}');
    await file.create(recursive: true);
    // Pre-fill the file to the cap so the next error triggers rotation.
    await file.writeAsBytes(List.filled(AppLogger.maxLogFileBytes, 0));

    await logger.error('after rotation');

    final content = await file.readAsString();
    expect(content, contains('after rotation'));
    expect(content.length, lessThan(AppLogger.maxLogFileBytes));
  });
}
