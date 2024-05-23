// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:project_new/testScreen.dart';
late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51OJvAESInaGLb0MUv9RqwK5GqS1LhAWLWPfP2OVRyOzuVPepwaN9L58rWq3ixOUq39RKjkkjf2qUNjl782PntLLX00npNk74Y8';
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return
      MaterialApp(
  //  builder: EasyLoading.init(),
      home: LeftEyeTest(),// SplashScreen(),
      debugShowCheckedModeBanner: false,
    );

  }
}
