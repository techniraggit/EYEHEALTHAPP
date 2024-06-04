import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class FirebaseApi{
  final FirebaseMessaging _firebaseMessaging =FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin=FlutterLocalNotificationsPlugin();





  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    // Initialize flutter_local_notifications
    _initializeNotifications();
    runApp(MyApp());
  }



// new background notifctn
  Future<void> showNotification1(String title, String body) async {

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }



  FirebaseApi() {
    //forgroundnoti
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {

    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher'); // Replace 'app_icon' with your launcher icon name
    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(RemoteMessage message) async {
    print("Local notification");

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notification',
      importance: Importance.max,
    );

    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notification',
      channelDescription: 'Your channel description',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const DarwinNotificationDetails iosNotificationDetails =
    DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
    print("message----2bavk"+message.notification!.body.toString());

    Map<String, dynamic> parsedJson = json.decode(message.notification!.body.toString());

    String description = parsedJson['data']['description'];
    String title = parsedJson['data']['title'];



    await _flutterLocalNotificationsPlugin.show(
      0, title,description, notificationDetails,
    );
  }



  void requestNotificationPermission()async{
    NotificationSettings settings=await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true
    );
    if(settings.authorizationStatus==AuthorizationStatus.authorized){
      print("user granted permissions");
    }
    else if(settings.authorizationStatus==AuthorizationStatus.provisional){
      print("user granted provisional permissions");

    }else{
      print("user denied permissions");

    }
  }



  void firebaseinit(){

    print("notifctn");
    FirebaseMessaging.onMessage.listen((message) {

      FirebaseApi().showNotification(message);

      if(Platform.isIOS){
        forgroundMessage();
      }

      if(Platform.isAndroid){
        print("device_: Android");
        showNotification(message);
      }
    });
  }


  Future<void> getdeviceToken()async {
    final fcmToken= await _firebaseMessaging.getToken();
    print('Token--:$fcmToken');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_token', fcmToken.toString());
    initPushNotifications();
  }
  void handleMessage(RemoteMessage? message){
    if(message==null) {
      return;
    }
     navigatorKey.currentState?.pushNamed('/notification_screen',arguments:message,);

  }
  Future initPushNotifications()async{//handleMessage
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen( handleMessage);

  }


  Future forgroundMessage() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }




}

