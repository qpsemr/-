/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GptTestPage extends StatefulWidget {
  @override
  _GptTestPageState createState() => _GptTestPageState();
}

class _GptTestPageState extends State<GptTestPage> {
  String responseText = '버튼을 눌러 GPT 응답을 받아보세요';

  Future<void> testGptConnection() async {
    var apiKey = dotenv.env['OPENAI_API_KEY']; // 실제 앱에선 보안 처리 필요

    final uri = Uri.parse("https://api.openai.com/v1/chat/completions");

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "gpt-4o",
        "messages": [
          {"role": "user", "content": "계란 하나로 만들 수 있는 간단한 요리 4개 정도 알려줘 "}
        ],
        "max_tokens": 1000,
        "temperature": 0.7
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final content = data['choices'][0]['message']['content'];
      setState(() {
        responseText = content;
      });
    } else {
      setState(() {
        responseText = "❌ 오류 발생: ${res.statusCode}\n${res.body}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("GPT API 연동 테스트")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: testGptConnection,
              child: Text("GPT 응답 받아보기"),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(responseText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GptTestPage extends StatefulWidget {
  @override
  _GptTestPageState createState() => _GptTestPageState();
}

class _GptTestPageState extends State<GptTestPage> {
  List<String> ingredients = ['계란', '감자', '양파'];
  List<String> selectedIngredients = [];
  List<String> recommendedRecipes = [];
  String recipeDetail = '';
  bool isLoading = false;

  final String apiUrl = "https://api.openai.com/v1/chat/completions";

  Future<void> fetchRecipeList() async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (selectedIngredients.isEmpty) return;

    setState(() {
      isLoading = true;
      recipeDetail = '';
      recommendedRecipes = [];
    });

    final res = await http.post(
      Uri.parse(apiUrl),
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
            "다음 재료로 만들 수 있는 요리를 4가지 추천해줘: ${selectedIngredients.join(', ')}. 요리 이름만 리스트로 알려줘."
          }
        ],
        "max_tokens": 200,
        "temperature": 0.7
      }),
    );

    if (res.statusCode == 200) {
      final raw = jsonDecode(res.body)['choices'][0]['message']['content'];
      final list = raw
          .split(RegExp(r'\n|\r'))
          .map((e) => e.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
          .where((e) => e is String && e.isNotEmpty)
          .toList();
      setState(() {
        recommendedRecipes = list;
      });
    } else {
      setState(() {
        recipeDetail = "❌ 오류 발생: ${res.statusCode}\n${res.body}";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchRecipeDetail(String recipeName) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];

    setState(() {
      recipeDetail = '';
      isLoading = true;
    });

    final res = await http.post(
      Uri.parse(apiUrl),
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
            "$recipeName의 자세한 레시피를 알려줘. 재료, 만드는 순서, 소요 시간 형식으로 정리해줘."
          }
        ],
        "max_tokens": 500,
        "temperature": 0.7
      }),
    );

    if (res.statusCode == 200) {
      final content = jsonDecode(res.body)['choices'][0]['message']['content'];
      setState(() {
        recipeDetail = content;
      });
    } else {
      setState(() {
        recipeDetail = "❌ 오류 발생: ${res.statusCode}\n${res.body}";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("GPT 요리 추천 테스트")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("✅ 사용할 재료 선택:"),
            ...ingredients.map((item) => CheckboxListTile(
              title: Text(item),
              value: selectedIngredients.contains(item),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    selectedIngredients.add(item);
                  } else {
                    selectedIngredients.remove(item);
                  }
                });
              },
            )),
            ElevatedButton(
              onPressed: isLoading ? null : fetchRecipeList,
              child: Text("요리 추천받기"),
            ),
            Divider(),
            if (recommendedRecipes.isNotEmpty) ...[
              Text("🍽 추천된 요리 목록:"),
              ...recommendedRecipes.map((recipe) => ListTile(
                title: Text(recipe),
                onTap: () => fetchRecipeDetail(recipe),
              )),
            ],
            if (recipeDetail.isNotEmpty) ...[
              Divider(),
              Text("📋 레시피 상세:", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Expanded(child: SingleChildScrollView(child: Text(recipeDetail))),
            ]
          ],
        ),
      ),
    );
  }
}

