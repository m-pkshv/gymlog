import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/providers.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/logger.dart';
import 'data/database.dart';
import 'data/seed/seed_runner.dart';
import 'l10n/app_localizations.dart';

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

  runApp(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const GymLogApp(),
    ),
  );
}

class GymLogApp extends StatelessWidget {
  const GymLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      // Default per UX 9; a settings-driven override lands with Stage 9.
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
    );
  }
}
