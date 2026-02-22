import 'package:flutter/material.dart';
import '../models/free_exercise.dart';
import '../utils/app_theme.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final FreeExercise exercise;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.exercise.imageUrls();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          widget.exercise.name.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Stack(
                children: [
                  Hero(
                    tag: 'exercise_${widget.exercise.name}',
                    child: images.isNotEmpty
                        ? PageView.builder(
                            itemCount: images.length,
                            onPageChanged: (i) => setState(() => currentIndex = i),
                            itemBuilder: (context, index) {
                              return Image.network(
                                images[index],
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : _imageFallback(),
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: currentIndex == i ? 12 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: currentIndex == i ? AppTheme.accent : Colors.white70,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Cards
                  Row(
                    children: [
                      Expanded(child: _infoCard(Icons.bar_chart, "Level", widget.exercise.level, Colors.orange)),
                      const SizedBox(width: 12),
                      Expanded(child: _infoCard(Icons.fitness_center, "Equip", widget.exercise.equipment, Colors.blue)),
                    ],
                  ),

                  const SizedBox(height: 32),

                  _sectionTitle("Target Muscles"),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...widget.exercise.primaryMuscles.map((m) => _muscleTag(m, true)),
                      ...widget.exercise.secondaryMuscles.map((m) => _muscleTag(m, false)),
                    ],
                  ),

                  const SizedBox(height: 32),

                  _sectionTitle("Instructions"),
                  const SizedBox(height: 16),

                  ...widget.exercise.instructions.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "${entry.key + 1}",
                              style: const TextStyle(
                                color: AppTheme.accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                fontSize: 15,
                                color: AppTheme.textPrimary.withOpacity(0.8),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value, Color color) {
    final cleanValue = value.isEmpty ? "Standard" : value;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            cleanValue,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _muscleTag(String muscle, bool isPrimary) {
    final color = isPrimary ? AppTheme.accent : Colors.blue.shade600;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        muscle.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: AppTheme.textPrimary,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey.shade400),
    );
  }
}
