import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:fraud_detection/services/detection_workflow.dart';
import 'package:fraud_detection/services/dialog.dart';
import 'package:fraud_detection/services/gemini_services.dart';
import 'package:fraud_detection/widgets/bottom_nav_bar.dart';
import 'package:fraud_detection/widgets/my_widgets.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

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
  String cardType = 'Visa'; // Default card type
  String randomId = '';
  bool iscvvfocused = false;

  final List<String> cardTypes = ['Visa', 'MasterCard', 'American Express'];

  @override
  void initState() {
    super.initState();
    generateRandomId();
  }

  void generateRandomId() {
    setState(() {
      randomId = 'PAY-${Random().nextInt(1000000).toString().padLeft(6, '0')}';
    });
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
    await Future.delayed(Duration(seconds: 6));
    Navigator.of(context).pop();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => BottomNavBar()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PAYMENT PAGE'),
        backgroundColor: Colors.deepPurple[100],
        centerTitle: true,
      ),
      body: Container(
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
                  items:
                      cardTypes.map((type) {
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
              SizedBox(height: 10),
              my_button(
                text: 'PROCEED TO PAY',
                ontap: () async {
                  if (card_holder_name.isNotEmpty &&
                      card_number.isNotEmpty &&
                      cvv.isNotEmpty &&
                      expiry.isNotEmpty &&
                      amount.isNotEmpty) {
                    print('All fields are filled. Proceeding with payment...');
                    Map<String, String> paymentDetails = {
                      'Card Holder Name': card_holder_name,
                      'Card Number': card_number,
                      'CVV': cvv,
                      'Expiry Date': expiry,
                      'Amount': amount,
                      'Card Type': cardType,
                      'Transaction ID': randomId,
                    };
                    print('Payment Details: $paymentDetails');

                    Map<String, String> dummy_data = {
                      "step": "1",
                      "type": "4",
                      "amount": amount,
                      "oldbalanceOrg":
                          "1000.00", // Example initial balance for origin
                      "newbalanceOrig": (1000.00 - double.parse(amount))
                          .toStringAsFixed(6),
                      "oldbalanceDest":
                          "500.00", // Example initial balance for destination
                      "newbalanceDest": (500.00 + double.parse(amount))
                          .toStringAsFixed(6),
                      "balance_change_org": ((double.parse(amount) / 1000.00) *
                              100)
                          .toStringAsFixed(6),
                      "balance_change_dest": ((double.parse(amount) / 500.00) *
                              100)
                          .toStringAsFixed(6),
                    };
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    int citySize =
                        prefs.getInt('city_size') ??
                        200; // Default to 2 if not found

                    DateTime now = DateTime.now();
                    Map<String, dynamic> secondApiData = {
                      "city_size": citySize,
                      "card_type": cardTypes.indexOf(cardType),
                      "device":
                          Random().nextInt(5000) +
                          1000, // Random device ID between 1000 and 6000
                      "channel":
                          Random().nextInt(5) +
                          1, // Random channel between 1 and 5
                      "distance_from_home":
                          Random().nextInt(50) +
                          1, // Random distance between 1 and 50
                      "transaction_hour": now.hour,
                      "weekend_transaction":
                          now.weekday == 6 || now.weekday == 7 ? 1 : 0,
                      "year": now.year % 100, // Last two digits of the year
                      "month": now.month,
                      "day": now.weekday,
                      "hour": now.hour,
                      "minute": now.minute,
                      "second": now.second,
                      "microsecond": now.microsecond,
                      "USD_converted_amount": double.parse(amount) * 0.012,
                      "is_bank_operating":
                          now.hour >= 9 && now.hour <= 17 ? 1 : 0,
                      "merchant_category_label": Random().nextDouble() * 50,
                      "city" : prefs.getString("city"),
                      "country" : prefs.getString("country"),
                    };
                    print('Dummy Data: $dummy_data');
                    print('Dummy Data2: $secondApiData');

                    detectionWorkflow.data = dummy_data;
                    // print('Storing data in Firestore...');
                    // await detectionWorkflow.storeDataInFirestore(dummy_data);

                    print('Making API call...');
                    int prediction1 = await detectionWorkflow.makeApiCall(
                      dummy_data,
                    );
                    print('Making  second API call...');
                    int prediction2 = await detectionWorkflow.makeSecondApiCall(
                      secondApiData,
                    );
                    print('API call completed. Prediction: $prediction2');

                    print('Handling response...');
                    await detectionWorkflow.handleResponse(
                      ((prediction1 + prediction2) / 2),
                    );

                    print('Gettings the the report from the Gemini');

                    Map<String, dynamic> ans = await getAIResponse(
                      dummy_data.toString(),
                      secondApiData.toString(),
                    );

                    print('Storing data in Firestore...');
                    await detectionWorkflow.storeDataInFirestore(ans);

                    print('Showing animation and navigating...');
                    await show_animation_navigate();
                  } else {
                    dialog(context, 'Please fill all the details');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
