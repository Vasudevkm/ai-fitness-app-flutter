import 'package:flutter/material.dart';
import '../services/free_exercise_service.dart';
import '../models/free_exercise.dart';
import '../utils/app_theme.dart';
import 'exercise_detail_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() =>
      _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {

  final FreeExerciseService _service =
      FreeExerciseService();

  List<FreeExercise> _allExercises = [];
  List<FreeExercise> _filteredExercises = [];

  bool _loading = true;
  String _selectedMuscle = "chest";
  String _searchQuery = "";

  final TextEditingController _searchController =
      TextEditingController();

  final List<String> muscles = [
    "chest",
    "back",
    "shoulders",
    "biceps",
    "triceps",
    "legs",
    "core",
  ];

  final Map<String, List<String>> muscleAliases = {
    "legs": [
      "quadriceps",
      "hamstrings",
      "glutes",
      "calves"
    ],
    "core": [
      "abdominals",
      "obliques",
      "lower back"
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadExercises(_selectedMuscle);
  }

  Future<void> _loadExercises(String muscle) async {
    setState(() => _loading = true);

    List<FreeExercise> results = [];

    if (muscleAliases.containsKey(muscle)) {
      for (String alias in muscleAliases[muscle]!) {
        final data =
            await _service.getByMuscle(alias);
        results.addAll(data);
      }
      results = results.toSet().toList();
    } else {
      results =
          await _service.getByMuscle(muscle);
    }

    setState(() {
      _allExercises = results;
      _applySearch();
      _loading = false;
    });
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredExercises = _allExercises;
    } else {
      _filteredExercises =
          _allExercises.where((exercise) {
        return exercise.name
            .toLowerCase()
            .contains(_searchQuery);
      }).toList();
    }
  }

  void _changeMuscle(String muscle) {
    setState(() {
      _selectedMuscle = muscle;
      _searchController.clear();
      _searchQuery = "";
    });

    _loadExercises(muscle);
  }

  Color _levelColor(String level) {
    switch (level.toLowerCase()) {
      case "beginner":
        return Colors.green;
      case "intermediate":
        return Colors.orange;
      case "expert":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text(
          "Workouts",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme:
            const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [

          /// 🔍 SEARCH BAR
          Padding(
            padding:
                const EdgeInsets.symmetric(
                    horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery =
                      value.toLowerCase();
                  _applySearch();
                });
              },
              decoration: InputDecoration(
                hintText:
                    "Search exercises...",
                prefixIcon:
                    const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets
                        .symmetric(
                        vertical: 0),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          20),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// MUSCLE SELECTOR
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection:
                  Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(
                      horizontal: 16),
              itemBuilder:
                  (context, index) {
                final muscle =
                    muscles[index];
                final selected =
                    muscle ==
                        _selectedMuscle;

                return GestureDetector(
                  onTap: () =>
                      _changeMuscle(
                          muscle),
                  child: AnimatedContainer(
                    duration:
                        const Duration(
                            milliseconds:
                                250),
                    padding:
                        const EdgeInsets
                            .symmetric(
                            horizontal:
                                18,
                            vertical:
                                10),
                    decoration:
                        BoxDecoration(
                      color: selected
                          ? Colors.green
                          : Colors.white,
                      borderRadius:
                          BorderRadius
                              .circular(
                                  20),
                    ),
                    child: Text(
                      muscle
                          .toUpperCase(),
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : Colors.black,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder:
                  (_, __) =>
                      const SizedBox(
                          width: 10),
              itemCount:
                  muscles.length,
            ),
          ),

          const SizedBox(height: 10),

          /// EXERCISE LIST
          Expanded(
            child: _loading
                ? const Center(
                    child:
                        CircularProgressIndicator())
                : _filteredExercises.isEmpty
                    ? const Center(
                        child: Text(
                          "No exercises found",
                          style: TextStyle(
                              color:
                                  Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets
                                .all(16),
                        itemCount:
                            _filteredExercises
                                .length,
                        itemBuilder:
                            (context,
                                index) {
                          final exercise =
                              _filteredExercises[
                                  index];

                          final image =
                              exercise
                                      .imageUrls()
                                      .isNotEmpty
                                  ? exercise
                                      .imageUrls()
                                      .first
                                  : null;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ExerciseDetailScreen(
                                    exercise:
                                        exercise,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin:
                                  const EdgeInsets
                                      .only(
                                      bottom:
                                          20),
                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.white,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors
                                        .black
                                        .withOpacity(
                                            0.05),
                                    blurRadius:
                                        12,
                                    offset:
                                        const Offset(
                                            0,
                                            6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [

                                  /// IMAGE
                                  ClipRRect(
                                    borderRadius:
                                        const BorderRadius
                                            .vertical(
                                      top:
                                          Radius.circular(
                                              24),
                                    ),
                                    child: image !=
                                            null
                                        ? Image.network(
                                            image,
                                            height:
                                                180,
                                            width: double
                                                .infinity,
                                            fit: BoxFit
                                                .cover,
                                          )
                                        : Container(
                                            height:
                                                180,
                                            color: Colors
                                                .grey
                                                .shade200,
                                            child:
                                                const Icon(
                                              Icons
                                                  .fitness_center,
                                              size:
                                                  60,
                                              color:
                                                  Colors
                                                      .grey,
                                            ),
                                          ),
                                  ),

                                  Padding(
                                    padding:
                                        const EdgeInsets
                                            .all(
                                            16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [

                                        Text(
                                          exercise
                                              .name,
                                          style:
                                              const TextStyle(
                                            fontSize:
                                                18,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),

                                        const SizedBox(
                                            height:
                                                8),

                                        Container(
                                          padding:
                                              const EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                      12,
                                                  vertical:
                                                      6),
                                          decoration:
                                              BoxDecoration(
                                            color: _levelColor(
                                                    exercise
                                                        .level)
                                                .withOpacity(
                                                    0.15),
                                            borderRadius:
                                                BorderRadius.circular(
                                                    20),
                                          ),
                                          child: Text(
                                            exercise
                                                .level
                                                .toUpperCase(),
                                            style:
                                                TextStyle(
                                              color: _levelColor(
                                                  exercise
                                                      .level),
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              fontSize:
                                                  12,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(
                                            height:
                                                8),

                                        Text(
                                          "Equipment: ${exercise.equipment}",
                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
