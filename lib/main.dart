import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ProviderScope(child: GymLogApp()));
}

/// Placeholder root widget for Stage 0. Full theming, routing (go_router)
/// and localization are wired in a later Stage 0 step.
class GymLogApp extends StatelessWidget {
  const GymLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymLog',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4C7BD9))),
      home: const Scaffold(
        body: Center(child: Text('GymLog')),
      ),
    );
  }
}
