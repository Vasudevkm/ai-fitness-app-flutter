import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/calorie_provider.dart';
import '../services/workout_plan_service.dart';
import '../services/diet_plan_service.dart';

class DataResetService {
  /// Completely wipes all local SharedPreferences and resets Provider states.
  static Future<void> resetAllData(BuildContext context) async {
    // Capture references BEFORE async gap to avoid using BuildContext across async boundaries
    final calorieProvider = context.read<CalorieProvider>();
    final workoutService = context.read<WorkoutPlanService>();
    final dietService = context.read<DietPlanService>();

    // 1. Wipe SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 2. Reset In-Memory Provider States
    calorieProvider.clearData();
    await workoutService.resetPlan();
    await dietService.resetPlan();
  }
}
