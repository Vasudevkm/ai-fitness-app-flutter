import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../services/workout_plan_service.dart';
import '../services/diet_plan_service.dart';
import 'auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // Staggered Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _nameOpacity;
  late Animation<double> _nameSlide;
  late Animation<double> _taglineOpacity;
  late Animation<double> _bgTransition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // 1. Logo Sequence (0.0 - 0.5)
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
      ),
    );

    // 2. Name Sequence (0.3 - 0.7)
    _nameOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );
    _nameSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // 3. Tagline Sequence (0.6 - 1.0)
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.9, curve: Curves.easeIn),
      ),
    );

    // Background transition
    _bgTransition = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final startTime = DateTime.now();

      await dotenv.load(fileName: ".env");
      await Firebase.initializeApp();

      final workoutService = context.read<WorkoutPlanService>();
      final dietService = context.read<DietPlanService>();

      await workoutService.loadPlan();
      await dietService.loadPlan();

      final elapsed = DateTime.now().difference(startTime);
      if (elapsed.inMilliseconds < 3000) {
        await Future.delayed(
            Duration(milliseconds: 3000 - elapsed.inMilliseconds));
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const AuthWrapper(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1.1, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 1000),
          ),
        );
      }
    } catch (e) {
      debugPrint("Initialization error: $e");
      if (mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthWrapper()));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Colors.white,
                  Color.lerp(Colors.white, const Color(0xFFE8F5E9),
                      _bgTransition.value)!,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Center Branding
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(35),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.25),
                                  blurRadius: 25,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.spa,
                              color: Colors.white,
                              size: 65,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Name
                      Opacity(
                        opacity: _nameOpacity.value,
                        child: Transform.translate(
                          offset: Offset(0, _nameSlide.value),
                          child: const Text(
                            "AROGYA",
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 8,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom Tagline
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: _taglineOpacity.value,
                    child: Column(
                      children: [
                        Text(
                          "TRACK • TRANSFORM • THRIVE",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.5,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 40,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.green.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.green),
                            minHeight: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
