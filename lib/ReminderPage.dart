import 'package:flutter/material.dart';

class ReminderPage extends StatelessWidget {
  const ReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminders'),
      ),
      body: Center(
        child: Text(
          'This is the Reminder Page',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
