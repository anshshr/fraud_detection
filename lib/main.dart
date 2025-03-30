import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fraud_detection/firebase_options.dart';
import 'package:fraud_detection/pages/auth/pages/login_page.dart';
import 'package:fraud_detection/services/notification_service.dart';
import 'package:fraud_detection/widgets/bottom_nav_bar.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("22b6bef2-b7ae-4ff0-a873-16c944957e58");
  OneSignal.Notifications.requestPermission(true);
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: Login()));
}
