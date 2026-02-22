import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/workout_plan_service.dart';
import '../services/diet_plan_service.dart';
import '../utils/app_theme.dart';
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
        backgroundColor: const Color(0xFFF8FBF8),
        appBar: AppBar(
          title: const Text(
            "MY PLANS",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              fontSize: 18,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
          centerTitle: true,
          actions: [
            Builder(builder: (context) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
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
          bottom: TabBar(
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 4, color: AppTheme.accent),
              insets: const EdgeInsets.symmetric(horizontal: 40),
            ),
            labelColor: AppTheme.accent,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
            tabs: const [
              Tab(text: "WORKOUT"),
              Tab(text: "DIET"),
            ],
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
      return _buildEmptyState("Ready to transform?", "Generate your personalized workout plan with Aarya.");
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        _buildHeaderCard("Fitness Journey", workoutService.progress,
            "${workoutService.completedDays} / ${workoutService.totalDays} Days Done"),
        const SizedBox(height: 10),
        ...plan.days.map((day) => _buildDayCard(
              title: day.title.toLowerCase().contains("day")
                  ? day.title
                  : "Day ${day.dayNumber} • ${day.title}",
              isCompleted: day.isCompleted,
              isRest: day.isRest,
              items: day.exercises,
              onToggle: () => workoutService.toggleDayCompletion(day.dayNumber),
            )),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildDietTab(DietPlanService dietService) {
    final DietPlan? plan = dietService.currentPlan;

    if (plan == null) {
      return _buildEmptyState("Eat for your goals", "Generate your customized nutrition plan with Aarya.");
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        _buildHeaderCard("Nutrition Path", dietService.progress,
            "${dietService.completedDays} / ${dietService.totalDays} Days Tracked"),
        const SizedBox(height: 10),
        ...plan.days.map((day) => _buildDayCard(
              title: day.title.toLowerCase().contains("day")
                  ? day.title
                  : "Day ${day.dayNumber} • ${day.title}",
              isCompleted: day.isCompleted,
              isRest: false,
              items: day.meals,
              onToggle: () => dietService.toggleDayCompletion(day.dayNumber),
            )),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildHeaderCard(String title, double progress, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.accent, AppTheme.accent.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.01, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(color: Colors.white54, blurRadius: 4)
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${(progress * 100).toInt()}% Complete",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard({
    required String title,
    required bool isCompleted,
    required bool isRest,
    required List<String> items,
    required VoidCallback onToggle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.white.withOpacity(0.6) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: isCompleted ? Colors.grey : Colors.black87,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          leading: GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppTheme.accent : Colors.transparent,
                border: Border.all(
                  color: isCompleted ? AppTheme.accent : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check,
                size: 16,
                color: isCompleted ? Colors.white : Colors.transparent,
              ),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(60, 0, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: isRest
                    ? [
                        Text("RECOVERY DAY 🧘",
                            style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                fontSize: 13))
                      ]
                    : items
                        .map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("• ",
                                      style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
                                  Expanded(
                                      child: Text(item,
                                          style: TextStyle(color: Colors.grey.shade700, fontSize: 14))),
                                ],
                              ),
                            ))
                        .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 80, color: Colors.green.withOpacity(0.2)),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog(String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text("CONFIRM", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
