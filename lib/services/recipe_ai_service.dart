import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RecipeAIService {
  final apiKey = dotenv.env['OPENAI_API_KEY'];

  Future<String> getRecipe(List<String> ingredients) async {
    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "gpt-4o",
        "messages": [
          {
            "role": "system",
            "content": "너는 요리 전문가야. 사용자에게 주어진 재료를 활용한 요리를 간단하고 실용적으로 추천해줘."
          },
          {
            "role": "user",
            "content": "다음 재료로 만들 수 있는 요리를 추천해줘: ${ingredients.join(', ')}"
          }
        ],
        "temperature": 0.7,
        "max_tokens": 400
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['choices'][0]['message']['content'];
    } else {
      print("GPT API 오류: ${response.body}");
      return "레시피를 받아오는 데 실패했습니다.";
    }
  }
}
