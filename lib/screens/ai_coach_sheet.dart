import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_planner_service.dart';
import '../services/user_profile_service.dart';
import '../services/workout_plan_service.dart';
import '../services/diet_plan_service.dart';
import '../models/workout_plan.dart';
import '../models/workout_day.dart';
import '../models/diet_plan.dart';
import '../models/diet_day.dart';
import '../models/user_profile.dart';

class AICoachSheet extends StatefulWidget {
  const AICoachSheet({super.key});

  @override
  State<AICoachSheet> createState() => _AICoachSheetState();
}

class _AICoachSheetState extends State<AICoachSheet> {

  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  static const String _chatKey = "ai_chat_history";

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ================= LOAD CHAT (2 DAY MEMORY) =================

  Future<void> _loadChatHistory() async {

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_chatKey);

    if (jsonString != null) {

      final List decoded = jsonDecode(jsonString);
      final now = DateTime.now();

      final filtered = decoded.where((msg) {
        final time = DateTime.parse(msg["timestamp"]);
        return now.difference(time).inDays < 2;
      }).toList();

      setState(() {
        _messages.clear();
        for (var msg in filtered) {
          _messages.add({
            "role": msg["role"],
            "content": msg["content"]
          });
        }
      });

      await prefs.setString(_chatKey, jsonEncode(filtered));
    }

    if (_messages.isEmpty) {
      _addGreeting();
    }
  }

  Future<void> _saveChatHistory() async {

    final prefs = await SharedPreferences.getInstance();

    final data = _messages.map((msg) {
      return {
        "role": msg["role"],
        "content": msg["content"],
        "timestamp": DateTime.now().toIso8601String(),
      };
    }).toList();

    await prefs.setString(_chatKey, jsonEncode(data));
  }

  Future<void> _addGreeting() async {

    final profile = await UserProfileService().getUserProfile();
    final name = profile?.name ?? "there";

    setState(() {
      _messages.add({
        "role": "assistant",
        "content": "Hi $name! I'm Aarya, your AI Fitness Coach. I'm here to help you reach your goals, whether it's building muscle, losing weight, or just staying active. How can I assist you today?"
      });
    });

    await _saveChatHistory();
  }

  // ================= SEND MESSAGE =================

  Future<void> _sendMessage() async {

    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": text});
      _loading = true;
    });

    _scrollToBottom();
    _controller.clear();

    final UserProfile? profile =
        await UserProfileService().getUserProfile();

    if (profile == null) {
      setState(() {
        _messages.add({
          "role": "assistant",
          "content": "Please complete your profile first."
        });
        _loading = false;
      });
      await _saveChatHistory();
      return;
    }

    // ================= DYNAMIC PLAN DETECTION =================

    final lowercaseText = text.toLowerCase();
    final bool isDietPlan = lowercaseText.contains("diet") || lowercaseText.contains("meal");
    final bool isWorkoutPlan = lowercaseText.contains("workout") || lowercaseText.contains("exercise");
    final bool isPlanRequest = lowercaseText.contains("plan") || lowercaseText.contains("schedule");

    if (isPlanRequest && (isDietPlan || isWorkoutPlan)) {
      final RegExp dayRegex = RegExp(r'(\d+)\s*day');
      final match = dayRegex.firstMatch(lowercaseText);
      final int numberOfDays = int.tryParse(match?.group(1) ?? "") ?? 7; // Default to 7 days

      if (isDietPlan) {
        // ================= DIET PLAN GENERATION =================
        final planData = await AIPlannerService()
            .generateDietPlan(profile, numberOfDays);

        if (planData != null) {
          final List daysJson = planData["days"] ?? [];
          final days = daysJson.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;

            return DietDay(
              dayNumber: index + 1,
              title: data["title"] ?? "Meals",
              meals: List<String>.from(data["meals"] ?? []),
              isCompleted: false,
              completedAt: null,
            );
          }).toList();

          final plan = DietPlan(days: days);
          if (mounted) {
            await context.read<DietPlanService>().savePlan(plan);
          }

          setState(() {
            _messages.add({
              "role": "assistant",
              "content":
                  "🥗 $numberOfDays-day diet plan created successfully! Check it in the Plan tab."
            });
            _loading = false;
          });

          await _saveChatHistory();
          _scrollToBottom();
          return;
        }
      } else {
        // ================= WORKOUT PLAN GENERATION =================
        final planData = await AIPlannerService()
            .generateCustomDayPlan(profile, numberOfDays);

        if (planData != null) {
          final List daysJson = planData["days"] ?? [];
          final days = daysJson.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;

            return WorkoutDay(
              dayNumber: index + 1,
              title: data["title"] ?? "Workout",
              exercises: List<String>.from(data["exercises"] ?? []),
              isRest: data["isRest"] ?? false,
              isCompleted: false,
              completedAt: null,
            );
          }).toList();

          final plan = WorkoutPlan(days: days);
          if (mounted) {
            await context.read<WorkoutPlanService>().savePlan(plan);
          }

          setState(() {
            _messages.add({
              "role": "assistant",
              "content":
                  "✅ $numberOfDays-day workout plan created successfully!"
            });
            _loading = false;
          });

          await _saveChatHistory();
          _scrollToBottom();
          return;
        }
      }
    }

    // ================= NORMAL CHAT =================

    final response =
        await AIPlannerService()
            .generateStructuredReply(text, profile);

    setState(() {
      _messages.add({
        "role": "assistant",
        "content": response
      });
      _loading = false;
    });

    await _saveChatHistory();
    _scrollToBottom();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        title: const Text("Chat with Aarya"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              itemCount: _messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.smart_toy,
                            color: Colors.green, size: 40),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Aarya",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Text(
                        "Your Personal Fitness AI",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  );
                }

                final message = _messages[index - 1];
                final isUser = message["role"] == "user";

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.green : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isUser ? 20 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      message["content"] ?? "",
                      style: TextStyle(
                        fontSize: 15,
                        color: isUser ? Colors.white : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_loading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.green,
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Ask Aarya anything...",
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
