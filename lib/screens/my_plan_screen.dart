import 'package:flutter/material.dart';
import '../services/workout_plan_service.dart';
import '../models/workout_plan.dart';
import '../models/workout_day.dart';

class MyPlanScreen extends StatefulWidget {
  const MyPlanScreen({super.key});

  @override
  State<MyPlanScreen> createState() =>
      _MyPlanScreenState();
}

class _MyPlanScreenState
    extends State<MyPlanScreen> {

  final WorkoutPlanService _planService =
      WorkoutPlanService();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _planService.loadPlan();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    final WorkoutPlan? plan =
        _planService.currentPlan;

    if (plan == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "No workout plan generated yet.",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Workout Plan"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                LinearProgressIndicator(
                  value: _planService.progress,
                  minHeight: 10,
                  backgroundColor:
                      Colors.grey.shade300,
                  color: Colors.green,
                ),

                const SizedBox(height: 8),

                Text(
                  "${_planService.completedDays} / ${_planService.totalDays} days completed",
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: plan.days.length,
              itemBuilder:
                  (context, index) {

                final WorkoutDay day =
                    plan.days[index];

                return Card(
                  margin:
                      const EdgeInsets.all(12),
                  child: ExpansionTile(
                    title: Text(
                        "Day ${day.dayNumber} - ${day.title}"),
                    trailing: Checkbox(
                      value: day.isCompleted,
                      onChanged: (_) async {
                        await _planService
                            .toggleDayCompletion(
                                day.dayNumber);
                        setState(() {});
                      },
                    ),
                    children: [

                      if (day.isRest)
                        const Padding(
                          padding:
                              EdgeInsets.all(16),
                          child:
                              Text("Rest Day 🧘"),
                        ),

                      if (!day.isRest)
                        Padding(
                          padding:
                              const EdgeInsets
                                  .all(16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: day.exercises
                                .map((e) =>
                                    Text("• $e"))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
