import 'package:flutter/material.dart';
import 'main.dart';
import 'user_calorie_goal.dart';

class CalorieCalculatorPage extends StatefulWidget {
  const CalorieCalculatorPage({super.key});

  @override
  _CalorieCalculatorPageState createState() => _CalorieCalculatorPageState();
}

class _CalorieCalculatorPageState extends State<CalorieCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  String _gender = 'male';
  double _age = 25;
  double _height = 170; // in cm
  String _activity = 'Sedentary';
  String _goal = 'Maintain weight';
  double? _calories;
  bool _showNext = false;

  final List<String> _activityLevels = [
    'Sedentary',
    'Lightly active',
    'Moderately active',
    'Very active',
    'Extra active',
  ];

  final List<String> _goalOptions = [
    'Lose weight',
    'Maintain weight',
    'Gain weight',
  ];

  final Map<String, String> _activityDescriptions = {
    'Sedentary': 'Little or no exercise, desk job.',
    'Lightly active': 'Light exercise/sports 1-3 days/week.',
    'Moderately active': 'Moderate exercise/sports 3-5 days/week.',
    'Very active': 'Hard exercise/sports 6-7 days/week.',
    'Extra active': 'Very hard exercise, physical job, or training.',
  };

  double _activityFactor(String activity) {
    switch (activity) {
      case 'Lightly active':
        return 1.375;
      case 'Moderately active':
        return 1.55;
      case 'Very active':
        return 1.725;
      case 'Extra active':
        return 1.9;
      case 'Sedentary':
      default:
        return 1.2;
    }
  }

  double _goalAdjustment(String goal) {
    switch (goal) {
      case 'Lose weight':
        return -500; // 500 kcal deficit per day
      case 'Gain weight':
        return 500; // 500 kcal surplus per day
      case 'Maintain weight':
      default:
        return 0;
    }
  }

  void _calculateCalories() {
    double bmr;
    double defaultWeight = 70; // Use a default weight
    if (_gender == 'male') {
      bmr = 10 * defaultWeight + 6.25 * _height - 5 * _age + 5;
    } else {
      bmr = 10 * defaultWeight + 6.25 * _height - 5 * _age - 161;
    }
    final calculated = bmr * _activityFactor(_activity) + _goalAdjustment(_goal);
    setState(() {
      _calories = calculated;
      _showNext = true;
    });
    UserCalorieGoal.dailyGoal = calculated;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Calculator'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF232526), Color(0xFF0f2027), Color(0xFF2193b0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              color: Colors.white.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              elevation: 8,
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.calculate, size: 48, color: Colors.white),
                      const SizedBox(height: 12),
                      Text('Calorie Calculator',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 8,
                                  color: Colors.black54,
                                  offset: Offset(1, 2),
                                ),
                              ])),
                      const SizedBox(height: 24),
                      Text('Gender', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Male', style: TextStyle(color: Colors.white)),
                              value: 'male',
                              groupValue: _gender,
                              activeColor: Color(0xFF2193b0),
                              onChanged: (val) => setState(() => _gender = val!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Female', style: TextStyle(color: Colors.white)),
                              value: 'female',
                              groupValue: _gender,
                              activeColor: Color(0xFF2193b0),
                              onChanged: (val) => setState(() => _gender = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Age (years)',
                          labelStyle: const TextStyle(color: Colors.white),
                          prefixIcon: const Icon(Icons.cake, color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        initialValue: _age.toStringAsFixed(0),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => _age = double.tryParse(val) ?? _age,
                        validator: (val) => val == null || val.isEmpty ? 'Enter your age' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Height (cm)',
                          labelStyle: const TextStyle(color: Colors.white),
                          prefixIcon: const Icon(Icons.height, color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        initialValue: _height.toStringAsFixed(0),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => _height = double.tryParse(val) ?? _height,
                        validator: (val) => val == null || val.isEmpty ? 'Enter your height' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _activity,
                        dropdownColor: Colors.black87,
                        items: _activityLevels
                            .map((level) => DropdownMenuItem(
                                  value: level,
                                  child: Text(level, style: const TextStyle(color: Colors.white)),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _activity = val!),
                        decoration: InputDecoration(
                          labelText: 'Activity Level',
                          labelStyle: const TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _activityDescriptions[_activity] ?? '',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _goal,
                        dropdownColor: Colors.black87,
                        items: _goalOptions
                            .map((g) => DropdownMenuItem(
                                  value: g,
                                  child: Text(g, style: const TextStyle(color: Colors.white)),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _goal = val!),
                        decoration: InputDecoration(
                          labelText: 'Goal',
                          labelStyle: const TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2193b0),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _calculateCalories,
                        child: const Text('Calculate', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                      if (_calories != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Your daily calorie needs:',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_calories!.toStringAsFixed(0)} kcal',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        AnimatedOpacity(
                          opacity: _showNext ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 600),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => MainScreen()),
                              );
                            },
                            child: Center(
                              child: Text(
                                'Next →',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Color(0xFF2193b0),
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 8,
                                      color: Colors.black54,
                                      offset: Offset(1, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
