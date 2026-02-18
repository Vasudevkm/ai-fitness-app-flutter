class WorkoutDay {

  int dayNumber;
  String title;
  List<String> exercises;
  bool isRest;

  bool isCompleted;
  DateTime? completedAt;

  WorkoutDay({
    required this.dayNumber,
    required this.title,
    required this.exercises,
    required this.isRest,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "dayNumber": dayNumber,
      "title": title,
      "exercises": exercises,
      "isRest": isRest,
      "isCompleted": isCompleted,
      "completedAt":
          completedAt?.toIso8601String(),
    };
  }

  factory WorkoutDay.fromJson(
      Map<String, dynamic> json) {

    return WorkoutDay(
      dayNumber: json["dayNumber"] ?? 1,
      title: json["title"] ?? "Workout",
      exercises:
          List<String>.from(json["exercises"] ?? []),
      isRest: json["isRest"] ?? false,
      isCompleted:
          json["isCompleted"] ?? false,
      completedAt:
          json["completedAt"] != null
              ? DateTime.parse(
                  json["completedAt"])
              : null,
    );
  }
}
