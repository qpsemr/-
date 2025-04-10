import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '냉장고 식재료 앱',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FridgePage(),
    );
  }
}

class FridgePage extends StatefulWidget {
  @override
  State<FridgePage> createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  String _sortField = 'day';
  bool _descending = true;

  void _changeSort(String field) {
    setState(() {
      if (_sortField == field) {
        _descending = !_descending;
      } else {
        _sortField = field;
        _descending = true;
      }
    });
  }

  void _showAddOrEditDialog({DocumentSnapshot? doc}) {
    final isEdit = doc != null;
    final TextEditingController nameController =
    TextEditingController(text: doc?['name'] ?? '');
    final TextEditingController countController =
    TextEditingController(text: doc?['count']?.toString() ?? '');
    String selectedLocation = doc?['location'] ?? '냉장실';
    DateTime selectedDate = DateTime.tryParse(doc?['day'] ?? '') ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? '식재료 수정' : '식재료 추가'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: '식재료 이름'),
                ),
                TextField(
                  controller: countController,
                  decoration: InputDecoration(labelText: '수량'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: selectedLocation,
                  items: ['냉장실', '냉동실']
                      .map((label) => DropdownMenuItem(
                    child: Text(label),
                    value: label,
                  ))
                      .toList(),
                  onChanged: (value) {
                    selectedLocation = value!;
                  },
                  decoration: InputDecoration(labelText: '보관 장소'),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '날짜: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Text('날짜 선택'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final count = int.tryParse(countController.text.trim()) ?? 0;
                final formattedDay =
                DateFormat("yyyy-MM-dd").format(selectedDate);

                if (name.isNotEmpty) {
                  if (isEdit) {
                    await FirebaseFirestore.instance
                        .collection('fridge_items')
                        .doc(doc!.id)
                        .update({
                      'name': name,
                      'count': count,
                      'location': selectedLocation,
                      'day': formattedDay,
                    });
                  } else {
                    await FirebaseFirestore.instance
                        .collection('fridge_items')
                        .add({
                      'name': name,
                      'count': count,
                      'location': selectedLocation,
                      'day': formattedDay,
                    });
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(isEdit ? '수정' : '추가'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildItemList(List<QueryDocumentSnapshot> docs, String location) {
    final filtered = docs
        .where((doc) => doc['location'] == location)
        .toList();

    if (filtered.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            location,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...filtered.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return ListTile(
            title: Text(data['name'] ?? '이름 없음'),
            subtitle: Text(
              '수량: ${data['count']}, 날짜: ${data['day']}',
            ),
            onTap: () => _showAddOrEditDialog(doc: doc),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('냉장고 식재료 관리'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _changeSort,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'name', child: Text('이름순')),
              PopupMenuItem(value: 'day', child: Text('날짜순')),
            ],
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('fridge_items')
            .orderBy(_sortField, descending: _descending)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView(
            children: [
              _buildItemList(docs, '냉장실'),
              _buildItemList(docs, '냉동실'),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
