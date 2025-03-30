import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> fetchGroqResponse(String message) async {
  // Replace with a valid API key (check at https://console.groq.com/keys)
  const String apiKey =
      "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";
  const String url = "https://api.groq.com/openai/v1/chat/completions";

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey", // Ensure no extra spaces
      },
      body: jsonEncode({
        "model": "llama3-8b-8192", // Updated model name
        "messages": [
          {
            "role": "system", // Use "system" for instructions
            "content":
                "Provide a clear, concise, and language-consistent response that is suitable for text-to-speech applications. Respond in the same language as the user's question.",
          },
          {
            "role": "user", // User message separate from instructions
            "content": message,
          },
        ],
        "temperature": 0.7, // Added for better control
        "max_tokens": 1024, // Prevent excessively long responses
      }),
    );

    print("Status Code: ${response.statusCode}"); // Debugging
    print("Response Body: ${response.body}"); // Debugging

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"];
    } else {
      throw Exception("API Error: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("Error in fetchGroqResponse: $e");
    return "Sorry, I couldn't process your request. Please try again.";
  }
}
