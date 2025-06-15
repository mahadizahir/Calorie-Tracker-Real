import 'package:flutter/material.dart';
import 'Nutrition_Service.dart';

class FoodLogPage extends StatefulWidget {
  const FoodLogPage({super.key});

  @override
  _FoodLogPageState createState() => _FoodLogPageState();
}

class _FoodLogPageState extends State<FoodLogPage> {
  final NutritionService _nutritionService = NutritionService();

  String _selectedMeal = '';
  String _searchQuery = '';
  List<dynamic> _searchResults = [];
  Map<String, dynamic>? _nutritionInfo;
  bool _isLoading = false;
  String _errorMessage = '';

  void _openAddFoodDialog(String meal) {
    _selectedMeal = meal;
    _searchQuery = '';
    _searchResults = [];
    _nutritionInfo = null;
    _errorMessage = '';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> searchFood() async {
              if (_searchQuery.trim().isEmpty) return;

              setStateDialog(() {
                _isLoading = true;
                _searchResults = [];
                _nutritionInfo = null;
                _errorMessage = '';
              });

              try {
                final results = await _nutritionService.searchFood(_searchQuery);
                print('🌐 Search Results: $results'); // Log search results
                if (results.isEmpty) {
                print('❌ No results found for query: $_searchQuery');
              }
                setStateDialog(() {
                  _searchResults = results;
                  _isLoading = false;
                  if (results.isEmpty) {
                    _errorMessage = 'No food found for "$_searchQuery".';
                  }
                });
              } catch (e) {
                print('❌ Exception in searchFood: $e');
                setStateDialog(() {
                  _errorMessage = 'Error fetching food data: $e'; // Log error message
                  _isLoading = false;
                });
              }
            }

            Future<void> selectFood(Map<String, dynamic> product) async {
              setStateDialog(() {
                _isLoading = true;
                _errorMessage = '';
              });

              // Use Open Food Facts product data directly
              await Future.delayed(Duration(milliseconds: 300)); // Simulate loading
              setStateDialog(() {
                _nutritionInfo = product;
                _isLoading = false;
              });

              // Wait a short moment to let the UI update, then close the dialog
              await Future.delayed(Duration(milliseconds: 100));
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            }

            return AlertDialog(
              scrollable: true,
              title: Text('Add Food to $_selectedMeal'),
              content: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(maxHeight: 500), // Increased max height for better usability
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search food...',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) => _searchQuery = val,
                        onSubmitted: (_) => searchFood(),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: searchFood,
                        child: Text('Search'),
                      ),
                      if (_isLoading)
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: CircularProgressIndicator(),
                        ),
                      if (!_isLoading && _errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      if (!_isLoading &&
                          _searchResults.isNotEmpty &&
                          _errorMessage.isEmpty)
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final product = _searchResults[index];
                              final label = product['product_name'] ?? 'Unnamed';
                              final nutriments = product['nutriments'] ?? {};
                              final caloriesValue = nutriments['energy-kcal_100g'];
                              final calories = caloriesValue is num
                                  ? caloriesValue.toDouble()
                                  : (caloriesValue is String ? double.tryParse(caloriesValue) : null);
                              return ListTile(
                                title: Text(label),
                                subtitle: Text('Calories (per 100g): '
                                    '${calories != null ? calories.toStringAsFixed(0) : 'N/A'}'),
                                onTap: () => selectFood(product),
                              );
                            },
                          ),
                        ),
                      if (!_isLoading &&
                          _searchResults.isEmpty &&
                          _errorMessage.isEmpty &&
                          _searchQuery.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            'No food found for "$_searchQuery". Try another keyword.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      if (_nutritionInfo != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nutrition for: ${_nutritionInfo!['product_name'] ?? 'Selected Food'}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Text('Calories (per 100g): '
                                  '${_nutritionInfo!['nutriments']?['energy-kcal_100g']?.toString() ?? 'N/A'} kcal'),
                              Text('Protein (per 100g): '
                                  '${_nutritionInfo!['nutriments']?['proteins_100g']?.toString() ?? 'N/A'} g'),
                              Text('Fat (per 100g): '
                                  '${_nutritionInfo!['nutriments']?['fat_100g']?.toString() ?? 'N/A'} g'),
                              Text('Carbs (per 100g): '
                                  '${_nutritionInfo!['nutriments']?['carbohydrates_100g']?.toString() ?? 'N/A'} g'),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  // Here you can add logic to log the selected food to your meal log
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Food logged: ${_nutritionInfo!['product_name'] ?? 'Selected Food'}')),
                                  );
                                },
                                child: Text('Log Food'),
                              ),
                            ],
                          ),
                        ),
                      // Always have at least one child to avoid empty column layout errors
                      if (_isLoading == false &&
                          _errorMessage.isEmpty &&
                          _searchResults.isEmpty &&
                          _nutritionInfo == null &&
                          _searchQuery.isEmpty)
                        SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMealCard(String meal) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Icon(Icons.fastfood),
        title: Text(meal),
        subtitle: Text('Tap "Add Food" to log items'),
        trailing: TextButton(
          child: Text('Add Food'),
          onPressed: () => _openAddFoodDialog(meal),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Food Log')),
      body: ListView(
        children: [
          _buildMealCard('Breakfast'),
          _buildMealCard('Lunch'),
          _buildMealCard('Dinner'),
        ],
      ),
    );
  }
}
