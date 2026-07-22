import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Local notifications for the rest timer (03_TECHNICAL_SPEC.md, sections
/// 7.2 step 3 and 7.3; D-11). A single fixed notification id is enough —
/// DM 6.4.1's "at most one inProgress workout" invariant means at most one
/// rest timer, and thus at most one pending notification, exists at a time.
/// Callers (the workout editor UI, which has `AppLocalizations`) supply
/// already-localized title/body text — this service has no access to the
/// widget tree's `Localizations`.
///
/// Every method here is meant to be called by the UI wrapped in its own
/// try/catch (matching the rest of this codebase's fire-and-forget side
/// effects): a notification failure must never block the core workout flow
/// (TS 7.3: "Отказ: таймер работает внутри приложения").
/// [hasRequestedPermission] fails *open* (returns true, i.e. "assume
/// already asked") rather than *closed* on any error reading the stored
/// flag — safer than risking a repeated, unwanted prompt.
class NotificationService {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const _restTimerNotificationId = 1;
  static const _restTimerChannelId = 'rest_timer';
  static const _restTimerChannelName = 'Rest timer';
  static const _permissionRequestedKey = 'notifications_permission_requested';

  /// Sets up the plugin and the Android notification channel. Called once
  /// at app startup (`main.dart`) — this is setup, not the TS 7.3 permission
  /// request, which stays contextual (first rest-timer start only).
  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _restTimerChannelId,
            _restTimerChannelName,
            importance: Importance.high,
          ),
        );
  }

  /// TS 7.3: "запрос... повторный автоматический запрос не выполняется" —
  /// tracked here (SharedPreferences, D-18: a non-critical UI flag, not
  /// main app data) since the OS itself doesn't expose "have we already
  /// asked". Fails open (`true`) on any error reading the flag.
  Future<bool> hasRequestedPermission() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_permissionRequestedKey) ?? false;
    } catch (_) {
      return true;
    }
  }

  Future<void> markPermissionRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionRequestedKey, true);
  }

  /// The actual OS permission prompt — call only after the caller's own
  /// contextual rationale dialog (TS 7.3: "с предварительным пояснительным
  /// диалогом").
  Future<void> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      await android.requestNotificationsPermission();
      return;
    }
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Drives the "Уведомления выключены" hint (TS 7.3) — assumed enabled on
  /// platforms/versions where this plugin exposes no reliable check, since
  /// the hint is meant to be unobtrusive, not a hard gate on the in-app
  /// timer (which always works regardless).
  Future<bool> areNotificationsEnabled() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.areNotificationsEnabled() ?? true;
    }
    return true;
  }

  /// Schedules (replacing any previously pending one) the "Отдых окончен —
  /// следующий подход" notification for [endsAtUtc] — inexact
  /// (`AndroidScheduleMode.inexactAllowWhileIdle`, TS 7.3: exact scheduling
  /// needs a separate permission this app doesn't request; ~1 min slop is
  /// accepted, and the in-app timer itself stays exact, anchor-based).
  Future<void> scheduleRestTimerEndNotification({
    required String title,
    required String body,
    required DateTime endsAtUtc,
  }) async {
    await _plugin.zonedSchedule(
      id: _restTimerNotificationId,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(endsAtUtc, tz.UTC),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _restTimerChannelId,
          _restTimerChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelRestTimerEndNotification() =>
      _plugin.cancel(id: _restTimerNotificationId);

  /// Opens the OS-level app settings screen (S-17, 04_UI_UX_SPEC.md,
  /// section 5: "Уведомления" -- статус + переход в системные настройки),
  /// via `permission_handler`, since neither platform exposes a
  /// notification-specific deep link through `flutter_local_notifications`
  /// itself. Returns whether a settings screen could be opened at all.
  Future<bool> openNotificationSettings() =>
      permission_handler.openAppSettings();
}
