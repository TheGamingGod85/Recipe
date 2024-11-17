import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/search_widget.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> cuisines = []; // List to hold cuisines dynamically fetched
  String selectedCuisine = 'Liked'; // Default to 'Liked'
  late List<Recipe> _allRecipes;
  List<Recipe> _filteredRecipes = [];
  bool isLoading = true;
  List<String> _likedRecipeIds = [];

  @override
  void initState() {
    super.initState();
    _loadLikedRecipes(); // Load liked recipe IDs
    _loadCuisines(); // Load cuisines from API
  }

  // Load liked recipes from SharedPreferences
  Future<void> _loadLikedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _likedRecipeIds = prefs.getStringList('likedRecipes') ?? [];
    });
  }

  // Save liked recipes to SharedPreferences
  Future<void> _saveLikedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('likedRecipes', _likedRecipeIds);
  }

  // Fetch the list of available cuisines from the API
  Future<void> _loadCuisines() async {
    try {
      List<String> fetchedCuisines = await ApiService.fetchCuisines();
      setState(() {
        cuisines = ['Liked'] + fetchedCuisines; // Always keep "Liked" at index 0
      });
      _loadRecipesForCuisine(selectedCuisine); // Load recipes for the initial selected cuisine
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch recipes for the selected cuisine
  Future<void> _loadRecipesForCuisine(String cuisine) async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Recipe> recipes;
      if (cuisine == 'Liked') {
        // Show liked recipes based on stored IDs
        recipes = await ApiService.fetchRecipes('Italian'); // Fetch any cuisine to filter liked recipes
        recipes = recipes.where((recipe) => _likedRecipeIds.contains(recipe.id)).toList();
      } else {
        recipes = await ApiService.fetchRecipes(cuisine); // Fetch by cuisine
      }

      setState(() {
        _allRecipes = recipes;
        _filteredRecipes = recipes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Toggle the liked status of a recipe
  void _toggleLiked(Recipe recipe) {
    setState(() {
      if (_likedRecipeIds.contains(recipe.id)) {
        _likedRecipeIds.remove(recipe.id); // Unliked
      } else {
        _likedRecipeIds.add(recipe.id); // Liked
      }
    });

    _saveLikedRecipes(); // Save the updated liked recipe IDs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'World Cuisine Explorer',
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
            icon: Icon(Icons.search),
            onPressed: () {
              // Open the SearchWidget
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchWidget(),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? LoadingWidget() // Show loading screen
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: cuisines.map((cuisine) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ChoiceChip(
                            label: Text(
                              cuisine,
                              style: TextStyle(
                                color: selectedCuisine == cuisine
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            selected: selectedCuisine == cuisine,
                            selectedColor: Colors.deepOrange,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  selectedCuisine = cuisine;
                                  _loadRecipesForCuisine(cuisine);
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 200,
                          autoPlay: true,
                          enlargeCenterPage: true,
                        ),
                        items: _filteredRecipes.take(5).map(
                          (recipe) {
                            bool isLiked = _likedRecipeIds.contains(recipe.id);
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RecipeDetailScreen(recipe: recipe),
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      recipe.image,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    left: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      color: Colors.black.withOpacity(0.6),
                                      child: Text(
                                        recipe.title,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: IconButton(
                                      icon: Icon(
                                        isLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isLiked ? Colors.red : null,
                                      ),
                                      onPressed: () => _toggleLiked(recipe),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ).toList(),
                      ),
                      const SizedBox(height: 10),
                      ..._filteredRecipes.map((recipe) {
                        bool isLiked = _likedRecipeIds.contains(recipe.id);
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  recipe.image,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                recipe.title,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isLiked ? Colors.red : null,
                                ),
                                onPressed: () => _toggleLiked(recipe),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RecipeDetailScreen(recipe: recipe),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
