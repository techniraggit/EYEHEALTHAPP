// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_alarm_background_trigger/flutter_alarm_background_trigger.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:platform_device_id_v2/platform_device_id_v2.dart';
import 'package:project_new/HomePage.dart';
import 'package:project_new/myPlanPage.dart';
import 'package:project_new/rewards_sync.dart';
import 'package:project_new/sign_up.dart';
import 'package:project_new/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Custom_navbar/bottom_navbar.dart';
import 'FirebaseOptions/FirebaseApi.dart';
import 'firebase_options.dart';
final navigatorKey=GlobalKey<NavigatorState>();


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);

  print("message----1bavk"+message.notification!.body.toString());
  Map<String, dynamic> parsedJson = json.decode(message.notification!.body.toString());
  String description = parsedJson['data']['description'];
  String title = parsedJson['data']['title'];
  FirebaseApi().showNotification1(title, description);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterAlarmBackgroundTrigger.initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseApi().getdeviceToken();
  //foreground noti
  FirebaseApi();
  Stripe.publishableKey =
  'pk_test_51OJvAESInaGLb0MUv9RqwK5GqS1LhAWLWPfP2OVRyOzuVPepwaN9L58rWq3ixOUq39RKjkkjf2qUNjl782PntLLX00npNk74Y8';
  // Stripe.publishableKey =
  // 'pk_test_51OHlGxSAmKaVJFiBFHlymFfDxqymuaLI34Y4AA0UslxUsqtBhKP2f4bLJnuHYKUuYggAPxUeNeq6rog5Zb4ZlGCc00vfgAiRu7';
  Fluttertoast.showToast;
  runApp(const MyApp());
  // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return
      MaterialApp(
    builder: EasyLoading.init(),
      home: SplashScreen(),
      navigatorKey: navigatorKey,
      routes: {'/notification_screen':(context)=>  SignIn(),},//Notificationpage(
      debugShowCheckedModeBanner: false,
    );

  }
}

class SplashScreen extends StatefulWidget {

  @override
  State<SplashScreen> createState() => Splash();
}

class Splash extends State<SplashScreen> {
late Future<bool>isLoggedIn;
  @override
  void initState() {
    super.initState();
    isLoggedIn = checkLoggedIn();
    Timer(
      const Duration(seconds: 3),
          () async {
        // Check condition and navigate accordingly
        if (await isLoggedIn) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OnBoardingScreen1(),
            ),
          );
        }
      },
    );
    // Timer(const Duration(seconds: 3),
    //         ()=>Navigator.push(context,
    //         MaterialPageRoute(builder:
    //             (context) =>const RewardContact()
    //             // RewardContact()//change this in final step  SecondScreen
    //         )
    //     )
    // );
  }
  Future<bool> checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? rememberMe = prefs.getBool('isLoggedIn');
    return rememberMe??false;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/splashscreen.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }}
class OnBoardingScreen1 extends StatefulWidget {
  const OnBoardingScreen1({super.key});

  @override
  _OnBoardingScreen1State createState() => _OnBoardingScreen1State();
}

class _OnBoardingScreen1State extends State<OnBoardingScreen1> {
  String deviceId = '';String deviceToken='';String deviceType='';


  Future<void> initPlatformState() async {
    String? deviceId_;    String? deviceName_;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {


      deviceId_ = await PlatformDeviceId.getDeviceId;
      if (Platform.isAndroid){
        deviceName_="android";
      }
      if (Platform.isIOS){
        deviceName_="ios";
      }
    } on PlatformException {
      deviceId_ = null;
    }


    if (!mounted) return;

    setState(() async {
      deviceId = deviceId_!;
      deviceType = deviceName_!;
      print("deviceId->$deviceId");
      print("device_type->$deviceType");
      print("device_type->${ prefs.getString('device_token')}");



      await prefs.setString('device_id', deviceId);
      await prefs.setString('device_type', deviceType);

          DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
            AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
            print('Running on ${androidInfo.id}');  // e.g. "Moto G (4)"

                   IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
                 print('Running on ${iosInfo.identifierForVendor}');  // e.g. "iPod7,1"

// WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
// print('Running on ${webBrowserInfo.userAgent}');  // e.g. "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:61.0) Gecko/20100101 Firefox/61.0"
    });
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // To position the Row at the vertical end
          children: [
            const SizedBox(height: 40,),
            Image.asset(
              'assets/onboardingperson1.png', // Replace this with your image path
              width:MediaQuery.of(context).size.width,
            ),
            SvgPicture.asset(
              'assets/unevenline.svg', // Replace this with your image path
              // width:MediaQuery.of(context).size.width,
            ),
            const SizedBox(height: 40,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Welcome to Eye Health Your Personal Eye Health Companion',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // SizedBox(height: 20,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0,vertical: 15),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'This screen can introduce the app and its purpose',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),




            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0,vertical: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  const SizedBox(width: 4,),
                  Container(
                    width: 20,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4600A9),
                      borderRadius: BorderRadius.circular(10), // Half of height to make it oval
                    ),
                  ),
                  const SizedBox(width: 4,),

                  Container(
                    width: 20,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCEB0FA),
                      borderRadius: BorderRadius.circular(10), // Half of height to make it oval
                    ),
                  ),
                  const SizedBox(width: 4,),

                  Container(
                    width: 20,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCEB0FA),
                      borderRadius: BorderRadius.circular(10), // Half of height to make it oval
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  // getDeviceInfo();
                  initPlatformState();

                  Navigator.push(context,
                      CupertinoPageRoute(builder:
                          (context) =>
                          OnBoardingScreen2()//change this in final step  SecondScreen
                      )
                  ) ;               },
                child: const Padding(
                  padding: EdgeInsets.only(right: 28.0,top:40,bottom: 20,),
                  child: SizedBox(
                    height:17 ,width: 31,
                    child: Text(
                      'Skip',
                      style: TextStyle(fontSize: 14, color: Color(0xFF4600A9),fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),

      ),

    );
  }
}





class OnBoardingScreen2 extends StatefulWidget {
  @override
  _OnBoardingScreen2State createState() => _OnBoardingScreen2State();
}

class _OnBoardingScreen2State extends State<OnBoardingScreen2> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // To position the Row at the vertical end
          children: [
            const SizedBox(height: 60,),
            Image.asset(
              'assets/onboardperson2.png', // Replace this with your image path
              width:MediaQuery.of(context).size.width,
              height: 250,
            ),
            SvgPicture.asset(
              'assets/unevenline.svg', // Replace this with your image path
              // width:MediaQuery.of(context).size.width,
            ),
            const SizedBox(height: 40,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Monitor Eye Fatigue and Reduce Digital Strain',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // SizedBox(height: 20,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0,vertical: 15),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'This screen can introduce the app and its purpose',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),




            Padding(
              padding: const EdgeInsets.fromLTRB(25,10,25,2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  const SizedBox(width: 4,),
                  Container(
                    width: 20,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCEB0FA),
                      borderRadius: BorderRadius.circular(10), // Half of height to make it oval
                    ),
                  ),
                  const SizedBox(width: 4,),

                  Container(
                    width: 20,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4600A9),
                      borderRadius: BorderRadius.circular(10), // Half of height to make it oval
                    ),
                  ),
                  const SizedBox(width: 4,),

                  Container(
                    width: 20,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCEB0FA),
                      borderRadius: BorderRadius.circular(10), // Half of height to make it oval
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4,),

            SvgPicture.asset(
              'assets/lines.svg', // Replace this with your image path
              // width:MediaQuery.of(context).size.width,
            ),
            const SizedBox(width: 4,),

            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      CupertinoPageRoute(builder:
                          (context) =>
                          OnBoardingScreen3()//change this in final step  SecondScreen
                      )
                  );               },
                child: const Padding(
                  padding: EdgeInsets.only(right: 28.0,top: 20,bottom: 20),
                  child: SizedBox(
                    height:17 ,width: 31,
                    child: Text(
                      'Skip',
                      style: TextStyle(fontSize: 14, color: Color(0xFF4600A9),fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),

      ),

    );
  }
}









class OnBoardingScreen3 extends StatefulWidget {
  @override
  _OnBoardingScreen3State createState() => _OnBoardingScreen3State();
}

class _OnBoardingScreen3State extends State<OnBoardingScreen3> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // To position the Row at the vertical end
          children: [
            const SizedBox(height: 40,),
            Image.asset(
              'assets/onboardingperson3.png', // Replace this with your image path
              width:MediaQuery.of(context).size.width,
            ),
            // Image.asset(
            //   'assets/unevenline.png', // Replace this with your image path
            //   // width:MediaQuery.of(context).size.width,
            // ),
            const SizedBox(height: 40,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Comprehensive Eye Tests at Your Fingertips',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // SizedBox(height: 20,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0,vertical: 15),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'This screen can introduce the app and its purpose',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),




            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0,vertical: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  const SizedBox(width: 4,),
                  Container(
                    width: 26,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCEB0FA),
                      borderRadius: BorderRadius.circular(10), // Half of height to make it oval
                    ),
                  ),
                  const SizedBox(width: 4,),

                  Container(
                    width: 26,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCEB0FA),
                      borderRadius: BorderRadius.circular(10), // Half of height to make it oval
                    ),
                  ),
                  const SizedBox(width: 4,),

                  Container(
                    width: 26,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4600A9),
                      borderRadius: BorderRadius.circular(10), // Half of height to make it oval
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 45.0,bottom: 20),
              child: Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder:
                            (context) =>
                            OnBoardingScreen2()//change this in final step  SecondScreen
                        )
                    )  ;              },
                  child: Container(
                    child:   ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignIn()),
                        );

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4600A9),
                        // Text color
                        // padding: EdgeInsets.all(16),
                        minimumSize: const Size(270, 50),
                        // Button padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                          // Button border radius
                        ),
                      ),
                      child: const Text('Get Started',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 16),),
                    ),

                  ),
                ),
              ),
            ),

          ],
        ),

      ),

    );
  }
}