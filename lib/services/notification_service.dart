import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ═══════════════════════════════════════════════════════════════════════════
  // CHANGE THESE VALUES TO TEST NOTIFICATIONS QUICKLY
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// The hour and minute for the FIRST daily pulse reminder.
  /// Set to 15:15 (3:15 PM) for testing. Change to 9:00 for production.
  static const int reminderHour = 15;
  static const int reminderMinute = 15;

  /// How often (in hours) to repeat the reminder if pulse is not submitted.
  /// Set to 1 for hourly reminders.
  static const int repeatIntervalHours = 1;

  /// The "day start" hour — pulses before this are counted as previous day.
  /// 20 = 8:00 PM. A new "trust day" begins at 8 PM.
  static const int dayStartHour = 20;

  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked: ${response.payload}');
      },
    );
    
    // Request permissions for Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DAILY PULSE REMINDER (repeats daily at the configured time)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> scheduleDailyPulseReminder(TimeOfDay time) async {
    await init();
    
    // Cancel existing pulse reminder (id 1)
    await flutterLocalNotificationsPlugin.cancel(1);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'trust_pulse_channel',
      'Daily Trust Pulse',
      channelDescription: 'Reminders to complete your daily Trust Pulse',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      "Time for today's Trust Pulse 💙",
      "Check in with your circle and build stronger bonds.",
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HOURLY NUDGE REMINDERS (if pulse not yet submitted)
  // Schedules repeating hourly reminders from the configured start time.
  // Call this on app start; cancel when pulse is submitted.
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> scheduleHourlyPulseNudge() async {
    await init();
    
    // Cancel any existing hourly nudges (ids 10-19)
    for (int i = 10; i < 20; i++) {
      await flutterLocalNotificationsPlugin.cancel(i);
    }

    final now = tz.TZDateTime.now(tz.local);

    // Schedule up to 8 hourly reminders starting from reminderHour
    for (int i = 0; i < 8; i++) {
      final hour = reminderHour + (i * repeatIntervalHours);
      if (hour >= 24) break; // Don't schedule past midnight

      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        reminderMinute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'trust_pulse_hourly',
        'Pulse Reminders',
        channelDescription: 'Hourly nudges to submit your daily trust pulse',
        importance: Importance.high,
        priority: Priority.high,
      );
      const NotificationDetails details =
          NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        10 + i,
        '🔔 Have you checked in today?',
        'Your circle is waiting. Submit your Trust Pulse now.',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  /// Call this after pulse is submitted to stop hourly nudges for today
  Future<void> cancelHourlyNudges() async {
    for (int i = 10; i < 20; i++) {
      await flutterLocalNotificationsPlugin.cancel(i);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WHATSAPP-STYLE INSTANT NOTIFICATION (real-time bubble)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> showWhatsAppStyleNotification(String title, String body) async {
    await init();
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'trust_circle_messages',
      'Circle Updates',
      channelDescription: 'Real-time updates from your circle',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      styleInformation: DefaultStyleInformation(true, true),
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SILENCE DETECTOR NOTIFICATION
  // Shown when a circle member hasn't submitted a pulse for 3+ days.
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> showSilenceAlert(String memberName, int daysSilent) async {
    await init();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'silence_detector',
      'Silence Alerts',
      channelDescription: 'Alerts when circle members go quiet',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      '🤫 $memberName has been quiet',
      '$memberName hasn\'t checked in for $daysSilent days. Reach out!',
      details,
    );
  }

  Future<void> showAggregatedSilenceAlert(int count, String firstMemberName) async {
    await init();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'silence_detector',
      'Silence Alerts',
      channelDescription: 'Alerts when circle members go quiet',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      '🤫 $firstMemberName and ${count - 1} more may need support',
      'Multiple members haven\'t checked in recently. Tap to view.',
      details,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RESOLVE MODE NOTIFICATION
  // Shown when circle trust score drops below threshold.
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> showResolveNotification(String circleName, double trustScore) async {
    await init();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'resolve_mode',
      'Resolve Mode',
      channelDescription: 'Alerts when trust score drops critically',
      importance: Importance.max,
      priority: Priority.max,
    );
    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      '⚠️ Trust Alert in $circleName',
      'Trust score dropped to ${trustScore.toStringAsFixed(0)}%. Tap to start Resolve Mode.',
      details,
      payload: '/resolve',
    );
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

final notificationService = NotificationService();
