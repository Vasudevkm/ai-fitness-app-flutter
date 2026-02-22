import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/calorie_provider.dart';
import '../models/food_entry.dart';
import '../utils/constants.dart';

class CalorieTrackingScreen extends StatefulWidget {
  const CalorieTrackingScreen({super.key});

  @override
  State<CalorieTrackingScreen> createState() =>
      _CalorieTrackingScreenState();
}

class _CalorieTrackingScreenState
    extends State<CalorieTrackingScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  List<dynamic> _results = [];
  bool _loading = false;

  // ================= SEARCH =================

  Future<void> _searchFood() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _loading = true);

    final url =
        "https://api.nal.usda.gov/fdc/v1/foods/search?query=$query&api_key=${AppConstants.usdaApiKey}";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _results = data["foods"] ?? [];
      });
    }

    setState(() => _loading = false);
  }

  // ================= NUTRIENT HELPER =================

  double _getNutrient(
      Map food, int nutrientId) {
    final nutrients =
        food["foodNutrients"] ?? [];

    for (var n in nutrients) {
      if (n["nutrientId"] == nutrientId) {
        return (n["value"] ?? 0).toDouble();
      }
    }

    return 0;
  }

  // ================= PORTION SHEET =================

  void _showPortionSheet(Map food) {
    final gramController = TextEditingController(text: "100");
    String selectedMeal = "Breakfast";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (stateContext, setStateSheet) {
            double grams = double.tryParse(gramController.text) ?? 0;

            double cal = _getNutrient(food, 1008);
            double protein = _getNutrient(food, 1003);
            double carbs = _getNutrient(food, 1005);
            double fat = _getNutrient(food, 1004);

            double finalCalories = (cal * grams) / 100;
            double finalProtein = (protein * grams) / 100;
            double finalCarbs = (carbs * grams) / 100;
            double finalFat = (fat * grams) / 100;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        food["description"] ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedMeal,
                        items: const [
                          DropdownMenuItem(value: "Breakfast", child: Text("Breakfast")),
                          DropdownMenuItem(value: "Lunch", child: Text("Lunch")),
                          DropdownMenuItem(value: "Dinner", child: Text("Dinner")),
                          DropdownMenuItem(value: "Snacks", child: Text("Snacks")),
                        ],
                        onChanged: (value) {
                          setStateSheet(() {
                            selectedMeal = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Meal",
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: gramController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: "Grams",
                        ),
                        onChanged: (value) {
                          setStateSheet(() {});
                        },
                      ),
                      const SizedBox(height: 20),
                      Text("Calories: ${finalCalories.toStringAsFixed(0)}"),
                      Text("Protein: ${finalProtein.toStringAsFixed(1)} g"),
                      Text("Carbs: ${finalCarbs.toStringAsFixed(1)} g"),
                      Text("Fat: ${finalFat.toStringAsFixed(1)} g"),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: grams <= 0
                            ? null
                            : () {
                                context.read<CalorieProvider>().addFood(
                                      FoodEntry(
                                        name: food["description"],
                                        calories: finalCalories,
                                        protein: finalProtein,
                                        carbs: finalCarbs,
                                        fat: finalFat,
                                        mealType: selectedMeal,
                                      ),
                                    );
                                Navigator.pop(stateContext);
                              },
                        child: const Text("Add Food"),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================= CALORIE GOAL EDIT =================

  void _showGoalEditDialog(BuildContext context, CalorieProvider provider) {
    final controller =
        TextEditingController(text: provider.dailyGoal.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Daily Calorie Goal"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Enter calories (e.g. 2500)",
            suffixText: "kcal",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                provider.setDailyGoal(val);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("SAVE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ================= MACRO BAR =================

  Widget _miniMacro(String label, double value, double goal, Color color) {
    final progress = (value / goal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("${value.toInt()}g", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: color.withOpacity(0.05),
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<CalorieProvider>();

    final remaining =
        provider.dailyGoal -
            provider.totalCalories;

    final calorieProgress =
        (provider.totalCalories /
                provider.dailyGoal)
            .clamp(0.0, 1.0);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAF8),
        appBar: AppBar(
          title: const Text("Nutrition Tracking"),
          backgroundColor: Colors.green,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: "TODAY'S LOG", icon: Icon(Icons.list_alt)),
              Tab(text: "ADD FOOD", icon: Icon(Icons.search)),
            ],
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /// CALORIES CONSUMED HERO
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.05),
                      blurRadius: 20,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Calories Consumed Today",
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showGoalEditDialog(context, provider),
                          child: const Icon(Icons.edit,
                              size: 16, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          provider.totalCalories.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          " / ${provider.dailyGoal} kcal",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: calorieProgress,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade100,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// MACROS ROW
              Row(
                children: [
                  Expanded(
                      child: _miniMacro("P", provider.totalProtein, 150, Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _miniMacro("C", provider.totalCarbs, 250, Colors.orange)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _miniMacro("F", provider.totalFat, 70, Colors.red)),
                ],
              ),

              const SizedBox(height: 24),

              Expanded(
                child: TabBarView(
                  children: [
                    _buildTodayLog(provider),
                    _buildAddFoodTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayLog(CalorieProvider provider) {
    if (provider.foods.isEmpty) {
      return const Center(
        child: Text("No food added today yet!"),
      );
    }

    return ListView.builder(
      itemCount: provider.foods.length,
      itemBuilder: (context, index) {
        final food = provider.foods[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.1),
              child: const Icon(Icons.restaurant, color: Colors.green, size: 20),
            ),
            title: Text(food.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                "${food.calories.toInt()} kcal • ${food.protein.toInt()}g P • ${food.mealType}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => provider.removeFood(food),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddFoodTab() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _searchFood(),
          decoration: const InputDecoration(
            hintText: "Search food...",
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_loading) const CircularProgressIndicator(),
        if (!_loading)
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final food = _results[index];
                final double cal = _getNutrient(food, 1008);
                final double protein = _getNutrient(food, 1003);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.restaurant, color: Colors.green),
                    ),
                    title: Text(food["description"],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle:
                        Text("$cal kcal / 100g • ${protein.toInt()}g protein"),
                    trailing:
                        const Icon(Icons.add_circle_outline, color: Colors.green),
                    onTap: () => _showPortionSheet(food),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
