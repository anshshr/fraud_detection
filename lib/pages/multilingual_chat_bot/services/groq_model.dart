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

// import 'package:groq/groq.dart';

// Future<String> fetchGroqResponse(String message) async {
//   const String apiKey =
//       "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";
//   final groq = Groq(apiKey: apiKey, model: "qwen-2.5-coder-32b");
//   print("entered groq");

//   groq.startChat();
//   try {
//     groq.setCustomInstructionsWith(
//       "You are a helpful assistant who always responds in a friendly, concise manner.give the appropriate , clear and concise answer in the given language only",
//     );
//     GroqResponse response = await groq.sendMessage("Hello, how are you?");
//     print(response.choices.first.message.content);
//     return response.choices.first.message.content;
//   } catch (e) {
//     return e.toString();
//   }
// }
