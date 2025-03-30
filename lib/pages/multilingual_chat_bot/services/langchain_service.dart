import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> sendMessage(String userMessage) async {
  print("entered the model of groq");
  final url = Uri.parse(
    'https://laughing-broccoli-g4494666rqvcjrv-5000.app.github.dev/chat',
  ); // Replace with your server's IP if running on a real device

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"message": userMessage}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print("AI Response: ${responseData['response']}");
      String ans = responseData['response'];

      return ans;
    } else {
      print("Error: ${response.statusCode}");
      return "Error: ${response.statusCode}";
    }
  } catch (e) {
    print("Failed to connect: $e");
    return e.toString();
  }
}

void main() {
  sendMessage("Hello, how are you?");
}
