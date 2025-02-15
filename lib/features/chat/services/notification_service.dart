// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class PushNotification {
//   static final firebaseMessaging = FirebaseMessaging.instance;
//   static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   // req notification permission
//   static Future init() async {
//     await firebaseMessaging.requestPermission(
//       alert: true,
//       announcement: true,
//       badge: true,
//       carPlay: false,
//       criticalAlert: true,
//       provisional: false,
//       sound: true,
//     );

//     final token = await firebaseMessaging.getToken();
//     print("device token: $token");
//   }

//   //initialise local notif
//   static Future localNotiInit() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings(
//       "@mipmap/ic_launcher",
//     );

//     final LinuxInitializationSettings initializationSettingsLinux =
//         LinuxInitializationSettings(defaultActionName: 'Open notification');
//     final InitializationSettings initializationSettings =
//         InitializationSettings(
//             android: initializationSettingsAndroid,
//             linux: initializationSettingsLinux);
//     // request notification permissions for android 13 or above
//     flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()!
//         .requestNotificationsPermission();

//     flutterLocalNotificationsPlugin.initialize(initializationSettings,
//         onDidReceiveNotificationResponse: onNotificationTap,
//         onDidReceiveBackgroundNotificationResponse: onNotificationTap);
//   }

//   static void onNotificationTap(NotificationResponse notificationResponse) {
   
//   }
// }


