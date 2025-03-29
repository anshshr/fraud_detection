import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> fetchGroqResponse(String message) async {
  const String apiKey =
      "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";
  const String url = "https://api.groq.com/openai/v1/chat/completions";
  print("entered groq");
  try {
    var response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "llama-3.3-70b-versatile",
        "messages": [
          {
            "role": "user",
            "content":
                "$message Provide a clear, concise, and language-consistent response that is suitable for text-to-speech applications. Ensure that the response is generated in the same language in which the question is asked.",
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data["choices"][0]["message"]["content"]);
      String ans = data["choices"][0]["message"]["content"];
      return ans;
    } else {
      print("Error: ${response.body}");
      return "error";
    }
  } catch (e) {
    return e.toString();
  }
}
