import 'package:flutter/material.dart';
import 'ai_coach_sheet.dart';

class AICoachScreenWrapper extends StatelessWidget {
  const AICoachScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: AICoachSheet(),
      ),
    );
  }
}
