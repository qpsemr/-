/*import 'package:flutter/material.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({Key? key, required String fridgeId}) : super(key: key);

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
}*/



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/fridge_service.dart';
import 'recipe_detail_page.dart';

class RecipePage extends StatefulWidget {
  final String fridgeId;

  const RecipePage({Key? key, required this.fridgeId}) : super(key: key);

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final FridgeService _fridgeService = FridgeService();
  late Future<List<Map<String, dynamic>>> _itemsFuture;

  final List<String> selectedIngredients = [];
  List<String> recommendedRecipes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _fridgeService.getFridgeItems(widget.fridgeId);
  }

  Future<void> fetchRecipeDetail(String recipeName) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];

    setState(() {
      isLoading = true;
    });

    final res = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "gpt-4o",
        "messages": [
          {
            "role": "user",
            "content":
            "$recipeName의 레시피를 자세히 알려줘. 재료, 만드는 순서, 소요시간 형식으로 정리해줘."
          }
        ],
        "temperature": 0.7,
        "max_tokens": 550
      }),
    );

    setState(() {
      isLoading = false;
    });

    if (res.statusCode == 200) {
      final detail = jsonDecode(res.body)['choices'][0]['message']['content'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecipeDetailPage(
            recipeName: recipeName,
            recipeDetail: detail,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("오류"),
          content: Text("레시피 정보를 불러오는 데 실패했습니다."),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("확인"))],
        ),
      );
    }
  }


  Future<void> getGptRecommendations() async {
    if (selectedIngredients.isEmpty) return;

    setState(() {
      isLoading = true;
      recommendedRecipes = [];
    });

    final apiKey = dotenv.env['OPENAI_API_KEY'];
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-4o",
        "messages": [
          {
            "role": "user",
            "content":
            "다음 재료로 만들 수 있는 요리 4가지를 추천해줘: ${selectedIngredients.join(', ')}. 요리 이름만 리스트로 알려줘."
          }
        ],
        "max_tokens": 300,
        "temperature": 0.7
      }),
    );

    if (response.statusCode == 200) {
      final raw = jsonDecode(response.body)['choices'][0]['message']['content'];
      final list = raw
          .split(RegExp(r'\n|\r'))                          // 줄바꿈으로 나누고
          .map((e) => e.toString().replaceAll(RegExp(r'^\d+\.\s*'), '').trim())  // 문자열화 + 숫자 포맷 제거
          .where((e) => e.toString().trim().isNotEmpty)     // ✅ 문자열이 비어 있지 않은 것만 필터링
          .toList();
      setState(() {
        recommendedRecipes = list.cast<String>();
      });
    } else {
      setState(() {
        recommendedRecipes = ['❌ 오류 발생: ${response.statusCode}'];
      });
    }

    setState(() {
      isLoading = false;
    });
  }



  Widget _buildIngredientList(List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...items.map((item) {
          final name = item['name'] ?? '이름 없음';
          return CheckboxListTile(
            title: Text(name),
            value: selectedIngredients.contains(name),
            onChanged: (checked) {
              setState(() {
                if (checked == true) {
                  selectedIngredients.add(name);
                } else {
                  selectedIngredients.remove(name);
                }
              });
            },
          );
        }).toList(),
        ElevatedButton(
          onPressed: isLoading ? null : getGptRecommendations,
          child: Text("요리 추천 받기"),
        ),
      ],
    );
  }

  Widget _buildRecommendedRecipes() {
    if (recommendedRecipes.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Text("🧠 추천된 요리:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...recommendedRecipes.map((recipe) => ListTile(
          title: Text(recipe),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => fetchRecipeDetail(recipe), // ✅ 바로 여기!
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('레시피 추천'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _itemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('냉장고에 등록된 재료가 없습니다.'));
            }

            final items = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildIngredientList(items),
                  _buildRecommendedRecipes(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


