import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserProfileService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> saveUserProfile(UserProfile profile) async {
    // 1. Save locally for fast access
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(profile.toMap());
    await prefs.setString("user_profile", encoded);

    // 2. Sync to Firestore if user is logged in
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _db.collection('users').doc(uid).set(
            profile.toMap(),
            SetOptions(merge: true),
          );
    }
  }

  Future<UserProfile?> getUserProfile() async {
    // Try local first
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("user_profile");

    if (data != null) {
      return UserProfile.fromMap(jsonDecode(data));
    }

    // fallback to Firestore if local is missing
    return await fetchProfileFromFirestore();
  }

  Future<UserProfile?> fetchProfileFromFirestore() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _db.collection('users').doc(uid).get();

    if (doc.exists && doc.data() != null) {
      final profile = UserProfile.fromMap(doc.data()!);
      // Update local cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_profile", jsonEncode(profile.toMap()));
      return profile;
    }

    return null;
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("user_profile");
  }
}
