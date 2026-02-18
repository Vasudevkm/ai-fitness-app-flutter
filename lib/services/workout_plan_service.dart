import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_plan.dart';
import '../models/workout_day.dart';

class WorkoutPlanService {

  static const _planKey = "saved_workout_plan";

  WorkoutPlan? _currentPlan;

  WorkoutPlan? get currentPlan => _currentPlan;

  Future<void> loadPlan() async {

    final prefs =
        await SharedPreferences.getInstance();

    final jsonString =
        prefs.getString(_planKey);

    if (jsonString != null) {

      final decoded =
          jsonDecode(jsonString);

      _currentPlan =
          WorkoutPlan.fromJson(decoded);
    }
  }

  Future<void> savePlan(
      WorkoutPlan plan) async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
        _planKey,
        jsonEncode(plan.toJson()));

    _currentPlan = plan;

    print("PLAN SAVED SUCCESSFULLY");
  }

  Future<void> toggleDayCompletion(
      int dayNumber) async {

    if (_currentPlan == null) return;

    final day =
        _currentPlan!.days.firstWhere(
            (d) => d.dayNumber ==
                dayNumber);

    day.isCompleted =
        !day.isCompleted;

    day.completedAt =
        day.isCompleted
            ? DateTime.now()
            : null;

    await savePlan(_currentPlan!);
  }

  int get totalDays =>
      _currentPlan?.days.length ?? 0;

  int get completedDays =>
      _currentPlan?.days
              .where((d) =>
                  d.isCompleted)
              .length ??
          0;

  double get progress {
    if (_currentPlan == null ||
        totalDays == 0) {return 0;}
    return completedDays /
        totalDays;
  }
}
