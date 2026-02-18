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
    final gramController =
        TextEditingController(text: "100");

    String selectedMeal = "Breakfast";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom:
                  MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: StatefulBuilder(
              builder: (context, setStateSheet) {

                double grams =
                    double.tryParse(
                            gramController.text) ??
                        0;

                double cal =
                    _getNutrient(food, 1008);
                double protein =
                    _getNutrient(food, 1003);
                double carbs =
                    _getNutrient(food, 1005);
                double fat =
                    _getNutrient(food, 1004);

                double finalCalories =
                    (cal * grams) / 100;
                double finalProtein =
                    (protein * grams) / 100;
                double finalCarbs =
                    (carbs * grams) / 100;
                double finalFat =
                    (fat * grams) / 100;

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [

                      Text(
                        food["description"] ??
                            "",
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: selectedMeal,
                        items: const [
                          DropdownMenuItem(
                              value:
                                  "Breakfast",
                              child: Text(
                                  "Breakfast")),
                          DropdownMenuItem(
                              value:
                                  "Lunch",
                              child: Text(
                                  "Lunch")),
                          DropdownMenuItem(
                              value:
                                  "Dinner",
                              child: Text(
                                  "Dinner")),
                          DropdownMenuItem(
                              value:
                                  "Snacks",
                              child: Text(
                                  "Snacks")),
                        ],
                        onChanged:
                            (value) {
                          setStateSheet(
                              () {
                            selectedMeal =
                                value!;
                          });
                        },
                        decoration:
                            const InputDecoration(
                          labelText:
                              "Meal",
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller:
                            gramController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                                decimal:
                                    true),
                        decoration:
                            const InputDecoration(
                          labelText:
                              "Grams",
                        ),
                        onChanged:
                            (value) {
                          setStateSheet(
                              () {});
                        },
                      ),

                      const SizedBox(height: 20),

                      /// LIVE MACRO PREVIEW
                      Text(
                          "Calories: ${finalCalories.toStringAsFixed(0)}"),
                      Text(
                          "Protein: ${finalProtein.toStringAsFixed(1)} g"),
                      Text(
                          "Carbs: ${finalCarbs.toStringAsFixed(1)} g"),
                      Text(
                          "Fat: ${finalFat.toStringAsFixed(1)} g"),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: grams <= 0
                            ? null
                            : () {
                                context
                                    .read<
                                        CalorieProvider>()
                                    .addFood(
                                      FoodEntry(
                                        name: food[
                                            "description"],
                                        calories:
                                            finalCalories,
                                        protein:
                                            finalProtein,
                                        carbs:
                                            finalCarbs,
                                        fat:
                                            finalFat,
                                        mealType:
                                            selectedMeal,
                                      ),
                                    );

                                Navigator.pop(
                                    context);
                              },
                        child:
                            const Text(
                                "Add Food"),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ================= MACRO BAR =================

  Widget _macroBar(
    String label,
    double value,
    double goal,
    Color color,
  ) {
    final progress =
        (value / goal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          "$label ${value.toStringAsFixed(0)}g",
          style: const TextStyle(
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          backgroundColor:
              color.withOpacity(0.15),
          valueColor:
              AlwaysStoppedAnimation(color),
        ),
        const SizedBox(height: 16),
      ],
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

    return Scaffold(
      appBar:
          AppBar(title: const Text("Nutrition")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// CALORIES
            Text(
              "Calories Remaining",
              style:
                  const TextStyle(
                      color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              remaining
                  .toStringAsFixed(0),
              style:
                  const TextStyle(
                      fontSize: 36,
                      fontWeight:
                          FontWeight.bold),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: calorieProgress,
              minHeight: 10,
            ),

            const SizedBox(height: 20),

            /// MACROS
            _macroBar(
                "Protein",
                provider.totalProtein,
                150,
                Colors.blue),
            _macroBar(
                "Carbs",
                provider.totalCarbs,
                250,
                Colors.orange),
            _macroBar(
                "Fat",
                provider.totalFat,
                70,
                Colors.red),

            const SizedBox(height: 20),

            /// SEARCH
            TextField(
              controller:
                  _searchController,
              textInputAction:
                  TextInputAction.search,
              onSubmitted:
                  (_) =>
                      _searchFood(),
              decoration:
                  const InputDecoration(
                hintText:
                    "Search food...",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            if (_loading)
              const CircularProgressIndicator(),

            if (!_loading)
              Expanded(
                child:
                    ListView.builder(
                  itemCount:
                      _results.length,
                  itemBuilder:
                      (context,
                          index) {
                    final food =
                        _results[index];

                    return ListTile(
                      title: Text(
                          food[
                              "description"]),
                      subtitle: Text(
                          "${_getNutrient(food, 1008)} kcal / 100g"),
                      onTap: () =>
                          _showPortionSheet(
                              food),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
