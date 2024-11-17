import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../models/recipe_detail.dart';

class ApiService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  static Future<List<Recipe>> fetchRecipes(String cuisine) async {
    final response = await http.get(Uri.parse('$baseUrl/filter.php?a=$cuisine'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['meals'];
      return data.map((json) => Recipe.fromMealDbJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  static Future<RecipeDetail> fetchRecipeDetails(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/lookup.php?i=$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['meals'][0];
      return RecipeDetail.fromMealDbJson(data);
    } else {
      throw Exception('Failed to load recipe details');
    }
  }
}
