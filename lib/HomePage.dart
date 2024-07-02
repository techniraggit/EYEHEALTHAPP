// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:action_broadcast/action_broadcast.dart';
// import 'package:alarm/alarm.dart';
// import 'package:alarm/model/alarm_settings.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
//
// import 'package:fl_chart/fl_chart.dart' hide AxisTitle;
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
// import 'package:project_new/Rewards/rewards_sync.dart';
// import 'package:project_new/alarm/demo_main.dart';
//
// import 'package:project_new/digitalEyeTest/testScreen.dart';
// import 'package:project_new/eyeFatigueTest/EyeFatigueSelfieScreen.dart';
// import 'package:project_new/eyeFatigueTest/ReportPage.dart';
// import 'package:project_new/eyeHealthTrack.dart';
// import 'package:project_new/sign_up.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
//
// import 'Custom_navbar/bottom_navbar.dart';
// import 'alarm/SharedPref.dart';
// import 'api/Api.dart';
// import 'api/config.dart';
// import 'models/fatigueGraphModel.dart';
// import 'notification/notification_dashboard.dart';
//
// class EyeHealthData {
//   final String date;
//   final double value;
//   final bool isFatigueRight;
//   final bool isMildTirednessRight;
//   final bool isFatigueLeft;
//   final bool isMildTirednessLeft;
//
//   EyeHealthData({
//     required this.date,
//     required this.value,
//     required this.isFatigueRight,
//     required this.isMildTirednessRight,
//     required this.isFatigueLeft,
//     required this.isMildTirednessLeft,
//   });
//
//   factory EyeHealthData.fromJson(Map<String, dynamic> json) {
//     return EyeHealthData(
//       date: json['date'],
//       value: json['value'].toDouble(),
//       isFatigueRight: json['is_fatigue_right'],
//       isMildTirednessRight: json['is_mild_tiredness_right'],
//       isFatigueLeft: json['is_fatigue_left'],
//       isMildTirednessLeft: json['is_mild_tiredness_left'],
//     );
//   }
// }
//
// class HomePage extends StatefulWidget {
//   @override
//   HomePageState createState() => HomePageState();
// }
//
// class HomePageState extends State<HomePage> with AutoCancelStreamMixin {
//   @override
//   Iterable<StreamSubscription> get registerSubscriptions sync* {
//     yield registerReceiver(['actionMusicPlaying']).listen(
//           (intent) {
//         switch (intent.action) {
//           case 'actionMusicPlaying':
//             setState(() {
//               getNotifactionCount();
//             });
//             break;
//         }
//       },
//     );
//   }
//
//   List<double>? _data;
//   List<String>? dates;
//   int i = 0;
//   bool edited = false;
//   // List<Feature>? features;
//   List<String>? labelX;
//   int count = 0;
//   List<String>? labelY;
//   List<double> todaygraphData = [];
//   List<double> firstTestgraphData = [];
//   List<double> idealTestgraphData = [];
//   List<dynamic> populationTestgraphData = [];
//
//   String _status = '';
//   List<FlSpot> _value = [];
//   List<_ChartData>? chartData;
//   List<_ChartData2>? chartData2;
//   double first_day_data=0.0;double current_day_data=0.0;double get_percentile_graph=0.0;double get_ideal_graph=0.0;
//   final PersistentTabController _controller = PersistentTabController();
//   // Settings settings = Settings();
//
//   List<PersistentTabConfig> _tabs() => [
//     PersistentTabConfig(
//       screen:  HomePage(),
//       item: ItemConfig(
//         icon: const Icon(Icons.home),
//         title: "Home",
//         activeForegroundColor: Colors.blue,
//         inactiveForegroundColor: Colors.grey,
//       ),
//     ),
//     PersistentTabConfig(
//       screen:  EyeHealthTrackDashboard(),
//       item: ItemConfig(
//         icon: const Icon(Icons.search),
//         title: "Search",
//         activeForegroundColor: Colors.teal,
//         inactiveForegroundColor: Colors.grey,
//       ),
//     ),
//     PersistentTabConfig.noScreen(
//       item: ItemConfig(
//         icon: const Icon(Icons.add),
//         title: "Add",
//         activeForegroundColor: Colors.blueAccent,
//         inactiveForegroundColor: Colors.grey,
//       ),
//       onPressed: (context) {
//         pushWithNavBar(
//           context,
//           DialogRoute(
//             context: context,
//             builder: (context) =>  ReportPage(),
//           ),
//         );
//       },
//     ),
//     PersistentTabConfig(
//       screen:  HomePage(),
//       item: ItemConfig(
//         icon: const Icon(Icons.message),
//         title: "Messages",
//         activeForegroundColor: Colors.deepOrange,
//         inactiveForegroundColor: Colors.grey,
//       ),
//     ),
//     // PersistentTabConfig(
//     //   screen:  MainScreen(),
//     //   item: ItemConfig(
//     //     icon: const Icon(Icons.settings),
//     //     title: "Settings",
//     //     activeForegroundColor: Colors.indigo,
//     //     inactiveForegroundColor: Colors.grey,
//     //   ),
//     // ),
//   ];
//
//
//   List<FlSpot> _spots = [FlSpot(0, 0)]; // Initialize _spots as needed
//   bool fatigue_left = false;
//   bool fatigue_right = false;
//   bool midtiredness_right = false;
//   bool midtiredness_left = false;
//   bool isSelected = false;
//   fatigueGraph? fatigueGraphData;
//   bool isLeftEyeSelected = false;
//
//   int currentHour = DateTime.now().hour;
//   late DateTime selectedDate;
//   String no_of_eye_test = "0";
//   String eye_health_score = "";
//   String fullname = "";
//   String no_of_fatigue_test = "0";
//   dynamic selectedPlanId = '';
//   bool isActivePlan = false;
//   bool isLoading1 = true;
//   int? isReadFalseCount = 0;
//   late Timer? _timer;
//   // Define selectedDate within the _CalendarButtonState class
//   final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey();
//
//   late List<AlarmSettings> alarms;
//   List<Map<String, dynamic>>? _datagraph;
//   static StreamSubscription<AlarmSettings>? subscription;
//   late DateTime _fromDate;
//   late DateTime _toDate;
//
//   Future<void> _selectDate(BuildContext context, bool isFromDate) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: isFromDate ? _fromDate : _toDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != (isFromDate ? _fromDate : _toDate)) {
//       setState(() {
//         if (isFromDate) {
//           _fromDate = picked;
//         } else {
//           _toDate = picked;
//         }
//       });
//     }
//   }
//
//   void _startTimer() {
//     const tenSeconds = Duration(seconds: 10);
//     _timer = Timer.periodic(tenSeconds, (timer) {
//       // Make your API call here
//       getNotifactionCount();
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     subscription?.cancel();
//     super.dispose();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     if (Alarm.android) {
//       checkAndroidNotificationPermission();
//       checkAndroidScheduleExactAlarmPermission();
//     }
//     loadAlarms();
//     getGraph();
//     _startTimer();
//
//     subscription ??= Alarm.ringStream.stream.listen(navigateToRingScreen);
//     Future.delayed(const Duration(seconds: 1), () {})
//         .then((_) => getNotifactionCount())
//         .then((_) {
//       if (mounted) {
//         setState(() {});
//       }
//       _timer = Timer.periodic(Duration(seconds: 10), (timer) {
//         getNotifactionCount();
//       });
//     });
//   }
//
//   Future<void> checkAndroidNotificationPermission() async {
//     final status = await Permission.notification.status;
//     if (status.isDenied) {
//       final res = await Permission.notification.request();
//     }
//   }
//
//   Future<void> getNotifactionCount() async {
//     try {
//       String userToken = '';
//       var sharedPref = await SharedPreferences.getInstance();
//       userToken = sharedPref.getString("access_token") ?? '';
//       String url = "${ApiProvider.baseUrl}/api/user_notification";
//       print("URL: $url");
//       print("userToken: $userToken");
//       Map<String, String> headers = {
//         'Authorization': 'Bearer $userToken', // Bearer token type
//         'Content-Type': 'application/json',
//       };
//       var response = await Dio().get(url, options: Options(headers: headers));
//       print('drf gfbt Count: $response');
//
//       if (response.statusCode == 200) {
//         final responseData = response.data;
//         // Map<String, dynamic> responseData = json.decode(response.data);
//         int unreadNotificationCount = responseData['is_read_false_count'];
//         isReadFalseCount = unreadNotificationCount;
//         print('Unread Notification Count: $unreadNotificationCount');
//         print('Unread gfbt Count: $response');
//         if (mounted) {
//           setState(() {});
//         }
//       } else if (response.statusCode == 401) {
//         Fluttertoast.showToast(msg: "Session Expired");
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => SignIn()),
//         );
//       } else {
//         throw Exception('Failed to load data');
//       }
//     } on DioError catch (e) {
//       if (e.response != null || e.response!.statusCode == 401) {
//         // Handle 401 error
//
//         Fluttertoast.showToast(msg: "Session Expired");
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => SignIn()),
//         );
//       } else {
//         // Handle other Dio errors
//         print("DioError: ${e.error}");
//       }
//     } catch (e) {
//       // Handle other exceptions
//       print("Exception---: $e");
//     }
//   }
//
//   Future<void> loadAlarms() async {
//     var sharedPref = await SharedPreferences.getInstance();
//     edited = sharedPref.getBool("edited") ?? false;
//     if (!edited) {
//       alarms = Alarm.getAlarms();
//       alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
//
//       if (alarms.isNotEmpty) {
//         for (int i = 0; i < alarms.length; i++) {
//           await Alarm.stop(alarms[i].id);
//         }
//         alarms.clear();
//       }
//
//       if (alarms.isEmpty) {
//         DateTime now = DateTime.now();
//
//         // Define alarm times for today
//         List<DateTime> todayAlarmTimes = [
//           DateTime(now.year, now.month, now.day, 6),
//           DateTime(now.year, now.month, now.day, 9),
//           DateTime(now.year, now.month, now.day, 12),
//           DateTime(now.year, now.month, now.day, 15),
//           DateTime(now.year, now.month, now.day, 18),
//           DateTime(now.year, now.month, now.day, 21),
//           DateTime(now.year, now.month, now.day + 1, 0),
//         ];
//
//         // Define alarm times for tomorrow
//         List<DateTime> tomorrowAlarmTimes = todayAlarmTimes.map((alarmTime) {
//           return alarmTime.add(const Duration(days: 1));
//         }).toList();
//
//         for (int i = 0; i < 7; i++) {
//           DateTime alarmTime;
//           if (todayAlarmTimes[i].isBefore(now)) {
//             // Set alarm for tomorrow
//             alarmTime = tomorrowAlarmTimes[i];
//           } else {
//             // Set alarm for today
//             alarmTime = todayAlarmTimes[i];
//           }
//
//           print("Alarm Time $alarmTime");
//           saveAlarm(i, alarmTime);
//         }
//       }
//     }
//   }
//
//   AlarmSettings buildAlarmSettings(int i, DateTime duration) {
//     final id = DateTime.now().millisecondsSinceEpoch % 10000 + i;
//     final alarmSettings = AlarmSettings(
//         id: id,
//         dateTime: duration,
//         loopAudio: true,
//         vibrate: true,
//         volume: null,
//         assetAudioPath: 'assets/marimba.mp3',
//         notificationTitle: 'Test Reminder',
//         notificationBody: 'Do your eye test',
//         isAlarmOn: true);
//     return alarmSettings;
//   }
//
//   Future<void> saveAlarm(int i, DateTime duration) async {
//     await Alarm.set(alarmSettings: buildAlarmSettings(i, duration));
//     alarms = Alarm.getAlarms();
//     alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
//     SharedPref.saveAlarmsToPrefs(alarms);
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
//   Future<void> checkAndroidExternalStoragePermission() async {
//     final status = await Permission.storage.status;
//     if (status.isDenied) {
//       final res = await Permission.storage.request();
//     }
//   }
//
//   Future<void> checkAndroidScheduleExactAlarmPermission() async {
//     final status = await Permission.scheduleExactAlarm.status;
//     if (status.isDenied) {
//       final res = await Permission.scheduleExactAlarm.request();
//     }
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
//
//   @override
//   Widget build(BuildContext context) =>
//       PersistentTabView(
//         controller: _controller,
//         tabs: _tabs(),
//         navBarBuilder: (navBarConfig) => settings.navBarBuilder(
//           navBarConfig,
//           NavBarDecoration(
//             color: settings.navBarColor,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           const ItemAnimation(),
//           const NeumorphicProperties(),
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () => showDialog(
//             context: context,
//             builder: (context) => Dialog(
//               child: SettingsView(
//                 settings: settings,
//                 onChanged: (newSettings) => setState(() {
//                   settings = newSettings;
//                 }),
//               ),
//             ),
//           ),
//           child: const Icon(Icons.settings),
//         ),
//         backgroundColor: Colors.green,
//         margin: settings.margin,
//         avoidBottomPadding: settings.avoidBottomPadding,
//         handleAndroidBackButtonPress: settings.handleAndroidBackButtonPress,
//         resizeToAvoidBottomInset: settings.resizeToAvoidBottomInset,
//         stateManagement: settings.stateManagement,
//         onWillPop: (context) async {
//           await showDialog(
//             context: context,
//             builder: (context) => Dialog(
//               child: Center(
//                 child: ElevatedButton(
//                   child: const Text("Close"),
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//               ),
//             ),
//           );
//           return false;
//         },
//         hideNavigationBar: settings.hideNavBar,
//         popAllScreensOnTapOfSelectedTab:
//         settings.popAllScreensOnTapOfSelectedTab,
//       );
//   // Widget build(BuildContext context) {
//   //   int currentHour = DateTime.now().hour;
//   //   // Determine the appropriate salutation based on the current hour
//   //   String salutation = 'Welcome';
//   //   // if (currentHour >= 0 && currentHour < 12) {
//   //   //   salutation = 'Good morning';
//   //   // } else if (currentHour >= 12 && currentHour < 17) {
//   //   //   salutation = 'Good afternoon';
//   //   // } else {
//   //   //   salutation = 'Good evening';
//   //   // }
//   //   return
//   //     Scaffold(
//   //     key: _scafoldKey,
//   //     endDrawer: NotificationSideBar(
//   //       onNotificationUpdate: () {
//   //         setState(() {
//   //           if (isReadFalseCount != null) {
//   //             if (isReadFalseCount! > 0) {
//   //               isReadFalseCount = isReadFalseCount! - 1;
//   //             }
//   //           }
//   //         });
//   //       },
//   //     ),
//   //     endDrawerEnableOpenDragGesture: false,
//   //     // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//   //     // floatingActionButton: Padding(
//   //     //   padding: const EdgeInsets.all(8.0), // Add padding
//   //     //   child: ClipOval(
//   //     //     child: Material(
//   //     //       // color: Colors.background,
//   //     //       color: Colors.white70.withOpacity(0.9), // Background color
//   //     //       elevation: 4.0, // Shadow
//   //     //       child: InkWell(
//   //     //         onTap: () {},
//   //     //         child: SizedBox(
//   //     //           width: 53.0, // Width of the FloatingActionButton
//   //     //           height: 50.0, // Height of the FloatingActionButton
//   //     //           child: Center(
//   //     //             child: Padding(
//   //     //               padding:
//   //     //               const EdgeInsets.all(8.0), // Add padding for the icon
//   //     //               child: Image.asset(
//   //     //                 "assets/home_icon.jpeg",
//   //     //                 width: 27,
//   //     //                 // fit: BoxFit.cover, // Uncomment if you want the image to cover the button
//   //     //                 // color: Colors.grey, // Uncomment if you want to apply a color to the image
//   //     //               ),
//   //     //             ),
//   //     //           ),
//   //     //         ),
//   //     //       ),
//   //     //     ),
//   //     //   ),
//   //     // ),
//   //     // appBar: PreferredSize(
//   //     //   preferredSize: const Size.fromHeight(145),
//   //     //   child: Stack(
//   //     //     children: [
//   //     //       Image.asset(
//   //     //         'assets/pageBackground.png',
//   //     //         fit: BoxFit.fill,
//   //     //         width: double.infinity,
//   //     //         height: 260,
//   //     //       ),
//   //     //       Padding(
//   //     //         padding: const EdgeInsets.all(14.0),
//   //     //         child: SizedBox(
//   //     //           child: Padding(
//   //     //             padding: const EdgeInsets.fromLTRB(8.0, 10.0, 0, 4),
//   //     //             child: Column(
//   //     //               crossAxisAlignment: CrossAxisAlignment.start,
//   //     //               children: [
//   //     //                 Row(
//   //     //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //     //                   children: [
//   //     //                     Text(
//   //     //                       salutation,
//   //     //                       style: const TextStyle(
//   //     //                           color: Colors.white,
//   //     //                           fontSize: 18,
//   //     //                           fontWeight: FontWeight.w500),
//   //     //                     ),
//   //     //                   ],
//   //     //                 ),
//   //     //                 Text(
//   //     //                   fullname,
//   //     //                   style: const TextStyle(
//   //     //                       color: Colors.lightBlueAccent, fontSize: 18),
//   //     //                 ),
//   //     //                 Row(
//   //     //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //     //                   children: [
//   //     //                     const Text(
//   //     //                       'Your Eye Health Score',
//   //     //                       style: TextStyle(color: Colors.white, fontSize: 18),
//   //     //                     ),
//   //     //                     ShaderMask(
//   //     //                       shaderCallback: (Rect bounds) {
//   //     //                         return const RadialGradient(
//   //     //                           radius: 1.0,
//   //     //                           colors: [
//   //     //                             Color(0xFFFFF400),
//   //     //                             Color(0xFFFFE800),
//   //     //                             Color(0xFFFFCA00),
//   //     //                             Color(0xFFFF9A00),
//   //     //                             Color(0xFFFF9800),
//   //     //                           ],
//   //     //                         ).createShader(bounds);
//   //     //                       },
//   //     //                       child: Text(
//   //     //                         eye_health_score,
//   //     //                         style: const TextStyle(
//   //     //                             fontSize: 31,
//   //     //                             color: Colors.white,
//   //     //                             fontWeight: FontWeight.bold),
//   //     //                       ),
//   //     //                     ),
//   //     //                   ],
//   //     //                 ),
//   //     //               ],
//   //     //             ),
//   //     //           ),
//   //     //         ),
//   //     //       ),
//   //     //       Positioned(
//   //     //         right: 16,
//   //     //         top: 16,
//   //     //         child: GestureDetector(
//   //     //           onTap: () {
//   //     //             _scafoldKey.currentState!.openEndDrawer();
//   //     //           },
//   //     //           child: Stack(
//   //     //             children: [
//   //     //               Container(
//   //     //                 decoration: BoxDecoration(
//   //     //                   color: const Color(0xffF9F9FA),
//   //     //                   borderRadius: BorderRadius.circular(17.0),
//   //     //                 ),
//   //     //                 height: 40,
//   //     //                 width: 40,
//   //     //                 child: Center(
//   //     //                   child: Icon(
//   //     //                     Icons.notifications,
//   //     //                     color: Colors.black,
//   //     //                   ),
//   //     //                 ),
//   //     //               ),
//   //     //               Positioned(
//   //     //                 right: 0,
//   //     //                 top:
//   //     //                 -1, // Adjust this value to position the text properly
//   //     //                 child: Container(
//   //     //                   padding: const EdgeInsets.all(2),
//   //     //                   decoration: const BoxDecoration(
//   //     //                     shape: BoxShape.circle,
//   //     //                     color: Colors.red,
//   //     //                   ),
//   //     //                   child: Text(
//   //     //                     '${isReadFalseCount}',
//   //     //                     style: const TextStyle(
//   //     //                       color: Colors.white,
//   //     //                       fontSize: 11,
//   //     //                       fontWeight: FontWeight.bold,
//   //     //                     ),
//   //     //                   ),
//   //     //                 ),
//   //     //               ),
//   //     //             ],
//   //     //           ),
//   //     //         ),
//   //     //       ),
//   //     //     ],
//   //     //   ),
//   //     // ),
//   //
//   //
//   //
//   //     body:
//   //     SingleChildScrollView(
//   //       child: Column(
//   //         crossAxisAlignment: CrossAxisAlignment.stretch,
//   //         children: <Widget>[
//   //           Padding(
//   //             padding: const EdgeInsets.all(8.0),
//   //             child: CarouselSlider(
//   //               items: [
//   //                 //1st Image of Slider
//   //                 Container(
//   //                   margin: EdgeInsets.all(6.0),
//   //                   decoration: BoxDecoration(
//   //                     borderRadius: BorderRadius.circular(8.0),
//   //                     image: DecorationImage(
//   //                       image: AssetImage('assets/slider1.png'),//NetworkImage("ADD IMAGE URL HERE"),
//   //                       fit: BoxFit.cover,
//   //                     ),
//   //                   ),
//   //                 ),
//   //
//   //                 //2nd Image of Slider
//   //                 Container(
//   //                   margin: EdgeInsets.all(6.0),
//   //                   decoration: BoxDecoration(
//   //                     borderRadius: BorderRadius.circular(8.0),
//   //                     image: DecorationImage(
//   //                       image: AssetImage('assets/slider2.png'),//NetworkImage("ADD IMAGE URL HERE"),
//   //                       fit: BoxFit.cover,
//   //                     ),
//   //                   ),
//   //                 ),
//   //
//   //                 //3rd Image of Slider
//   //                 Container(
//   //                   margin: EdgeInsets.all(6.0),
//   //                   decoration: BoxDecoration(
//   //                     borderRadius: BorderRadius.circular(8.0),
//   //                     image: DecorationImage(
//   //                       image: AssetImage('assets/slider3.png'),//NetworkImage("ADD IMAGE URL HERE"),
//   //                       fit: BoxFit.cover,
//   //                     ),
//   //                   ),
//   //                 ),
//   //
//   //                 //4th Image of Slider
//   //                 Container(
//   //                   margin: EdgeInsets.all(6.0),
//   //                   decoration: BoxDecoration(
//   //                     borderRadius: BorderRadius.circular(8.0),
//   //                     image: DecorationImage(
//   //                       image: AssetImage('assets/slider1.png'),//NetworkImage("ADD IMAGE URL HERE"),
//   //                       fit: BoxFit.cover,
//   //                     ),
//   //                   ),
//   //                 ),
//   //
//   //                 //5th Image of Slider
//   //                 Container(
//   //                   margin: EdgeInsets.all(6.0),
//   //                   decoration: BoxDecoration(
//   //                     borderRadius: BorderRadius.circular(8.0),
//   //                     image: DecorationImage(
//   //                       image: AssetImage('assets/slider2.png'),//NetworkImage("ADD IMAGE URL HERE"),
//   //                       fit: BoxFit.cover,
//   //                     ),
//   //                   ),
//   //                 ),
//   //
//   //               ],
//   //
//   //               //Slider Container properties
//   //               options: CarouselOptions(
//   //                 height: 180.0,
//   //                 enlargeCenterPage: true,
//   //                 autoPlay: true,
//   //                 aspectRatio: 16 / 9,
//   //                 autoPlayCurve: Curves.fastOutSlowIn,
//   //                 enableInfiniteScroll: true,
//   //                 autoPlayAnimationDuration: Duration(milliseconds: 500),
//   //                 viewportFraction: 0.8,
//   //               ),
//   //             ),
//   //           ),
//   //   SizedBox(height: 10,),
//   //   Padding(
//   //             padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 5),
//   //             child: GestureDetector(
//   //               onTap: () {
//   //                 checkActivePlan('eyeTest');
//   //                 /*   Navigator.push(
//   //                   context,
//   //                   MaterialPageRoute(builder: (context) => AddCustomerPage()),
//   //                 );*/
//   //               },
//   //               child: Image.asset('assets/digital_eye_exam.png',),
//   //             ),
//   //           ),
//   //           Padding(
//   //             padding:
//   //             const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
//   //             child: GestureDetector(
//   //               onTap: () {
//   //                 // sendcustomerDetails(context);
//   //                 checkActivePlan('fatigue');
//   //               },
//   //               child: Image.asset('assets/eyeFatigueTest.png'),
//   //             ),
//   //           ),
//   //           SizedBox(height: 10,),
//   //           Row(
//   //             children: [
//   //               const Padding(
//   //                 padding: EdgeInsets.fromLTRB(16.0, 10, 0, 10),
//   //                 child: Text(
//   //                   'EYE HEALTH OVERVIEW', // Display formatted current date
//   //                   style: TextStyle(
//   //                     fontSize: 18,
//   //                     fontWeight: FontWeight.bold,
//   //                   ),
//   //                 ),
//   //               ),
//   //              Spacer(),
//   //               Padding(
//   //                 padding: const EdgeInsets.symmetric(horizontal: 18.0),
//   //                 child: GestureDetector(
//   //                     onTap: () {
//   //                       Navigator.push(
//   //                         context,
//   //                         MaterialPageRoute<void>(
//   //                           builder: (context) => const ExampleAlarmHomeScreen(),
//   //                         ),
//   //                       );
//   //                     },
//   //                     child:Icon(
//   //                       Icons.alarm, // Replace with the alarm icon from Icons class
//   //                       size: 33, // Adjust the size of the icon as needed
//   //                       color: Colors.blue, // Adjust the color of the icon as needed
//   //                     ),),
//   //               ),
//   //             ],
//   //           ),
//   //
//   //           Container(
//   //             color: Colors.white,
//   //             child: Padding(
//   //               padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 1),
//   //               child: Container(
//   //                 // color: Colors.white,
//   //                 width: MediaQuery.of(context).size.width,
//   //                 child: Card(
//   //                   color: Colors.white,
//   //                   elevation: 0.2,
//   //                   child: Column(
//   //                     crossAxisAlignment: CrossAxisAlignment.start,
//   //                     children: [
//   //                       // if (chartData != null) ...{
//   //                       // Center(
//   //                       //   child: Container(
//   //                       //     color: Colors.white,
//   //                       //     child: _buildVerticalSplineChart(),
//   //                       //   ),
//   //                       // ),
//   //                       // SizedBox(height: 10),
//   //                       // Row(
//   //                       //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//   //                       //   children: [
//   //                       //     _buildColorDescription(Colors.black, 'First Test'),
//   //                       //     _buildColorDescription(Colors.green, 'Ideal'),
//   //                       //     _buildColorDescription(Colors.orange, 'Percentile'),
//   //                       //     _buildColorDescription(Colors.blue, 'User avg'),
//   //                       //   ],
//   //                       // ),
//   //                       Center(
//   //                         child: Column(
//   //                           mainAxisAlignment: MainAxisAlignment.center,
//   //                           children: <Widget>[
//   //                             DotWithLabel(index: 0, label: 'Ideal Score',point:get_ideal_graph.toDouble(), ),
//   //                             Divider(
//   //                               height: 5,
//   //                               thickness: 0.5,
//   //                               color: Colors.grey[400],
//   //                               indent: 20,
//   //                               endIndent: 20,
//   //                             ),
//   //                             SizedBox(height: 7,),
//   //                             DotWithLabel(index: 1, label: 'Percentile Score of the population',point:get_percentile_graph.toDouble(),),
//   //                             Divider(
//   //                               height: 5,
//   //                               thickness: 0.5,
//   //                               color: Colors.grey[400],
//   //                               indent: 20,
//   //                               endIndent: 20,
//   //                             ),
//   //                             SizedBox(height: 7,),
//   //
//   //                             DotWithLabel( index:2,label: 'Your Avg. Score',point:current_day_data.toDouble(),),
//   //                             Divider(
//   //                               height: 5,
//   //                               thickness: 0.5,
//   //                               color: Colors.grey[400],
//   //                               indent: 20,
//   //                               endIndent: 20,
//   //                             ),
//   //                             SizedBox(height: 7,),
//   //
//   //                             DotWithLabel(index: 3, label: 'Your First Score',point:first_day_data.toDouble(),),//color: Colors.black,
//   //                           ],
//   //                         ),
//   //                       ),
//   //                       SizedBox(height: 20,),
//   //                       Padding(
//   //                         padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1),
//   //                         child: Row(
//   //                           crossAxisAlignment: CrossAxisAlignment.start,
//   //                           children: [
//   //                             Padding(
//   //                               padding: const EdgeInsets.all(5.0),
//   //                               child: Container(
//   //                                 width: 10,
//   //                                 height: 10,
//   //                                 decoration: BoxDecoration(
//   //                                   color: Colors.background, // Adjust color as needed
//   //                                   shape: BoxShape.circle,
//   //                                 ),
//   //                               ),
//   //                             ),
//   //                             SizedBox(width: 8),
//   //                             Expanded(
//   //                               child: Text(
//   //                                 'Score 10 indicates - You have Perfect Eyes',
//   //                                 style: TextStyle(
//   //                                   fontSize: 12,
//   //                                   fontWeight: FontWeight.w600,
//   //                                   color: Colors.background, // Adjust text color as needed
//   //                                 ),
//   //                               ),
//   //                             ),
//   //                           ],
//   //                         ),
//   //                       ),
//   //
//   //                       SizedBox(height: 10,),
//   //                       Padding(
//   //                         padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1),
//   //                         child: Row(
//   //                           crossAxisAlignment: CrossAxisAlignment.start,
//   //                           children: [
//   //                             Padding(
//   //                               padding: const EdgeInsets.all(6.0),
//   //                               child: Container(
//   //                                 width: 10,
//   //                                 height: 10,
//   //                                 decoration: BoxDecoration(
//   //                                   color: Colors.redAccent, // Adjust color as needed
//   //                                   shape: BoxShape.circle,
//   //                                 ),
//   //                               ),
//   //                             ),
//   //                             SizedBox(width: 8),
//   //                             Expanded(
//   //                               child: Text(
//   //                                 'Score 3 indicates - Your eyes need Urgent attention',
//   //                                 style: TextStyle(
//   //                                   fontSize: 12,
//   //                                   fontWeight: FontWeight.w600,
//   //                                   color: Colors.redAccent, // Adjust text color as needed
//   //                                 ),
//   //                               ),
//   //                             ),
//   //                           ],
//   //                         ),
//   //                       ),
//   //
//   //
//   //
//   //
//   //
//   //
//   //
//   //
//   //                       if   (count==0)...{
//   //                         SizedBox(height: 10),
//   //
//   //                         Padding(
//   //                           padding: EdgeInsets.fromLTRB(16.0, 10, 0, 0),
//   //                           child: Text(
//   //                             'Get your first test done now and start tracking your eye health.', // Display formatted current date
//   //                             style: TextStyle(
//   //                                 fontSize: 14,
//   //                                 color: Colors.black),
//   //                           ),
//   //                         ),
//   //                         SizedBox(height: 9),
//   //                         Center(
//   //                           child: Padding(
//   //                             padding: const EdgeInsets.all(8.0),
//   //                             child: ElevatedButton(
//   //                               onPressed: () {
//   //
//   //                                 requestPermission();
//   //
//   //                                 // Navigator.push(
//   //                                 // context,
//   //                                 // MaterialPageRoute(
//   //                                 // builder: (context) => EyeFatigueSelfieScreen()),
//   //                                 // );
//   //                               },
//   //                               child: Text('Start Test Now'),
//   //                               style: ElevatedButton.styleFrom(
//   //                                 minimumSize: Size(200, 45),
//   //                                 foregroundColor: Colors.white,
//   //                                 backgroundColor: Colors.bluebutton,
//   //                                 shape: RoundedRectangleBorder(
//   //                                   borderRadius: BorderRadius.circular(25),
//   //                                 ),
//   //                               ),
//   //                             ),
//   //                           ),
//   //                         ),
//   //                         // SizedBox(height: 30),
//   //                         // Center(
//   //                         //   child: Column(
//   //                         //     mainAxisAlignment: MainAxisAlignment.center,
//   //                         //     children: <Widget>[
//   //                         //       SizedBox(height: 30),
//   //                         //       Image.asset(
//   //                         //         'assets/error.png', // Replace with your image path
//   //                         //         width: 200, // Adjust width as needed
//   //                         //         height: 250, // Adjust height as needed
//   //                         //       ),
//   //                         //       SizedBox(height: 20), // Adjust spacing between image and text
//   //                         //
//   //                         //       Padding(
//   //                         //         padding: const EdgeInsets.symmetric(horizontal: 20.0),
//   //                         //         child: Text(
//   //                         //           'No Reports to Show',
//   //                         //           textAlign: TextAlign.center,
//   //                         //           style: TextStyle(
//   //                         //             fontSize: 16,
//   //                         //             color: Colors.black,
//   //                         //           ),
//   //                         //         ),
//   //                         //       ),
//   //                         //     ],
//   //                         //   ),
//   //                         // ),
//   //                         // SizedBox(height: 30),
//   //
//   //                       },
//   //
//   //
//   //                       // },
//   //
//   //
//   //                       SizedBox(height: 29),
//   //                     ],
//   //                   ),
//   //                 ),
//   //               ),
//   //             ),
//   //           ),
//   //
//   //           SizedBox(
//   //             height: 8,),
//   //
//   //            Padding(
//   //             padding: EdgeInsets.fromLTRB(16.0, 10, 0, 0),
//   //             child: Text(
//   //               'YOU HAVE TESTED SO FAR', // Display formatted current date
//   //               style: TextStyle(
//   //                   fontSize: 18,
//   //                   fontWeight: FontWeight.bold,
//   //                   color: Colors.black),
//   //             ),
//   //           ),
//   //     SizedBox(
//   //        height: 24,),
//   //
//   //       Padding(
//   //   padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10),
//   //   child: SizedBox(
//   //
//   //   height: 180, // Adjust height as needed
//   //   child: Row(
//   //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//   //   children: [
//   //   Expanded(
//   //   child: Container(
//   //   decoration: const BoxDecoration(
//   //   image: DecorationImage(
//   //   image: AssetImage('assets/interview.png'),
//   //   // Replace with your image asset
//   //   fit: BoxFit.cover, // Ensure the image covers the entire container
//   //   ),
//   //   ),
//   //   child: Column(
//   //   mainAxisAlignment: MainAxisAlignment.start,
//   //   children: [
//   //   const SizedBox(height: 28),
//   //   Padding(
//   //   padding: const EdgeInsets.symmetric(vertical: 8.0),
//   //   child: Text(
//   //   no_of_eye_test ?? "0",
//   //   style: const TextStyle(
//   //   color: Colors.white,
//   //   fontSize: 22,
//   //   fontWeight: FontWeight.bold,
//   //   ),
//   //   ),
//   //   ),
//   //   const Padding(
//   //   padding: EdgeInsets.symmetric(vertical: 5.0),
//   //   child: Text(
//   //   'Eye Test',
//   //   style: TextStyle(
//   //   color: Colors.white,
//   //   fontSize: 16,
//   //   ),
//   //   ),
//   //   ),
//   //   ],
//   //   ),
//   //   ),
//   //   ),
//   //   Expanded(
//   //   child: Container(
//   //   decoration: const BoxDecoration(
//   //   image: DecorationImage(
//   //   image: AssetImage('assets/eye_bg.png'),
//   //   // Replace with your image asset
//   //   fit: BoxFit.cover, // Ensure the image covers the entire container
//   //   ),
//   //   ),
//   //   child: Column(
//   //   mainAxisAlignment: MainAxisAlignment.start,
//   //   children: [
//   //   const SizedBox(height: 28),
//   //   Padding(
//   //   padding: const EdgeInsets.symmetric(
//   //   vertical: 12.0, horizontal: 8.0),
//   //   child: Text(
//   //   no_of_fatigue_test ?? "0",
//   //   style: const TextStyle(
//   //   color: Colors.white,
//   //   fontSize: 22,
//   //   fontWeight: FontWeight.bold,
//   //   ),
//   //   ),
//   //   ),
//   //   const Padding(
//   //   padding: EdgeInsets.symmetric(
//   //   vertical: 5.0, horizontal: 4.0),
//   //   child: Text(
//   //   'Eye Fatigue Test',
//   //   style: TextStyle(
//   //   color: Colors.white,
//   //   fontSize: 14,
//   //   ),
//   //   ),
//   //   ),
//   //   ],
//   //   ),
//   //   ),
//   //   ),
//   //   ],
//   //   ),
//   //   ),
//   //   ),
//   //
//   //       const SizedBox(height: 19),
//   //
//   //         ],
//   //       ),
//   //     ),
//   //
//   //     bottomNavigationBar: CustomBottomAppBar(
//   //       currentScreen: 'HomePage',
//   //     ),
//   //   );
//   // }
//
//   Widget _buildColorDescription(Color color, String text) {
//     return Row(
//       children: [
//         Container(
//           width: 22,
//           height: 15,
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(
//                 25), // Adjust the radius to make it rounded
//           ),
//           margin: const EdgeInsets.only(right: 4),
//         ),
//         Text(text),
//       ],
//     );
//   }
//
//   void requestPermission() async {
//     PermissionStatus status = await Permission.camera.status;
//     PermissionStatus status2 = await Permission.microphone.status;
//
//     if ((status == PermissionStatus.granted &&
//         status2 == PermissionStatus.granted)) {
//       setState(() {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => EyeFatigueSelfieScreen()),
//         );
//       });
//     }
//     if (!status.isGranted) {
//       status = await Permission.camera.request();
//     }
//     if (!status2.isGranted) {
//       status = await Permission.microphone.request();
//     }
//     if (status == PermissionStatus.denied ||
//         status == PermissionStatus.permanentlyDenied) {
//       await [Permission.camera].request();
//
//       // Permissions are denied or denied forever, let's request it!
//       status = await Permission.camera.status;
//       if (status == PermissionStatus.denied) {
//         await [Permission.camera].request();
//         print("camera permissions are still denied");
//       } else if (status == PermissionStatus.permanentlyDenied) {
//         print("camera permissions are permanently denied");
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text("camera permissions required"),
//               content: Text(
//                   "camera permissions are permanently denied. Please go to app settings to enable camera permissions."),
//               actions: <Widget>[
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors
//                         .background, // Set your desired background color here
//                     // You can also customize other button properties here if needed
//                   ),
//                   onPressed: () async {
//                     Navigator.pop(context); // Close the dialog
//                     await openAppSettings();
//                   },
//                   child: Text(
//                     "OK",
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       }
//     }
//
//     if (status2 == PermissionStatus.denied ||
//         status2 == PermissionStatus.permanentlyDenied) {
//       await [Permission.microphone].request();
//
//       // Permissions are denied or denied forever, let's request it!
//       status2 = await Permission.microphone.status;
//       if (status2 == PermissionStatus.denied) {
//         await [Permission.microphone].request();
//         print("microphone permissions are still denied");
//       }
//       if (status2 == PermissionStatus.permanentlyDenied) {
//         print("microphone permissions are permanently denied");
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text("microphone permissions required"),
//               content: Text(
//                   "microphone permissions are permanently denied. Please go to app settings to enable microphone permissions."),
//               actions: <Widget>[
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors
//                         .background, // Set your desired background color here
//                     // You can also customize other button properties here if needed
//                   ),
//                   onPressed: () async {
//                     Navigator.pop(context); // Close the dialog
//                     await openAppSettings();
//                   },
//                   child: Text(
//                     "OK",
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       }
//     }
//   }
//   //
//   // SfCartesianChart _buildVerticalSplineChart() {
//   //   return SfCartesianChart(
//   //     isTransposed: false,
//   //     plotAreaBorderWidth: 0,
//   //     legend: const Legend(isVisible: true),
//   //     primaryXAxis: const CategoryAxis(
//   //       majorTickLines: MajorTickLines(size: 0),
//   //       axisLine: AxisLine(width: 0.3),
//   //       majorGridLines: MajorGridLines(width: 0),
//   //       title: AxisTitle(text: 'time slots  (x-axis) --->'),
//   //     ), // Disable vertical inner gridlines
//   //
//   //     primaryYAxis: const NumericAxis(
//   //       minimum: 0,
//   //       maximum: 11,
//   //       interval: 1,
//   //       labelFormat: '{value}',
//   //       title: AxisTitle(
//   //           text: 'eye score  (y-axis)  --->'), // Description for X axis
//   //       majorGridLines: MajorGridLines(width: 0), // Hide horizontal grid lines
//   //     ),
//   //     series: firstTestgraphData.isNotEmpty
//   //         ? _getVerticalSplineSeries()
//   //         : _getVerticalSplineSeries1(),
//   //     tooltipBehavior: TooltipBehavior(enable: true),
//   //   );
//   // }
//   //
//   // List<SplineSeries<_ChartData, String>> _getVerticalSplineSeries() {
//   //   return <SplineSeries<_ChartData, String>>[
//   //     // SplineSeries<_ChartData, String>(
//   //     //     markerSettings: const MarkerSettings(isVisible: true),
//   //     //     dataSource: chartData,color: Colors.black,
//   //     //     xValueMapper: (_ChartData sales, _) => sales.x,
//   //     //     yValueMapper: (_ChartData sales, _) => sales.y,
//   //     //     name: 'Initial User Score'),
//   //     SplineSeries<_ChartData, String>(
//   //       markerSettings: const MarkerSettings(isVisible: true),
//   //       dataSource: chartData,
//   //       cardinalSplineTension: 0.5,
//   //       splineType: SplineType.monotonic,
//   //       name: 'Ideal Score',
//   //       color: Colors.green,
//   //       xValueMapper: (_ChartData sales, _) => sales.x,
//   //       yValueMapper: (_ChartData sales, _) => sales.y2,
//   //       emptyPointSettings: const EmptyPointSettings(
//   //           mode: EmptyPointMode.gap, // Connect null points to zero
//   //           color: Colors.green,
//   //           borderColor: Colors.green,
//   //           borderWidth:
//   //           2 // Optional: Set color of the line connecting null points
//   //       ),
//   //     ),
//   //     // SplineSeries<_ChartData, String>(
//   //     //   markerSettings: const MarkerSettings(isVisible: true),
//   //     //   dataSource: chartData,
//   //     //   name: 'over 3.5 lac users',color:Colors.orange ,
//   //     //   xValueMapper: (_ChartData sales, _) => sales.x,
//   //     //   yValueMapper: (_ChartData sales, _) => sales.y3,
//   //     // ),
//   //
//   //     SplineSeries<_ChartData, String>(
//   //       markerSettings: const MarkerSettings(isVisible: true),
//   //       dataSource: chartData,
//   //       color: Colors.blue,
//   //       cardinalSplineTension: 0.5,
//   //       splineType: SplineType.monotonic,
//   //       name: 'User Average Score',
//   //       xValueMapper: (_ChartData sales, _) => sales.x,
//   //       yValueMapper: (_ChartData sales, _) => sales.y4,
//   //       emptyPointSettings: const EmptyPointSettings(
//   //           mode: EmptyPointMode.zero, // Connect null points to zero
//   //           color: Colors.blue,
//   //           borderColor: Colors.blue,
//   //           borderWidth:
//   //           2 // Optional: Set color of the line connecting null points
//   //       ),
//   //     )
//   //   ];
//   // }
//   //
//   // List<SplineSeries<_ChartData2, String>> _getVerticalSplineSeries1() {
//   //   return <SplineSeries<_ChartData2, String>>[
//   //     SplineSeries<_ChartData2, String>(
//   //       markerSettings: const MarkerSettings(isVisible: true),
//   //       dataSource: chartData2,
//   //       cardinalSplineTension: 0.5,
//   //       splineType: SplineType.monotonic,
//   //       name: 'Ideal Score',
//   //       color: Colors.green,
//   //       xValueMapper: (_ChartData2 sales, _) => sales.x,
//   //       yValueMapper: (_ChartData2 sales, _) => sales.y,
//   //       emptyPointSettings: const EmptyPointSettings(
//   //           mode: EmptyPointMode.gap, // Connect null points to zero
//   //           color: Colors.green,
//   //           borderColor: Colors.green,
//   //           borderWidth:
//   //           2 // Optional: Set color of the line connecting null points
//   //       ),
//   //     ),
//   //     SplineSeries<_ChartData2, String>(
//   //       markerSettings: const MarkerSettings(isVisible: true),
//   //       dataSource: chartData2,
//   //       color: Colors.blue,
//   //       cardinalSplineTension: 0.5,
//   //       splineType: SplineType.monotonic,
//   //       name: 'User Average Score',
//   //       xValueMapper: (_ChartData2 sales, _) => sales.x,
//   //       yValueMapper: (_ChartData2 sales, _) => sales.y2,
//   //       emptyPointSettings: const EmptyPointSettings(
//   //           mode: EmptyPointMode.zero, // Connect null points to zero
//   //           color: Colors.blue,
//   //           borderColor: Colors.blue,
//   //           borderWidth:
//   //           2 // Optional: Set color of the line connecting null points
//   //       ),
//   //     )
//   //   ];
//   // }
//
//   void checkActivePlan(String testType) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String token = prefs.getString('access_token') ?? '';
//
//     try {
//       final response = await http.get(
//         Uri.parse('${ApiProvider.baseUrl + ApiProvider.isActivePlan}'),
//         headers: <String, String>{
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         // _progressDialog!.hide();
//
//         final jsonResponse = jsonDecode(response.body);
//
//         // Access the value of is_verified
//         isActivePlan = jsonResponse['is_active_plan'];
//         selectedPlanId = jsonResponse['plan_id'];
//
//         setState(() {
//           if (isActivePlan == false) {
//             Fluttertoast.showToast(
//               msg: "Before Start the Test Please Purchase the Plan",
//               toastLength: Toast.LENGTH_LONG,
//               gravity: ToastGravity.BOTTOM,
//               timeInSecForIosWeb: 1,
//               backgroundColor: Colors.bluebutton,
//               textColor: Colors.white,
//               fontSize: 16.0,
//             );
//           } else {
//             if (testType == 'fatigue') {
//               requestPermission();
//             } else {
//               showModalBottomSheet(
//                 context: context,
//                 builder: (context) => BottomDialog(),
//               );
//             }
//           }
//         });
//
//         print("responseviewprofile999:${response.body}");
//
//         return json.decode(response.body);
//       } else {
//         // _progressDialog!.hide();
//
//         print(response.body);
//       }
//     } catch (e) {
//       // _progressDialog!.hide();
//
//       print("exception:$e");
//     }
//     throw Exception('');
//   }
//
//   Future<void> sendcustomerDetails(BuildContext context) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String authToken =
//     // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
//     prefs.getString('access_token') ?? '';
//     final String apiUrl = '${Api.baseurl}/api/eye/add-customer';
// // Replace these headers with your required headers
//     Map<String, String> headers = {
//       'Authorization': 'Bearer $authToken',
//       'Content-Type': 'application/json',
//     };
//
//     var body = json.encode({
//       "is_self": true,
//     });
//
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: headers,
//         body: body,
//       );
//       print('response === ' + response.body);
//       if (response.statusCode == 200) {
//         if (kDebugMode) {
//           print('sddd ${response.body}');
//         }
//         Map<String, dynamic> jsonResponse = jsonDecode(response.body);
//       } else {
//         print('Failed with status code: ${response.statusCode}');
//         print('Failed sddd ${response.body}');
//       }
//     } catch (e) {
// // Handle exceptions here (e.g., network errors)
//       print('Exception: $e');
//     }
//   }
//
//   Future<void> getGraph() async {
//     //List<double>
//     // try {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String authToken = prefs.getString('access_token') ?? '';
//     final response = await http.get(
//       Uri.parse(
//           '${ApiProvider.baseUrl}/api/fatigue/fatigue-graph?user_timezone=Asia/Kolkata'),
//       headers: <String, String>{
//         'Authorization': 'Bearer $authToken',
//       },
//     );
//     print("response=======data===${response.body}");
//     if (response.statusCode == 200) {
//       final responseData = json.decode(response.body);
//       fatigueGraphData = fatigueGraph.fromJson(responseData);
//
//       print("graphdata===:${response.body}");
//
//       Map<String, dynamic> jsonData = jsonDecode(response.body);
//       // List<dynamic> data = jsonData['data'];
//       fullname = jsonData['name'];
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString('name', fullname);
//       int no_of_fatigue = jsonData['no_of_fatigue_test'];
//       int no_of_eye_ = jsonData['no_of_eye_test'];
//       dynamic eye_hscore = jsonData['eye_health_score'];
//       setState(() {
//         first_day_data=jsonData['first_day_data'].toDouble();
//         current_day_data=jsonData['current_day_data'].toDouble();
//         get_percentile_graph=jsonData['get_percentile_graph'].toDouble();
//         get_ideal_graph=jsonData['get_ideal_graph'].toDouble();
//         // _datagraph = List<Map<String, dynamic>>.from(jsonData['data']);
//         no_of_fatigue_test = no_of_fatigue.toString();
//         no_of_eye_test = no_of_eye_.toString();
//         eye_health_score = eye_hscore.toString();
//       });
//
//       // if (responseData.containsKey('status') && responseData['status']) {
//       //   if (responseData.containsKey('first_day_data') &&
//       //       responseData['first_day_data'].containsKey('value')) {
//       //     List<dynamic> firstDayValue = responseData['first_day_data']['value'];
//       //     firstTestgraphData
//       //         .addAll(firstDayValue.map((value) => value.toDouble()));
//       //   }
//       //   if (responseData.containsKey('current_day_data') &&
//       //       responseData['current_day_data'].containsKey('value')) {
//       //     List<dynamic> currentDayValue =
//       //     responseData['current_day_data']['value'];
//       //     todaygraphData
//       //         .addAll(currentDayValue.map((value) => value.toDouble()));
//       //   }
//       //   if (responseData.containsKey('get_percentile_graph')) {
//       //     List<dynamic> population =
//       //     List<dynamic>.from(jsonData['get_percentile_graph']);
//       //
//       //     populationTestgraphData
//       //         .addAll(population.map((value) => value.toDouble()));
//       //   }
//       //   if (responseData.containsKey('get_ideal_graph')) {
//       //     List<dynamic> ideal = List<dynamic>.from(jsonData['get_ideal_graph']);
//       //
//       //     idealTestgraphData.addAll(ideal.map((value) => value.toDouble()));
//       //   }
//       // }
//       print("fffffffffffffff$todaygraphData");
//       // setState(() {
//       //   if (firstTestgraphData.isNotEmpty) {
//       //     chartData = <_ChartData>[
//       //       _ChartData('6 AM', firstTestgraphData[0], idealTestgraphData[0],
//       //           populationTestgraphData[0], todaygraphData[0]),
//       //       _ChartData('9 AM', firstTestgraphData[1], idealTestgraphData[1],
//       //           populationTestgraphData[1], todaygraphData[1]),
//       //       _ChartData('12 PM', firstTestgraphData[2], idealTestgraphData[2],
//       //           populationTestgraphData[2], todaygraphData[2]),
//       //       _ChartData('3 PM', firstTestgraphData[3], idealTestgraphData[3],
//       //           populationTestgraphData[3], todaygraphData[3]),
//       //       _ChartData('6 PM', firstTestgraphData[4], idealTestgraphData[4],
//       //           populationTestgraphData[4], todaygraphData[4]),
//       //       _ChartData('9 PM', firstTestgraphData[5], idealTestgraphData[5],
//       //           populationTestgraphData[5], todaygraphData[5]),
//       //       _ChartData('12 AM', firstTestgraphData[6], idealTestgraphData[6],
//       //           populationTestgraphData[6], todaygraphData[6]),
//       //     ];
//       //   } else {
//       //     chartData2 = <_ChartData2>[
//       //       _ChartData2(
//       //           '6 AM', idealTestgraphData[0], populationTestgraphData[0]),
//       //       _ChartData2(
//       //           '9 AM', idealTestgraphData[1], populationTestgraphData[1]),
//       //       _ChartData2(
//       //           '12 PM', idealTestgraphData[2], populationTestgraphData[2]),
//       //       _ChartData2(
//       //           '3 PM', idealTestgraphData[3], populationTestgraphData[3]),
//       //       _ChartData2(
//       //         '6 PM',
//       //         idealTestgraphData[4],
//       //         populationTestgraphData[4],
//       //       ),
//       //       _ChartData2(
//       //           '9 PM', idealTestgraphData[5], populationTestgraphData[5]),
//       //       _ChartData2(
//       //           '12 AM', idealTestgraphData[6], populationTestgraphData[6])
//       //     ];
//       //   }
//       // });
//
//       count = jsonData['no_of_eye_test'];
//       isLoading1 = false;
//       // return data
//       //     .map((item) => double.parse(item['value'].toString()))
//       //     .toList();
//     } else if (response.statusCode == 401) {
//       Fluttertoast.showToast(msg: "Session Expired");
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => SignIn()),
//       );
//     } else {
//       print(response.body);
//     }
//     // } catch (e) {
//     //   // _progressDialog!.hide();
//     //
//     //   print("exception---:$e");
//     // }
//     // throw Exception(Exception);
//   }
// }
//
//
//
// class MainScreen extends StatelessWidget {
//   const MainScreen({super.key, this.useRouter = false});
//
//   final bool useRouter;
//
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(title: const Text("Tab Main Screen")),
//     backgroundColor: Colors.indigo,
//     body: SingleChildScrollView(
//
//   child: Column(
//   crossAxisAlignment: CrossAxisAlignment.stretch,
//     children: <Widget>[
//       Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: CarouselSlider(
//           items: [
//             //1st Image of Slider
//             Container(
//               margin: EdgeInsets.all(6.0),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8.0),
//                 image: DecorationImage(
//                   image: AssetImage('assets/slider1.png'),//NetworkImage("ADD IMAGE URL HERE"),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//
//             //2nd Image of Slider
//             Container(
//               margin: EdgeInsets.all(6.0),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8.0),
//                 image: DecorationImage(
//                   image: AssetImage('assets/slider2.png'),//NetworkImage("ADD IMAGE URL HERE"),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//
//             //3rd Image of Slider
//             Container(
//               margin: EdgeInsets.all(6.0),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8.0),
//                 image: DecorationImage(
//                   image: AssetImage('assets/slider3.png'),//NetworkImage("ADD IMAGE URL HERE"),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//
//             //4th Image of Slider
//             Container(
//               margin: EdgeInsets.all(6.0),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8.0),
//                 image: DecorationImage(
//                   image: AssetImage('assets/slider1.png'),//NetworkImage("ADD IMAGE URL HERE"),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//
//             //5th Image of Slider
//             Container(
//               margin: EdgeInsets.all(6.0),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8.0),
//                 image: DecorationImage(
//                   image: AssetImage('assets/slider2.png'),//NetworkImage("ADD IMAGE URL HERE"),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//
//           ],
//
//           //Slider Container properties
//           options: CarouselOptions(
//             height: 180.0,
//             enlargeCenterPage: true,
//             autoPlay: true,
//             aspectRatio: 16 / 9,
//             autoPlayCurve: Curves.fastOutSlowIn,
//             enableInfiniteScroll: true,
//             autoPlayAnimationDuration: Duration(milliseconds: 500),
//             viewportFraction: 0.8,
//           ),
//         ),
//       ),
//       SizedBox(height: 10,),
//       Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 5),
//         child: GestureDetector(
//           onTap: () {
//             checkActivePlan('eyeTest');
//             /*   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => AddCustomerPage()),
//                   );*/
//           },
//           child: Image.asset('assets/digital_eye_exam.png',),
//         ),
//       ),
//       Padding(
//         padding:
//         const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
//         child: GestureDetector(
//           onTap: () {
//             // sendcustomerDetails(context);
//             checkActivePlan('fatigue');
//           },
//           child: Image.asset('assets/eyeFatigueTest.png'),
//         ),
//       ),
//       SizedBox(height: 10,),
//       Row(
//         children: [
//           const Padding(
//             padding: EdgeInsets.fromLTRB(16.0, 10, 0, 10),
//             child: Text(
//               'EYE HEALTH OVERVIEW', // Display formatted current date
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Spacer(),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 18.0),
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute<void>(
//                     builder: (context) => const ExampleAlarmHomeScreen(),
//                   ),
//                 );
//               },
//               child:Icon(
//                 Icons.alarm, // Replace with the alarm icon from Icons class
//                 size: 33, // Adjust the size of the icon as needed
//                 color: Colors.blue, // Adjust the color of the icon as needed
//               ),),
//           ),
//         ],
//       ),
//
//       Container(
//         color: Colors.white,
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 1),
//           child: Container(
//             // color: Colors.white,
//             width: MediaQuery.of(context).size.width,
//             child: Card(
//               color: Colors.white,
//               elevation: 0.2,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // if (chartData != null) ...{
//                   // Center(
//                   //   child: Container(
//                   //     color: Colors.white,
//                   //     child: _buildVerticalSplineChart(),
//                   //   ),
//                   // ),
//                   // SizedBox(height: 10),
//                   // Row(
//                   //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   //   children: [
//                   //     _buildColorDescription(Colors.black, 'First Test'),
//                   //     _buildColorDescription(Colors.green, 'Ideal'),
//                   //     _buildColorDescription(Colors.orange, 'Percentile'),
//                   //     _buildColorDescription(Colors.blue, 'User avg'),
//                   //   ],
//                   // ),
//                   Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         DotWithLabel(index: 0, label: 'Ideal Score',point:get_ideal_graph.toDouble(), ),
//                         Divider(
//                           height: 5,
//                           thickness: 0.5,
//                           color: Colors.grey[400],
//                           indent: 20,
//                           endIndent: 20,
//                         ),
//                         SizedBox(height: 7,),
//                         DotWithLabel(index: 1, label: 'Percentile Score of the population',point:get_percentile_graph.toDouble(),),
//                         Divider(
//                           height: 5,
//                           thickness: 0.5,
//                           color: Colors.grey[400],
//                           indent: 20,
//                           endIndent: 20,
//                         ),
//                         SizedBox(height: 7,),
//
//                         DotWithLabel( index:2,label: 'Your Avg. Score',point:current_day_data.toDouble(),),
//                         Divider(
//                           height: 5,
//                           thickness: 0.5,
//                           color: Colors.grey[400],
//                           indent: 20,
//                           endIndent: 20,
//                         ),
//                         SizedBox(height: 7,),
//
//                         DotWithLabel(index: 3, label: 'Your First Score',point:first_day_data.toDouble(),),//color: Colors.black,
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 20,),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(5.0),
//                           child: Container(
//                             width: 10,
//                             height: 10,
//                             decoration: BoxDecoration(
//                               color: Colors.background, // Adjust color as needed
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             'Score 10 indicates - You have Perfect Eyes',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.background, // Adjust text color as needed
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   SizedBox(height: 10,),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(6.0),
//                           child: Container(
//                             width: 10,
//                             height: 10,
//                             decoration: BoxDecoration(
//                               color: Colors.redAccent, // Adjust color as needed
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             'Score 3 indicates - Your eyes need Urgent attention',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.redAccent, // Adjust text color as needed
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//
//
//
//
//
//
//
//                   if   (count==0)...{
//                     SizedBox(height: 10),
//
//                     Padding(
//                       padding: EdgeInsets.fromLTRB(16.0, 10, 0, 0),
//                       child: Text(
//                         'Get your first test done now and start tracking your eye health.', // Display formatted current date
//                         style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.black),
//                       ),
//                     ),
//                     SizedBox(height: 9),
//                     Center(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: ElevatedButton(
//                           onPressed: () {
//
//                             requestPermission();
//
//                             // Navigator.push(
//                             // context,
//                             // MaterialPageRoute(
//                             // builder: (context) => EyeFatigueSelfieScreen()),
//                             // );
//                           },
//                           child: Text('Start Test Now'),
//                           style: ElevatedButton.styleFrom(
//                             minimumSize: Size(200, 45),
//                             foregroundColor: Colors.white,
//                             backgroundColor: Colors.bluebutton,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(25),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     // SizedBox(height: 30),
//                     // Center(
//                     //   child: Column(
//                     //     mainAxisAlignment: MainAxisAlignment.center,
//                     //     children: <Widget>[
//                     //       SizedBox(height: 30),
//                     //       Image.asset(
//                     //         'assets/error.png', // Replace with your image path
//                     //         width: 200, // Adjust width as needed
//                     //         height: 250, // Adjust height as needed
//                     //       ),
//                     //       SizedBox(height: 20), // Adjust spacing between image and text
//                     //
//                     //       Padding(
//                     //         padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                     //         child: Text(
//                     //           'No Reports to Show',
//                     //           textAlign: TextAlign.center,
//                     //           style: TextStyle(
//                     //             fontSize: 16,
//                     //             color: Colors.black,
//                     //           ),
//                     //         ),
//                     //       ),
//                     //     ],
//                     //   ),
//                     // ),
//                     // SizedBox(height: 30),
//
//                   },
//
//
//                   // },
//
//
//                   SizedBox(height: 29),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//
//       SizedBox(
//         height: 8,),
//
//       Padding(
//         padding: EdgeInsets.fromLTRB(16.0, 10, 0, 0),
//         child: Text(
//           'YOU HAVE TESTED SO FAR', // Display formatted current date
//           style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.black),
//         ),
//       ),
//       SizedBox(
//         height: 24,),
//
//       Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10),
//         child: SizedBox(
//
//           height: 180, // Adjust height as needed
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               Expanded(
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     image: DecorationImage(
//                       image: AssetImage('assets/interview.png'),
//                       // Replace with your image asset
//                       fit: BoxFit.cover, // Ensure the image covers the entire container
//                     ),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 28),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Text(
//                           no_of_eye_test ?? "0",
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const Padding(
//                         padding: EdgeInsets.symmetric(vertical: 5.0),
//                         child: Text(
//                           'Eye Test',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     image: DecorationImage(
//                       image: AssetImage('assets/eye_bg.png'),
//                       // Replace with your image asset
//                       fit: BoxFit.cover, // Ensure the image covers the entire container
//                     ),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 28),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 12.0, horizontal: 8.0),
//                         child: Text(
//                           no_of_fatigue_test ?? "0",
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const Padding(
//                         padding: EdgeInsets.symmetric(
//                             vertical: 5.0, horizontal: 4.0),
//                         child: Text(
//                           'Eye Fatigue Test',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//
//       const SizedBox(height: 19),
//
//     ],
//   ),
//   ),
//
//   );
// }
//
// class DotWithLabel extends StatelessWidget {
//   // final Color color;
//   final int index;
//
//   final String label;
//   final double point;
//
//   const DotWithLabel({
//     Key? key,
//     // required this.color,
//     required this.index,
//
//     required this.label,
//     required this.point,
//
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//
//     double screenWidth = MediaQuery.of(context).size.width;
//
//     return Container(
//       width: screenWidth, // Ensure the container spans the full width of the screen
//       padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//       child: Builder(
//         builder: (context) {
//           Color textColor = _getTextColor(index);
//
//           return Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: <Widget>[
//               // Container(
//               //   width: 14.0,
//               //   height: 15.0,
//               //   decoration: BoxDecoration(
//               //     shape: BoxShape.circle,
//               //     color: color,
//               //   ),
//               // ),
//               //
//               // SizedBox(width: MediaQuery.of(context).size.width/4), // Adjust spacing as needed
//               Expanded(
//                 child: Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               SizedBox(width: 20), // Adjust spacing as needed
//               Text(
//                 '$point',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: textColor,
//                   fontWeight: FontWeight.w600,
//
//                 ),
//               ),
//             ],
//           );
//         }
//       ),
//     );
//   }
//
//
//   Color _getTextColor(int index) {
//     // Define your logic to determine text color based on point value
//     if (index == 0) {
//       return Colors.green; // Example condition for green color
//     } else if (index == 1) {
//       return Colors.orange; // Example condition for orange color
//     }
//     else if (index == 2) {
//       return Colors.blue; // Example condition for orange color
//     }else {
//       return Colors.background; // Example condition for red color
//     }
//   }
// }
//
//
//
// class _ChartData {
//   _ChartData(this.x, this.y, this.y2, this.y3, this.y4);
//   final String x;
//   final double y;
//   final double y2;
//   final double y3;
//   final double y4;
// }
//
// class _ChartData2 {
//   _ChartData2(this.x, this.y, this.y2);
//   final String x;
//   final double y;
//   final double y2;
// }
//
// class setReminder extends StatefulWidget {
//   @override
//   State<setReminder> createState() => ReminderState();
// }
//
// class ReminderState extends State<setReminder> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         home: Scaffold(
//             // appBar: AppBar(
//             //   title: const Text(''),
//             // ),
//             body: Builder(builder: (context) {
//               return const Center();
//             })));
//   }
// }
//
// class MyClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     var path = Path();
//     path.lineTo(0, size.height - 50);
//     path.quadraticBezierTo(
//         size.width / 2, size.height, size.width, size.height - 50);
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }
//
// class BottomDialog extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16.0, 16, 16, 8),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Digital Eye Exam',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ],
//           ),
//           Divider(thickness: 1, color: Colors.grey.shade500),
//           const SizedBox(height: 18),
//           Card(
//             child: GestureDetector(
//               onTap: () {
//                 sendcustomerDetails(context, true);
//               },
//               child: Image.asset('assets/test_for_myself_img.png'),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 12.0),
//             child: Card(
//               child: GestureDetector(
//                 onTap: () {
//                   Navigator.pop(context);
//                   showModalBottomSheet(
//                     context: context,
//                     builder: (context) => OtherDetailsBottomSheet(),
//                   );
//                 },
//                 child: Image.asset('assets/test_for_someone_img.png'),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> sendcustomerDetails(BuildContext context, bool isSelf,
//       {String? name, String? age}) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String authToken = prefs.getString('access_token') ?? '';
//     final String apiUrl = '${Api.baseurl}/api/eye/add-customer';
//
//     Map<String, String> headers = {
//       'Authorization': 'Bearer $authToken',
//       'Content-Type': 'application/json',
//     };
//
//     var body = json.encode({
//       'is_self': isSelf,
//       if (!isSelf) 'name': name,
//       if (!isSelf) 'age': age,
//     });
//
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: headers,
//         body: body,
//       );
//
//       print('API Response: ${response.statusCode} - ${response.body}');
//
//       if (response.statusCode == 200) {
//         Map<String, dynamic> jsonResponse = jsonDecode(response.body);
//         if (jsonResponse.containsKey('customer_id')) {
//           String customerId = jsonResponse['customer_id'];
//
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           prefs.setString('customer_id', customerId);
//
//           print('Customer ID: $customerId');
//
//           // Check if the context is still mounted before navigating
//           if (context.mounted) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => GiveInfo()),
//             );
//           }
//         } else {
//           print('Customer ID not found in response.');
//         }
//       } else {
//         print('API call failed with status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Exception: $e');
//     }
//   }
// }
//
// class OtherDetailsBottomSheet extends StatefulWidget {
//   @override
//   _OtherDetailsBottomSheetState createState() =>
//       _OtherDetailsBottomSheetState();
// }
//
// class _OtherDetailsBottomSheetState extends State<OtherDetailsBottomSheet> {
//   Future<void> sendcustomerDetails(BuildContext context, bool isSelf,
//       {String? name, String? age}) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String authToken = prefs.getString('access_token') ?? '';
//     final String apiUrl = '${Api.baseurl}/api/eye/add-customer';
//
//     Map<String, String> headers = {
//       'Authorization': 'Bearer $authToken',
//       'Content-Type': 'application/json',
//     };
//
//     var body = json.encode({
//       'is_self': isSelf,
//       if (!isSelf) 'name': name,
//       if (!isSelf) 'age': age,
//     });
//
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: headers,
//         body: body,
//       );
//
//       print('API Response: ${response.statusCode} - ${response.body}');
//
//       if (response.statusCode == 200) {
//         Map<String, dynamic> jsonResponse = jsonDecode(response.body);
//         if (jsonResponse.containsKey('customer_id')) {
//           String customerId = jsonResponse['customer_id'];
//
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           prefs.setString('customer_id', customerId);
//
//           print('Customer ID: $customerId');
//
//           // Navigate to GiveInfo screen
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => GiveInfo()),
//           );
//         } else {
//           print('Customer ID not found in response.');
//         }
//       } else {
//         print('API call failed with status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Exception: $e');
//     }
//   }
//
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _ageController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true, // Adjusts layout when keyboard appears
//
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           physics: const ScrollPhysics(),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Test For Someone Else',
//                       style:
//                       TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//                 Divider(thickness: 1.5, color: Colors.grey.shade400),
//                 const SizedBox(height: 20),
//                 SizedBox(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 10.0, vertical: 1),
//                     child: TextFormField(
//                       controller: _nameController,
//                       textInputAction: TextInputAction.next,
//                       decoration: InputDecoration(
//                         labelText: 'Full Name',
//                         labelStyle: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.black,
//                           fontWeight: FontWeight.w100,
//                         ),
//                         hintText: 'Enter Full Name',
//                         hintStyle: const TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey,
//                           fontWeight: FontWeight.w400,
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(
//                               27.0), // Add circular border
//                         ),
//                         floatingLabelBehavior: FloatingLabelBehavior.always,
//                       ),
//                       inputFormatters: [
//                         LengthLimitingTextInputFormatter(30),
//                       ],
//                       style: const TextStyle(
//                           fontSize: 15, fontWeight: FontWeight.w400),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter a full name';
//                         }
//                         final nameRegExp = RegExp(r'^[a-zA-Z\s]+$');
//                         if (!nameRegExp.hasMatch(value)) {
//                           return 'Name must contain only alphabets';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 SizedBox(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 10.0, vertical: 1),
//                     child: TextFormField(
//                       controller: _ageController,
//                       textInputAction: TextInputAction.next,
//                       keyboardType: TextInputType.number,
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly,
//                         LengthLimitingTextInputFormatter(3),
//                       ],
//                       decoration: InputDecoration(
//                         labelText: 'Age',
//                         labelStyle: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.black,
//                           fontWeight: FontWeight.w400,
//                         ),
//                         hintText: 'Age',
//                         hintStyle: const TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey,
//                           fontWeight: FontWeight.w400,
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(
//                               27.0), // Add circular border
//                         ),
//                         floatingLabelBehavior: FloatingLabelBehavior.always,
//                       ),
//                       style: const TextStyle(
//                           fontSize: 15, fontWeight: FontWeight.w400),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter an age';
//                         }
//                         int? age = int.tryParse(value);
//                         if (age == null || age < 10 || age > 70) {
//                           return 'Age must be between 10 and 70';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         sendcustomerDetails(context, false,
//                             name: _nameController.text,
//                             age: _ageController.text);
//                       }
//                     },
//                     child: const Text('Submit'),
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: const Size(350, 50),
//                       foregroundColor: Colors.white,
//                       backgroundColor: Colors.bluebutton,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class ExampleAlarmRingScreen extends StatelessWidget {
//   const ExampleAlarmRingScreen({required this.alarmSettings, super.key});
//
//   final AlarmSettings alarmSettings;
// //TODO Data Change Alarm Design
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Text(
//               'Its a reminder , please do eye test',
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
import 'package:project_new/alarm/demo_main.dart';

import 'package:project_new/digitalEyeTest/testScreen.dart';
import 'package:project_new/eyeFatigueTest/EyeFatigueSelfieScreen.dart';
import 'package:project_new/sign_up.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'Custom_navbar/bottom_navbar.dart';
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
  double first_day_data=0.0;double current_day_data=0.0;double get_percentile_graph=0.0;double get_ideal_graph=0.0;


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
  String eye_health_score = "";
  String fullname = "";
  String no_of_fatigue_test = "0";
  dynamic selectedPlanId = '';
  bool isActivePlan = false;
  bool isLoading1 = true;
  int? isReadFalseCount = 0;
  late Timer? _timer;

  // Define selectedDate within the _CalendarButtonState class
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey();

  // late List<AlarmSettings> alarms;
  List<Map<String, dynamic>>? _datagraph;

  // static StreamSubscription<AlarmSettings>? subscription;
  late DateTime _fromDate;
  late DateTime _toDate;

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _fromDate : _toDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isFromDate ? _fromDate : _toDate)) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  void _startTimer() {
    const tenSeconds = Duration(seconds: 10);
    _timer = Timer.periodic(tenSeconds, (timer) {
      // Make your API call here
      getNotifactionCount();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    //subscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getGraph();
    /*   if (Alarm.android) {
      checkAndroidNotificationPermission();
      checkAndroidScheduleExactAlarmPermission();
    }
    loadAlarms();
    getGraph();
    _startTimer();*/

    // subscription ??= Alarm.ringStream.stream.listen(navigateToRingScreen);
    Future.delayed(const Duration(seconds: 1), () {})
        .then((_) => getNotifactionCount())
        .then((_) {
      if (mounted) {
        setState(() {});
      }
      _timer = Timer.periodic(Duration(seconds: 10), (timer) {
        getNotifactionCount();
      });
    });
  }

  Future<void> checkAndroidNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      final res = await Permission.notification.request();
    }
  }

  Future<void> getNotifactionCount() async {
    try {
      String userToken = '';
      var sharedPref = await SharedPreferences.getInstance();
      userToken = sharedPref.getString("access_token") ?? '';
      String url = "${ApiProvider.baseUrl}/api/user_notification";
      print("URL: $url");
      print("userToken: $userToken");
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
    } on DioError catch (e) {
      if (e.response != null || e.response!.statusCode == 401) {
        // Handle 401 error

        Fluttertoast.showToast(msg: "Session Expired");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      } else {
        // Handle other Dio errors
        print("DioError: ${e.error}");
      }
    } catch (e) {
      // Handle other exceptions
      print("Exception---: $e");
    }
  }

/*
  Future<void> loadAlarms() async {
    var sharedPref = await SharedPreferences.getInstance();
    edited = sharedPref.getBool("edited") ?? false;
    if (!edited) {
      alarms = Alarm.getAlarms();
      alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);

      if (alarms.isNotEmpty) {
        for (int i = 0; i < alarms.length; i++) {
          await Alarm.stop(alarms[i].id);
        }
        alarms.clear();
      }

      if (alarms.isEmpty) {
        DateTime now = DateTime.now();

        // Define alarm times for today
        List<DateTime> todayAlarmTimes = [
          DateTime(now.year, now.month, now.day, 6),
          DateTime(now.year, now.month, now.day, 9),
          DateTime(now.year, now.month, now.day, 12),
          DateTime(now.year, now.month, now.day, 15),
          DateTime(now.year, now.month, now.day, 18),
          DateTime(now.year, now.month, now.day, 21),
          DateTime(now.year, now.month, now.day + 1, 0),
        ];

        // Define alarm times for tomorrow
        List<DateTime> tomorrowAlarmTimes = todayAlarmTimes.map((alarmTime) {
          return alarmTime.add(const Duration(days: 1));
        }).toList();

        for (int i = 0; i < 7; i++) {
          DateTime alarmTime;
          if (todayAlarmTimes[i].isBefore(now)) {
            // Set alarm for tomorrow
            alarmTime = tomorrowAlarmTimes[i];
          } else {
            // Set alarm for today
            alarmTime = todayAlarmTimes[i];
          }

          print("Alarm Time $alarmTime");
          saveAlarm(i, alarmTime);
        }
      }
    }
  }

  AlarmSettings buildAlarmSettings(int i, DateTime duration) {
    final id = DateTime.now().millisecondsSinceEpoch % 10000 + i;
    final alarmSettings = AlarmSettings(
        id: id,
        dateTime: duration,
        loopAudio: true,
        vibrate: true,
        volume: null,
        assetAudioPath: 'assets/marimba.mp3',
        notificationTitle: 'Test Reminder',
        notificationBody: 'Do your eye test',
        isAlarmOn: true);
    return alarmSettings;
  }

  Future<void> saveAlarm(int i, DateTime duration) async {
    await Alarm.set(alarmSettings: buildAlarmSettings(i, duration));
    alarms = Alarm.getAlarms();
    alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    SharedPref.saveAlarmsToPrefs(alarms);
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) =>
            ExampleAlarmRingScreen(alarmSettings: alarmSettings),
      ),
    );
    loadAlarms();
  }
*/
  Future<void> checkAndroidExternalStoragePermission() async {
    final status = await Permission.storage.status;
    if (status.isDenied) {
      final res = await Permission.storage.request();
    }
  }

  Future<void> checkAndroidScheduleExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.status;
    if (status.isDenied) {
      final res = await Permission.scheduleExactAlarm.request();
    }
  }

/*
  Future<void> navigateToAlarmScreen(AlarmSettings? settings) async {
    final res = await showModalBottomSheet<bool?>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: ExampleAlarmEditScreen(alarmSettings: settings),
        );
      },
    );

    if (res != null && res == true) loadAlarms();
  }
*/

  @override
  Widget build(BuildContext context) {
    int currentHour = DateTime.now().hour;
    // Determine the appropriate salutation based on the current hour
    String salutation = 'Welcome';
    // if (currentHour >= 0 && currentHour < 12) {
    //   salutation = 'Good morning';
    // } else if (currentHour >= 12 && currentHour < 17) {
    //   salutation = 'Good afternoon';
    // } else {
    //   salutation = 'Good evening';
    // }
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0), // Add padding
        child: ClipOval(
          child: Material(
            // color: Colors.background,
            color: Colors.white70.withOpacity(0.9), // Background color
            elevation: 4.0, // Shadow
            child: InkWell(
              onTap: () {},
              child: SizedBox(
                width: 53.0, // Width of the FloatingActionButton
                height: 50.0, // Height of the FloatingActionButton
                child: Center(
                  child: Padding(
                    padding:
                    const EdgeInsets.all(8.0), // Add padding for the icon
                    child: Image.asset(
                      "assets/home_icon.jpeg",
                      width: 27,
                      // fit: BoxFit.cover, // Uncomment if you want the image to cover the button
                      // color: Colors.grey, // Uncomment if you want to apply a color to the image
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
                  padding: const EdgeInsets.fromLTRB(8.0, 10.0, 0, 4),
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
                              eye_health_score,
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
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: CarouselSlider(
                items: [
                  //1st Image of Slider
                  Container(
                    margin: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: AssetImage('assets/slider1.png'),
                        //NetworkImage("ADD IMAGE URL HERE"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  //2nd Image of Slider
                  Container(
                    margin: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: AssetImage('assets/slider2.png'),
                        //NetworkImage("ADD IMAGE URL HERE"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  //3rd Image of Slider
                  Container(
                    margin: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: AssetImage('assets/slider3.png'),
                        //NetworkImage("ADD IMAGE URL HERE"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  //4th Image of Slider
                  Container(
                    margin: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: AssetImage('assets/slider1.png'),
                        //NetworkImage("ADD IMAGE URL HERE"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  //5th Image of Slider
                  Container(
                    margin: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: AssetImage('assets/slider2.png'),
                        //NetworkImage("ADD IMAGE URL HERE"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],

                //Slider Container properties
                options: CarouselOptions(
                  height: 190.0,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: Duration(milliseconds: 500),
                  viewportFraction: 0.8,
                ),
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
            SizedBox(height: 10,),
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
                      /* Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => const ExampleAlarmHomeScreen(),
                          ),
                        );*/
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
            // Container(
            //   color: Colors.white,
            //   child: Padding(
            //     padding:
            //     const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1),
            //     child: Container(
            //       color: Colors.white,
            //       width: MediaQuery.of(context).size.width,
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           if (chartData != null) ...{
            //             Center(
            //               child: Card(
            //                 color: Colors.white,
            //                 elevation: 0.5,
            //                 child: isLoading1
            //                     ? const Center(
            //                   child: CircularProgressIndicator(
            //                     color: Colors.blue,
            //                   ),
            //                 )
            //                     :
            //                 Center(
            //                   child: Column(
            //                     mainAxisAlignment: MainAxisAlignment.center,
            //                     children: <Widget>[
            //                       DotWithLabel(index: 0, label: 'Ideal Score',point:8),
            //                       Divider(
            //                         height: 5,
            //                         thickness: 0.5,
            //                         color: Colors.grey[400],
            //                         indent: 20,
            //                         endIndent: 20,
            //                       ),
            //                       SizedBox(height: 5,),
            //                       DotWithLabel(index: 1, label: 'Percentile Score of the population',point:6),
            //                       Divider(
            //                         height: 5,
            //                         thickness: 0.5,
            //                         color: Colors.grey[400],
            //                         indent: 20,
            //                         endIndent: 20,
            //                       ),
            //                       SizedBox(height: 5,),
            //
            //                       DotWithLabel( index:2,label: 'Your Avg. Score',point:5),
            //                       Divider(
            //                         height: 5,
            //                         thickness: 0.5,
            //                         color: Colors.grey[400],
            //                         indent: 20,
            //                         endIndent: 20,
            //                       ),
            //                       SizedBox(height: 5,),
            //
            //                       DotWithLabel(index: 3, label: 'Your First Score',point:4),//color: Colors.black,
            //                     ],
            //                   ),
            //                 ),
            //                 // _buildVerticalSplineChart(),
            //               ),
            //             ),
            //             SizedBox(height: 20,),
            //             Padding(
            //               padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1),
            //               child: Row(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Padding(
            //                     padding: const EdgeInsets.all(5.0),
            //                     child: Container(
            //                       width: 10,
            //                       height: 10,
            //                       decoration: BoxDecoration(
            //                         color: Colors.background, // Adjust color as needed
            //                         shape: BoxShape.circle,
            //                       ),
            //                     ),
            //                   ),
            //                   SizedBox(width: 8),
            //                   Expanded(
            //                     child: Text(
            //                       'Score 10 indicates - You have Perfect Eyes',
            //                       style: TextStyle(
            //                         fontSize: 12,
            //                         fontWeight: FontWeight.w600,
            //                         color: Colors.background, // Adjust text color as needed
            //                       ),
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //
            //             SizedBox(height: 10,),
            //             Padding(
            //               padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1),
            //               child: Row(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Padding(
            //                     padding: const EdgeInsets.all(6.0),
            //                     child: Container(
            //                       width: 10,
            //                       height: 10,
            //                       decoration: BoxDecoration(
            //                         color: Colors.redAccent, // Adjust color as needed
            //                         shape: BoxShape.circle,
            //                       ),
            //                     ),
            //                   ),
            //                   SizedBox(width: 8),
            //                   Expanded(
            //                     child: Text(
            //                       'Score 3 indicates - Your eyes need Urgent attention',
            //                       style: TextStyle(
            //                         fontSize: 12,
            //                         fontWeight: FontWeight.w600,
            //                         color: Colors.redAccent, // Adjust text color as needed
            //                       ),
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //
            //
            //
            //
            //
            //
            //
            //             // const SizedBox(
            //             //     height:
            //             //     10), // Adjust spacing between chart and color descriptions
            //
            //             // Color descriptions
            //             // Center(
            //             //   child: SingleChildScrollView(
            //             //     scrollDirection: Axis.horizontal,
            //             //     child: Row(
            //             //       children: [
            //             //         const SizedBox(width: 9),
            //             //         _buildColorDescription(
            //             //             Colors.green, 'Ideal Score'),
            //             //         const SizedBox(width: 9),
            //             //         _buildColorDescription(
            //             //             Colors.blue, 'User Average Score'),
            //             //         const SizedBox(width: 9),
            //             //       ],
            //             //     ),
            //             //   ),
            //             // )
            //           },
            //           if (count == 0 && isLoading1 == false) ...{
            //             const SizedBox(height: 10),
            //             const Padding(
            //               padding: EdgeInsets.fromLTRB(16.0, 10, 0, 0),
            //               child: Text(
            //                 'Get your first test done now and start tracking your eye health.',
            //                 // Display formatted current date
            //                 style:
            //                 TextStyle(fontSize: 14, color: Colors.black),
            //               ),
            //             ),
            //             const SizedBox(height: 9),
            //             Center(
            //               child: Padding(
            //                 padding: const EdgeInsets.all(8.0),
            //                 child: ElevatedButton(
            //                   onPressed: () {
            //                     requestPermission();
            //                     // Navigator.push(
            //                     //   context,
            //                     //   MaterialPageRoute(
            //                     //       builder: (context) =>
            //                     //           EyeFatigueSelfieScreen()),
            //                     // );
            //                   },
            //                   child: const Text('Start Test Now'),
            //                   style: ElevatedButton.styleFrom(
            //                     minimumSize: const Size(200, 45),
            //                     foregroundColor: Colors.white,
            //                     backgroundColor: Colors.bluebutton,
            //                     shape: RoundedRectangleBorder(
            //                       borderRadius: BorderRadius.circular(25),
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           },
            //           const SizedBox(height: 19),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 1),
                child: Container(
                  // color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    color: Colors.white,
                    elevation: 0.2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // if (chartData != null) ...{
                        // Center(
                        //   child: Container(
                        //     color: Colors.white,
                        //     child: _buildVerticalSplineChart(),
                        //   ),
                        // ),
                        // SizedBox(height: 10),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //   children: [
                        //     _buildColorDescription(Colors.black, 'First Test'),
                        //     _buildColorDescription(Colors.green, 'Ideal'),
                        //     _buildColorDescription(Colors.orange, 'Percentile'),
                        //     _buildColorDescription(Colors.blue, 'User avg'),
                        //   ],
                        // ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              DotWithLabel(index: 0, label: 'Ideal Score',point:get_ideal_graph.toDouble(), ),
                              Divider(
                                height: 5,
                                thickness: 0.5,
                                color: Colors.grey[400],
                                indent: 20,
                                endIndent: 20,
                              ),
                              SizedBox(height: 7,),
                              DotWithLabel(index: 1, label: 'Percentile Score of the population',point:get_percentile_graph.toDouble(),),
                              Divider(
                                height: 5,
                                thickness: 0.5,
                                color: Colors.grey[400],
                                indent: 20,
                                endIndent: 20,
                              ),
                              SizedBox(height: 7,),

                                  DotWithLabel( index:2,label: 'Your Avg. Score',point:5),
                                  Divider(
                                    height: 5,
                                    thickness: 0.5,
                                    color: Colors.grey[400],
                                    indent: 20,
                                    endIndent: 20,
                                  ),
                                  SizedBox(height: 5,),

                                  DotWithLabel(index: 3, label: 'Your First Score',point:4),//color: Colors.black,
                                ],
                              ),
                            ),
                            // _buildVerticalSplineChart(),
                          ),
                        ),
                        SizedBox(height: 20,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.background, // Adjust color as needed
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
                                    color: Colors.background, // Adjust text color as needed
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 10,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent, // Adjust color as needed
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
                                    color: Colors.redAccent, // Adjust text color as needed
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),








                        if   (count==0)...{
                          SizedBox(height: 10),

                          Padding(
                            padding: EdgeInsets.fromLTRB(16.0, 10, 0, 0),
                            child: Text(
                              'Get your first test done now and start tracking your eye health.', // Display formatted current date
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black),
                            ),
                          ),
                          SizedBox(height: 9),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () {

                                  requestPermission();

                                  // Navigator.push(
                                  // context,
                                  // MaterialPageRoute(
                                  // builder: (context) => EyeFatigueSelfieScreen()),
                                  // );
                                },
                                child: Text('Start Test Now'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(200, 45),
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.bluebutton,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // SizedBox(height: 30),
                          // Center(
                          //   child: Column(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     children: <Widget>[
                          //       SizedBox(height: 30),
                          //       Image.asset(
                          //         'assets/error.png', // Replace with your image path
                          //         width: 200, // Adjust width as needed
                          //         height: 250, // Adjust height as needed
                          //       ),
                          //       SizedBox(height: 20), // Adjust spacing between image and text
                          //
                          //       Padding(
                          //         padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          //         child: Text(
                          //           'No Reports to Show',
                          //           textAlign: TextAlign.center,
                          //           style: TextStyle(
                          //             fontSize: 16,
                          //             color: Colors.black,
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // SizedBox(height: 30),

                        },


                        // },


                        SizedBox(height: 29),
                      ],
                    ),
                  ),
                ),
              ),
            ),      SizedBox(
              height: 8,),

             Padding(
              padding: EdgeInsets.fromLTRB(16.0, 10, 0, 0),
              child: Text(
                'You’ve Tested soo far ', // Display formatted current date
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    color: Colors.black87),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
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
                            fit: BoxFit.cover, // Ensure the image covers the entire container
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             SizedBox(height: 15),
                            Padding(
                              padding: EdgeInsets.only(left: 22.0), // Adjusted padding
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
                                  const SizedBox(height: 5), // Added SizedBox for spacing
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
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,

                          children: [
                            // Number (left top)
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0, top: 12.0),
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
                              padding: const EdgeInsets.only(left: 20.0, top: 10.0),
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
            const SizedBox(height: 15),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        currentScreen: 'HomePage',
      ),
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EyeFatigueSelfieScreen()),
        );
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
  //
  // SfCartesianChart _buildVerticalSplineChart() {
  //   return SfCartesianChart(
  //     isTransposed: false,
  //     plotAreaBorderWidth: 0,
  //     legend: const Legend(isVisible: true),
  //     primaryXAxis: const CategoryAxis(
  //       majorTickLines: MajorTickLines(size: 0),
  //       axisLine: AxisLine(width: 0.3),
  //       majorGridLines: MajorGridLines(width: 0),
  //       title: AxisTitle(text: 'time slots  (x-axis) --->'),
  //     ), // Disable vertical inner gridlines
  //
  //     primaryYAxis: const NumericAxis(
  //       minimum: 0,
  //       maximum: 11,
  //       interval: 1,
  //       labelFormat: '{value}',
  //       title: AxisTitle(
  //           text: 'eye score  (y-axis)  --->'), // Description for X axis
  //       majorGridLines: MajorGridLines(width: 0), // Hide horizontal grid lines
  //     ),
  //     series: firstTestgraphData.isNotEmpty
  //         ? _getVerticalSplineSeries()
  //         : _getVerticalSplineSeries1(),
  //     tooltipBehavior: TooltipBehavior(enable: true),
  //   );
  // }
  //
  // List<SplineSeries<_ChartData, String>> _getVerticalSplineSeries() {
  //   return <SplineSeries<_ChartData, String>>[
  //     // SplineSeries<_ChartData, String>(
  //     //     markerSettings: const MarkerSettings(isVisible: true),
  //     //     dataSource: chartData,color: Colors.black,
  //     //     xValueMapper: (_ChartData sales, _) => sales.x,
  //     //     yValueMapper: (_ChartData sales, _) => sales.y,
  //     //     name: 'Initial User Score'),
  //     SplineSeries<_ChartData, String>(
  //       markerSettings: const MarkerSettings(isVisible: true),
  //       dataSource: chartData,
  //       cardinalSplineTension: 0.5,
  //       splineType: SplineType.monotonic,
  //       name: 'Ideal Score',
  //       color: Colors.green,
  //       xValueMapper: (_ChartData sales, _) => sales.x,
  //       yValueMapper: (_ChartData sales, _) => sales.y2,
  //       emptyPointSettings: const EmptyPointSettings(
  //           mode: EmptyPointMode.gap, // Connect null points to zero
  //           color: Colors.green,
  //           borderColor: Colors.green,
  //           borderWidth:
  //           2 // Optional: Set color of the line connecting null points
  //       ),
  //     ),
  //     // SplineSeries<_ChartData, String>(
  //     //   markerSettings: const MarkerSettings(isVisible: true),
  //     //   dataSource: chartData,
  //     //   name: 'over 3.5 lac users',color:Colors.orange ,
  //     //   xValueMapper: (_ChartData sales, _) => sales.x,
  //     //   yValueMapper: (_ChartData sales, _) => sales.y3,
  //     // ),
  //
  //     SplineSeries<_ChartData, String>(
  //       markerSettings: const MarkerSettings(isVisible: true),
  //       dataSource: chartData,
  //       color: Colors.blue,
  //       cardinalSplineTension: 0.5,
  //       splineType: SplineType.monotonic,
  //       name: 'User Average Score',
  //       xValueMapper: (_ChartData sales, _) => sales.x,
  //       yValueMapper: (_ChartData sales, _) => sales.y4,
  //       emptyPointSettings: const EmptyPointSettings(
  //           mode: EmptyPointMode.zero, // Connect null points to zero
  //           color: Colors.blue,
  //           borderColor: Colors.blue,
  //           borderWidth:
  //           2 // Optional: Set color of the line connecting null points
  //       ),
  //     )
  //   ];
  // }
  //
  // List<SplineSeries<_ChartData2, String>> _getVerticalSplineSeries1() {
  //   return <SplineSeries<_ChartData2, String>>[
  //     SplineSeries<_ChartData2, String>(
  //       markerSettings: const MarkerSettings(isVisible: true),
  //       dataSource: chartData2,
  //       cardinalSplineTension: 0.5,
  //       splineType: SplineType.monotonic,
  //       name: 'Ideal Score',
  //       color: Colors.green,
  //       xValueMapper: (_ChartData2 sales, _) => sales.x,
  //       yValueMapper: (_ChartData2 sales, _) => sales.y,
  //       emptyPointSettings: const EmptyPointSettings(
  //           mode: EmptyPointMode.gap, // Connect null points to zero
  //           color: Colors.green,
  //           borderColor: Colors.green,
  //           borderWidth:
  //           2 // Optional: Set color of the line connecting null points
  //       ),
  //     ),
  //     SplineSeries<_ChartData2, String>(
  //       markerSettings: const MarkerSettings(isVisible: true),
  //       dataSource: chartData2,
  //       color: Colors.blue,
  //       cardinalSplineTension: 0.5,
  //       splineType: SplineType.monotonic,
  //       name: 'User Average Score',
  //       xValueMapper: (_ChartData2 sales, _) => sales.x,
  //       yValueMapper: (_ChartData2 sales, _) => sales.y2,
  //       emptyPointSettings: const EmptyPointSettings(
  //           mode: EmptyPointMode.zero, // Connect null points to zero
  //           color: Colors.blue,
  //           borderColor: Colors.blue,
  //           borderWidth:
  //           2 // Optional: Set color of the line connecting null points
  //       ),
  //     )
  //   ];
  // }

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
      fatigueGraphData = fatigueGraph.fromJson(responseData);

      print("graphdata===:${response.body}");

      Map<String, dynamic> jsonData = jsonDecode(response.body);
      // List<dynamic> data = jsonData['data'];
      fullname = jsonData['name'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', fullname);
      int no_of_fatigue = jsonData['no_of_fatigue_test'];
      int no_of_eye_ = jsonData['no_of_eye_test'];
      dynamic eye_hscore = jsonData['eye_health_score'];
      setState(() {
        first_day_data=jsonData['first_day_data'].toDouble();
        current_day_data=jsonData['current_day_data'].toDouble();
        get_percentile_graph=jsonData['get_percentile_graph'].toDouble();
        get_ideal_graph=jsonData['get_ideal_graph'].toDouble();
        // _datagraph = List<Map<String, dynamic>>.from(jsonData['data']);
        no_of_fatigue_test = no_of_fatigue.toString();
        no_of_eye_test = no_of_eye_.toString();
        eye_health_score = eye_hscore.toString();
      });

      // if (responseData.containsKey('status') && responseData['status']) {
      //   if (responseData.containsKey('first_day_data') &&
      //       responseData['first_day_data'].containsKey('value')) {
      //     List<dynamic> firstDayValue = responseData['first_day_data']['value'];
      //     firstTestgraphData
      //         .addAll(firstDayValue.map((value) => value.toDouble()));
      //   }
      //   if (responseData.containsKey('current_day_data') &&
      //       responseData['current_day_data'].containsKey('value')) {
      //     List<dynamic> currentDayValue =
      //     responseData['current_day_data']['value'];
      //     todaygraphData
      //         .addAll(currentDayValue.map((value) => value.toDouble()));
      //   }
      //   if (responseData.containsKey('get_percentile_graph')) {
      //     List<dynamic> population =
      //     List<dynamic>.from(jsonData['get_percentile_graph']);
      //
      //     populationTestgraphData
      //         .addAll(population.map((value) => value.toDouble()));
      //   }
      //   if (responseData.containsKey('get_ideal_graph')) {
      //     List<dynamic> ideal = List<dynamic>.from(jsonData['get_ideal_graph']);
      //
      //     idealTestgraphData.addAll(ideal.map((value) => value.toDouble()));
      //   }
      // }
      print("fffffffffffffff$todaygraphData");
      // setState(() {
      //   if (firstTestgraphData.isNotEmpty) {
      //     chartData = <_ChartData>[
      //       _ChartData('6 AM', firstTestgraphData[0], idealTestgraphData[0],
      //           populationTestgraphData[0], todaygraphData[0]),
      //       _ChartData('9 AM', firstTestgraphData[1], idealTestgraphData[1],
      //           populationTestgraphData[1], todaygraphData[1]),
      //       _ChartData('12 PM', firstTestgraphData[2], idealTestgraphData[2],
      //           populationTestgraphData[2], todaygraphData[2]),
      //       _ChartData('3 PM', firstTestgraphData[3], idealTestgraphData[3],
      //           populationTestgraphData[3], todaygraphData[3]),
      //       _ChartData('6 PM', firstTestgraphData[4], idealTestgraphData[4],
      //           populationTestgraphData[4], todaygraphData[4]),
      //       _ChartData('9 PM', firstTestgraphData[5], idealTestgraphData[5],
      //           populationTestgraphData[5], todaygraphData[5]),
      //       _ChartData('12 AM', firstTestgraphData[6], idealTestgraphData[6],
      //           populationTestgraphData[6], todaygraphData[6]),
      //     ];
      //   } else {
      //     chartData2 = <_ChartData2>[
      //       _ChartData2(
      //           '6 AM', idealTestgraphData[0], populationTestgraphData[0]),
      //       _ChartData2(
      //           '9 AM', idealTestgraphData[1], populationTestgraphData[1]),
      //       _ChartData2(
      //           '12 PM', idealTestgraphData[2], populationTestgraphData[2]),
      //       _ChartData2(
      //           '3 PM', idealTestgraphData[3], populationTestgraphData[3]),
      //       _ChartData2(
      //         '6 PM',
      //         idealTestgraphData[4],
      //         populationTestgraphData[4],
      //       ),
      //       _ChartData2(
      //           '9 PM', idealTestgraphData[5], populationTestgraphData[5]),
      //       _ChartData2(
      //           '12 AM', idealTestgraphData[6], populationTestgraphData[6])
      //     ];
      //   }
      // });

      count = jsonData['no_of_eye_test'];
      isLoading1 = false;
      // return data
      //     .map((item) => double.parse(item['value'].toString()))
      //     .toList();
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
      width: screenWidth, // Ensure the container spans the full width of the screen
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Builder(
        builder: (context) {
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
              SizedBox(width: 20), // Adjust spacing as needed
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
        }
      ),
    );
  }

  Color _getTextColor(int index) {
    // Define your logic to determine text color based on point value
    if (index == 0) {
      return Colors.green; // Example condition for green color
    } else if (index == 1) {
      return Colors.orange; // Example condition for orange color
    }
    else if (index == 2) {
      return Colors.blue; // Example condition for orange color
    }else {
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
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('customer_id')) {
          String customerId = jsonResponse['customer_id'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('customer_id', customerId);

          print('Customer ID: $customerId');

          // Check if the context is still mounted before navigating
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GiveInfo()),
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
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('customer_id')) {
          String customerId = jsonResponse['customer_id'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('customer_id', customerId);

          print('Customer ID: $customerId');

          // Navigate to GiveInfo screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GiveInfo()),
          );
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

/*
class ExampleAlarmRingScreen extends StatelessWidget {
  const ExampleAlarmRingScreen({required this.alarmSettings, super.key});

 // final AlarmSettings alarmSettings;
//TODO Data Change Alarm Design
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
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
      ),
    );
  }
}
*/
