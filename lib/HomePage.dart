import 'dart:async';
import 'dart:convert';

import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:draw_graph/models/feature.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:project_new/alarm/demo_main.dart';

import 'package:project_new/digitalEyeTest/testScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Custom_navbar/bottom_navbar.dart';
import 'api/Api.dart';
import 'api/config.dart';

import 'eyeFatigueTest/eyeFatigueTest.dart';
import 'models/fatigueGraphModel.dart';

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

class HomePageState extends State<HomePage> {
  List<double>? _data;
  List<String>? dates;
  int i = 0;
  List<Feature>? features;
  List<String>? labelX;

  List<String>? labelY;

  String _status = '';
  List<FlSpot> _value = [];
  List<FlSpot> _spots = [FlSpot(0, 0)]; // Initialize _spots as needed
  bool fatigue_left = false;
  bool fatigue_right = false;
  bool midtiredness_right = false;
  bool midtiredness_left = false;
  bool isSelected = false;
  fatigueGraph? fatigueGraphData;
  bool isLeftEyeSelected = false;
  List<double> data1 = [10, 30, 20, 40, 30]; // Sample data for line 1
  List<double> data2 = [30, 50, 60, 50, 60];
  int currentHour = DateTime.now().hour;
  late DateTime selectedDate;
  String no_of_eye_test = "0";
  String eye_health_score = "";
  String fullname = "";
  String no_of_fatigue_test = "0";
  dynamic selectedPlanId = '';
  bool isActivePlan = false;

  // Define selectedDate within the _CalendarButtonState class

  late List<AlarmSettings> alarms;
  List<Map<String, dynamic>>? _datagraph;
  static StreamSubscription<AlarmSettings>? subscription;
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

  @override
  void initState() {
    super.initState();

    if (Alarm.android) {
      checkAndroidNotificationPermission();
      checkAndroidScheduleExactAlarmPermission();
    }
    // loadAlarms();
    getGraph().then((data) {
      setState(() {
        _data = data;
      });
    }).catchError((error) {
      print(error);
    });
    subscription ??= Alarm.ringStream.stream.listen(navigateToRingScreen);
  }

  Future<void> checkAndroidNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      final res = await Permission.notification.request();
    }
  }

  void loadAlarms() {
    setState(() {
      alarms = Alarm.getAlarms();
      alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    });
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

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    int currentHour = DateTime.now().hour;
    // Determine the appropriate salutation based on the current hour
    String salutation = '';
    if (currentHour >= 0 && currentHour < 12) {
      salutation = 'Good morning';
    } else if (currentHour >= 12 && currentHour < 17) {
      salutation = 'Good afternoon';
    } else {
      salutation = 'Good evening';
    }
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0), // Add padding
        child: ClipOval(
          child: Material(
            color: Colors.white, // Background color
            elevation: 4.0, // Shadow
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
              },
              child: SizedBox(
                width: 53.0, // Width of the FloatingActionButton
                height: 50.0, // Height of the FloatingActionButton
                child: Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(8.0), // Add padding for the icon
                    child: Image.asset(
                      "assets/home_icon.png",
                      width: 20,
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
        preferredSize: Size.fromHeight(150),
        child: Stack(
          children: [
            Image.asset(
              'assets/pageBackground.png',
              // Replace 'background_image.jpg' with your image asset
              fit: BoxFit.fill,
              width: double.infinity,
              height: 250,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 10.0, 0, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => setReminder()),
                              );
                            },
                            child: Text(
                              salutation,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ),
                          GestureDetector(
                              onTap: () {
                                navigateToAlarmScreen(null);
                              },
                              child: Image.asset('assets/notification.png'))
                        ],
                      ),
                      Text(
                        fullname,
                        style: TextStyle(
                            color: Colors.lightBlueAccent, fontSize: 18),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Your Eye Health Score',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          Text(
                            eye_health_score,
                            style: TextStyle(
                              color: Colors.yellowAccent,
                              fontSize: 28,
                              decoration: TextDecoration.combine(
                                [TextDecoration.underline],
                              ),
                              decorationColor: Colors
                                  .yellow, // Set the underline color to yellow
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
              padding: const EdgeInsets.all(15.0),
              child: GestureDetector(
                onTap: () {
                  checkActivePlan('eyeTest');
                  /*   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddCustomerPage()),
                  );*/
                },
                child: Image.asset('assets/digital_eye_exam.png'),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: GestureDetector(
                onTap: () {
                  // sendcustomerDetails(context);
                  checkActivePlan('fatigue');
                },
                child: Image.asset('assets/eyeFatigueTest.png'),
              ),
            ),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => MyPlan()),
            //     );
            //   },
            //   child: Image.asset('assets/find_near_by_store.png'),
            // ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 17.0, vertical: 10),
              child: Text(
                'EYE HEALTH STATUS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            SizedBox(width: 8),

            Padding(
              padding: EdgeInsets.all(8.0),
              child: Card(
                child: ListTile(
                  title: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Fatigue Right'),
                              Text(
                                fatigue_right ? 'Yes' : 'No',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Mild Tiredness Right'),
                              Text(
                                midtiredness_right ? 'Yes' : 'No',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Add spacing between the row and the additional columns
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Fatigue left'),
                              Text(
                                fatigue_left ? 'Yes' : 'No',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Mild Tiredness Left'),
                              Text(
                                midtiredness_left ? 'Yes' : 'No',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.fromLTRB(16.0, 10, 0, 10),
            //   child: Text(
            //     'EYE HEALTH GRAPH OVERVIEW', // Display formatted current date
            //     style: TextStyle(
            //         fontSize: 18,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.deepPurple),
            //   ),
            // ),
            // Padding(
            //   padding: EdgeInsets.fromLTRB(16.0, 10, 15, 10),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: <Widget>[
            //       Row(
            //         children: [
            //           Text('From: '),//${DateFormat('yyyy-MM-dd').format(_fromDate)}
            //           SizedBox(width: 8),
            //
            //
            //           TextButton(
            //             onPressed: () async {
            //               final DateTime? picked = await showDatePicker(
            //                 context: context,
            //                 initialDate: DateTime.now(),
            //                 firstDate: DateTime(2000),
            //
            //                 lastDate: DateTime(2101),
            //               );
            //               if (picked != null) {
            //                 // _fr[index] = picked;
            //
            //                 setState(() {});
            //               }
            //             },
            //             child: Image.asset('assets/calender.png'),
            //           ),
            //         ],
            //       ),
            //
            //       SizedBox(width: 20),
            //       Row(
            //         children: [
            //           Text('To: '),
            //           SizedBox(width: 8),
            //           TextButton(
            //             onPressed: () async {
            //               final DateTime? picked = await showDatePicker(
            //                 context: context,
            //                 initialDate: DateTime.now(),
            //                 firstDate: DateTime(2000),
            //                 //_fromDates[index] != null ? _fromDates[index]! : DateTime(2000),
            //
            //                 // firstDate:_fromDates[index] != null?? DateTime(2000), // Set the first selectable date to the current date
            //                 lastDate: DateTime(2101),
            //               );
            //               if (picked != null) {
            //                 // _toDates[index] = picked;
            //
            //                 setState(() {});
            //               }
            //             },
            //             child: Image.asset('assets/calender.png'),
            //           ),
            //         ],
            //       ),//${DateFormat('yyyy-MM-dd').format(_toDate)}
            //
            //     ],
            //   ),
            // ),
            //
            // SizedBox(height: 20),
            // Builder(
            //     builder: (context) {
            //       final List<Color> gradientColors = [
            //         Colors.background.withOpacity(0.6),Colors.white.withOpacity(0.8)
            //
            //       ];
            //       return AspectRatio(
            //         aspectRatio: 1.5,
            //         child: LineChart(
            //           LineChartData(
            //             lineBarsData: [
            //               LineChartBarData(
            //                 spots: _datagraph?.asMap().entries
            //                     .map((entry) {
            //                   final date = DateTime.parse(entry.value['date']);
            //                   final value = entry.value['value'] as double;
            //                   return FlSpot(entry.key.toDouble(), value);
            //                 })
            //                     .toList()
            //                     .sublist(0,11), // Take the first 10 entries
            //                 isCurved: true,
            //                 colors: gradientColors,
            //                 barWidth: 1.6,
            //                 belowBarData: BarAreaData(
            //                   show: true,
            //                   colors: gradientColors
            //                       .map((color) => color.withOpacity(0.3))
            //                       .toList(),
            //                 ),
            //                 dotData: FlDotData(show: true),
            //                 isStrokeCapRound: true,
            //                 curveSmoothness: 0.3,
            //               ),
            //             ],
            //             gridData: FlGridData(show: false),
            //             titlesData: FlTitlesData(
            //               show: true,
            //               bottomTitles: SideTitles(
            //                 showTitles: true,
            //                 margin: 8,
            //                 reservedSize: 3,
            //                 interval: 1, // Interval is set to 1 to show all labels
            //                 getTitles: (value) {
            //                   final index = value.toInt();
            //                   if (index >= 0 && index < 10) { // Show only the first 10 dates
            //                     final date = DateTime.parse(_datagraph?[index]['date']);
            //                     return '${date.day}/${date.month}';
            //                   }
            //                   return '';
            //                 },
            //               ),
            //             ),
            //             borderData: FlBorderData(show: true),
            //             minX: 0,
            //             maxX: 9, // Set to 9 because we are showing 10 values (0-indexed)
            //             minY: 0,
            //             maxY: 100,
            //           ),
            //         ),
            //       );
            //
            //
            //     }
            // ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 10, 0, 0),
              child: Text(
                'YOU HAVE TESTED SO FAR', // Display formatted current date
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SizedBox(
                height: 200, // Adjust height as needed
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 180,
                      width: 140,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/interview.png'),
                          // Replace with your image asset
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 28,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              no_of_eye_test ?? "0",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            child: Text(
                              'Eye Test',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 180,
                      width: 140,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/eye_bg.png'),
                          // Replace with your image asset
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 28,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 8.0),
                            child: Text(
                              no_of_fatigue_test ?? "0",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 4.0),
                            child: Text(
                              'Eye Fatigue Test',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
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
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EyeFatigueStartScreen()),
              );
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

  Future<List<double>> getGraph() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken = prefs.getString('access_token') ?? '';
      final response = await http.get(
        Uri.parse('${ApiProvider.baseUrl}/api/fatigue/fatigue-graph'),
        headers: <String, String>{
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        fatigueGraphData = fatigueGraph.fromJson(responseData);

        print("graphdata===:${response.body}");

        Map<String, dynamic> jsonData = jsonDecode(response.body);
        List<dynamic> data = jsonData['data'];
        fullname = jsonData['name'];
        int no_of_fatigue = jsonData['no_of_fatigue_test'];
        int no_of_eye_ = jsonData['no_of_eye_test'];
        dynamic eye_hscore = jsonData['eye_health_score'];
        setState(() {
          _datagraph = List<Map<String, dynamic>>.from(jsonData['data']);
          no_of_fatigue_test = no_of_fatigue.toString();
          no_of_eye_test = no_of_eye_.toString();
          eye_health_score = eye_hscore.toString();
        });

        return data
            .map((item) => double.parse(item['value'].toString()))
            .toList();
      } else {
        print(response.body);
      }
    } catch (e) {
      // _progressDialog!.hide();

      print("exception:$e");
    }
    throw Exception('');
  }
}

class setReminder extends StatefulWidget {
  @override
  State<setReminder> createState() => ReminderState();
}

class ReminderState extends State<setReminder> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Plugin example app'),
            ),
            body: Builder(builder: (context) {
              return Center();
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
      padding: EdgeInsets.fromLTRB(16.0, 16, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Digital Eye Exam',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Divider(thickness: 1, color: Colors.grey.shade500),
          SizedBox(height: 18),
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
          physics: ScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Test For Someone Else',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(thickness: 1.5, color: Colors.grey.shade400),
                SizedBox(height: 20),
                SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 1),
                    child: TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w100,
                        ),
                        hintText: 'Enter Full Name',
                        hintStyle: TextStyle(
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
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
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
                SizedBox(height: 20),
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
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                        hintText: 'Age',
                        hintStyle: TextStyle(
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
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
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
                SizedBox(height: 16),
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
                    child: Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(350, 50),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'You alarm (${alarmSettings.id}) is ringing...',
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
