import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:project_new/HomePage.dart';
import 'package:project_new/digitalEyeTest/EyeTestReportDetail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Custom_navbar/bottom_navbar.dart';
import '../FatigueReportDetails.dart';
import '../api/config.dart';

class ReportPage extends StatefulWidget {
  @override
  ReportPageState createState() => ReportPageState();
}

class ReportPageState extends State<ReportPage> {
  List<dynamic> itemsdata = [];
  bool isLoading = true;
  List<dynamic> percentage = [];
  List<dynamic> items = [];
  List<dynamic> ReportIds = [];
  String testResult = 'Good';
  List<Prescription> prescriptions = [];
  @override
  void initState() {
    super.initState();
    getReports();
    geteyeReports();
    getPrescriptionFiles();
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
              appBar: AppBar(
                title: const Text('Report and Statistics'),
                bottom: TabBar(
                  tabs: [
                    Tab(text: 'Fatigue Report'),
                    Tab(text: 'Eye Test Report'),
                    Tab(text: 'Other'),
                  ],
                  labelColor: Colors.bluebutton,
                  unselectedLabelColor: Colors.black,
                  labelStyle:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: TextStyle(fontSize: 14),
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.notifications),
                    onPressed: () {
                      // Handle notification icon pressed
                    },
                  ),
                ],
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
                    elevation: 4.0, // Shadow
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
              bottomNavigationBar: CustomBottomAppBar(),
            ),
          );
  }

  Widget buildFatigueReport(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Card(
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
                                if (percentage[index] > 50.0) {
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
  color: Colors.grey.shade600,
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
      appBar: AppBar(title: Text('Prescription Details')),
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
                  backgroundColor: Colors.blue,
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


