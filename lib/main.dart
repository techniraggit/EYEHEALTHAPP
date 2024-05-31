// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:platform_device_id_v2/platform_device_id_v2.dart';
import 'package:project_new/HomePage.dart';
import 'package:project_new/eyeHealthTrack.dart';
import 'package:project_new/Rewards/rewards_sync.dart';
import 'package:project_new/sign_up.dart';
import 'package:project_new/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Custom_navbar/bottom_navbar.dart';
import 'FirebaseOptions/FirebaseApi.dart';
import 'eyeFatigueTest/eyeFatigueTestReport.dart';
import 'firebase_options.dart';
final navigatorKey=GlobalKey<NavigatorState>();
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
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
  // FlutterAlarmBackgroundTrigger.initialize();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Alarm.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseApi().getdeviceToken();
  //foreground noti
  FirebaseApi();
  Stripe.publishableKey =
  'pk_test_51OJvAESInaGLb0MUv9RqwK5GqS1LhAWLWPfP2OVRyOzuVPepwaN9L58rWq3ixOUq39RKjkkjf2qUNjl782PntLLX00npNk74Y8';

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
        home: SplashScreen(),// SplashScreen(),
        navigatorKey: navigatorKey,

        // theme: ThemeData.dark(),
        routes: {'/notification_screen':(context)=>  SignIn(),
          },//Notificationpage(
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
              builder: (context) =>HomePage(),
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

//
// import 'dart:async';
// import 'dart:io';
//
// import 'package:alarm/alarm.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
//
// import 'dart:async';
//
// import 'package:alarm/alarm.dart';
// import 'package:alarm/model/alarm_settings.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//
//   await Alarm.init();
//
//   runApp(
//     MaterialApp(
//       theme: ThemeData(useMaterial3: false),
//       home: const ExampleAlarmHomeScreen(),
//     ),
//   );
// }
//
//
// class ExampleAlarmHomeScreen extends StatefulWidget {
//   const ExampleAlarmHomeScreen({super.key});
//
//   @override
//   State<ExampleAlarmHomeScreen> createState() => _ExampleAlarmHomeScreenState();
// }
//
// class _ExampleAlarmHomeScreenState extends State<ExampleAlarmHomeScreen> {
//   late List<AlarmSettings> alarms;
//
//   static StreamSubscription<AlarmSettings>? subscription;
//
//   @override
//   void initState() {
//     super.initState();
//     if (Alarm.android) {
//       checkAndroidNotificationPermission();
//       checkAndroidScheduleExactAlarmPermission();
//     }
//     loadAlarms();
//     subscription ??= Alarm.ringStream.stream.listen(navigateToRingScreen);
//   }
//
//   void loadAlarms() {
//     setState(() {
//       alarms = Alarm.getAlarms();
//       alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
//     });
//   }
//
//   Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute<void>(
//         builder: (context) =>
//             ExampleAlarmRingScreen(alarmSettings: alarmSettings),
//       ),
//     );
//     loadAlarms();
//   }
//
//   Future<void> navigateToAlarmScreen(AlarmSettings? settings) async {
//     final res = await showModalBottomSheet<bool?>(
//       context: context,
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       builder: (context) {
//         return FractionallySizedBox(
//           heightFactor: 0.75,
//           child: ExampleAlarmEditScreen(alarmSettings: settings),
//         );
//       },
//     );
//
//     if (res != null && res == true) loadAlarms();
//   }
//
//   Future<void> checkAndroidNotificationPermission() async {
//     final status = await Permission.notification.status;
//     if (status.isDenied) {
//       alarmPrint('Requesting notification permission...');
//       final res = await Permission.notification.request();
//       alarmPrint(
//         'Notification permission ${res.isGranted ? '' : 'not '}granted',
//       );
//     }
//   }
//
//   Future<void> checkAndroidExternalStoragePermission() async {
//     final status = await Permission.storage.status;
//     if (status.isDenied) {
//       alarmPrint('Requesting external storage permission...');
//       final res = await Permission.storage.request();
//       alarmPrint(
//         'External storage permission ${res.isGranted ? '' : 'not'} granted',
//       );
//     }
//   }
//
//   Future<void> checkAndroidScheduleExactAlarmPermission() async {
//     final status = await Permission.scheduleExactAlarm.status;
//     alarmPrint('Schedule exact alarm permission: $status.');
//     if (status.isDenied) {
//       alarmPrint('Requesting schedule exact alarm permission...');
//       final res = await Permission.scheduleExactAlarm.request();
//       alarmPrint(
//         'Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted',
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     subscription?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('alarm 3.1.4')),
//       body: SafeArea(
//         child: alarms.isNotEmpty
//             ? ListView.separated(
//           itemCount: alarms.length,
//           separatorBuilder: (context, index) => const Divider(height: 1),
//           itemBuilder: (context, index) {
//             return ExampleAlarmTile(
//               key: Key(alarms[index].id.toString()),
//               title: TimeOfDay(
//                 hour: alarms[index].dateTime.hour,
//                 minute: alarms[index].dateTime.minute,
//               ).format(context),
//               onPressed: () => navigateToAlarmScreen(alarms[index]),
//               onDismissed: () {
//                 Alarm.stop(alarms[index].id).then((_) => loadAlarms());
//               },
//             );
//           },
//         )
//             : Center(
//           child: Text(
//             'No alarms set',
//             style: Theme.of(context).textTheme.titleMedium,
//           ),
//         ),
//       ),
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             ExampleAlarmHomeShortcutButton(refreshAlarms: loadAlarms),
//             FloatingActionButton(
//               onPressed: () => navigateToAlarmScreen(null),
//               child: const Icon(Icons.alarm_add_rounded, size: 33),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }
// }
//
//
// class ExampleAlarmEditScreen extends StatefulWidget {
//   const ExampleAlarmEditScreen({super.key, this.alarmSettings});
//
//   final AlarmSettings? alarmSettings;
//
//   @override
//   State<ExampleAlarmEditScreen> createState() => _ExampleAlarmEditScreenState();
// }
//
// class _ExampleAlarmEditScreenState extends State<ExampleAlarmEditScreen> {
//   bool loading = false;
//
//   late bool creating;
//   late DateTime selectedDateTime;
//   late bool loopAudio;
//   late bool vibrate;
//   late double? volume;
//   late String assetAudio;
//
//   @override
//   void initState() {
//     super.initState();
//     creating = widget.alarmSettings == null;
//
//     if (creating) {
//       selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
//       selectedDateTime = selectedDateTime.copyWith(second: 0, millisecond: 0);
//       loopAudio = true;
//       vibrate = true;
//       volume = null;
//       assetAudio = 'assets/marimba.mp3';
//     } else {
//       selectedDateTime = widget.alarmSettings!.dateTime;
//       loopAudio = widget.alarmSettings!.loopAudio;
//       vibrate = widget.alarmSettings!.vibrate;
//       volume = widget.alarmSettings!.volume;
//       assetAudio = widget.alarmSettings!.assetAudioPath;
//     }
//   }
//
//   String getDay() {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final difference = selectedDateTime.difference(today).inDays;
//
//     switch (difference) {
//       case 0:
//         return 'Today';
//       case 1:
//         return 'Tomorrow';
//       case 2:
//         return 'After tomorrow';
//       default:
//         return 'In $difference days';
//     }
//   }
//
//   Future<void> pickTime() async {
//     final res = await showTimePicker(
//       initialTime: TimeOfDay.fromDateTime(selectedDateTime),
//       context: context,
//     );
//
//     if (res != null) {
//       setState(() {
//         final now = DateTime.now();
//         selectedDateTime = now.copyWith(
//           hour: res.hour,
//           minute: res.minute,
//           second: 0,
//           millisecond: 0,
//           microsecond: 0,
//         );
//         if (selectedDateTime.isBefore(now)) {
//           selectedDateTime = selectedDateTime.add(const Duration(days: 1));
//         }
//       });
//     }
//   }
//
//   AlarmSettings buildAlarmSettings() {
//     final id = creating
//         ? DateTime.now().millisecondsSinceEpoch % 10000 + 1
//         : widget.alarmSettings!.id;
//
//     final alarmSettings = AlarmSettings(
//       id: id,
//       dateTime: selectedDateTime,
//       loopAudio: loopAudio,
//       vibrate: vibrate,
//       volume: volume,
//       assetAudioPath: assetAudio,
//       notificationTitle: 'Alarm example',
//       notificationBody: 'Your alarm ($id) is ringing',
//       enableNotificationOnKill: Platform.isIOS,
//     );
//     return alarmSettings;
//   }
//
//   void saveAlarm() {
//     if (loading) return;
//     setState(() => loading = true);
//     Alarm.set(alarmSettings: buildAlarmSettings()).then((res) {
//       if (res) Navigator.pop(context, true);
//       setState(() => loading = false);
//     });
//   }
//
//   void deleteAlarm() {
//     Alarm.stop(widget.alarmSettings!.id).then((res) {
//       if (res) Navigator.pop(context, true);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: Text(
//                   'Cancel',
//                   style: Theme.of(context)
//                       .textTheme
//                       .titleLarge!
//                       .copyWith(color: Colors.blueAccent),
//                 ),
//               ),
//               TextButton(
//                 onPressed: saveAlarm,
//                 child: loading
//                     ? const CircularProgressIndicator()
//                     : Text(
//                   'Save',
//                   style: Theme.of(context)
//                       .textTheme
//                       .titleLarge!
//                       .copyWith(color: Colors.blueAccent),
//                 ),
//               ),
//             ],
//           ),
//           Text(
//             getDay(),
//             style: Theme.of(context)
//                 .textTheme
//                 .titleMedium!
//                 .copyWith(color: Colors.blueAccent.withOpacity(0.8)),
//           ),
//           RawMaterialButton(
//             onPressed: pickTime,
//             fillColor: Colors.grey[200],
//             child: Container(
//               margin: const EdgeInsets.all(20),
//               child: Text(
//                 TimeOfDay.fromDateTime(selectedDateTime).format(context),
//                 style: Theme.of(context)
//                     .textTheme
//                     .displayMedium!
//                     .copyWith(color: Colors.blueAccent),
//               ),
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Loop alarm audio',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               Switch(
//                 value: loopAudio,
//                 onChanged: (value) => setState(() => loopAudio = value),
//               ),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Vibrate',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               Switch(
//                 value: vibrate,
//                 onChanged: (value) => setState(() => vibrate = value),
//               ),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Sound',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               DropdownButton(
//                 value: assetAudio,
//                 items: const [
//                   DropdownMenuItem<String>(
//                     value: 'assets/marimba.mp3',
//                     child: Text('Marimba'),
//                   ),
//                   DropdownMenuItem<String>(
//                     value: 'assets/nokia.mp3',
//                     child: Text('Nokia'),
//                   ),
//                   DropdownMenuItem<String>(
//                     value: 'assets/mozart.mp3',
//                     child: Text('Mozart'),
//                   ),
//                   DropdownMenuItem<String>(
//                     value: 'assets/star_wars.mp3',
//                     child: Text('Star Wars'),
//                   ),
//                   DropdownMenuItem<String>(
//                     value: 'assets/one_piece.mp3',
//                     child: Text('One Piece'),
//                   ),
//                 ],
//                 onChanged: (value) => setState(() => assetAudio = value!),
//               ),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Custom volume',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               Switch(
//                 value: volume != null,
//                 onChanged: (value) =>
//                     setState(() => volume = value ? 0.5 : null),
//               ),
//             ],
//           ),
//           SizedBox(
//             height: 30,
//             child: volume != null
//                 ? Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Icon(
//                   volume! > 0.7
//                       ? Icons.volume_up_rounded
//                       : volume! > 0.1
//                       ? Icons.volume_down_rounded
//                       : Icons.volume_mute_rounded,
//                 ),
//                 Expanded(
//                   child: Slider(
//                     value: volume!,
//                     onChanged: (value) {
//                       setState(() => volume = value);
//                     },
//                   ),
//                 ),
//               ],
//             )
//                 : const SizedBox(),
//           ),
//           if (!creating)
//             TextButton(
//               onPressed: deleteAlarm,
//               child: Text(
//                 'Delete Alarm',
//                 style: Theme.of(context)
//                     .textTheme
//                     .titleMedium!
//                     .copyWith(color: Colors.red),
//               ),
//             ),
//           const SizedBox(),
//         ],
//       ),
//     );
//   }
// }
//
//
// class ExampleAlarmRingScreen extends StatelessWidget {
//   const ExampleAlarmRingScreen({required this.alarmSettings, super.key});
//
//   final AlarmSettings alarmSettings;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Text(
//               'You alarm (${alarmSettings.id}) is ringing...',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const Text('🔔', style: TextStyle(fontSize: 50)),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 RawMaterialButton(
//                   onPressed: () {
//                     final now = DateTime.now();
//                     Alarm.set(
//                       alarmSettings: alarmSettings.copyWith(
//                         dateTime: DateTime(
//                           now.year,
//                           now.month,
//                           now.day,
//                           now.hour,
//                           now.minute,
//                         ).add(const Duration(minutes: 1)),
//                       ),
//                     ).then((_) => Navigator.pop(context));
//                   },
//                   child: Text(
//                     'Snooze',
//                     style: Theme.of(context).textTheme.titleLarge,
//                   ),
//                 ),
//                 RawMaterialButton(
//                   onPressed: () {
//                     Alarm.stop(alarmSettings.id)
//                         .then((_) => Navigator.pop(context));
//                   },
//                   child: Text(
//                     'Stop',
//                     style: Theme.of(context).textTheme.titleLarge,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class ExampleAlarmHomeShortcutButton extends StatefulWidget {
//   const ExampleAlarmHomeShortcutButton({
//     required this.refreshAlarms,
//     super.key,
//   });
//
//   final void Function() refreshAlarms;
//
//   @override
//   State<ExampleAlarmHomeShortcutButton> createState() =>
//       _ExampleAlarmHomeShortcutButtonState();
// }
//
// class _ExampleAlarmHomeShortcutButtonState
//     extends State<ExampleAlarmHomeShortcutButton> {
//   bool showMenu = false;
//
//   Future<void> onPressButton(int delayInHours) async {
//     var dateTime = DateTime.now().add(Duration(hours: delayInHours));
//     double? volume;
//
//     if (delayInHours != 0) {
//       dateTime = dateTime.copyWith(second: 0, millisecond: 0);
//       volume = 0.5;
//     }
//
//     setState(() => showMenu = false);
//
//     final alarmSettings = AlarmSettings(
//       id: DateTime.now().millisecondsSinceEpoch % 10000,
//       dateTime: dateTime,
//       assetAudioPath: 'assets/marimba.mp3',
//       volume: volume,
//       notificationTitle: 'Alarm example',
//       notificationBody:
//       'Shortcut button alarm with delay of $delayInHours hours',
//       enableNotificationOnKill: Platform.isIOS,
//     );
//
//     await Alarm.set(alarmSettings: alarmSettings);
//
//     widget.refreshAlarms();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         GestureDetector(
//           onLongPress: () {
//             setState(() => showMenu = true);
//           },
//           child: FloatingActionButton(
//             onPressed: () => onPressButton(0),
//             backgroundColor: Colors.red,
//             heroTag: null,
//             child: const Text('RING NOW', textAlign: TextAlign.center),
//           ),
//         ),
//         if (showMenu)
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextButton(
//                 onPressed: () => onPressButton(24),
//                 child: const Text('+24h'),
//               ),
//               TextButton(
//                 onPressed: () => onPressButton(36),
//                 child: const Text('+36h'),
//               ),
//               TextButton(
//                 onPressed: () => onPressButton(48),
//                 child: const Text('+48h'),
//               ),
//             ],
//           ),
//       ],
//     );
//   }
// }
//
// class ExampleAlarmTile extends StatelessWidget {
//   const ExampleAlarmTile({
//     required this.title,
//     required this.onPressed,
//     super.key,
//     this.onDismissed,
//   });
//
//   final String title;
//   final void Function() onPressed;
//   final void Function()? onDismissed;
//
//   @override
//   Widget build(BuildContext context) {
//     return Dismissible(
//       key: key!,
//       direction: onDismissed != null
//           ? DismissDirection.endToStart
//           : DismissDirection.none,
//       background: Container(
//         color: Colors.red,
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.only(right: 30),
//         child: const Icon(
//           Icons.delete,
//           size: 30,
//           color: Colors.white,
//         ),
//       ),
//       onDismissed: (_) => onDismissed?.call(),
//       child: RawMaterialButton(
//         onPressed: onPressed,
//         child: Container(
//           height: 100,
//           padding: const EdgeInsets.all(35),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const Icon(Icons.keyboard_arrow_right_rounded, size: 35),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
