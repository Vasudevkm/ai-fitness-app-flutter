import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserProfileService {

  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(profile.toMap());
    await prefs.setString("user_profile", encoded);
  }

  Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("user_profile");

    if (data == null) return null;

    return UserProfile.fromMap(jsonDecode(data));
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("user_profile");
  }
}
