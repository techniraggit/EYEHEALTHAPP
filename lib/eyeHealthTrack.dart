import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
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


  // Future<List<double>> getGraph() async {
  //   // try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String authToken = prefs.getString('access_token') ?? '';
  //     final response = await http.get(
  //       Uri.parse('${ApiProvider.baseUrl}/api/fatigue/fatigue-graph?user_timezone=Asia/Kolkata'),
  //       headers: <String, String>{
  //         'Authorization': 'Bearer $authToken',
  //       },
  //
  //     );
  //
  //     if (response.statusCode == 200) {
  //
  //       final responseData = json.decode(response.body);
  //       fatigueGraphData = fatigueGraph.fromJson(responseData);
  //
  //
  //       print("graphdata===:${response.body}");
  //
  //       Map<String, dynamic> jsonData = jsonDecode(response.body);
  //       List<dynamic> data = jsonData['data'];
  //       // name=jsonData['name'];
  //
  //       // fatigue_left=data[0]['is_fatigue_left'];
  //       // fatigue_right=data[0]['is_fatigue_right'];
  //       // midtiredness_right=data[0]['is_mild_tiredness_right'];
  //       // midtiredness_left=data[0]['is_mild_tiredness_left'];
  //       int no_of_fatigue=jsonData['no_of_fatigue_test'];
  //       int  no_of_eye_=jsonData['no_of_eye_test'];
  //       double eye_hscore=jsonData['eye_health_score'];
  //       setState(() {
  //         no_of_fatigue_test=no_of_fatigue.toString();
  //         no_of_eye_test=no_of_eye_.toString();
  //         eye_health_score=eye_hscore.toString();
  //       });
  //
  //       return data.map((item) => double.parse(item['value'].toString())).toList();
  //
  //     }
  //     else {
  //
  //       print(response.body);
  //     }
  //   // }
  //   // catch (e) {     // _progressDialog!.hide();
  //
  //     // print("exception:$e");
  //   // }
  //   throw Exception('');
  // }
  Future<void> getGraph() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('access_token') ?? '';
    final response = await http.get(
      Uri.parse('${ApiProvider.baseUrl}/api/fatigue/fatigue-graph?user_timezone=Asia/Kolkata'),
      headers: <String, String>{
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      List<double> todaygraphData = [];
      List<double> firstTestgraphData = [];

      if (responseData.containsKey('status') && responseData['status']) {
        if (responseData.containsKey('first_day_data') && responseData['first_day_data'].containsKey('value')) {
          List<dynamic> firstDayValue = responseData['first_day_data']['value'];
          firstTestgraphData.addAll(firstDayValue.map((value) => value.toDouble()));
        }
        if (responseData.containsKey('current_day_data') && responseData['current_day_data'].containsKey('value')) {
          List<dynamic> currentDayValue = responseData['current_day_data']['value'];
          todaygraphData.addAll(currentDayValue.map((value) => value.toDouble()));
        }
      }
print("fffffffffffffff$todaygraphData");
      // return graphData;
    } else {
      throw Exception('Failed to load graph data');
    }
  }

  @override
  void initState() {
    super.initState();
    getGraph();
    // getGraph().then((data) {
    //   setState(() {
    //     _data = data;
    //   });
    // }).catchError((error) {
    //   print(error);
    // });
  }





  bool isSelected = false;
  bool isLeftEyeSelected = false;
  List<double> data1 = [10, 30, 20, 40, 30]; // Sample data for line 1
  List<double> data2 = [30, 50, 60, 50, 60]; // Sample data for line 2
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMMM').format(DateTime.now());
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
              child: Image.asset('assets/banner1.png'),
            ),
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
                          SizedBox(width: 3,),
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
                        // Padding(
                        //   padding: EdgeInsets.all(1),
                        //   child: ListTile(
                        //     title: Text(
                        //       'Right Eye Health',
                        //       style: TextStyle(
                        //         fontSize: 16.0,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //     subtitle: Text('April 30-May 30'),
                        //   ),
                        // ),
                  Center(
                    child: SizedBox(
                      width: 300,
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: false, // Hide grid lines
                          ),
                          borderData: FlBorderData(
                            show: true, // Show boundary
                            border: Border(
                              bottom: BorderSide(color: Colors.black, width: 1),
                              left: BorderSide(color: Colors.black, width: 1),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                FlSpot(0, 2),
                                FlSpot(1, 4),
                                FlSpot(2, 6),
                                FlSpot(3, 8),
                              ],
                              isCurved: true,
                              colors: [Colors.background],
                              barWidth: 4,
                              belowBarData: BarAreaData(show: true, colors: [Colors.orange.withOpacity(0.3)]),
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: [
                                FlSpot(0, 2),
                                FlSpot(1, 3),
                                FlSpot(2, 8),
                                FlSpot(3, 7),
                              ],
                              isCurved: true,
                              colors: [Colors.orange],
                              barWidth: 4,
                              belowBarData: BarAreaData(show: true, colors: [Colors.blue.withOpacity(0.3)]),
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: [
                                FlSpot(0, 3),
                                FlSpot(1, 6),
                                FlSpot(2, 8),
                                FlSpot(3, 4),
                              ],
                              isCurved: true,
                              colors: [Colors.green], // changed from 'background' to 'grey'
                              barWidth: 4,
                              belowBarData: BarAreaData(show: true, colors: [Colors.grey.withOpacity(0.3)]), // changed from 'background' to 'grey'
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: [
                                FlSpot(0, 5),
                                FlSpot(1, 6),
                                FlSpot(2, 3),
                                FlSpot(3, 7),
                              ],
                              isCurved: true,
                              colors: [Colors.yellow], // changed from 'background' to 'green'
                              barWidth: 4,
                              belowBarData: BarAreaData(show: true, colors: [Colors.green.withOpacity(0.3)]), // changed from 'background' to 'green'
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                              getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                                return lineBarsSpot.map((lineBarSpot) {
                                  final flSpot = lineBarSpot;
                                  if (flSpot.bar.colors.contains(Colors.background)) {
                                    return LineTooltipItem('Orange Line: ${flSpot.y}', TextStyle(color: Colors.white));
                                  } else if (flSpot.bar.colors.contains(Colors.orange)) {
                                    return LineTooltipItem('Blue Line: ${flSpot.y}', TextStyle(color: Colors.white));
                                  } else if (flSpot.bar.colors.contains(Colors.green)) {
                                    return LineTooltipItem('Grey Line: ${flSpot.y}', TextStyle(color: Colors.white));
                                  } else if (flSpot.bar.colors.contains(Colors.yellow)) {
                                    return LineTooltipItem('Green Line: ${flSpot.y}', TextStyle(color: Colors.white));
                                  }
                                  return null;
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                        // Container(
                        //   height: 200,
                        //   width: MediaQuery.of(context).size.width, // Adjust the width as needed
                        //   child: SingleChildScrollView(
                        //     scrollDirection: Axis.horizontal,
                        //     child: AspectRatio(
                        //       aspectRatio: 1.40,
                        //       child: _data != null
                        //           ? Builder(
                        //           builder: (context) {
                        //
                        //
                        //             if(_data!.length>10){
                        //               i=10;
                        //
                        //             }else{
                        //               i=_data!.length;
                        //             }
                        //             return LineChart(
                        //               LineChartData(
                        //                 lineBarsData: [
                        //                   LineChartBarData(
                        //                     spots: _data!
                        //                         .sublist(0, i)
                        //                         .asMap()
                        //                         .entries
                        //                         .map((entry) {
                        //                       return FlSpot(
                        //                           entry.key.toDouble(), entry.value);
                        //                     }).toList(),
                        //                     isCurved: true,
                        //                     colors: [Colors.deepPurple],
                        //                     barWidth: 4,
                        //                     isStrokeCapRound: true,
                        //                     belowBarData: BarAreaData(
                        //                       show: true,
                        //                       colors: [
                        //                         Colors.deepPurple.withOpacity(0.1)
                        //                       ],
                        //                     ),
                        //                   ),
                        //                 ],
                        //                 gridData: FlGridData(
                        //                   drawVerticalLine: true,
                        //                   drawHorizontalLine: false,
                        //                 ),
                        //                 titlesData: FlTitlesData(
                        //                   leftTitles: SideTitles(
                        //                     showTitles: true,
                        //                     interval: 10.0,
                        //                   ),
                        //                 ),
                        //                 minX: 0,
                        //                 maxX: 10, // Initially show only 10 values
                        //                 minY: 10,
                        //                 maxY: 100,
                        //               ),
                        //             );
                        //           }
                        //       )
                        //           : CircularProgressIndicator(),
                        //     ),
                        //   ),
                        // ),
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
                  // Padding(padding: EdgeInsets.all(1),
                    // child :ListTile(
                    //   title: Text(
                    //     'Right Eye Health',
                    //     style: TextStyle(
                    //       fontSize: 16.0,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    //   subtitle: Text('April 30-May 30'),
                    // ),),

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

