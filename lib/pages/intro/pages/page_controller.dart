import 'package:flutter/material.dart';
import 'package:fraud_detection/pages/intro/pages/address_page.dart';
import 'package:fraud_detection/pages/intro/pages/bank_details_page.dart';
import 'package:fraud_detection/pages/intro/pages/final_submission.dart';
import 'package:fraud_detection/pages/intro/pages/identification_page.dart';
import 'package:fraud_detection/widgets/custom_appbar.dart';

class PageControllerScreen extends StatefulWidget {
  @override
  _PageControllerScreenState createState() => _PageControllerScreenState();
}

class _PageControllerScreenState extends State<PageControllerScreen> {
  final PageController pageController = PageController();
  Map<String, String> userDetails = {};

  void saveDetails(Map<String, String> data) {
    userDetails.addAll(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: PageView(
        controller: pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          AddressPage(controller: pageController, onNext: saveDetails),
          IdentificationPage(controller: pageController, onNext: saveDetails),
          BankDetailsPage(controller: pageController, onNext: saveDetails),
          FinalSubmissionPage(),
        ],
      ),
    );
  }
}
