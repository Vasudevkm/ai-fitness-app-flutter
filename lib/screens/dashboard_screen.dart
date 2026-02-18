import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calorie_provider.dart';
import '../services/user_profile_service.dart';
import '../services/ai_planner_service.dart';
import '../services/workout_plan_service.dart';
import '../models/workout_plan.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {

  String? _aiInsight;
  bool _loadingInsight = true;

  final WorkoutPlanService _planService =
      WorkoutPlanService();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadInsight();
    await _planService.loadPlan();
    setState(() {});
  }

  Future<void> _loadInsight() async {

    final profile =
        await UserProfileService()
            .getUserProfile();

    if (profile != null) {

      final insight =
          await AIPlannerService()
              .generateDailyInsight(profile);

      setState(() {
        _aiInsight = insight;
        _loadingInsight = false;
      });

    } else {
      setState(() {
        _loadingInsight = false;
      });
    }
  }

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

    final WorkoutPlan? plan =
        _planService.currentPlan;

    // 🔥 Calculate plan progress safely
    int totalDays = 0;
    int completedDays = 0;
    double completionPercentage = 0;

    if (plan != null) {
      totalDays = plan.days.length;
      completedDays = plan.days
          .where((d) => d.isCompleted)
          .length;

      if (totalDays > 0) {
        completionPercentage =
            completedDays / totalDays;
      }
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7FAF8),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _initialize,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 10),

                // ================= CALORIE HERO =================
                Center(
                  child: Column(
                    children: [

                      SizedBox(
                        width: 160,
                        height: 160,
                        child: Stack(
                          alignment:
                              Alignment.center,
                          children: [

                            CircularProgressIndicator(
                              value:
                                  calorieProgress,
                              strokeWidth: 12,
                              backgroundColor:
                                  Colors.grey
                                      .shade200,
                              valueColor:
                                  const AlwaysStoppedAnimation(
                                      Colors.green),
                            ),

                            Column(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [
                                Text(
                                  "$remaining",
                                  style:
                                      const TextStyle(
                                    fontSize: 32,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  "kcal left",
                                  style:
                                      TextStyle(
                                          color: Colors
                                              .grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),

                // ================= PLAN PREVIEW =================
                if (plan != null) ...[

                  const Text(
                    "Your Workout Plan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding:
                        const EdgeInsets.all(20),
                    decoration:
                        BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                              20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.05),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [

                        LinearProgressIndicator(
                          value:
                              completionPercentage,
                          minHeight: 8,
                          backgroundColor:
                              Colors.grey
                                  .shade200,
                          color: Colors.green,
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "$completedDays / $totalDays days completed",
                          style: const TextStyle(
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],

                // ================= MACROS =================
                const Text(
                  "Macros",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

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

                const SizedBox(height: 40),

                // ================= AI INSIGHT =================
                const Text(
                  "AI Insight of the Day",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding:
                      const EdgeInsets.all(
                          20),
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius
                            .circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors
                            .black
                            .withOpacity(
                                0.05),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: _loadingInsight
                      ? const Center(
                          child:
                              CircularProgressIndicator(),
                        )
                      : Text(
                          _aiInsight ??
                              "Stay consistent today 💪",
                          style:
                              const TextStyle(
                                  fontSize:
                                      15),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _macroBar(
      String title,
      double value,
      double goal,
      Color color) {

    final progress =
        (value / goal).clamp(0.0, 1.0);

    return Padding(
      padding:
          const EdgeInsets.only(
              bottom: 18),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [

          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              Text(title),
              Text(
                  "${value.toStringAsFixed(0)}g / ${goal.toInt()}g"),
            ],
          ),

          const SizedBox(height: 6),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(
                    10),
            child:
                LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor:
                  Colors.grey
                      .shade200,
              valueColor:
                  AlwaysStoppedAnimation(
                      color),
            ),
          ),
        ],
      ),
    );
  }
}
