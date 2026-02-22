import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../utils/app_theme.dart';
import '../utils/fitness_utils.dart';
import 'main_navigation_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState
    extends State<ProfileSetupScreen> {

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final experienceController = TextEditingController();

  String goal = "Muscle Gain";
  String activityLevel = "Moderate";

  List<String> medicalConditions = [];
  List<String> injuries = [];
  List<String> dietaryRestrictions = [];

  final List<String> availableConditions = [
    "Obesity",
    "Type 2 Diabetes",
    "Hypertension",
    "Asthma",
    "Heart Disease",
    "Thyroid Disorder",
    "PCOS",
    "Arthritis",
    "High Cholesterol",
  ];

  final List<String> availableInjuries = [
    "Knee Pain",
    "Lower Back Pain",
    "Shoulder Injury",
    "Neck Pain",
    "Ankle Injury",
  ];

  final List<String> availableDietary = [
    "Vegetarian",
    "Vegan",
    "Keto",
    "Low Carb",
    "Low Sodium",
    "Gluten Free",
    "Lactose Intolerant",
    "High Protein",
  ];

  Widget _buildMultiSelect(
      String title,
      List<String> options,
      List<String> selectedList) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold)),
        ...options.map(
          (item) => CheckboxListTile(
            title: Text(item),
            value: selectedList.contains(item),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  selectedList.add(item);
                } else {
                  selectedList.remove(item);
                }
              });
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Profile Setup"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            _input("Name", nameController),
            _input("Age", ageController,
                TextInputType.number),
            _input("Height (cm)",
                heightController,
                TextInputType.number),
            _input("Weight (kg)",
                weightController,
                TextInputType.number),
            _input("Experience (years)",
                experienceController,
                TextInputType.number),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: goal,
              items: const [
                DropdownMenuItem(
                    value: "Muscle Gain",
                    child:
                        Text("Muscle Gain")),
                DropdownMenuItem(
                    value: "Fat Loss",
                    child: Text("Fat Loss")),
                DropdownMenuItem(
                    value: "Maintenance",
                    child:
                        Text("Maintenance")),
              ],
              onChanged: (val) {
                setState(() => goal = val!);
              },
              decoration: const InputDecoration(
                  labelText: "Goal"),
            ),

            DropdownButtonFormField<String>(
              value: activityLevel,
              items: const [
                DropdownMenuItem(
                    value: "Sedentary",
                    child:
                        Text("Sedentary")),
                DropdownMenuItem(
                    value: "Moderate",
                    child:
                        Text("Moderate")),
                DropdownMenuItem(
                    value: "Active",
                    child: Text("Active")),
              ],
              onChanged: (val) {
                setState(() =>
                    activityLevel = val!);
              },
              decoration: const InputDecoration(
                  labelText:
                      "Activity Level"),
            ),

            _buildMultiSelect(
                "Medical Conditions",
                availableConditions,
                medicalConditions),

            _buildMultiSelect(
                "Injuries",
                availableInjuries,
                injuries),

            _buildMultiSelect(
                "Dietary Restrictions",
                availableDietary,
                dietaryRestrictions),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async {

                final experience =
                    int.tryParse(
                        experienceController.text) ?? 0;

                final level =
                    calculateLevel(
                        experience);

                final profile =
                    UserProfile(
                  name:
                      nameController.text,
                  age: int.tryParse(
                      ageController.text) ?? 0,
                  goal: goal,
                  height: int.tryParse(
                      heightController.text) ?? 0,
                  weight: int.tryParse(
                      weightController.text) ?? 0,
                  experienceYears:
                      experience,
                  level: level,
                  medicalConditions:
                      medicalConditions,
                  injuries: injuries,
                  dietaryRestrictions:
                      dietaryRestrictions,
                  activityLevel:
                      activityLevel,
                );

                await UserProfileService()
                    .saveUserProfile(profile);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const MainNavigationScreen(),
                  ),
                );
              },
              child:
                  const Text("Save Profile"),
            )
          ],
        ),
      ),
    );
  }

  Widget _input(String label,
      TextEditingController controller,
      [TextInputType type =
          TextInputType.text]) {
    return Padding(
      padding:
          const EdgeInsets.only(
              bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration:
            InputDecoration(
                labelText: label),
      ),
    );
  }
}
