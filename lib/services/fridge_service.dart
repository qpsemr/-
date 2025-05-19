/// services/fridge_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FridgeService {
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? 'sampleUser';

  Future<int> getTotalItemCount(String fridgeId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('fridges')
        .doc(fridgeId)
        .collection('fridge_items')
        .get();
    return snapshot.docs.length;
  }

  Future<int> getExpiringItemCount(String fridgeId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('fridges')
        .doc(fridgeId)
        .collection('fridge_items')
        .get();
    final today = DateTime.now();
    return snapshot.docs.where((item) {
      try {
        final day = DateTime.parse(item['day']);
        return day.isBefore(today.add(Duration(days: 3)));
      } catch (_) {
        return false;
      }
    }).length;
  }

  Future<List<Map<String, dynamic>>> getFridgeItems(String fridgeId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('fridges')
        .doc(fridgeId)
        .collection('fridge_items')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

}




