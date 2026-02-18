class UserProfile {
  final String name;
  final int age;
  final String goal;
  final int height;
  final int weight;
  final int experienceYears;
  final String level;

  final List<String> medicalConditions;
  final List<String> injuries;
  final List<String> dietaryRestrictions;
  final String activityLevel;

  UserProfile({
    required this.name,
    required this.age,
    required this.goal,
    required this.height,
    required this.weight,
    required this.experienceYears,
    required this.level,
    required this.medicalConditions,
    required this.injuries,
    required this.dietaryRestrictions,
    required this.activityLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "age": age,
      "goal": goal,
      "height": height,
      "weight": weight,
      "experienceYears": experienceYears,
      "level": level,
      "medicalConditions": medicalConditions,
      "injuries": injuries,
      "dietaryRestrictions": dietaryRestrictions,
      "activityLevel": activityLevel,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map["name"] ?? "",
      age: map["age"] ?? 0,
      goal: map["goal"] ?? "",
      height: map["height"] ?? 0,
      weight: map["weight"] ?? 0,
      experienceYears: map["experienceYears"] ?? 0,
      level: map["level"] ?? "",
      medicalConditions:
          List<String>.from(map["medicalConditions"] ?? []),
      injuries:
          List<String>.from(map["injuries"] ?? []),
      dietaryRestrictions:
          List<String>.from(map["dietaryRestrictions"] ?? []),
      activityLevel:
          map["activityLevel"] ?? "Moderate",
    );
  }
}
