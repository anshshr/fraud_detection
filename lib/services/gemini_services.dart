import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const apiKey = "AIzaSyA8BMrypImr7UFL7NYrkqxAmggMWGom1vo";

Future<Map<String, dynamic>> getAIResponse(
  String message1,
  String message2,
) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  String user_id = auth.currentUser?.uid ?? "user_id";
  String message =
      "Analyze the provided fraud transaction data and generate a structured JSON response based on the given schema. Ensure that the overall_risk_score is a number between 1 and 100, accurately representing the likelihood of fraudulent activity. Evaluate the transaction by comparing the sender's account balance, transferred amount, and receiver's final balance to determine the risk level. Identify suspicious patterns such as large withdrawals, sudden balance drops, frequent transactions, or unusual device usage. Provide a clear and concise explanation of the risk factors, focusing on transaction patterns, anomalies, and behavioral inconsistencies. Ensure the JSON is well-structured, logically consistent, and contains only the necessary fields. Additionally, include the user ID as \"user_id\": \"${user_id}\" in the response. Make sure the evaluation reflects whether the transaction appears fraudulent or normal based on the sender's financial activity and risk patterns ad receiver financial data and fill in this  json: {"
      "\"transaction_analysis\": {"
      "\"report_summary\": \"\","
      "\"risk_evaluation\": {"
      "\"overall_risk_score\": \"\","
      "\"risk_factors\": ["
      "{"
      "\"factor\": \"\","
      "\"description\": \"\","
      "\"risk_impact\": \"\","
      "\"relevant_data\": {"
      "\"transfer_amount\": \"\","
      "\"origin_account_initial\": \"\","
      "\"origin_account_final\": \"\","
      "\"destination_account_initial\": \"\","
      "\"destination_account_final\": \"\","
      "\"origin_balance_change_percent\": \"\","
      "\"destination_balance_change_percent\": \"\""
      "},"
      "\"additional_context\": \"\""
      "}"
      "},"
      "\"transaction_details\": {"
      "\"transaction_data\": {"
      "\"step\": \"\","
      "\"type\": \"\","
      "\"transfer_amount\": \"\","
      "\"origin_account_initial_balance\": \"\","
      "\"origin_account_final_balance\": \"\","
      "\"destination_account_initial_balance\": \"\","
      "\"destination_account_final_balance\": \"\","
      "\"origin_balance_change_percentage\": \"\","
      "\"destination_balance_change_percentage\": \"\","
      "\"card_type\": \"\","
      "\"device_id\": \"\","
      "\"channel_used\": \"\","
      "\"transaction_hour\": \"\","
      "\"weekend_status\": \"\","
      "\"year\": \"\","
      "\"month\": \"\","
      "\"day\": \"\","
      "\"minute\": \"\","
      "\"second\": \"\","
      "\"microsecond\": \"\","
      "\"usd_equivalent_amount\": \"\","
      "\"bank_operational_hours\": \"\","
      "\"fraud_probability_score\": \"\","
      "\"transaction_context\": \"\","
      "\"geographical_context\": \"\","
      "\"historical_transaction_pattern\": \"\","
      "\"device_usage_pattern\": \"\","
      "}"
      "}"
      "}";

  try {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );

    final content = [Content.text(message + message1 + message2)];
    final response = await model.generateContent(content);

    // Clean and Extract JSON
    var ans = response.text?.trim().replaceAll("*", "").replaceAll("```", "");

    if (ans != null) {
      // Extract JSON part using RegExp
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(ans);
      if (jsonMatch != null) {
        final jsonString = jsonMatch.group(0);

        // Parse the response into a Map<String, dynamic>
        final jsonResponse = jsonDecode(jsonString!) as Map<String, dynamic>;

        return jsonResponse;
      } else {
        throw Exception("Valid JSON not found in AI response");
      }
    } else {
      throw Exception("Response text is null");
    }
  } catch (e) {
    print("Error: $e");
    return {"error": e.toString()};
  }
}

// Future<String> convertToFormattedString(Map<String, dynamic> data) async {
//   String message = """
//   You are provided with a Map<String, dynamic> data structure. Convert the data into a well-formatted string that contains all details exactly as they are. 
//   Preserve the accuracy of all fields, numbers, and text. 
//   Do NOT add extra details, alter the meaning, or restructure it incorrectly. 
//   Return the response as a clean and readable string representation.
  
//   Here is the data: ${data}
//   """;

//   try {
//     final model = GenerativeModel(
//       model: 'gemini-1.5-flash-latest',
//       apiKey: apiKey,
//     );

//     final content = [Content.text(message)];
//     final response = await model.generateContent(content);

//     // Extract and clean the response
//     var ans = response.text?.trim();

//     if (ans != null) {
//       // Ensure no unwanted symbols (like markdown formatting)
//       ans = ans.replaceAll("*", "").replaceAll("```", "").trim();
//       return ans;
//     } else {
//       throw Exception("Response text is null");
//     }
//   } catch (e) {
//     print("Error: $e");
//     return e.toString();
//   }
// }
