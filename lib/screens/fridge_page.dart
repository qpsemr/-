import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/fridge_detail_page.dart';
import '../screens/settings_page.dart'; // 설정 페이지 임포트

class FridgePage extends StatelessWidget {
  final userId = FirebaseAuth.instance.currentUser?.uid ?? 'sampleUser';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('나의 냉장고'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.grey[700]),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsPage()),
              );
            },
          )
        ],
      ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 구분선 추가
                  Divider(color: Colors.grey[400]),

                  SizedBox(height: 12),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ...fridges.map((fridge) {
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .collection('fridges')
                              .doc(fridge.id)
                              .collection('fridge_items')
                              .snapshots(),
                          builder: (context, itemSnapshot) {
                            if (!itemSnapshot.hasData) return SizedBox();
                            final items = itemSnapshot.data!.docs;

                            final total = items.length;
                            final expiring = items.where((doc) {
                              final day = DateTime.tryParse(doc['day']);
                              return day != null && day.isBefore(DateTime.now().add(Duration(days: 3)));
                            }).length;

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
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.kitchen, size: 32, color: Colors.blueAccent),
                                    SizedBox(height: 8),
                                    Text(
                                      fridge['name'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '총 식재료: $total개',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    Text(
                                      '임박 식재료: $expiring개',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: expiring > 0 ? Colors.red : Colors.black54,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),

                      // 냉장고 추가 카드
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
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(Icons.add, size: 40, color: Colors.grey),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}