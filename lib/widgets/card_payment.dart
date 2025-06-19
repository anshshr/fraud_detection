import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:fraud_detection/services/detection_workflow.dart';
import 'package:fraud_detection/services/dialog.dart';
import 'package:fraud_detection/services/gemini_services.dart';
import 'package:fraud_detection/widgets/bottom_nav_bar.dart';
import 'package:fraud_detection/widgets/custom_appbar.dart';
import 'package:fraud_detection/widgets/my_widgets.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CardPayment extends StatefulWidget {
  const CardPayment({Key? key}) : super(key: key);

  @override
  State<CardPayment> createState() => _CardPaymentState();
}

class _CardPaymentState extends State<CardPayment> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final DetectionWorkflow detectionWorkflow = DetectionWorkflow();
  String card_number = '';
  String expiry = '';
  String cvv = '';
  String card_holder_name = '';
  String amount = '';
  String cardType = 'Visa';
  String randomId = '';
  bool iscvvfocused = false;
  late SharedPreferences prefs;

  final List<String> cardTypes = ['Visa', 'MasterCard', 'American Express'];

  @override
  void initState() {
    super.initState();
    generateRandomId();
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("amount", 1000);
  }

  void generateRandomId() {
    setState(() {
      randomId = 'PAY-${Random().nextInt(1000000).toString().padLeft(6, '0')}';
    });
  }

  Future<void> _processPayment() async {
    if (!formkey.currentState!.validate()) {
      dialog(context, 'Please fill all the details correctly');
      return;
    }

    if (card_holder_name.isEmpty || 
        card_number.isEmpty || 
        cvv.isEmpty || 
        expiry.isEmpty || 
        amount.isEmpty) {
      dialog(context, 'Please fill all the details');
      return;
    }

    await show_animation_navigate();

    try {
      // Prepare transaction data
      Map<String, String> paymentDetails = {
        'cardHolderName': card_holder_name,
        'cardNumber': card_number,
        'cvv': cvv,
        'expiryDate': expiry,
        'amount': amount,
        'cardType': cardType,
        'transactionId': randomId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Prepare dummy data for fraud detection
      double currentBalance = prefs.getDouble("amount") ?? 1000;
      double amountValue = double.parse(amount);
      double newBalance = currentBalance - amountValue;

      Map<String, String> dummy_data = {
        "step": "1",
        "type": "4",
        "amount": amount,
        "oldbalanceOrg": currentBalance.toStringAsFixed(2),
        "newbalanceOrig": newBalance.toStringAsFixed(2),
        "oldbalanceDest": "500.00",
        "newbalanceDest": (500.00 + amountValue).toStringAsFixed(2),
        "balance_change_org": ((amountValue / currentBalance) * 100).toStringAsFixed(2),
        "balance_change_dest": ((amountValue / 500.00) * 100).toStringAsFixed(2),
      };

      // Update local balance
      await prefs.setDouble("amount", newBalance);

      // Prepare second API data
      DateTime now = DateTime.now();
      Map<String, dynamic> secondApiData = {
        "city_size": prefs.getInt('city_size') ?? 200,
        "card_type": cardTypes.indexOf(cardType),
        "device": Random().nextInt(5000) + 1000,
        "channel": Random().nextInt(5) + 1,
        "distance_from_home": Random().nextInt(50) + 1,
        "transaction_hour": now.hour,
        "weekend_transaction": now.weekday == 6 || now.weekday == 7 ? 1 : 0,
        "year": now.year % 100,
        "month": now.month,
        "day": now.weekday,
        "hour": now.hour,
        "minute": now.minute,
        "second": now.second,
        "microsecond": now.microsecond,
        "USD_converted_amount": amountValue * 0.012,
        "is_bank_operating": now.hour >= 9 && now.hour <= 17 ? 1 : 0,
        "merchant_category_label": Random().nextDouble() * 50,
        "city": prefs.getString("city") ?? "Unknown",
        "country": prefs.getString("country") ?? "Unknown",
      };

      // Get AI response
      Map<String, dynamic> ans = await getAIResponse(
        dummy_data.toString(),
        secondApiData.toString(),
      );

      // Process risk score
      double riskScore = _parseRiskScore(ans);

      // Store transaction with additional metadata
      Map<String, dynamic> transactionData = {
        ...ans,
        'paymentDetails': paymentDetails,
        'timestamp': FieldValue.serverTimestamp(),
        'formattedDate': DateFormat('MMM dd, yyyy - HH:mm').format(now),
        'status': riskScore < 50 ? 'Completed' : 
                 riskScore < 80 ? 'Pending Review' : 'Flagged',
      };

      // Store in Firestore
      await detectionWorkflow.storeDataInFirestore(transactionData);

      // Handle response
      await detectionWorkflow.handleResponse(riskScore);

      // Navigate back
      if (mounted) {
        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => BottomNavBar()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        dialog(context, 'Payment failed: ${e.toString()}');
      }
    }
  }

  double _parseRiskScore(Map<String, dynamic> ans) {
    try {
      var riskScore = ans["transaction_analysis"]["risk_evaluation"]["overall_risk_score"];
      return riskScore is int ? riskScore.toDouble() : double.parse(riskScore.toString());
    } catch (e) {
      return 0.0;
    }
  }

  Future<void> show_animation_navigate() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.network(
                'https://lottie.host/61d7fdd4-c9c1-497a-a3a9-d1317f17e306/YRUAMEzLDh.json',
              ),
              Text(
                'PROCESSING PAYMENT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.green.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.only(top: 10),
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              CreditCardWidget(
                cardNumber: card_number,
                expiryDate: expiry,
                cardHolderName: card_holder_name,
                cvvCode: cvv,
                showBackView: iscvvfocused,
                onCreditCardWidgetChange: (CreditCardBrand) {},
              ),
              CreditCardForm(
                cardNumber: card_number,
                expiryDate: expiry,
                cardHolderName: card_holder_name,
                cvvCode: cvv,
                onCreditCardModelChange: (data) {
                  setState(() {
                    card_number = data.cardNumber;
                    cvv = data.cvvCode;
                    expiry = data.expiryDate;
                    card_holder_name = data.cardHolderName;
                    iscvvfocused = data.isCvvFocused;
                  });
                },
                formKey: formkey,
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Transaction ID',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  controller: TextEditingController(text: randomId),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter Amount',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  onChanged: (value) {
                    setState(() {
                      amount = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButtonFormField<String>(
                  value: cardType,
                  items: cardTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      cardType = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Select Card Type',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              ),
              SizedBox(height: 20),
              my_button(
                text: 'PROCEED TO PAY',
                ontap: _processPayment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}