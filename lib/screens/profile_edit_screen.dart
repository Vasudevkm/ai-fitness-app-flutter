import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../services/data_reset_service.dart';
import '../utils/app_theme.dart';
import '../utils/fitness_utils.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() =>
      _ProfileEditScreenState();
}

class _ProfileEditScreenState
    extends State<ProfileEditScreen> {

  final _service = UserProfileService();

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

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile =
        await _service.getUserProfile();

    if (profile == null) return;

    setState(() {
      nameController.text = profile.name;
      ageController.text =
          profile.age.toString();
      heightController.text =
          profile.height.toString();
      weightController.text =
          profile.weight.toString();
      experienceController.text =
          profile.experienceYears
              .toString();

      goal = profile.goal;
      activityLevel =
          profile.activityLevel;

      medicalConditions =
          List.from(
              profile.medicalConditions);
      injuries =
          List.from(profile.injuries);
      dietaryRestrictions =
          List.from(profile
              .dietaryRestrictions);
    });
  }

  Widget _input(
      String label,
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
          labelText: label,
          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildMultiSelect(
      String title,
      List<String> options,
      List<String> selectedList) {

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(title,
            style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 16)),
        ...options.map(
          (item) => CheckboxListTile(
            value:
                selectedList.contains(item),
            title: Text(item),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  selectedList
                      .add(item);
                } else {
                  selectedList
                      .remove(item);
                }
              });
            },
          ),
        )
      ],
    );
  }

  void _showLogoutDialog(
      BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:
            const Text("Confirm Logout"),
        content: const Text(
            "Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              // Reset all data for a clean slate
              await DataResetService.resetAllData(context);
              
              await FirebaseAuth.instance.signOut();
              
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text(
              "Logout",
              style:
                  TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppTheme.background,
      appBar: AppBar(
        title:
            const Text("Edit Profile"),
        backgroundColor:
            AppTheme.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [

            _input("Name",
                nameController),
            _input("Age",
                ageController,
                TextInputType
                    .number),
            _input("Height (cm)",
                heightController,
                TextInputType
                    .number),
            _input("Weight (kg)",
                weightController,
                TextInputType
                    .number),
            _input(
                "Experience (years)",
                experienceController,
                TextInputType
                    .number),

            DropdownButtonFormField<String>(
              value: goal,
              items: const [
                DropdownMenuItem(
                    value:
                        "Muscle Gain",
                    child:
                        Text("Muscle Gain")),
                DropdownMenuItem(
                    value: "Fat Loss",
                    child:
                        Text("Fat Loss")),
                DropdownMenuItem(
                    value:
                        "Maintenance",
                    child:
                        Text("Maintenance")),
              ],
              onChanged: (val) {
                setState(
                    () => goal =
                        val!);
              },
              decoration:
                  const InputDecoration(
                labelText: "Goal",
              ),
            ),

            DropdownButtonFormField<String>(
              value: activityLevel,
              items: const [
                DropdownMenuItem(
                    value:
                        "Sedentary",
                    child:
                        Text("Sedentary")),
                DropdownMenuItem(
                    value:
                        "Moderate",
                    child:
                        Text("Moderate")),
                DropdownMenuItem(
                    value:
                        "Active",
                    child:
                        Text("Active")),
              ],
              onChanged: (val) {
                setState(() =>
                    activityLevel =
                        val!);
              },
              decoration:
                  const InputDecoration(
                labelText:
                    "Activity Level",
              ),
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

            SizedBox(
              width:
                  double.infinity,
              child:
                  ElevatedButton(
                onPressed:
                    () async {

                  final experience =
                      int.tryParse(
                          experienceController
                              .text) ?? 0;

                  final level =
                      calculateLevel(
                          experience);

                  final updatedProfile =
                      UserProfile(
                    name:
                        nameController.text,
                    age: int.tryParse(
                        ageController
                            .text) ?? 0,
                    goal: goal,
                    height: int.tryParse(
                        heightController
                            .text) ?? 0,
                    weight: int.tryParse(
                        weightController
                            .text) ?? 0,
                    experienceYears:
                        experience,
                    level: level,
                    medicalConditions:
                        medicalConditions,
                    injuries:
                        injuries,
                    dietaryRestrictions:
                        dietaryRestrictions,
                    activityLevel:
                        activityLevel,
                  );

                  await _service
                      .saveUserProfile(
                          updatedProfile);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Profile updated successfully!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child:
                    const Text(
                        "Save Changes"),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width:
                  double.infinity,
              child:
                  OutlinedButton.icon(
                icon: const Icon(
                    Icons.logout,
                    color:
                        Colors.red),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                      color:
                          Colors.red),
                ),
                style:
                    OutlinedButton
                        .styleFrom(
                  side:
                      const BorderSide(
                          color:
                              Colors.red),
                ),
                onPressed: () =>
                    _showLogoutDialog(
                        context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
