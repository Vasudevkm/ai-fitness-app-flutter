import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'workout_screen.dart';
import 'calorie_tracking_screen.dart';
import 'ai_coach_sheet.dart';
import 'my_plan_screen.dart';
import 'profile_edit_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {

  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = const [
      DashboardScreen(),
      WorkoutScreen(),
      CalorieTrackingScreen(),
      AICoachSheet(),
      MyPlanScreen(),
      ProfileEditScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.05),
              blurRadius: 10,
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type:
              BottomNavigationBarType.fixed,
          selectedItemColor:
              Colors.green,
          unselectedItemColor:
              Colors.grey,
          showUnselectedLabels: true,
          items: const [

            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),

            BottomNavigationBarItem(
              icon:
                  Icon(Icons.fitness_center),
              label: "Workouts",
            ),

            BottomNavigationBarItem(
              icon:
                  Icon(Icons.local_fire_department),
              label: "Nutrition",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy),
              label: "AI",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: "Plan",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
