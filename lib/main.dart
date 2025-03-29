import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fraud_detection/pages/auth/pages/login_page.dart';
import 'package:fraud_detection/widgets/bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: BottomNavBar()));
}
