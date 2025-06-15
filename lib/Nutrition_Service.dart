import 'dart:convert';
import 'package:http/http.dart' as http;

class NutritionService {
  final String appId = '1c13eaea';
  final String appKey = 'ba18a87277315bd1ed92c4eca9d76aac';

  /// Search food using Edamam's Food Database API
  Future<List<dynamic>> searchFood(String query) async {
    final url = Uri.parse(
      'https://api.edamam.com/api/food-database/v2/parser'
      '?app_id=$appId'
      '&app_key=$appKey'
      '&ingr=${Uri.encodeComponent(query)}'
      '&nutrition-type=logging',
    );

    print('🔍 [searchFood] Searching: $query');
    print('🌐 URL: $url');

    try {
      final response = await http.get(url);
      print('🌐 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🌐 Response Data: $data'); // Log the full response data
        return data['hints'] ?? [];
      } else {
        print('❌ [searchFood] Failed with status: ${response.statusCode}');
        throw Exception('Failed to fetch food search results.');
      }
    } catch (e) {
      print('❌ [searchFood] Exception: $e');
      rethrow;
    }
  }

  /// Get nutrition info for a given food name
  Future<Map<String, dynamic>> getNutritionInfo(String foodName) async {
    final url = Uri.parse(
      'https://api.edamam.com/api/nutrition-data'
      '?app_id=$appId'
      '&app_key=$appKey'
      '&ingr=1%20${Uri.encodeComponent(foodName)}',
    );

    print('📥 [getNutritionInfo] Fetching for: $foodName');
    print('🌐 URL: $url');

    try {
      final response = await http.get(url);
      print('🌐 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🌐 Nutrition Data: $data'); // Log the nutrition data

        if (data['calories'] == 0 && (data['totalWeight'] ?? 0) == 0) {
          throw Exception('No nutrition data found for "$foodName".');
        }

        return data;
      } else {
        print('❌ [getNutritionInfo] Failed status: ${response.statusCode}');
        throw Exception('Failed to fetch nutrition data.');
      }
    } catch (e) {
      print('❌ [getNutritionInfo] Exception: $e');
      rethrow;
    }
  }
}