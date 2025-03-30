import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

const apiKey = "AIzaSyA8BMrypImr7UFL7NYrkqxAmggMWGom1vo";

Future<Map<String, dynamic>> getAIResponse(
  String message1,
  String message2,
) async {
  String message =
      "You are provided with data from a fraud transaction model. Analyze the data and generate a JSON response by filling in the following schema with appropriate values based on your analysis. Ensure the JSON is well-structured and contains only the required data Also try to make the score values between 1 to 100. Here is the schema to fill in: {"
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
      "\"city_size\": \"\","
      "\"card_type\": \"\","
      "\"device_id\": \"\","
      "\"channel_used\": \"\","
      "\"distance_from_typical_location\": \"\","
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
      "\"merchant_category\": \"\","
      "\"fraud_probability_score\": \"\","
      "\"transaction_context\": \"\","
      "\"user_behavior_description\": \"\","
      "\"geographical_context\": \"\","
      "\"historical_transaction_pattern\": \"\","
      "\"device_usage_pattern\": \"\","
      "\"merchant_reputation\": \"\","
      "\"time_of_day_analysis\": \"\""
      "}"
      "}"
      "}";

  try {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );

    final content = [Content.text(message)];
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
