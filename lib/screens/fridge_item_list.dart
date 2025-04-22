/// screens/fridge_item_list.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FridgeItemList extends StatelessWidget {
  final String fridgeId;
  final String place;

  FridgeItemList({required this.fridgeId, required this.place});

  final userId = FirebaseAuth.instance.currentUser?.uid ?? 'sampleUser';

  Stream<QuerySnapshot> getItemsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('fridges')
        .doc(fridgeId)
        .collection('fridge_items')
        .where('place', isEqualTo: place)
        .snapshots();
  }

  Future<void> _addItem(BuildContext context) async {
    String name = '';
    int count = 1;
    String day = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('식재료 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(hintText: '이름'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: InputDecoration(hintText: '수량'),
                keyboardType: TextInputType.number,
                onChanged: (value) => count = int.tryParse(value) ?? 1,
              ),
              TextField(
                decoration: InputDecoration(hintText: '유통기한 (yyyy-MM-dd)'),
                onChanged: (value) => day = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (name.isNotEmpty && day.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('fridges')
                      .doc(fridgeId)
                      .collection('fridge_items')
                      .add({
                    'name': name,
                    'count': count,
                    'day': day,
                    'place': place,
                  });
                }
                Navigator.pop(context);
              },
              child: Text('추가'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: getItemsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final items = snapshot.data!.docs;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item['name']),
                subtitle: Text('수량: ${item['count']} | 유통기한: ${item['day']}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addItem(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
