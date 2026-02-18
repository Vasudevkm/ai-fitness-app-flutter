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
        backgroundColor: AppTheme.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.exercise.name.toUpperCase(),
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🖼 IMAGE CAROUSEL
          if (images.isNotEmpty)
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 240,
                    child: PageView.builder(
                      itemCount: images.length,
                      onPageChanged: (i) {
                        setState(() => currentIndex = i);
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (_, __, ___) =>
                              _imageFallback(),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // ● ● ● DOT INDICATORS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: currentIndex == i ? 10 : 6,
                      height: currentIndex == i ? 10 : 6,
                      decoration: BoxDecoration(
                        color: currentIndex == i
                            ? AppTheme.accent
                            : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            _imageFallback(),

          const SizedBox(height: 24),

          _InfoTile(
            label: "Level",
            value: widget.exercise.level.isEmpty
                ? "Unknown"
                : widget.exercise.level,
          ),
          const SizedBox(height: 8),

          _InfoTile(
            label: "Equipment",
            value: widget.exercise.equipment.isEmpty
                ? "Bodyweight"
                : widget.exercise.equipment,
          ),
          const SizedBox(height: 8),

          _InfoTile(
            label: "Primary Muscles",
            value: widget.exercise.primaryMuscles.join(", "),
          ),

          if (widget.exercise.secondaryMuscles.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InfoTile(
              label: "Secondary Muscles",
              value: widget.exercise.secondaryMuscles.join(", "),
            ),
          ],

          const SizedBox(height: 24),

          const Text(
            "Instructions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ...widget.exercise.instructions.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text("• $step"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: const Text(
        "No exercise images available",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
