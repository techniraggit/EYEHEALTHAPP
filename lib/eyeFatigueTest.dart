
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:project_new/eyeFatigueTestReport.dart';
import 'Api.dart';

class EyeFatigueStartScreen extends StatefulWidget {
  @override
  EyeFatigueStartScreenState createState() => EyeFatigueStartScreenState();
}

class EyeFatigueStartScreenState extends State<EyeFatigueStartScreen>{
  @override
  void initState() {
    super.initState();
  }
  Future<void> sendcustomerDetails(BuildContext context) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String access_token = prefs.getString('access') ?? '';
    final String apiUrl = '${Api.baseurl}/api/eye/add-customer';
// Replace these headers with your required headers
    Map<String, String> headers = {
      'Authorization': 'Bearer ${Api.access_token}',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
      );
      print('response === ' + response.body);
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('sddd ${response.body}');
        }
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EyeFatigueSecondScreen()),
        );
        Map<String, dynamic> jsonMap = jsonDecode(response.body);
      } else {
        print('Failed with status code: ${response.statusCode}');
        print('Failed sddd ${response.body}');
      }
    } catch (e) {
// Handle exceptions here (e.g., network errors)
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Eye Fatigue Test"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // Add your back button functionality here
            },
          ),
        ),
        body: Center(
          child: Column(
            //  mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/phone_image.png',
                // Replace 'phone_image.svg' with your SVG asset path
                width: 300, // Adjust image size as needed
                height: 300,
              ),
              SizedBox(height: 8),
              Text(
                'Welcome to Eye Health Fatique Meter',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 20,
                  fontWeight: FontWeight.w700
                ), textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Text(
                  'Keep your eyes healthy and productive with Eye Fatigue Meter.'
                  ' This innovative tool helps you monitor and manage eye strain caused by prolonged '
                  'screen time and other factors. Simply position yourself in front of '
                  'the camera as indicated in the provided image.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ), textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  sendcustomerDetails(context);

                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                  // Background color
                  // Text color
                  padding: EdgeInsets.all(16),
                  minimumSize: Size(300, 40),
                  // Button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                    // Button border radius
                  ),
                ),
                child: Text('Let\'s Check Eyes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EyeFatigueSecondScreen extends StatefulWidget {
  @override
  EyeFatigueSecondScreenState createState() => EyeFatigueSecondScreenState();
}

class EyeFatigueSecondScreenState extends State<EyeFatigueSecondScreen> {
  CameraController? _controller;
  late List<CameraDescription> cameras;
  bool isRecording = false;
  late String videoPath;
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front),
      ResolutionPreset.high,
    );

    await _controller!.initialize();
    _startVideoRecording();
  }

  Future<void> _startVideoRecording() async {
    if (!_controller!.value.isInitialized) {
      return;
    }
    final directory = await getApplicationDocumentsDirectory();
    videoPath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';

    try {
      await _controller!.startVideoRecording();
      isRecording = true;
      setState(() {});
      if (_controller!.value.isRecordingVideo) {
        final XFile file = await _controller!.stopVideoRecording();
        isRecording = false;
        videoPath = file.path;
        setState(() {});
        print('Video recorded to: $videoPath');
        if (videoPath != null) {

        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _uploadVideo(String videoFile) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String access_token = prefs.getString('access') ?? '';
// Replace these headers with your required headers
    Map<String, String> headers = {
      'Authorization': 'Bearer ${Api.access_token}',
    };

    try {
      var request = http.MultipartRequest('POST', Uri.parse('https://mobile.testing-f-meter-backend.zuktiinnovations.com/calculate-blink-rate/'));
      request.files.add(await http.MultipartFile.fromPath('video', videoFile));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('sddd ${response.reasonPhrase}');
        }
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EyeFatigueSecondScreen()),
        );
      } else {
        print('Failed with status code: ${response.statusCode}');
        print('Failed sddd ${response.reasonPhrase}');
      }
    } catch (e) {
// Handle exceptions here (e.g., network errors)
      print('Exception: $e');
    }
  }
  Future<void> sendcustomerDetails(BuildContext context) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String access_token = prefs.getString('access') ?? '';
    final String apiUrl = '${Api.baseurl}/api/eye/add-customer';
// Replace these headers with your required headers
    Map<String, String> headers = {
      'Authorization': 'Bearer ${Api.access_token}',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
      );
      print('response === ' + response.body);
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('sddd ${response.body}');
        }
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EyeFatigueSecondScreen()),
        );

      } else {
        print('Failed with status code: ${response.statusCode}');
        print('Failed sddd ${response.body}');
      }
    } catch (e) {
// Handle exceptions here (e.g., network errors)
      print('Exception: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.fromLTRB(12, 20, 12, 10),
              child: Text(
                'Keep your eyes healthy and productive with Eye Fatigue Meter.'
                ' This innovative tool helps you monitor and manage eye strain caused by prolonged '
                'screen time and other factors. Simply position yourself in front of '
                'the camera as indicated in the provided image.',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ), textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10),
            Spacer(),

           HideableContainer(),
            // Spacer to push the button to the bottom
            Padding(
              padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: ElevatedButton(
                onPressed: () {
                  _uploadVideo(videoPath);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EyeFatigueThirdScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.purple.shade300,
                  minimumSize: Size(350, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HideableContainer extends StatefulWidget {
@override
_HideableContainerState createState() => _HideableContainerState();
}

class _HideableContainerState extends State<HideableContainer> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Wrap the container with Visibility to manage its visibility.
          Visibility(
            visible: _isVisible,
            child: Container(
              color: Colors.lightBlue.shade300,
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Read the text on your screen and we have assessed your eye health based on reading ability',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 24,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isVisible = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class EyeFatigueThirdScreen extends StatefulWidget {
  @override
  EyeFatigueThirdScreenState createState() => EyeFatigueThirdScreenState();
}

class EyeFatigueThirdScreenState extends State<EyeFatigueThirdScreen> {
  bool success = false;

  /*Future<Map<String, dynamic>> fetchData() async {
    final response = await http.get(Uri.parse('https://api.example.com/data'));
    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      return json.decode(response.body);
    } else {
      // If the server did not return a 200 OK response, throw an exception
      throw Exception('Failed to load data from API');
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Center(
            // Centering the title horizontally
            child: Text("Eye Fatigue Test"),
          ),
        ),
        body: Center(
          child: FutureBuilder(
            future: fetchData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text(
                    'Please wait till loading...'); // Display text while loading
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                Object? data = snapshot.data;
                return dataLoadedUI(context);
              }
            },
          ),
        ),
      ),
    );
  }

  // Function to build UI after data is loaded
  Widget dataLoadedUI(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/congrats_icon.png',
          width: 300,
          height: 300,
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text(
            'Congratulations! You have completed the Eye Fatigue Test.',
            style: TextStyle(
              color: Colors.deepPurple,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.fromLTRB(15, 8, 15, 8),
          child: Text(
            'To view your results, go to the Report section to find your Eye Fatigue Test report and gain insights.',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
            textAlign: TextAlign.center, // Optional: align text center
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EyeFatigueTestReport()),
            );
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
            padding: EdgeInsets.all(16),
            minimumSize: Size(300, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
          ),
          child: Text('GO TO REPORTS'),
        ),
      ],
    );
  }

  // Function to fetch demo data (replace with your actual API call)
  Future<Map<String, dynamic>> fetchData() async {
    await Future.delayed(Duration(seconds: 2)); // Simulating API call delay
    return {'message': 'Hello from API'}; // Demo data
  }
}
