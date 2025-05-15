// screens/fridge_detail_page.dart
import 'package:flutter/material.dart';
import 'fridge_item_list.dart';
import 'recipe_page.dart';

enum SortOption { expiryAsc, expiryDesc, countDesc, countAsc }

class FridgeDetailPage extends StatefulWidget {
  final String fridgeId;
  final String fridgeName;

  const FridgeDetailPage({
    Key? key,
    required this.fridgeId,
    required this.fridgeName,
  }) : super(key: key);

  @override
  _FridgeDetailPageState createState() => _FridgeDetailPageState();
}

class _FridgeDetailPageState extends State<FridgeDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedPlace = '냉장실';
  int _selectedBottomIndex = 0;
  SortOption _sortOption = SortOption.expiryAsc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          selectedPlace = _tabController.index == 0 ? '냉장실' : '냉동실';
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onBottomTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RecipePage()),
      );
    } else {
      setState(() => _selectedBottomIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fridgeName),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '냉장실'),
            Tab(text: '냉동실'),
          ],
        ),
        actions: [
          if (_selectedBottomIndex == 0)
            PopupMenuButton<SortOption>(
              icon: const Icon(Icons.sort),
              onSelected: (opt) => setState(() => _sortOption = opt),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: SortOption.expiryAsc,
                  child: Text('유통기한 적은 순'),
                ),
                PopupMenuItem(
                  value: SortOption.expiryDesc,
                  child: Text('유통기한 많은 순'),
                ),
                PopupMenuItem(
                  value: SortOption.countDesc,
                  child: Text('수량 많은 순'),
                ),
                PopupMenuItem(
                  value: SortOption.countAsc,
                  child: Text('수량 적은 순'),
                ),
              ],
            ),
        ],
      ),
      body: _selectedBottomIndex == 0
          ? FridgeItemList(
        fridgeId: widget.fridgeId,
        place: selectedPlace,
        sortOption: _sortOption,
      )
          : const SizedBox.shrink(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomIndex,
        onTap: _onBottomTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen),
            label: '식재료',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: '레시피',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}