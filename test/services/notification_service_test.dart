import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/services/notification_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

/// `hasRequestedPermission`/`markPermissionRequested` are the only parts of
/// `NotificationService` unit-testable without a real device or platform
/// channel mock -- they're pure `SharedPreferences` reads/writes
/// (`SharedPreferences.setMockInitialValues`, a standard test utility the
/// package ships for exactly this). The plugin-facing methods
/// (initialize/requestPermission/schedule/cancel) call
/// `resolvePlatformSpecificImplementation`, which dispatches on the actual
/// host platform -- meaningfully verifying those needs a real device
/// (same accepted-risk category as the rest of this project's Android/iOS
/// gaps); `workout_editor_flow_test.dart`'s "notifications" group instead
/// verifies the *screen's* orchestration logic by mocking
/// `NotificationService` as a whole.
void main() {
  late NotificationService service;
  late MockFlutterLocalNotificationsPlugin plugin;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    plugin = MockFlutterLocalNotificationsPlugin();
    service = NotificationService(plugin);
  });

  test(
    'hasRequestedPermission is false before markPermissionRequested is ever called',
    () async {
      expect(await service.hasRequestedPermission(), isFalse);
    },
  );

  test(
    'markPermissionRequested makes hasRequestedPermission true, and it persists',
    () async {
      await service.markPermissionRequested();

      expect(await service.hasRequestedPermission(), isTrue);

      // A fresh NotificationService instance (e.g. a new app session)
      // reading the same underlying SharedPreferences store still sees it.
      final another = NotificationService(plugin);
      expect(await another.hasRequestedPermission(), isTrue);
    },
  );
}
