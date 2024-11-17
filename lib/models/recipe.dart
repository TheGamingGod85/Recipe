class Recipe {
  final String id;
  final String title;
  final String image;

  Recipe({required this.id, required this.title, required this.image});

  factory Recipe.fromMealDbJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['idMeal'],
      title: json['strMeal'],
      image: json['strMealThumb'],
    );
  }
}
