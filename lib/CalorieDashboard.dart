import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'food_log_service.dart';
import 'exercise_log_service.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF232526), Color(0xFF0f2027), Color(0xFF2193b0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13), // Slightly more visible
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16.0),
                child: _buildViewSwitcher(),
              ),
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
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16.0),
                child: _buildDailySummary(),
              ),
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
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16.0),
                child: _buildMacroChart(),
              ),
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
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16.0),
                child: _buildNutritionalBreakdown(),
              ),
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
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16.0),
                child: _buildGoalComparison(),
              ),
            ],
          ),
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
    final burned = ExerciseLogService().getTotalBurned();
    final foodLog = FoodLogService().foodLog;
    double consumed = 0;
    for (var food in foodLog) {
      consumed += (food['calories'] ?? 0) is num ? food['calories'] : double.tryParse(food['calories'].toString()) ?? 0;
    }
    return Column(
      children: [
        Text('Daily Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem('Consumed', '${consumed.toStringAsFixed(0)} kcal'),
            _buildSummaryItem('Burned', '${burned.toStringAsFixed(0)} kcal'),
            _buildSummaryItem('Goal',
                userGoal != null
                    ? '${userGoal.toStringAsFixed(0)} kcal'
                    : '1500 kcal'),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildMacroChart() {
    final userGoal = UserCalorieGoal.dailyGoal ?? 2000.0;
    final foodLog = FoodLogService().foodLog;
    double consumed = 0;
    for (var food in foodLog) {
      consumed += (food['calories'] ?? 0) is num ? food['calories'] : double.tryParse(food['calories'].toString()) ?? 0;
    }
    final burned = ExerciseLogService().getTotalBurned();
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
        value: remaining.toDouble(),
        title: 'Remaining\n${remaining.toStringAsFixed(0)}',
        radius: 80,
        titleStyle: TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Calorie Distribution',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
    );
  }

  Widget _buildNutritionalBreakdown() {
    final totals = FoodLogService().getNutritionTotals();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nutritional Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Protein', style: TextStyle(color: Colors.white)),
            Text('${totals['protein']?.toStringAsFixed(1) ?? '0'} g', style: TextStyle(color: Colors.white)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Fat', style: TextStyle(color: Colors.white)),
            Text('${totals['fat']?.toStringAsFixed(1) ?? '0'} g', style: TextStyle(color: Colors.white)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Carbs', style: TextStyle(color: Colors.white)),
            Text('${totals['carbs']?.toStringAsFixed(1) ?? '0'} g', style: TextStyle(color: Colors.white)),
          ],
        ),
      ],
    );
  }

  Widget _buildGoalComparison() {
    final foodLog = FoodLogService().foodLog;
    double intake = 0;
    for (var food in foodLog) {
      intake += (food['calories'] ?? 0) is num ? food['calories'] : double.tryParse(food['calories'].toString()) ?? 0;
    }
    final burned = ExerciseLogService().getTotalBurned();
    final goal = UserCalorieGoal.dailyGoal ?? 2000.0;
    final progress = goal > 0 ? ((intake - burned) / goal).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Intake vs Goal (will reduce if exercise)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 10),
        LinearProgressIndicator(
          value: progress,
          minHeight: 10,
          backgroundColor: Colors.grey[300],
          color: Colors.green,
        ),
        SizedBox(height: 5),
        Text('${(intake - burned).toInt()} / ${goal.toInt()} kcal', style: TextStyle(color: Colors.white)),
      ],
    );
  }
}

class UserCalorieGoal {
  static double? dailyGoal;
}