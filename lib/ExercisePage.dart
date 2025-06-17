import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'exercise_log_service.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  final exercises = [
    {'name': 'Jogging', 'met': 7.0},
    {'name': 'Push-up', 'met': 8.0},
    {'name': 'Sit-up', 'met': 6.0},
  ];

  List<Map<String, dynamic>> myExercises = [];
  String? selected;
  double duration = 30, weight = 70, calories = 0;

  static const _exerciseKey = 'my_exercises';

  @override
  void initState() {
    super.initState();
    _loadExercises();
    ExerciseLogService().exerciseLog = myExercises;
  }

  Future<void> _loadExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_exerciseKey);
    if (encoded == null) {
      myExercises = [];
    } else {
      final List<dynamic> decoded = jsonDecode(encoded);
      myExercises = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    setState(() {});
    ExerciseLogService().exerciseLog = myExercises;
  }

  Future<void> _saveExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(myExercises);
    await prefs.setString(_exerciseKey, encoded);
    ExerciseLogService().exerciseLog = myExercises;
  }

  void _deleteExercise(int index) async {
    setState(() {
      myExercises.removeAt(index);
    });
    await _saveExercises();
    ExerciseLogService().exerciseLog = myExercises;
  }

  void calculateCalories() {
    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an exercise type first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final ex = exercises.firstWhere(
      (e) => e['name'] == selected,
      orElse: () => {},
    );
    final met = ex['met'] ?? 0;
    final hour = duration / 60;
    setState(() {
      calories = (met as double) * weight * hour;
      myExercises.add({
        'name': selected,
        'duration': duration,
        'calories': calories,
      });
    });
    _saveExercises();
    ExerciseLogService().exerciseLog = myExercises;
  }

  void addCustomExercise() {
    final nameCtrl = TextEditingController();
    final metCtrl = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Add Exercise'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: metCtrl,
                  decoration: InputDecoration(labelText: 'MET'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final met = double.tryParse(metCtrl.text);
                  if (name.isNotEmpty && met != null) {
                    setState(() {
                      exercises.add({'name': name, 'met': met});
                      selected = name;
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
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
        title: const Text('Exercise Tracker', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selected,
                      decoration: const InputDecoration(labelText: 'Exercise', labelStyle: TextStyle(color: Colors.white)),
                      dropdownColor: Colors.black,
                      items: exercises
                          .map(
                            (e) => DropdownMenuItem<String>(
                              value: e['name'] as String,
                              child: Text(e['name'] as String, style: const TextStyle(color: Colors.white)),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => selected = val),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Duration (minutes)', labelStyle: TextStyle(color: Colors.white)),
                      keyboardType: TextInputType.number,
                      initialValue: duration.toStringAsFixed(0),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) => duration = double.tryParse(val) ?? duration,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Weight (kg)', labelStyle: TextStyle(color: Colors.white)),
                      keyboardType: TextInputType.number,
                      initialValue: weight.toStringAsFixed(0),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) => weight = double.tryParse(val) ?? weight,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2193b0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: calculateCalories,
                      child: const Text('Calculate & Save', style: TextStyle(color: Colors.white)),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Add Custom Exercise', style: TextStyle(color: Colors.white)),
                      onPressed: addCustomExercise,
                    ),
                    if (calories > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Calories: ${calories.toStringAsFixed(1)} kcal',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('My Exercises', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: myExercises.length,
                      itemBuilder: (_, i) {
                        final ex = myExercises[i];
                        return ListTile(
                          leading: const Icon(Icons.fitness_center, color: Colors.white),
                          title: Text(ex['name'], style: const TextStyle(color: Colors.white)),
                          subtitle: Text(
                            '${ex['duration']} min - ${ex['calories'].toStringAsFixed(1)} kcal',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteExercise(i),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
