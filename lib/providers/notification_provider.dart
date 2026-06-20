import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class NotificationNotifier extends Notifier<bool> {
  @override
  bool build() {
    _loadState();
    return false;
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('notifications_enabled') ?? false;
  }

  Future<void> toggle(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);

    if (value) {
      await notificationService.scheduleDailyPulseReminder(const TimeOfDay(hour: 9, minute: 0));
    } else {
      await notificationService.cancelAll();
    }
  }
}

final notificationsEnabledProvider = NotifierProvider<NotificationNotifier, bool>(() {
  return NotificationNotifier();
});
