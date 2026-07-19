import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:path_provider/path_provider.dart';

/// Local, offline logger (03_TECHNICAL_SPEC.md, section 11.7): debug/info/
/// error levels, never sent over the network. Outside release builds,
/// every level goes to the console (`dart:developer` log, visible in
/// DevTools/`flutter logs`) and nothing is written to disk. In release,
/// only `error` is kept — appended to a single log file capped at ~1 MB so
/// a device never accumulates unbounded log data.
///
/// [isReleaseBuild] and [logDirectory] are injectable so tests can exercise
/// the file-rotation behavior deterministically instead of depending on the
/// compile-time `kReleaseMode` constant or the real platform directory.
class AppLogger {
  AppLogger({bool? isReleaseBuild, Future<Directory> Function()? logDirectory})
    : _isReleaseBuild = isReleaseBuild ?? kReleaseMode,
      _logDirectory = logDirectory ?? getApplicationSupportDirectory;

  /// Size cap before the log file is rotated (truncated and restarted).
  static const int maxLogFileBytes = 1024 * 1024;

  static const String logFileName = 'app.log';

  final bool _isReleaseBuild;
  final Future<Directory> Function() _logDirectory;

  void debug(String message) =>
      _console(message, level: 500, name: 'gymlog.debug');

  void info(String message) =>
      _console(message, level: 800, name: 'gymlog.info');

  /// Logs an error. Returns a [Future] so callers that care about the file
  /// write completing (mainly tests) can await it; normal call sites are
  /// free to fire-and-forget.
  Future<void> error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) async {
    _console(
      message,
      level: 1000,
      name: 'gymlog.error',
      error: error,
      stackTrace: stackTrace,
    );
    if (_isReleaseBuild) {
      await _appendToFile(message, error, stackTrace);
    }
  }

  void _console(
    String message, {
    required int level,
    required String name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (_isReleaseBuild) return;
    developer.log(
      message,
      level: level,
      name: name,
      error: error,
      stackTrace: stackTrace,
    );
  }

  Future<void> _appendToFile(
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) async {
    try {
      final dir = await _logDirectory();
      final file = File('${dir.path}/$logFileName');
      if (await file.exists() && await file.length() >= maxLogFileBytes) {
        // Rotate: this app only ever persists errors, so truncating keeps
        // the most recent ones rather than the oldest.
        await file.writeAsString('');
      }

      final buffer = StringBuffer()
        ..write(DateTime.now().toUtc().toIso8601String())
        ..write(' ERROR ')
        ..write(message);
      if (error != null) buffer.write(' | $error');
      if (stackTrace != null) buffer.write('\n$stackTrace');
      buffer.write('\n');

      await file.writeAsString(
        buffer.toString(),
        mode: FileMode.append,
        flush: true,
      );
    } catch (_) {
      // Logging must never crash the app.
    }
  }
}
