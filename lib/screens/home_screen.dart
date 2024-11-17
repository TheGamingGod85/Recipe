import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> cuisines = ['Italian', 'Indian', 'Chinese', 'Mexican'];
  String selectedCuisine = 'Italian';
  late Future<List<Recipe>> _recipes;

  @override
  void initState() {
    super.initState();
    _recipes = ApiService.fetchRecipes(selectedCuisine);
  }

  void _fetchRecipes(String cuisine) {
    setState(() {
      selectedCuisine = cuisine;
      _recipes = ApiService.fetchRecipes(cuisine);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('World Cuisine Explorer'),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedCuisine,
            items: cuisines.map((cuisine) {
              return DropdownMenuItem(
                value: cuisine,
                child: Text(cuisine),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                _fetchRecipes(value);
              }
            },
          ),
          Expanded(
            child: FutureBuilder<List<Recipe>>(
              future: _recipes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load recipes.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No recipes available.'));
                }

                final recipes = snapshot.data!;
                return ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return ListTile(
                      leading: Image.network(recipe.image),
                      title: Text(recipe.title),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RecipeDetailScreen(recipe: recipe),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
