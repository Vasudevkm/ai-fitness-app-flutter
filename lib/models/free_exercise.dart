class FreeExercise {
  final String id;
  final String name;
  final List primaryMuscles;
  final List secondaryMuscles;
  final List instructions;
  final List images;
  final String equipment;
  final String level;
  final String category;

  FreeExercise({
    required this.id,
    required this.name,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    required this.images,
    required this.equipment,
    required this.level,
    required this.category,
  });

  factory FreeExercise.fromJson(Map<String, dynamic> json) {
    return FreeExercise(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      primaryMuscles: json['primaryMuscles'] ?? [],
      secondaryMuscles: json['secondaryMuscles'] ?? [],
      instructions: json['instructions'] ?? [],
      images: json['images'] ?? [],
      equipment: json['equipment'] ?? '',
      level: json['level'] ?? '',
      category: json['category'] ?? '',
    );
  }

  /// Build GitHub RAW image URL
  List<String> imageUrls() {
    return images
        .map(
          (img) =>
              'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/$img',
        )
        .toList();
  }

}
