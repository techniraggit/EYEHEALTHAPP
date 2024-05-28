import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_new/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Api.dart';
import '../customDialog.dart';
import 'testScreen.dart';

class TestReport extends StatefulWidget {
  const TestReport({super.key});

//for Red Green Test Screen
  @override
  TestReportState createState() => TestReportState();
}

class TestReportState extends State<TestReport> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    GenerateReport();
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

  Future<void> GenerateReport() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String access_token = prefs.getString('access_token') ?? '';
    String id = prefs.getString('test_id') ?? '';
    String CustomerId = prefs.getString('customer_id') ?? '';

    String test_id = id;
    final String apiUrl =
        '${Api.baseurl}/api/eye/generate-report?test_id=$test_id';
// Replace these headers with your required headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $access_token',
      'Customer-Id': CustomerId //$access_token
    };
// Replace this with your PUT request body
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
//body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> parsedJson = jsonDecode(response.body);
        if (parsedJson['status'] == true && parsedJson['status_code'] == 200) {
          List<dynamic> tests = [
            parsedJson['data']['right_eye'],
            parsedJson['data']['left_eye']
          ];
          name = parsedJson['data']['right_eye']['full_name'];
          // age = parsedJson['data']['age']; // Assuming you get age data from somewhere else

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
          });
        } else {
          print('Failed with status: ${parsedJson['status']}');
          print('Failed with status code: ${parsedJson['status_code']}');
          print('Failed with message: ${parsedJson['message']}');
        }
      }

      /* if (response.statusCode == 200) {
        print('generate_report: ${response.body}');
// If the call to the server was successful, parse the JSON
        Map<String, dynamic> parsedJson = jsonDecode(response.body);
        List<dynamic> tests = parsedJson['data']['test'];
        name = parsedJson['data']['right_eye']['full_name'];
        //age = parsedJson['data']['age'];
        for (var test in tests) {
          String eyeStatus = test['eye_status'];
          String Test =test['test'];
          if(Test=='myopia'){
            if (eyeStatus == 'left') {
              left_sph = test['myopia_sph_power'] ?? '';
              left_eye = test['eye_status'] ?? '';
              left_cyl = test['cyl_power'] ?? '';
              left_axis = test['degree'] ?? '';
              left_add = test['age_power'] ?? '';
              if(left_add.isEmpty){
                left_add='-';
              }
              if(left_axis.isEmpty){
                left_axis='-';
              }
              if(left_cyl.isEmpty){
                left_cyl='-';
              }
              if(left_sph.isEmpty){
                left_sph='-';
              }
              if(left_eye.isEmpty){
                left_eye='-';
              }
            }
            if (eyeStatus == 'right') {
              right_sph = test['myopia_sph_power'] ?? '';
              right_eye = test['eye_status'] ?? '';
              right_cyl = test['cyl_power'] ?? '';
              right_axis = test['degree'] ?? '';
              right_add = test['age_power'] ?? '';
              if(right_add.isEmpty){
                right_add='-';
              }
              if(right_axis.isEmpty){
                right_axis='-';
              }
              if(right_cyl.isEmpty){
                right_cyl='-';
              }
              if(right_sph.isEmpty){
                right_sph='-';
              }
              if(right_eye.isEmpty){
                right_eye='-';
              }
            }
          }else{
            if (eyeStatus == 'left') {
              left_sph = test['myopia_sph_power'] ?? '';
              left_eye = test['eye_status'] ?? '';
              left_cyl = test['cyl_power'] ?? '';
              left_axis = test['degree'] ?? '';
              left_add = test['age_power'] ?? '';
              if(left_add.isEmpty){
                left_add='-';
              }
              if(left_axis.isEmpty){
                left_axis='-';
              }
              if(left_cyl.isEmpty){
                left_cyl='-';
              }
              if(left_sph.isEmpty){
                left_sph='-';
              }
              if(left_eye.isEmpty){
                left_eye='-';
              }
            }
            if (eyeStatus == 'right') {
              right_sph = test['hypermyopia_sph_power'] ?? '';
              right_eye = test['eye_status'] ?? '';
              right_cyl = test['cyl_power'] ?? '';
              right_axis = test['degree'] ?? '';
              right_add = test['age_power'] ?? '';
              if(right_add.isEmpty){
                left_add='-';
              }
              if(right_axis.isEmpty){
                right_axis='-';
              }
              if(right_sph.isEmpty){
                right_axis='-';
              }
              if(right_sph.isEmpty){
                right_axis='-';
              }
              if(right_eye.isEmpty){
                right_axis='-';
              }
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
// If the server did not return a 200 OK response,
// handle the error here (display error message or take appropriate action)
        print('Failed with status code: ${response.statusCode}');
        print('Failed with : ${response.body}');
      }*/
    } catch (e) {
      if (e is SocketException) {
        CustomAlertDialog.eyetstcomplete(
            context, 'poor internet connectivity , please try again later!');
      }

// If the server returns an error response, throw an exception
      throw Exception('Failed to send data');
    }
  }

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
    return Scaffold(
        appBar: AppBar(
          title: Text("EYE TEST"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.bluebutton),
            onPressed: () {
              // Add your back button functionality here
            },
          ),
        ),
        body: Stack(fit: StackFit.expand, children: <Widget>[
          // Background Image
          Center(
            child: isLoading
                ? Center(
// Show loader when isLoading is true
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    //
                    //  child:SingleChildScrollView(

                    //mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      /**
                        Container(
                        child:Image.asset(
                        'assets/zukti_logo.png', // Replace with your logo path
                        width: 300, // Adjust width as needed
                        height: 150,
                        // Adjust height as needed
                        ),),**/

                      SizedBox(height: 80.0),
                      Container(
                        child: const Text(
                          'Patient Report', // Text content
                          style: TextStyle(
                            fontSize: 20, // Font size
                            fontWeight: FontWeight.bold, // Font weight
                            color: Color(0xFF1E3777), // Text color
                            fontStyle: FontStyle.normal, // Font style
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: const Text(
                          'Patient Details', // Text content
                          style: TextStyle(
                            fontSize: 12, // Font size
                            fontWeight: FontWeight.bold, // Font weight
                            color: Color(0xFF1E3777), // Text color
                            fontStyle: FontStyle.normal, // Font style
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10.0),
                        margin: EdgeInsets.all(8), // Adjust height as needed
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Full name',
                                style: TextStyle(
                                    fontSize: 16, color: Color(0xFF1E3777))),
                            Text(
                              'Age',
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF1E3777)),
                            ),
                          ],
                        ),
                      ),
                      VerticalBox(name: name, age: age),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: const Text(
                          'Patient Prescription', // Text content
                          style: TextStyle(
                            fontSize: 12, // Font size
                            fontWeight: FontWeight.bold, // Font weight
                            color: Color(0xFF1E3777), // Text color
                            fontStyle: FontStyle.normal, // Font style
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(12.0),
                        margin: EdgeInsets.all(8), // Adjust height as needed
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text(
                              'EYE',
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF1E3777)),
                            ),
                            Text(
                              'SPH',
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF1E3777)),
                            ),
                            Text(
                              'CYL',
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF1E3777)),
                            ),
                            Text(
                              'AXIS',
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF1E3777)),
                            ),
                            Text(
                              'ADD',
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF1E3777)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(12.0),
                        margin: EdgeInsets.all(8),
// Adjust height as needed
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
// Change background color here
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text(
                              left_eye,
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF1E3777)),
                            ),
                            Text(
                              left_sph,
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF1E3777)),
                            ),
                            Text(
                              left_cyl,
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF1E3777)),
                            ),
                            Text(
                              left_axis,
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF1E3777)),
                            ),
                            Text(
                              left_add,
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF1E3777)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(12.0),
                        margin: EdgeInsets.all(8), // Adjust height as needed
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text(
                              right_eye,
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF1E3777)),
                            ),
                            Text(
                              right_sph,
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF1E3777)),
                            ),
                            Text(
                              right_cyl,
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF1E3777)),
                            ),
                            Text(
                              right_axis,
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF1E3777)),
                            ),
                            Text(
                              right_add,
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF1E3777)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: 250,
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => HomePage()),
                              );
                              // Perform exit action here
                              // For demonstration, it closes the app
                              // Navigator.of(context).pop();
                            },
                            child: Text(
                              'Exit',
                              style: TextStyle(
                                  fontSize: 16), // Adjust text size here
                            ),
                          ),
                        ),
                      )
                      /**  Container(
                        width: 300.0, // Set the desired width
                        height: 100.0, // Set the desired height
                        padding: EdgeInsets.all(8.0),
                        margin: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextField(
                        controller: textEditingController1, // Attach the controller
                        decoration: InputDecoration(
                        border: InputBorder.none, // Remove underline
                        hintText: 'Write to Us Your Experience',
                        ),),), Container(
                        margin: EdgeInsets.all(16.0), // Set t
                        child: ElevatedButton(
                        onPressed: () {
                        SubmitFeedback(); // Add your button functionality here
                        },
                        style: ElevatedButton.styleFrom(
                        foregroundColor: Color(0xFF1E3777), backgroundColor: Color(0xFFCADAE1), // Text color
                        padding: EdgeInsets.all(16),
                        minimumSize: Size(200, 40),// Button padding
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Button border radius
                        ),
                        ),
                        child: Text('Submit'),
                        ),
                        ),**/
                    ],
                  ),
          ),
          //),
        ]));
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
      padding: EdgeInsets.all(13.0),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '$name',
            style: TextStyle(fontSize: 18, color: Color(0xFF1E3777)),
          ),
          Text(
            '$age',
            style: TextStyle(fontSize: 18, color: Color(0xFF1E3777)),
          ),
        ],
      ),
    );
  }
}
