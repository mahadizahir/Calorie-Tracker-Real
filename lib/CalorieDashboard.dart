import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'user_calorie_goal.dart';

// Make sure this import path is correct
// import 'FoodLogPage.dart'; // No longer needed here since navigation is in bottom nav

class CalorieDashboardPage extends StatefulWidget {
  const CalorieDashboardPage({super.key});

  @override
  _CalorieDashboardPageState createState() => _CalorieDashboardPageState();
}

class _CalorieDashboardPageState extends State<CalorieDashboardPage> {
  String view = 'Daily';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calorie & Nutrition Dashboard'),
        backgroundColor: Colors.green,
        // Removed the food icon button to avoid duplication with bottom nav
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.restaurant_menu),
        //     tooltip: 'Log Food',
        //     onPressed: () {
        //       // No longer needed here
        //     },
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildViewSwitcher(),
            SizedBox(height: 16),
            _buildDailySummary(),
            SizedBox(height: 16),
            _buildMacroChart(),
            SizedBox(height: 16),
            _buildNutritionalBreakdown(),
            SizedBox(height: 16),
            _buildGoalComparison(),
          ],
        ),
      ),
    );
  }

  Widget _buildViewSwitcher() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ['Daily'].map((option) {
        return ChoiceChip(
          label: Text(option),
          selected: view == option,
          onSelected: (selected) {
            setState(() {
              view = option;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildDailySummary() {
    final userGoal = UserCalorieGoal.dailyGoal;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Daily Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Consumed', '2000 kcal'),
                _buildSummaryItem('Burned', '500 kcal'),
                _buildSummaryItem('Goal',
                    userGoal != null
                        ? '${userGoal.toStringAsFixed(0)} kcal'
                        : '1500 kcal'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }

  Widget _buildMacroChart() {
    final userGoal = UserCalorieGoal.dailyGoal ?? 2000.0;
    final consumed = 2000.0;
    final burned = 500.0;
    final remaining = (userGoal - (consumed - burned)).clamp(0, userGoal);

    final sections = [
      PieChartSectionData(
        color: Colors.blue,
        value: consumed,
        title: 'Consumed\n${consumed.toStringAsFixed(0)}',
        radius: 80,
        titleStyle: TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: burned,
        title: 'Burned\n${burned.toStringAsFixed(0)}',
        radius: 80,
        titleStyle: TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: remaining.toDouble(), // Fix type error
        title: 'Remaining\n${remaining.toStringAsFixed(0)}',
        radius: 80,
        titleStyle: TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calorie Distribution',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionalBreakdown() {
    final nutrients = {
      'Sugar': '30g',
      'Fiber': '25g',
      'Vitamin A': '90%',
      'Vitamin C': '80%',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nutritional Breakdown',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...nutrients.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text(e.key), Text(e.value)],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalComparison() {
    final intake = 1400.0;
    final goal = 2000.0;
    final progress = intake / goal;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Intake vs Goal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
            ),
            SizedBox(height: 5),
            Text('${intake.toInt()} / ${goal.toInt()} kcal'),
          ],
        ),
      ),
    );
  }
}