import 'package:flutter/material.dart';
import 'Nutrition_Service.dart';

class FoodSearchHistory {
  static List<Map<String, dynamic>> history = [];
}

class FoodSearchPage extends StatefulWidget {
  const FoodSearchPage({super.key});

  @override
  _FoodSearchPageState createState() => _FoodSearchPageState();
}

class _FoodSearchPageState extends State<FoodSearchPage> {
  final NutritionService _nutritionService = NutritionService();
  String _searchQuery = '';
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, dynamic>? _nutritionInfo;

  List<Map<String, dynamic>> get _history => FoodSearchHistory.history;

  void _addToHistory(Map<String, dynamic> foodItem) {
    setState(() {
      FoodSearchHistory.history.insert(0, foodItem);
    });
  }

  void _removeFromHistory(int index) {
    setState(() {
      FoodSearchHistory.history.removeAt(index);
    });
  }

  Future<void> _searchFood() async {
    if (_searchQuery.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
      _searchResults = [];
      _nutritionInfo = null;
      _errorMessage = '';
    });
    try {
      final results = await _nutritionService.searchFood(_searchQuery);
      setState(() {
        _searchResults = results;
        _isLoading = false;
        if (results.isEmpty) {
          _errorMessage = 'No food found for "$_searchQuery".';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching food data: $e';
        _isLoading = false;
      });
    }
  }

  void _showNutritionInfo(Map<String, dynamic> product) {
    setState(() {
      _nutritionInfo = product;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Food Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'This search does not affect your calorie dashboard.',
                  style: TextStyle(color: const Color.fromARGB(255, 252, 0, 0), fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search food...',
                    border: OutlineInputBorder(),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _searchResults = [];
                                _nutritionInfo = null;
                                _errorMessage = '';
                              });
                            },
                            tooltip: 'Clear search',
                          )
                        : null,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                  onSubmitted: (_) => _searchFood(),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _searchFood,
                      child: Text('Search'),
                    ),
                  ],
                ),
              ],
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
            if (!_isLoading && _searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final foodItem = _searchResults[index];
                    final food = foodItem['food'] ?? {};
                    final label = food['label'] ?? 'Unnamed';
                    final nutrients = food['nutrients'] ?? {};
                    final caloriesValue = nutrients['ENERC_KCAL'];
                    final calories = caloriesValue is num
                        ? caloriesValue.toDouble()
                        : (caloriesValue is String ? double.tryParse(caloriesValue) : null);
                    final measures = foodItem['measures'] as List<dynamic>? ?? [];
                    String servingInfo = '';
                    if (measures.isNotEmpty) {
                      // Show the first non-gram measure if available, otherwise show 'Gram'
                      final nonGramMeasure = measures.firstWhere(
                        (m) => (m['label']?.toString().toLowerCase() != 'gram'),
                        orElse: () => null,
                      );
                      if (nonGramMeasure != null) {
                        final label = nonGramMeasure['label'] ?? '';
                        final weight = nonGramMeasure['weight'] != null ? '${nonGramMeasure['weight']}g' : '';
                        servingInfo = '$label${weight.isNotEmpty ? ' ($weight)' : ''}';
                      } else {
                        // fallback to Gram
                        final gramMeasure = measures.firstWhere(
                          (m) => (m['label']?.toString().toLowerCase() == 'gram'),
                          orElse: () => null,
                        );
                        if (gramMeasure != null) {
                          final weight = gramMeasure['weight'] != null ? '${gramMeasure['weight']}g' : '';
                          servingInfo = 'Gram${weight.isNotEmpty ? ' ($weight)' : ''}';
                        }
                      }
                    }
                    return ListTile(
                      title: Text(label),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Calories: '
                              '${calories != null ? calories.toStringAsFixed(1) : 'N/A'}'),
                          if (servingInfo.isNotEmpty)
                            Text('Serving: $servingInfo', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      onTap: () => _showNutritionInfo(foodItem),
                    );
                  },
                ),
              ),
            if (_nutritionInfo != null)
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 370),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Nutrition for: \\${_nutritionInfo!['food']?['label'] ?? 'Selected Food'}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: const Color.fromARGB(255, 0, 0, 0)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.grey[600]),
                                tooltip: 'Close',
                                onPressed: () {
                                  setState(() => _nutritionInfo = null);
                                },
                              ),
                            ],
                          ),
                          Divider(thickness: 1.2, color: Colors.deepPurple[100]),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _nutrientTile('Calories', _nutritionInfo!['food']?['nutrients']?['ENERC_KCAL'], 'kcal', Colors.orange),
                              _nutrientTile('Protein', _nutritionInfo!['food']?['nutrients']?['PROCNT'], 'g', Colors.blue),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _nutrientTile('Fat', _nutritionInfo!['food']?['nutrients']?['FAT'], 'g', Colors.red),
                              _nutrientTile('Carbs', _nutritionInfo!['food']?['nutrients']?['CHOCDF'], 'g', Colors.green),
                            ],
                          ),
                          SizedBox(height: 18),
                          Center(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 222, 122, 250),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                              ),
                              onPressed: () {
                                _addToHistory(_nutritionInfo!);
                                setState(() => _nutritionInfo = null);
                              },
                              icon: Icon(Icons.add, size: 20),
                              label: Text('Add', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Column(
              children: [
                if (_history.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            final food = _history[index]['food'] ?? {};
                            final label = food['label'] ?? 'Unnamed';
                            final nutrients = food['nutrients'] ?? {};
                            final caloriesValue = nutrients['ENERC_KCAL'];
                            final calories = caloriesValue is num
                                ? caloriesValue.toDouble()
                                : (caloriesValue is String ? double.tryParse(caloriesValue) : null);
                            return ListTile(
                              title: Text(label),
                              subtitle: Text('Calories: '
                                  '${calories != null ? calories.toStringAsFixed(1) : 'N/A'}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.refresh),
                                    tooltip: 'Show again',
                                    onPressed: () => setState(() => _nutritionInfo = _history[index]),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () => _removeFromHistory(index),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _nutrientTile(String label, dynamic value, String unit, Color color) {
    String display = 'N/A';
    if (value != null) {
      if (value is num) {
        display = value.toStringAsFixed(1);
      } else if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) display = parsed.toStringAsFixed(1);
      }
    }
    return Column(
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: color)),
        SizedBox(height: 4),
        Text('$display $unit', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
