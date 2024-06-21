import 'dart:async';
import 'dart:convert';
import 'package:action_broadcast/action_broadcast.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project_new/sign_up.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:http/http.dart' as http;

import 'package:fl_chart/fl_chart.dart'hide AxisTitle;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Custom_navbar/bottom_navbar.dart';
import 'HomePage.dart';
import 'api/config.dart';
import 'eyeFatigueTest/EyeFatigueSelfieScreen.dart';
import 'eyeFatigueTest/eyeFatigueTest.dart';
import 'models/fatigueGraphModel.dart';
import 'notification/notification_dashboard.dart';

class EyeHealthTrackDashboard extends StatefulWidget {
  @override
  EyeHealthTrackDashboardState createState() => EyeHealthTrackDashboardState();
}

class EyeHealthTrackDashboardState extends State<EyeHealthTrackDashboard> with AutoCancelStreamMixin{

  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey();
  int? isReadFalseCount = 0;

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
      }
      else if (response.statusCode == 401) {
        Fluttertoast.showToast(msg: "Session Expired");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      }
      else {
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


  bool fatigue_left=false; List<double>? _data;int i=0;bool isLoading = false;bool isLoading1 =true;
  bool fatigue_right=false;fatigueGraph? fatigueGraphData;int count=0;
  bool midtiredness_right= false;List<double> todaygraphData = [];
  List<double> firstTestgraphData = [];
  bool midtiredness_left=false;
  String no_of_eye_test="0";String eye_health_score="";String name="";String no_of_fatigue_test="0";

  List<double> idealTestgraphData = [];
  List<double> populationTestgraphData = [];




  Future<List<double>> getGraph() async {
    try {
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
        fatigueGraphData = fatigueGraph.fromJson(responseData);

        print("graphdata===:${response.body}");

        Map<String, dynamic> jsonData = jsonDecode(response.body);
        // List<dynamic> data = jsonData['data'];
        int no_of_fatigue = jsonData['no_of_fatigue_test'];
        int no_of_eye_ = jsonData['no_of_eye_test'];
        dynamic eye_hscore = jsonData['eye_health_score'];
        setState(() {
          // _datagraph = List<Map<String, dynamic>>.from(jsonData['data']);
          no_of_fatigue_test = no_of_fatigue.toString();
          no_of_eye_test = no_of_eye_.toString();
          eye_health_score = eye_hscore.toString();
        });
        if (responseData.containsKey('status') && responseData['status']) {
          if (responseData.containsKey('first_day_data') && responseData['first_day_data'].containsKey('value')) {
            List<dynamic> firstDayValue = responseData['first_day_data']['value'];
            firstTestgraphData.addAll(firstDayValue.map((value) => value.toDouble()));
          }
          if (responseData.containsKey('current_day_data') && responseData['current_day_data'].containsKey('value')) {
            List<dynamic> currentDayValue = responseData['current_day_data']['value'];
            todaygraphData.addAll(currentDayValue.map((value) => value.toDouble()));
          }
          if (responseData.containsKey('current_day_data') ) {
            List<dynamic> population = List<double>.from(jsonData['get_percentile_graph']);

            populationTestgraphData.addAll(population.map((value) => value.toDouble()));
          }
          if (responseData.containsKey('get_ideal_graph') ) {
            List<dynamic> ideal =  List<double>.from(jsonData['get_ideal_graph']);

            idealTestgraphData.addAll(ideal.map((value) => value.toDouble()));
          }
        }
        print("fffffffffffffff$todaygraphData");
        setState(() {
          chartData = <_ChartData>[
            _ChartData('6 AM', firstTestgraphData[0], idealTestgraphData[0] ,populationTestgraphData[0],todaygraphData[0]),
            _ChartData('9 AM', firstTestgraphData[1], idealTestgraphData[1], populationTestgraphData[1],todaygraphData[1]),
            _ChartData('12 PM', firstTestgraphData[2],  idealTestgraphData[2],populationTestgraphData[2],todaygraphData[2]),
            _ChartData('3 PM', firstTestgraphData[3], idealTestgraphData[3],populationTestgraphData[3], todaygraphData[3]),
            _ChartData('6 PM', firstTestgraphData[4], idealTestgraphData[4], populationTestgraphData[4],todaygraphData[4]),
            _ChartData('9 PM', firstTestgraphData[5],  idealTestgraphData[5],populationTestgraphData[5],todaygraphData[5]),
            _ChartData('12 AM', firstTestgraphData[6],  idealTestgraphData[6],populationTestgraphData[6],todaygraphData[6]),



          ];
        });
        count = jsonData['no_of_eye_test'];
        isLoading1=false;

        // return data
        //     .map((item) => double.parse(item['value'].toString()))
        //     .toList();
      }
      else if (response.statusCode == 401) {
        Fluttertoast.showToast(msg: "Session Expired");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      }      else {
        print(response.body);
      }
    } catch (e) {
      // _progressDialog!.hide();

      print("exception:$e");
    }
    throw Exception('');
  }

  List<_ChartData>? chartData;

  @override
  void initState() {
    super.initState();

    getGraph();    getNotifactionCount();



  }





  bool isSelected = false;
  bool isLeftEyeSelected = false;
  List<double> data1 = [10, 30, 20, 40, 30]; // Sample data for line 1
  List<double> data2 = [30, 50, 60, 50, 60]; // Sample data for line 2
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMMM').format(DateTime.now());
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
                Navigator.of(context).pop();
                // Navigator.push(
                //   context, CupertinoPageRoute(
                //   builder: (context) => HomePage(
                //   ),
                // ),
                //
                // );
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




      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                iconSize: 28, // Back button icon
                onPressed: () {
                  Navigator.of(context).pop();              },
              ),
            ),
            Center(
              child: Text(
                'Eye Health Track',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  // Adjust size as needed
                  // Add other styling properties as needed
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 16,
              child: GestureDetector(
                onTap: () async {
                  _scafoldKey.currentState!.openEndDrawer();
                },
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffF9F9FA),
                        borderRadius: BorderRadius.circular(17.0),
                      ),
                      height: 40,
                      width: 40,
                      child: Center(
                        child: Icon(
                          Icons.notifications,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: -1, // Adjust this value to position the text properly
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Text(
                          '${isReadFalseCount}',
                          style: TextStyle(
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
              padding: const EdgeInsets.fromLTRB(16.0, 6, 0, 8),
              child: Text(
                'Today $formattedDate', // Display formatted current date
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset('assets/banner1.png'),
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
            Container(
              color: Colors.white,

              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 8.0, vertical: 1),
                child: Container(
                  color: Colors.white,

                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    elevation: 0.1,
                    color: Colors.white,
                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [


                                  if(chartData!=null)...{
                                      Center(

                    child: Container(
                    color: Colors.white,

                        child:isLoading1
                            ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        )
                            : _buildVerticalSplineChart(),


                    ),
                                      ),
                        SizedBox(height: 10), // Adjust spacing between chart and color descriptions

                        // Color descriptions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // _buildColorDescription(Colors.black, 'First Test'),
                            _buildColorDescription(Colors.green, 'Ideal'),
                            // _buildColorDescription(Colors.orange, 'Percentile'),
                            _buildColorDescription(Colors.blue, 'User avg'),
                          ],
                        ),},



if(count==0&&isLoading1==false)...{
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
                                // Navigator.push([]
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) => EyeFatigueSelfieScreen()),
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
                        ),},

                        SizedBox(height: 29),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
      bottomNavigationBar:
      CustomBottomAppBar(currentScreen: "EyeHealth"),

    );
  }
  Widget _buildColorDescription(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          color: color,
          margin: EdgeInsets.only(right: 5),
        ),
        Text(text),
      ],
    );
  }

  void requestPermission() async {
    PermissionStatus status = await Permission.camera.status;
    PermissionStatus status2 = await Permission.microphone.status;

    if((status==PermissionStatus.granted&&status2==PermissionStatus.granted) ){
      setState(() {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EyeFatigueSelfieScreen()),
        );
      });

    }
    if (!status.isGranted ) {
      status = await Permission.camera.request();
    }
    if (!status2.isGranted ) {
      status = await Permission.microphone.request();
    }
    if (status == PermissionStatus.denied ||
        status == PermissionStatus.permanentlyDenied) {
      await [Permission.camera].request();

      // Permissions are denied or denied forever, let's request it!
      status =  await Permission.camera.status;
      if (status == PermissionStatus.denied) {
        await [Permission.camera].request();
        print("camera permissions are still denied");
      } else if (status ==PermissionStatus.permanentlyDenied) {
        print("camera permissions are permanently denied");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("camera permissions required"),
              content: Text("camera permissions are permanently denied. Please go to app settings to enable camera permissions."),
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
                  child: Text("OK",

                    style: TextStyle(
                        color: Colors.white, fontSize: 16),
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
      status2 =  await Permission.microphone.status;
      if (status2 == PermissionStatus.denied) {
        await [Permission.microphone].request();
        print("microphone permissions are still denied");
      }  if (status2 ==PermissionStatus.permanentlyDenied) {
        print("microphone permissions are permanently denied");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("microphone permissions required"),
              content: Text("microphone permissions are permanently denied. Please go to app settings to enable microphone permissions."),
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
                  child: Text("OK",

                    style: TextStyle(
                        color: Colors.white, fontSize: 16),
                  ),
                ),

              ],
            );
          },
        );
      }
    }


  }


  SfCartesianChart _buildVerticalSplineChart() {
    return SfCartesianChart(
      isTransposed: false,
      plotAreaBorderWidth: 0,

      legend: const Legend(isVisible:true),
      primaryXAxis: const CategoryAxis(
        majorTickLines: MajorTickLines(size: 0),
        axisLine: AxisLine(width: 0.3),
        majorGridLines: MajorGridLines(width: 0),
        title:  AxisTitle(text: 'time slots  (x-axis) --->'),
      ),// Disable vertical inner gridlines
      primaryYAxis: const NumericAxis(
        minimum: 0,
        maximum: 11,
        interval: 1,
        labelFormat: '{value}',
        title: AxisTitle(text: 'eye score  (y-axis)  --->'), // Description for X axis
        majorGridLines: MajorGridLines(width: 0), // Hide horizontal grid lines
      ),
      series: _getVerticalSplineSeries(),
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }


  List<SplineSeries<_ChartData, String>> _getVerticalSplineSeries() {
    return <SplineSeries<_ChartData, String>>[

      SplineSeries<_ChartData, String>(
        markerSettings: const MarkerSettings(isVisible: true),
        dataSource: chartData,
        cardinalSplineTension: 0.5,
        splineType: SplineType.monotonic,
        name: 'Ideal Score',color: Colors.green,
        xValueMapper: (_ChartData sales, _) => sales.x,
        yValueMapper: (_ChartData sales, _) => sales.y2,
        emptyPointSettings: EmptyPointSettings(
          mode: EmptyPointMode.gap, // Connect points with a line when there's a gap
          color: Colors.green, // Optional: Set color of the line connecting null points
        ),
      ),

      SplineSeries<_ChartData, String>(
        markerSettings: const MarkerSettings(isVisible: true),
        dataSource: chartData,color: Colors.blue,
        name: 'User Average Score',
        cardinalSplineTension: 0.5,
        splineType: SplineType.monotonic,
        xValueMapper: (_ChartData sales, _) => sales.x,
        yValueMapper: (_ChartData sales, _) => sales.y4, emptyPointSettings: EmptyPointSettings(
        mode: EmptyPointMode.gap, // Connect points with a line when there's a gap
        color: Colors.blue, // Optional: Set color of the line connecting null points
      ),
      )
    ];
  }

  @override
  void dispose() {
    chartData!.clear();
    super.dispose();
  }
}
/// Private class for storing the spline series data points.
class _ChartData {
  _ChartData(this.x, this.y, this.y2, this.y3, this.y4);
  final String x;
  final double y;
  final double y2;
  final double y3;
  final double y4;

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
                title: const Column(
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
                  const Padding(padding: EdgeInsets.all(1),
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
                title: const Column(
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

