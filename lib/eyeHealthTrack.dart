import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'Custom_navbar/bottom_navbar.dart';
import 'HomePage.dart';
import 'api/config.dart';
import 'models/fatigueGraphModel.dart';

class EyeHealthTrackDashboard extends StatefulWidget {
  @override
  EyeHealthTrackDashboardState createState() => EyeHealthTrackDashboardState();
}

class EyeHealthTrackDashboardState extends State<EyeHealthTrackDashboard> {
  bool fatigue_left=false; List<double>? _data;int i=0;
  bool fatigue_right=false;fatigueGraph? fatigueGraphData;
  bool midtiredness_right= false;
  bool midtiredness_left=false;
  String no_of_eye_test="0";String eye_health_score="";String name="";String no_of_fatigue_test="0";


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
        fatigueGraphData = fatigueGraph?.fromJson(responseData);


        print("graphdata===:${response.body}");

        Map<String, dynamic> jsonData = jsonDecode(response.body);
        List<dynamic> data = jsonData['data'];
        // name=jsonData['name'];

        fatigue_left=data[0]['is_fatigue_left'];
        fatigue_right=data[0]['is_fatigue_right'];
        midtiredness_right=data[0]['is_mild_tiredness_right'];
        midtiredness_left=data[0]['is_mild_tiredness_left'];
        int no_of_fatigue=jsonData['no_of_fatigue_test'];
        int  no_of_eye_=jsonData['no_of_eye_test'];
        double eye_hscore=jsonData['eye_health_score'];

        setState(() {
          no_of_fatigue_test=no_of_fatigue.toString();
          no_of_eye_test=no_of_eye_.toString();
          eye_health_score=eye_hscore.toString();
          print("gphdata===:${eye_health_score}");

        });

        return data.map((item) => double.parse(item['value'].toString())).toList();

      }
      else {

        print(response.body);
      }
    }
    catch (e) {     // _progressDialog!.hide();

      print("exception:$e");
    }
    throw Exception('');
  }
  @override
  void initState() {
    super.initState();
    // getGraph();
    getGraph().then((data) {
      setState(() {
        _data = data;
      });
    }).catchError((error) {
      print(error);
    });
  }
  //  List<AlarmSettings> alarms=[];
  //
  // static StreamSubscription<AlarmSettings>? subscription;
  //
  //
  //
  //
  //
  //
  //
  //
  // @override
  // void initState() {
  //   super.initState();
  //   if (Alarm.android) {
  //     checkAndroidNotificationPermission();
  //     checkAndroidScheduleExactAlarmPermission();
  //   }
  //   loadAlarms();
  //   subscription ??= Alarm.ringStream.stream.listen(navigateToRingScreen);
  // }
  //
  // void loadAlarms() {
  //   setState(() {
  //     alarms = Alarm.getAlarms();
  //     alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
  //   });
  // }
  //
  // Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
  //   await Navigator.push(
  //     context,
  //     MaterialPageRoute<void>(
  //       builder: (context) =>
  //           ExampleAlarmRingScreen(alarmSettings: alarmSettings),
  //     ),
  //   );
  //   loadAlarms();
  // }
  //
  // Future<void> navigateToAlarmScreen(AlarmSettings? settings) async {
  //   final res = await showModalBottomSheet<bool?>(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(10),
  //     ),
  //     builder: (context) {
  //       return FractionallySizedBox(
  //         heightFactor: 0.75,
  //         child: ExampleAlarmEditScreen(alarmSettings: settings),
  //       );
  //     },
  //   );
  //
  //   if (res != null && res == true) loadAlarms();
  // }
  //
  // Future<void> checkAndroidNotificationPermission() async {
  //   final status = await Permission.notification.status;
  //   if (status.isDenied) {
  //     alarmPrint('Requesting notification permission...');
  //     final res = await Permission.notification.request();
  //     alarmPrint(
  //       'Notification permission ${res.isGranted ? '' : 'not '}granted',
  //     );
  //   }
  // }
  //
  // Future<void> checkAndroidExternalStoragePermission() async {
  //   final status = await Permission.storage.status;
  //   if (status.isDenied) {
  //     alarmPrint('Requesting external storage permission...');
  //     final res = await Permission.storage.request();
  //     alarmPrint(
  //       'External storage permission ${res.isGranted ? '' : 'not'} granted',
  //     );
  //   }
  // }
  //
  // Future<void> checkAndroidScheduleExactAlarmPermission() async {
  //   final status = await Permission.scheduleExactAlarm.status;
  //   alarmPrint('Schedule exact alarm permission: $status.');
  //   if (status.isDenied) {
  //     alarmPrint('Requesting schedule exact alarm permission...');
  //     final res = await Permission.scheduleExactAlarm.request();
  //     alarmPrint(
  //       'Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted',
  //     );
  //   }
  // }
  //
  // @override
  // void dispose() {
  //   subscription?.cancel();
  //   super.dispose();
  // }




  bool isSelected = false;
  bool isLeftEyeSelected = false;
  List<double> data1 = [10, 30, 20, 40, 30]; // Sample data for line 1
  List<double> data2 = [30, 50, 60, 50, 60]; // Sample data for line 2
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMMM').format(DateTime.now());
    return Scaffold(
      backgroundColor: Colors.white,
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
                  context, CupertinoPageRoute(
                  builder: (context) => HomePage(
                  ),
                ),

                );
              },
              child: SizedBox(
                width: 53.0, // Width of the FloatingActionButton
                height: 50.0, // Height of the FloatingActionButton
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0), // Add padding for the icon
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



      appBar: AppBar(
        backgroundColor: Colors.white,

        title: Text('Eye Health Track'),
        actions: <Widget>[
          // ExampleAlarmHomeShortcutButton(refreshAlarms: loadAlarms),

          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () async {
              print("asdklaskldjaskldasjkdjlkas");
              // navigateToAlarmScreen(null);


              // checkAndroidScheduleExactAlarmPermission();
              // await Alarm.init();
              // final alarmSettings = AlarmSettings(
              //   id: 42,
              //   dateTime: DateTime.now().add(Duration(seconds: 15)),
              //   assetAudioPath: 'assets/alarm.mp3',
              //   loopAudio: false,
              //   vibrate: true,
              //   volume: 0.8,
              //   androidFullScreenIntent: true,
              //   fadeDuration: 1.0,
              //   notificationTitle: 'This is the title',
              //   notificationBody: 'This is the body',
              //   enableNotificationOnKill: true,
              // );
              // // Handle notification icon pressed
              // await Alarm.set(alarmSettings: alarmSettings);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 6, 0, 8),
              child: Text(
                'Today $formattedDate', // Display formatted current date
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/banner1.png',
                    fit: BoxFit.cover, // Ensure the image covers the entire stack
                  ),
                  Positioned(
                    right: 20,
                    bottom: 120, // Adjust the position of the text as needed
                    child: Text(
                      'Your Eye Health Score',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                     Positioned(
                      right: 50,
                      bottom: 80, // Adjust the position of the text as needed
                      child:  Text(
                        eye_health_score, // Convert double to String
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.amber, // Adjust size as needed
                          // Add other styling properties as needed
                        ),
                      ),
                    ),

                ],
              ),
            )
,
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 10, 0, 10),
              child: Text(
                'EYE HEALTH STATUS', // Display formatted current date
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
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
            //   padding: const EdgeInsets.all(8.0),
            //   child: Card(
            //     child: ListTile(
            //       title: Column(
            //         children: [
            //           Row(
            //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //             children: [
            //               Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Text('No. of eye fatigue test',style: TextStyle(
            //                     fontSize: 14,
            //                     fontWeight: FontWeight.w400,)),
            //                   Text('value',style: TextStyle(
            //                     fontSize: 14,
            //                     fontWeight: FontWeight.bold,
            //                   ),),
            //                 ],
            //               ),
            //               SizedBox(width: 3,),
            //               Column(
            //                 crossAxisAlignment: CrossAxisAlignment.end,
            //                 children: [
            //                   Text('No. of digital eye test',style: TextStyle(
            //                     fontSize: 14,
            //                     fontWeight: FontWeight.w400,)),
            //                   Text('Value ',style: TextStyle(
            //                     fontSize: 14,
            //                     fontWeight: FontWeight.bold,
            //                   ),),
            //                 ],
            //               ),
            //             ],
            //           ),
            //           SizedBox(height: 16), // Add spacing between the row and the additional columns
            //           Row(
            //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //             children: [
            //               Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Text('Prescription uploaded',style: TextStyle(
            //             fontSize: 14,
            //             fontWeight: FontWeight.w400,)),
            //                   Text('value',style: TextStyle(
            //                     fontSize: 14,
            //                     fontWeight: FontWeight.bold,
            //                   ),),
            //                 ],
            //               ),
            //               Column(
            //                 crossAxisAlignment: CrossAxisAlignment.end,
            //                 children: [
            //                   Text('visit to optemistist',style: TextStyle(
            //                     fontSize: 14,
            //                     fontWeight: FontWeight.w400,)),
            //                   Text('Value',style: TextStyle(
            //                     fontSize: 14,
            //                     fontWeight: FontWeight.bold,
            //                   ),),
            //                 ],
            //               ),
            //             ],
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 10, 0, 10),
              child: Text(
                'EYE HEALTH GRAPH OVERVIEW', // Display formatted current date
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 1),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(1),
                          child: ListTile(
                            title: Text(
                              'Right Eye Health',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text('April 30-May 30'),
                          ),
                        ),
                        Container(
                          height: 200,
                          width: MediaQuery.of(context).size.width, // Adjust the width as needed
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: AspectRatio(
                              aspectRatio: 1.40,
                              child: _data != null
                                  ? Builder(
                                  builder: (context) {


                                    if(_data!.length>10){
                                      i=10;

                                    }else{
                                      i=_data!.length;
                                    }
                                    return LineChart(
                                      LineChartData(
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: _data!
                                                .sublist(0, i)
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              return FlSpot(
                                                  entry.key.toDouble(), entry.value);
                                            }).toList(),
                                            isCurved: true,
                                            colors: [Colors.deepPurple],
                                            barWidth: 4,
                                            isStrokeCapRound: true,
                                            belowBarData: BarAreaData(
                                              show: true,
                                              colors: [
                                                Colors.deepPurple.withOpacity(0.1)
                                              ],
                                            ),
                                          ),
                                        ],
                                        gridData: FlGridData(
                                          drawVerticalLine: true,
                                          drawHorizontalLine: false,
                                        ),
                                        titlesData: FlTitlesData(
                                          leftTitles: SideTitles(
                                            showTitles: true,
                                            interval: 10.0,
                                          ),
                                        ),
                                        minX: 0,
                                        maxX: 10, // Initially show only 10 values
                                        minY: 10,
                                        maxY: 100,
                                      ),
                                    );
                                  }
                              )
                                  : CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 16),
            //   child: Container(
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(20),
            //       color: Colors.grey[200],
            //     ),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //
            //       children: [
            //         GestureDetector(
            //           onTap: () {
            //             setState(() {
            //               isLeftEyeSelected = true;
            //             });
            //           },
            //           child: Padding(
            //             padding: const EdgeInsets.all(12.0),
            //             child: Container(
            //               decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(23),
            //                 color: isLeftEyeSelected ? Colors.white : Colors.transparent,
            //               ),
            //               child: Padding(
            //                 padding: const EdgeInsets.all(8.0),
            //                 child: Text(
            //                   'Left Eye Health',
            //                   style: TextStyle(
            //                     fontWeight: FontWeight.bold,
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //         GestureDetector(
            //           onTap: () {
            //             setState(() {
            //               isLeftEyeSelected = false;
            //             });
            //           },
            //           child: Padding(
            //             padding: const EdgeInsets.all(12.0),
            //             child: Container(
            //               decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(23),
            //
            //                 color: !isLeftEyeSelected ? Colors.white : Colors.transparent,
            //               ),
            //               child: Padding(
            //                 padding: const EdgeInsets.all(8.0),
            //                 child: Text(
            //                   'Right Eye Health',
            //                   style: TextStyle(
            //                     fontWeight: FontWeight.bold,
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            //
            // SizedBox(height: 20), // Add spacing between the row and the eye health widgets
            // isLeftEyeSelected ? LeftEyeHealthWidget() : RightEyeHealthWidget(),
            // Text and toggle button below the graph
          ],
        ),
      ),
      bottomNavigationBar:
      CustomBottomAppBar(),  );
  }
}

class LeftEyeHealthWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First Card for Image, Label, and Text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 1),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListTile(
                leading: Image.asset('assets/lefteye.png'),
                title: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Label 1:'),
                            Text('value'),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Label 2'),
                            Text('Value '),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16), // Add spacing between the row and the additional columns
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Label'),
                            Text('value'),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Label'),
                            Text('Value'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Second Card for Heading and Graph
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 1),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: EdgeInsets.all(1),
                    child :ListTile(
                      title: Text(
                        'Left Eye Health',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // subtitle: Text('April 30-May 30'),
                    ),),

                  // Container with fixed height to contain the LineChart
                  SizedBox(
                    height: 200,
                    width: MediaQuery.of(context).size.width,

                    // Adjust the height as needed
                    child: AspectRatio(
                      aspectRatio: 1.40,
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                FlSpot(0, 4),
                                FlSpot(2, 4),
                                FlSpot(4, 6),
                                FlSpot(6, 3),
                                FlSpot(8, 4),
                                FlSpot(10, 5),
                              ],
                              isCurved: true,
                              colors: [Colors.deepPurple],
                              barWidth: 4,
                              isStrokeCapRound: true,
                              belowBarData: BarAreaData(
                                show: true,
                                colors: [Colors.deepPurple.withOpacity(0.2)],
                              ),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            bottomTitles: SideTitles(
                              showTitles: true,
                              getTitles: (value) {
                                switch (value.toInt()) {
                                  case 0:
                                    return 'Mon';
                                  case 2:
                                    return 'Tue';
                                  case 4:
                                    return 'Wed';
                                  case 6:
                                    return 'Thu';
                                  case 8:
                                    return 'Fri';
                                  case 10:
                                    return 'Sat';
                                }
                                return '';
                              },
                            ),
                            leftTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            drawHorizontalLine: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RightEyeHealthWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First Card for Image, Label, and Text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical:1),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListTile(
                leading: Image.asset('assets/righteye.png'),
                title: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Label 1:'),
                            Text('value'),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Label 2'),
                            Text('Value '),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16), // Add spacing between the row and the additional columns
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Label'),
                            Text('value'),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Label'),
                            Text('Value'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Second Card for Heading and Graph
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 1),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: EdgeInsets.all(1),
                    child :ListTile(
                      title: Text(
                        'Right Eye Health',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('April 30-May 30'),
                    ),),

                  // Container with fixed height to contain the LineChart
                  Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,

                    // Adjust the height as needed
                    child: AspectRatio(
                      aspectRatio: 1.40,
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                FlSpot(0, 4),
                                FlSpot(2, 4),
                                FlSpot(4, 6),
                                FlSpot(6, 3),
                                FlSpot(8, 4),
                                FlSpot(10, 5),
                              ],
                              isCurved: true,
                              colors: [Colors.deepPurple],
                              barWidth: 4,
                              isStrokeCapRound: true,
                              belowBarData: BarAreaData(
                                show: true,
                                colors: [Colors.deepPurple.withOpacity(0.2)],
                              ),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            bottomTitles: SideTitles(
                              showTitles: true,
                              getTitles: (value) {
                                switch (value.toInt()) {
                                  case 0:
                                    return 'Mon';
                                  case 2:
                                    return 'Tue';
                                  case 4:
                                    return 'Wed';
                                  case 6:
                                    return 'Thu';
                                  case 8:
                                    return 'Fri';
                                  case 10:
                                    return 'Sat';
                                }
                                return '';
                              },
                            ),
                            leftTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            drawHorizontalLine: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}