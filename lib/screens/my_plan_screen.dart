import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/workout_plan_service.dart';
import '../services/diet_plan_service.dart';
import '../models/workout_plan.dart';
import '../models/workout_day.dart';
import '../models/diet_plan.dart';
import '../models/diet_day.dart';

class MyPlanScreen extends StatefulWidget {
  const MyPlanScreen({super.key});

  @override
  State<MyPlanScreen> createState() => _MyPlanScreenState();
}

class _MyPlanScreenState extends State<MyPlanScreen> {
  @override
  Widget build(BuildContext context) {
    final workoutService = context.watch<WorkoutPlanService>();
    final dietService = context.watch<DietPlanService>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Fitness Plans"),
          backgroundColor: Colors.green,
          actions: [
            Builder(builder: (context) {
              return PopupMenuButton<String>(
                onSelected: (value) async {
                  final tabIndex = DefaultTabController.of(context).index;
                  if (value == 'clear') {
                    _showConfirmDialog(
                      "Clear Completed?",
                      "This will remove all finished items from this plan.",
                      () async {
                        if (tabIndex == 0) {
                          await workoutService.clearCompletedWorkouts();
                        } else {
                          await dietService.clearCompletedWorkouts();
                        }
                      },
                    );
                  } else if (value == 'reset') {
                    _showConfirmDialog(
                      "Reset Plan?",
                      "This will completely delete this plan.",
                      () async {
                        if (tabIndex == 0) {
                          await workoutService.resetPlan();
                        } else {
                          await dietService.resetPlan();
                        }
                      },
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: Text("Clear Completed"),
                  ),
                  const PopupMenuItem(
                    value: 'reset',
                    child: Text("Reset Active Plan"),
                  ),
                ],
              );
            }),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "WORKOUTS", icon: Icon(Icons.fitness_center)),
              Tab(text: "DIET", icon: Icon(Icons.restaurant)),
            ],
            indicatorColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: [
            _buildWorkoutTab(workoutService),
            _buildDietTab(dietService),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutTab(WorkoutPlanService workoutService) {
    final WorkoutPlan? plan = workoutService.currentPlan;

    if (plan == null) {
      return const Center(child: Text("No workout plan generated yet."));
    }

    return Column(
      children: [
        _buildProgressBar(workoutService.progress,
            "${workoutService.completedDays} / ${workoutService.totalDays} days completed"),
        Expanded(
          child: ListView.builder(
            itemCount: plan.days.length,
            itemBuilder: (context, index) {
              final WorkoutDay day = plan.days[index];
              final String displayTitle = day.title.toLowerCase().contains("day")
                  ? day.title
                  : "Day ${day.dayNumber} - ${day.title}";

              return Card(
                margin: const EdgeInsets.all(12),
                child: ExpansionTile(
                  title: Text(displayTitle),
                  trailing: Checkbox(
                    value: day.isCompleted,
                    onChanged: (_) async {
                      await workoutService.toggleDayCompletion(day.dayNumber);
                    },
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: day.isRest
                            ? [const Text("Rest Day 🧘")]
                            : day.exercises.map((e) => Text("• $e")).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDietTab(DietPlanService dietService) {
    final DietPlan? plan = dietService.currentPlan;

    if (plan == null) {
      return const Center(child: Text("No diet plan generated yet."));
    }

    return Column(
      children: [
        _buildProgressBar(dietService.progress,
            "${dietService.completedDays} / ${dietService.totalDays} days completed"),
        Expanded(
          child: ListView.builder(
            itemCount: plan.days.length,
            itemBuilder: (context, index) {
              final DietDay day = plan.days[index];
              final String displayTitle = day.title.toLowerCase().contains("day")
                  ? day.title
                  : "Day ${day.dayNumber} - ${day.title}";

              return Card(
                margin: const EdgeInsets.all(12),
                child: ExpansionTile(
                  title: Text(displayTitle),
                  trailing: Checkbox(
                    value: day.isCompleted,
                    onChanged: (_) async {
                      await dietService.toggleDayCompletion(day.dayNumber);
                    },
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: day.meals.map((m) => Text("• $m")).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double progress, String label) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.grey.shade300,
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  void _showConfirmDialog(
      String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text("CONFIRM", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
