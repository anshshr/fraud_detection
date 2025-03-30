// ignore_for_file: prefer_const_declarations, non_constant_identifier_names

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

// Function to call Groq API for customizing the user message
Future<String> customizeMessageWithGroq(String user_message) async {
  try {
    // Replace with your Groq API key
    const String groqApiKey =
        "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";

    // Define the Groq API endpoint
    final url = Uri.parse('https://api.groq.com/v1/completions');

    // Prepare the request payload
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $groqApiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'model': 'qwen-2.5-32b', // Replace with the desired Groq model
        'prompt':
            'Customize the following message to make it professional and concise: "$user_message"',
        'max_tokens': 100, // Limit the response length
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String customizedMessage =
          responseData['choices'][0]['text'].toString().trim();
      return customizedMessage;
    } else {
      print(
        "Failed to customize message with Groq. Response: ${response.body}",
      );
      return user_message; // Return the original message if customization fails
    }
  } catch (e) {
    print("Error customizing message with Groq: ${e.toString()}");
    return user_message; // Return the original message in case of an error
  }
}

Future<void> send_email_from_app(
  String user_name,
  String user_subject,
  String user_message,
) async {
  try {
    // Get the currently logged-in user
    final User? firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      print("No user is currently logged in.");
      return;
    }

    final String sender_email = firebaseUser.email ?? "no-reply@example.com";

    // Customize the user message using Groq
    final String customizedMessage = await customizeMessageWithGroq(
      user_message,
    );

    // EmailJS details
    final ser_id = 'service_nrps61o';
    final temp_id = 'template_9p49isy';
    final user_identity = '8zS-jyIk3THGHSFac';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    final response = await http.post(
      url,
      body: json.encode({
        'service_id': ser_id,
        'template_id': temp_id,
        'user_id': user_identity,
        'template_params': {
          'name': user_name,
          'user_message': customizedMessage, // Use the customized message
          'subject': user_subject,
          'user_email':
              "shubhambera2022@gmail.com", // Replace with the receiver's email
          'email': sender_email, // Sender's email
        },
      }),
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print("Email sent successfully!");
    } else {
      print("Failed to send email. Response: ${response.body}");
    }
  } catch (e) {
    print("Error sending email: ${e.toString()}");
  }
}

void main() {
  send_email_from_app(
    "Ansh",
    "Test Subject",
    "This is a test message. Please make it sound professional.",
  );
}
