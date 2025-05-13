import 'package:flutter/material.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('레시피'),
      ),
      body: Center(
        child: Text(
          '레시피 페이지',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
