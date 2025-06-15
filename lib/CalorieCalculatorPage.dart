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
  double _weight = 70; // in kg
  String _activity = 'Sedentary';
  double? _calories;

  final List<String> _activityLevels = [
    'Sedentary',
    'Lightly active',
    'Moderately active',
    'Very active',
    'Extra active',
  ];

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

  void _calculateCalories() {
    double bmr;
    if (_gender == 'male') {
      bmr = 10 * _weight + 6.25 * _height - 5 * _age + 5;
    } else {
      bmr = 10 * _weight + 6.25 * _height - 5 * _age - 161;
    }
    final calculated = bmr * _activityFactor(_activity);
    setState(() {
      _calories = calculated;
    });
    UserCalorieGoal.dailyGoal = calculated;
    // Do NOT navigate automatically. Show a button instead.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calorie Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('Male'),
                      value: 'male',
                      groupValue: _gender,
                      onChanged: (val) => setState(() => _gender = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('Female'),
                      value: 'female',
                      groupValue: _gender,
                      onChanged: (val) => setState(() => _gender = val!),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: 'Age (years)'),
                initialValue: _age.toStringAsFixed(0),
                keyboardType: TextInputType.number,
                onChanged: (val) => _age = double.tryParse(val) ?? _age,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Height (cm)'),
                initialValue: _height.toStringAsFixed(0),
                keyboardType: TextInputType.number,
                onChanged: (val) => _height = double.tryParse(val) ?? _height,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Weight (kg)'),
                initialValue: _weight.toStringAsFixed(0),
                keyboardType: TextInputType.number,
                onChanged: (val) => _weight = double.tryParse(val) ?? _weight,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _activity,
                items: _activityLevels
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _activity = val!),
                decoration: InputDecoration(labelText: 'Activity Level'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculateCalories,
                child: Text('Calculate'),
              ),
              if (_calories != null) ...[
                SizedBox(height: 20),
                Text(
                  'Your daily calorie needs: \\${_calories!.toStringAsFixed(0)} kcal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => MainScreen()),
                    );
                  },
                  child: Text('Continue to Dashboard'),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
