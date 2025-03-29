import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:fraud_detection/widgets/custom_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IdentificationPage extends StatefulWidget {
  final PageController controller;
  final Function(Map<String, String>) onNext;

  IdentificationPage({required this.controller, required this.onNext, Key? key})
    : super(key: key);

  @override
  _IdentificationPageState createState() => _IdentificationPageState();
}

class _IdentificationPageState extends State<IdentificationPage> {
  final TextEditingController aadhar = TextEditingController();
  final TextEditingController pan = TextEditingController();

void goToNextPage() async {
  if (aadhar.text.isNotEmpty || pan.text.isNotEmpty) {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('Aadhar', aadhar.text);
    prefs.setString('PAN', pan.text);

    widget.onNext({'Aadhar': aadhar.text, 'PAN': pan.text});
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
                          controller: aadhar,
                          hintText: 'Enter Your Aadhar Number',
                          inputType: TextInputType.number,
                        ),
                        SizedBox(height: 15),
                        CustomTextfield(
                          controller: pan,
                          hintText: 'Enter Your PAN Number',
                          inputType: TextInputType.text,
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
