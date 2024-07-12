
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:action_broadcast/action_broadcast.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart' hide AxisTitle;
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:second_eye/alarm/SharedPref.dart';
import 'package:second_eye/alarm/demo_main.dart';
// import 'package:second_eye/alarm/demo_main.dart';

import 'package:second_eye/digitalEyeTest/testScreen.dart';
import 'package:second_eye/eyeFatigueTest/EyeFatigueSelfieScreen.dart';
import 'package:second_eye/sign_up.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'Custom_navbar/bottom_navbar.dart';
import 'Rewards/rewards.dart';
import 'Rewards/rewards_sync.dart';
import 'api/Api.dart';
import 'api/config.dart';
import 'models/fatigueGraphModel.dart';
import 'notification/notification_dashboard.dart';

class EyeHealthData {
  final String date;
  final double value;
  final bool isFatigueRight;
  final bool isMildTirednessRight;
  final bool isFatigueLeft;
  final bool isMildTirednessLeft;

  EyeHealthData({
    required this.date,
    required this.value,
    required this.isFatigueRight,
    required this.isMildTirednessRight,
    required this.isFatigueLeft,
    required this.isMildTirednessLeft,
  });

  factory EyeHealthData.fromJson(Map<String, dynamic> json) {
    return EyeHealthData(
      date: json['date'],
      value: json['value'].toDouble(),
      isFatigueRight: json['is_fatigue_right'],
      isMildTirednessRight: json['is_mild_tiredness_right'],
      isFatigueLeft: json['is_fatigue_left'],
      isMildTirednessLeft: json['is_mild_tiredness_left'],
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with AutoCancelStreamMixin {
  @override
  Iterable<StreamSubscription> get registerSubscriptions sync* {
    yield registerReceiver(['actionMusicPlaying']).listen(
          (intent) {
        switch (intent.action) {
          case 'actionMusicPlaying':
            setState(() {
              getNotifactionCount();
            });
            break;
        }
      },
    );
  }

  List<double>? _data;
  List<String>? dates;
  int i = 0;
  bool edited = false;
  List<dynamic>  carousalData=[];

  // List<Feature>? features;
  List<String>? labelX;
  int count = 0;
  List<String>? labelY;
  List<double> todaygraphData = [];
  List<double> firstTestgraphData = [];
  List<double> idealTestgraphData = [];
  List<dynamic> populationTestgraphData = [];

  String _status = '';
  List<FlSpot> _value = [];
  List<_ChartData>? chartData;
  List<_ChartData2>? chartData2;
  double first_day_data = 0.0;
  double current_day_data = 0.0;
  double get_percentile_graph = 0.0;
  double get_ideal_graph = 0.0;

  List<FlSpot> _spots = [FlSpot(0, 0)]; // Initialize _spots as needed
  bool fatigue_left = false;
  bool fatigue_right = false;
  bool midtiredness_right = false;
  bool midtiredness_left = false;
  bool isSelected = false;
  fatigueGraph? fatigueGraphData;
  bool isLeftEyeSelected = false;

  int currentHour = DateTime.now().hour;
  late DateTime selectedDate;
  String no_of_eye_test = "0";
  dynamic eye_health_score = "";
  String fullname = "";
  String no_of_fatigue_test = "0";
  dynamic selectedPlanId = '';
  bool isActivePlan = false;
  bool isLoading1 = true;
  int? isReadFalseCount = 0;
  Timer? _timer;bool isCrosalLoading=true;

  // Define selectedDate within the _CalendarButtonState class
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey();



  void _startTimer() {
    const tenSeconds = Duration(seconds: 10);
    _timer = Timer.periodic(tenSeconds, (timer) {
      // Make your API call here
      getNotifactionCount();
    });
  }

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }

  Future<void> cancelTimer() async {
    if (_timer != null) {
      _timer!.cancel();
    }
  }


  @override
  void initState() {
    super.initState();
    // getGraph();
    getCarouselData();
    getGraph();
    _startTimer();


    Future.delayed(const Duration(seconds: 1), () {})
        .then((_) => getNotifactionCount())
        .then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> getNotifactionCount() async {
    try {
      String userToken = '';
      var sharedPref = await SharedPreferences.getInstance();
      userToken = sharedPref.getString("access_token") ?? '';
      String url = "${ApiProvider.baseUrl}/api/user_notification";
      print("URL: $url");
      print("userToken: $userToken");
      if(userToken.isNotEmpty){

        Map<String, String> headers = {
        'Authorization': 'Bearer $userToken', // Bearer token type
        'Content-Type': 'application/json',
      };
      var response = await Dio().get(url, options: Options(headers: headers));
      print('drf gfbt Count: $response');

      if (response.statusCode == 200) {
        final responseData = response.data;
        // Map<String, dynamic> responseData = json.decode(response.data);
        int unreadNotificationCount = responseData['is_read_false_count'];
        isReadFalseCount = unreadNotificationCount;
        print('Unread Notification Count: $unreadNotificationCount');
        print('Unread gfbt Count: $response');
        if (mounted) {
          setState(() {});
        }
      } else if (response.statusCode == 401) {
        Fluttertoast.showToast(msg: "Session Expired");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      } else {
        throw Exception('Failed to load data');
      }
    } }
    on DioError catch (e) {
      if (e.response != null || e.response!.statusCode == 401) {
        // Handle 401 error

        Fluttertoast.showToast(msg: "Session Expired");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      }
      else {
        // Handle other Dio errors
        print("DioError: ${e.error}");
      }
    }




    catch (e) {
      // Handle other exceptions
      print("Exception---: $e");
    }
  }




  @override
  Widget build(BuildContext context) {
    int currentHour = DateTime.now().hour;
    // Determine the appropriate salutation based on the current hour
    String salutation = 'Welcome';

    return Scaffold(
      key: _scafoldKey,
      endDrawer: NotificationSideBar(
        onNotificationUpdate: () {
          setState(() {
            if (isReadFalseCount != null) {
              if (isReadFalseCount! > 0) {
                isReadFalseCount = isReadFalseCount! - 1;
              }
            }
          });
        },
      ),
      endDrawerEnableOpenDragGesture: false,
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.all(8.0), // Add padding
      //   child: ClipOval(
      //     child: Material(
      //       color: Colors.white70.withOpacity(0.9), // Background color
      //       elevation: 4.0, // Shadow
      //       child: InkWell(
      //         onTap: () {
      //           Navigator.push(
      //             context,
      //             CupertinoPageRoute(
      //               builder: (context) => HomePage(),
      //             ),
      //           );
      //         },
      //         child: SizedBox(
      //           width: 53.0, // Width of the FloatingActionButton
      //           height: 50.0, // Height of the FloatingActionButton
      //           child: Center(
      //             child: Padding(
      //               padding:
      //                   const EdgeInsets.all(8.0), // Add padding for the icon
      //               child: Image.asset(
      //                 "assets/home_icon.jpg",
      //                 width: 27,
      //                 // fit: BoxFit.cover, // Uncomment if you want the image to cover the button
      //                 // color: Colors.grey, // Uncomment if you want to apply a color to the image
      //               ),
      //             ),
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(145),
        child: Stack(
          children: [
            Image.asset(
              'assets/pageBackground.png',
              fit: BoxFit.fill,
              width: double.infinity,
              height: 260,
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 10.0, 0, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            salutation,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      Text(
                        fullname,
                        style: const TextStyle(
                            color: Colors.lightBlueAccent,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Your Eye Health Score',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                          ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return const RadialGradient(
                                radius: 1.0,
                                colors: [
                                  Color(0xFFFFF400),
                                  Color(0xFFFFE800),
                                  Color(0xFFFFCA00),
                                  Color(0xFFFF9A00),
                                  Color(0xFFFF9800),
                                ],
                              ).createShader(bounds);
                            },
                            child: Text(
                              eye_health_score.toString(),
                              style: const TextStyle(
                                  fontSize: 31,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 16,
              child: GestureDetector(
                onTap: () {
                  _scafoldKey.currentState!.openEndDrawer();
                },
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffF9F9FA),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      height: 40,
                      width: 40,
                      child: Center(
                        child: Icon(
                          Icons.notifications_none,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top:
                          -1, // Adjust this value to position the text properly
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Text(
                          '${isReadFalseCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
SizedBox(height: 10,),
            isCrosalLoading
                ? Center(
              // Show loader when isLoading is true
              child: CircularProgressIndicator(),
            )
                :  CarouselSlider(
              items: carousalData.map((item) {
                return Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () {
                        // Navigate based on image name
                        switch (item['name']) {
                          case 'Prescription':
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (context) => PrescriptionUpload(),
                              ),
                            );
                            break;
                          case 'Refer and Earn':
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (context) => RewardContact(),
                              ),
                            );
                            break;
                          case 'Reward':
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (context) => RewardsScreen(),
                              ),
                            );
                            break;
                          case 'Eye Test':
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => BottomDialog(),
                            );
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute<void>(
                            //     builder: (context) => BottomDialog(),
                            //   ),
                            // );
                            break;
                          case 'Eye Fatigue Test':
                            if (context.mounted) {
                              pushNewScreenWithRouteSettings(
                                context,
                                settings: const RouteSettings(name: 'music_player_page'),
                                screen: EyeFatigueSelfieScreen(),
                                withNavBar: false,
                                pageTransitionAnimation: PageTransitionAnimation.cupertino,
                              );
                            }
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute<void>(
                            //     builder: (context) => EyeFatigueSelfieScreen(),
                            //   ),
                            // );
                            break;
                          default:
                            break;
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: NetworkImage(item['image']),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height / 4, // Adjust height as needed
                enlargeCenterPage: true,
                autoPlay: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: Duration(milliseconds: 370),
                viewportFraction: 0.8,
              ),
            ),
                     Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
              child: GestureDetector(
                onTap: () {
                  // checkActivePlan('eyeTest');
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => BottomDialog(),
                  );
                },
                child: Image.asset(
                  'assets/digital_eye_exam.png',
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
              child: GestureDetector(
                onTap: () {
                  requestPermission();
                  // checkActivePlan('fatigue');
                },
                child: Image.asset('assets/eyeFatigueTest.png'),
              ),
            ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 10, 0, 10),
                  child: Text(
                    'EYE HEALTH OVERVIEW', // Display formatted current date
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => BottomAlarmDialog(),
                      );
                       // Navigator.push(
                       //    context,
                       //    MaterialPageRoute<void>(
                       //      builder: (context) => const ExampleAlarmHomeScreen(),
                       //    ),
                       //  );
                    },
                    child: Icon(
                      Icons.alarm,
                      // Replace with the alarm icon from Icons class
                      size: 33, // Adjust the size of the icon as needed
                      color:
                          Colors.blue, // Adjust the color of the icon as needed
                    ),
                  ),
                ),
              ],
            ),

            Container(
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1),
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // if (chartData != null) ...{
                      Center(
                        child: Card(
                          color: Colors.white,
                          elevation: 0.5,
                          child:
                              //     : isLoading1
                              //     ?
                              // const Center(
                              //   child: CircularProgressIndicator(
                              //     color: Colors.blue,
                              //   ),
                              // )
                              //     :

                              Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                DotWithLabel(
                                    index: 0,
                                    label: 'Ideal Score',
                                    point: get_ideal_graph.toDouble()),
                                Divider(
                                  height: 5,
                                  thickness: 0.5,
                                  color: Colors.grey[400],
                                  indent: 20,
                                  endIndent: 20,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                DotWithLabel(
                                  index: 1,
                                  label: 'Percentile Score of the population',
                                  point: get_percentile_graph.toDouble(),
                                ),
                                Divider(
                                  height: 5,
                                  thickness: 0.5,
                                  color: Colors.grey[400],
                                  indent: 20,
                                  endIndent: 20,
                                ),
                                SizedBox(
                                  height: 5,
                                ),

                                DotWithLabel(
                                  index: 2,
                                  label: 'Your Avg. Score',
                                  point: current_day_data.toDouble(),
                                ),
                                Divider(
                                  height: 5,
                                  thickness: 0.5,
                                  color: Colors.grey[400],
                                  indent: 20,
                                  endIndent: 20,
                                ),
                                SizedBox(
                                  height: 7,
                                ),

                                DotWithLabel(
                                  index: 3,
                                  label: 'Your First Score',
                                  point: first_day_data.toDouble(),
                                ), //color: Colors.black,
                              ],
                            ),
                          ),
                          // _buildVerticalSplineChart(),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 1),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.background,
                                  // Adjust color as needed
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Score 10 indicates - You have Perfect Eyes',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors
                                      .background, // Adjust text color as needed
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 1),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  // Adjust color as needed
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Score 3 indicates - Your eyes need Urgent attention',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors
                                      .redAccent, // Adjust text color as needed
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // const SizedBox(
                      //     height:
                      //     10), // Adjust spacing between chart and color descriptions

                      // Color descriptions
                      // Center(
                      //   child: SingleChildScrollView(
                      //     scrollDirection: Axis.horizontal,
                      //     child: Row(
                      //       children: [
                      //         const SizedBox(width: 9),
                      //         _buildColorDescription(
                      //             Colors.green, 'Ideal Score'),
                      //         const SizedBox(width: 9),
                      //         _buildColorDescription(
                      //             Colors.blue, 'User Average Score'),
                      //         const SizedBox(width: 9),
                      //       ],
                      //     ),
                      //   ),
                      // )
                      // },
                      if (count == 0 && isLoading1 == false) ...{
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16.0, 10, 0, 0),
                          child: Text(
                            'Get your first test done now and start tracking your eye health.',
                            // Display formatted current date
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 9),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                requestPermission();
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) =>
                                //           EyeFatigueSelfieScreen()),
                                // );
                              },
                              child: const Text('Start Test Now'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(200, 45),
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.bluebutton,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ),
                        ),
                      },
                      const SizedBox(height: 7),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 10, 0, 0),
              child: Text(
                'You’ve Tested so far ', // Display formatted current date
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    color: Colors.black87),
              ),
            ),
            SizedBox(
              height: 6,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              child: SizedBox(
                height: 180, // Adjust height as needed
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/interview.png'),
                            fit: BoxFit
                                .fill, // Ensure the image covers the entire container
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 15),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 22.0), // Adjusted padding
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    no_of_eye_test ?? "0",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 5), // Added SizedBox for spacing
                                  const Text(
                                    'Eye Test',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/eye_bg.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,

                          children: [
                            // Number (left top)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20.0, top: 12.0),
                              child: Text(
                                no_of_fatigue_test ?? "0",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Text (below number)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20.0, top: 10.0),
                              child: Text(
                                'Eye Fatigue Test',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
            // const SizedBox(height: 15),
            SizedBox(height: 80,),
          ],
        ),
      ),
      // bottomNavigationBar: CustomBottomAppBar(
      //   currentScreen: 'HomePage',
      // ),
    );
  }

  Widget _buildColorDescription(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 15,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(
                25), // Adjust the radius to make it rounded
          ),
          margin: const EdgeInsets.only(right: 4),
        ),
        Text(text),
      ],
    );
  }

  void requestPermission() async {
    PermissionStatus status = await Permission.camera.status;
    PermissionStatus status2 = await Permission.microphone.status;

    if ((status == PermissionStatus.granted &&
        status2 == PermissionStatus.granted)) {
      setState(() {

        pushNewScreenWithRouteSettings(
          context,
          settings: const RouteSettings(name: 'music_player_page'),
          screen: EyeFatigueSelfieScreen(),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );


        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => EyeFatigueSelfieScreen()),
        // );
      });
    }
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    if (!status2.isGranted) {
      status = await Permission.microphone.request();
    }
    if (status == PermissionStatus.denied ||
        status == PermissionStatus.permanentlyDenied) {
      await [Permission.camera].request();

      // Permissions are denied or denied forever, let's request it!
      status = await Permission.camera.status;
      if (status == PermissionStatus.denied) {
        await [Permission.camera].request();
        print("camera permissions are still denied");
      } else if (status == PermissionStatus.permanentlyDenied) {
        print("camera permissions are permanently denied");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("camera permissions required"),
              content: Text(
                  "camera permissions are permanently denied. Please go to app settings to enable camera permissions."),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .background, // Set your desired background color here
                    // You can also customize other button properties here if needed
                  ),
                  onPressed: () async {
                    Navigator.pop(context); // Close the dialog
                    await openAppSettings();
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            );
          },
        );
      }
    }

    if (status2 == PermissionStatus.denied ||
        status2 == PermissionStatus.permanentlyDenied) {
      await [Permission.microphone].request();

      // Permissions are denied or denied forever, let's request it!
      status2 = await Permission.microphone.status;
      if (status2 == PermissionStatus.denied) {
        await [Permission.microphone].request();
        print("microphone permissions are still denied");
      }
      if (status2 == PermissionStatus.permanentlyDenied) {
        print("microphone permissions are permanently denied");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("microphone permissions required"),
              content: Text(
                  "microphone permissions are permanently denied. Please go to app settings to enable microphone permissions."),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .background, // Set your desired background color here
                    // You can also customize other button properties here if needed
                  ),
                  onPressed: () async {
                    Navigator.pop(context); // Close the dialog
                    await openAppSettings();
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void checkActivePlan(String testType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('access_token') ?? '';

    try {
      final response = await http.get(
        Uri.parse('${ApiProvider.baseUrl + ApiProvider.isActivePlan}'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // _progressDialog!.hide();

        final jsonResponse = jsonDecode(response.body);

        // Access the value of is_verified
        isActivePlan = jsonResponse['is_active_plan'];
        selectedPlanId = jsonResponse['plan_id'];

        setState(() {
          if (isActivePlan == false) {
            Fluttertoast.showToast(
              msg: "Before Start the Test Please Purchase the Plan",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.bluebutton,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          } else {
            if (testType == 'fatigue') {
              requestPermission();
            } else {
              showModalBottomSheet(
                context: context,
                builder: (context) => BottomDialog(),
              );
            }
          }
        });

        print("responseviewprofile999:${response.body}");

        return json.decode(response.body);
      } else {
        // _progressDialog!.hide();

        print(response.body);
      }
    } catch (e) {
      // _progressDialog!.hide();

      print("exception:$e");
    }
    throw Exception('');
  }
  Future<void> getCarouselData() async {
    // try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken = prefs.getString('access_token') ?? '';
      final response = await http.get(
        Uri.parse('${ApiProvider.baseUrl}/api/dashboard-count'),
        headers: <String, String>{
          'Authorization': 'Bearer $authToken',
        },
      );
      print("response=======data===${response.body}");
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        carousalData = responseData['carousel'];
        isCrosalLoading=false;
      } else if (response.statusCode == 401) {
        Fluttertoast.showToast(msg: "Session Expired");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      } else {
        print(response.body);
      }
    // } catch (e) {
    //   // _progressDialog!.hide();
    //
    //   print("exception---:$e");
    // }
    // throw Exception(Exception);
  }
  Future<void> sendcustomerDetails(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken =
        // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
        prefs.getString('access_token') ?? '';
    final String apiUrl = '${Api.baseurl}/api/eye/add-customer';
// Replace these headers with your required headers
    Map<String, String> headers = {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json',
    };

    var body = json.encode({
      "is_self": true,
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );
      print('response === ' + response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context);

        if (kDebugMode) {
          print('sddd ${response.body}');
        }
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      } else {
        print('Failed with status code: ${response.statusCode}');
        print('Failed sddd ${response.body}');
      }
    } catch (e) {
// Handle exceptions here (e.g., network errors)
      print('Exception: $e');
    }
  }

  Future<void> getGraph() async {
    //List<double>
    // try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('access_token') ?? '';
    final response = await http.get(
      Uri.parse(
          '${ApiProvider.baseUrl}/api/fatigue/fatigue-graph?user_timezone=Asia/Kolkata'),
      headers: <String, String>{
        'Authorization': 'Bearer $authToken',
      },
    );
    print("response=======data===${response.body}");
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        first_day_data = responseData['first_day_data'].toDouble();
        current_day_data = responseData['current_day_data'].toDouble();
        get_percentile_graph = responseData['get_percentile_graph'].toDouble();
        get_ideal_graph = responseData['get_ideal_graph'].toDouble();
        no_of_fatigue_test = responseData['no_of_fatigue_test'].toString();
        no_of_eye_test = responseData['no_of_eye_test'].toString();
        fullname = responseData['name'];
        eye_health_score = responseData['eye_health_score'];
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', fullname);

      count = responseData['no_of_fatigue_test'];
      isLoading1 = false;

    } else if (response.statusCode == 401) {
      Fluttertoast.showToast(msg: "Session Expired");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignIn()),
      );
    } else {
      print(response.body);
    }
    // } catch (e) {
    //   // _progressDialog!.hide();
    //
    //   print("exception---:$e");
    // }
    // throw Exception(Exception);
  }
}

class DotWithLabel extends StatelessWidget {
  // final Color color;
  final int index;

  final String label;
  final double point;

  const DotWithLabel({
    Key? key,
    // required this.color,
    required this.index,
    required this.label,
    required this.point,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      // Ensure the container spans the full width of the screen
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Builder(builder: (context) {
        Color textColor = _getTextColor(index);

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Container(
            //   width: 14.0,
            //   height: 15.0,
            //   decoration: BoxDecoration(
            //     shape: BoxShape.circle,
            //     color: color,
            //   ),
            // ),
            //
            // SizedBox(width: MediaQuery.of(context).size.width/4), // Adjust spacing as needed
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 20),
            // Adjust spacing as needed
            Text(
              '$point',
              style: TextStyle(
                fontSize: 18,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      }),
    );
  }

  Color _getTextColor(int index) {
    // Define your logic to determine text color based on point value
    if (index == 0) {
      return Colors.green; // Example condition for green color
    } else if (index == 1) {
      return Colors.orange; // Example condition for orange color
    } else if (index == 2) {
      return Colors.blue; // Example condition for orange color
    } else {
      return Colors.background; // Example condition for red color
    }
  }
}

class _ChartData {
  _ChartData(this.x, this.y, this.y2, this.y3, this.y4);

  final String x;
  final double y;
  final double y2;
  final double y3;
  final double y4;
}

class _ChartData2 {
  _ChartData2(this.x, this.y, this.y2);

  final String x;
  final double y;
  final double y2;
}

class setReminder extends StatefulWidget {
  @override
  State<setReminder> createState() => ReminderState();
}

class ReminderState extends State<setReminder> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(
        // appBar: AppBar(
        //   title: const Text(''),
        // ),
        body: Builder(builder: (context) {
      return const Center();
    })));
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BottomDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Digital Eye Exam',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Divider(thickness: 1, color: Colors.grey.shade500),
          const SizedBox(height: 18),
          Card(
            child: GestureDetector(
              onTap: () {
                sendcustomerDetails(context, true);
              },
              child: Image.asset('assets/test_for_myself_img.png'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Card(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => OtherDetailsBottomSheet(),
                  );
                },
                child: Image.asset('assets/test_for_someone_img.png'),
              ),
            ),
          ),
          SizedBox(height: 80,)
        ],
      ),
    );
  }

  Future<void> sendcustomerDetails(BuildContext context, bool isSelf,
      {String? name, String? age}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('access_token') ?? '';
    final String apiUrl = '${Api.baseurl}/api/eye/add-customer';

    Map<String, String> headers = {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json',
    };

    var body = json.encode({
      'is_self': isSelf,
      if (!isSelf) 'name': name,
      if (!isSelf) 'age': age,
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      print('API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        Navigator.pop(context);
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('customer_id')) {
          String customerId = jsonResponse['customer_id'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('customer_id', customerId);

          print('Customer ID: $customerId');

          // Check if the context is still mounted before navigating
          if (context.mounted) {
            pushNewScreenWithRouteSettings(
              context,
              settings: const RouteSettings(name: 'music_player_page'),
              screen: GiveInfo(),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => GiveInfo()),
            // );
          }
        } else {
          print('Customer ID not found in response.');
        }
      } else {
        print('API call failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }
}







class BottomAlarmDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Set Alarms',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Divider(thickness: 1, color: Colors.grey.shade500),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => ExampledefaultAlarmHomeScreen(),
                ),
              );
              // showModalBottomSheet(
              //   context: context,
              //   builder: (context) => ExampleAlarmHomeScreen(),
              // );
            },

            child: Card(
              elevation: 2,
              child: Container(
                height: 70,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => ExampledefaultAlarmHomeScreen(),
                      ),
                    );
                    // showModalBottomSheet(
                    //   context: context,
                    //   builder: (context) => ExampleAlarmHomeScreen(),
                    // );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Schedule default system alarms',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.background),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_forward_ios,color: Colors.background,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => ExampleAlarmHomeScreen(),
                ),
              );

            },

            child: Card(
              elevation: 2,
              child: Container(
                height: 70,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => ExampleAlarmHomeScreen(),
                      ),
                    );

                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Add your own alarms',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.background),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_forward_ios,color: Colors.background,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 80,
          ),
        ],
      ),
    );
  }

  Future<void> sendcustomerDetails(BuildContext context, bool isSelf,
      {String? name, String? age}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('access_token') ?? '';
    final String apiUrl = '${Api.baseurl}/api/eye/add-customer';

    Map<String, String> headers = {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json',
    };

    var body = json.encode({
      'is_self': isSelf,
      if (!isSelf) 'name': name,
      if (!isSelf) 'age': age,
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      print('API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        Navigator.pop(context);

        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('customer_id')) {
          String customerId = jsonResponse['customer_id'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('customer_id', customerId);

          print('Customer ID: $customerId');

          // Check if the context is still mounted before navigating
          if (context.mounted) {
              pushNewScreenWithRouteSettings(
                context,
                settings: const RouteSettings(name: 'music_player_page'),
                screen: GiveInfo(),
                withNavBar: false,
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
          }
        } else {
          print('Customer ID not found in response.');
        }
      } else {
        print('API call failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }
}

class OtherDetailsBottomSheet extends StatefulWidget {
  @override
  _OtherDetailsBottomSheetState createState() =>
      _OtherDetailsBottomSheetState();
}

class _OtherDetailsBottomSheetState extends State<OtherDetailsBottomSheet> {
  Future<void> sendcustomerDetails(BuildContext context, bool isSelf,
      {String? name, String? age}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('access_token') ?? '';
    final String apiUrl = '${Api.baseurl}/api/eye/add-customer';

    Map<String, String> headers = {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json',
    };

    var body = json.encode({
      'is_self': isSelf,
      if (!isSelf) 'name': name,
      if (!isSelf) 'age': age,
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      print('API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        Navigator.pop(context);
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('customer_id')) {
          String customerId = jsonResponse['customer_id'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('customer_id', customerId);

          print('Customer ID: $customerId');
          // PersistentNavBarNavigator.pushNewScreen(
          //   context,
          //   screen:  GiveInfo(),
          //   withNavBar: false,
          // );
          if (context.mounted) {
            pushNewScreenWithRouteSettings(
              context,
              settings: const RouteSettings(name: 'music_player_page'),
              screen: GiveInfo(),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );}
        } else {
          print('Customer ID not found in response.');
        }
      } else {
        print('API call failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Adjusts layout when keyboard appears

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: const ScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Test For Someone Else',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(thickness: 1.5, color: Colors.grey.shade400),
                const SizedBox(height: 20),
                SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 1),
                    child: TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w100,
                        ),
                        hintText: 'Enter Full Name',
                        hintStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              27.0), // Add circular border
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(30),
                      ],
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w400),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a full name';
                        }
                        final nameRegExp = RegExp(r'^[a-zA-Z\s]+$');
                        if (!nameRegExp.hasMatch(value)) {
                          return 'Name must contain only alphabets';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 1),
                    child: TextFormField(
                      controller: _ageController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Age',
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                        hintText: 'Age',
                        hintStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              27.0), // Add circular border
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w400),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an age';
                        }
                        int? age = int.tryParse(value);
                        if (age == null || age < 10 || age > 70) {
                          return 'Age must be between 10 and 70';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        sendcustomerDetails(context, false,
                            name: _nameController.text,
                            age: _ageController.text);
                      }
                    },
                    child: const Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(350, 50),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.bluebutton,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class ExampleAlarmRingScreen extends StatelessWidget {
  const ExampleAlarmRingScreen({required this.alarmSettings, super.key});

  final AlarmSettings alarmSettings;
//TODO Data Change Alarm Design
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Its a reminder , please do eye test',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text('🔔', style: TextStyle(fontSize: 50)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              RawMaterialButton(
                onPressed: () {
                  final now = DateTime.now();
                  Alarm.set(
                    alarmSettings: alarmSettings.copyWith(
                      dateTime: DateTime(
                        now.year,
                        now.month,
                        now.day,
                        now.hour,
                        now.minute,
                      ).add(const Duration(minutes: 1)),
                    ),
                  ).then((_) => Navigator.pop(context));
                },
                child: Text(
                  'Snooze',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              RawMaterialButton(
                onPressed: () {
                  Alarm.stop(alarmSettings.id)
                      .then((_) => Navigator.pop(context));
                },
                child: Text(
                  'Stop',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

