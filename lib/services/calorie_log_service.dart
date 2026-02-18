import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalorieLogService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String _todayKey() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<void> addCalories({
    required String foodName,
    required double grams,
    required double calories,
  }) async {
    final uid = _auth.currentUser!.uid;
    final dateKey = _todayKey();

    final docRef = _db
        .collection('users')
        .doc(uid)
        .collection('calorie_logs')
        .doc(dateKey);

    await _db.runTransaction((tx) async {
      final snapshot = await tx.get(docRef);

      if (!snapshot.exists) {
        tx.set(docRef, {
          'totalCalories': calories,
          'entries': [
            {
              'food': foodName,
              'grams': grams,
              'calories': calories,
              'timestamp': Timestamp.now(),
            }
          ],
        });
      } else {
        final currentTotal =
            (snapshot['totalCalories'] as num).toDouble();

        tx.update(docRef, {
          'totalCalories': currentTotal + calories,
          'entries': FieldValue.arrayUnion([
            {
              'food': foodName,
              'grams': grams,
              'calories': calories,
              'timestamp': Timestamp.now(),
            }
          ]),
        });
      }
    });
  }
}
