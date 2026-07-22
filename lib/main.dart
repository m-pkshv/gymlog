import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/locale.dart';
import 'app/providers.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/logger.dart';
import 'data/database.dart';
import 'data/repositories_impl/app_settings_repository_impl.dart';
import 'data/seed/seed_runner.dart';
import 'domain/enums.dart';
import 'l10n/app_localizations.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Uncaught errors are logged instead of silently disappearing
  // (05_AI_INSTRUCTIONS.md, section 10: no swallowed errors) — in release
  // this is the only place these errors are recorded (TS 11.7).
  final logger = AppLogger();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    logger.error(
      details.exceptionAsString(),
      error: details.exception,
      stackTrace: details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    logger.error(error.toString(), error: error, stackTrace: stackTrace);
    return true;
  };

  // Reference data + the placeholder exercise catalog (DM 12) must exist
  // before any screen queries them; done once here, ahead of the first
  // frame, so the UI never has to special-case an unseeded database.
  final db = AppDatabase();
  await SeedRunner(db).run();
  // The settings singleton row (DM 6.12) must exist before any screen
  // watches it, same reasoning as the seed above.
  await AppSettingsRepositoryImpl(db).ensureInitialized();

  // Rest-timer notifications (Stage 4, TS 7.3, D-11): plugin/channel setup
  // happens once here, but *after* the first frame (Stage 10, TS 11.6
  // profiling: `initialize()` synchronously parses the whole IANA timezone
  // database and measurably delayed the first frame on every launch,
  // seeded or not). Nothing needs the channel to exist before the first
  // frame -- the actual permission *request* is contextual (first
  // rest-timer start) and every notification call is already wrapped in
  // its own try/catch by its callers (TS 7.3: "a notification failure must
  // never block the core workout flow"), so a call landing just before
  // `initialize()` finishes fails the same safe way a denied permission
  // does, instead of blocking startup.
  final notificationService = NotificationService(
    FlutterLocalNotificationsPlugin(),
  );

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const GymLogApp(),
    ),
  );

  unawaited(
    notificationService.initialize().catchError((Object error, StackTrace stackTrace) {
      logger.error(
        'Failed to initialize the notification service',
        error: error,
        stackTrace: stackTrace,
      );
    }),
  );
}

class GymLogApp extends ConsumerWidget {
  const GymLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `AppTheme.system`/`AppLocale.system` (table defaults) while the
    // settings row hasn't loaded yet — same as the pre-Stage-9 hardcoded
    // theme default and the implicit OS-locale resolution, so there's no
    // flash of the wrong theme/language before the first frame.
    final settings = ref.watch(appSettingsProvider).value;
    final theme = settings?.theme ?? AppTheme.system;
    final locale = settings?.locale ?? AppLocale.system;
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: flutterThemeMode(theme),
      locale: flutterLocale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
    );
  }
}
