import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:fraud_detection/pages/home_page.dart';
import 'package:fraud_detection/services/dialog.dart';
import 'package:fraud_detection/widgets/my_widgets.dart';

import 'package:lottie/lottie.dart';

class PaymentPage extends StatefulWidget {
  String amount;
  PaymentPage({Key? key, required this.amount}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  String card_number = '';
  String expiry = '';
  String cvv = '';
  String card_holder_name = '';
  bool iscvvfocused = false;

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
    // await Future.delayed(Duration(seconds: 6));
    // Navigator.of(context).pop();

    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(builder: (context) => HomePage()),
    //   (route) => false,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              my_button(
                text: 'PROCEED TO PAY ${widget.amount}/-',
                ontap: () async {
                  if (card_holder_name != null &&
                      card_holder_name.isNotEmpty &&
                      card_number != null &&
                      card_number.isNotEmpty &&
                      cvv.isNotEmpty &&
                      cvv != null &&
                      expiry != null &&
                      expiry.isNotEmpty) {
                    await show_animation_navigate();
                  } else {
                    dialog(context, 'please fill all the details');
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
