import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';
import '../widgets/search_widget.dart';
import 'recipe_detail_screen.dart';
import '../widgets/loading_widget.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> cuisines = ['Italian', 'Indian', 'Chinese', 'Mexican'];
  String selectedCuisine = 'Italian';
  late List<Recipe> _allRecipes; // To store all recipes
  List<Recipe> _filteredRecipes = [];
  bool isLoading = true; // Loading state for all recipes

  @override
  void initState() {
    super.initState();
    _loadRecipesForCuisine(selectedCuisine); // Load recipes for the initial cuisine
  }

  // Fetch recipes for the selected cuisine
  Future<void> _loadRecipesForCuisine(String cuisine) async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      List<Recipe> recipes = await ApiService.fetchRecipes(cuisine);
      setState(() {
        _allRecipes = recipes; // Store all recipes for search functionality
        _filteredRecipes = recipes; // Filter recipes based on selected cuisine
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error here (e.g., show a message)
    }
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
          // Search Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
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
          ),
        ],
      ),
      body: isLoading
          ? LoadingWidget() // Show loading screen while data is being fetched
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
                        items: _filteredRecipes
                            .take(5)
                            .map(
                              (recipe) => GestureDetector(
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
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 10),
                      ..._filteredRecipes.map((recipe) {
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
