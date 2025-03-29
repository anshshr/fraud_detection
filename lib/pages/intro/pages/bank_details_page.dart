import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:fraud_detection/widgets/custom_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BankDetailsPage extends StatefulWidget {
  final PageController controller;
  final Function(Map<String, String>) onNext;

  BankDetailsPage({required this.controller, required this.onNext, Key? key})
    : super(key: key);

  @override
  _BankDetailsPageState createState() => _BankDetailsPageState();
}

class _BankDetailsPageState extends State<BankDetailsPage> {
  final TextEditingController bankName = TextEditingController();
  final TextEditingController accountNumber = TextEditingController();
  final TextEditingController ifscCode = TextEditingController();
  final TextEditingController branch = TextEditingController();
void goToNextPage() async {
  if (bankName.text.isNotEmpty &&
      accountNumber.text.isNotEmpty &&
      ifscCode.text.isNotEmpty &&
      branch.text.isNotEmpty) {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('Bank Name', bankName.text);
    prefs.setString('Account Number', accountNumber.text);
    prefs.setString('IFSC Code', ifscCode.text);
    prefs.setString('Branch', branch.text);

    widget.onNext({
      'Bank Name': bankName.text,
      'Account Number': accountNumber.text,
      'IFSC Code': ifscCode.text,
      'Branch': branch.text,
    });
    widget.controller.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
  
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://th.bing.com/th/id/OIP.iyYZ6JRT93KJHo-2axvlVwHaF7?rs=1&pid=ImgDetMain',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark Overlay
          Container(color: Colors.black.withOpacity(0.5)),
          // Centered Card with Blur Effect
          Center(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  elevation: 8,
                  color: Colors.white.withOpacity(0.75),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomTextfield(
                          controller: bankName,
                          hintText: 'Enter Your Bank Name',
                        ),
                        SizedBox(height: 15),
                        CustomTextfield(
                          controller: accountNumber,
                          hintText: 'Enter Your Account Number',
                          inputType: TextInputType.number,
                        ),
                        SizedBox(height: 15),
                        CustomTextfield(
                          controller: ifscCode,
                          hintText: 'Enter Your IFSC Code',
                        ),
                        SizedBox(height: 15),
                        CustomTextfield(
                          controller: branch,
                          hintText: 'Enter Your Bank Branch',
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: goToNextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                          ),
                          child: Text(
                            "Next",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
