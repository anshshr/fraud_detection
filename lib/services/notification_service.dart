import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendPushNotification(String message) async {
  final String url = "https://api.onesignal.com/notifications?c=push";

  final Map<String, String> headers = {
    "Authorization":
        "basic os_v2_app_frso3ldapvdfpn5nyimtop5ojf2tmtj4tkhublmnj4zjmjerpbu4hmb5gggivjnvaragrexknibxskdlfcbrbr5iuvrhn4bwrj3ylfq", // 🔥 Replace with your API Key
    "Content-Type": "application/json",
  };

  final Map<String, dynamic> body = {
    "app_id":
        "2c64edac-607d-4657-b7ad-c219373fae49", // 🔥 Replace with your OneSignal App ID
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
  sendPushNotification("🚀 New event triggered! Check it out.");
}
