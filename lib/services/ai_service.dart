import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class AIService {
  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  Future<String> askAI({
    required String userMessage,
    bool structured = false,
  }) async {
    final systemPrompt = structured
        ? '''
You are a certified fitness trainer.
Generate a SAFE workout plan.
Avoid medical or injury advice.
Use bullet points.
Include sets, reps, and rest.
'''
        : '''
You are a helpful AI fitness coach.
Answer clearly and safely.
Avoid medical advice.
''';

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer ${AppConstants.groqApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "llama-3.1-8b-instant",
        "messages": [
          {"role": "system", "content": systemPrompt},
          {"role": "user", "content": userMessage}
        ],
        "max_tokens": structured ? 400 : 250,
        "temperature": 0.7,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Groq error ${response.statusCode}: ${response.body}",
      );
    }

    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  }
}
