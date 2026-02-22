import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calorie_provider.dart';
import '../services/user_profile_service.dart';
import '../services/ai_planner_service.dart';
import '../services/workout_plan_service.dart';
import '../services/diet_plan_service.dart';
import '../models/workout_plan.dart';
import '../models/diet_plan.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _aiInsight;
  bool _loadingInsight = true;

  @override
  void initState() {
    super.initState();
    _loadInsight();
  }

  Future<void> _loadInsight() async {
    final profile = await UserProfileService().getUserProfile();

    if (profile != null) {
      final insight = await AIPlannerService().generateDailyInsight(profile);

      if (mounted) {
        setState(() {
          _aiInsight = insight;
          _loadingInsight = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _loadingInsight = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final calorieProvider = context.watch<CalorieProvider>();
    final workoutService = context.watch<WorkoutPlanService>();
    final dietService = context.watch<DietPlanService>();

    final remaining = calorieProvider.dailyGoal - calorieProvider.totalCalories;
    final calorieProgress = (calorieProvider.totalCalories / calorieProvider.dailyGoal).clamp(0.0, 1.0);

    final workoutPlan = workoutService.currentPlan;
    final dietPlan = dietService.currentPlan;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadInsight();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // ================= CALORIE HERO =================
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background Track
                            ShaderMask(
                              shaderCallback: (rect) {
                                return SweepGradient(
                                  startAngle: 0,
                                  endAngle: 3.14 * 2,
                                  stops: [calorieProgress, calorieProgress],
                                  colors: [
                                    Colors.greenAccent.shade400,
                                    Colors.grey.shade200,
                                  ],
                                ).createShader(rect);
                              },
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // Inner White Circle
                            Container(
                              width: 155,
                              height: 155,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${calorieProvider.totalCalories.toInt()}",
                                    style: const TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  Text(
                                    "OF ${calorieProvider.dailyGoal}",
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "kcal consumed",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),

                // ================= WORKOUT PLAN PREVIEW =================
                if (workoutPlan != null) ...[
                  const Text(
                    "Workout Progress",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPlanCard(
                    progress: workoutService.progress,
                    label: "${workoutService.completedDays} / ${workoutService.totalDays} days",
                  ),
                  const SizedBox(height: 24),
                ],

                // ================= DIET PLAN PREVIEW =================
                if (dietPlan != null) ...[
                  const Text(
                    "Diet Progress",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPlanCard(
                    progress: dietService.progress,
                    label: "${dietService.completedDays} / ${dietService.totalDays} days",
                  ),
                  const SizedBox(height: 24),
                ],

                // ================= MACROS =================
                const Text(
                  "Macros",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _macroBar("Protein", calorieProvider.totalProtein, 150, Colors.blue),
                _macroBar("Carbs", calorieProvider.totalCarbs, 250, Colors.orange),
                _macroBar("Fat", calorieProvider.totalFat, 70, Colors.red),

                const SizedBox(height: 40),

                // ================= AI INSIGHT =================
                const Text(
                  "Daily AI Coach Tip",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: _loadingInsight
                      ? const Center(child: CircularProgressIndicator())
                      : Text(
                          _aiInsight ?? "Stay consistent today 💪",
                          style: const TextStyle(fontSize: 15),
                        ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({required double progress, required String label}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade100,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _macroBar(String title, double value, double goal, Color color) {
    final progress = (value / goal).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 10,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  "${value.toStringAsFixed(0)}g / ${goal.toInt()}g",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
