import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class UsdaService {

  Future<List<dynamic>> searchFood(String query) async {
    final response = await http.get(
      Uri.parse(
        "https://api.nal.usda.gov/fdc/v1/foods/search?query=$query&api_key=${AppConstants.usdaApiKey}"
      ),
    );

    final data = jsonDecode(response.body);
    return data["foods"] ?? [];
  }

  double getNutrient(List nutrients, int id) {
    try {
      final nutrient =
          nutrients.firstWhere((n) => n["nutrientId"] == id);
      return (nutrient["value"] ?? 0).toDouble();
    } catch (_) {
      return 0;
    }
  }
}
