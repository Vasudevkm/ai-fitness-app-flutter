import 'workout_day.dart';

class WorkoutPlan {

  final List<WorkoutDay> days;

  WorkoutPlan({
    required this.days,
  });

  Map<String, dynamic> toJson() {
    return {
      "days":
          days.map((d) => d.toJson()).toList(),
    };
  }

  factory WorkoutPlan.fromJson(
      Map<String, dynamic> json) {

    return WorkoutPlan(
      days: (json["days"] as List)
          .map((d) =>
              WorkoutDay.fromJson(d))
          .toList(),
    );
  }

  double get completionPercentage {
    if (days.isEmpty) return 0;
    final completed =
        days.where((d) =>
            d.isCompleted).length;
    return completed / days.length;
  }
}
