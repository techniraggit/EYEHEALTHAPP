import 'dart:convert';
import 'dart:io';

import 'package:action_broadcast/action_broadcast.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_new/HomePage.dart';
import 'package:project_new/sign_up.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../api/config.dart';
import '../notification/notification_dashboard.dart';
import 'eyeFatigueTest.dart';

class ReportDetails extends StatefulWidget {
  final int reportId;
  @override
  ReportDetails({required this.reportId});

  EyeFatiguereports createState() => EyeFatiguereports();
}

class EyeFatiguereports extends State<ReportDetails>  with AutoCancelStreamMixin{
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey();
  int? isReadFalseCount = 0;
  String firstname="";String lastname="";String age="";String testresult= "";String created_on="";
  int report_id = 0;

  bool is_fatigue_right = false;
  bool is_mild_tiredness_right = false;
  bool is_fatigue_left = false;
  bool is_mild_tiredness_left = false;

  bool isLoading = true;

  List<String> bulletPoints = [
    "The results displayed are for reference purposes only.",
    "If you feel the power displayed is different than your old power, then please speak with your eye doctor or call EyeMyEye and speak with the optometrist.",
    "Without confirmation from your eye doctor or Eye health optometrist, do not use this power to make glasses."
  ];



  bool _saving = false; List<int> pdfBytes = [0x25, 0x50, 0x44, 0x46, ];
  String _message = '';


  @override
  void initState() {
    super.initState();

    getReport(widget.reportId);
    getNotifactionCount();
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
  // Sample data for line 2
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMMM').format(DateTime.now());
    return isLoading
        ? const Center(
      child: CircularProgressIndicator(
        color: Colors.blue,
      ),
    )
        : Scaffold(
      backgroundColor: Colors.white,

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
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
                  Navigator.pop(context);
                },
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10, // Adjust height as needed
                ),
                Center(
                  child: Text(
                    'Eye Fatigue Test Report',
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: Colors.grey, // Border color
                          width: 1.0, // Border width
                        ),
                      ),
                      height: 35,
                      width: 35,
                      child: Center(
                        child: Icon(
                          Icons.notifications_none,
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

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Text(
                created_on ?? "",
                // 'Today $formattedDate', // Display formatted current date
                style: const TextStyle(
                  fontStyle: FontStyle.normal,
                  color: Colors.grey,
                ),
              ),
            ),
            const Padding(
              padding:
              EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
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
                padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                child: Card(
                    child: ListTile(
                        title: Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Full Name', style:  TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                  ),),
                                  Text(
                                    '${firstname} ${lastname}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Age', style:  TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              ),),
                                  Text(
                                    age ?? "",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ])))),
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
              child: Card(
                child: ListTile(
                  title: Column(
                    children: [
                      // Add spacing between the row and the additional columns
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Text('Eye Fatigue in Left',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15)),
                              Center(
                                child: is_fatigue_left
                                    ? const Text(
                                  'Yes',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15),
                                )
                                    : const Text('No',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 13)),
                              ),
                              // Text('Yes',style: TextStyle(
                              //   fontSize: 16,
                              //   fontWeight: FontWeight.bold,
                              // ),),
                            ],
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Text('Eye Fatigue in Right',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15)),
                              Center(
                                child: is_fatigue_right
                                    ? const Text(
                                  'Yes',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15),
                                )
                                    : const Text('No',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 13)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                          height:
                          16), // Add spacing between the row and the additional columns
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Text('Tiredness in Left',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15)),
                              Center(
                                child: is_mild_tiredness_left
                                    ? const Text(
                                  'Yes',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15),
                                )
                                    : const Text('No',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 13)),
                              ),
                              // Text('Yes',style: TextStyle(
                              //   fontSize: 16,
                              //   fontWeight: FontWeight.bold,
                              // ),),
                            ],
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Text('Tiredness in in Right',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15)),
                              Center(
                                child: is_mild_tiredness_right
                                    ? const Text(
                                  'Yes',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15),
                                )
                                    : const Text('No',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 13)),
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
              padding:
              EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: Text(
                "Patient's Description",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: Card(
                child: ListTile(
                  title: Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Test Results',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                    Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: testresult
                          .split('\n')
                          .map(
                            (line) => Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Icon(Icons.circle, size: 10),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                line,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            SizedBox(height: 8),

                          ],
                        ),
                      )
                          .toList(),
                    ),


                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding:
              EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: Text(
                'Suggestion Test',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: bulletPoints
                  .map((bullet) => Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                      EdgeInsets.only(top: 4.0, left: 8),
                      child: Icon(
                        Icons.circle,
                        size: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        bullet,
                        style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
              ))
                  .toList(),
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                  onPressed: () async {
                    downloadReport();

                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade400,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width:
                        8), // Add spacing between the icon and text
                    Text(
                      'Download Report',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
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
    );
  }

  Future<void> getReport(int id) async {
    try {
      var sharedPref = await SharedPreferences.getInstance();
      String userToken = sharedPref.getString("access_token") ?? '';

      Map<String, String> headers = {
        'Authorization': 'Bearer $userToken',
// Bearer token type
      };
      print("statusCode================${userToken}");

      final response = await http.get(
        Uri.parse('${ApiProvider.baseUrl}/api/fatigue/fatigue-reports?report_id=$id'),
        headers: headers,
      );
      print("statusCode================${response.body}");
      if (response.statusCode == 200) {
        isLoading = false;
        final responseData = json.decode(response.body);
        // address_list = AddressList.fromJson(responseData);
        firstname = responseData['data']['user']['first_name'];
        lastname = responseData['data']['user']['last_name'];
        age = responseData['data']['user']['age'].toString();
        testresult = responseData['data']['suggestion'];
        report_id = responseData['data']['report_id'];
        print("report_id================${report_id}");
        created_on = responseData['data']['created_on'].toString().substring(0, 10);


        is_fatigue_right = responseData['data']['is_fatigue_right'];
        is_mild_tiredness_right =
        responseData['data']['is_mild_tiredness_right'];
        is_fatigue_left = responseData['data']['is_fatigue_left'];
        is_mild_tiredness_left =
        responseData['data']['is_mild_tiredness_left'];
        setState(() {});
      } else if (response.statusCode == 401) {
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
      } else {
        // Handle other Dio errors
        print("DioError: ${e.error}");
      }
    } catch (e) {
      // Handle other exceptions
      print("Exception---: $e");
    }
  }
  void requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.status;

    if (!status.isGranted ) {
      status = await Permission.storage.request();
    }


    if (status == PermissionStatus.denied ||
          status == PermissionStatus.permanentlyDenied) {
        await [Permission.storage].request();

        // Permissions are denied or denied forever, let's request it!
        status =  await Permission.storage.status;
        if (status == PermissionStatus.denied) {
          await [Permission.storage].request();
          print("storage permissions are still denied");
        } else if (status ==PermissionStatus.permanentlyDenied) {
          print("storage permissions are permanently denied");
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("storage permissions required"),
                content: Text("storage permissions are permanently denied. Please go to app settings to enable files and media permissions."),
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

     if( status.isGranted) {
      print("storage permissions are granted ");
      downloadReport();

    }
  }
  Future<String?> downloadReport() async {
    String _filePath = '';
    try {
      var sharedPref = await SharedPreferences.getInstance();
      String userToken = sharedPref.getString("access_token") ?? '';

      Map<String, String> headers = {
        'Authorization': 'Bearer $userToken',
      };

      final response = await http.get(
        Uri.parse(
            '${ApiProvider.baseUrl}/api/fatigue/download-report?report_id=$report_id'), // Adjust the URL as needed
        headers: headers,
      );
      var status = await Permission.storage.request();

      print('PDFreport_id $report_id');



      if (response.statusCode == 200) {
        Directory? downloadsDirectory = await getDownloadsDirectory();

        if (downloadsDirectory != null) {
          File? pdfFile; String? pdfPath ;
          // Create a file in the Downloads directory

           pdfPath = '${downloadsDirectory.path}${report_id}/report.pdf';
           pdfFile = File(pdfPath);
          // Write the response content to the file
          await pdfFile.writeAsBytes(response.bodyBytes);

          // Check if the file was successfully saved
          if (await pdfFile.exists()) {
            // Show a message or perform any further actions if needed
            print('PDF downloaded successfully: $pdfPath');
            Fluttertoast.showToast(msg: "PDF downloaded successfully");
            return pdfPath;
          } else {
            Fluttertoast.showToast(msg: "Failed to save PDF");
            return null;
          }
        }
        else {
          print('Downloads directory not found.');
          Fluttertoast.showToast(msg: "Failed to save PDF");
          return null;
        }
      }
      else if (response.statusCode == 401) {
        Fluttertoast.showToast(msg: "Session Expired");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
        return null;
      }
      else {
        print('Failed to download PDF: ${response.statusCode}');

        // Handle other error cases if necessary
        return null;
      }

  }catch (e) {
      print("Exception: $e");
      return null;
    }
}}
