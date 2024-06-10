import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_new/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Custom_navbar/customDialog.dart';

import '../api/Api.dart';
import '../api/config.dart';
import 'testScreen.dart';

class EyeTestReport extends StatefulWidget {
  final int reportId;

  EyeTestReport({required this.reportId});

//for Red Green Test Screen
  @override
  TestReportState createState() => TestReportState();
}

class TestReportState extends State<EyeTestReport> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    GenerateReport(widget.reportId);
  }

  String left_eye = "a",
      left_sph = "b",
      left_cyl = "c",
      left_axis = "d",
      left_add = "a",
      name = "a",
      age = "a";
  String right_eye = "a",
      right_sph = "a",
      right_cyl = "a",
      right_axis = "a",
      right_add = "a";
  TextEditingController textEditingController1 = TextEditingController();
  Future<void> GenerateReport(int reportId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String access_token = prefs.getString('access_token') ?? '';
// Replace this with your PUT request body
    try {
      final response = await http.get(
        Uri.parse('${ApiProvider.baseUrl}/api/eye/reports?report_id=$reportId'),
        headers: <String, String>{
          'Authorization': 'Bearer $access_token',
        },
      );

      print("dddddddddd${response.body}");
      if (response.statusCode == 200) {
        Map<String, dynamic> parsedJson = jsonDecode(response.body);
        if (parsedJson['status'] == true && parsedJson['status_code'] == 200) {
          List<dynamic> tests = [
            parsedJson['data']['right_eye'],
            parsedJson['data']['left_eye']
          ];
          name = parsedJson['data']['user_profile']['full_name'];
          age = parsedJson['data']['user_profile']
              ['age']; // Assuming you get age data from somewhere else

          for (var test in tests) {
            String eyeStatus = test['eye_status'];
            String Test = test['test'];
            if (Test == 'myopia') {
              if (eyeStatus == 'left') {
                left_sph = test['myopia_sph_power'] ?? '';
                left_eye = test['eye_status'] ?? '';
                left_cyl = test['cyl_power'] ?? '';
                left_axis = test['degree'] ?? '';
                left_add = test['age_power'] ?? '';
                left_add = left_add.isEmpty ? '-' : left_add;
                left_axis = left_axis.isEmpty ? '-' : left_axis;
                left_cyl = left_cyl.isEmpty ? '-' : left_cyl;
                left_sph = left_sph.isEmpty ? '-' : left_sph;
                left_eye = left_eye.isEmpty ? '-' : left_eye;
              }
              if (eyeStatus == 'right') {
                right_sph = test['myopia_sph_power'] ?? '';
                right_eye = test['eye_status'] ?? '';
                right_cyl = test['cyl_power'] ?? '';
                right_axis = test['degree'] ?? '';
                right_add = test['age_power'] ?? '';
                right_add = right_add.isEmpty ? '-' : right_add;
                right_axis = right_axis.isEmpty ? '-' : right_axis;
                right_cyl = right_cyl.isEmpty ? '-' : right_cyl;
                right_sph = right_sph.isEmpty ? '-' : right_sph;
                right_eye = right_eye.isEmpty ? '-' : right_eye;
              }
            } else {
              if (eyeStatus == 'left') {
                left_sph = test['hyperopia_sph_power'] ?? '';
                left_eye = test['eye_status'] ?? '';
                left_cyl = test['cyl_power'] ?? '';
                left_axis = test['degree'] ?? '';
                left_add = test['age_power'] ?? '';
                left_add = left_add.isEmpty ? '-' : left_add;
                left_axis = left_axis.isEmpty ? '-' : left_axis;
                left_cyl = left_cyl.isEmpty ? '-' : left_cyl;
                left_sph = left_sph.isEmpty ? '-' : left_sph;
                left_eye = left_eye.isEmpty ? '-' : left_eye;
              }
              if (eyeStatus == 'right') {
                right_sph = test['hyperopia_sph_power'] ?? '';
                right_eye = test['eye_status'] ?? '';
                right_cyl = test['cyl_power'] ?? '';
                right_axis = test['degree'] ?? '';
                right_add = test['age_power'] ?? '';
                right_add = right_add.isEmpty ? '-' : right_add;
                right_axis = right_axis.isEmpty ? '-' : right_axis;
                right_cyl = right_cyl.isEmpty ? '-' : right_cyl;
                right_sph = right_sph.isEmpty ? '-' : right_sph;
                right_eye = right_eye.isEmpty ? '-' : right_eye;
              }
            }
          }
          setState(() {
            isLoading = false;
            left_cyl;
            left_eye;
            left_sph;
            left_axis;
            left_add;
            name;
            age;
            right_eye;
            right_add;
            right_axis;
            right_cyl;
            right_sph;
          });
        } else {
          print('Failed with status: ${parsedJson['status']}');
          print('Failed with status code: ${parsedJson['status_code']}');
          print('Failed with message: ${parsedJson['message']}');
        }
      }
    } catch (e) {
      if (e is SocketException) {
        CustomAlertDialog.eyetstcomplete(
            context, 'poor internet connectivity , please try again later!');
      }

// If the server returns an error response, throw an exception
      throw Exception('Failed to send data');
    }
  }

  final List<String> bulletPoints = [
    // existing bullet points
    'The results displayed are for reference purposes only.',
    'If you feel the power displayed is different than your old power, then please speak with your eye doctor or call EyeMyEye and speak with the optometrist.',
    'Without confirmation from your eye doctor or EyeMyEye optometrist, do not use this power to make glasses.'
  ];

  Future<void> SubmitFeedback() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String access_token = prefs.getString('access') ?? '';
    final String apiUrl =
        'https://testing1.zuktiapp.zuktiinnovations.com/patient-feedback-api/';
// Replace these headers with your required headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
// Replace this with your PUT request body
    Map<String, dynamic> body = {
      'patient_feedback': textEditingController1.text,
    };
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );
      print(response.body);
      if (response.statusCode == 200) {
        print('patient-feedback: ${response.body}');
// If the call to the server was successful, parse the JSON
        final jsonResponse = jsonDecode(response.body);
        String message = jsonResponse['message'];
        showCustomToast(context, message);
        textEditingController1.clear();
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      if (e is SocketException) {
        CustomAlertDialog.eyetstcomplete(
            context, 'poor internet connectivity , please try again later!');
      }

// If the server returns an error response, throw an exception
      throw Exception('Failed to send data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false,
          );
          return false;
        },
        child: MaterialApp(
            home: Scaffold(
                appBar: AppBar(
                  title: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Zukti',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.textblue,
                          ),
                        ),
                        TextSpan(
                          text: ' Eyetest Report',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  centerTitle: true,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.bluebutton),
                    onPressed: () {
                    Navigator.pop(context);
                    },
                  ),
                ),
                body: Stack(
                  children: <Widget>[
                    // Background Image
                    isLoading
                        ? Center(
                            // Show loader when isLoading is true
                            child: CircularProgressIndicator(),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: Container(
                                    child: Text(
                                      'Overall Ocular Wellnes', // Text content
                                      style: TextStyle(
                                        fontSize: 18, // Font size
                                        fontWeight:
                                            FontWeight.w500, // Font weight
                                        color: Colors.black, // Text color
                                        fontStyle:
                                            FontStyle.normal, // Font style
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.bordergrey),
                                      // Changed to Colors.grey
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(20),
                                          child: Text(
                                            'Patient Details', // Text content
                                            style: TextStyle(
                                              fontSize: 14,
                                              // Font size
                                              fontWeight: FontWeight.bold,
                                              // Font weight
                                              color: Colors.black,
                                              // Text color
                                              fontStyle: FontStyle
                                                  .normal, // Font style
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 13.0, vertical: 2),
                                          margin: EdgeInsets.all(8),
                                          // Adjust height as needed
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text('Full name',
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black)),
                                              Text(
                                                'Age',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                        VerticalBox(name: name, age: age),
                                        Padding(
                                          padding: EdgeInsets.all(10),
                                          child: const Text(
                                            'Patient Prescription', // Text content
                                            style: TextStyle(
                                              fontSize: 14,
                                              // Font size
                                              fontWeight: FontWeight.bold,
                                              // Font weight
                                              color: Colors.black,
                                              // Text color
                                              fontStyle: FontStyle
                                                  .normal, // Font style
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Table(
                                                  columnWidths: {
                                                    0: FlexColumnWidth(1),
                                                    1: FlexColumnWidth(1),
                                                    2: FlexColumnWidth(1),
                                                    3: FlexColumnWidth(1),
                                                    4: FlexColumnWidth(1),
                                                  },
                                                  children: [
                                                    TableRow(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            'EYE',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            'SPH',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            'CYL',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            'AXIS',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            'ADD',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            left_eye,
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .deepPurple,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            left_sph,
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            left_cyl,
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            left_axis,
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            left_add,
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            right_eye,
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .deepPurple,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            right_sph,
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            right_cyl,
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            right_axis,
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            right_add,
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        /*       Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: <Widget>[
                                                    Text(
                                                      'EYE',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.black),
                                                    ),
                                                    Text(
                                                      'SPH',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.black),
                                                    ),
                                                    Text(
                                                      'CYL',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.black),
                                                    ),
                                                    Text(
                                                      'AXIS',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.black),
                                                    ),
                                                    Text(
                                                      'ADD',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Add a divider between sections
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: <Widget>[
                                                    Text(
                                                      left_eye,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors
                                                              .deepPurple),
                                                    ),
                                                    Text(
                                                      left_sph,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.black),
                                                    ),
                                                    Text(
                                                      left_cyl,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.black),
                                                    ),
                                                    Text(
                                                      left_axis,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.black),
                                                    ),
                                                    Text(
                                                      left_add,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Add a divider between sections
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: <Widget>[
                                                    Text(
                                                      right_eye,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors
                                                              .deepPurple),
                                                    ),
                                                    Text(
                                                      right_sph,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.black),
                                                    ),
                                                    Text(
                                                      right_cyl,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.black),
                                                    ),
                                                    Text(
                                                      right_axis,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.black),
                                                    ),
                                                    Text(
                                                      right_add,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),*/
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16),
                                  child: Text(
                                    'Disclaimer',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors
                                          .textblue, // Changed to Colors.blue
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      bulletPoints.asMap().entries.map((entry) {
                                    int index = entry.key +
                                        1; // Serial number starting from 1
                                    String bullet = entry.value;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 16.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 4.0, left: 8),
                                            child: Text(
                                              '$index.',
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w500,
                                                color: Colors
                                                    .textblue, // Changed to Colors.blue
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Expanded(
                                            child: Text(
                                              bullet,
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w400,
                                                color: Colors
                                                    .textblue, // Changed to Colors.blue
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),

                                /*    Image.asset(
                                  width: MediaQuery.sizeOf(context).width,
                                  height: 30,
                                  'assets/report_banner.png',
                                ),*/

                                /*  Container(
                        width: 140,
                        height: 50,
                        child: Center(
                        child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.deepPurple, // Background color
                        padding: const EdgeInsets.all(10),
                        minimumSize: const Size(300, 30), // Button padding
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26), // Button border radius
                        ),
                        ),
                        onPressed: () {
                        Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(builder: (context) => HomePage()),
                        );
                        },
                        child: Text(
                        'Exit',
                        style: TextStyle(fontSize: 16), // Adjust text size here
                        ),
                        ),
                        ),
                        ),*/

                                // Space for the bottom banner
                              ],
                            ),
                          ),

                    // Bottom Banner

                    SizedBox(height: 60),
                  ],
                ))));
  }
}

class VerticalBox extends StatelessWidget {
  final String name;
  final String age;

  const VerticalBox({
    required this.name,
    required this.age,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13.0),
      margin: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '$name',
            style: TextStyle(
                fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          Text(
            '$age',
            style: TextStyle(
                fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
