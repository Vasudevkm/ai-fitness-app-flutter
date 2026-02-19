class DietDay {
  int dayNumber;
  String title;
  List<String> meals;
  bool isCompleted;
  DateTime? completedAt;

  DietDay({
    required this.dayNumber,
    required this.title,
    required this.meals,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "dayNumber": dayNumber,
      "title": title,
      "meals": meals,
      "isCompleted": isCompleted,
      "completedAt": completedAt?.toIso8601String(),
    };
  }

  factory DietDay.fromJson(Map<String, dynamic> json) {
    return DietDay(
      dayNumber: json["dayNumber"] ?? 1,
      title: json["title"] ?? "Meals",
      meals: List<String>.from(json["meals"] ?? []),
      isCompleted: json["isCompleted"] ?? false,
      completedAt: json["completedAt"] != null
          ? DateTime.parse(json["completedAt"])
          : null,
    );
  }
}
