import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:project_new/HomePage.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert' as convert;

import '../Custom_navbar/customDialog.dart';
import '../api/Api.dart';
import 'camara.dart';
import 'TestReport.dart';

class GiveInfo extends StatefulWidget {
  @override
  SelectQuestion createState() => SelectQuestion();
}

class SelectQuestion extends State<GiveInfo> {
  ProgressDialog? _progressDialog;
  late Future<List<Question>> _questionsFuture;

  List<int> idList = [];
  List<int> selectedIds = [];
  String message = "";
  late final http.Client client;

  void _onCheckboxChanged(bool? value, int questionId) {
    setState(() {
      if (value == true) {
        // Add the ID to the selected IDs list if it's not already present
        if (!selectedIds.contains(questionId)) {
          selectedIds.add(questionId);
        }
      } else {
        // Remove the ID from the selected IDs list if it's present
        selectedIds.remove(questionId);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _questionsFuture = getQuestionApi();
    _configureTts();
    _onReplayPressed();
  }

  @override
  void dispose() {
    // Dispose of the progress dialog when the state is disposed
    _progressDialog?.hide();
    flutterTts.stop();
    super.dispose();
  }

  final FlutterTts flutterTts = FlutterTts();

  void _configureTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _onReplayPressed() {
    const String replayText =
        "Please read and answer the below questions to the best of your understanding. Your response will help us conduct the eye test effectively. All questions are mandatory.";
    _speak(replayText);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        return false;
      },
      child: Scaffold(
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
        body: Stack(
          children: [
            FutureBuilder<List<Question>>(
              future: _questionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No questions available'));
                } else {
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 50),
                    // Add padding to avoid button overlap
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: _onReplayPressed,
                                child: Container(
                                  padding: EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 4.0),
                                        child: Image.asset(
                                          'assets/play_circle_fill.png',
                                          width: 50,
                                          height: 40,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      // Adjust spacing between icon and text
                                      Text(
                                        'Replay Audio',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                'Welcome to Eye Health',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.bluebutton,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  'Are you wearing Eyeglasses or Contact Lenses for Vision Correction Faces, or Sightseeing?',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 10),
                              // Dynamically create QuestionCheckbox widgets based on fetched questions
                              for (var question in snapshot.data!) ...[
                                QuestionCheckbox(
                                  questionId: question.id,
                                  questionText: question.questionText,
                                  onChanged: (bool? value) {
                                    _onCheckboxChanged(value, question.id);
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                child: ElevatedButton(
                  onPressed: () {
                    submitApi();
                  },
                  child: Text('Next'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF5900D9),
                    padding: EdgeInsets.all(6),
                    minimumSize: Size(MediaQuery.of(context).size.width, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

/*  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        return false;
      },
      child: Scaffold(
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
        body: Stack(
          children: [
            FutureBuilder<List<Question>>(
              future: _questionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No questions available'));
                } else {
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 100),
                    // Add padding to avoid button overlap
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Welcome to Eye Health',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.bluebutton,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  'Are you wearing Eyeglasses or Contact Lenses for Vision Correction Faces, or Sightseeing?',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 10),
                              // Dynamically create QuestionCheckbox widgets based on fetched questions
                              for (var question in snapshot.data!) ...[
                                QuestionCheckbox(
                                  questionId: question.id,
                                  questionText: question.questionText,
                                  onChanged: (bool? value) {
                                    _onCheckboxChanged(value, question.id);
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                child: ElevatedButton(
                  onPressed: () {
                    submitApi();
                  },
                  child: Text('Next'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF5900D9),
                    padding: EdgeInsets.all(6),
                    minimumSize: Size(MediaQuery.of(context).size.width, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }*/

  Future<List<Question>> getQuestionApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('access_token') ?? '';
    String customer = prefs.getString('customer_id') ?? '';

    var headers = {
      'Authorization': 'Bearer $authToken',
      'Customer-Id': customer,
      // Remove or modify Content-Type header here
      'Content-Type': 'application/json',
    };

    try {
      http.Response response = await http.get(
        Uri.parse('${Api.baseurl}/api/eye/get-question-details'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        final List<dynamic> data = parsed['data'];

        return data.map<Question>((json) {
          // Assign custom names like "qst1", "qst2", etc., to the questions
          final customName = 'qst${json['id']}';
          return Question(id: json['id'], questionText: json['question_text']);
        }).toList();
      } else {
        throw Exception('Failed to fetch questions');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> submitApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken =
        // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
        prefs.getString('access_token') ?? '';
    String CustomerId = prefs.getString('customer_id') ?? '';
    print("myselectedid${selectedIds}");
    var headers = {
      'Authorization': 'Bearer ${authToken}',
// Remove or modify Content-Type header here
      'Content-Type': 'application/json',
      'Customer-Id': CustomerId,
    };
    var body = json.encode({
      "selected_question": selectedIds,
    });
    try {
      // Update message while API call is in progress
      //  _progressDialog!.update(message: 'please wait...');

      http.Response response = await http.post(
        Uri.parse('${Api.baseurl}/api/eye/select-questions'),
        headers: headers,
        body: body,
      );
      print(headers);

      if (response.statusCode == 200) {
        // _progressDialog!.hide();
        print(response.body);

        final responseBody = json.decode(response.body);
        final int id = responseBody['data']['id'];
        final String test = responseBody['data']['test'];
        //  message=responseMap['message'];
        //  CustomAlertDialog.attractivepopupnodelay(context, message);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('patient_id', '$id');
        await prefs.setString('test', test);
        print("id $id");
        print("id $test");
        print(response.body);
        //   _progressDialog!.hide();

        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => Camara()),
        );
      } else {
        // _progressDialog!.hide();

        CustomAlertDialog.attractivepopupnodelay(
            context, 'Please answer the questions carefully');
// Map<String, dynamic> parsedJson = json.decode(response.body);
        print(response.reasonPhrase);
      }
    } catch (e) {
      // _progressDialog!.hide();

      if (e is SocketException) {
        CustomAlertDialog.attractivepopupnodelay(
            context, 'poor internet connectivity , please try again later!');
      }

// If the server returns an error response, throw an exception
      //  throw Exception('Failed to send data');
    } finally {
      //  _progressDialog!.hide();
    }
    // _progressDialog!.hide();
  }
}

class LeftEyeTest extends StatefulWidget {
  @override
  LeftEyeTestState createState() => LeftEyeTestState();
}

class LeftEyeTestState extends State<LeftEyeTest> {
  @override
  void initState() {
    super.initState();
    _configureTts();
    _onReplayPressed();
  }

  final FlutterTts flutterTts = FlutterTts();

  void _configureTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _onReplayPressed() {
    const String replayText =
        "We will start by testing your left eye. Please place your left hand palm on your left eye gently covering the eye. At any time do not put pressure on the eye or squint to see. Start by clicking on button Left Eye.";
    _speak(replayText);
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
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _onReplayPressed,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 4.0),
                                child: Image.asset(
                                  'assets/play_circle_fill.png',
                                  width: 50,
                                  height: 40,
                                ),
                              ),
                              SizedBox(width: 8),
                              // Adjust spacing between icon and text
                              Text(
                                'Replay Audio',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10, 10, 10.0, 0),
                          child: Text(
                            'Eye Test Instructions for Optimal Results',
                            style: TextStyle(
                              color: Colors.bluebutton,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: Image.asset(
                          'assets/left_eye_image.png',
                          width: 300,
                          height: 220,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            bulletText(
                                'Please place one hand over one eye while testing the other eye. This will help ensure accurate results during the test.'),
                            bulletText(
                                'For the virtual eye test, it\'s recommended to maintain a distance of approximately 50 cm from the screen. This distance is optimal for obtaining accurate results and facilitating thorough analysis of your vision.'),
                            bulletText(
                                'To facilitate the best possible testing conditions, we advise conducting the eye test in a well-lit room. Adequate lighting enhances the accuracy of the test results and ensures a comfortable testing experience for users.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: ElevatedButton(
                  onPressed: () {
                    select_eye_for_test('left');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF4600A9),
                    // Set button background color
                    padding: EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text('Next'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> select_eye_for_test(String eye) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String access_token = prefs.getString('access_token') ?? '';
      String test = prefs.getString('test') ?? '';
      String id = prefs.getString('patient_id') ?? '';
      String CustomerId = prefs.getString('customer_id') ?? '';
      var headers = {
        'Authorization': 'Bearer ${access_token}',
        'Content-Type': 'application/json',
        'Customer-Id': CustomerId,
      };
      var request =
          http.Request('POST', Uri.parse('${Api.baseurl}/api/eye/select-eye'));
      request.body =
          json.encode({"test_id": id, "eye_status": eye, "test": test});
      print(request.body);

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      print(response.stream);

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> parsedJson = json.decode(responseBody);

        // Extract data from the parsed JSON
        String test = parsedJson['data']['test'];
        int testId = parsedJson['data']['id'];
        print("resp: $responseBody");

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('test_id', testId.toString());
        // await prefs.setString('test', test);
        print("testname: $test");
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => AlphabetTest()),
        );
      } else {
        print(response.stream);
      }
    } catch (e) {
      if (e is SocketException) {
        CustomAlertDialog.attractivepopup(
            context, 'poor internet connectivity , please try again later!');
      }

// If the server returns an error response, throw an exception
    }
  }
}

Widget bulletText(String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("• ", style: TextStyle(fontSize: 18)),
      Expanded(
        child: Text(
          text,
          style: TextStyle(fontSize: 16, color: Colors.bluebutton),
        ),
      ),
    ],
  );
}

class AlphabetTest extends StatefulWidget {
  @override
  AlphabetTestState createState() => AlphabetTestState();
}

class AlphabetTestState extends State<AlphabetTest> {
  CameraController? _controller;
  late List<CameraDescription> _cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    getSnellFraction();
    _configureTts();
    _onReplayPressed();
  }

  final FlutterTts flutterTts = FlutterTts();

  void _configureTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _onReplayPressed() {
    const String replayText =
        "Please read the letters on the screen. If you are able to read clearly click green button. Keep clicking on green button until you are unable to see or letters are blurred. If letters are blurred click on black button. If you are unable to read the letters click on red button.";
    _speak(replayText);
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    CameraDescription? frontCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () =>
          _cameras.isEmpty ? throw 'No camera available' : _cameras[0],
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium);

    await _controller?.initialize();
    // _controller?.setZoomLevel(-2.5);

    if (mounted) {
      setState(() {});
    }
    // Start capturing images per second
    _captureImagePerSecond();
  }

  void _captureImagePerSecond() async {
    // Capture an image every second
    while (true) {
      XFile? image = await _controller
          ?.takePicture(); // Process the captured image as needed
      print('Image captured: ${image?.path}');
      // Delay to capture image per second
      capturePhoto(image!);
      await Future.delayed(Duration(seconds: 1));
      // regpatient1(image);
    }
  }

  void capturePhoto(XFile photo) async {
    // Note: `controller` being initialized as shown in readme
    // https://pub.dev/packages/camera#example

    List<int> photoAsBytes = await photo.readAsBytes();
    String photoAsBase64 = convert.base64Encode(photoAsBytes);
    sendDistanceRequest(photoAsBase64);
  }

  Future<void> sendDistanceRequest(String image) async {
    var apiUrl =
        '${Api.baseurl}/api/eye/calculate-distance'; // Replace with your API endpoint
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var distanceType;
    String text = prefs.getString('test') ?? '';
    print("testTypecam:--" + text);
    if (text == 'myopia') {
      distanceType = 'fardistance';
    } else if (text == 'hyperopia') {
      distanceType = 'neardistance';
    } //print('image$image');

    try {
      var frameData =
          image; // Replace this with your frame data as a base64 string
      // var distanceType = testname//'neardistance'; // Replace this with the distance type

      var requestBody = jsonEncode({
        'frameData': frameData,
        'test_distance': distanceType,
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken =
          // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
          prefs.getString('access_token') ?? '';
      String CustomerId = prefs.getString('customer_id') ?? '';

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authToken} ',
          'Customer-Id': CustomerId,
        },
        body: requestBody,
      );
      print("frameData: " + frameData);
      // print("test_distance :" + distanceType);
      print("response-camera${response.body}");
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        String alertMessage = data['alert'];
        setState(() {
          alert = alertMessage;
        });
      } else {
        Map<String, dynamic> data = jsonDecode(response.body);

        String alertMessage = data['alert'];
        alert = alertMessage;
        //   print('Request failed with status: ${response.statusCode}');
        //   print('Request failed with status: ${response.body}');
        setState(() {
          alert = alertMessage;
          print("alert$alertMessage");
        });

        // Handle error response
      }
    } catch (e) {
      if (e is SocketException) {
        CustomAlertDialog.attractivepopup(
            context, 'poor internet connectivity , please try again later!');
      } else {
        /* CustomAlertDialog.attractivepopup(
            context, 'make sure you have proper light on your face ');*/
      }

// If the server returns an error response, throw an exception
      //throw Exception('Failed to send data');
    }
  }

  int currentIndex = 0;
  String alert = '';
  String randomText = 'W';
  var len;
  List<Map<String, dynamic>> snellenFractions = [];
  List<Map<String, dynamic>> oldsnellenFractions = [];

  Future<void> getSnellFraction() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken =
          // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
          prefs.getString('access_token') ?? '';
      String testname = prefs.getString('test') ?? '';
      var headers = {
        'Authorization': 'Bearer ${authToken}',
      };
      var uri = Uri.parse(
          '${Api.baseurl}/api/eye/snellen-fraction/?test_name=$testname');
      var response = await http.get(
        uri,
        headers: headers,
      );
      if (response.statusCode == 200) {
        print("hhhh${response.body}");
        //  getRandomTest();
        final parsedData = json.decode(response.body);
// Process the parsed data here
        snellenFractions = List<Map<String, dynamic>>.from(parsedData['data']);
        /*       snellenFractions = (parsedData['data'] as List).map((item) {
          double fraction;
          String fractionStr = item['snellen_fraction'];
           if (fractionStr.contains('/')) {
        //  if (fractionStr==) {
             List<String> parts = fractionStr.split('/');
             fraction = double.parse(parts[0]) / double.parse(parts[1]);
            // Handle fractional string

            fraction = 6/6;
          } else {
            // Handle decimal string
            fraction = double.parse(fractionStr);
          }
          return {
            "snellen_fraction": fraction,
          };
        }).toList();*/
        len = snellenFractions.length;
        print('Snellen Fractions: $snellenFractions' + "lenght: $len");
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

  bool isLoading = false;
  bool isLoadingRandomText = false;

  @override
  void dispose() {
    _controller?.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        /* Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => TestScreen()),
        );*/
        return false;
      },
      child: MaterialApp(
        home: Scaffold(
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
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _onReplayPressed,
                    child: Container(
                      padding: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 4.0),
                            child: Image.asset(
                              'assets/play_circle_fill.png',
                              width: 50,
                              height: 40,
                            ),
                          ),
                          SizedBox(width: 8),
                          // Adjust spacing between icon and text
                          Text(
                            'Replay Audio',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 70),
                  Container(
                    width: 150,
                    height: 150,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            randomText,
                            style: TextStyle(
                              fontSize: currentTextSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Visibility(
                            visible: isLoadingRandomText,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        width: 320,
                        height: 40,
                        padding: EdgeInsets.all(8),
                        child: Text(
                          alert,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: alert == 'Good to go'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 50,
                            width: 160,
                            child: ElevatedButton(
                              onPressed: () {
                                increaseTextSize();
                                getRandomTest();
                              },
                              child: Text(
                                'Back',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 3),
                                backgroundColor: Colors.teal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 30),
                          SizedBox(
                            height: 50,
                            width: 150,
                            child: ElevatedButton(
                              onPressed: () {
                                decreaseTextSize();
                                getRandomTest();
                              },
                              child: Text(
                                'Perfectly Visible',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 3),
                                backgroundColor: Colors.bluebutton,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 50,
                          width: 160,
                          child: ElevatedButton(
                            onPressed: () {
                              Myopia_or_HyperMyopiaTest(context);
                            },
                            child: Text(
                              'Not able to Read',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 3),
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                right: 10,
                child: Container(
                  width: 100.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: InteractiveViewer(
                    // boundaryMargin: EdgeInsets.all(20.0),
                    minScale: 0.1,
                    maxScale: 1.5,
                    child: _controller != null
                        ? CameraPreview(_controller!)
                        : Container(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? nextFraction;

  // double nextFraction_new=0.0;
  double currentTextSize = 28.0; // Initial text size

  Future<void> increaseTextSize() async {
    if (currentIndex == 0) {
      print("currentIndex pv inc$currentIndex");
      //currentIndex = snellenFractions.length-1 ;

      //currentIndex--;
      int len = snellenFractions.length - 1;
      print("currentIndex pv inc${snellenFractions.length}");
      nextFraction = snellenFractions[len]['snellen_fraction'];
      // Decrease index by 1 from its last index
      /*    nextFraction_new = snellenFractions[len]['snellen_fraction'];
      print("nahi$nextFraction_new");*/
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String text = prefs.getString('test') ?? '';
      double value = 0.0;
      if (text == 'myopia') {
        List<String>? parts = nextFraction?.split('/');
        double numerator = double.parse(parts![0]);
        double denominator = double.parse(parts[1]);
        value = (numerator / denominator);
      } else {
        value = double.parse(nextFraction!);
      }

      double calculatedSize = 20.0 * value;
      //double calculatedSize = 20.0 * nextFraction_new;

      currentTextSize = calculatedSize;
    }
    if (currentIndex > 0 && currentIndex <= snellenFractions.length) {
      int len = snellenFractions.length - 1;
      if (currentIndex < len) {
        currentIndex++;
      }

      print("currentIndex pv iii$currentIndex");
      // Decrease index by 1 from its last index
      nextFraction = snellenFractions[currentIndex]['snellen_fraction'];
/*      print("nahi$nextFraction_new");
 */
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String text = prefs.getString('test') ?? '';
      double value = 0.0;
      if (text == 'myopia') {
        List<String>? parts = nextFraction?.split('/');
        double numerator = double.parse(parts![0]);
        double denominator = double.parse(parts[1]);
        value = (numerator / denominator);
      } else {
        value = double.parse(nextFraction!);
      }
      /* List<String>? parts = nextFraction?.split('/');
      double numerator = double.parse(parts![0]);
      double denominator = double.parse(parts[1]);
      double calculatedSize = 20.0 * (numerator / denominator);*/

      double calculatedSize = 20.0 * value;

      currentTextSize = calculatedSize;
    }
  }

// Initial index// Initial text size
  Future<void> decreaseTextSize() async {
    if (currentIndex == 0) {
      print("currentIndex pv dec $currentIndex");
      currentIndex = snellenFractions.length - 1;

      //currentIndex--;
      // Decrease index by 1 from its last index
      nextFraction = snellenFractions[currentIndex]['snellen_fraction'];
      print("nahi$nextFraction");

      /*     List<String>? parts = nextFraction?.split('/');
      double numerator = double.parse(parts![0]);
      double denominator = double.parse(parts[1]);
      // double calculatedSize = 20.0 * nextFraction_new;

      double calculatedSize = 20.0 * (numerator / denominator);*/
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String text = prefs.getString('test') ?? '';
      double value = 0.0;
      if (text == 'myopia') {
        List<String>? parts = nextFraction?.split('/');
        double numerator = double.parse(parts![0]);
        double denominator = double.parse(parts[1]);
        value = (numerator / denominator);
      } else {
        value = double.parse(nextFraction!);
      }
      double calculatedSize = 20.0 * value;

      currentTextSize = calculatedSize;
    }
    if (currentIndex > 0 && currentIndex <= snellenFractions.length) {
      int len = snellenFractions.length - 1;
      if (currentIndex > 0) {
        currentIndex--;
      }

      print("currentIndex pv ddd$currentIndex");
// Decrease index by 1 from its last index
      nextFraction = snellenFractions[currentIndex]['snellen_fraction'];
      print("nahi$nextFraction");
      /*  List<String>? parts = nextFraction?.split('/');
      double numerator = double.parse(parts![0]);
      double denominator = double.parse(parts[1]);
      double calculatedSize = 20.0 * (numerator / denominator);*/
      // double calculatedSize = 20.0 * nextFraction_new;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String text = prefs.getString('test') ?? '';
      double value = 0.0;
      if (text == 'myopia') {
        List<String>? parts = nextFraction?.split('/');
        double numerator = double.parse(parts![0]);
        double denominator = double.parse(parts[1]);
        value = (numerator / denominator);
      } else {
        value = double.parse(nextFraction!);
      }
      double calculatedSize = 20.0 * value;
      currentTextSize = calculatedSize;
    }
  }

  Future<String?> getRandomTest() async {
    setState(() {
      isLoadingRandomText = true;
      randomText = '';
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken =
          // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
          prefs.getString('access_token') ?? '';
      String id = prefs.getString('test_id') ?? '';
      String CustomerId = prefs.getString('customer_id') ?? '';

      print('beebeb$id');
//todo notworking
      print("nahi$nextFraction");
      var headers = {
        'Authorization': 'Bearer ${authToken}',
        'Content-Type': 'application/json',
        'Customer-Id': CustomerId,
      };
      var request =
          http.Request('POST', Uri.parse('${Api.baseurl}/api/eye/random-text'));
      request.body =
          json.encode({"test_id": id, "snellen_fraction": nextFraction});
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      print(response.statusCode);
      String responseBody = await response.stream.bytesToString();
      Map<String, dynamic> parsedJson = json.decode(responseBody);
      print(parsedJson.toString());
      if (response.statusCode == 200) {
//String responseBody = await response.stream.bytesToString();
// Map<String, dynamic> parsedJson = json.decode(responseBody);
// Extract data from the parsed JSON
        String choose_astigmatism =
            parsedJson['data']['test_object']['choose_astigmatism'];
        currentTextSize = parsedJson['data']['textSize'];
        randomText = parsedJson['data']['random_text'];
        setState(() {
          isLoadingRandomText = false;
// Assign fetched data to your variables
          currentTextSize;
          randomText;
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('choose_astigmatism', choose_astigmatism);
        print("choose_astigmatism: $choose_astigmatism");
        return choose_astigmatism; // Return the response data
      } else {
        print(response.reasonPhrase);
        return null; // Return null or handle error accordingly
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

  Future<void> Myopia_or_HyperMyopiaTest(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken = prefs.getString('access_token') ?? '';
      String test_id = prefs.getString('test_id') ?? '';
      String CustomerId = prefs.getString('customer_id') ?? '';
      print("testid$test_id snell$nextFraction");
      var headers = {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
        'Customer-Id': CustomerId,
      };
      var request = http.Request(
          'PUT',
          Uri.parse(
              '${Api.baseurl}/api/eye/myopia-or-hyperopia-or-presbyopia-test'));
      request.body =
          json.encode({"test_id": test_id, "snellen_fraction": nextFraction});
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      print(response.statusCode);
      String responseBody = await response.stream.bytesToString();
      Map<String, dynamic> parsedJson = json.decode(responseBody);
      print(parsedJson.toString());
      if (response.statusCode == 200) {
        // showCustomToast(context, ' Operation Successfully ');
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => AstigmationTest()),
        );
        print(await response.stream.bytesToString());
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
}

class ReadingTest extends StatefulWidget {
  @override
  Reading createState() => Reading();
}

class Reading extends State<ReadingTest> {
  CameraController? _controller;
  late List<CameraDescription> _cameras;
  bool isLoadingRandomText = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    getReadingSnellFraction();
    _configureTts();
    _onReplayPressed();
  }

  final FlutterTts flutterTts = FlutterTts();

  void _configureTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _onReplayPressed() {
    const String replayText =
        "We are now going to test your eyesight for near reading or reading small letters at one hand distance. The problem of near reading is age related. In this test, you will be shown a word at different sizes. You have to stop and move ahead when you are able to read the word clearly. The words will start from small to big.You need to stop the moment you are able to read clearly. Lets begin";
    _speak(replayText);
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    CameraDescription? frontCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () =>
          _cameras.isEmpty ? throw 'No camera available' : _cameras[0],
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium);

    await _controller?.initialize();
    // _controller?.setZoomLevel(-2.5);

    if (mounted) {
      setState(() {});
    }
    // Start capturing images per second
    _captureImagePerSecond();
  }

  void _captureImagePerSecond() async {
    // Capture an image every second
    while (true) {
      XFile? image = await _controller
          ?.takePicture(); // Process the captured image as needed
      print('Image captured: ${image?.path}');
      // Delay to capture image per second
      capturePhoto(image!);
      await Future.delayed(Duration(seconds: 1));
      // regpatient1(image);
    }
  }

  void capturePhoto(XFile photo) async {
    // Note: `controller` being initialized as shown in readme
    // https://pub.dev/packages/camera#example

    List<int> photoAsBytes = await photo.readAsBytes();
    String photoAsBase64 = convert.base64Encode(photoAsBytes);
    sendDistanceRequest(photoAsBase64);
  }

  Future<void> sendDistanceRequest(String image) async {
    var apiUrl =
        '${Api.baseurl}/api/eye/calculate-distance'; // Replace with your API endpoint
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var distanceType;
    String text = prefs.getString('test') ?? '';
    print("testTypecam:--" + text);
    if (text == 'myopia') {
      distanceType = 'fardistance';
    } else if (text == 'hyperopia') {
      distanceType = 'neardistance';
    } //print('image$image');

    try {
      var frameData =
          image; // Replace this with your frame data as a base64 string
      // var distanceType = testname//'neardistance'; // Replace this with the distance type

      var requestBody = jsonEncode({
        'frameData': frameData,
        'test_distance': distanceType,
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken =
      // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
      prefs.getString('access_token') ?? '';
      String CustomerId = prefs.getString('customer_id') ?? '';

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authToken} ',
          'Customer-Id': CustomerId,
        },
        body: requestBody,
      );
      print("frameData: " + frameData);
      // print("test_distance :" + distanceType);
      print("response-camera${response.body}");
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        String alertMessage = data['alert'];
        setState(() {
          alert = alertMessage;
        });
      } else {
        Map<String, dynamic> data = jsonDecode(response.body);

        String alertMessage = data['alert'];
        alert = alertMessage;
        //   print('Request failed with status: ${response.statusCode}');
        //   print('Request failed with status: ${response.body}');
        setState(() {
          alert = alertMessage;
          print("alert$alertMessage");
        });

        // Handle error response
      }
    } catch (e) {
      if (e is SocketException) {
        CustomAlertDialog.attractivepopup(
            context, 'poor internet connectivity , please try again later!');
      } else {
        /* CustomAlertDialog.attractivepopup(
            context, 'make sure you have proper light on your face ');*/
      }

// If the server returns an error response, throw an exception
      //throw Exception('Failed to send data');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    flutterTts.stop();
    super.dispose();
  }

  String alert = '';
  String randomText = 'Test';
  var len;
  int currentIndex = 0;
  List<Map<String, dynamic>> snellenFractions = [];

  Future<void> getReadingSnellFraction() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken = prefs.getString('access_token') ?? '';
      String testname = "hyperopia";
      var headers = {
        'Authorization': 'Bearer $authToken',
      };
      var uri = Uri.parse(
          '${Api.baseurl}/api/eye/snellen-fraction/?test_name=$testname');
      var response = await http.get(
        uri,
        headers: headers,
      );
      print("aaaaaaaaaa${response.body}");
      if (response.statusCode == 200) {
        getReadingRandomTest();
        final parsedData = json.decode(response.body);
// Process the parsed data here
        snellenFractions = List<Map<String, dynamic>>.from(parsedData['data']);
        len = snellenFractions.length;
        print('Snellen Fractions: $snellenFractions' + "lenght: $len");
      } else {
        var connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          Fluttertoast.showToast(
            msg:
                'Poor internet connection , make sure you have a good internet',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.white,
          );
        }
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

/*  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => GiveInfo()),
          // (route) => route.isFirst, // Remove until the first route (Screen 1)
        );
        return false;
      },
      child: MaterialApp(
          home: Scaffold(
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
              body: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/test.png'),
// Replace with your image
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      child: Column(
                        //  mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 10),
                          Container(
                            width: 150,
                            height: 80,
                            child: Center(
                              child: Text(
                                randomText,
                                style: TextStyle(
                                  fontSize: currentTextSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 20),
                              SizedBox(
                                height: 45,
                                width: 130,
                                child: ElevatedButton(
                                  onPressed: () {
                                    getReadingSnellFraction();
                                    increaseReadingTextSize();
                                  },
                                  child: Text(
                                    'Back',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight
                                            .bold // Set the text color here
                                        // You can also set other properties like fontSize, fontWeight, etc.
                                        ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1),
                                    backgroundColor: Colors.yellow,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              SizedBox(
                                height: 45,
                                width: 140,
                                child: ElevatedButton(
                                  onPressed: () {
                                    getReadingSnellFraction();

                                    decreaseReadingTextSize();
                                  },
                                  child: Text(
                                    'Perfectly '
                                    'Visible',
                                    style: TextStyle(
                                      color: Colors
                                          .white, // Set the text color here
                                      // You can also set other properties like fontSize, fontWeight, etc.
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1),
                                    backgroundColor: Colors.lightGreen,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            height: 40,
                            width: 150,
                            child: ElevatedButton(
                              onPressed: () {
                                Update_HyperMyopiaTest(context);
                              },
                              child: Text(
                                'Not able to Read',
                                style: TextStyle(
                                  color:
                                      Colors.white, // Set the text color here
                                  // You can also set other properties like fontSize, fontWeight, etc.
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 3),
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 320,
                            height: 40,
                            padding: EdgeInsets.all(8),
                            child: Text(
                              alert,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 22,
                                  color: alert == 'Good to go'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold
                                  // Change text color here
                                  // You can also set other properties like fontWeight, fontStyle, etc.
                                  ),
                            ),
                          ),
                          Container(
                            child: InteractiveViewer(
                             // boundaryMargin: EdgeInsets.all(20.0),
                              minScale: 0.1,
                              maxScale: 1.5,
                              child: _controller != null
                                  ? CameraPreview(_controller!)
                                  : Container(),
                            ),

                            width: 280.0,
                            // Set the desired width
                            height: 320.0,
                            // Set the desired height
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                            ),
                          )

                          ,
                        ],
                      ),
                    ),
                  ),
                ],
              ))),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        /* Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => TestScreen()),
        );*/
        return false;
      },
      child: MaterialApp(
        home: Scaffold(
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
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    /*   image: DecorationImage(
                    image: AssetImage('assets/test.png'),
                    fit: BoxFit.cover,
                  ),*/
                    ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 70),
                  Container(
                    width: 150,
                    height: 150,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            randomText,
                            style: TextStyle(
                              fontSize: currentTextSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Visibility(
                            visible: isLoadingRandomText,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        width: 320,
                        height: 70,
                        padding: EdgeInsets.all(8),
                        child: Text(
                          alert,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            color: alert == 'Good to go'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 50,
                            width: 160,
                            child: ElevatedButton(
                              onPressed: () {
                                getReadingSnellFraction();
                                increaseReadingTextSize();
                              },
                              child: Text(
                                'Back',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 3),
                                backgroundColor: Colors.teal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 30),
                          SizedBox(
                            height: 50,
                            width: 150,
                            child: ElevatedButton(
                              onPressed: () {
                                getReadingSnellFraction();
                                decreaseReadingTextSize();
                              },
                              child: Text(
                                'Perfectly Visible',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 3),
                                backgroundColor: Colors.bluebutton,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 50,
                          width: 160,
                          child: ElevatedButton(
                            onPressed: () {
                              Update_HyperMyopiaTest(context);
                            },
                            child: Text(
                              'Not able to Read',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 3),
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                right: 10,
                child: Container(
                  width: 100.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: InteractiveViewer(
                    // boundaryMargin: EdgeInsets.all(20.0),
                    minScale: 0.1,
                    maxScale: 1.5,
                    child: _controller != null
                        ? CameraPreview(_controller!)
                        : Container(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? nextFraction;
  double currentTextSize = 24.0; // Initial text size
// Initial text size

  void increaseReadingTextSize() {
    if (currentIndex == 0 || currentIndex < snellenFractions.length - 1) {
// currentIndex = snellenFractions.length;
      currentIndex = currentIndex + 1;
      print("currentIndex back$currentIndex");

      // Decrease index by 1 from its last index
      nextFraction = snellenFractions[currentIndex]['snellen_fraction'];
      print("nahi$nextFraction");
      List<String>? parts = nextFraction?.split('/');
      double numerator = double.parse(parts![0]);
      double denominator = double.parse(parts[1]);
      double calculatedSize = 20.0 * (numerator / denominator);
      currentTextSize = calculatedSize;
    } else {
      print("currentIndex back$currentIndex");

      // Decrease index by 1 from its last index
      nextFraction = snellenFractions[currentIndex]['snellen_fraction'];
      print("nahi$nextFraction");
      List<String>? parts = nextFraction?.split('/');
      double numerator = double.parse(parts![0]);
      double denominator = double.parse(parts[1]);
      double calculatedSize = 20.0 * (numerator / denominator);
      currentTextSize = calculatedSize;
    }
  }

// Initial index// Initial text size
  void decreaseReadingTextSize() {
    if (currentIndex == 0) {
      print("currentIndex pv $currentIndex");
      currentIndex = snellenFractions.length - 1;

      //currentIndex--;
      // Decrease index by 1 from its last index
      nextFraction = snellenFractions[currentIndex]['snellen_fraction'];
      print("nahi$nextFraction");
      List<String>? parts = nextFraction?.split('/');
      double numerator = double.parse(parts![0]);
      double denominator = double.parse(parts[1]);
      double calculatedSize = 20.0 * (numerator / denominator);
      currentTextSize = calculatedSize;
    }
    if (currentIndex > 0 && currentIndex <= snellenFractions.length) {
      currentIndex--;
      print("currentIndex pv $currentIndex");
// Decrease index by 1 from its last index
      nextFraction = snellenFractions[currentIndex]['snellen_fraction'];
      print("nahi$nextFraction");
      List<String>? parts = nextFraction?.split('/');
      double numerator = double.parse(parts![0]);
      double denominator = double.parse(parts[1]);
      double calculatedSize = 20.0 * (numerator / denominator);
      currentTextSize = calculatedSize;
    }
  }

  Map<String, dynamic>? paymentIntent;
  String selectedPlan = 'a', expiry_date = 'b';
  String test_left = '0';
  late String subscriptionId;

  Future<String?> getReadingRandomTest() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken =
          // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
          prefs.getString('access_token') ?? '';
      String id = prefs.getString('test_id') ?? '';
      String CustomerId = prefs.getString('customer_id') ?? '';
      print('beebeb$id');
//todo notworking
      print("nahi$nextFraction");
      var headers = {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
        'Customer-Id': CustomerId,
      };
      var request = http.Request(
          'POST', Uri.parse('${Api.baseurl}/api/eye/random-word-test'));
      request.body =
          json.encode({"test_id": id, "snellen_fraction": nextFraction});
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      print(response.statusCode);
      String responseBody = await response.stream.bytesToString();
      Map<String, dynamic> parsedJson = json.decode(responseBody);
      print(parsedJson.toString());
      if (response.statusCode == 200) {
//String responseBody = await response.stream.bytesToString();
// Map<String, dynamic> parsedJson = json.decode(responseBody);
// Extract data from the parsed JSON
        // String choose_astigmatism =parsedJson['data']['test_object']['choose_astigmatism'];
        currentTextSize = parsedJson['size'];
        randomText = parsedJson['word'];
        setState(() {
// Assign fetched data to your variables
          currentTextSize;
          randomText;
        }); //remove for reading test update
        /** SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('choose_astigmatism', choose_astigmatism);
            print("choose_astigmatism: $choose_astigmatism");
            return choose_astigmatism; // Return the response data**/
      } else {
        var connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          Fluttertoast.showToast(
            msg:
                'Poor internet connection , make sure you have a good internet',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.white,
          );
        }
        print(response.reasonPhrase);
        return null; // Return null or handle error accordingly
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

  Future<void> Update_HyperMyopiaTest(BuildContext context) async {
    //  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('access_token') ?? '';
    String test_id = prefs.getString('test_id') ?? '';
    String CustomerId = prefs.getString('customer_id') ?? '';
    var headers = {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json',
      'Customer-Id': CustomerId,
    };
    var request = http.Request(
        'PUT',
        Uri.parse(
            '${Api.baseurl}/api/eye/update-Reading-SnellenFraction-TestApi'));
    request.body =
        json.encode({"test_id": test_id, "snellen_fraction": nextFraction});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    print(response.statusCode);
    String responseBody = await response.stream.bytesToString();
    Map<String, dynamic> parsedJson = json.decode(responseBody);
    print(parsedJson.toString());
    if (response.statusCode == 200) {
      // showCustomToast(context, ' Operation Successfully ');
      String eyeStatus = parsedJson["data"]["eye_status"];
      if (eyeStatus == "right") {
        CustomAlertDialog.attractivepopup(
            context, 'You Have Successfully Completed Eyetest.....');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('page', "readingtestpage");
        Navigator.push(context,
            CupertinoPageRoute(builder: (context) => const TestReport()));
        // getActivePlan();
      } else {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => RightEye()),
        );
      }
      print(await response.stream.bytesToString());
    }
    /* } catch (e) {
      if (e is SocketException) {
        CustomAlertDialog.attractivepopup(
            context, 'poor internet connectivity , please try again later!');
      }

// If the server returns an error response, throw an exception
      throw Exception('Failed to send data');
    }*/
  }

/* Future<void> getActivePlan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken =
        // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
        prefs.getString('access_token') ?? '';

    final String apiUrl =
        'https://testing1.zuktiapp.zuktiinnovations.com/subscription-active-plan/';
// Replace these headers with your required headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    };
// Replace this with your PUT request body

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
//body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        print('respsss ${response.body}');

        SharedPreferences prefs = await SharedPreferences.getInstance();
        String page = prefs.getString('page') ?? '';
        if (page == "myplan") {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => MyPlan()),
          );
        } else {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => ReportPage()),
          );
          print('Failed with status code: ${response.body}');
        }

// If the call to the server was successful, parse the JSON
      } else {
        Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) =>
// LoginScreen()),
                  MyPlan()),
        );
// If the server did not return a 200 OK response,
// handle the error here (display error message or take appropriate action)
        print('Failed with status code: ${response.body}');
      }
    } catch (e) {
// Handle exceptions here (e.g., network errors)
      print('Exception: $e');
    }
  }*/
}

class AstigmationTest extends StatefulWidget {
  @override
  AstigmationTest1 createState() => AstigmationTest1();
}

class AstigmationTest1 extends State<AstigmationTest> {
  CameraController? _controller;
  late List<CameraDescription> _cameras;

  Timer? _timer;
  bool increasing = true;
  double imageSize = 250.0; // Initial image size
  bool isLoadingRandomText = false;

  @override
  void initState() {
    super.initState();
    startTimer();
    _initializeCamera();
    _configureTts();
    _onReplayPressed();
  }

  final FlutterTts flutterTts = FlutterTts();

  void _configureTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _onReplayPressed() {
    const String replayText =
        "Focus on the black dot for 10 second. After 10 second look at the lines and click on the region which is more darker than others. Region A, Region B, Region C or Region D. If unable to see the lines clearly, click on Increase or click on decrease till you see any one region darker than others. If you are able to see all regions equally darker then click on option None. Once you select the region, click next";
    _speak(replayText);
  }

  void startTimer() {
    _timer?.cancel(); // Cancel the previous timer if it exists
    _timer = Timer.periodic(Duration(seconds: 6), (timer) {
      setState(() {
        //&& !increasing
        print("imagesize$imageSize");

        if (increasing) {
          if (imageSize < 250.0 && increasing && imageSize >= 210) {
            imageSize += 10.0; // Increase image size by 10 units
          } else {
            increasing = false;
          }
        } else {
          if (imageSize > 210.0 && !increasing && imageSize <= 250) {
            imageSize -= 10.0; // Decrease image size by 10 units
          } else {
            increasing = true;
          }
        }
      });
    });
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    CameraDescription? frontCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () =>
          _cameras.isEmpty ? throw 'No camera available' : _cameras[0],
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium);

    await _controller?.initialize();
    // _controller?.setZoomLevel(-2.5);

    if (mounted) {
      setState(() {});
    }
    // Start capturing images per second
    _captureImagePerSecond();
  }

  void _captureImagePerSecond() async {
    // Capture an image every second
    while (true) {
      XFile? image = await _controller
          ?.takePicture(); // Process the captured image as needed
      print('Image captured: ${image?.path}');
      // Delay to capture image per second
      capturePhoto(image!);
      await Future.delayed(Duration(seconds: 1));
      // regpatient1(image);
    }
  }

  void capturePhoto(XFile photo) async {
    // Note: `controller` being initialized as shown in readme
    // https://pub.dev/packages/camera#example

    List<int> photoAsBytes = await photo.readAsBytes();
    String photoAsBase64 = convert.base64Encode(photoAsBytes);
    sendDistanceRequest(photoAsBase64);
  }

  Future<void> sendDistanceRequest(String image) async {
    var apiUrl =
        '${Api.baseurl}/api/eye/calculate-distance'; // Replace with your API endpoint
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var distanceType;
    String text = prefs.getString('test') ?? '';
    print("testTypecam:--" + text);
    if (text == 'myopia') {
      distanceType = 'fardistance';
    } else if (text == 'hyperopia') {
      distanceType = 'neardistance';
    } //print('image$image');

    try {
      var frameData =
          image; // Replace this with your frame data as a base64 string
      // var distanceType = testname//'neardistance'; // Replace this with the distance type

      var requestBody = jsonEncode({
        'frameData': frameData,
        'test_distance': distanceType,
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken =
          // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
          prefs.getString('access_token') ?? '';
      String CustomerId = prefs.getString('customer_id') ?? '';

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authToken} ',
          'Customer-Id': CustomerId,
        },
        body: requestBody,
      );
      print("frameData: " + frameData);
      // print("test_distance :" + distanceType);
      print("response-camera${response.body}");
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        String alertMessage = data['alert'];

        // print(alertMessage);
        // Handle the response data here
        //   print('Request sucxsss with status: ${response.body}');

        //  print("alert$alertMessage");
        setState(() {
          alert = alertMessage;
        });
      } else {
        Map<String, dynamic> data = jsonDecode(response.body);

        String alertMessage = data['alert'];
        alert = alertMessage;
        //   print('Request failed with status: ${response.statusCode}');
        //   print('Request failed with status: ${response.body}');
        setState(() {
          alert = alertMessage;
          print("alert$alertMessage");
        });

        // Handle error response
      }
    } catch (e) {
      if (e is SocketException) {
        CustomAlertDialog.attractivepopup(
            context, 'poor internet connectivity , please try again later!');
      } else {
        /* CustomAlertDialog.attractivepopup(
            context, 'make sure you have proper light on your face ');*/
      }

// If the server returns an error response, throw an exception
      //throw Exception('Failed to send data');
    }
  }

  String alert = '';

  List<int> dataList = [];
  String region = 'n';

  void increaseSize() {
    setState(() {
      if (imageSize < 250.0 && imageSize >= 210) {
        imageSize += 10.0;
        print("astigSizeinc:" + imageSize.toString());
      }
    }); // Increase image size by 10 units

    // });
  }

  void decreaseSize() {
    setState(() {
      if (imageSize > 210.0 && imageSize <= 250) {
        //&& imageSize <= 220.0
        imageSize -= 10.0; // Decrease image size by 10 units
        print("astigSizedec:" + imageSize.toString());
      }
    });
  }

  Future<void> ChoseAstigmation() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken =
          // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
          prefs.getString('access_token') ?? '';
      String test_id = prefs.getString('test_id') ?? '';
      await prefs.setString('region', region);
      print("choseastigmation_response${region}");
      String CustomerId = prefs.getString('customer_id') ?? '';
      print("choseastigmation_res${authToken}");
      String apiUrl = '${Api.baseurl}/api/eye/choose-astigmatism';
      Map<String, dynamic> body1 = {
        'test_id': test_id,
        'choose_astigmatism': region,
      };
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${authToken}',
          'Content-Type': 'application/json',
          'Customer-Id': CustomerId
        },
        body: jsonEncode(body1),
      );
      if (kDebugMode) {
        print("choseastigmation_response${response.body}");
      }
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => AstigmationTest2()),
        );
        final List<dynamic> data = jsonData['data'];
        dataList = List<int>.from(data);

        setState(() {});
      }
      if (response.statusCode == 400) {
        // showCustomToast(context, "Get In Range");
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

  Color containerColor = Colors.bluebutton;
  Color containerColor2 = Colors.bluebutton;
  Color containerColor3 = Colors.bluebutton;
  Color containerColor4 = Colors.bluebutton;
  Color containerColor5 = Colors.bluebutton;

  @override
  void dispose() {
    _controller?.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => GiveInfo()),
        );
        return false;
      },
      child: MaterialApp(
        home: Scaffold(
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
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                    child: Text(
                      'Astigmatic Test',
                      style: TextStyle(
                          fontSize: 24.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  GestureDetector(
                    onTap: _onReplayPressed,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 4.0),
                            child: Image.asset(
                              'assets/play_circle_fill.png',
                              width: 50,
                              height: 40,
                            ),
                          ),
                          SizedBox(width: 8),
                          // Adjust spacing between icon and text
                          Text(
                            'Replay Audio',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Text(
                      'Choose the part where you can see a more darker line',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    child: Image.asset(
                      'assets/astigmation1.png',
                      width: imageSize,
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {},
                          child: buildAstigmaticButton('A', containerColor, () {
                            setState(() {
                              containerColor = Colors.lightBlueAccent;
                              containerColor2 = Colors.bluebutton;
                              containerColor3 = Colors.bluebutton;
                              containerColor4 = Colors.bluebutton;
                              containerColor5 = Colors.bluebutton;
                            });
                            region = 'a';
                            ChoseAstigmation();
                          }),
                        ),
                        buildAstigmaticButton('B', containerColor2, () {
                          setState(() {
                            containerColor = Colors.bluebutton;
                            containerColor3 = Colors.bluebutton;
                            containerColor4 = Colors.bluebutton;
                            containerColor5 = Colors.bluebutton;
                            containerColor2 = Colors.lightBlueAccent;
                          });
                          region = 'b';

                          ChoseAstigmation();
                        }),
                        buildAstigmaticButton('C', containerColor3, () {
                          setState(() {
                            containerColor2 = Colors.bluebutton;
                            containerColor = Colors.bluebutton;
                            containerColor4 = Colors.bluebutton;
                            containerColor5 = Colors.bluebutton;
                            containerColor3 = Colors.lightBlueAccent;
                          });
                          region = 'c';

                          ChoseAstigmation();
                        }),
                        buildAstigmaticButton('D', containerColor4, () {
                          setState(() {
                            containerColor4 = Colors.lightBlueAccent;
                            containerColor2 = Colors.bluebutton;
                            containerColor3 = Colors.bluebutton;
                            containerColor = Colors.bluebutton;
                            containerColor5 = Colors.bluebutton;
                          });
                          ChoseAstigmation();
                          region = 'd';
                        }),
                        buildAstigmaticButton('None', containerColor5, () {
                          setState(() {
                            containerColor5 = Colors.lightBlueAccent;
                            containerColor2 = Colors.bluebutton;
                            containerColor3 = Colors.bluebutton;
                            containerColor4 = Colors.bluebutton;
                            containerColor = Colors.bluebutton;
                          });
                          showCustomToast(context, 'Operation Successfully');
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => AstigmationTest3()),
                          );
                        }),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      alert,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22,
                          color:
                              alert == 'Good to go' ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomElevatedButtonY(
                          text: 'Decrease',
                          onPressed: decreaseSize,
                        ),
                        CustomElevatedButtonG(
                          text: 'Increase',
                          onPressed: increaseSize,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 10,
                child: Container(
                  width: 100.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: InteractiveViewer(
                    // boundaryMargin: EdgeInsets.all(20.0),
                    minScale: 0.1,
                    maxScale: 1.5,
                    child: _controller != null
                        ? CameraPreview(_controller!)
                        : Container(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAstigmaticButton(
      String text, Color color, VoidCallback onPressed) {
    return Container(
      height: 36,
      width: 60,
      margin: EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextButton(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class AstigmationTest2 extends StatefulWidget {
  @override
  Astigmationtest2 createState() =>
      Astigmationtest2(currentImage: ''); //assets/astigmationtest2.png
}

class Astigmationtest2 extends State<AstigmationTest2> {
  CameraController? _controller;
  late List<CameraDescription> _cameras;
  String currentImage = ''; //assets/astigmationtest2.png

  String alert = '';
  double imageSize1 = 180;
  bool increasing = false;
  Timer? _timer;

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    CameraDescription? frontCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () =>
          _cameras.isEmpty ? throw 'No camera available' : _cameras[0],
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium);

    await _controller?.initialize();
    // _controller?.setZoomLevel(-2.5);

    if (mounted) {
      setState(() {});
    }
    // Start capturing images per second
    _captureImagePerSecond();
  }

  void _captureImagePerSecond() async {
    // Capture an image every second
    while (true) {
      XFile? image = await _controller
          ?.takePicture(); // Process the captured image as needed
      print('Image captured: ${image?.path}');
      // Delay to capture image per second
      capturePhoto(image!);
      await Future.delayed(Duration(seconds: 1));
      // regpatient1(image);
    }
  }

  void capturePhoto(XFile photo) async {
    // Note: `controller` being initialized as shown in readme
    // https://pub.dev/packages/camera#example

    List<int> photoAsBytes = await photo.readAsBytes();
    String photoAsBase64 = convert.base64Encode(photoAsBytes);
    sendDistanceRequest(photoAsBase64);
  }

  Future<void> sendDistanceRequest(String image) async {
    var apiUrl =
        '${Api.baseurl}/api/eye/calculate-distance'; // Replace with your API endpoint
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var distanceType;
    String text = prefs.getString('test') ?? '';
    print("testTypecam:--" + text);
    if (text == 'myopia') {
      distanceType = 'fardistance';
    } else if (text == 'hyperopia') {
      distanceType = 'neardistance';
    } //print('image$image');

    try {
      var frameData =
          image; // Replace this with your frame data as a base64 string
      // var distanceType = testname//'neardistance'; // Replace this with the distance type

      var requestBody = jsonEncode({
        'frameData': frameData,
        'test_distance': distanceType,
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken =
          // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
          prefs.getString('access_token') ?? '';
      String CustomerId = prefs.getString('customer_id') ?? '';

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authToken} ',
          'Customer-Id': CustomerId,
        },
        body: requestBody,
      );
      print("frameData: " + frameData);
      // print("test_distance :" + distanceType);
      print("response-camera${response.body}");
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        String alertMessage = data['alert'];

        // print(alertMessage);
        // Handle the response data here
        //   print('Request sucxsss with status: ${response.body}');

        //  print("alert$alertMessage");
        setState(() {
          alert = alertMessage;
        });
      } else {
        Map<String, dynamic> data = jsonDecode(response.body);

        String alertMessage = data['alert'];
        alert = alertMessage;
        //   print('Request failed with status: ${response.statusCode}');
        //   print('Request failed with status: ${response.body}');
        setState(() {
          alert = alertMessage;
          print("alert$alertMessage");
        });

        // Handle error response
      }
    } catch (e) {
      if (e is SocketException) {
        CustomAlertDialog.attractivepopup(
            context, 'poor internet connectivity , please try again later!');
      } else {
        /* CustomAlertDialog.attractivepopup(
            context, 'make sure you have proper light on your face ');*/
      }

// If the server returns an error response, throw an exception
      //throw Exception('Failed to send data');
    }
  }

// Replace this with your PUT request body
  @override
  void initState() {
    super.initState();
    startTimer();
    //fetchData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      delayedAPICall();
    });
    // delayedAPICall();
    _initializeCamera();
    _configureTts();
    _onReplayPressed();
  }

  final FlutterTts flutterTts = FlutterTts();

  void _configureTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _onReplayPressed() {
    const String replayText =
        "Focus on the black dot for 10 second. After 10 second look at the lines and click on the region which is more darker than others. Region A, Region B, Region C or Region D. If unable to see the lines clearly, click on Increase or click on decrease till you see any one region darker than others. If you are able to see all regions equally darker then click on option None. Once you select the region, click next";
    _speak(replayText);
  }

  void startTimer() {
    _timer?.cancel(); // Cancel the previous timer if it exists
    _timer = Timer.periodic(Duration(seconds: 6), (timer) {
      setState(() {
        //&& !increasing
        print("imagesize1$imageSize1");

        if (increasing) {
          if (imageSize1 < 180.0 && increasing && imageSize1 >= 140) {
            imageSize1 += 10.0; // Increase image size by 10 units
          } else {
            increasing = false;
          }
        } else {
          if (imageSize1 > 140.0 && !increasing && imageSize1 <= 180) {
            imageSize1 -= 10.0; // Decrease image size by 10 units
          } else {
            increasing = true;
          }
        }
      });
    });
  }

  List<int> dataList = [];

  Future<void> delayedAPICall() async {
    // Simulating a delayed API call after 3 seconds
    print('API call will be made after 3 seconds...');

    // Delay the API call for 3 seconds
    await Future.delayed(Duration(seconds: 3));

    // After the delay, make the API call
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken =
          // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
          prefs.getString('access_token') ?? '';
      String test_id = prefs.getString('test_id') ?? '';
      String selectedRegion = prefs.getString('region') ?? '';
      String CustomerId = prefs.getString('customer_id') ?? '';

      print("eeee$test_id");
      final String apiUrl =
          '${Api.baseurl}/api/eye/get-degrees?test_id=$test_id';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Customer-Id': CustomerId,
        },
      );
      print("degrees--" + response.body);
      print("apiurl--" + apiUrl);
      print("token--" + authToken);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];
        dataList = List<int>.from(data);
        print('sss$dataList');
      }
      if (selectedRegion == "a") {
        currentImage = 'assets/astig1.png';
      }
      if (selectedRegion == "b") {
        currentImage = 'assets/astig2.png';
      }
      if (selectedRegion == "c") {
        currentImage = 'assets/astig3.png';
      }
      if (selectedRegion == "d") {
        print("selectrefion4 " + selectedRegion);
        currentImage = 'assets/astig4.png';
      }
      setState(() {
        currentImage;
      });
    } catch (e) {
      if (e is SocketException) {
        CustomAlertDialog.attractivepopup(
            context, 'poor internet connectivity , please try again later!');
      } else {
        CustomAlertDialog.attractivepopup(context, "please try to be in range");
      }

// If the server returns an error response, throw an exception
      throw Exception('Failed to send data');
    }
  }

  int Degree = 500;

  Future<void> ChoseAstigmation(int value) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken =
          // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
          prefs.getString('access_token') ?? '';
      String test_id = prefs.getString('test_id') ?? '';
      String CustomerId = prefs.getString('customer_id') ?? '';
      String apiUrl = '${Api.baseurl}/api/eye/choose-degree-api';
      Map<String, dynamic> body1 = {
        'test_id': test_id,
        "degree": value,
      };
      print("degree_choosen$body1");
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
          'Customer-Id': CustomerId,
        },
        body: jsonEncode(body1),
      );
      print("degree_choosssssssssen$response");
      print("choseastigmation_response" + response.body);
      if (response.statusCode == 200) {
        /**Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => ShadowTest2()),
            );**/
        final jsonData = json.decode(response.body);

        final List<dynamic> data = jsonData['data'];

        dataList = List<int>.from(data);
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

  void increaseSize() {
    setState(() {
      if (imageSize1 < 180.0 && imageSize1 >= 140) {
        imageSize1 += 10.0;
        print("astigSizeinc:" + imageSize1.toString());
      }
    }); // Increase image size by 10 units

    // });
  }

  void decreaseSize() {
    setState(() {
      if (imageSize1 > 140.0 && imageSize1 <= 180) {
        //&& imageSize <= 220.0
        imageSize1 -= 10.0; // Decrease image size by 10 units
        print("astigSizedec:" + imageSize1.toString());
      }
    });
  }

  Astigmationtest2({required this.currentImage});

  @override
  void dispose() {
    _controller?.dispose();
    _timer?.cancel();
    flutterTts.stop();
    super.dispose();
  }

  @override
  int selectedValue = 0;

/*
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => GiveInfo()),
        );
        return false;
      },
      child: MaterialApp(
        home: Scaffold(
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
          body: Stack(
            children: <Widget>[
              // Background Image
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 5),
                      Padding(
                        padding: EdgeInsets.fromLTRB(40, 10, 10, 2),
                        child: Text(
                          'Astigmatic Test',
                          style: TextStyle(
                              fontSize: 22.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                        child: Text(
                          'Choose the part where you can see a more darker line',
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.0),
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 8, 10, 8),
                        child: currentImage.isEmpty
                            ? CircularProgressIndicator()
                            : Image.asset(
                          currentImage,
                          width: imageSize1,
                          fit: BoxFit.fill,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 35,
                            width: 130,
                            child: CustomElevatedButtonY(
                              text: 'Decrease',
                              onPressed: decreaseSize,
                            ),
                          ),
                          Container(
                            height: 35,
                            width: 130,
                            child: CustomElevatedButtonG(
                              text: 'Increase ',
                              onPressed: increaseSize,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Center(
                        child: dataList.isEmpty
                            ? CircularProgressIndicator()
                            : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            children: dataList.map((value) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: OutlinedButton(
                                  onPressed: () {
                                    print('Button $value pressed');
                                    ChoseAstigmation(value);
                                    Degree = value;
                                    setState(() {
                                      selectedValue = value;
                                    });
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                      selectedValue == value
                                          ? Colors.lightBlueAccent
                                          : Colors.bluebutton,
                                    ),
                                    side: MaterialStateProperty.all<
                                        BorderSide>(
                                      BorderSide(
                                        color: Colors
                                            .white, // Blue border color
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    value.toString(),
                                    style: TextStyle(
                                      color: selectedValue == value
                                          ? Colors.white
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: 320,
                        height: 40,
                        padding: EdgeInsets.all(8),
                        child: Text(
                          alert,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 22,
                              color: alert == 'Good to go'
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 10,
                width: 100,
                height: 150,
                child: _controller != null
                    ? CameraPreview(_controller!)
                    : Container(
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      'Loading Camera...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    SizedBox(height: 10), // Adjust as needed
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        // Adjust colors as needed
                        color: Colors.bluebutton,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: MaterialButton(
                        onPressed: () {
                          if (Degree == 500) {
                            CustomAlertDialog.attractivepopup(
                                context, 'please select the degree');
                          } else {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => ShadowTest()),
                            );
                          }
                        },
                        child: Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => GiveInfo()),
        );
        return false;
      },
      child: MaterialApp(
        home: Scaffold(
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
          body: Stack(
            children: <Widget>[
              // Background Image
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(40, 10, 10, 2),
                        child: Text(
                          'Astigmatic Test',
                          style: TextStyle(
                              fontSize: 22.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      GestureDetector(
                        onTap: _onReplayPressed,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 4.0),
                                child: Image.asset(
                                  'assets/play_circle_fill.png',
                                  width: 50,
                                  height: 40,
                                ),
                              ),
                              SizedBox(width: 8),
                              // Adjust spacing between icon and text
                              Text(
                                'Replay Audio',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                        child: Text(
                          'Choose the part where you can see a more darker line',
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.0),
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 8, 10, 8),
                        child: currentImage.isEmpty
                            ? CircularProgressIndicator()
                            : Image.asset(
                                currentImage,
                                width: imageSize1,
                                fit: BoxFit.fill,
                              ),
                      ),
                      SizedBox(height: 10.0),
                      Center(
                        child: dataList.isEmpty
                            ? CircularProgressIndicator()
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: dataList.map((value) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: OutlinedButton(
                                        onPressed: () {
                                          print('Button $value pressed');
                                          ChoseAstigmation(value);
                                          Degree = value;
                                          setState(() {
                                            selectedValue = value;
                                          });
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                            selectedValue == value
                                                ? Colors.lightBlueAccent
                                                : Colors.bluebutton,
                                          ),
                                          side: MaterialStateProperty.all<
                                              BorderSide>(
                                            BorderSide(
                                              color: Colors
                                                  .white, // Blue border color
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          value.toString(),
                                          style: TextStyle(
                                            color: selectedValue == value
                                                ? Colors.white
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 35,
                            width: 130,
                            child: CustomElevatedButtonY(
                              text: 'Decrease',
                              onPressed: decreaseSize,
                            ),
                          ),
                          Container(
                            height: 35,
                            width: 130,
                            child: CustomElevatedButtonG(
                              text: 'Increase ',
                              onPressed: increaseSize,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          alert,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 22,
                              color: alert == 'Good to go'
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 10,
                width: 100,
                height: 150,
                child: _controller != null
                    ? CameraPreview(_controller!)
                    : Container(
                        color: Colors.black,
                        child: Center(
                          child: Text(
                            'Loading Camera...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    SizedBox(height: 10), // Adjust as needed
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          // Adjust colors as needed
                          color: Colors.bluebutton,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: MaterialButton(
                          minWidth: double.infinity,
                          onPressed: () {
                            if (Degree == 500) {
                              CustomAlertDialog.attractivepopup(
                                  context, 'please select the degree');
                            } else {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => ShadowTest()),
                              );
                            }
                          },
                          child: Text(
                            'Next',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getImageWidget(String imagePath) {
    /**  if (imagePath.toLowerCase().endsWith('.svg')) {
        // Load SVG image
        return SvgPicture.asset(
        imagePath,
        width: imageSize1,
        //  height: imageSize1,
        semanticsLabel: 'SVG Image',
        );
        } elseif (imagePath.toLowerCase().endsWith('.png')) {
        // Load PNG image**/
    return Image.asset(
      imagePath,
      width: imageSize1,
      //  height: imageSize1,
      fit: BoxFit.fill,
    );
  }
/**else {
    // Handle unsupported formats or provide a default image
    return Text('');
    }}**/
}

class AstigmationTest3 extends StatefulWidget {
  @override
  AstigmationTestNone createState() => AstigmationTestNone();
}

class AstigmationTestNone extends State<AstigmationTest3> {
  CameraController? _controller;
  late List<CameraDescription> _cameras;
  bool increasing = false;
  Timer? _timer;
  bool isLoadingRandomText = false;

  void initState() {
    super.initState();
    startTimer();
    _initializeCamera();
    _configureTts();
    _onReplayPressed();
  }

  final FlutterTts flutterTts = FlutterTts();

  void _configureTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _onReplayPressed() {
    const String replayText =
        "Focus on the black dot for 10 second. After 10 second look at the lines and click on the degree option which is more darker than others. If unable to see the lines clearly, click on Increase or click on decrease till you see any one line darker than others. Once you select the degree, click next";
    _speak(replayText);
  }

  void startTimer() {
    _timer?.cancel(); // Cancel the previous timer if it exists
    _timer = Timer.periodic(Duration(seconds: 6), (timer) {
      setState(() {
        //&& !increasing
        print("imagesize3$imageSize");

        if (increasing) {
          if (imageSize < 260.0 && increasing && imageSize >= 220) {
            imageSize += 10.0; // Increase image size by 10 units
          } else {
            increasing = false;
          }
        } else {
          if (imageSize > 220.0 && !increasing && imageSize <= 260) {
            imageSize -= 10.0; // Decrease image size by 10 units
          } else {
            increasing = true;
          }
        }
      });
    });
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    CameraDescription? frontCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () =>
          _cameras.isEmpty ? throw 'No camera available' : _cameras[0],
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium);

    await _controller?.initialize();
    // _controller?.setZoomLevel(-2.5);

    if (mounted) {
      setState(() {});
    }
    // Start capturing images per second
    _captureImagePerSecond();
  }

  void _captureImagePerSecond() async {
    // Capture an image every second
    while (true) {
      XFile? image = await _controller
          ?.takePicture(); // Process the captured image as needed
      print('Image captured: ${image?.path}');
      // Delay to capture image per second
      capturePhoto(image!);
      await Future.delayed(Duration(seconds: 1));
      // regpatient1(image);
    }
  }

  void capturePhoto(XFile photo) async {
    // Note: `controller` being initialized as shown in readme
    // https://pub.dev/packages/camera#example

    List<int> photoAsBytes = await photo.readAsBytes();
    String photoAsBase64 = convert.base64Encode(photoAsBytes);
    sendDistanceRequest(photoAsBase64);
  }

  Future<void> sendDistanceRequest(String image) async {
    var apiUrl =
        '${Api.baseurl}/api/eye/calculate-distance'; // Replace with your API endpoint
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var distanceType;
    String text = prefs.getString('test') ?? '';
    print("testTypecam:--" + text);
    if (text == 'myopia') {
      distanceType = 'fardistance';
    } else if (text == 'hyperopia') {
      distanceType = 'neardistance';
    } //print('image$image');

    try {
      var frameData =
          image; // Replace this with your frame data as a base64 string
      // var distanceType = testname//'neardistance'; // Replace this with the distance type

      var requestBody = jsonEncode({
        'frameData': frameData,
        'test_distance': distanceType,
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken =
          // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
          prefs.getString('access_token') ?? '';
      String CustomerId = prefs.getString('customer_id') ?? '';

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authToken} ',
          'Customer-Id': CustomerId,
        },
        body: requestBody,
      );
      print("frameData: " + frameData);
      // print("test_distance :" + distanceType);
      print("response-camera${response.body}");
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        String alertMessage = data['alert'];

        // print(alertMessage);
        // Handle the response data here
        //   print('Request sucxsss with status: ${response.body}');

        //  print("alert$alertMessage");
        setState(() {
          alert = alertMessage;
        });
      } else {
        Map<String, dynamic> data = jsonDecode(response.body);

        String alertMessage = data['alert'];
        alert = alertMessage;
        //   print('Request failed with status: ${response.statusCode}');
        //   print('Request failed with status: ${response.body}');
        setState(() {
          alert = alertMessage;
          print("alert$alertMessage");
        });

        // Handle error response
      }
    } catch (e) {
      if (e is SocketException) {
        CustomAlertDialog.attractivepopup(
            context, 'poor internet connectivity , please try again later!');
      } else {
        /* CustomAlertDialog.attractivepopup(
            context, 'make sure you have proper light on your face ');*/
      }

// If the server returns an error response, throw an exception
      //throw Exception('Failed to send data');
    }
  }

  String alert = '';

  String selectedPart = '';
  double imageSize = 260.0; // Initial image size
  List<int> dataList = [];

  void increaseSize() {
    setState(() {
      if (imageSize < 260.0 && imageSize >= 220) {
        imageSize += 10.0;
        print("astigSizeinc:" + imageSize.toString());
      }
    }); // Increase image size by 10 units

    // });
  }

  void decreaseSize() {
    setState(() {
      if (imageSize > 220.0 && imageSize <= 260) {
        //&& imageSize <= 220.0
        imageSize -= 10.0; // Decrease image size by 10 units
        print("astigSizedec:" + imageSize.toString());
      }
    });
  }

  Future<void> CounterApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken =
        // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
        prefs.getString('access_token') ?? '';
    String CustomerId = prefs.getString('customer_id') ?? '';

    final String apiUrl = '${Api.baseurl}/counter-api/?counter_value=0';
// Replace these headers with your required headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': '$authToken',
      'Customer-Id': CustomerId,
    };
// Replace this with your PUT request body

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
//body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        print('counter ${response.body}');
// If the call to the server was successful, parse the JSON
      } else {
// If the server did not return a 200 OK response,
// handle the error here (display error message or take appropriate action)
        print('Failed with status code: ${response.statusCode}');
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

  Future<void> ChoseAstigmation() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken = prefs.getString('access_token') ?? '';
      String test_id = prefs.getString('test_id') ?? '';
      String CustomerId = prefs.getString('customer_id') ?? '';
      print("choseastigmation_res$CustomerId");

      final String apiUrl = '${Api.baseurl}/api/eye/choose-astigmatism-api/';
      Map<String, dynamic> body1 = {
        'test_id': test_id,
        'choose_astigmatism': selectedPart,
      };
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
          'Customer-Id': CustomerId,
        },
        body: jsonEncode(body1),
      );
      print("choseastigmation_response" + response.body);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];
        dataList = List<int>.from(data);
        setState(() {});
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

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('access_token') ?? '';
    String test_id = prefs.getString('test_id') ?? '';
    await prefs.setString('region', selectedPart);
// Replace this URL with your PUT API endpoint
    final String apiUrl =
        'https://testing1.zuktiapp.zuktiinnovations.com/choose-astigmatism-api/';
// Replace these headers with your required headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    };
// Replace this with your PUT request body
    Map<String, dynamic> body = {
      'test_id': test_id,
      'choose_astigmatism': selectedPart,
    };
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        print('success with status choose astigmation: ${response.body}');
// If the call to the server was successful, parse the JSON
        setState(() {
          // _data = json.decode(response.body);
        });
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

  Color containerColor = Colors.bluebutton;
  Color containerColor2 = Colors.bluebutton;
  Color containerColor3 = Colors.bluebutton;
  Color containerColor4 = Colors.bluebutton;
  Color containerColor5 = Colors.bluebutton;

  @override
  void dispose() {
    _controller?.dispose();
    flutterTts.stop();
    super.dispose();
  }

/*
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => GiveInfo()),
            // (route) => route.isFirst, // Remove until the first route (Screen 1)
          );
          return false;
        },
        child: MaterialApp(
          home: Scaffold(
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
            body: Stack(
              children: <Widget>[
                // Background Image
                Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Background Image
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 55, 0, 2),
                          child: SingleChildScrollView(
                            child: Column(
                              //mainAxisAlignment: MainAxisAlignment.center,
                              //  crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.fromLTRB(40, 15, 40, 2),
                                  child: Text(
                                    '  Astigmatic Test',
                                    style: TextStyle(
                                        fontSize: 24.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(height: 1.0),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 5, 0, 20),
                                  child: Text(
                                    'Choose the part where you can see a more darker line',
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                // Text in the Middle
                                SizedBox(height: 2.0),
                                Image.asset(
                                  'assets/astigmation3.png',
                                  // height: imageSize,
                                  width: imageSize,
                                ),
                                */ /*   Image.asset(
                    'assets/d/s1.svg',
                    // Replace with your image path
                    width: imageSize,
                    height: imageSize,
                  ),*/ /*
                                SizedBox(height: 23.0),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      height: 35,
                                      width: 150,
                                      //padding: const EdgeInsets.fromLTRB(3, 1, 3, 1),
                                      margin: EdgeInsets.fromLTRB(10, 5, 20, 0),
                                      // padding: const EdgeInsets.fromLTRB(30, 14, 30, 10),
                                      // margin: EdgeInsets.fromLTRB(10, 10, 20, 0),

                                      child: CustomElevatedButtonY(
                                        text: 'Decrease ',
                                        onPressed: decreaseSize,
                                      ),
                                    ),
                                    Container(
                                      height: 35,
                                      width: 150,
                                      //padding: const EdgeInsets.fromLTRB(3, 1, 3, 1),
                                      margin: EdgeInsets.fromLTRB(10, 5, 20, 0),

                                      child: CustomElevatedButtonG(
                                        text: 'Increase ',
                                        onPressed: increaseSize,
                                      ),
                                    ),
                                  ],
                                ),

                                // Two Horizontal Aligned Buttons

                                SizedBox(height: 5.0),

                                // Four Buttons Aligned Horizontally
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Container(
                                        height: 35,
                                        width: 60,
                                        margin: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.bluebutton,
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        child: MaterialButton(
                                          onPressed: () {},
                                          child: TextButton(
                                            child: Text(
                                              'A',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                // Change container color to white
                                                containerColor =
                                                    Colors.lightBlueAccent;
                                                containerColor5 =
                                                    Colors.bluebutton;
                                                containerColor3 =
                                                    Colors.bluebutton;
                                                containerColor4 =
                                                    Colors.bluebutton;
                                                containerColor2 =
                                                    Colors.bluebutton;
                                              });
                                              selectedPart = 'a';
                                              ChoseAstigmation();
                                              fetchData();
                                              Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (context) =>
                                                        AstigmationTest2()),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 35,
                                        width: 60,
                                        margin: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.bluebutton,
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        child: MaterialButton(
                                          onPressed: () {},
                                          child: TextButton(
                                            child: Text(
                                              'B',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                // Change container color to white
                                                containerColor2 =
                                                    Colors.lightBlueAccent;
                                                containerColor5 =
                                                    Colors.bluebutton;
                                                containerColor3 =
                                                    Colors.bluebutton;
                                                containerColor4 =
                                                    Colors.bluebutton;
                                                containerColor =
                                                    Colors.bluebutton;
                                              });
                                              selectedPart = 'b';
                                              ChoseAstigmation();
                                              fetchData();
                                              Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (context) =>
                                                        AstigmationTest2()),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 35,
                                        width: 60,
                                        margin: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.bluebutton,
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        child: MaterialButton(
                                          onPressed: () {},
                                          child: TextButton(
                                            child: Text(
                                              'C',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                // Change container color to white
                                                containerColor3 =
                                                    Colors.lightBlueAccent;
                                                containerColor2 =
                                                    Colors.bluebutton;
                                                containerColor =
                                                    Colors.bluebutton;
                                                containerColor4 =
                                                    Colors.bluebutton;
                                                containerColor5 =
                                                    Colors.bluebutton;
                                              });
                                              selectedPart = 'c';
                                              ChoseAstigmation();
                                              fetchData();
                                              Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (context) =>
                                                        AstigmationTest2()),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 35,
                                        width: 60,
                                        margin: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.bluebutton,
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        child: MaterialButton(
                                          onPressed: () {},
                                          child: TextButton(
                                            child: Text(
                                              'D',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                // Change container color to white
                                                containerColor4 =
                                                    Colors.lightBlueAccent;
                                                containerColor2 =
                                                    Colors.bluebutton;
                                                containerColor3 =
                                                    Colors.bluebutton;
                                                containerColor5 =
                                                    Colors.bluebutton;
                                                containerColor =
                                                    Colors.bluebutton;
                                              });
                                              selectedPart = 'd';
                                              ChoseAstigmation();
                                              fetchData();
                                              Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (context) =>
                                                        AstigmationTest2()),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 35,
                                        width: 85,
                                        margin:
                                            EdgeInsets.fromLTRB(3, 3, 10, 0),

                                        //margin: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.bluebutton,
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        child: MaterialButton(
                                          onPressed: () {},
                                          child: TextButton(
                                            child: Text(
                                              'None',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                // Change container color to white
                                                containerColor5 =
                                                    Colors.lightBlueAccent;
                                                containerColor2 =
                                                    Colors.bluebutton;
                                                containerColor3 =
                                                    Colors.bluebutton;
                                                containerColor4 =
                                                    Colors.bluebutton;
                                                containerColor =
                                                    Colors.bluebutton;
                                              });
                                              CounterApi();
                                              showCustomToast(context,
                                                  'Operation Successfully ');
                                              Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (context) =>
                                                        RedGreenTest()),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),

                                Container(
                                  width: 320,
                                  height: 40,
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    alert,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 22,
                                        color: alert == 'Good to go'
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Positioned(
                                  right: 10,
                                  width: 100,
                                  // Adjust the width as needed
                                  height: 150,
                                  // Adjust the height as needed
                                  child: _controller != null
                                      ? CameraPreview(_controller!)
                                      : Container(
                                          color: Colors.black,
                                          child: Center(
                                            child: Text(
                                              'Loading Camera...',
                                              style: TextStyle(
                                                  color: Colors.white),
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
                ),
              ],
            ),
          ),
        ));
  }*/

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => GiveInfo()),
        );
        return false;
      },
      child: MaterialApp(
        home: Scaffold(
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
          body: Stack(
            children: <Widget>[
              // Background Image
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Background Image
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 55, 0, 2),
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.fromLTRB(40, 15, 40, 2),
                                child: Text(
                                  'Astigmatic Test',
                                  style: TextStyle(
                                    fontSize: 24.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _onReplayPressed,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 4.0),
                                        child: Image.asset(
                                          'assets/play_circle_fill.png',
                                          width: 50,
                                          height: 40,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      // Adjust spacing between icon and text
                                      Text(
                                        'Replay Audio',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 1.0),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 5, 0, 20),
                                child: Text(
                                  'Choose the part where you can see a more darker line',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.0),
                              Image.asset(
                                'assets/astigmation3.png',
                                width: 300, // Adjust the size as needed
                              ),
                              SizedBox(height: 23.0),
                              // Four Buttons Aligned Horizontally
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    _buildOptionButton(
                                        'A', Colors.bluebutton, 0),
                                    _buildOptionButton(
                                        'B', Colors.bluebutton, 1),
                                    _buildOptionButton(
                                        'C', Colors.bluebutton, 2),
                                    _buildOptionButton(
                                        'D', Colors.bluebutton, 3),
                                    _buildOptionButton(
                                        'None', Colors.bluebutton, 4),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                width: 320,
                                height: 40,
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  alert,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: alert == 'Good to go'
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
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
              Positioned(
                right: 10,
                top: 10,
                width: 100,
                height: 150,
                child: _controller != null
                    ? CameraPreview(_controller!)
                    : Container(
                        color: Colors.black,
                        child: Center(
                          child: Text(
                            'Loading Camera...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          height: 40,
                          width: 140,
                          child: CustomElevatedButtonY(
                            text: 'Decrease ',
                            onPressed: decreaseSize,
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 140,
                          child: CustomElevatedButtonG(
                            text: 'Increase ',
                            onPressed: increaseSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(String label, Color color, int index) {
    return Container(
      height: 35,
      width: index == 4 ? 85 : 60,
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextButton(
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        onPressed: () {
          setState(() {
            if (index == 0) {
              containerColor4 = Colors.lightBlueAccent;
              containerColor2 = Colors.bluebutton;
              containerColor3 = Colors.bluebutton;
              containerColor5 = Colors.bluebutton;
              containerColor = Colors.bluebutton;
              selectedPart = 'a';
            } else if (index == 1) {
              containerColor2 = Colors.lightBlueAccent;
              containerColor = Colors.bluebutton;
              containerColor3 = Colors.bluebutton;
              containerColor4 = Colors.bluebutton;
              containerColor5 = Colors.bluebutton;
              selectedPart = 'b';
            } else if (index == 2) {
              containerColor3 = Colors.lightBlueAccent;
              containerColor2 = Colors.bluebutton;
              containerColor = Colors.bluebutton;
              containerColor4 = Colors.bluebutton;
              containerColor5 = Colors.bluebutton;
              selectedPart = 'c';
            } else if (index == 3) {
              containerColor4 = Colors.lightBlueAccent;
              containerColor2 = Colors.bluebutton;
              containerColor3 = Colors.bluebutton;
              containerColor5 = Colors.bluebutton;
              containerColor = Colors.bluebutton;
              selectedPart = 'd';
            } else {
              containerColor5 = Colors.lightBlueAccent;
              containerColor2 = Colors.bluebutton;
              containerColor3 = Colors.bluebutton;
              containerColor4 = Colors.bluebutton;
              containerColor = Colors.bluebutton;
              CounterApi();
              showCustomToast(context, 'Operation Successfully');
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => RedGreenTest()),
              );
              return;
            }
            ChoseAstigmation();
            fetchData();
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => AstigmationTest2()),
            );
          });
        },
      ),
    );
  }
}

class ShadowTest extends StatefulWidget {
  @override
  _ShadowTestState createState() => _ShadowTestState();
}

class _ShadowTestState extends State<ShadowTest> {
  CameraController? _controller;
  late List<CameraDescription> _cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _configureTts();
    _onReplayPressed();
  }

  final FlutterTts flutterTts = FlutterTts();

  void _configureTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _onReplayPressed() {
    const String replayText =
        "you are doing well. Now we are at a crucial part of the eye test. In this test you will observe a small letter with a shadow and with increase in size of the letter the shadow will starts to decrease. You will encounter a point where the letter will appear better than the first time you saw the letter. Please select that state and then press Next. For clear instruction and visual example click on ‘?’ icon at the top of the screen. Start by clicking on increase or decrease. When done click on next.";
    _speak(replayText);
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    CameraDescription? frontCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () =>
          _cameras.isEmpty ? throw 'No camera available' : _cameras[0],
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium);

    await _controller?.initialize();
    // _controller?.setZoomLevel(-2.5);

    if (mounted) {
      setState(() {});
    }
    // Start capturing images per second
    _captureImagePerSecond();
  }

  void _captureImagePerSecond() async {
    // Capture an image every second
    while (true) {
      XFile? image = await _controller
          ?.takePicture(); // Process the captured image as needed
      print('Image captured: ${image?.path}');
      // Delay to capture image per second
      capturePhoto(image!);
      await Future.delayed(Duration(seconds: 1));
      // regpatient1(image);
    }
  }

  void capturePhoto(XFile photo) async {
    // Note: `controller` being initialized as shown in readme
    // https://pub.dev/packages/camera#example

    List<int> photoAsBytes = await photo.readAsBytes();
    String photoAsBase64 = convert.base64Encode(photoAsBytes);
    sendDistanceRequest(photoAsBase64);
  }

  Future<void> sendDistanceRequest(String image) async {
    var apiUrl =
        '${Api.baseurl}/api/eye/calculate-distance'; // Replace with your API endpoint
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var distanceType;
    String text = prefs.getString('test') ?? '';
    print("testTypecam:--" + text);
    if (text == 'myopia') {
      distanceType = 'fardistance';
    } else if (text == 'hyperopia') {
      distanceType = 'neardistance';
    } //print('image$image');

    try {
      var frameData =
          image; // Replace this with your frame data as a base64 string
      // var distanceType = testname//'neardistance'; // Replace this with the distance type

      var requestBody = jsonEncode({
        'frameData': frameData,
        'test_distance': distanceType,
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken =
          // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
          prefs.getString('access_token') ?? '';
      String CustomerId = prefs.getString('customer_id') ?? '';

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authToken} ',
          'Customer-Id': CustomerId,
        },
        body: requestBody,
      );
      print("frameData: " + frameData);
      // print("test_distance :" + distanceType);
      print("response-camera${response.body}");
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        String alertMessage = data['alert'];

        // print(alertMessage);
        // Handle the response data here
        //   print('Request sucxsss with status: ${response.body}');

        //  print("alert$alertMessage");
        setState(() {
          alert = alertMessage;
        });
      } else {
        Map<String, dynamic> data = jsonDecode(response.body);

        String alertMessage = data['alert'];
        alert = alertMessage;
        //   print('Request failed with status: ${response.statusCode}');
        //   print('Request failed with status: ${response.body}');
        setState(() {
          alert = alertMessage;
          print("alert$alertMessage");
        });

        // Handle error response
      }
    } catch (e) {
      if (e is SocketException) {
        CustomAlertDialog.attractivepopup(
            context, 'poor internet connectivity , please try again later!');
      } else {
        /* CustomAlertDialog.attractivepopup(
            context, 'make sure you have proper light on your face ');*/
      }

// If the server returns an error response, throw an exception
      //throw Exception('Failed to send data');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    flutterTts.stop();
    super.dispose();
  }

  String alert = '';
  String dynamicText = 'A';
  double currentTextSize = 15.118110236220474; //4-29
  void changeSize(String direction) {
    if (direction == 'up') {
      if (currentTextSize < 109.60629921259843 &&
          currentTextSize >= 15.118110236220474) {
        currentTextSize += 1.8897637795275593;
        print("currentTextSize" + currentTextSize.toString());
      }
    } else if (direction == 'down') {
      if (currentTextSize > 15.118110236220474 &&
          currentTextSize <= 109.60629921259843) {
        currentTextSize -= 1.8897637795275593;
        print("currentTextSize" + currentTextSize.toString());
      }
    }
    setState(() {
      currentTextSize;
    });
  }

  bool isCameraInitialized = false;

/*
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) =>
                  GiveInfo()), // Replace 'test()' with the appropriate screen
        );
        return false;
      },
      child: MaterialApp(
        home: Scaffold(
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
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.4,
                          color: Colors.black,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[

                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 10, 4, 0),
                                child: Text(
                                  'Shadow Test',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              Spacer(),
                              // This pushes the next widget to the center
                              Center(
                                child: Text(
                                  dynamicText,
                                  // Replace with your dynamic text variable
                                  style: TextStyle(
                                    fontSize: currentTextSize,
                                    // Replace with your text size variable
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Spacer(),
                              // This pushes the above widget to the center
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              height: 40,
                              width: 150,
                              margin: EdgeInsets.fromLTRB(10, 5, 20, 0),
                              child: CustomElevatedButtonY(
                                text: 'Decrease',
                                onPressed: () => changeSize('down'),
                              ),
                            ),
                            Container(
                              height: 40,
                              margin: EdgeInsets.fromLTRB(10, 5, 20, 0),
                              child: CustomElevatedButtonG(
                                text: 'Increase',
                                onPressed: () => changeSize('up'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(00.0),
                        child: Text(
                          alert,
                          // Replace with your alert text variable
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: alert == 'Good to go'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Two Horizontal Aligned Buttons
                      // Four Buttons Aligned Horizontally
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 10,
                width: 100,
                // Adjust the width as needed
                height: 150,
                // Adjust the height as needed
                child: _controller != null
                    ? CameraPreview(_controller!)
                    : Container(
                        color: Colors.black,
                      ),
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 0, 15, 8),
            child: Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.bluebutton, // Change to your desired color
                borderRadius: BorderRadius.circular(25),
              ),
              child: MaterialButton(
                onPressed: () {
                  // Call your function here
                  CylTestApi();
                },
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
*/
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => GiveInfo()),
        );
        return false;
      },
      child: MaterialApp(
        home: Scaffold(
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
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: _onReplayPressed,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Image.asset(
                                'assets/play_circle_fill.png',
                                width: 50,
                                height: 40,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Replay Audio',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // Add some space after the button
                    Padding(
                      padding: const EdgeInsets.only(top: 90.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.4,
                        color: Colors.black,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 4, 0),
                              child: Text(
                                'Shadow Test',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Spacer(),
                            Center(
                              child: Text(
                                dynamicText,
                                style: TextStyle(
                                  fontSize: currentTextSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // Add some space after the container
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 40,
                            width: 150,
                            margin: EdgeInsets.fromLTRB(10, 5, 20, 0),
                            child: CustomElevatedButtonY(
                              text: 'Decrease',
                              onPressed: () => changeSize('down'),
                            ),
                          ),
                          Container(
                            height: 40,
                            margin: EdgeInsets.fromLTRB(10, 5, 20, 0),
                            child: CustomElevatedButtonG(
                              text: 'Increase',
                              onPressed: () => changeSize('up'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        alert,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color:
                              alert == 'Good to go' ? Colors.green : Colors.red,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 10,
                width: 100,
                height: 150,
                child: _controller != null
                    ? CameraPreview(_controller!)
                    : Container(
                        color: Colors.black,
                      ),
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 0, 15, 8),
            child: Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.bluebutton,
                borderRadius: BorderRadius.circular(25),
              ),
              child: MaterialButton(
                onPressed: () {
                  // Call your function here
                  CylTestApi();
                },
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> CylTestApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken =
        // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
        prefs.getString('access_token') ?? '';
    String test_id = prefs.getString('test_id') ?? '';
    String CustomerId = prefs.getString('customer_id') ?? '';
    print("snsjsjsj"); // Replace this URL with your PUT API endpoint
    final String apiUrl = '${Api.baseurl}/api/eye/cyl-test';
// Replace these headers with your required headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${authToken}',
      'Customer-Id': CustomerId
    };
// Replace this with your PUT request body
    Map<String, dynamic> body = {
      'test_id': test_id,
      'cyl_text_size': currentTextSize,
    };
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        print('success with status cylTest: ${response.body}');
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => RedGreenTest()),
        );
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
}

class RedGreenTest extends StatefulWidget {
//for Red Green Test Screen
  @override
  redgreen createState() => redgreen();
}

class redgreen extends State<RedGreenTest> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  late List<CameraDescription> _cameras;
  // bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    fetchData();
    _initializeCamera();
    _configureTts();
    _onReplayPressed();
  }

  final FlutterTts flutterTts = FlutterTts();
  late Future<void> _captureProcess;

  void _configureTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _onReplayPressed() {
    const String replayText =
        "Thanks for going through the test. We are now going to show you random letters basis your test results on a red and green background. You have to observe and tell in which colour do you see letters more better.You only need to identify and tell which colour background is better than the other. Lets start the test. if more than 2 times same colour chosen We recommend you to redo the test and follow all instructions correctly";
    _speak(replayText);
  }

/*
  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    CameraDescription? frontCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () =>
          _cameras.isEmpty ? throw 'No camera available' : _cameras[0],
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium);

    await _controller?.initialize();
    //  _controller?.setZoomLevel(-2.5);

    if (mounted) {
      setState(() {});
    }
    // Start capturing images per second
    _captureProcess = _captureImagePerSecond();
  }

  _captureImagePerSecond() async {
    // Capture an image every second
    while (true) {
      XFile? image = await _controller
          ?.takePicture(); // Process the captured image as needed
      print('Image captured: ${image?.path}');
      // Delay to capture image per second
      capturePhoto(image!);
      await Future.delayed(Duration(seconds: 1));
      // regpatient1(image);
    }
  }

  void capturePhoto(XFile photo) async {
    // Note: `controller` being initialized as shown in readme
    // https://pub.dev/packages/camera#example

    List<int> photoAsBytes = await photo.readAsBytes();
    String photoAsBase64 = convert.base64Encode(photoAsBytes);
    sendDistanceRequest(photoAsBase64);
  }
*/
  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    CameraDescription? frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras!.isEmpty ? throw 'No camera available' : _cameras![0],
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium);

    _initializeControllerFuture = _controller!.initialize();

    try {
      await _initializeControllerFuture;
      if (mounted) {
        setState(() {
          // _isCapturing = true;
          _captureProcess = _captureImagePerSecond();
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _captureImagePerSecond() async {
    // while (_isCapturing) {
      try {
        XFile image = await _controller!.takePicture();
        print('Image captured: ${image.path}');
        capturePhoto(image);
        await Future.delayed(Duration(seconds: 1));
      } catch (e) {
        // if (_isCapturing) {
        //   print('Error capturing image: $e');
        // }
      // }
    }
  }

  void capturePhoto(XFile photo) async {
    List<int> photoAsBytes = await photo.readAsBytes();
    String photoAsBase64 = base64Encode(photoAsBytes);
    sendDistanceRequest(photoAsBase64);
  }
  Future<void> sendDistanceRequest(String image) async {
    var apiUrl =
        '${Api.baseurl}/api/eye/calculate-distance'; // Replace with your API endpoint
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var distanceType;
    String text = prefs.getString('test') ?? '';
    print("testTypecam:--" + text);
    if (text == 'myopia') {
      distanceType = 'fardistance';
    } else if (text == 'hyperopia') {
      distanceType = 'neardistance';
    } //print('image$image');

    try {
      var frameData =
          image; // Replace this with your frame data as a base64 string
      // var distanceType = testname//'neardistance'; // Replace this with the distance type

      var requestBody = jsonEncode({
        'frameData': frameData,
        'test_distance': distanceType,
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken =
          // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
          prefs.getString('access_token') ?? '';
      String CustomerId = prefs.getString('customer_id') ?? '';

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authToken} ',
          'Customer-Id': CustomerId,
        },
        body: requestBody,
      );
      print("frameData: " + frameData);
      // print("test_distance :" + distanceType);
      print("response-camera${response.body}");
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        String alertMessage = data['alert'];

        // print(alertMessage);
        // Handle the response data here
        //   print('Request sucxsss with status: ${response.body}');

        //  print("alert$alertMessage");
        setState(() {
          alert = alertMessage;
        });
      } else {
        Map<String, dynamic> data = jsonDecode(response.body);

        String alertMessage = data['alert'];
        alert = alertMessage;
        //   print('Request failed with status: ${response.statusCode}');
        //   print('Request failed with status: ${response.body}');
        setState(() {
          alert = alertMessage;
          print("alert$alertMessage");
        });

        // Handle error response
      }
    } catch (e) {
      if (e is SocketException) {
        CustomAlertDialog.attractivepopup(
            context, 'poor internet connectivity , please try again later!');
      } else {
        /* CustomAlertDialog.attractivepopup(
            context, 'make sure you have proper light on your face ');*/
      }

// If the server returns an error response, throw an exception
      //throw Exception('Failed to send data');
    }
  }

  @override
  void dispose() {
    // _isCapturing = false;
    _controller?.dispose();
    flutterTts.stop();
    super.dispose();
  }

  String alert = '';
  Map<String, dynamic> _data = {};
  static String action = "";
  String snellenFraction = '0', randomText = 'W';
  double textSize = 10;
  late bool isComplete;
  late bool testcancel;

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken =
        // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
        prefs.getString('access_token') ?? '';
    String CustomerId = prefs.getString('customer_id') ?? '';

    String test_id = prefs.getString('test_id') ?? '';
    print('mytestid$test_id');

    final String apiUrl =
        '${Api.baseurl}/api/eye/snellen-fraction-red-green-test?test_id=$test_id';
// Replace these headers with your required headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
      'Customer-Id': CustomerId
    };
// Replace this with your PUT request body

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
//body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        print('success with get Red/green Test: ${response.body}');
// If the call to the server was successful, parse the JSON
        _data = json.decode(response.body);
        snellenFraction = _data['snellen_fraction'];
        textSize = _data['text_size'];
        print('Red/green Test: $snellenFraction');
        snellenFraction;
        setState(() {
          textSize;
        });
      }
// If the server did not return a 200 OK response,
// handle the error here (display error message or take appropriate action)
      print('Failed with status code: ${response.statusCode}');
    } catch (e) {
      if (e is SocketException) {
        CustomAlertDialog.attractivepopup(
            context, 'poor internet connectivity , please try again later!');
      }

// If the server returns an error response, throw an exception
      throw Exception('Failed to send data');
    }
  }

  //double imageSize = 200.0; // Initial image size
  Map<String, dynamic>? paymentIntent;
  String selectedPlan = 'a', expiry_date = 'b';
  String test_left = '0';
  late String subscriptionId;

  Future<void> _callAPI() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken =
        // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
        prefs.getString('access_token') ?? '';
// Replace this URL with your PUT API endpoint
    String test_id = prefs.getString('test_id') ?? '';
    String CustomerId = prefs.getString('customer_id') ?? '';
    print('snellen_fraction: $snellenFraction');
    print('test_id: $test_id');
    print('action: $CustomerId');
    final String apiUrl = '${Api.baseurl}/api/eye/final-red-green-action-test';
// Replace these headers with your required headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
      'Customer-Id': CustomerId
    };
// Replace this with your PUT request body
    Map<String, dynamic> body = {
      'action': action,
      'test_id': test_id,
      'snellen_fraction': snellenFraction,
    };
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );
      print("red-green test:" + response.body);
      print("test_id:" + test_id);

      if (response.statusCode == 200) {
        print('success with get Red/green Test: ${response.body}');
// If the call to the server was successful, parse the JSON
        _data = json.decode(response.body);
        snellenFraction = _data['data']['snellen_fraction'];
        textSize = _data['data']['text_size'];
        isComplete = _data['data']['is_completed'];
        testcancel = _data['data']['test_cancel'];
        print('testcancel: $testcancel + $isComplete');

        randomText = _data['data']['random_text'];
        print('Red/green Test: $snellenFraction');
        print('Red/green Test: $randomText');
        print('Red/green Test: $textSize');
        setState(() {
          snellenFraction;
          textSize;
          randomText;
        });
        if (isComplete == true) {
          UpdateRedGreenTest();
        }
        if (testcancel == true) {
          CustomAlertDialog.attractivepopup(context,
              'Please do the test again and follow the instructions carefully ... ');
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => GiveInfo()),
          );
        }
      }
// If the server did not return a 200 OK response,
// handle the error here (display error message or take appropriate action)     }
    } catch (e) {
      if (e is SocketException) {
        CustomAlertDialog.attractivepopup(
            context, 'poor internet connectivity , please try again later!');
      }

// If the server returns an error response, throw an exception
      throw Exception('Failed to send data');
    }
  }

  Future<void> UpdateRedGreenTest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken =
        // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
        prefs.getString('access_token') ?? '';
    String test_id = prefs.getString('test_id') ?? '';
    String CustomerId = prefs.getString('customer_id') ?? '';

// Replace this URL with your PUT API endpoint
    final String apiUrl = '${Api.baseurl}/api/eye/update-red-green-action-api';
// Replace these headers with your required headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
      'Customer-Id': CustomerId //$access_token
    };
// Replace this with your PUT request body
    Map<String, dynamic> body = {
      'test_id': test_id,
      'snellen_fraction': snellenFraction,
    };
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        print('success with status next redgreen test: ${response.body}');
// If the call to the server was successful, parse the JSON
        setState(() {});
        _data = json.decode(response.body);
        Map<String, dynamic> jsonResponseMap = json.decode(response.body);

// Extracting age
        if (jsonResponseMap.containsKey("data") &&
            jsonResponseMap["data"].containsKey("data") &&
            jsonResponseMap["data"]["data"].containsKey("eye_status")) {
          String eyeStatus = jsonResponseMap["data"]["data"]["eye_status"];
          //  String patientName = jsonResponseMap["data"]["data"]["full_name"];
          String patientAge = jsonResponseMap["data"]["user_age"];
          int age = int.tryParse(patientAge) ?? 0; // Safely parse age
          print("Patient Age: $age");

          if (eyeStatus == "right") {
            if (age >= 40) {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => ReadingTest()),
              );
            } else {
              // Navigate to appropriate screen based on age and eye status
              if (age < 40 && jsonResponseMap["data"]['data']["is_completed"]) {
                print("ssssssssss");
                // If age < 40 and the test is completed, navigate to the TestReport
                CustomAlertDialog.attractivepopup(
                    context, 'You Have Successfully Completed Eye Test.....');
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('page', "redgreen");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TestReport()));
              } else {
                // Otherwise, navigate to the next appropriate screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReadingTest()),
                );
              }
            }
          } else {
            if (age >= 40) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReadingTest()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RightEye()),
              );
            }
          }
        } else {
          print("Invalid response format or missing 'eye_status' field.");
        }
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

  final bool _isCameraVisible = true;

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
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      'Red/Green Test',
                      style: TextStyle(
                        fontSize: 24.0,
                        color: Color(0xFF1E3777),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: GestureDetector(
                      onTap: _onReplayPressed,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Image.asset(
                                'assets/play_circle_fill.png',
                                width: 50,
                                height: 40,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Replay Audio',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 10.0),
                    child: InkWell(
                      onTap: () {
                        action = "red";
                        _callAPI();
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        color: Colors.red.shade700,
                        child: Center(
                          child: Text(
                            randomText,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: textSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 10.0),
                    child: InkWell(
                      onTap: () {
                        action = "green";
                        _callAPI();
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        color: Colors.green.shade700,
                        child: Center(
                          child: Text(
                            randomText,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: textSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10, height: 10),
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      alert,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color:
                            alert == 'Good to go' ? Colors.green : Colors.red,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                  // Add some space to avoid overlap with the button
                ],
              ),
            ),
          ),
          Positioned(
            right: 10,
            child: Visibility(
              visible: _isCameraVisible,
              child: Container(
                width: 100.0,
                height: 150.0,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: InteractiveViewer(
                  minScale: 0.1,
                  maxScale: 1.5,
                  child: _controller != null
                      ? CameraPreview(_controller!)
                      : Container(),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 10,
            right: 10,
            child: Container(
              height: 50.0,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.bluebutton, // Change to your desired color
                borderRadius: BorderRadius.circular(25),
              ),
              child: MaterialButton(
                onPressed: () {
                  // Call your function here
                  UpdateRedGreenTest();
                },
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RightEye extends StatefulWidget {
//for Red Green Test Screen
  @override
  RightEyeState createState() => RightEyeState();
}

class RightEyeState extends State<RightEye> {
  @override
  void initState() {
    super.initState();
    _configureTts();
    _onReplayPressed();
  }

  final FlutterTts flutterTts = FlutterTts();

  void _configureTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _onReplayPressed() {
    const String replayText =
        "We will start by testing your right eye. Please place your right hand palm on your right eye gently covering the eye. At any time do not put pressure on the eye or squint to see. Start by clicking on button right Eye";
    _speak(replayText);
  }

// Add your desired functionality here
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
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _onReplayPressed,
                        child: Container(
                          padding: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 4.0),
                                child: Image.asset(
                                  'assets/play_circle_fill.png',
                                  width: 50,
                                  height: 40,
                                ),
                              ),
                              SizedBox(width: 8),
                              // Adjust spacing between icon and text
                              Text(
                                'Replay Audio',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'Eye Test Instructions for Optimal Results',
                            style: TextStyle(
                              color: Colors.bluebutton,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: Image.asset(
                          'assets/right_eye_image.png',
                          width: 300,
                          height: 220,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            bulletText(
                                'Please place one hand over one eye while testing the other eye. This will help ensure accurate results during the test.'),
                            bulletText(
                                'For the virtual eye test, it\'s recommended to maintain a distance of approximately 50 cm from the screen. This distance is optimal for obtaining accurate results and facilitating thorough analysis of your vision.'),
                            bulletText(
                                'To facilitate the best possible testing conditions, we advise conducting the eye test in a well-lit room. Adequate lighting enhances the accuracy of the test results and ensures a comfortable testing experience for users.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: ElevatedButton(
                  onPressed: () {
                    select_eye_for_test('right', context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF4600A9),
                    // Set button background color
                    padding: EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text('Next'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> select_eye_for_test(String eye, BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken =
          // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
          prefs.getString('access_token') ?? '';
      String test = prefs.getString('test') ?? '';
      String CustomerId = prefs.getString('customer_id') ?? '';
      int id = 0;
      print('testt$test');

      var headers = {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
        'Customer-Id': CustomerId
      };
      var request =
          http.Request('POST', Uri.parse('${Api.baseurl}/api/eye/select-eye'));
      request.body =
          json.encode({"test_id": id, "eye_status": eye, "test": test});
      String request1 =
          json.encode({"test_id": id, "eye_status": eye, "test": test});
      request.headers.addAll(headers);
      print("rryryr$request1");
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> parsedJson = json.decode(responseBody);

        // Extract data from the parsed JSON
        String test = parsedJson['data']['test'];
        print("resp: $responseBody");
        String test_id = parsedJson['data']['id'].toString();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('test_id', test_id);
        // await prefs.setString('test', test);
        print("testname: $test");

        // Accessing the parsed data

        //print(await response.stream.bytesToString());
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => AlphabetTest()),
        );
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
}
//shadowtest2--redgreentest

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomElevatedButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.bluebutton, // Change the text color
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white, // Text color
            fontSize: 16,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class CustomElevatedButtonG extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomElevatedButtonG({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.bluebutton, width: 2.0), // Blue border
        backgroundColor: Colors.white, // Yellow background
        padding: EdgeInsets.symmetric(vertical: 1, horizontal: 20),
      ),
      child: Text(
        '+ $text', // Include the dash before the text
        style: TextStyle(
          color: Colors.bluebutton, // Text color
          fontSize: 18,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class CustomElevatedButtonY extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomElevatedButtonY({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.bluebutton, width: 2.0), // Blue border
        backgroundColor: Colors.white, // Yellow background
        padding: EdgeInsets.symmetric(vertical: 1, horizontal: 20),
      ),
      child: Text(
        '- $text', // Include the dash before the text
        style: TextStyle(
          color: Colors.bluebutton, // Text color
          fontSize: 18,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

void showCustomToast(BuildContext context, String message) {
  OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 50,
      left: MediaQuery.of(context).size.width * 0.2,
      right: MediaQuery.of(context).size.height * 0.1,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black26.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    ),
  );
  Overlay.of(context).insert(overlayEntry);
// Remove the toast after 2 seconds
  Future.delayed(Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}

class QuestionCheckbox extends StatefulWidget {
  final int questionId;
  final String questionText;
  final ValueChanged<bool> onChanged;

  QuestionCheckbox({
    required this.questionId,
    required this.questionText,
    required this.onChanged,
  });

  @override
  _QuestionCheckboxState createState() => _QuestionCheckboxState();
}

class _QuestionCheckboxState extends State<QuestionCheckbox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.questionText,
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Row(
                  children: [
                    Transform.scale(
                      scale: 1.3,
                      child: Theme(
                        data: ThemeData(
                          checkboxTheme: CheckboxThemeData(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: MaterialStateBorderSide.resolveWith(
                              (states) {
                                return BorderSide(
                                    color: Colors.bluebutton, width: 2);
                              },
                            ),
                            fillColor: MaterialStateProperty.resolveWith(
                              (states) {
                                if (states.contains(MaterialState.selected)) {
                                  return Colors
                                      .bluebutton; // Fill color when checked
                                }
                                return Colors
                                    .white; // Fill color when unchecked
                              },
                            ),
                            checkColor: MaterialStateProperty.resolveWith(
                              (states) {
                                if (states.contains(MaterialState.selected)) {
                                  return Colors
                                      .white; // Check color when checked
                                }
                                return Colors
                                    .bluebutton; // Check color when unchecked (hidden)
                              },
                            ),
                          ),
                        ),
                        child: Checkbox(
                          value: isChecked == true,
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked = value ?? false;
                            });
                            widget.onChanged(isChecked!);
                          },
                        ),
                      ),
                    ),
                    Text('Yes', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
              Row(
                children: [
                  Transform.scale(
                    scale: 1.3,
                    child: Theme(
                      data: ThemeData(
                        checkboxTheme: CheckboxThemeData(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: MaterialStateBorderSide.resolveWith(
                            (states) {
                              return BorderSide(
                                  color: Colors.bluebutton, width: 2);
                            },
                          ),
                          fillColor: MaterialStateProperty.resolveWith(
                            (states) {
                              if (states.contains(MaterialState.selected)) {
                                return Colors
                                    .bluebutton; // Fill color when checked
                              }
                              return Colors.white; // Fill color when unchecked
                            },
                          ),
                          checkColor: MaterialStateProperty.resolveWith(
                            (states) {
                              if (states.contains(MaterialState.selected)) {
                                return Colors.white; // Check color when checked
                              }
                              return Colors
                                  .bluebutton; // Check color when unchecked (hidden)
                            },
                          ),
                        ),
                      ),
                      child: Checkbox(
                        value: isChecked == false,
                        onChanged: (bool? value) {
                          setState(() {
                            isChecked = (value == true ? false : null)!;
                          });
                          widget.onChanged(isChecked ?? false);
                        },
                      ),
                    ),
                  ),
                  Text('No', style: TextStyle(color: Colors.black)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Question {
  final int id;
  final String questionText;

  Question({required this.id, required this.questionText});

  // Factory method to create a Question object from JSON
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      questionText: json['question_text'],
    );
  }
}
