import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_entry.dart';

class CalorieProvider extends ChangeNotifier {
  List<FoodEntry> _foods = [];
  int dailyGoal = 2000;
  String _lastResetDate = "";

  double totalCalories = 0;
  double totalProtein = 0;
  double totalCarbs = 0;
  double totalFat = 0;

  List<FoodEntry> get foods => _foods;

  CalorieProvider() {
    _loadData();
  }

  // ================= LOAD DATA =================

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load goal
    dailyGoal = prefs.getInt("daily_goal") ?? 2000;
    _lastResetDate = prefs.getString("last_reset_date") ?? "";

    // Check for daily reset
    final today = DateTime.now().toIso8601String().split("T")[0];
    if (_lastResetDate != today) {
      _foods = [];
      _lastResetDate = today;
      await _saveData();
    } else {
      // Load foods
      final saved = prefs.getString("food_entries");
      if (saved != null) {
        final List decoded = jsonDecode(saved);
        _foods = decoded.map((e) => FoodEntry.fromMap(e)).toList();
      }
    }

    _recalculate();
    notifyListeners();
  }

  // ================= SAVE =================

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("daily_goal", dailyGoal);
    await prefs.setString("last_reset_date", _lastResetDate);

    final encoded = jsonEncode(_foods.map((e) => e.toMap()).toList());
    await prefs.setString("food_entries", encoded);
  }

  // ================= SET DAILY GOAL =================

  Future<void> setDailyGoal(int goal) async {
    dailyGoal = goal;
    await _saveData();
    notifyListeners();
  }

  // ================= ADD FOOD =================

  Future<void> addFood(FoodEntry entry) async {
    // Double check reset before adding if app was kept open
    _checkDailyReset();

    _foods.add(entry);
    _recalculate();
    await _saveData();
    notifyListeners();
  }

  // ================= REMOVE FOOD =================

  Future<void> removeFood(FoodEntry entry) async {
    _foods.remove(entry);
    _recalculate();
    await _saveData();
    notifyListeners();
  }

  // ================= DAILY RESET CHECK =================

  void _checkDailyReset() {
    final today = DateTime.now().toIso8601String().split("T")[0];
    if (_lastResetDate != today) {
      _foods = [];
      _lastResetDate = today;
      _recalculate();
      _saveData();
    }
  }

  // ================= CLEAR DATA =================

  Future<void> clearData() async {
    _foods = [];
    dailyGoal = 2000;
    _recalculate();
    notifyListeners();
  }

  // ================= RECALCULATE =================

  void _recalculate() {
    totalCalories = 0;
    totalProtein = 0;
    totalCarbs = 0;
    totalFat = 0;

    for (var food in _foods) {
      totalCalories += food.calories;
      totalProtein += food.protein;
      totalCarbs += food.carbs;
      totalFat += food.fat;
    }
  }
}
