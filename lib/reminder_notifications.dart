import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';

class ReminderNotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInitSettings);

    await _flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> requestPermissions() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final result = await Permission.notification.request();
      debugPrint('Notification permission status: $result');
    } else {
      debugPrint('Notification permission already granted.');
    }
  }

  Future<void> scheduleReminder(
    String title,
    TimeOfDay time,
    int id, {
    bool weekly = false,
  }) async {
    // Request exact alarm permission before scheduling
    final androidImplementation = _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestExactAlarmsPermission();

    final now = DateTime.now();
    final scheduledDate =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);

    final tzDateTime = tz.TZDateTime.from(
      scheduledDate.isBefore(now)
          ? scheduledDate.add(const Duration(days: 1))
          : scheduledDate,
      tz.local,
    );

    debugPrint('Scheduling reminder: $title at ${tzDateTime.toString()} (id: $id)');

    const androidDetails = AndroidNotificationDetails(
      'meal_reminder_v3', // Changed channel ID to force recreation
      'Meal Reminders',
      channelDescription: 'Notifications for meal reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ticker: 'Reminder',
      visibility: NotificationVisibility.public,
      icon: '@mipmap/ic_launcher',
    );

    const platformDetails = NotificationDetails(android: androidDetails);

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        'Time to log your $title',
        tzDateTime,
        platformDetails,
        matchDateTimeComponents: weekly ? DateTimeComponents.dayOfWeekAndTime : DateTimeComponents.time,
        payload: null,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('Reminder scheduled successfully.');
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
    }
  }

  Future<void> sendNotification(String title, String body, int id) async {
    const androidDetails = AndroidNotificationDetails(
      'general',
      'General Notifications',
      channelDescription: 'General notification channel',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const platformDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(id, title, body, platformDetails);
  }

  Future<void> notifyCalorieLimitExceeded() async {
    await sendNotification('Calorie Alert', 'You are exceeding your daily calorie limit.', 101);
  }

  Future<void> notifyInactivity() async {
    await sendNotification('Inactivity Alert', 'You\'ve been inactive for a while. Consider a short walk.', 102);
  }

  Future<void> notifyLowWaterIntake() async {
    await sendNotification('Hydration Alert', 'Remember to drink water!', 103);
  }

  Future<void> sendDailyMotivation() async {
    await sendNotification('Health Tip', 'Stay positive! A healthy mind fuels a healthy body.', 104);
  }
}

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  _ReminderSettingsScreenState createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  final ReminderNotificationService _reminderService = ReminderNotificationService();

  Map<String, bool> toggles = {
    'Breakfast': false,
    'Lunch': false,
    'Dinner': false,
    'Weight': false,
  };

  Map<String, TimeOfDay> times = {
    'Breakfast': const TimeOfDay(hour: 9, minute: 48),
    'Lunch': const TimeOfDay(hour: 13, minute: 45),
    'Dinner': const TimeOfDay(hour: 20, minute: 4),
    'Weight': const TimeOfDay(hour: 7, minute: 23),
  };

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _reminderService.requestPermissions(); // Ask permission
    await _reminderService.init();               // Initialize notifications
  }

  Future<void> _toggleReminder(String key, bool value) async {
    setState(() => toggles[key] = value);
    if (value) {
      await _reminderService.scheduleReminder(
        key,
        times[key]!,
        key.hashCode,
        weekly: key == 'Weight',
      );
      // Show a pop-up dialog when a reminder is set
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Reminder Set'),
            content: Text('A notification will pop up and play a sound at ${times[key]!.format(context)}.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _pickTime(String key) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: times[key]!,
    );
    if (picked != null) {
      setState(() => times[key] = picked);
      if (toggles[key]!) {
        await _reminderService.scheduleReminder(
          key,
          picked,
          key.hashCode,
          weekly: key == 'Weight',
        );
      }
    }
  }

  Widget _buildReminderTile(String key) {
    return ListTile(
      title: Text('$key - ${times[key]!.format(context)}'),
      trailing: Switch(
        value: toggles[key]!,
        onChanged: (val) => _toggleReminder(key, val),
      ),
      onTap: () => _pickTime(key),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('Meals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _buildReminderTile('Breakfast'),
          _buildReminderTile('Lunch'),
          _buildReminderTile('Dinner'),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('Weight', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _buildReminderTile('Weight'),
        ],
      ),
    );
  }
}
