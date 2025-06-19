import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fraud_detection/pages/auth/services/auth_service.dart';
import 'package:fraud_detection/services/notification_service.dart';
import 'package:http/http.dart' as http;

class DetectionWorkflow {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final AuthService authService = AuthService();

  // 1.first take the complete data and convert into json format and store in dcb
  Map<String, String>? data;
  void get_data(Map<String, String> values) {
    data = values;
  }

  //2. store it in the db with user reference
  Future<void> storeDataInFirestore(Map<String, dynamic> inputData) async {
    try {
      final userId = authService.getCurrentUserId();
      if (userId == null) {
        throw Exception("User not logged in");
      }

      // Add transaction to user's transactions subcollection
      await firebaseFirestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .add(inputData);

      // Also add to global transactions_report collection with user reference
      await firebaseFirestore.collection('transactions_report').add({
        ...inputData,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Data stored successfully in Firestore.");
    } catch (e) {
      print("Failed to store data in Firestore: $e");
      rethrow;
    }
  }

  // 3.then based on the data make an api call to the model
  Future<int> makeApiCall(Map<String, String> inputData) async {
    final url = Uri.parse('https://ai-agent-nu.onrender.com/predict');
    final body = {
      "step": int.parse(inputData['step'] ?? '0'),
      "type": int.parse(inputData['type'] ?? '0'),
      "amount": double.parse(inputData['amount'] ?? '0.0'),
      "oldbalanceOrg": double.parse(inputData['oldbalanceOrg'] ?? '0.0'),
      "newbalanceOrig": double.parse(inputData['newbalanceOrig'] ?? '0.0'),
      "oldbalanceDest": double.parse(inputData['oldbalanceDest'] ?? '0.0'),
      "newbalanceDest": double.parse(inputData['newbalanceDest'] ?? '0.0'),
      "balance_change_org": double.parse(
        inputData['balance_change_org'] ?? '0.0',
      ),
      "balance_change_dest": double.parse(
        inputData['balance_change_dest'] ?? '0.0',
      ),
    };
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['prediction'] as int;
    } else {
      throw Exception("Failed to make API call: ${response.statusCode}");
    }
  }

  Future<int> makeSecondApiCall(Map<String, dynamic> inputData) async {
    final url = Uri.parse('https://model-financial-fraud.onrender.com/predict');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(inputData),
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['prediction'] as int;
    } else {
      throw Exception("Failed to make API call: ${response.statusCode}");
    }
  }

  // 4.get the response and make an notification in the user device
  Future<void> handleResponse(double prediction) async {
    if (prediction >= 0 && prediction < 50) {
      print("Transaction is legitimate. Low risk detected.");
      await sendPushNotification("✅ Low Risk: The transaction is legitimate.");
    } else if (prediction >= 50 && prediction < 80) {
      print("Medium risk transaction detected. Alerting user...");
      await sendPushNotification(
        "⚠️ Medium Risk: Please review the transaction.",
      );
    } else if (prediction >= 80 && prediction <= 100) {
      print("Fraudulent transaction detected! High risk alert.");
      await sendPushNotification(
        "🚨 High Risk: Fraudulent transaction detected!",
      );
    } else {
      print("Invalid prediction value received.");
    }
  }
}
