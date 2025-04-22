/// screens/fridge_detail_page.dart
import 'package:flutter/material.dart';
import '../screens/fridge_item_list.dart';

class FridgeDetailPage extends StatelessWidget {
  final String fridgeId;
  final String fridgeName;

  const FridgeDetailPage({required this.fridgeId, required this.fridgeName});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(fridgeName),
          bottom: TabBar(
            tabs: [
              Tab(text: '냉장실'),
              Tab(text: '냉동실'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FridgeItemList(fridgeId: fridgeId, place: '냉장실'),
            FridgeItemList(fridgeId: fridgeId, place: '냉동실'),
          ],
        ),
      ),
    );
  }
}
