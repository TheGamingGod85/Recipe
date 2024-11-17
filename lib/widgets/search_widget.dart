import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recipe.dart';
import '../screens/recipe_detail_screen.dart';
import '../services/api_service.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({Key? key}) : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  List<Recipe> _allRecipes = []; // List to hold all recipes
  List<Recipe> _filteredRecipes = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllRecipes(); // Load all recipes when the search widget is initialized
  }

  // Fetch all recipes across all cuisines
  Future<void> _loadAllRecipes() async {
    List<Recipe> allRecipes = [];
    final List<String> cuisines = ['Italian', 'Indian', 'Chinese', 'Mexican']; // List of cuisines
    for (String cuisine in cuisines) {
      var recipes = await ApiService.fetchRecipes(cuisine);
      allRecipes.addAll(recipes);
    }
    setState(() {
      _allRecipes = allRecipes; // Store all recipes in the state
      _filteredRecipes = allRecipes; // Initialize the filtered list with all recipes
    });
  }

  // Filter recipes based on the search query
  void _filterRecipes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRecipes = _allRecipes; // Reset to all recipes if no query
      } else {
        _filteredRecipes = _allRecipes
            .where((recipe) => recipe.title
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Recipes'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _filterRecipes('');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                _filterRecipes(query); // Filter recipes when the query changes
              },
            ),
          ),
          Expanded(
            child: _allRecipes.isEmpty
                ? Center(child: CircularProgressIndicator()) // Show a loading spinner while recipes are being fetched
                : ListView.builder(
                    itemCount: _filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _filteredRecipes[index];
                      return ListTile(
                        title: Text(recipe.title),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RecipeDetailScreen(recipe: recipe),
                            ),
                          ).then((value) {
                            // Ensure that the back navigation goes directly to the Home screen
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          });
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