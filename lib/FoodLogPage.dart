import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'nutrition_service.dart';
import 'food_log_service.dart';

class FoodLogPage extends StatefulWidget {
  const FoodLogPage({super.key});

  @override
  _FoodLogPageState createState() => _FoodLogPageState();
}

class _FoodLogPageState extends State<FoodLogPage> {
  final NutritionService _nutritionService = NutritionService();
  List<Map<String, dynamic>> _foodLog = [];
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    FoodLogService().loadFoodLog().then((_) {
      setState(() {
        _foodLog = FoodLogService().foodLog;
      });
    });
  }

  Future<void> _saveFoodLog() async {
    await FoodLogService().saveFoodLog();
    setState(() {
      _foodLog = FoodLogService().foodLog;
    });
  }

  Future<void> _searchFood(String query) async {
    setState(() {
      _isSearching = true;
      _searchResults = [];
    });
    try {
      final results = await _nutritionService.searchFood(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching food: $e')),
      );
    }
  }

  void _showAddSearchedFoodDialog(Map<String, dynamic> food, String meal) {
    final foodName = food['food']['label'] ?? '';
    final nutrients = food['food']['nutrients'] ?? {};
    final calories = nutrients['ENERC_KCAL']?.toString() ?? '';
    final protein = nutrients['PROCNT']?.toString() ?? '';
    final fat = nutrients['FAT']?.toString() ?? '';
    final carbs = nutrients['CHOCDF']?.toString() ?? '';
    String name = foodName;
    String cal = calories;
    String pro = protein;
    String fa = fat;
    String car = carbs;
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.35),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Add "$foodName" to $meal', style: TextStyle(color: Colors.white)),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: InputDecoration(labelText: 'Food Name', labelStyle: TextStyle(color: Colors.white70)),
                    style: TextStyle(color: Colors.white),
                    onChanged: (val) => name = val,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Enter food name' : null,
                  ),
                  TextFormField(
                    initialValue: cal,
                    decoration: InputDecoration(labelText: 'Calories (required)', labelStyle: TextStyle(color: Colors.white70)),
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => cal = val,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Enter calories' : null,
                  ),
                  TextFormField(
                    initialValue: pro,
                    decoration: InputDecoration(labelText: 'Protein (required)', labelStyle: TextStyle(color: Colors.white70)),
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => pro = val,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Enter protein' : null,
                  ),
                  TextFormField(
                    initialValue: fa,
                    decoration: InputDecoration(labelText: 'Fat (required)', labelStyle: TextStyle(color: Colors.white70)),
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => fa = val,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Enter fat' : null,
                  ),
                  TextFormField(
                    initialValue: car,
                    decoration: InputDecoration(labelText: 'Carbs (required)', labelStyle: TextStyle(color: Colors.white70)),
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => car = val,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Enter carbs' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2193b0)),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _foodLog.add({
                      'meal': meal,
                      'foodName': name,
                      'calories': double.tryParse(cal) ?? 0,
                      'protein': double.tryParse(pro) ?? 0,
                      'fat': double.tryParse(fa) ?? 0,
                      'carbs': double.tryParse(car) ?? 0,
                    });
                  });
                  _saveFoodLog();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Food logged: $name')),
                  );
                }
              },
              child: Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showSearchDialog(String meal) {
    String query = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.35),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Add Food for $meal', style: TextStyle(color: Colors.white)),
          content: TextField(
            decoration: InputDecoration(hintText: 'Enter food name', hintStyle: TextStyle(color: Colors.white54)),
            style: TextStyle(color: Colors.white),
            onChanged: (val) => query = val,
            onSubmitted: (val) async {
              Navigator.of(context).pop();
              await _searchFood(val);
              _showSearchResults(meal);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2193b0)),
              onPressed: () async {
                Navigator.of(context).pop();
                await _searchFood(query);
                _showSearchResults(meal);
              },
              child: Text('Search', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showSearchResults(String meal) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.35),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Search Results', style: TextStyle(color: Colors.white)),
          content: _isSearching
              ? Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
                  ? Text('No results found.', style: TextStyle(color: Colors.white70))
                  : SizedBox(
                      width: 300,
                      height: 300,
                      child: ListView.separated(
                        itemCount: _searchResults.length,
                        separatorBuilder: (context, index) => SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final food = _searchResults[index];
                          final label = food['food']['label'] ?? '';
                          final nutrients = food['food']['nutrients'] ?? {};
                          final calories = nutrients['ENERC_KCAL']?.toString() ?? 'N/A';
                          return ListTile(
                            tileColor: Colors.black.withOpacity(0.16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            title: Text(label, style: TextStyle(color: Colors.white)),
                            subtitle: Text('Calories: $calories', style: TextStyle(color: Colors.white70)),
                            onTap: () {
                              Navigator.of(context).pop();
                              _showAddSearchedFoodDialog(food, meal);
                            },
                          );
                        },
                      ),
                    ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMealCard(String meal) {
    final mealFoods = _foodLog.where((f) => f['meal'] == meal).toList();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          unselectedWidgetColor: Colors.white.withOpacity(0.7), // Unselected arrow
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: Colors.white, // Selected arrow
            onSurface: Colors.white, // Text color
          ),
        ),
        child: ExpansionTile(
          leading: Icon(Icons.fastfood, color: Colors.white),
          title: Text(meal, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text('Tap "Search Food" to log items', style: TextStyle(color: Colors.white70)),
          collapsedIconColor: Colors.white.withOpacity(0.7),
          iconColor: Colors.white,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.search, color: Colors.white),
                  label: Text('Search Food', style: TextStyle(color: Colors.white)),
                  onPressed: () => _showSearchDialog(meal),
                ),
              ],
            ),
            ...mealFoods.asMap().entries.map((entry) {
              final food = entry.value;
              return ListTile(
                title: Text(food['foodName'] ?? '', style: TextStyle(color: Colors.white)),
                subtitle: Text('Calories: ${food['calories']}', style: TextStyle(color: Colors.white70)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Protein: ${food['protein']}g', style: TextStyle(color: Colors.white70)),
                        Text('Fat: ${food['fat']}g', style: TextStyle(color: Colors.white70)),
                        Text('Carbs: ${food['carbs']}g', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _foodLog.removeAt(_foodLog.indexOf(food));
                        });
                        _saveFoodLog();
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Food Log', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: ListView(
          children: [
            _buildMealCard('Breakfast'),
            _buildMealCard('Lunch'),
            _buildMealCard('Dinner'),
            _buildMealCard('Snack'),
          ],
        ),
      ),
    );
  }
}
