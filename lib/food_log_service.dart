import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FoodLogService {
  static final FoodLogService _instance = FoodLogService._internal();
  factory FoodLogService() => _instance;
  FoodLogService._internal();

  List<Map<String, dynamic>> _foodLog = [];

  Future<void> loadFoodLog() async {
    final prefs = await SharedPreferences.getInstance();
    final foodLogString = prefs.getString('food_log');
    if (foodLogString != null) {
      final List<dynamic> decoded = jsonDecode(foodLogString);
      _foodLog = decoded.cast<Map<String, dynamic>>();
    }
  }

  Future<void> saveFoodLog() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('food_log', jsonEncode(_foodLog));
  }

  List<Map<String, dynamic>> get foodLog => _foodLog;

  void addFood(Map<String, dynamic> food) {
    _foodLog.add(food);
    saveFoodLog();
  }

  void removeFood(Map<String, dynamic> food) {
    _foodLog.remove(food);
    saveFoodLog();
  }

  Map<String, double> getNutritionTotals() {
    double totalProtein = 0;
    double totalFat = 0;
    double totalCarbs = 0;
    for (var food in _foodLog) {
      totalProtein += (food['protein'] ?? 0) is num ? food['protein'] : double.tryParse(food['protein'].toString()) ?? 0;
      totalFat += (food['fat'] ?? 0) is num ? food['fat'] : double.tryParse(food['fat'].toString()) ?? 0;
      totalCarbs += (food['carbs'] ?? 0) is num ? food['carbs'] : double.tryParse(food['carbs'].toString()) ?? 0;
    }
    return {
      'protein': totalProtein,
      'fat': totalFat,
      'carbs': totalCarbs,
    };
  }
}
