import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendPushNotification(String message) async {
  final String url = "https://api.onesignal.com/notifications?c=push";

  final Map<String, String> headers = {
    "Authorization":
        "basic os_v2_app_ek3l54vxvzh7bkdtc3eujfl6lan5b2suwkke63vgkntrpptr4uyn7kq35oumcygm6vm7yd7sdooq6a3zaeq7okb4ios4vq7zof24hfy", // 🔥 Replace with your API Key
    "Content-Type": "application/json",
  };

  final Map<String, dynamic> body = {
    "app_id":
        "22b6bef2-b7ae-4ff0-a873-16c944957e58", // 🔥 Replace with your OneSignal App ID
    "contents": {"en": message}, // Notification message
    "headings": {"en": "New Report Available"},
    "included_segments": ["All"], // 🔥 Replace with your segment
    "data": {"reportDetails": "true"},
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print("✅ Notification Sent Successfully");
    } else {
      print("❌ Failed to send notification: ${response.body}");
    }
  } catch (e) {
    print("🚨 Error sending notification: $e");
  }
}

void main() {
  sendPushNotification("this is hii from ansh");
}
