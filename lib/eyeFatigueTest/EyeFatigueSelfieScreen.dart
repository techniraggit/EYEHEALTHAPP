import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart' ;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'as convert;
import 'package:http/http.dart' as http;

import '../Custom_navbar/customDialog.dart';
import '../api/Api.dart';
import 'eyeFatigueTest.dart';

bool isclose=false;bool uploaded=false;
bool isLoading = false;bool startgame=false;bool gamepermission=false;
class EyeFatigueSelfieScreen extends StatefulWidget {
  @override
  EyeFatigueTestSelfieState createState() => EyeFatigueTestSelfieState();
}

class EyeFatigueTestSelfieState extends State<EyeFatigueSelfieScreen> {
  GlobalKey _cameraPreviewKey1 = GlobalKey();

  CameraController? _controller;
  late List<CameraDescription> _cameras;bool selfieloader=false;
  bool _isCameraInitialized = false; // Flag to track camera initialization
  @override
  void initState() {
    super.initState();
    // getPermission();
    _initializeCamera();
    isclose=false; uploaded=false;
    isLoading = false;startgame=false;gamepermission=false;
    sendcustomerDetails();

  }




  // void getPermission() async {
  //   PermissionStatus status = await Permission.storage.status;
  //   PermissionStatus status1 = await Permission.photos.status;
  //   PermissionStatus status2 = await Permission.microphone.status;
  //
  //   if((status==PermissionStatus.granted&&status2==PermissionStatus.granted) ){
  //     setState(() {
  //       _initializeCamera();
  //     });
  //
  //   }
  //   if (!status.isGranted ) {
  //     status = await Permission.storage.request();
  //   }
  //   if (!status2.isGranted ) {
  //     status = await Permission.microphone.request();
  //   }//status1==PermissionStatus.granted&&
  //   // if (!status1.isGranted ) {
  //   //   status1 = await Permission.photos.request();
  //   // }
  //   if (status == PermissionStatus.denied ||
  //       status == PermissionStatus.permanentlyDenied) {
  //     await [Permission.storage].request();
  //
  //     // Permissions are denied or denied forever, let's request it!
  //     status =  await Permission.storage.status;
  //     if (status == PermissionStatus.denied) {
  //       await [Permission.storage].request();
  //       print("storage permissions are still denied");
  //     } else if (status ==PermissionStatus.permanentlyDenied) {
  //       print("storage permissions are permanently denied");
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: Text("storage permissions required"),
  //             content: Text("storage permissions are permanently denied. Please go to app settings to enable files and media permissions."),
  //             actions: <Widget>[
  //               ElevatedButton(
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors
  //                       .background, // Set your desired background color here
  //                   // You can also customize other button properties here if needed
  //                 ),
  //                 onPressed: () async {
  //                   Navigator.pop(context); // Close the dialog
  //                   await openAppSettings();
  //                 },
  //                 child: Text("OK",
  //
  //                   style: TextStyle(
  //                       color: Colors.white, fontSize: 16),
  //                 ),
  //               ),
  //
  //             ],
  //           );
  //         },
  //       );
  //     }
  //   }
  //   // if (status1 == PermissionStatus.denied ||
  //   //     status1 == PermissionStatus.permanentlyDenied) {
  //   //   await [Permission.photos].request();
  //   //
  //   //   // Permissions are denied or denied forever, let's request it!
  //   //   status1 =  await Permission.photos.status;
  //   //   if (status1 == PermissionStatus.denied) {
  //   //     await [Permission.photos].request();
  //   //     print("photos permissions are still denied");
  //   //   }
  //   //    if (status1 ==PermissionStatus.permanentlyDenied) {
  //   //     print("photos permissions are permanently denied");
  //   //     showDialog(
  //   //       context: context,
  //   //       builder: (BuildContext context) {
  //   //         return AlertDialog(
  //   //           title: Text("photos permissions required"),
  //   //           content: Text("photos permissions are permanently denied. Please go to app settings to enable files and media permissions."),
  //   //           actions: <Widget>[
  //   //             ElevatedButton(
  //   //               style: ElevatedButton.styleFrom(
  //   //                 backgroundColor: Colors
  //   //                     .background, // Set your desired background color here
  //   //                 // You can also customize other button properties here if needed
  //   //               ),
  //   //               onPressed: () async {
  //   //                 Navigator.pop(context); // Close the dialog
  //   //                 await openAppSettings();
  //   //               },
  //   //               child: Text("OK",
  //   //
  //   //                 style: TextStyle(
  //   //                     color: Colors.white, fontSize: 16),
  //   //               ),
  //   //             ),
  //   //
  //   //           ],
  //   //         );
  //   //       },
  //   //     );
  //   //   }
  //   // }
  //   if (status2 == PermissionStatus.denied ||
  //       status2 == PermissionStatus.permanentlyDenied) {
  //     await [Permission.microphone].request();
  //
  //     // Permissions are denied or denied forever, let's request it!
  //     status2 =  await Permission.microphone.status;
  //     if (status2 == PermissionStatus.denied) {
  //       await [Permission.microphone].request();
  //       print("microphone permissions are still denied");
  //     }  if (status2 ==PermissionStatus.permanentlyDenied) {
  //       print("microphone permissions are permanently denied");
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: Text("microphone permissions required"),
  //             content: Text("microphone permissions are permanently denied. Please go to app settings to enable microphone permissions."),
  //             actions: <Widget>[
  //               ElevatedButton(
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors
  //                       .background, // Set your desired background color here
  //                   // You can also customize other button properties here if needed
  //                 ),
  //                 onPressed: () async {
  //                   Navigator.pop(context); // Close the dialog
  //                   await openAppSettings();
  //                 },
  //                 child: Text("OK",
  //
  //                   style: TextStyle(
  //                       color: Colors.white, fontSize: 16),
  //                 ),
  //               ),
  //
  //             ],
  //           );
  //         },
  //       );
  //     }
  //   }
  //
  //
  // }

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
    _cameras = await availableCameras();
    CameraDescription? frontCamera = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.isEmpty ? throw 'No camera available' : _cameras[0],
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium);
    await _controller!.initialize();

    if (mounted) {
      setState(() {
        _isCameraInitialized = true; // Set the flag to true when initialized
      });
    }


  }

  void _captureImage() async {
    // Capture images only if camera is initialized

    if (_isCameraInitialized) {
      try {
        XFile? image = await _controller!.takePicture();
        print('Image captured: ${image.path}');
        capturePhoto(image);
            } catch (e) {
        selfieloader=false;

        Fluttertoast.showToast(msg: "Image not Captured Properly , please capture again.");
        print('Error capturing image: $e');
        resetCameraPreview();
        _cameraPreviewKey1 = GlobalKey();

      }

      // await Future.delayed(Duration(seconds: 1));
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }
    super.dispose();
  }
  void resetCameraPreview() {
    setState(() {
      selfieloader=true;// Capture images only if camera is initialized

      // Generate a new GlobalKey to force the CameraPreview widget to rebuild
    });
  }
  @override

  Widget build(BuildContext context) {

    // if (!_isCameraInitialized) {
    //   return const Center(
    //     child: CircularProgressIndicator(),
    //   );
    // }
    if(_controller==null){
      return Container();
    }
    if (!_controller!.value.isInitialized) {
      return Container();
    }
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Eye Fatigue Test"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.bluebutton),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50.0), // Adjust this value as needed
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text('Look straight ahead, position your face inside the box, '
                            'and click capture button!',style: TextStyle(fontWeight: FontWeight.w400,color: Colors.black,fontSize: 16),),
                      ),
                      SizedBox(height: 11),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[


                          SizedBox(height: 20),
                           Container(
                             child: ClipRect(
                              child: FittedBox(
                                fit: BoxFit.cover,
                                key: _cameraPreviewKey1,

                                child: SizedBox(
                                  width: (_controller?.value.previewSize?.height ?? 0) / 2,
                                  height: (_controller?.value.previewSize?.width??0)/2,

                                  child: CameraPreview(_controller!),
                                ),
                              ),
                                                       ),
                           ),
                          SizedBox(height: 90),
                          // Container(
                          //   margin: EdgeInsets.all(20),
                          //   child: ElevatedButton(
                          //     onPressed: selfieloader ? null : () {
                          //       _captureImage();
                          //     },
                          //     style: ElevatedButton.styleFrom(
                          //       foregroundColor: Colors.white,
                          //       backgroundColor: Colors.bluebutton,
                          //       padding: EdgeInsets.all(16),
                          //       minimumSize: Size(300, 30),
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(22),
                          //       ),
                          //     ),
                          //     child: Text('Take Selfie'),
                          //   ),
                          // ),
      Container(
        margin: EdgeInsets.all(20),
        child: Stack(
          children: [
            ElevatedButton(
              onPressed: selfieloader ? null : () {
                setState(() {
                  selfieloader=true;
                });
                _captureImage();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // Assuming you have defined Colors.bluebutton somewhere
                padding: EdgeInsets.all(16),
                minimumSize: Size(300, 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Text('Take Selfie'),
            ),
            if (selfieloader)
              Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(), // Replace with your desired loader widget
                ),
              ),
          ],
        ),
      )

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

    List<int> photoAsBytes = await photo.readAsBytes();
    String photoAsBase64 = convert.base64Encode(photoAsBytes);
    //TODO implement new method
    SendImageApi(photoAsBase64);
  }

  Future<void> SendImageApi(String image) async {
    var apiUrl =
        '${Api.baseurl}/api/fatigue/take-user-selfie'; // Replace with your API endpoint



    try {
      var frameData =
          image; // Replace this with your frame data as a base64 string

      var requestBody = jsonEncode({
        'frameData': frameData,

      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userToken =
          prefs.getString("access_token") ?? '';
      String customer_access =
          prefs.getString("customer_token") ?? '';
print("access_token===="+userToken);
      print("customer_access===="+customer_access);

      if (userToken.isNotEmpty && customer_access.isNotEmpty) {
        Map<String, String> headers = {
          'Authorization': 'Bearer $userToken',
          'Customer-Access-Token': customer_access,
          'Content-Type': 'application/json',
        };

        http.Response response = await http.post(
          Uri.parse(apiUrl),
          headers: headers,
          body: requestBody,
        );


      print("frameData: " + frameData);
      print("headerss: " + headers.toString());

      // print("test_distance :" + distanceType);
      print("response-camera${response.body}");
      if (response.statusCode == 200) {

        Navigator.push(
           context,
           MaterialPageRoute(
               builder: (context) => EyeFatigueStartScreen()),
         );
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          selfieloader=false;
        });
      }
        if (response.statusCode == 404){
          setState(() {
            selfieloader=false;
          });
          final responseData = json.decode(response.body);
          String alertMessage = responseData['error'];
          Fluttertoast.showToast(msg: alertMessage);
          print("alertMessage-camera${alertMessage}");

        }
        else {
        final responseData = json.decode(response.body);
        String alertMessage = responseData['error'];
Fluttertoast.showToast(msg: alertMessage);
setState(() {
  selfieloader=false;
});

        // Handle error response
      }
    } }catch (e) {
      setState(() {
        selfieloader=false;
      });
      if (e is SocketException) {
        CustomAlertDialog.attractivepopup(
            context, 'poor internet connectivity , please try again later!');
      }


    }
  }




}