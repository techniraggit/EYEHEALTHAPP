import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:project_new/testScreen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import 'package:image_picker/image_picker.dart';
import 'Api.dart';
import 'customDialog.dart';

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

  @override
  void initState() {
    super.initState();
    //validtoken(context);
    _initializeCamera();
  }

  Future<void> validtoken(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String access_token = prefs.getString('access') ?? '';

    Map<String, String> headers = {
      'Authorization': 'Bearer $access_token',
    };

    final String apiUrl =
        'https://testing1.zuktiapp.zuktiinnovations.com/check-token-expiry-api/';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: headers,
//body: jsonEncode(body),
    );
    print(response.body);
    if (response.statusCode == 200) {
      print("ValidToken" + response.body);
    } else {
      //todo
      /* Navigator.push
        (context,
        CupertinoPageRoute(builder: (context) => MyLogin()),
      );
*/
    }
  }

  Future<void> _initializeCamera() async {
    /**WidgetsFlutterBinding.ensureInitialized();

        SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        ]);**/
    _cameras = await availableCameras();
    CameraDescription? frontCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () =>
          _cameras.isEmpty ? throw 'No camera available' : _cameras[0],
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium);
//medium for myopia, zoom level1
    await _controller?.initialize();
    //_controller?.setZoomLevel(-1);

    if (mounted) {
      setState(() {});
    }
    // Start capturing images per second
    _captureImagePerSecond();
  }

  void _captureImagePerSecond() async {
    // Capture an image every second
    while (true) {
      try {
        XFile? image = await _controller?.takePicture();
        if (image != null) {
          // Process the captured image as needed
          print('Image captured: ${image.path}');
          capturePhoto(image);
        } else {
          print('Failed to capture image.');
        }
      } catch (e) {
        print('Error capturing image: $e');
      }

      // Delay to capture image per second
      await Future.delayed(Duration(seconds: 1));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String alert = '';

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => GiveInfo()),
            //  (route) => route.isFirst, // Remove until the first route (Screen 1)
          );
          return false;
        },
        child: Scaffold(
            body: Container(
                decoration: BoxDecoration(
                    /* image: DecorationImage(
                    image: AssetImage('assets/test.png'),
                    // Replace with your image asset
                    fit: BoxFit.cover,
                  ),*/
                    ),
                child: Center(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 1),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 90,
                              ),
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
                                    // Change text color here
                                    // You can also set other properties like fontWeight, fontStyle, etc.
                                  ),
                                ),
                              ),
                              Container(
                                width: 180,
                                height: 200,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: alert == 'Good to go'
                                          ? Colors.green
                                          : Colors.red,
                                      width: 2),
                                ),
                                child: ClipRect(
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width:
                                          _controller.value.previewSize?.height,
                                      height:
                                          _controller.value.previewSize?.width,
                                      child: CameraPreview(_controller),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                child: Container(
                                  margin: EdgeInsets.all(20),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _controller.dispose().then((_) {
                                        Navigator.pushReplacement(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (context) => LeftEyeTest()),
                                        );
                                      });
                                      // Add your button functionality here
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white, backgroundColor: Colors.bluebutton,
                                      // Text color
                                      padding: EdgeInsets.all(16),
                                      minimumSize: Size(200, 30),
                                      // Button padding
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        // Button border radius
                                      ),
                                    ),
                                    child: Text('Start Test Now'),
                                  ),
                                ),
                              ),
                            ]),
                      ]),
                ))));
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
        'http://192.168.29.221:8000/api/eye/calculate-distance'; // Replace with your API endpoint
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var distanceType;
    String text = prefs.getString('test') ?? '';
    print("testTypecam:--" + text);
    if (text == 'myopia') {
      distanceType = 'fardistance';
    } else if (text == 'hyperopia') {
      distanceType = 'neardistance';
    } //print('image$image');
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    //  String access_token = prefs.getString('access') ?? '';
    String access_token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk';
    try {
      var frameData =
          image; // Replace this with your frame data as a base64 string
      // var distanceType = testname//'neardistance'; // Replace this with the distance type

      var requestBody = jsonEncode({
        'frameData': frameData,
        'test_distance': distanceType,
      });

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Api.access_token} ',
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
