import 'package:flutter/material.dart';
import 'package:flutter_application_1/reminder_notifications.dart';
import 'CalorieDashboard.dart';
import 'FoodLogPage.dart';
import 'FoodSearchPage.dart'; // Import FoodSearchPage
import 'SignInPage.dart';


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
    ReminderSettingsScreen(),
    FoodLogPage(),
    FoodSearchPage(), // Replace CalorieCalculatorPage with FoodSearchPage
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.notifications),
      label: 'Reminder',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.restaurant_menu),
      label: 'Food',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'Search',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: _navItems,
      ),
    );
  }
}