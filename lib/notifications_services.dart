import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:user_authentication_flutter/add_blog_page.dart';
import 'package:user_authentication_flutter/individualChatPage.dart';
import 'package:user_authentication_flutter/uploadProfileImage.dart';

class NotificationServices{
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void requestNotificationPermission()async{
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      criticalAlert: true,
      provisional: true,
      sound: true
    );
    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print("user granted permission for notification");
    }else if(settings.authorizationStatus == AuthorizationStatus.provisional){//to understand about provisional
      print("user granted provisional permission");
    }else{
      print("user denied permission for notifications");
    }
  }
  void initLocalNotifications(BuildContext context,RemoteMessage message) async{
    var androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = DarwinInitializationSettings();
    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
      onDidReceiveNotificationResponse: (payload){
        handleMessage(context, message);
      }
    );
  }
  void firebaseInit(BuildContext context){
    FirebaseMessaging.onMessage.listen((message) {
      // if(kDebugMode){
      //   print(message.notification!.title.toString());
      //   print(message.notification!.body.toString());
      // }
      print("in line 53 firebase init");
      print(message.notification!.title.toString());
      print(message.notification!.body.toString());
      print(message.data.toString());
      print(message.data['key']);

      initLocalNotifications(context, message);
      showNotification(message);
    });
  }
  Future<void> showNotification(RemoteMessage message)async{
    AndroidNotificationChannel  channel = AndroidNotificationChannel(Random.secure().nextInt(100000).toString(), 'High Importance Notification',importance: Importance.max);
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(channel.id.toString(),channel.name.toString(),channelDescription: "Your channel Desc",importance: Importance.high, priority: Priority.high, ticker: 'ticker');
    DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true
    );
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails
    );
    Future.delayed(Duration.zero, (){
      _flutterLocalNotificationsPlugin.show(1, message.notification!.title.toString(), message.notification!.body.toString(), notificationDetails);
    });
  }
  Future<String> getDeviceToken() async{
    String? token = await messaging.getToken();
    return token!;
  }
  void isTokenRefresh() async{//when device token will be refreshed then it will listen to the same
    messaging.onTokenRefresh.listen((event) {event.toString();});
  }
  Future<void> setupInteractMessage(BuildContext context)async {
    //when app is terminated
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage!=null){
      handleMessage(context, initialMessage);
    }
    //when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }
  void handleMessage(BuildContext context, RemoteMessage message){
    if(message.data['type']=='messageSentNotification'){

      Navigator.push(context, MaterialPageRoute(builder: (context)=>IndividualChatPage(
          name: message.data['name'],
          icon: message.data['icon'],
          targetEmailId: message.data['targetEmailId'],
          userEmailId: message.data['userEmailId'],
          newMsg: false)));
    }
  }
}