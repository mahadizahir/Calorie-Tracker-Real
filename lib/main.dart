import 'package:flutter/material.dart';
import 'package:flutter_application_1/reminder_notifications.dart';
import 'CalorieDashboard.dart';
import 'FoodLogPage.dart';
import 'FoodSearchPage.dart'; // Import FoodSearchPage
import 'SignInPage.dart';
import 'ReminderPage.dart'; // Import ReminderPage


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        canvasColor: Colors.transparent, // Ensures BottomNavigationBar is transparent on web
      ),
      home: SignInPage(), // Show sign-in first
    );
  }
}

/// The main screen with bottom navigation after sign-in.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    CalorieDashboardPage(),
    ReminderSettingsScreen(), // Use the functional reminder notification screen
    FoodLogPage(),
    FoodSearchPage(), // Replace CalorieCalculatorPage with FoodSearchPage
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        backgroundColor: Colors.transparent, // Let gradient show through
        body: _screens[_selectedIndex],
        bottomNavigationBar: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(icon: Icons.home, label: 'Home', index: 0),
              _buildNavItem(icon: Icons.notifications, label: 'Reminder', index: 1),
              _buildNavItem(icon: Icons.restaurant_menu, label: 'Food', index: 2),
              _buildNavItem(icon: Icons.search, label: 'Search', index: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
            size: 28,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}