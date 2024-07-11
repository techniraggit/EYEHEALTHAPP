
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:alarm/alarm.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:platform_device_id_v2/platform_device_id_v2.dart';
import 'package:second_eye/HomePage.dart';
import 'package:second_eye/sign_up.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'FirebaseOptions/FirebaseApi.dart';
import 'api/firebase_options.dart';
import 'dashboard.dart';


final navigatorKey=GlobalKey<NavigatorState>();
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
bool isLoggedIn=false;
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
  await Upgrader.clearSavedSettings(); // REMOVE this for release builds

  // FlutterAlarmBackgroundTrigger.initialize();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // await dotenv.load(fileName: ".env");

 await Alarm.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  await FirebaseApi().getdeviceToken();
  //foreground noti
  FirebaseApi();
  Stripe.publishableKey =
  'pk_test_51OJvAESInaGLb0MUv9RqwK5GqS1LhAWLWPfP2OVRyOzuVPepwaN9L58rWq3ixOUq39RKjkkjf2qUNjl782PntLLX00npNk74Y8';

  Fluttertoast.showToast;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isLoggedIn =  prefs.getBool('isLoggedIn') ?? false;
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  // runApp( PersistenBottomNavBarDemo());

  runApp( MyApp());//MyApp
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return
      MaterialApp(
        builder: EasyLoading.init(),
        home:SplashScreen(),
        navigatorKey: navigatorKey,

          routes: isLoggedIn
              ? {
            '/notification_screen': (context) => SignIn(),
          }
              : {
            '/other_screen': (context) =>Dashboard(),//Dashboard()
          },

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
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) =>Dashboard (),//HomePage(),
            ),
                (Route<dynamic> route) => false,
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SwipeableScreens(),
            ),
          );

          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => SwipeableScreens(),//OnBoardingScreen1(),
          //   ),
          //       (Route<dynamic> route) => false,
          // );
        }
      },
    );

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




class SwipeableScreens extends StatefulWidget {
  @override
  _SwipeableScreensState createState() => _SwipeableScreensState();
}

class _SwipeableScreensState extends State<SwipeableScreens> with AutomaticKeepAliveClientMixin {

  PageController _pageController = PageController(initialPage: 0);

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure super.build is called first
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          OnBoardingScreen1(),
          OnBoardingScreen2(),
          OnBoardingScreen3(),
        ],
      ),
    );
  }
}
















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
      if(Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        print('Running on ${androidInfo.id}'); // e.g. "Moto G (4)"
      }
      if(Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        print('Running on ${iosInfo.identifierForVendor}');
      }// e.g. "iPod7,1"

// WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
// print('Running on ${webBrowserInfo.userAgent}');  // e.g. "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:61.0) Gecko/20100101 Firefox/61.0"
    });
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body:

        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // To position the Row at the vertical end
            children: [
              const SizedBox(height: 40,),
              Image.asset(
                'assets/onboardingperson1.png', // Replace this with your image path
                width:MediaQuery.of(context).size.width,
                height:MediaQuery.of(context).size.width,

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
                    'Welcome to Second Eye Your Personal Eye Health Companion',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 5),
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  children: <Widget>[

                    Container(
                      // margin: EdgeInsets.only(top: 8.0),  // Adjust the vertical alignment of the bullet point
                      width: 6,  // Diameter of the bullet point
                      height: 6,  // Diameter of the bullet point
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,  // Color of the bullet point
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Digital eye test and prescription generation',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),


          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 5),
            child: Align(
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  Container(
                    // margin: EdgeInsets.only(top: 8.0),  // Adjust the vertical alignment of the bullet point
                    width: 6,  // Diameter of the bullet point
                    height: 6,  // Diameter of the bullet point
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,  // Color of the bullet point
                    ),
                  ),
                  SizedBox(width: 8),  // Adjust the space between the dotted circle and the text as needed
                  Text(
                    'Eye fatigue assessment and prevention tips',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 10,),


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
              SizedBox(height: 10,),
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

                  child: Container(
                    margin:  EdgeInsets.symmetric(vertical: 10,horizontal: 50),

                    // height:17 ,width: 31,
                    child: Text(
                      'Skip',
                      style: TextStyle(fontSize: 14, color: Color(0xFF4600A9),fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,),

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
            const SizedBox(height: 25,),
            Image.asset(
              'assets/onboardperson2.png', // Replace this with your image path
              height:MediaQuery.of(context).size.width/1.5,
              // height: 300,
            ),
            SvgPicture.asset(
              'assets/unevenline.svg', // Replace this with your image path
              // width:MediaQuery.of(context).size.width,
            ),
             SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Align(
               alignment: Alignment.topLeft,

                child: Text(

                  'Earn Exciting Rewards',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Container(
                //   // margin: EdgeInsets.only(top: 8.0),  // Adjust the vertical alignment of the bullet point
                //   width: 6,  // Diameter of the bullet point
                //   height: 6,  // Diameter of the bullet point
                //   decoration: BoxDecoration(
                //     shape: BoxShape.circle,
                //     color: Colors.black,  // Color of the bullet point
                //   ),
                // ),
                SizedBox(width: 8),  // Adjust the space between the bullet point and the text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Complete Eye Tests:',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,  // Bold weight for the heading
                        ),
                      ),
                      SizedBox(height: 8),  // Adjust the space between the heading and the bullet points
                      Text(
                        'Get points and boost your rewards with regular tests.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,  // Normal weight for the bullet points
                        ),
                      ),
                      SizedBox(height: 3,),
                    ],
                  ),
                ),
              ],
            ),
          ),
            SizedBox(height: 12,),

            Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0,vertical: 5 ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Container(
                //   margin: EdgeInsets.only(top: 4.0),  // Adjust the vertical alignment of the bullet point
                //   width: 6,  // Diameter of the bullet point
                //   height: 6,  // Diameter of the bullet point
                //   decoration: BoxDecoration(
                //     shape: BoxShape.circle,
                //     color: Colors.black,  // Color of the bullet point
                //   ),
                // ),
                SizedBox(width: 8),  // Adjust the space between the bullet point and the text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Refer Friends:',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,  // Bold weight for the heading
                        ),
                      ),
                      SizedBox(height: 8),  // Adjust the space between the heading and the bullet points
                      Text(
                        'Earn bonus points for each friend who joins with your code.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,  // Normal weight for the bullet points
                        ),
                      ),
                      SizedBox(height: 3,),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0, ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Container(
                //   // margin: EdgeInsets.only(top: 8.0),  // Adjust the vertical alignment of the bullet point
                //   width: 6,  // Diameter of the bullet point
                //   height: 6,  // Diameter of the bullet point
                //   decoration: BoxDecoration(
                //     shape: BoxShape.circle,
                //     color: Colors.black,  // Color of the bullet point
                //   ),
                // ),
                SizedBox(width: 8),  // Adjust the space between the bullet point and the text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Redeem Rewards:',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,  // Bold weight for the heading
                        ),
                      ),
                      SizedBox(height: 8),  // Adjust the space between the heading and the bullet points
                      Text(
                        'Use points for discounts on eyewear and more!',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,  // Normal weight for the bullet points
                        ),
                      ),
                      SizedBox(height: 3,),
                    ],
                  ),
                ),
              ],
            ),
          ),




            const SizedBox(height: 18,),

            Padding(
              padding: const EdgeInsets.fromLTRB(25,9,25,2),
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
            // const SizedBox(height: 4,),
            //
            // SvgPicture.asset(
            //   'assets/lines.svg', // Replace this with your image path
            //   // width:MediaQuery.of(context).size.width,
            // ),
            // const SizedBox(width: 4,),

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
                child:  Container(
                  margin:  EdgeInsets.symmetric(vertical: 10,horizontal: 50),

                  // height:17 ,width: 31,
                  child: Text(
                    'Skip',
                    style: TextStyle(fontSize: 14, color: Color(0xFF4600A9),fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ),
SizedBox(height: 20,),
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
            const SizedBox(height: 7,),
            Image.asset(
              'assets/onboardingperson3.png',
              // height: 189,// Replace this with your image path
              height:MediaQuery.of(context).size.width/1.5,
            ),
            // Image.asset(
            //   'assets/unevenline.png', // Replace this with your image path
            //   // width:MediaQuery.of(context).size.width,
            // ),
            const SizedBox(height: 12,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Take a Quick Eye Test & Check Fatigue:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0, ),
            child: Align(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Simple & Fast:',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,  // Bold weight for the heading
                    ),
                  ),
                  SizedBox(height: 8),  // Adjust the space between the heading and the bullet points
                  Text(
                    'Find a quiet spot, position your device, and follow the on-screen instructions .\n'
                    ,style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,  // Normal weight for the bullet points
                    ),
                  ),
                ],
              ),
            ),
          ),
            SizedBox(height: 8,),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0,),
            child: Align(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Detailed Results:',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,  // Bold weight for the heading
                    ),
                  ),
                  SizedBox(height: 8),  // Adjust the space between the heading and the bullet points
                  Text(
                    'Get a report with a prescription suggestion and eye fatigue assessment.\n',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,  // Normal weight for the bullet points
                    ),
                  ),
                ],
              ),
            ),
          ),

        SizedBox(height: 8,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0,),
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Personalized Tips:',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,  // Bold weight for the heading
                      ),
                    ),
                    SizedBox(height: 8),  // Adjust the space between the heading and the bullet points
                    Text(
                      'Receive recommendations to keep your eyes feeling fresh.\n',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,  // Normal weight for the bullet points
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 18,),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0,),
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
              padding: const EdgeInsets.only(top: 45.0,bottom: 10),
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




























