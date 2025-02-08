import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/main.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/logger.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Solicitud de permisos para notificaciones
  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Usuario concedió permisos de notificación');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('⚠️ Usuario concedió permisos provisionales');
    } else {
      Get.snackbar(
        '❌ Permiso de notificación denegado',
        'Por favor, activa las notificaciones para recibir actualizaciones.',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Redirigir a la configuración de notificaciones después de 2 segundos
      Future.delayed(const Duration(seconds: 2), () {
        AppSettings.openAppSettings(type: AppSettingsType.notification);
      });
    }
  }

  void getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("📱 Token del dispositivo: $token");
  }

  void listenForTokenChanges() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'fcmToken': newToken,
        });
        print("🔄 Token actualizado automáticamente: $newToken");
      }
    });
  }

  // init
  void initLocalNotification(
      BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) {
        handleMessages(context, message);
      },
    );
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;
      if (kDebugMode) {
        print(
            "📩 Mensaje recibido en primer plano: ${message.notification?.title}");
        print(
            "📩 Mensaje recibido en primer plano body: ${message.notification?.body}");
      }
      if (Platform.isIOS) {
        iosForgroundMessage();
      }
      if (Platform.isAndroid) {
        initLocalNotification(context, message);
        //  handleMessages(context, message);
        showNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📬 Notificación tocada con la app abierta");
    });
  }

//show pop up

  void showPopup(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

//funtion to show notification
  Future<void> showNotification(RemoteMessage message) async {
    // android channel
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      message.notification!.android!.channelId.toString(),
      message.notification!.android!.channelId.toString(),
      importance: Importance.max,
      showBadge: true,
      playSound: true,
    );
//android notification details
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: "chanel description",
      importance: Importance.max,
      channelShowBadge: true,
      playSound: true,
      sound: channel.sound,
      priority: Priority.high,
    );
// ios notification details
    DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails(
            presentAlert: true, presentSound: true, presentBadge: true);
    //marge notification details
    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);
//show notification
    Future.delayed(Duration.zero, () async {
      await _flutterLocalNotificationsPlugin.show(
        0,
        message.notification?.title ?? "Nueva Notificación",
        message.notification?.body ?? "Detalles no disponibles",
        notificationDetails,
        payload: "my data",
      );
    });
  }

  // background message and temp message
  Future<void> setupInteractedMessage(BuildContext context) async {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data.isNotEmpty) {
        handleMessages(context, message);
      }
    });
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null && message.data.isNotEmpty) {
        handleMessages(context, message);
      }
    });
  }

// handle message
  Future<void> handleMessages(
      BuildContext context, RemoteMessage message) async {
    Navigator.pushNamed(
      context,
      RouteNames.notificationScreen,
      arguments: {
        'title': message.notification?.title ?? "Nueva Notificación",
        'body': message.notification?.body ?? "Detalles no disponibles",
      },
    );
    showPopup(context, message.notification?.title ?? "Nueva Notificación",
        message.notification?.body ?? "Detalles no disponibles");
  }

// ios forground message
  Future iosForgroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
