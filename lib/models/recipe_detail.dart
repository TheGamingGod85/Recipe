class RecipeDetail {
  final String title;
  final String image;
  final String instructions;
  final List<String> ingredients;

  RecipeDetail({
    required this.title,
    required this.image,
    required this.instructions,
    required this.ingredients,
  });

  factory RecipeDetail.fromMealDbJson(Map<String, dynamic> json) {
    List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];

      if (ingredient != null && ingredient.isNotEmpty) {
        ingredients.add('$measure $ingredient'.trim());
      }
    }

    return RecipeDetail(
      title: json['strMeal'],
      image: json['strMealThumb'],
      instructions: json['strInstructions'],
      ingredients: ingredients,
    );
  }
}
