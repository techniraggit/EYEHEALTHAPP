// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:fluttertoast/fluttertoast.dart';
//
// class UserVideo extends StatefulWidget {
//   final String text;
//
//   UserVideo({required this.text});
//
//   @override
//   _UserVideoState createState() => _UserVideoState();
// }
//
// class _UserVideoState extends State<UserVideo> {
//   CameraController? _controller;
//   bool _isMobile = false;
//   String? _imageData;
//   String? _distanceCheck;
//   String? _alertDistanceCheck;
//   bool _warningDisplayed = false;
//   Timer? _timer;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     _isMobile = _checkIfMobile();
//   }
//
//   @override
//   void dispose() {
//     _controller?.dispose();
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     final firstCamera = cameras.first;
//
//     _controller = CameraController(firstCamera, ResolutionPreset.high);
//
//     await _controller?.initialize();
//     if (!mounted) {
//       return;
//     }
//
//     setState(() {});
//
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       _captureImage();
//     });
//   }
//
//   bool _checkIfMobile() {
//     return (defaultTargetPlatform == TargetPlatform.iOS ||
//         defaultTargetPlatform == TargetPlatform.android);
//   }
//
//   void _captureImage() async {
//     if (_controller == null || !_controller!.value.isInitialized) {
//       return;
//     }
//
//     try {
//       final image = await _controller?.takePicture();
//       setState(() {
//         _imageData = base64Encode(Uint8List.fromList(image!.readAsBytesSync()));
//       });
//       _sendImageToBackend();
//     } catch (e) {
//       print('Error capturing image: $e');
//     }
//   }
//
//   Future<void> _sendImageToBackend() async {
//     if (_imageData == null) return;
//
//     final prefs = await SharedPreferences.getInstance();
//     final authToken = prefs.getString('business_access_token') ?? '';
//     final businessUrl = prefs.getString('BusinessBaseurl') ?? '';
//
//     final distanceText = widget.text == 'myopia' || widget.text == 'presbyopia'
//         ? 'fardistance'
//         : widget.text == 'hyperopia'
//         ? 'neardistance'
//         : 'fardistance';
//
//     final headers = {
//       'Authorization': 'Bearer $authToken',
//       'Content-Type': 'application/json'
//     };
//
//     final body = jsonEncode({
//       'frameData': _imageData,
//       'test_distance': distanceText,
//     });
//
//     try {
//       final response = await http.post(
//         Uri.parse('$businessUrl/calculate-distance/'),
//         headers: headers,
//         body: body,
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['alert'] != null) {
//           if ((data['alert'] == 'Move Back!' || data['alert'] == 'Move Closer!') && !_warningDisplayed) {
//             Fluttertoast.showToast(
//               msg: "Please don't move forward or backward",
//               toastLength: Toast.LENGTH_SHORT,
//               gravity: ToastGravity.BOTTOM,
//             );
//             setState(() {
//               _warningDisplayed = true;
//             });
//           }
//           setState(() {
//             _alertDistanceCheck = data['alert'];
//             _distanceCheck = data['distance'];
//           });
//         }
//       } else {
//         if (response.statusCode == 503) {
//           if (!_warningDisplayed) {
//             Fluttertoast.showToast(
//               msg: 'Please check your network connection and try again.',
//               toastLength: Toast.LENGTH_SHORT,
//               gravity: ToastGravity.BOTTOM,
//             );
//             setState(() {
//               _warningDisplayed = true;
//             });
//           }
//         } else {
//           final data = jsonDecode(response.body);
//           if (data['alert'] == 'Get In Range' && !_warningDisplayed) {
//             Fluttertoast.showToast(
//               msg: "Please don't move forward or backward",
//               toastLength: Toast.LENGTH_SHORT,
//               gravity: ToastGravity.BOTTOM,
//             );
//             setState(() {
//               _warningDisplayed = true;
//             });
//           }
//           setState(() {
//             _alertDistanceCheck = data['alert'];
//           });
//         }
//       }
//     } catch (e) {
//       print('Error sending image to backend: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_controller == null || !_controller!.value.isInitialized) {
//       return Center(child: CircularProgressIndicator());
//     }
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           CameraPreview(_controller!),
//           Positioned(
//             top: 50,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: Container(
//                 padding: EdgeInsets.all(8),
//                 color: _alertDistanceCheck == "Good to go" ? Colors.green : Colors.red,
//                 child: Text(
//                   _alertDistanceCheck ?? 'Get In Range',
//                   style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }