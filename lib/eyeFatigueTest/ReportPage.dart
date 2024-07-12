
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
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:second_eye/HomePage.dart';
import 'package:second_eye/Rewards/rewards_sync.dart';
import 'package:second_eye/api/Api.dart';
import 'package:second_eye/digitalEyeTest/EyeTestReportDetail.dart';
import 'package:second_eye/digitalEyeTest/TestReport.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Custom_navbar/bottom_navbar.dart';
import '../api/config.dart';
import '../models/fatigueGraphModel.dart';
import '../notification/notification_dashboard.dart';
import '../sign_up.dart';
import 'EyeFatigueSelfieScreen.dart';
import 'FatigueReportDetails.dart';
import 'eyeFatigueTest.dart';

class ReportPage extends StatefulWidget {
  @override
  ReportPageState createState() => ReportPageState();
}
class _ChartData {
  _ChartData(this.x, this.y4, this.y2, this.y3, this.y);
  final String x;
  final double y;
  final double y2;
  final double y3;
  final double y4;

}
class ReportPageState extends State<ReportPage> with AutoCancelStreamMixin {

  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey();
  int? isReadFalseCount = 0;
  bool isLoading = false;
  List<double> idealTestgraphData = [];
  List<double> populationTestgraphData = [];
  List<dynamic> percentage = [];

  String testResult = 'Good';
  int count = 0;
  List<Prescription> prescriptions = [];
  fatigueGraph? fatigueGraphData;
  bool midtiredness_right = false;
  List<double> todaygraphData = [];
  List<double> firstTestgraphData = [];
  List<_ChartData>? chartData;

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
   // getNotifactionCount();
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

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMMM').format(DateTime.now());
    return  WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop();
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) =>   HomePage()),
      // );
      return true; // Example: always allow back navigation
    },child :isLoading
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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Stack(
            children: [
              // Align(
              //   alignment: Alignment.topLeft,
              //   child: IconButton(
              //     icon: const Icon(
              //       Icons.arrow_back,
              //       color: Colors.black,
              //     ),
              //     iconSize: 28, // Back button icon
              //     onPressed: () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(builder: (context) => HomePage()),
              //       );
              //     },
              //   ),
              // ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 10, // Adjust height as needed
                  ),
                  // SizedBox(
                  //   height: kToolbarHeight + 10, // Adjust height as needed
                  // ),
                  Center(
                    child: Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 8.0,vertical: 9),
                      child: Text(
                        'Reports and Statistics',
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          // Adjust size as needed
                          // Add other styling properties as needed
                        ),),
                    ),

                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0,),
                    child: Text(
                      'Today $formattedDate', // Display formatted current date
                      style:
                      TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
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
                        top: -1,
                        // Adjust this value to position the text properly
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
        body: Container(
          margin: const EdgeInsets.only(bottom: 50),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[

                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: GestureDetector(
                  onTap: (){
                    Navigator.push(context,
                        CupertinoPageRoute(builder:
                            (context) =>
                            _ReportFatigueTest()//change this in final step  SecondScreen
                        )
                    ) ;
                  },
                    child: Card(
                      color: Colors.white,
                      elevation: 2,
                      child: Row(
                        children: [

                          // Image on the left side
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/fatigue.png',
                              // Add any additional properties to style the image
                            ),
                          ),
                          // Columns on the right side
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      'Eye Fatigue Test',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 4.0,
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      'Discover your eye fatigue level in just 2 minutes with our quick reading assessment.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
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
                ), // Add spacing between titles and dynamic list
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context,
                          CupertinoPageRoute(builder:
                              (context) =>
                              _ReportEyeTest()//change this in final step  SecondScreen
                          )
                      ) ;
                    },
                    child: Card(color: Colors.white,
                      elevation: 2,
                      child: Row(
                        children: [
                          // Image on the left side
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.asset(
                              'assets/eye.png',
                              // Add any additional properties to style the image
                            ),
                          ),
                          // Columns on the right side
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 4.0,
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      'Eye Test Reports',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 4.0,
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      'Check your vision and generate a prescription estimate, all from the comfort of your home.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
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
                ),

                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context,
                          CupertinoPageRoute(builder:
                              (context) =>
                              _ReportOther()//change this in final step  SecondScreen
                          )
                      ) ;
                    },
                    child: Card(
                      color: Colors.white,
                      elevation: 2,
                      child: Row(
                        children: [
                          // Image on the left side
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.asset(
                              'assets/document_upload.png',
                              // Add any additional properties to style the image
                            ),
                          ),
                          // Columns on the right side
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 4.0,
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      'Upload Prescription',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 4.0,
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      'upload Prescription and keep the record at one place, also uploading correct prescription will help you to Earn Rewards.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
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
                ),
                SizedBox(height: 80,),

              ],
            ),
          ),
        ), /*TabBarView(
          children: [
            buildFatigueReport(
              context,
            ),
            buildEyeTestReport(context),
            buildOtherReport(context),
          ],
        ),*/
        // floatingActionButtonLocation:
        // FloatingActionButtonLocation.centerDocked,
        // floatingActionButton: Padding(
        //   padding: const EdgeInsets.all(8.0), // Add padding
        //   child: ClipOval(
        //     child: Material(
        //       color: Colors.white70.withOpacity(0.9), // Background color
        //       elevation: 1.0, // Shadow
        //       child: InkWell(
        //         onTap: () {
        //           // Navigator.of(context).pop();
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
        //               padding: const EdgeInsets.all(8.0),
        //               // Add padding for the icon
        //               child: Image.asset(
        //                 "assets/home_icon.jpg",
        //                 width: 20,
        //               ),
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        // bottomNavigationBar: CustomBottomAppBar(currentScreen: 'ReportPage',),
      ),
    ) );
  }


}
class _ReportOther extends StatefulWidget {
  @override
  _ReportOtherState createState() => _ReportOtherState();
}
class _ReportOtherState extends State<_ReportOther> {
  @override
  void initState() {
    getPrescriptionFiles();
    super.initState();

  }
  List<Prescription> prescriptions = [];
  List<dynamic> itemsdata = [];
  List<dynamic> items = [];
  List<dynamic> ReportIds = [];
  bool isLoading= true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text('My Prescriptions',              style: TextStyle(fontWeight: FontWeight.w600,fontSize: 17),
          ),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      floatingActionButton: Padding(
        padding:  EdgeInsets.only(bottom: MediaQuery.of(context).size.width/4),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrescriptionUpload(),
              ),
            );
          },
          backgroundColor: Colors.bluebutton,
          child: Container(
            // margin:  EdgeInsets.only(bottom: MediaQuery.of(context).size.width),
              child: Icon(Icons.camera_enhance_outlined, color: Colors.white)),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if(prescriptions==null||prescriptions.isEmpty)...{
            Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 30),
            Image.asset(
            'assets/error.png', // Replace with your image path
            width: 200, // Adjust width as needed
            height: 250, // Adjust height as needed
            ),
            SizedBox(height: 20), // Adjust spacing between image and text

            Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
            'No prescription is uploaded yet... upload new prescription to get points!',
            textAlign: TextAlign.center,
            style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            ),
            ),
            ),
            ],
            ),
            ),
            },
            Padding(
              padding: const EdgeInsets.fromLTRB(0,0,0,50),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: prescriptions.length,
                itemBuilder: (context, index) {
                  final prescription = prescriptions[index];
                  return Card(
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17.0),
                      side: BorderSide(color: Colors.grey.shade400, width: 1.0),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 11),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                prescription.problemFaced,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Colors.greytext,
                                ),
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
                                    style: TextStyle(fontStyle: FontStyle.normal),
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
                                            builder: (context) =>
                                                PrescriptionDetailPage(prescription: prescription),
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
                                        angle: pi,
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
            ),
            SizedBox(height: 80,),

          ],
        ),
      ),

    );
  }


  List<dynamic> percentage = [];
  Future<void> getPrescriptionFiles() async {
    var sharedPref = await SharedPreferences.getInstance();
    String userToken = sharedPref.getString("access_token") ?? '';
    try {
      Map<String, String> headers = {
        'Authorization': 'Bearer $userToken',
      };

      var response = await Dio().get(
        "${ApiProvider.baseUrl}${ApiProvider.uploadPrescription}",
        options: Options(headers: headers),
      );

      dynamic logger = Logger();
      logger.d(response.data);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.toString());
        setState(() {
          prescriptions = (data['data'] as List)
              .map((item) => Prescription.fromJson(item))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load data: $e $stacktrace');
    }
  }
}
class _ReportFatigueTest extends StatefulWidget {
  @override
  __ReportFatigueTestState createState() => __ReportFatigueTestState();
}
class __ReportFatigueTestState extends State<_ReportFatigueTest> {
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey();
  int? isReadFalseCount = 0;
  bool isLoading = true;
  List<double> idealTestgraphData = [];
  List<double> populationTestgraphData = [];
  List<dynamic> percentage = [];

  String testResult = 'Good';
  int count = 0;
  double first_day_data=0.0;double current_day_data=0.0;double get_percentile_graph=0.0;double get_ideal_graph=0.0;
  List<Prescription> prescriptions = [];
  fatigueGraph? fatigueGraphData;
  bool midtiredness_right = false;
  List<double> todaygraphData = [];
  List<double> firstTestgraphData = [];
  List<_ChartData>? chartData;
  List<dynamic> itemsdata = [];
  @override
  void initState() {
    getGraph();
    getReports();
    super.initState();
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
            print("response-"+response.body);

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
  Future<void> getGraph() async {
  // try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('access_token') ?? '';
    final response = await http.get(
      Uri.parse('${ApiProvider
          .baseUrl}/api/fatigue/fatigue-graph?user_timezone=Asia/Kolkata'),
      headers: <String, String>{
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      fatigueGraphData = fatigueGraph.fromJson(responseData);

      print("graphdata===:${response.body}");

      Map<String, dynamic> jsonResponse = json.decode(response.body);

      // Accessing eye_health_score from the JSON response
      // List<dynamic> data = jsonData['data'];
      setState(() {
        count=jsonResponse['no_of_fatigue_test'];
        first_day_data=jsonResponse['first_day_data'].toDouble();
        current_day_data=jsonResponse['current_day_data'].toDouble();
        get_percentile_graph=jsonResponse['get_percentile_graph'].toDouble();
        get_ideal_graph=jsonResponse['get_ideal_graph'].toDouble();
      });


      // if (responseData.containsKey('status') && responseData['status']) {
      //   if (responseData.containsKey('first_day_data') &&
      //       responseData['first_day_data'].containsKey('value')) {
      //     List<
      //         dynamic> firstDayValue = responseData['first_day_data']['value'];
      //     firstTestgraphData.addAll(
      //         firstDayValue.map((value) => value.toDouble()));
      //   }
      //   if (responseData.containsKey('current_day_data') &&
      //       responseData['current_day_data'].containsKey('value')) {
      //     List<
      //         dynamic> currentDayValue = responseData['current_day_data']['value'];
      //     todaygraphData.addAll(
      //         currentDayValue.map((value) => value.toDouble()));
      //   }
      //   if (responseData.containsKey('get_percentile_graph')) {
      //     List<dynamic> population = List<double>.from(
      //         jsonData['get_percentile_graph']);
      //
      //     populationTestgraphData.addAll(
      //         population.map((value) => value.toDouble()));
      //   }
      //   if (responseData.containsKey('get_ideal_graph')) {
      //     List<dynamic> ideal = List<double>.from(
      //         jsonData['get_ideal_graph']);
      //
      //     idealTestgraphData.addAll(ideal.map((value) => value.toDouble()));
      //   }
      // }
      // print("fffffffffffffff$todaygraphData");
      // setState(() {
      //   chartData = <_ChartData>[
      //     _ChartData('6 AM', todaygraphData[0], idealTestgraphData[0],
      //         populationTestgraphData[0], firstTestgraphData[0]),
      //     _ChartData('9 AM', todaygraphData[1], idealTestgraphData[1],
      //         populationTestgraphData[1], firstTestgraphData[1]),
      //     _ChartData('12 PM', todaygraphData[2], idealTestgraphData[2],
      //         populationTestgraphData[2], firstTestgraphData[2]),
      //     _ChartData('3 PM', todaygraphData[3], idealTestgraphData[3],
      //         populationTestgraphData[3], firstTestgraphData[3]),
      //     _ChartData('6 PM', todaygraphData[4], idealTestgraphData[4],
      //         populationTestgraphData[4], firstTestgraphData[4]),
      //     _ChartData('9 PM', todaygraphData[5], idealTestgraphData[5],
      //         populationTestgraphData[5], firstTestgraphData[5]),
      //     _ChartData('12 AM', todaygraphData[6], idealTestgraphData[6],
      //         populationTestgraphData[6], firstTestgraphData[6]),
      //
      //
      //   ];
      // });
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
    } else {
      print(response.body);
    }
  // } catch (e) {
  //   // _progressDialog!.hide();
  //
  //   print("exception:$e");
  // }
  // throw Exception('');
}
  List<dynamic> ReportIds = [];
  List<dynamic> items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Padding(
            padding:  EdgeInsets.symmetric(vertical: 12.0),
            child: Text('Eye Fatigue Test Report',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
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

                                DotWithLabel( index:2,label: 'Your Avg. Score',point:current_day_data.toDouble(),),
                                Divider(
                                  height: 5,
                                  thickness: 0.5,
                                  color: Colors.grey[400],
                                  indent: 20,
                                  endIndent: 20,
                                ),
                                SizedBox(height: 7,),

                                DotWithLabel(index: 3, label: 'Your First Score',point:first_day_data.toDouble(),),//color: Colors.black,
                              ],
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
    SizedBox(height: 30),
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 30),
            Image.asset(
              'assets/error.png', // Replace with your image path
              width: 200, // Adjust width as needed
              height: 250, // Adjust height as needed
            ),
            SizedBox(height: 20), // Adjust spacing between image and text

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'No Reports to Show',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    SizedBox(height: 30),

    },
                       // },


                        SizedBox(height: 29),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
                    side: BorderSide(color: Colors.grey.shade400, width: 1.0),
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
                                'Test Score : ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              Builder(
                                builder: (context) {
                                  int score=0;
                                  score=percentage[index];
                                  if (percentage[index] > 5.0) {
                                    testResult = 'Good';

                                  } else {
                                    testResult = "Bad";
                                  }
                                  return Text(
                                    score.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: testResult == 'Good' ? Colors.green : Colors.red,
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
                                          builder: (context) => ReportDetails(reportId: ReportIds[index]),
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
                                      angle: -pi,
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
SizedBox(height: 80,),
          ],
        ),
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

  void requestPermission() async {
    PermissionStatus status = await Permission.camera.status;
    PermissionStatus status2 = await Permission.microphone.status;

    if((status==PermissionStatus.granted&&status2==PermissionStatus.granted) ){
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
        //   MaterialPageRoute(
        //       builder: (context) => EyeFatigueSelfieScreen()),
        // );
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
    // title: ChartTitle(text:  'EYE Health Graph - 2024'),
    plotAreaBorderWidth: 0,
    legend: Legend(isVisible: true),
    primaryXAxis: const CategoryAxis(
      majorTickLines: MajorTickLines(size: 0),
      axisLine: AxisLine(width: 0.3),
      majorGridLines: MajorGridLines(width: 0),
      title: AxisTitle(text: 'time slots  (x-axis) --->'),
    ),
    // Disable vertical inner gridlines

    primaryYAxis: const NumericAxis(
      minimum: 0,
      maximum: 11,
      interval: 1,
      labelFormat: '{value}',
      title: AxisTitle(text: 'eye score  (y-axis)  --->'),
      // Description for X axis
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


}
class _ReportEyeTest extends StatefulWidget {
  @override
  __ReportEyeTestState createState() => __ReportEyeTestState();
}
class __ReportEyeTestState extends State<_ReportEyeTest> {
  Map<String, dynamic>? apiData;
  bool isLoading = true;

  @override
  void initState() {
    geteyeReports();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text('Eye Test Report'
              ,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 17),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if( apiData?['data']==null|| apiData?['data'].isEmpty)...{
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 30),
                        Image.asset(
                          'assets/error.png', // Replace with your image path
                          width: 200, // Adjust width as needed
                          height: 250, // Adjust height as needed
                        ),
                        SizedBox(height: 20), // Adjust spacing between image and text

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            'No test is done yet... please do digital eye test first', // Display formatted current date
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                },
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: apiData?['data'].length ?? 0,
                  itemBuilder: (context, index) {
                    final eyeTest = apiData?['data'][index];
                    return Card(
                      color: Colors.white,
                      elevation: 0.4,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17.0),
                        side: BorderSide(
                            color: Colors.grey.shade400, width: 1.0), // Add this line to set the border color and width
                      ),
                      child: Container(
                        height: 110,
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
          ),
          SizedBox(height: 80,)
        ],
      ),
    );
  }
  Future<void> geteyeReports() async {
    try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('access_token') ?? '';
    final response = await http.get(
      Uri.parse('${ApiProvider.baseUrl}/api/eye/reports'),
      headers: <String, String>{
        'Authorization': 'Bearer $authToken',
      },
    );
    print('ddddd${response.body}');


    if (response.statusCode ==  200) {
      final responseData = json.decode(response.body);

      print('ddddd${responseData}');

      setState(() {
        isLoading = false;

       // logger.d('ddddd${responseData}');
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
        }  catch (e) {
      print("exception:$e");
    }
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
              if( prescription.rejectionNotes.isNotEmpty)
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
              const SizedBox(
                height: 80,
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


