class USDAFoodItem {
  final String name;
  final double calories;

  USDAFoodItem({
    required this.name,
    required this.calories,
  });

  factory USDAFoodItem.fromJson(Map<String, dynamic> json) {
    double kcal = 0;

    final nutrients = json['foodNutrients'] as List<dynamic>;
    for (final n in nutrients) {
      if (n['nutrientName'] == 'Energy') {
        kcal = (n['value'] as num).toDouble();
        break;
      }
    }

    return USDAFoodItem(
      name: json['description'],
      calories: kcal,
    );
  }
}
