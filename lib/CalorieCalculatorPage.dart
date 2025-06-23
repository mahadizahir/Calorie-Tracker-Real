import 'package:flutter/material.dart';
import 'main.dart';
import 'CalorieDashboard.dart';

class UserProfile {
  static String? username;
  static String? gender;
  static int? age;
  static int? height;
  static double? weight;
}

class CalorieCalculatorPage extends StatefulWidget {
  final String? username;
  const CalorieCalculatorPage({super.key, this.username});

  @override
  _CalorieCalculatorPageState createState() => _CalorieCalculatorPageState();
}

class _CalorieCalculatorPageState extends State<CalorieCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  String _gender = 'male';
  int _age = 25;
  int _height = 170; // in cm
  double _weight = 70; // in kg
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
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      return;
    }
    if (_gender == 'male') {
      bmr = 10 * _weight + 6.25 * _height - 5 * _age + 5;
    } else {
      bmr = 10 * _weight + 6.25 * _height - 5 * _age - 161;
    }
    final calculated = bmr * _activityFactor(_activity) + _goalAdjustment(_goal);
    setState(() {
      _calories = calculated;
      _showNext = true;
    });
    UserCalorieGoal.dailyGoal = calculated;
    UserProfile.gender = _gender;
    UserProfile.age = _age;
    UserProfile.height = _height;
    UserProfile.weight = _weight;
  }

  @override
  void initState() {
    super.initState();
    if (widget.username != null) {
      UserProfile.username = widget.username;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  
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
                        initialValue: _age.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => _age = int.tryParse(val) ?? _age,
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
                        initialValue: _height.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => _height = int.tryParse(val) ?? _height,
                        validator: (val) => val == null || val.isEmpty ? 'Enter your height' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Weight (kg)',
                          labelStyle: const TextStyle(color: Colors.white),
                          prefixIcon: const Icon(Icons.fitness_center, color: Colors.white),
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
                        initialValue: _weight.toStringAsFixed(0),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => _weight = double.tryParse(val) ?? _weight,
                        validator: (val) => val == null || val.isEmpty ? 'Enter your weight' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _activity,
                        dropdownColor: Colors.black87,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
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
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
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
                        if (_showNext)
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => MainScreen()),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              child: const Text('Next →'),
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
