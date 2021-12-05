import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapps/pages/dashboard_page.dart';
import 'package:flutter_chatapps/pages/login_page.dart';
import 'package:flutter_chatapps/utils/notif_contoller.dart';
import 'package:flutter_chatapps/utils/prefs.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  NotifController.initLocalNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: Prefs.getPerson(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.hasError && snapshot.data != null) {
            return DashboardPage();
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }
}
