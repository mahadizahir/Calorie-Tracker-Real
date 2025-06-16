import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    debugPrint('Current device time: \\${DateTime.now().toString()}');
    debugPrint('Time zone: \\${tz.local.name}');

    const androidDetails = AndroidNotificationDetails(
      'meal_reminder_v4', // New channel ID to force recreation
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

  Future<void> showMealReminderChannelNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'meal_reminder_v4', // New channel ID to force creation
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
    await _flutterLocalNotificationsPlugin.show(
      8888,
      'Meal Reminder Channel Created',
      'This is a test to create the Meal Reminders channel.',
      platformDetails,
    );
  }

  // Remove the immediate test notification function
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
    'Snack': false,
  };

  Map<String, TimeOfDay> times = {
    'Breakfast': const TimeOfDay(hour: 9, minute: 48),
    'Lunch': const TimeOfDay(hour: 13, minute: 45),
    'Dinner': const TimeOfDay(hour: 20, minute: 4),
    'Snack': const TimeOfDay(hour: 16, minute: 0),
  };

  @override
  void initState() {
    super.initState();
    _initializeService();
    _loadReminderSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reminderService.showMealReminderChannelNotification();
    });
  }

  Future<void> _initializeService() async {
    await _reminderService.requestPermissions(); // Ask permission
    await _reminderService.init();               // Initialize notifications
  }

  Future<void> _loadReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      toggles = {
        for (var key in toggles.keys)
          key: prefs.getBool('toggle_$key') ?? false,
      };
      times = {
        for (var key in times.keys)
          key: TimeOfDay(
            hour: prefs.getInt('time_${key}_hour') ?? times[key]!.hour,
            minute: prefs.getInt('time_${key}_minute') ?? times[key]!.minute,
          ),
      };
    });
  }

  Future<void> _saveReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    for (var key in toggles.keys) {
      await prefs.setBool('toggle_$key', toggles[key]!);
    }
    for (var key in times.keys) {
      await prefs.setInt('time_${key}_hour', times[key]!.hour);
      await prefs.setInt('time_${key}_minute', times[key]!.minute);
    }
  }

  Future<void> _toggleReminder(String key, bool value) async {
    setState(() => toggles[key] = value);
    await _saveReminderSettings();
    if (value) {
      await _reminderService.scheduleReminder(
        key,
        times[key]!,
        key.hashCode,
        weekly: false, // Only meals, not weight
      );
      // Show a pop-up dialog when a reminder is set
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Reminder Set'),
            content: Text('A notification will pop up and play a sound at \\${times[key]!.format(context)}.'),
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
      await _saveReminderSettings();
      if (toggles[key]!) {
        await _reminderService.scheduleReminder(
          key,
          picked,
          key.hashCode,
          weekly: false, // Only meals, not weight
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF232526), Color(0xFF0f2027), Color(0xFF2193b0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Reminders', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Reminders',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black54,
                        offset: Offset(1, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Meals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    _buildStyledReminderTile('Breakfast'),
                    _buildStyledReminderTile('Lunch'),
                    _buildStyledReminderTile('Dinner'),
                    _buildStyledReminderTile('Snack'),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF2193b0),
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            // Placeholder for adding new reminders
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add custom reminders coming soon!')),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStyledReminderTile(String key) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: Text('$key - ${times[key]!.format(context)}', style: const TextStyle(color: Colors.white)),
        trailing: Switch(
          value: toggles[key]!,
          onChanged: (val) => _toggleReminder(key, val),
          activeColor: const Color(0xFF2193b0),
        ),
        onTap: () => _pickTime(key),
      ),
    );
  }
}
