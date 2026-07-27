import 'package:integration_test/integration_test_driver.dart';

/// Driver entry point for running `integration_test/perf_test.dart` in
/// profile mode on a real device (Stage 10 frame-jank profiling, TS 11.6).
/// Usage:
///   flutter drive --driver=test_driver/perf_driver.dart \
///     --target=integration_test/perf_test.dart --profile -d DEVICE_ID
Future<void> main() => integrationDriver();
