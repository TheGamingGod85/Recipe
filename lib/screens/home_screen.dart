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
  String selectedCuisine = 'Italian'; // Default to a specific cuisine (no Liked tab)
  List<Recipe> _allRecipes = [];
  List<Recipe> _sortedRecipes = []; // Sorted list of recipes (liked on top)
  bool isLoading = true;
  List<String> _likedRecipeIds = [];
  Map<String, List<Recipe>> _cuisineRecipeCache = {}; // Cache for cuisines

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
        cuisines = fetchedCuisines; // Remove 'Liked' from the list
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
      if (_cuisineRecipeCache.containsKey(cuisine)) {
        // Load from cache if available
        setState(() {
          _allRecipes = _cuisineRecipeCache[cuisine]!;
          _sortRecipesByLiked();
          isLoading = false;
        });
        return;
      }

      List<Recipe> recipes = await ApiService.fetchRecipes(cuisine);
      setState(() {
        _allRecipes = recipes;
        _cuisineRecipeCache[cuisine] = recipes; // Cache results
        _sortRecipesByLiked();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Sort the recipes with liked ones on top
  void _sortRecipesByLiked() {
    _sortedRecipes = _allRecipes
        .where((recipe) => _likedRecipeIds.contains(recipe.id))
        .toList()
      ..addAll(
        _allRecipes.where((recipe) => !_likedRecipeIds.contains(recipe.id)),
      );
  }

  // Toggle the liked status of a recipe
  void _toggleLiked(Recipe recipe) async {
    final updatedLikedIds = [..._likedRecipeIds];
    if (updatedLikedIds.contains(recipe.id)) {
      updatedLikedIds.remove(recipe.id); // Unliked
    } else {
      updatedLikedIds.add(recipe.id); // Liked
    }

    await _saveLikedRecipes();

    setState(() {
      _likedRecipeIds = updatedLikedIds;
      _sortRecipesByLiked(); // Re-sort the recipes to reflect the updated liked list
    });
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
              // Open the SearchWidget with fade transition
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SearchWidget(),
                    );
                  },
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
                // Carousel with images of selected cuisine
                CarouselSlider(
                  options: CarouselOptions(
                    height: 200,
                    autoPlay: true,
                    enlargeCenterPage: true,
                  ),
                  items: _sortedRecipes.take(5).map(
                    (recipe) {
                      bool isLiked = _likedRecipeIds.contains(recipe.id);
                      return GestureDetector(
                        onTap: () {
                          // Fade transition to RecipeDetailScreen
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: RecipeDetailScreen(recipe: recipe),
                                );
                              },
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            // Recipe image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.network(
                                recipe.image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                            // Recipe title at the bottom
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Container(
                                  padding: EdgeInsets.all(8.0),
                                  color: Colors.black54, // Semi-transparent background
                                  child: Text(
                                    recipe.title,
                                    style: TextStyle(
                                      color: Colors.white, // Text color
                                      fontSize: 16,         // Font size
                                      fontWeight: FontWeight.bold, // Font weight
                                    ),
                                    textAlign: TextAlign.center, // Center align the text
                                  ),
                                ),
                              )
                            ),
                            // Like button at the top-right corner
                            Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                icon: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: isLiked ? Colors.red : null,
                                ),
                                onPressed: () {
                                  _toggleLiked(recipe); // Toggle like status
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ).toList(),
                ),



                // Cuisine selection chips
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
                
                // Recipe List
                Expanded(
                  child: ListView(
                    children: [
                      ..._sortedRecipes.map((recipe) {
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
                                // Fade transition to RecipeDetailScreen
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: RecipeDetailScreen(recipe: recipe),
                                      );
                                    },
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
