import 'package:flutter/material.dart';

class RecipeDetailPage extends StatelessWidget {
  final String recipeName;
  final String recipeDetail;

  const RecipeDetailPage({
    Key? key,
    required this.recipeName,
    required this.recipeDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipeName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            recipeDetail,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
