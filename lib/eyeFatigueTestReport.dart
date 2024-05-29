import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_new/HomePage.dart';
import 'package:project_new/sign_up.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'api/config.dart';
import 'eyeFatigueTest.dart'; // Import intl package

class EyeFatigueTestReport extends StatefulWidget {
  @override
  EyeFatigueTestReportState createState() => EyeFatigueTestReportState();
}

class EyeFatigueTestReportState extends State<EyeFatigueTestReport> {
String? firstname,lastname,age,testresult,created_on;int report_id=0;
bool ? is_fatigue_right,is_mild_tiredness_right,is_fatigue_left,is_mild_tiredness_left;
bool isLoading=true;
  List<double> data1 = [10, 30, 20, 40, 30]; // Sample data for line 1
  List<double> data2 = [30, 50, 60, 50, 60];
  List<String> bulletPoints = [
    "The results displayed are for reference purposes only.",
    "If you feel the power displayed is different than your old power, then please speak with your eye doctor or call EyeMyEye and speak with the optometrist.",
    "Without confirmation from your eye doctor or Eye health optometrist, do not use this power to make glasses."
  ];



  @override
  void initState() {
    super.initState();
     isclose=false; uploaded=false;
     isLoading = false;
    getReport();
  }
  // Sample data for line 2
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMMM').format(DateTime.now());
    return
        WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => HomePage()),
                    (Route<dynamic> route) => false);

            return false;
          },
      child: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.black,
        ),
      )
          :Scaffold(
        appBar: AppBar(
          title:  Center(child: Text('Eye Fatigue Test Report',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500),)),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                // Handle notification icon pressed
              },
            ),
          ],
        ),
        body:   SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Text(
                    created_on??"",
                    // 'Today $formattedDate', // Display formatted current date
                    style: TextStyle(
                      fontStyle: FontStyle.normal,
                      color: Colors.grey,
                    ),
                  ),
                ),


                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 16),
                  child: Text(
                    "Patient's Details",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 12),
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
                                  Text('${firstname} ${lastname}',style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Age'),
                                  Text(age??""
                                    ,style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16),])))),


              Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 12),
              child: Card(
              child: ListTile(
              title: Column(
              children: [
                          // Add spacing between the row and the additional columns
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Eye Fatigue in Left',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 15)),
                                  Center(
                                    child: is_fatigue_left! ? Text('Yes',style: TextStyle(color: Colors.green,fontWeight: FontWeight.w400,fontSize: 15),): Text('No',style: TextStyle(color: Colors.red,fontWeight: FontWeight.w400,fontSize: 13)),
                                  ),
                                  // Text('Yes',style: TextStyle(
                                  //   fontSize: 16,
                                  //   fontWeight: FontWeight.bold,
                                  // ),),
                                ],
                              ),
                              SizedBox(width: 10,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Eye Fatigue in Right',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 15)),
                                  Center(
                                    child: is_fatigue_right! ? Text('Yes',style: TextStyle(color: Colors.green,fontWeight: FontWeight.w400,fontSize: 15),): Text('No',style: TextStyle(color: Colors.red,fontWeight: FontWeight.w400,fontSize: 13)),
                                  ),
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
                                  Text('Tiredness in Left',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 15)),
                                  Center(
                                    child: is_mild_tiredness_left! ? Text('Yes',style: TextStyle(color: Colors.green,fontWeight: FontWeight.w400,fontSize: 15),): Text('No',style: TextStyle(color: Colors.red,fontWeight: FontWeight.w400,fontSize: 13)),
                                  ),
                                  // Text('Yes',style: TextStyle(
                                  //   fontSize: 16,
                                  //   fontWeight: FontWeight.bold,
                                  // ),),
                                ],
                              ),
                              SizedBox(width: 10,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tiredness in in Right',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 15)),
                                  Center(
                                    child: is_mild_tiredness_right! ? Text('Yes',style: TextStyle(color: Colors.green,fontWeight: FontWeight.w400,fontSize: 15),): Text('No',style: TextStyle(color: Colors.red,fontWeight: FontWeight.w400,fontSize: 13)),
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
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 16),
                  child: const Text(
                    "Patient's Description",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 16),
                  child: Card(
                    child: ListTile(
                      title: Container(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Test Results',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),),
                            SizedBox(height: 10,),
                            Text(
                              testresult!      ,                    style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),


                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 16),
                  child: Text(
                    'Suggestion Test',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),),
                ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: bulletPoints
                .map((bullet) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 4.0,left: 8),
                    child: Icon(Icons.circle,size: 11,color: Colors.grey,),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      bullet,
                      style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
            ))
                .toList(),
          ),


                SizedBox(height: 30,),
                Padding(

                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    onPressed: () {
              downloadReport();                },
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
    );
  }












Future<void> getReport() async {
    try {
      var sharedPref = await SharedPreferences.getInstance();
      String userToken = sharedPref.getString("access_token") ?? '';

      Map<String, String> headers = {
        'Authorization': 'Bearer $userToken',
// Bearer token type
      };
      print("statusCode================${userToken}");

      final response = await http.get(
        Uri.parse('${ApiProvider.baseUrl}/api/fatigue/fatigue-reports'),
        headers: headers,
      );
      print("statusCode================${response.body}");
      if (response.statusCode == 200) {
        isLoading=false;
        final responseData = json.decode(response.body);
        // address_list = AddressList.fromJson(responseData);
        firstname=responseData['data'][0]['user']['first_name'];
        lastname=responseData['data'][0]['user']['last_name'];
        age=responseData['data'][0]['user']['age'].toString();
        testresult=responseData['data'][0]['suggestion'];
        created_on=responseData['data'][0]['created_on'].toString().substring(0,10);
        report_id=responseData['data'][0]['report_id'];
        is_fatigue_right=responseData['data'][0]['is_fatigue_right'];
        is_mild_tiredness_right=responseData['data'][0]['is_mild_tiredness_right'];
        is_fatigue_left=responseData['data'][0]['is_fatigue_left'];
        is_mild_tiredness_left=responseData['data'][0]['is_mild_tiredness_left'];
        setState(() {});
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


  Future<String?> downloadReport() async {
    try {
      var sharedPref = await SharedPreferences.getInstance();
      String userToken = sharedPref.getString("access_token") ?? '';

      Map<String, String> headers = {
        'Authorization': 'Bearer $userToken',
      };

      final response = await http.get(
        Uri.parse('${ApiProvider.baseUrl}/api/fatigue/download-report?report_id=83'), // Adjust the URL as needed
        headers: headers,
      );

      if (response.statusCode == 200) {
        Directory appDocDir = await getApplicationDocumentsDirectory();

        // Create a file in the application documents directory
        String pdfPath = '${appDocDir.path}/downloaded_file.pdf';
        File pdfFile = File(pdfPath);
Fluttertoast.showToast(msg: "PDF downloaded successfully");
        // Write the response content to the file
        await pdfFile.writeAsBytes(response.bodyBytes);

        // Show a message or perform any further actions if needed
        print('PDF downloaded successfully   $pdfFile.path');

        // Return the path of the downloaded file
        return pdfFile.path;

      } else if (response.statusCode == 401) {
        Fluttertoast.showToast(msg: "Session Expired");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
        return null;
      } else {
        print('Failed to download PDF: ${response.statusCode}');

        // Handle other error cases if necessary
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }

}



