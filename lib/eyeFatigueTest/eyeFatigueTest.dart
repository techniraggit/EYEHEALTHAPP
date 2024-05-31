
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:light_compressor/light_compressor.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:project_new/HomePage.dart';
import 'package:project_new/eyeFatigueTest/eyeFatigueTestReport.dart';
import 'package:project_new/sign_up.dart';
// import 'package:video_compress/video_compress.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/Api.dart';
import '../api/config.dart';
bool isclose=false;bool uploaded=false;
bool isLoading = false;
class EyeFatigueStartScreen extends StatefulWidget {
  @override
  EyeFatigueStartScreenState createState() => EyeFatigueStartScreenState();
}

class EyeFatigueStartScreenState extends State<EyeFatigueStartScreen>{


  @override
  void initState() {
    super.initState();
    isclose=false; uploaded=false;
    isLoading = false;

  }







  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Eye Fatigue Test"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Add your back button functionality here
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              //  mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 5),
                Image.asset(
                  'assets/phone_image.png',

                  // Replace 'phone_image.svg' with your SVG asset path
                  width: 200, // Adjust image size as needed
                  height: 200,
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    'Welcome to Eye Health Fatique Meter',
                    style: TextStyle(
                        color: Colors.purple,
                        fontSize: 17,
                        fontWeight: FontWeight.w700
                    ), textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    'Keep your eyes healthy and productive with Eye Fatigue Meter. This innovative tool helps you monitor and manage eye strain caused by prolonged screen time and other factors.',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w400
                    ), textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 4),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    'Given below are a set of instructions. Take a moment to read them carefully. ',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600
                    ), textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 2),

                Padding(
                  padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(Icons.camera_alt),
                        title: Text('Position the camera at a reading distance parallel to your face.',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400),),
                      ),
                      ListTile(
                        leading: Icon(Icons.arrow_forward),
                        title: Text('In the next step, you’ll see some text appear at the top of the screen.',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400)),
                      ),
                      ListTile(
                        leading: Icon(Icons.record_voice_over),
                        title: Text('Simply read the content aloud until it ends.',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400)),
                      ),
                      // ListTile(
                      //   leading: Icon(Icons.timer),
                      //   title: Text('Once you’ve finished reading, kindly allow us a moment to review your results and create your customized report.'),
                      // ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EyeFatigueSecondScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                    // Background color
                    // Text color
                    padding: const EdgeInsets.all(16),
                    minimumSize: const Size(300, 40),
                    // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                      // Button border radius
                    ),
                  ),
                  child: const Text('Let\'s Check Eyes'),
                ),
              ],
            ),
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

class EyeFatigueSecondScreenState extends State<EyeFatigueSecondScreen> with SingleTickerProviderStateMixin{
  bool cancel=true;  final LightCompressor _lightCompressor = LightCompressor();
  bool isRecording = false;
  late String videoPath;  String? _compressedVideoPath;
  CameraController? _controller;
  late List<CameraDescription> cameras;
  late AnimationController _animationController;
  final List<String> _lines = [
    'Keep your eyes healthy and productive with Eye',
    'Fatigue Meter. This innovative tool helps you',
    'Monitor and manage eye strain caused by ',
    'Prolonged screen time and other factors. Simply',
    'Position yourself in front of the camera as ',
    'Indicated in the provided image',
  ];
  int _startIndex = 0;
  bool _firstTime = true;
  @override
  void dispose() {
    _controller?.dispose();
    _animationController.dispose();

    super.dispose();
  }
  @override

  void initState() {
    // TODO: implement initState
    super.initState();
    isclose=false; uploaded=false;
    isLoading = false;

    _initializeCamera();

    sendcustomerDetails();
  isloading();












    _animationController = AnimationController(
      duration: Duration(seconds: 9), // Adjust duration as needed
      vsync: this,
    );

    _startAnimation();

  }
  void _startAnimation() async {
    await _animationController.forward().orCancel;
    _startIndex += 3;
    if (_startIndex >= _lines.length) _startIndex = 0;
    _animationController.reset();
    _startAnimation();
  }
  Future<void> sendcustomerDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken =
    // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
    prefs.getString('access_token') ?? '';
    final String apiUrl = '${Api.baseurl}/api/fatigue/add-customer';
// Replace these headers with your required headers
    Map<String, String> headers = {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json',

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
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Extract the customer ID
        String customerAccessToken = jsonResponse['data']['token']['access'];
        prefs.setString('customer_token', customerAccessToken);
        print('customer_acess_token === ' + customerAccessToken);

      } else {
        print('Failed with status code: ${response.statusCode}');
        print('Failed sddd ${response.body}');
      }
    } catch (e) {
// Handle exceptions here (e.g., network errors)
      print('Exception: $e');
    }
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
  Future<void> _uploadVideo(String videoFile) async {
    isclose=true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token =
        prefs.getString('access_token') ?? '';
    String CustacsesToken =
        prefs.getString('customer_token') ?? '';
    var headers = {
      'Authorization': 'Bearer $token',
      'Customer-Access-Token': '$CustacsesToken',
    };
    print("token =$token      CustacsesToken ==========$CustacsesToken     ");
    final url = Uri.parse('${ApiProvider.baseUrl+"/api/fatigue/calculate-blink-rate"}'); // Replace with your API endpoint
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('video',videoFile));
    request.headers.addAll(headers);

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);


      print('Video upload=response=${response.body}');
      if (response.statusCode == 200) {

        print('Video uploaded successfully');
        setState(() {
          uploaded=true;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EyeFatigueThirdScreen()),
        );

        // MyProgressDialog.dismissProgressDialog(progressDialog!);

      } else {
        // MyProgressDialog.dismissProgressDialog(progressDialog!);
        Fluttertoast.showToast(msg: "face is not captured properly, please test again");
        setState(() {
          isclose=false; uploaded=false;
          isLoading = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage()),
        );
        print('Failed to upload video');
      }
    } catch (e) {
      isclose=false; uploaded=false;
      isLoading = false;
      print('Error uploading video: $e');
    }
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

      await Future.delayed(const Duration(seconds: 30));

      if (_controller!.value.isRecordingVideo) {
        final XFile file = await _controller!.stopVideoRecording();
        isRecording = false;


        print('Video recorded to: ${file.path}');

        // Verify file existence
        if (await File(file.path).exists()) {
          setState(() {
            isLoading=true;
            print("isLoading========$isLoading");

          });
          final videoFile = File(file.path);
          final videoSizeBytes = await videoFile.length();
          print('Video size: ${videoSizeBytes / (1024 * 1024)} MB'); // Convert bytes to MB for readability

          setState(() {
            _compressedVideoPath = null; // Reset compressed video path
          });

          final String videoName =
              'MyVideo-${DateTime.now().millisecondsSinceEpoch}.mp4';

          final Result response = await _lightCompressor.compressVideo(
            path: file.path,
            videoQuality: VideoQuality.low,
            isMinBitrateCheckEnabled: false,
            video: Video(videoName: videoName),
            android: AndroidConfig(isSharedStorage: true, saveAt: SaveAt.Movies),
            ios: IOSConfig(saveInGallery: false),
          );

          if (response is OnSuccess) {
            setState(() async {
              final videoFile = File(response.destinationPath);
              final videoSizeBytes = await videoFile.length();
              print('Compressed Video size: ${videoSizeBytes / (1024 * 1024)} MB');
              _uploadVideo(response.destinationPath);

              print('Compressed video path: ${response.destinationPath}');
            });
          } else if (response is OnFailure) {
            setState(() {
              Fluttertoast.showToast(msg: "${response.message}");

            });
          } else if (response is OnCancelled) {
            Fluttertoast.showToast(msg: "${response.isCancelled}");
            print(response.isCancelled);
          }
          // setState(() {
          //   _compressedVideoPath = response;
          // });





          // _uploadVideo(compressedVideo!.path!);






        } else {
          print('File does not exist.');
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press here
        // Return true to allow back navigation, false to prevent it
        return false; // Set to false to prevent back navigation
      },
      child: MaterialApp(
        home: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background_fatigue.png'), // Replace 'assets/background_image.jpg' with your image path
                fit: BoxFit.cover,
              ),
            ),
            child: isLoading
                ?
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Please wait, we are fetching your report...",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
                :  Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
      
      
      
      
      
      
                const SizedBox(height: 10),
              Column(
                children: [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: List.generate(3, (index) {
                          final lineIndex = (_startIndex + index) % _lines.length;
                          final line = _lines[lineIndex];
                          final animationValue = _animationController.value;
                          final opacity = 1.0 - animationValue;
                          final translateY = (1.0 - opacity) * 100.0;
                          return Transform.translate(
                            offset: Offset(0.0, translateY),
                            child: Opacity(
                              opacity: opacity,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  line,
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  )
                ],
              ),


                const SizedBox(height: 10),
                const Spacer(),
      
                // Visibility(
                //   visible: cancel,
                //   child: Padding(
                //     padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                //     child: Container(
                //       color: Colors.lightBlue.shade300,
                //       child: Row(
                //         children: [
                //           const Expanded(
                //             child: Padding(
                //               padding: EdgeInsets.all(8.0),
                //               child: Text(
                //                 'Read the ON Your screen and we have assessed your eye health based on reading ability',
                //                 style: TextStyle(
                //                   color: Colors.white,
                //                   fontSize: 14,
                //                 ),
                //               ),
                //             ),
                //           ),
                //           const SizedBox(width: 8),
                //           // Add some space between the text and icon
                //           IconButton(
                //             icon: const Icon(
                //               Icons.close,
                //               size: 24,
                //               color: Colors.white,
                //             ),
                //             onPressed: () {
                //               setState(() {
                //                 cancel=false;
                //               });
                //             },
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
      
                // Spacer to push the button to the bottom
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: ElevatedButton(
                    onPressed: isclose ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EyeFatigueThirdScreen(),
                        ),
                      );
                    } : null,

                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:  isclose ? Colors.purple.shade300 : Colors.grey.shade300 ,
      
                      // backgroundColor: Colors.purple.shade300,
                      minimumSize: const Size(350, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
      
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> isloading() async {
    // Delay for 30 seconds
    await Future.delayed(const Duration(seconds: 30));

    // After 30 seconds, update isLoading
    setState(() {
      isLoading = true;
    });
  }
}

class EyeFatigueThirdScreen extends StatefulWidget {
  @override
  EyeFatigueThirdScreenState createState() => EyeFatigueThirdScreenState();
}

class EyeFatigueThirdScreenState extends State<EyeFatigueThirdScreen> {
  bool success = false;bool enable=false;
@override
  void initState() {

    // TODO: implement initState
    super.initState();
    sendReportDb();
  }
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
    return   WillPopScope(
      onWillPop: () async {
        // Handle back button press here
        // Return true to allow back navigation, false to prevent it
        return false; // Set to false to prevent back navigation
      },
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Center(
              // Centering the title horizontally
              child: Text("Eye Fatigue Test"),
            ),
          ),
          body:
           uploaded
        ? const Center(
        child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "Please wait, we are fetching your report...",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      )
          :
           Column(
             // mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Image.asset(
                 'assets/congrats_icon.png',
                 width: 300,
                 height: 300,
               ),
               const SizedBox(height: 8),
               const Padding(
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
               const SizedBox(height: 10),
               const Padding(
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
               const SizedBox(height: 20),
               ElevatedButton(
                 onPressed:enable ? () async {
                   setState(() {
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                           builder: (context) => EyeFatigueTestReport()),
                     );
                   });
                 }:null,
                 style: ElevatedButton.styleFrom(
                   foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                   padding: const EdgeInsets.all(16),
                   minimumSize: const Size(300, 40),
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(26),
                   ),
                 ),
                 child: const Text('GO TO REPORTS'),
               ),
             ],
           )


        ),
      ),
    );
  }

  // Function to build UI after data is loaded
  Future<void> sendReportDb() async {
    try {
      var sharedPref = await SharedPreferences.getInstance();
      String userToken =
          sharedPref.getString("access_token") ?? '';
      String customer_access =
          sharedPref.getString("customer_token") ?? '';
      Map<String, String> headers = {
        'Authorization': 'Bearer $userToken',
        'Customer-Access-Token':customer_access,

// Bearer token type
      };
      print("userrrtoken====000============${userToken}===================customer_access=======$customer_access");

      final response = await http.get(
        Uri.parse('${ApiProvider.baseUrl}/api/fatigue/blinks-report-details'),
        headers: headers,
      );
      print("senddata====0000000===========${response.body}");
      print("senddata====0000000=========== status code ${response.statusCode}");

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(()  {
        int  report_id=responseData['data']['report_id'];

        sharedPref.setInt('report_id', report_id);
        print("report____--id${report_id.toString()}");
          uploaded=false;
          enable=true;
        });





      }
      else if (response.statusCode == 401)
      {
        setState(() {
          isclose=false; uploaded=false;
          isLoading = false;
        });
        Fluttertoast.showToast(msg: "Session Expired");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      }
      else if(response.statusCode == 500) {
        setState(() {
           isclose=false; uploaded=false;
           isLoading = false;
        });
        Fluttertoast.showToast(msg: "Server error occurred, Please try again.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }else{
        setState(() {
          isclose=false; uploaded=false;
          isLoading = false;
        });
        if (responseData.containsKey('error')) {

          // Handle the case when no data is found
          String errorMessage = responseData['error'];
          String message = responseData['msg'];
          print('$errorMessage: $message');
          Fluttertoast.showToast(msg:message );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
          // You can show an appropriate message to the user or take other actions as needed
        }
        throw Exception('Failed to load data');
      }
    } on DioError catch (e) {
      setState(() {
        isclose=false; uploaded=false;
        isLoading = false;
      });
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

  // Function to fetch demo data (replace with your actual API call)
  Future<Map<String, dynamic>> fetchData() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulating API call delay
    return {'message': 'Hello from API'}; // Demo data
  }
}
