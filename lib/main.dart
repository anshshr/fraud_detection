import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fraud_detection/firebase_options.dart';
import 'package:fraud_detection/services/notification_service.dart';
import 'package:fraud_detection/widgets/bottom_nav_bar.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("2c64edac-607d-4657-b7ad-c219373fae49");
  OneSignal.Notifications.requestPermission(true);
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: BottomNavBar()));
}
 