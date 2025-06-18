import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fraud_detection/firebase_options.dart';
import 'package:fraud_detection/pages/data_insights_page.dart';
import 'package:fraud_detection/pages/report_details.dart';
import 'package:fraud_detection/widgets/bottom_nav_bar.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("2c64edac-607d-4657-b7ad-c219373fae49");
  OneSignal.Notifications.requestPermission(true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final navigatorkey = GlobalKey<NavigatorState>();

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    String? screen;

    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      screen = data?["screen"];

      if (screen != null) {
        navigatorkey.currentState?.pushNamed(screen!);
      }
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "fraud detection",
      initialRoute: "/",
      routes: {
        "/": (context) => BottomNavBar(),
        "/data": (context) => BottomNavBar(),

        '/reportDetails': (context) => BottomNavBar(),
      },
    );
  }
}
