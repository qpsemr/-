/// screens/fridge_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/fridge_detail_page.dart';
import '../services/fridge_service.dart';

class FridgePage extends StatelessWidget {
  final FridgeService _fridgeService = FridgeService();
  final userId = FirebaseAuth.instance.currentUser?.uid ?? 'sampleUser';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('나의 냉장고')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('fridges')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final fridges = snapshot.data!.docs;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ...fridges.map((fridge) {
                    return FutureBuilder<List<int>>(
                      future: Future.wait([
                        _fridgeService.getTotalItemCount(fridge.id),
                        _fridgeService.getExpiringItemCount(fridge.id)
                      ]),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return SizedBox();
                        final total = snapshot.data![0];
                        final expiring = snapshot.data![1];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FridgeDetailPage(
                                  fridgeId: fridge.id,
                                  fridgeName: fridge['name'],
                                ),
                              ),
                            );
                          },
                          onLongPress: () async {
                            String newName = fridge['name'];
                            await showDialog(
                              context: context,
                              builder: (context) {
                                final controller = TextEditingController(text: newName);
                                return AlertDialog(
                                  title: Text('냉장고 이름 변경'),
                                  content: TextField(
                                    controller: controller,
                                    onChanged: (value) => newName = value,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        if (newName.isNotEmpty) {
                                          await fridge.reference.update({'name': newName});
                                        }
                                        Navigator.pop(context);
                                      },
                                      child: Text('변경'),
                                    )
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2 - 24,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  fridge['name'],
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text('총 식재료: $total개'),
                                Text('임박 식재료: $expiring개'),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                  GestureDetector(
                    onTap: () async {
                      String newFridgeName = '';
                      await showDialog(
                        context: context,
                        builder: (context) {
                          final controller = TextEditingController();
                          return AlertDialog(
                            title: Text('냉장고 추가'),
                            content: TextField(
                              controller: controller,
                              decoration: InputDecoration(hintText: '냉장고 이름'),
                              onChanged: (value) => newFridgeName = value,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  if (newFridgeName.isNotEmpty) {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(userId)
                                        .collection('fridges')
                                        .add({'name': newFridgeName});
                                  }
                                  Navigator.pop(context);
                                },
                                child: Text('추가'),
                              )
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2 - 24,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Icon(Icons.add, size: 40)),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
