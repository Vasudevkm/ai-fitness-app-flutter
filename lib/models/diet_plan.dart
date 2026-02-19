import 'diet_day.dart';

class DietPlan {
  final List<DietDay> days;

  DietPlan({
    required this.days,
  });

  Map<String, dynamic> toJson() {
    return {
      "days": days.map((d) => d.toJson()).toList(),
    };
  }

  factory DietPlan.fromJson(Map<String, dynamic> json) {
    return DietPlan(
      days: (json["days"] as List)
          .map((d) => DietDay.fromJson(d))
          .toList(),
    );
  }

  double get completionPercentage {
    if (days.isEmpty) return 0;
    final completed = days.where((d) => d.isCompleted).length;
    return completed / days.length;
  }
}
