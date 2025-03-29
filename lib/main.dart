import 'package:flutter/material.dart';
import 'package:fraud_detection/widgets/bottom_nav_bar.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomNavBar(),
      title: "fraud detection tool",
    ),
  );
}
