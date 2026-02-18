import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/auth_wrapper.dart';
import 'providers/calorie_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Load .env FIRST
  await dotenv.load(fileName: ".env");

  // Debug check
  print("Loaded API Key: ${dotenv.env['GROQ_API_KEY']}");

  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (_) => CalorieProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}
