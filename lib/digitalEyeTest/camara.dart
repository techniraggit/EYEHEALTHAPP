import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:project_new/digitalEyeTest/testScreen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import 'package:image_picker/image_picker.dart';

import '../Custom_navbar/customDialog.dart';
import '../api/Api.dart';


class Camara extends StatelessWidget {
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
          home: CameraS(),
        ));
  }
}

class CameraS extends StatefulWidget {
  const CameraS({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraS> {
  late CameraController _controller;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false; // Flag to track camera initialization

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
    const String replayText = "Maintain the screen brightness at 50% throughout the eye test. Keep the device on a stable surface at the eye level. Keep the device at the recommended distance, for this follow the onscreen instructions throughout the eye test. Only move your face Move forward or backward till the time you see good to go sign on screen. Do not disturb or move the device from its position during the eye test. Are you ready? Let’s start the test. Please click on Start Eye Test Now.";
    _speak(replayText);
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    CameraDescription? frontCamera = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.isEmpty ? throw 'No camera available' : _cameras[0],
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium);
    await _controller.initialize();

    if (mounted) {
      setState(() {
        _isCameraInitialized = true; // Set the flag to true when initialized
      });
    }

    _captureImagePerSecond();
  }

  void _captureImagePerSecond() async {
    while (_isCameraInitialized) { // Capture images only if camera is initialized
      try {
        XFile? image = await _controller.takePicture();
        if (image != null) {
          print('Image captured: ${image.path}');
          capturePhoto(image);
        } else {
          print('Failed to capture image.');
        }
      } catch (e) {
        print('Error capturing image: $e');
      }

      await Future.delayed(Duration(seconds: 1));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String alert = '';
/*
  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => GiveInfo()),
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

        body:
        Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50.0), // Adjust this value as needed
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 1),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 90),
                      Container(
                        width: 320,
                        height: 40,
                        padding: EdgeInsets.all(8),
                        child: Text(
                          alert,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: alert == 'Good to go' ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                      Container(
                        width: 180,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: alert == 'Good to go' ? Colors.green : Colors.red,
                            width: 2,
                          ),
                        ),
                        child: ClipRect(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _controller.value.previewSize?.height,
                              height: _controller.value.previewSize?.width,
                              child: CameraPreview(_controller),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(20),
                        child: ElevatedButton(
                          onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                CupertinoPageRoute(builder: (context) => LeftEyeTest()),
                              );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.bluebutton,
                            padding: EdgeInsets.all(16),
                            minimumSize: Size(200, 30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text('Start Test Now'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => GiveInfo()),
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
        body: Column(
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
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50.0), // Adjust this value as needed
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 1),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 90),
                          Container(
                            width: 320,
                            height: 40,
                            padding: EdgeInsets.all(8),
                            child: Text(
                              alert,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: alert == 'Good to go' ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                          Container(
                            width: 180,
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: alert == 'Good to go' ? Colors.green : Colors.red,
                                width: 2,
                              ),
                            ),
                            child: ClipRect(
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: _controller.value.previewSize?.height,
                                  height: _controller.value.previewSize?.width,
                                  child: CameraPreview(_controller),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(20),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  CupertinoPageRoute(builder: (context) => LeftEyeTest()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.bluebutton,
                                padding: EdgeInsets.all(16),
                                minimumSize: Size(200, 30),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text('Start Test Now'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Replay audio button below app bar

          ],
        ),
      ),
    );
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
}
