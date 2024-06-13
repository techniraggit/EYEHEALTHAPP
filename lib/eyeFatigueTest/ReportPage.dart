









import 'dart:convert';
import 'dart:math';
import 'package:action_broadcast/action_broadcast.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:project_new/HomePage.dart';
import 'package:project_new/Rewards/rewards_sync.dart';
import 'package:project_new/api/Api.dart';
import 'package:project_new/digitalEyeTest/EyeTestReportDetail.dart';
import 'package:project_new/digitalEyeTest/TestReport.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Custom_navbar/bottom_navbar.dart';
import '../api/config.dart';
import '../models/fatigueGraphModel.dart';
import '../notification/notification_dashboard.dart';
import '../sign_up.dart';
import 'FatigueReportDetails.dart';

class ReportPage extends StatefulWidget {
  @override
  ReportPageState createState() => ReportPageState();
}
class _ChartData {
  _ChartData(this.x, this.y, this.y2, this.y3, this.y4);
  final String x;
  final double y;
  final double y2;
  final double y3;
  final double y4;

}
class ReportPageState extends State<ReportPage> with AutoCancelStreamMixin{
  List<dynamic> itemsdata = []; final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey();
  int? isReadFalseCount = 0;
  bool isLoading = true; List<double> idealTestgraphData = [];
  List<double> populationTestgraphData = [];
  List<dynamic> percentage = [];
  List<dynamic> items = [];
  List<dynamic> ReportIds = [];
  String testResult = 'Good';int count=0;
  List<Prescription> prescriptions = [];fatigueGraph? fatigueGraphData;
  bool midtiredness_right= false;List<double> todaygraphData = [];
  List<double> firstTestgraphData = [];  List<_ChartData>? chartData;
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
  @override
  void initState() {
    super.initState();
    getReports();
    geteyeReports();
    getGraph();    getNotifactionCount();

    getPrescriptionFiles();
  }
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

        if (responseData.containsKey('status') && responseData['status']) {
          if (responseData.containsKey('first_day_data') && responseData['first_day_data'].containsKey('value')) {
            List<dynamic> firstDayValue = responseData['first_day_data']['value'];
            firstTestgraphData.addAll(firstDayValue.map((value) => value.toDouble()));
          }
          if (responseData.containsKey('current_day_data') && responseData['current_day_data'].containsKey('value')) {
            List<dynamic> currentDayValue = responseData['current_day_data']['value'];
            todaygraphData.addAll(currentDayValue.map((value) => value.toDouble()));
          }
          if (responseData.containsKey('get_percentile_graph') ) {
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
  Future<void> getNotifactionCount() async {
    try{
      String userToken = '';
      var sharedPref = await SharedPreferences.getInstance();
      userToken = sharedPref.getString("access_token") ?? '';
      String url = "'${ApiProvider.baseUrl}/api/helping/get-count";
      print("URL: $url");

      Map<String, String> headers = {
        'Authorization': 'Bearer $userToken', // Bearer token type
        'Content-Type': 'application/json',
      };
      var response = await Dio().get(url, options: Options(headers: headers));
      print('drf gfbt Count: $response');

      if (response.statusCode == 200) {
        final responseData = response.data;
        // Map<String, dynamic> responseData = json.decode(response.data);
        int unreadNotificationCount = responseData['unread_notification_count'];
        isReadFalseCount = unreadNotificationCount;
        print('Unread Notification Count: $unreadNotificationCount');
        print('Unread gfbt Count: $response');
        if(mounted){
          setState(() {});

        }
      }else if (response.statusCode == 401) {

        Fluttertoast.showToast(msg: "Session Expired");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      }   else if (response.statusCode == 401) {

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
      }

      else {
        // Handle other Dio errors
        print("DioError: ${e.error}");
      }
    } catch (e) {
      // Handle other exceptions
      print("Exception---: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMMM').format(DateTime.now());
    return isLoading
        ? Center(
      child: CircularProgressIndicator(
        color: Colors.black,
      ),
    )
        : DefaultTabController(
      length: 3,
      child: Scaffold(



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
        // appBar: AppBar(
        //   backgroundColor: Colors.white,
        //   title: const Text('Report and Statistics'),
        //   bottom: TabBar(
        //     tabs: [
        //       Tab(text: 'Fatigue Report'),
        //       Tab(text: 'Eye Test Report'),
        //       Tab(text: 'Other'),
        //     ],
        //     labelColor: Colors.bluebutton,
        //     unselectedLabelColor: Colors.black,
        //     labelStyle:
        //     TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        //     unselectedLabelStyle: TextStyle(fontSize: 14),
        //   ),
        //   actions: <Widget>[
        //     IconButton(
        //       icon: Icon(Icons.notifications),
        //       onPressed: () {
        //         // Handle notification icon pressed
        //       },
        //     ),
        //   ],
        // ),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(140),
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                      height:  10, // Adjust height as needed
                    ),
                  // SizedBox(
                  //   height: kToolbarHeight + 10, // Adjust height as needed
                  // ),
                  Center(
                    child: Text(
                      'Reports and Statistics',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        // Adjust size as needed
                        // Add other styling properties as needed
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TabBar(
                    tabs: [
                      Tab(text: 'Fatigue Report'),
                      Tab(text: 'Eye Test Report'),
                      Tab(text: 'Other'),
                    ],
                    labelColor: Colors.bluebutton,
                    unselectedLabelColor: Colors.black,
                    labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    unselectedLabelStyle: TextStyle(fontSize: 14),
                  ),
                ],
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

        body: TabBarView(
          children: [
            buildFatigueReport(
              context,
            ),
            buildEyeTestReport(context),
            buildOtherReport(context),
          ],
        ),
        floatingActionButtonLocation:
        FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0), // Add padding
          child: ClipOval(
            child: Material(
              color: Colors.white, // Background color
              elevation: 1.0, // Shadow
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
                      padding: const EdgeInsets.all(8.0),
                      // Add padding for the icon
                      child: Image.asset(
                        "assets/home_icon.png",
                        width: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomAppBar(currentScreen: 'ReportPage',),
      ),
    );
  }

  Widget buildFatigueReport(BuildContext context) {
    return SingleChildScrollView(
      child: Column(

        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // const Padding(
          //   padding: EdgeInsets.fromLTRB(16.0, 10, 0, 10),
          //   child: Text(
          //     'EYE HEALTH GRAPH OVERVIEW', // Display formatted current date
          //     style: TextStyle(
          //       fontSize: 18,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          // ),
          Container(
            color: Colors.white,

            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: 8.0, vertical: 1),
              child: Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                child: Card(
                  color: Colors.white,
                  elevation: 0.1,
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
                      if(chartData!=null)...{
                        Center(

                          child: Container(
                            color: Colors.white,

                            child: _buildVerticalSplineChart(),


                          ),
                        ),
                        SizedBox(height: 10), // Adjust spacing between chart and color descriptions

                        // Color descriptions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildColorDescription(Colors.black, 'First Test'),
                            _buildColorDescription(Colors.green, 'Ideal'),
                            _buildColorDescription(Colors.orange, 'Percentile'),
                            _buildColorDescription(Colors.blue, 'User avg'),
                          ],
                        ),},
                      SizedBox(height: 29),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10,),
          ListView.builder(

            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Card(
                color: Colors.white,
                elevation: 0.4,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17.0),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 11),
                  child: ListTile(
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Date: ' + items[index].toString().substring(0, 10),
                            style: TextStyle(fontStyle: FontStyle.normal),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'Test Result : ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            Builder(
                              builder: (context) {
                                if (percentage[index] > 5.0) {
                                  testResult = "Good";
                                } else {
                                  testResult = "Bad";
                                }
                                return Text(
                                  testResult,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: testResult == 'Good'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                );
                              },
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => ReportDetails(
                                          reportId: ReportIds[index],
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.bluebutton,
                                    shape: CircleBorder(),
                                    minimumSize: Size(30, 30),
                                  ),
                                  child: Transform.rotate(
                                    angle: -pi / 1,
                                    child: Transform.scale(
                                      scale: 0.6,
                                      child: Icon(Icons.arrow_back_ios_new),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
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


  SfCartesianChart _buildVerticalSplineChart() {
    return SfCartesianChart(
      isTransposed: false,
      // title: ChartTitle(text:  'EYE Health Graph - 2024'),
      plotAreaBorderWidth: 0,
      legend: Legend(isVisible:true),
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
          color: Colors.black,
          animationDuration: 0.0,
          cardinalSplineTension: 0.5,
          splineType: SplineType.monotonic,
          xValueMapper: (_ChartData sales, _) => sales.x,
          yValueMapper: (_ChartData sales, _) => sales.y,
          name: 'First Test'),
      SplineSeries<_ChartData, String>(
        markerSettings: const MarkerSettings(isVisible: true),
        dataSource: chartData,
        name: 'Ideal',
        color: Colors.green,
        animationDuration: 0.0,
        cardinalSplineTension: 0.5,
        splineType: SplineType.monotonic,
        xValueMapper: (_ChartData sales, _) => sales.x,
        yValueMapper: (_ChartData sales, _) => sales.y2,
      ),
      SplineSeries<_ChartData, String>(
        markerSettings: const MarkerSettings(isVisible: true),
        dataSource: chartData,
        cardinalSplineTension: 0.5,
        splineType: SplineType.monotonic,
        animationDuration: 0.0,
        name: 'over 3.5 lac users',
        color: Colors.orange,
        xValueMapper: (_ChartData sales, _) => sales.x,
        yValueMapper: (_ChartData sales, _) => sales.y3,
      ),
      SplineSeries<_ChartData, String>(
        markerSettings: const MarkerSettings(isVisible: true),
        dataSource: chartData,
        color: Colors.blue,
        name: 'User avg',
        animationDuration: 0.0,
        cardinalSplineTension: 0.5,
        splineType: SplineType.monotonic,
        xValueMapper: (_ChartData sales, _) => sales.x,
        yValueMapper: (_ChartData sales, _) => sales.y4,
      )
    ];
  }

  Map<String, dynamic>? apiData;
  Widget buildEyeTestReport(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: apiData?['data'].length, // Assuming apiData is your response object
            itemBuilder: (context, index) {
              final eyeTest = apiData?['data'][index];
              return Card(
                color: Colors.white,
                elevation: 0.4,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17.0),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 11),
                  child: ListTile(
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Date: ' + eyeTest['created_on'].toString().substring(0, 10),
                            style: TextStyle(fontStyle: FontStyle.normal),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'Name : ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              eyeTest['user_profile']['full_name'],
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: eyeTest['test_result'] == 'Good'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => EyeTestReport(
                                          reportId: eyeTest['report_id'],
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.bluebutton,
                                    shape: CircleBorder(),
                                    minimumSize: Size(30, 30),
                                  ),
                                  child: Transform.rotate(
                                    angle: -pi / 1,
                                    child: Transform.scale(
                                      scale: 0.6,
                                      child: Icon(Icons.arrow_back_ios_new),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }


/*
  Widget buildOtherReport(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              final prescription = prescriptions[index];
              return Card(
                color: Colors.white,
                elevation: 1,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17.0),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 11),
                  child: ListTile(
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prescription.problemFaced,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Colors.bluebutton,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Date: ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                prescription.createdOn.toLocal().toString().substring(0, 10),
                                style: TextStyle(
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PrescriptionDetailPage(prescription: prescription),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.bluebutton,
                                    shape: CircleBorder(),
                                    minimumSize: Size(30, 30),
                                  ),
                                  child: Transform.rotate(
                                    angle: pi, // Correct rotation angle to 180 degrees
                                    child: Transform.scale(
                                      scale: 0.6,
                                      child: Icon(Icons.arrow_back_ios_new),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    ],
      ),);
  }
*/
  Widget buildOtherReport(BuildContext context) {
    return Scaffold(
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrescriptionUpload(),
                  ),
                );
              },
              backgroundColor: Colors.bluebutton, // Set the background color of the FAB
              child: Icon(Icons.camera_enhance_outlined, color: Colors.white), // Set the icon of the FAB
            ),
          ),
     /*     Padding(
            padding: const EdgeInsets.all(8.0),
            child: Positioned(
              bottom: 10,
              right: 10,
              child: Text(
                'Upload Prescription',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),*/
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: prescriptions.length,
              itemBuilder: (context, index) {
                final prescription = prescriptions[index];
                return Card(
                  color: Colors.white,
                  elevation: 1,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17.0),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 2, vertical: 11),
                    child: ListTile(
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prescription.problemFaced,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.bluebutton,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Date: ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  prescription.createdOn.toLocal().toString().substring(0, 10),
                                  style: TextStyle(
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PrescriptionDetailPage(prescription: prescription),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.bluebutton,
                                      shape: CircleBorder(),
                                      minimumSize: Size(30, 30),
                                    ),
                                    child: Transform.rotate(
                                      angle: pi, // Correct rotation angle to 180 degrees
                                      child: Transform.scale(
                                        scale: 0.6,
                                        child: Icon(Icons.arrow_back_ios_new),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  Future getPrescriptionFiles() async {
    var sharedPref = await SharedPreferences.getInstance();
    String userToken = sharedPref.getString("access_token") ?? '';
    try {
      Map<String, String> headers = {
        'Authorization': 'Bearer $userToken', // Bearer token type
        // 'Content-Type': 'application/json',
      };
      // Make the API request to fetch project sites
      var response = await Dio().get(
          "${ApiProvider.baseUrl}${ApiProvider.uploadPrescription}",
          options: Options(headers: headers));
      dynamic logger = Logger();

      logger.d(response.data);
      // Check the response status code
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.toString());

        prescriptions = (data['data'] as List)
            .map((item) => Prescription.fromJson(item))
            .toList();

        /*  Map<String, dynamic> data = json.decode(response.toString());
        List<dynamic> prescriptionFiles = data['data']; // Specify the file name
        List<String> prescriptionNames = [];
        isLoading = false;
        for (var fileEntry in prescriptionFiles) {
          String invoiceFile = fileEntry['file'];
          String date = fileEntry['created_on'];
          String status = fileEntry['status'];

          String images = fileEntry['file'];
         // image.add(images);


          String prescription_id = fileEntry['prescription_id'];

          prescriptionNames.add(invoiceFile);
        //  dates.add(date);
       //   statuses.add(status);
        //  prescriptionid.add(prescription_id);
        }
        print('Purchase Orderdd: $prescriptionNames');
        // Extract the invoice_file values and create PlatformFile objects
        List<PlatformFile> platformFiles = [];
        for (var fileEntry in prescriptionFiles) {
          String invoiceFilePath = fileEntry['file'];
          PlatformFile platformFile = PlatformFile(
            name: invoiceFilePath.split('/').last,
            size: 0, // Set appropriate file size
            bytes: null, // Set appropriate file bytes
          );
          platformFiles.add(platformFile);
        }
      //  _files.addAll(platformFiles);

        setState(() {});*/
      } else {
        // If the request was not successful, throw an error
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      // If an error occurs during the request, throw the error
      throw Exception('Failed to load data: $e    $stacktrace');
    }
  }

  Future<void> getReports() async {
    // try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('access_token') ?? '';
    final response = await http.get(
      Uri.parse('${ApiProvider.baseUrl}/api/fatigue/fatigue-reports'),
      headers: <String, String>{
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        isLoading = false;
        itemsdata = responseData['data'];
        for (int i = 0; i < itemsdata.length; i++) {
          int id = json.decode(response.body)['data'][i]['report_id'];
          String date = json.decode(response.body)['data'][i]['created_on'];
          dynamic percentage_ =
          json.decode(response.body)['data'][i]['percentage'];
          ReportIds.add(id);
          items.add(date);
          percentage.add(percentage_);
        }
      });
    } else {
      print(response.body);
    }
    /*  } catch (e) {
      print("exception:$e");
    }*/
  }
  Future<void> geteyeReports() async {
    //try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('access_token') ?? '';
    final response = await http.get(
      Uri.parse('${ApiProvider.baseUrl}/api/eye/reports'),
      headers: <String, String>{
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        isLoading = false;
        dynamic logger = Logger();

        logger.d('ddddd${responseData}');
        apiData= responseData;
        /*   itemsdata = responseData['data'];
        for (int i = 0; i < itemsdata.length; i++) {
          int id = json.decode(response.body)['data'][i]['report_id'];
          String date = json.decode(response.body)['data'][i]['created_on'];
          dynamic percentage_ =
          json.decode(response.body)['data'][i]['percentage'];
          ReportIds.add(id);
          items.add(date);
          percentage.add(percentage_);
        }*/
      });
    }
    else {
      print(response.body);
    }
    /*    }  catch (e) {
      print("exception:$e");
    }*/
  }
}

class Prescription {
  final String prescriptionId;
  final DateTime createdOn;
  final DateTime updatedOn;
  final String uploadedFile;
  final String status;
  final String rejectionNotes;
  final String problemFaced;
  final String user;

  Prescription({
    required this.prescriptionId,
    required this.createdOn,
    required this.updatedOn,
    required this.uploadedFile,
    required this.status,
    required this.rejectionNotes,
    required this.problemFaced,
    required this.user,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      prescriptionId: json['prescription_id'],
      createdOn: DateTime.parse(json['created_on']),
      updatedOn: DateTime.parse(json['updated_on']),
      uploadedFile: json['uploaded_file'],
      status: json['status'],
      rejectionNotes: json['rejection_notes'],
      problemFaced: json['problem_faced'],
      user: json['user'],
    );
  }
}

class PrescriptionDetailPage extends StatelessWidget {
  final Prescription prescription;

  PrescriptionDetailPage({required this.prescription});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Prescription Details'),backgroundColor: Colors.white,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Problem Faced: ${prescription.problemFaced}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Created On: ${prescription.createdOn.toLocal().toString().substring(0, 10)}',
                style: TextStyle(fontSize: 16),
              ),
              /*   SizedBox(height: 10),
              Text(
                'Updated On: ${prescription.updatedOn.toLocal().toString().substring(0, 10)}',
                style: TextStyle(fontSize: 16),
              ),*/
              SizedBox(height: 10),
              Text(
                'Status: ${prescription.status}',
                style: TextStyle(
                  fontSize: 16,
                  color: _getStatusColor(prescription.status),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Rejection Notes: ${prescription.rejectionNotes}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              SizedBox(height: 20),
              prescription.uploadedFile.endsWith('.pdf')
                  ? ElevatedButton(
                onPressed: () {
                  _launchURL('${ApiProvider.baseUrl}${prescription.uploadedFile}');
                },
                child: Text('View PDF'),
              )
                  : Image.network(
                '${ApiProvider.baseUrl}${prescription.uploadedFile}',
                errorBuilder: (context, error, stackTrace) {
                  return Text('Failed to load image');
                },
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.bluebutton,
                  foregroundColor: Colors.white,// Background color of the button
                  textStyle: TextStyle(fontSize: 16), // Text style of the button label
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Padding around the button's content
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Border radius of the button
                ),
                onPressed: () {
                  _launchURL('${ApiProvider.baseUrl}${prescription.uploadedFile}');
                },
                icon: Icon(Icons.download),
                label: Text('Download File'),
              ),

            ],
          ),
        ),
      ),
    );
  }
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return Colors.green;
    case 'pending':
      return Colors.yellow;
    case 'rejected':
      return Colors.red;
    default:
      return Colors.black;
  }
}


