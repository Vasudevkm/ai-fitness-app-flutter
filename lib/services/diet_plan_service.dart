import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diet_plan.dart';

class DietPlanService extends ChangeNotifier {
  static const _planKey = "saved_diet_plan";

  DietPlan? _currentPlan;

  DietPlan? get currentPlan => _currentPlan;

  Future<void> loadPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_planKey);

    if (jsonString != null) {
      final decoded = jsonDecode(jsonString);
      _currentPlan = DietPlan.fromJson(decoded);
      notifyListeners();
    }
  }

  Future<void> savePlan(DietPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_planKey, jsonEncode(plan.toJson()));
    _currentPlan = plan;
    notifyListeners();
  }

  Future<void> toggleDayCompletion(int dayNumber) async {
    if (_currentPlan == null) return;

    final day = _currentPlan!.days.firstWhere((d) => d.dayNumber == dayNumber);
    day.isCompleted = !day.isCompleted;
    day.completedAt = day.isCompleted ? DateTime.now() : null;

    await savePlan(_currentPlan!);
  }

  int get totalDays => _currentPlan?.days.length ?? 0;

  int get completedDays =>
      _currentPlan?.days.where((d) => d.isCompleted).length ?? 0;

  double get progress {
    if (_currentPlan == null || totalDays == 0) return 0;
    return completedDays / totalDays;
  }

  Future<void> clearCompletedWorkouts() async {
    if (_currentPlan == null) return;

    final remainingDays =
        _currentPlan!.days.where((d) => !d.isCompleted).toList();

    // Re-index days to maintain sequence
    for (int i = 0; i < remainingDays.length; i++) {
      remainingDays[i].dayNumber = i + 1;
    }

    final newPlan = DietPlan(days: remainingDays);
    await savePlan(newPlan);
  }

  Future<void> resetPlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_planKey);
    _currentPlan = null;
    notifyListeners();
  }
}
