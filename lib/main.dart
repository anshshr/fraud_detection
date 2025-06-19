import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fraud_detection/firebase_options.dart';
import 'package:fraud_detection/pages/auth/pages/auth_screen.dart';
import 'package:fraud_detection/pages/auth/pages/login_page.dart';
import 'package:fraud_detection/pages/data_insights_page.dart';
import 'package:fraud_detection/widgets/bottom_nav_bar.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("22b6bef2-b7ae-4ff0-a873-16c944957e58");
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      navigatorKey: navigatorkey,
      debugShowCheckedModeBanner: false,
      title: "Fraud Detection",
      initialRoute: "/auth",
      routes: {
        "/auth": (context) => AuthScreen(),
        "/": (context) => Login(),
        "/data": (context) => DataInsightsPage(),
        '/reportDetails': (context) => BottomNavBar(),
      },
    );
  }
}
