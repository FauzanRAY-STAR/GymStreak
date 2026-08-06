import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/workout_schedule.dart';
import '../repositories/user_settings_repository.dart';
import '../repositories/workout_schedule_repository.dart';
import '../repositories/workout_session_repository.dart';

/// Mengelola local notification milik GymStreak.
///
/// Pengingat dijadwalkan mingguan berdasarkan [WorkoutSchedule]. Mode
/// `inexactAllowWhileIdle` dipakai agar aplikasi tidak perlu meminta izin
/// exact alarm pada Android versi baru.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const MethodChannel _timezoneChannel = MethodChannel(
    'gymstreak/device_timezone',
  );
  static const String _scheduledIdsKey = 'gymstreak_scheduled_notification_ids';
  static const String _channelId = 'workout_reminders';
  static const String _channelName = 'Pengingat Workout';
  static const String _channelDescription =
      'Pengingat jadwal workout mingguan GymStreak';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  bool get _isSupportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  Future<void> initialize() async {
    if (_initialized || !_isSupportedPlatform) return;

    tz.initializeTimeZones();
    await _configureLocalTimezone();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (_) {
        // Deep-link ke halaman workout dapat ditambahkan di tahap berikutnya.
      },
    );
    _initialized = true;
  }

  Future<void> _configureLocalTimezone() async {
    var timezoneId = _fallbackTimezoneId();

    try {
      final nativeTimezone = await _timezoneChannel.invokeMethod<String>(
        'getLocalTimezone',
      );
      if (nativeTimezone != null && nativeTimezone.isNotEmpty) {
        timezoneId = nativeTimezone;
      }
    } on PlatformException {
      // Gunakan fallback berdasarkan UTC offset perangkat.
    } on MissingPluginException {
      // Platform belum memiliki implementasi native.
    }

    try {
      tz.setLocalLocation(tz.getLocation(timezoneId));
    } on ArgumentError {
      tz.setLocalLocation(tz.getLocation(_fallbackTimezoneId()));
    }
  }

  String _fallbackTimezoneId() {
    switch (DateTime.now().timeZoneOffset.inHours) {
      case 7:
        return 'Asia/Jakarta';
      case 8:
        return 'Asia/Makassar';
      case 9:
        return 'Asia/Jayapura';
      default:
        return 'UTC';
    }
  }

  /// Meminta izin notifikasi pada platform yang membutuhkannya.
  Future<bool> requestPermission() async {
    await initialize();
    if (!_isSupportedPlatform) return false;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      return result ?? true;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }

    return false;
  }

  /// Membaca pengaturan dan jadwal terbaru dari database, kemudian
  /// menjadwalkan ulang seluruh pengingat.
  Future<bool> syncFromStoredSettings({bool requestPermission = false}) async {
    final settings = await UserSettingsRepository().getSettings();
    if (settings == null) {
      await cancelWorkoutReminders();
      return false;
    }

    final schedules = await WorkoutScheduleRepository().getActive();
    return syncWorkoutReminders(
      schedules: schedules,
      reminderEnabled: settings.reminderEnabled,
      secondReminderEnabled: settings.secondReminderEnabled,
      requestPermission: requestPermission,
    );
  }

  Future<bool> syncWorkoutReminders({
    required List<WorkoutSchedule> schedules,
    required bool reminderEnabled,
    required bool secondReminderEnabled,
    bool requestPermission = false,
  }) async {
    await initialize();
    await cancelWorkoutReminders();

    if (!_isSupportedPlatform || !reminderEnabled) return false;

    if (requestPermission && !await this.requestPermission()) {
      return false;
    }

    final now = DateTime.now();
    final todaySessions = await WorkoutSessionRepository().getByDate(now);
    final hasCompletedWorkoutToday = todaySessions.isNotEmpty;

    final newIds = <int>[];
    for (final schedule in schedules.where((item) => item.active)) {
      final scheduleId = schedule.id;
      if (scheduleId == null) continue;

      final primaryId = _primaryNotificationId(scheduleId);
      final primaryDate = _nextWeeklyInstance(
        weekday: schedule.dayOfWeek,
        time: schedule.reminderTime,
        skipToday:
            hasCompletedWorkoutToday && schedule.dayOfWeek == now.weekday,
      );

      await _scheduleWeekly(
        id: primaryId,
        scheduledDate: primaryDate,
        title: 'Waktunya Workout!',
        body: '${schedule.workoutType} sudah menunggumu. Yuk jaga streak!',
        payload: 'workout_schedule:$scheduleId',
      );
      newIds.add(primaryId);

      if (secondReminderEnabled) {
        final secondId = _secondNotificationId(scheduleId);
        await _scheduleWeekly(
          id: secondId,
          scheduledDate: primaryDate.add(const Duration(hours: 1)),
          title: 'Jangan lewatkan workout hari ini',
          body:
              'Sempatkan ${schedule.workoutType} agar target mingguan tercapai.',
          payload: 'workout_schedule:$scheduleId:second',
        );
        newIds.add(secondId);
      }
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _scheduledIdsKey,
      newIds.map((id) => id.toString()).toList(),
    );
    return newIds.isNotEmpty;
  }

  Future<void> _scheduleWeekly({
    required int id,
    required tz.TZDateTime scheduledDate,
    required String title,
    required String body,
    required String payload,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
    );
  }

  tz.TZDateTime _nextWeeklyInstance({
    required int weekday,
    required String time,
    bool skipToday = false,
  }) {
    final parts = time.split(':');
    final hour = int.tryParse(parts.first) ?? 18;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    if (!scheduled.isAfter(now) ||
        (skipToday &&
            scheduled.year == now.year &&
            scheduled.month == now.month &&
            scheduled.day == now.day)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }

    return scheduled;
  }

  Future<void> cancelWorkoutReminders() async {
    if (!_isSupportedPlatform) return;
    await initialize();

    final preferences = await SharedPreferences.getInstance();
    final ids = preferences.getStringList(_scheduledIdsKey) ?? const <String>[];

    for (final rawId in ids) {
      final id = int.tryParse(rawId);
      if (id != null) {
        await _plugin.cancel(id: id);
      }
    }

    await preferences.remove(_scheduledIdsKey);
  }

  int _primaryNotificationId(int scheduleId) => 10000 + scheduleId;

  int _secondNotificationId(int scheduleId) => 20000 + scheduleId;
}
