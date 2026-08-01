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
  static const _exactAlarmPermissionRequestedKey =
      'exact_alarm_permission_requested';

  /// Sets up the plugin and the Android notification channel. Called once
  /// at app startup (`main.dart`) — this is setup, not the TS 7.3 permission
  /// request, which stays contextual (first rest-timer start only).
  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    await _plugin.initialize(
      // `ic_notification` (android/app/src/main/res/drawable), not the app
      // launcher icon: `@mipmap/ic_launcher` became an adaptive icon on
      // Stage 12 (foreground+background layers), and several OEM skins
      // (MIUI observed, owner-reported) silently drop a notification whose
      // small icon resolves to an adaptive icon instead of a plain
      // silhouette -- no crash, no logcat error, the scheduled alarm still
      // fires (confirmed via `dumpsys alarm`), the notification just never
      // reaches the tray.
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
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

  /// Same "asked once, never re-prompt automatically" tracking as
  /// [hasRequestedPermission]/[markPermissionRequested], for the exact-alarm
  /// permission specifically (Stage 12).
  Future<bool> hasRequestedExactAlarmPermission() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_exactAlarmPermissionRequestedKey) ?? false;
    } catch (_) {
      return true;
    }
  }

  Future<void> markExactAlarmPermissionRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_exactAlarmPermissionRequestedKey, true);
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

  /// Whether the OS will let [scheduleRestTimerEndNotification]'s
  /// `AndroidScheduleMode.alarmClock` call succeed. Always `true` on iOS
  /// (this is an Android-only special access, `permission_handler` reports
  /// `granted` there by default). On Android this is normally auto-granted,
  /// except Android 14+ (API 34), which requires the user to flip it on
  /// manually via the "Alarms & reminders" settings screen (owner-reported,
  /// Stage 12 -- see the AndroidManifest.xml comment on this permission for
  /// how that was diagnosed).
  Future<bool> hasExactAlarmPermission() async {
    final status = await permission_handler.Permission.scheduleExactAlarm.status;
    return status.isGranted;
  }

  /// Opens the OS "Alarms & reminders" settings screen for this app (no
  /// runtime dialog exists for this permission, unlike
  /// [requestPermission]) -- call only after the caller's own contextual
  /// rationale, same as that method.
  Future<void> requestExactAlarmPermission() async {
    await permission_handler.Permission.scheduleExactAlarm.request();
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
  /// следующий подход" notification for [endsAtUtc].
  ///
  /// `AndroidScheduleMode.alarmClock` (`AlarmManager.setAlarmClock()`), not
  /// `inexactAllowWhileIdle` (TS 7.3's original choice): confirmed
  /// owner-reported on a real MIUI/HyperOS device, live-tested via the
  /// diagnostic buttons in Settings ("Уведомления") -- an immediate
  /// `.show()` notification always appeared, but a `zonedSchedule` call with
  /// `inexactAllowWhileIdle` never did, scheduled 10s ahead or as the real
  /// rest timer, screen locked or not, autostart granted or not. The alarm
  /// itself always fired on time (confirmed via `dumpsys alarm`/logcat --
  /// the app process woke specifically for it every time); the OS-level
  /// delivery of a notification posted from that background-woken receiver
  /// was what silently never reached the tray. `alarmClock` is exempt from
  /// Doze/battery-optimization restrictions on all Android versions without
  /// any extra permission (unlike `exact`/`exactAllowWhileIdle`, which need
  /// `SCHEDULE_EXACT_ALARM` on API 31+) -- the standard, most reliable
  /// delivery mode precisely for this failure pattern on OEM skins.
  /// Trade-off, accepted by the owner before switching: Android shows a
  /// small alarm-clock glyph in the status bar while the alarm is pending,
  /// which reads as fitting for a running timer rather than out of place.
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
      androidScheduleMode: AndroidScheduleMode.alarmClock,
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
