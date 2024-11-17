import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/recipe_detail.dart';
import '../services/api_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Future<RecipeDetail> _recipeDetail;

  @override
  void initState() {
    super.initState();
    _recipeDetail = ApiService.fetchRecipeDetails(widget.recipe.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.title),
      ),
      body: FutureBuilder<RecipeDetail>(
        future: _recipeDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load recipe details.'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No details available.'));
          }

          final details = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(details.image),
                SizedBox(height: 16),
                Text(
                  details.title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'Ingredients:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ...details.ingredients.map((ingredient) => Text('• $ingredient')),
                SizedBox(height: 16),
                Text(
                  'Instructions:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(details.instructions),
              ],
            ),
          );
        },
      ),
    );
  }
}
