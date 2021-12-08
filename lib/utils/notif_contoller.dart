// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NotifController {
  static Future initLocalNotification() async {
    final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    if (Platform.isIOS) {
      var initializationSettingsAndroid =
          AndroidInitializationSettings('icon_notification');
      var initializationSettingsIOS = IOSInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: (id, title, body, payload) async {},
      );
      var initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onSelectNotification: (payload) async {},
      );
    } else {
      var initializationSettingsAndroid =
          AndroidInitializationSettings('icon_notification');
      var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) async {},
      );
      var initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onSelectNotification: (payload) async {},
      );
    }
  }

  static Future<void> sendNotification({
    final String type = '',
    final String myLastChat = '',
    final String myUid = '',
    final String myName = '',
    final String photo = '',
    final String personToken = '',
  }) async {
    String serverKey =
        'AAAAtWsba64:APA91bHLjVqOXTjyZyUj6jiwRq5GATX65OfE3Vgew6CRwsnWFYx12a-c5aoh4ZNsBbBrJ0cKV2lCeglkJWGyLKgWv1iV5Dl8RN9riA9_WsHGMKw9cYzrJ1QrM-J5Cgr0CToQoceJ21ky';
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=$serverKey',
        },
        body: json.encode(
          {
            'notification': {
              'body': type == 'text'
                  ? myLastChat.length >= 25
                      ? myLastChat.substring(0, 25) + '...'
                      : myLastChat
                  : '<Image>',
              'title': myName,
              "sound": "default",
              'tag': myUid,
            },
            'priority': 'high',
            'to': personToken,
          },
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  static Future<String> getTokenFromDevice() async {
    String token = '';
    try {
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      String vapidKey =
          'BPVq3Ql-UtiYGDMoC_8gsG5dRBZ9YGJ-rP8GJe5xmG8w3lxE7hc8leazFYclMfLudhBr84bAzADtpaDMFRPrtl4';
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        token =
            (await FirebaseMessaging.instance.getToken(vapidKey: vapidKey))!;
        print('User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        FirebaseMessaging.instance.getToken(vapidKey: vapidKey).then((value) {
          print('token : $value');
        });
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
      }

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage messages) {
        print('A new onMessageOpenedApp event was published!');
      });
    } catch (e) {
      print(e);
    }
    return token;
  }
}
