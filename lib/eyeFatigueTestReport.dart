import 'dart:convert';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Api.dart';
import 'customDialog.dart';
import 'eyeFatigueTest.dart'; // Import intl package

class EyeFatigueTestReport extends StatefulWidget {
  @override
  EyeFatigueTestReportState createState() => EyeFatigueTestReportState();
}

class EyeFatigueTestReportState extends State<EyeFatigueTestReport> {
  bool isSelected = false;
  bool isLeftEyeSelected = false;
  List<double> data1 = [10, 30, 20, 40, 30]; // Sample data for line 1
  List<double> data2 = [30, 50, 60, 50, 60]; // Sample data for line 2

  Future<void> getReport() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String access_token = prefs.getString('access') ?? '';
      String testname = prefs.getString('test') ?? '';
      var headers = {
        'Authorization': 'Bearer ${Api.access_token}',
      };
      var uri = Uri.parse(
          '${Api.baseurl}/api/fatigue/blinks-report-details');
      var response = await http.get(
        uri,
        headers: headers,
      );
      if (response.statusCode == 200) {
        print("hhhh${response.body}");
        //  getRandomTest();
        final parsedData = json.decode(response.body);
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      if (e is SocketException) {
        CustomAlertDialog.attractivepopup(
            context, 'poor internet connectivity , please try again later!');
      }

// If the server returns an error response, throw an exception
      throw Exception('Failed to send data');
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMMM').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eye Fatigue Test Report'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notification icon pressed
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 0, 0, 8),
              child: Text(
                'Today $formattedDate', // Display formatted current date
                style: TextStyle(
                  fontStyle: FontStyle.normal,
                  color: Colors.grey,
                ),
              ),
            ),


                   const Padding(
                     padding: EdgeInsets.all(8.0),
                     child: Text(
                      'Patients Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                                       ),
                   ),

            Padding(
              padding: const EdgeInsets.all(8.0),
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
                              Text('Full Name'),
                              Text('Kajal',style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Age'),
                              Text('25 ',style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16), // Add spacing between the row and the additional columns
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Eye Fatigue in left eye'),
                              Text('0',style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Eye Fatigue in left eye'),
                              Text('0',style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
              const Text(
                    'Patient Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),

      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: ListTile(
            title: Container(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('No. of eye fatigue test'),
                  Text(
                    'value',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),


    ),
            Padding(
              padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(
                      'Suggestion Test',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),),
                        Text(
                          'value',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          'value',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          'value',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          'value',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // Add your download functionality here
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple.shade400,
                              padding: EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: 8), // Add spacing between the icon and text
                                Text(
                                  'Download Report',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ),
                                ),
                                Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.white,
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
          ],
        ),
      ),
    );
  }}



