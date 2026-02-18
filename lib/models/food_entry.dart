class FoodEntry {
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String mealType;

  FoodEntry({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.mealType,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "calories": calories,
      "protein": protein,
      "carbs": carbs,
      "fat": fat,
      "mealType": mealType,
    };
  }

  factory FoodEntry.fromMap(Map<String, dynamic> map) {
    return FoodEntry(
      name: map["name"],
      calories: (map["calories"] ?? 0).toDouble(),
      protein: (map["protein"] ?? 0).toDouble(),
      carbs: (map["carbs"] ?? 0).toDouble(),
      fat: (map["fat"] ?? 0).toDouble(),
      mealType: map["mealType"] ?? "Breakfast",
    );
  }
}
