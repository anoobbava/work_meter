import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  static const String _notificationSettingsKey = 'notification_settings';
  static const String _scheduledNotificationsKey = 'scheduled_notifications';
  
  /// Initialize notification service
  static Future<void> initialize() async {
    // Initialize timezone data
    tz.initializeTimeZones();
    
    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    
    // Request permissions
    await _requestPermissions();
    
    // Initialize default settings
    await _initializeDefaultSettings();
  }
  
  /// Request notification permissions
  static Future<void> _requestPermissions() async {
    // Skip platform-specific permission requests on web
    if (kIsWeb) {
      // Web platform doesn't need these permissions
      return;
    }
    
    if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      await androidImplementation?.requestNotificationsPermission();
    }
  }
  
  /// Handle notification tap
  static void _onNotificationTap(NotificationResponse notificationResponse) {
    // Handle notification tap based on payload
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      // Parse payload and navigate accordingly
      print('Notification tapped with payload: $payload');
    }
  }
  
  /// Initialize default notification settings
  static Future<void> _initializeDefaultSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_notificationSettingsKey)) {
      NotificationSettings defaultSettings = NotificationSettings(
        attendanceReminders: true,
        leaveUpdates: true,
        checkInReminders: true,
        checkOutReminders: true,
        dailyReports: false,
        weeklyReports: true,
              checkInReminderTime: NotificationTime(hour: 9, minute: 0),
      checkOutReminderTime: NotificationTime(hour: 17, minute: 30),
      );
      
      await _saveNotificationSettings(defaultSettings);
    }
  }
  
  /// Show immediate notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationImportance importance = NotificationImportance.defaultImportance,
  }) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'work_meter_channel',
      'Work Meter Notifications',
      channelDescription: 'Notifications for work meter app',
      importance: _getAndroidImportance(importance),
      priority: Priority.high,
      showWhen: true,
    );
    
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
  
  /// Schedule notification
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationImportance importance = NotificationImportance.defaultImportance,
  }) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'work_meter_scheduled',
      'Scheduled Notifications',
      channelDescription: 'Scheduled notifications for work meter',
      importance: _getAndroidImportance(importance),
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();
    
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    // Convert DateTime to TZDateTime
    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
    
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      platformChannelSpecifics,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    
    // Save scheduled notification
    await _saveScheduledNotification(ScheduledNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: payload,
    ));
  }
  
  /// Schedule daily recurring notification
  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required NotificationTime time,
    String? payload,
  }) async {
    // Create a daily repeating notification
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    
    // If the scheduled time has passed for today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }
    
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'work_meter_daily',
      'Daily Reminders',
      channelDescription: 'Daily recurring notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();
    
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    await _notificationsPlugin.periodicallyShow(
      id,
      title,
      body,
      RepeatInterval.daily,
      platformChannelSpecifics,
      payload: payload,
    );
  }
  
  /// Show attendance reminder
  static Future<void> showAttendanceReminder() async {
    await showNotification(
      id: 1,
      title: 'Time to Check In!',
      body: 'Don\'t forget to mark your attendance for today.',
      payload: 'attendance_reminder',
      importance: NotificationImportance.high,
    );
  }
  
  /// Show check-out reminder
  static Future<void> showCheckOutReminder() async {
    await showNotification(
      id: 2,
      title: 'Time to Check Out!',
      body: 'Remember to mark your check-out time.',
      payload: 'checkout_reminder',
      importance: NotificationImportance.high,
    );
  }
  
  /// Show leave status notification
  static Future<void> showLeaveStatusNotification({
    required String leaveType,
    required String status,
    String? comment,
  }) async {
    String title = 'Leave Application $status';
    String body = 'Your $leaveType application has been $status.';
    if (comment != null && comment.isNotEmpty) {
      body += '\nComment: $comment';
    }
    
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      payload: 'leave_status',
      importance: NotificationImportance.high,
    );
  }
  
  /// Show overtime notification
  static Future<void> showOvertimeNotification(int overtimeMinutes) async {
    String body = 'You have worked ${overtimeMinutes} minutes overtime today.';
    
    await showNotification(
      id: 3,
      title: 'Overtime Alert',
      body: body,
      payload: 'overtime_alert',
      importance: NotificationImportance.defaultImportance,
    );
  }
  
  /// Schedule check-in reminder
  static Future<void> scheduleCheckInReminder() async {
    NotificationSettings settings = await getNotificationSettings();
    if (settings.checkInReminders) {
      await scheduleDailyNotification(
        id: 100,
        title: 'Check In Reminder',
        body: 'Time to start your work day!',
        time: settings.checkInReminderTime,
        payload: 'checkin_reminder',
      );
    }
  }
  
  /// Schedule check-out reminder
  static Future<void> scheduleCheckOutReminder() async {
    NotificationSettings settings = await getNotificationSettings();
    if (settings.checkOutReminders) {
      await scheduleDailyNotification(
        id: 101,
        title: 'Check Out Reminder',
        body: 'Don\'t forget to check out!',
        time: settings.checkOutReminderTime,
        payload: 'checkout_reminder',
      );
    }
  }
  
  /// Get notification settings
  static Future<NotificationSettings> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    String? settingsJson = prefs.getString(_notificationSettingsKey);
    
    if (settingsJson != null) {
      return NotificationSettings.fromJson(json.decode(settingsJson));
    }
    
    // Return default settings if none found
    return NotificationSettings(
      attendanceReminders: true,
      leaveUpdates: true,
      checkInReminders: true,
      checkOutReminders: true,
      dailyReports: false,
      weeklyReports: true,
      checkInReminderTime: NotificationTime(hour: 9, minute: 0),
      checkOutReminderTime: NotificationTime(hour: 17, minute: 30),
    );
  }
  
  /// Save notification settings
  static Future<void> _saveNotificationSettings(NotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationSettingsKey, json.encode(settings.toJson()));
  }
  
  /// Update notification settings
  static Future<void> updateNotificationSettings(NotificationSettings settings) async {
    await _saveNotificationSettings(settings);
    
    // Update scheduled notifications based on new settings
    await _updateScheduledNotifications(settings);
  }
  
  /// Update scheduled notifications based on settings
  static Future<void> _updateScheduledNotifications(NotificationSettings settings) async {
    // Cancel existing reminders
    await cancelNotification(100); // Check-in reminder
    await cancelNotification(101); // Check-out reminder
    
    // Reschedule based on new settings
    if (settings.checkInReminders) {
      await scheduleCheckInReminder();
    }
    
    if (settings.checkOutReminders) {
      await scheduleCheckOutReminder();
    }
  }
  
  /// Save scheduled notification
  static Future<void> _saveScheduledNotification(ScheduledNotification notification) async {
    final prefs = await SharedPreferences.getInstance();
    List<ScheduledNotification> notifications = await getScheduledNotifications();
    
    notifications.removeWhere((n) => n.id == notification.id);
    notifications.add(notification);
    
    String notificationsJson = json.encode(notifications.map((n) => n.toJson()).toList());
    await prefs.setString(_scheduledNotificationsKey, notificationsJson);
  }
  
  /// Get scheduled notifications
  static Future<List<ScheduledNotification>> getScheduledNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    String? notificationsJson = prefs.getString(_scheduledNotificationsKey);
    
    if (notificationsJson != null) {
      List<dynamic> decoded = json.decode(notificationsJson);
      return decoded.map((item) => ScheduledNotification.fromJson(item)).toList();
    }
    
    return [];
  }
  
  /// Cancel notification
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
  
  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
  
  /// Convert notification importance to Android importance
  static Importance _getAndroidImportance(NotificationImportance importance) {
    switch (importance) {
      case NotificationImportance.min:
        return Importance.min;
      case NotificationImportance.low:
        return Importance.low;
      case NotificationImportance.defaultImportance:
        return Importance.defaultImportance;
      case NotificationImportance.high:
        return Importance.high;
      case NotificationImportance.max:
        return Importance.max;
    }
  }
}

class NotificationSettings {
  final bool attendanceReminders;
  final bool leaveUpdates;
  final bool checkInReminders;
  final bool checkOutReminders;
  final bool dailyReports;
  final bool weeklyReports;
  final NotificationTime checkInReminderTime;
  final NotificationTime checkOutReminderTime;
  
  NotificationSettings({
    required this.attendanceReminders,
    required this.leaveUpdates,
    required this.checkInReminders,
    required this.checkOutReminders,
    required this.dailyReports,
    required this.weeklyReports,
    required this.checkInReminderTime,
    required this.checkOutReminderTime,
  });
  
  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      attendanceReminders: json['attendanceReminders'] ?? true,
      leaveUpdates: json['leaveUpdates'] ?? true,
      checkInReminders: json['checkInReminders'] ?? true,
      checkOutReminders: json['checkOutReminders'] ?? true,
      dailyReports: json['dailyReports'] ?? false,
      weeklyReports: json['weeklyReports'] ?? true,
      checkInReminderTime: NotificationTime(
        hour: json['checkInReminderHour'] ?? 9,
        minute: json['checkInReminderMinute'] ?? 0,
      ),
      checkOutReminderTime: NotificationTime(
        hour: json['checkOutReminderHour'] ?? 17,
        minute: json['checkOutReminderMinute'] ?? 30,
      ),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'attendanceReminders': attendanceReminders,
      'leaveUpdates': leaveUpdates,
      'checkInReminders': checkInReminders,
      'checkOutReminders': checkOutReminders,
      'dailyReports': dailyReports,
      'weeklyReports': weeklyReports,
      'checkInReminderHour': checkInReminderTime.hour,
      'checkInReminderMinute': checkInReminderTime.minute,
      'checkOutReminderHour': checkOutReminderTime.hour,
      'checkOutReminderMinute': checkOutReminderTime.minute,
    };
  }
}

class ScheduledNotification {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledDate;
  final String? payload;
  
  ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    this.payload,
  });
  
  factory ScheduledNotification.fromJson(Map<String, dynamic> json) {
    return ScheduledNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      payload: json['payload'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate.toIso8601String(),
      'payload': payload,
    };
  }
}

enum NotificationImportance {
  min,
  low,
  defaultImportance,
  high,
  max,
}

class NotificationTime {
  final int hour;
  final int minute;
  
  NotificationTime({required this.hour, required this.minute});
  
  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
} 