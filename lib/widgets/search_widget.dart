import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../screens/recipe_detail_screen.dart';
import '../services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({Key? key}) : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  List<Recipe> _allRecipes = []; // List to hold all recipes across cuisines
  List<Recipe> _filteredRecipes = [];
  TextEditingController _searchController = TextEditingController();
  List<String> _cuisines = []; // List to hold dynamic cuisines

  @override
  void initState() {
    super.initState();
    _loadCuisines(); // Load cuisines dynamically
  }

  // Fetch all cuisines dynamically from the API
  Future<void> _loadCuisines() async {
    try {
      var response = await ApiService.fetchCuisines(); // Modify the ApiService to fetch cuisines
      setState(() {
        _cuisines = response; // Store the cuisines
      });
      _loadAllRecipes(); // After cuisines are loaded, fetch recipes
    } catch (e) {
      print("Error loading cuisines: $e");
    }
  }

  // Fetch recipes across all cuisines
  Future<void> _loadAllRecipes() async {
    List<Recipe> allRecipes = [];
    for (String cuisine in _cuisines) {
      try {
        var recipes = await ApiService.fetchRecipes(cuisine);
        allRecipes.addAll(recipes); // Add recipes from each cuisine to the list
      } catch (e) {
        print("Error fetching recipes for $cuisine: $e");
      }
    }
    setState(() {
      _allRecipes = allRecipes; // Store all recipes in the state
      _filteredRecipes = allRecipes; // Initialize filtered list with all recipes
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
                .contains(query.toLowerCase())) // Case-insensitive search by title
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Recipes',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orangeAccent, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _filterRecipes(''); // Clear search query
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
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                _filterRecipes(query); // Filter recipes when the query changes
              },
            ),
          ),
          Expanded(
            child: _allRecipes.isEmpty
                ? Center(child: CircularProgressIndicator()) // Show loading spinner while recipes are being fetched
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
