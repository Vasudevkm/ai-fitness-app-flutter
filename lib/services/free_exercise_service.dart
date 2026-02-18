import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/free_exercise.dart';

class FreeExerciseService {
  static const String _url =
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json';

  List<FreeExercise>? _cache;

  Future<List<FreeExercise>> _fetchAll() async {
    if (_cache != null) return _cache!;

    final response = await http.get(Uri.parse(_url));

    final List data = jsonDecode(response.body);
    _cache = data.map((e) => FreeExercise.fromJson(e)).toList();
    return _cache!;
  }

  Future<List<FreeExercise>> getByMuscle(String muscle) async {
    final all = await _fetchAll();
    final target = muscle.toLowerCase();

    return all.where((e) {
      final primary = e.primaryMuscles
          .map((m) => m.toString().toLowerCase())
          .toList();

      final secondary = e.secondaryMuscles
          .map((m) => m.toString().toLowerCase())
          .toList();

      return primary.any((m) => m.contains(target)) ||
          secondary.any((m) => m.contains(target));
    }).toList();
  }
}
