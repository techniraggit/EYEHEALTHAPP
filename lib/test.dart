import 'package:flutter/material.dart';
import 'package:camera/camera.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SwipableCamera(),
    );
  }
}

class SwipableCamera extends StatefulWidget {
  @override
  _SwipableCameraState createState() => _SwipableCameraState();
}

class _SwipableCameraState extends State<SwipableCamera> {
  late CameraController _controller;
  late List<CameraDescription> _cameras;
  int _currentCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras[_currentCameraIndex],
      ResolutionPreset.high,
    );
    await _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _switchCamera() {
    setState(() {
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
      _controller = CameraController(
        _cameras[_currentCameraIndex],
        ResolutionPreset.high,
      );
      _controller.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.value.isInitialized) {
      return Stack(
        children: <Widget>[
          CameraPreview(_controller),
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.switch_camera),
              onPressed: _switchCamera,
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
