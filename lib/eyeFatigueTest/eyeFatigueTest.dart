
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:light_compressor/light_compressor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:project_new/HomePage.dart';
import 'package:project_new/sign_up.dart';
// import 'package:video_compress/video_compress.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../api/Api.dart';
import '../api/config.dart';
import '../dinogame/cactus.dart';
import '../dinogame/cloud.dart';
import '../dinogame/constants.dart';
import '../dinogame/dino.dart';
import '../dinogame/game_object.dart';
import '../dinogame/ground.dart';
import 'EyeFatigueSelfieScreen.dart';
import 'eyeFatigueTestReport.dart';


bool isclose=false;bool uploaded=false;
bool isLoading = false;bool startgame=false;bool gamepermission=false;
class EyeFatigueStartScreen extends StatefulWidget {
  @override
  EyeFatigueStartScreenState createState() => EyeFatigueStartScreenState();
}

class EyeFatigueStartScreenState extends State<EyeFatigueStartScreen>{


  @override
  void initState() {
    super.initState();
    isclose=false; uploaded=false;
    isLoading = false;startgame=false;gamepermission=false;

  }







  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Eye Fatigue Test"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
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
                          builder: (context) => EyeFatigueSelfieScreen()),
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
class MyTickerProvider1 implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

class MyTickerProvider2 implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}






class EyeFatigueSecondScreen extends StatefulWidget {
  @override
  EyeFatigueSecondScreenState createState() => EyeFatigueSecondScreenState();
}

class EyeFatigueSecondScreenState extends State<EyeFatigueSecondScreen> with SingleTickerProviderStateMixin{
  bool cancel=true;  final LightCompressor _lightCompressor = LightCompressor();
  bool isRecording = false;

  Dino dino = Dino();
  double runVelocity = initialVelocity;
  double runDistance = 0;
  int highScore = 0;
  TextEditingController gravityController =
  TextEditingController(text: gravity.toString());
  TextEditingController accelerationController =
  TextEditingController(text: acceleration.toString());
  TextEditingController jumpVelocityController =
  TextEditingController(text: jumpVelocity.toString());
  TextEditingController runVelocityController =
  TextEditingController(text: initialVelocity.toString());
  TextEditingController dayNightOffestController =
  TextEditingController(text: dayNightOffest.toString());
  double _position = 0.0;
  Timer? _timer;
  int _secondsLeft = 30;
  late AnimationController worldController;
  Duration lastUpdateCall = const Duration();

  List<Cactus> cacti = [Cactus(worldLocation: const Offset(200, 0))];

  List<Ground> ground = [
    Ground(worldLocation: const Offset(0, 0)),
    Ground(worldLocation: Offset(groundSprite.imageWidth / 10, 0))
  ];

  List<Cloud> clouds = [
    Cloud(worldLocation: const Offset(100, 20)),
    Cloud(worldLocation: const Offset(200, 10)),
    Cloud(worldLocation: const Offset(350, -10)),
  ];

  late String videoPath;  String? _compressedVideoPath;
  CameraController? _controller;
  late List<CameraDescription> cameras;
  late AnimationController _animationController;
  final List<String> _lines = [
    'Eyes, like tranquil pools reflecting the serenity of a forest, whisper tales of peace.',
    "In the gaze of nature's eyes, one finds solace amidst the chaos, a sanctuary of tranquility.",
    'With each glance, nature unfolds a silent symphony, a gentle reminder of its timeless beauty.',
    "Within nature's gaze lies the boundless expanse of the starlit sky, serene and captivating.",
    'Eyes, like serene sunsets painting the sky with hues of gold and amber, embody the warmth and calmness of nature.',
    "Within the depths of nature's eyes, discover the tranquil beauty of a forest glade, where sunlight dances through the leaves and birds sing melodies of peace.",
  ];
  int _startIndex = 0;
  bool _firstTime = true; AnimationController? _timercontroller;double? progress ;
  Animation<Color?> ?_animation;
  @override

  void initState() {
    // TODO: implement initState
    super.initState();
    isclose=false; uploaded=false;
    isLoading = false;startgame=false;gamepermission=false;
    Future.delayed(Duration(seconds: 1), () {

    _initializeCamera();

    startTimer();
    });

    // Future.delayed(Duration(seconds: 1), () {

      // startTimer();
    // });

  isloading();












    _animationController = AnimationController(
      duration: Duration(seconds: 9), // Adjust duration as needed
      vsync: MyTickerProvider1(),
    );

    _startAnimation();

    worldController = AnimationController(
      duration: const Duration(days: 99),
      vsync: MyTickerProvider2(),
    );
    worldController.addListener(_update);
    // worldController.forward();
    _die();

  }


  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }
    // _controller?.dispose();
    _animationController.dispose();
    gravityController.dispose();
    accelerationController.dispose();
    jumpVelocityController.dispose();
    runVelocityController.dispose();
    dayNightOffestController.dispose();
    _timer?.cancel();
    _timercontroller?.dispose();

    super.dispose();
  }
  void startTimer() {
    _timercontroller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 30),
    )..addListener(() {
      setState(() {});
    });

    _animation = ColorTween(
      begin: Colors.grey,
      end: Colors.purple,
    ).animate(_timercontroller!);

    _timercontroller?.forward();
    // _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    //   setState(() {
    //     _secondsLeft--;
    //     _position = _secondsLeft / 30;
    //   });
    //   if (_secondsLeft <= 0) {
    //     _timer?.cancel();
    //   }
    // });
  }

  void _die() {
    setState(() {
      worldController.stop();
      dino.die();
    });
  }

  void _newGame() {
    setState(() {
      highScore = max(highScore, runDistance.toInt());
      runDistance = 0;
      runVelocity = initialVelocity;
      dino.state = DinoState.running;
      dino.dispY = 0;
      worldController.reset();
      cacti = [
        Cactus(worldLocation: const Offset(200, 0)),
        Cactus(worldLocation: const Offset(300, 0)),
        Cactus(worldLocation: const Offset(450, 0)),
      ];

      ground = [
        Ground(worldLocation: const Offset(0, 0)),
        Ground(worldLocation: Offset(groundSprite.imageWidth / 10, 0))
      ];

      clouds = [
        Cloud(worldLocation: const Offset(100, 20)),
        Cloud(worldLocation: const Offset(200, 10)),
        Cloud(worldLocation: const Offset(350, -15)),
        Cloud(worldLocation: const Offset(500, 10)),
        Cloud(worldLocation: const Offset(550, -10)),
      ];

      worldController.forward();
    });
  }

  _update() {
    try {
      double elapsedTimeSeconds;
      dino.update(lastUpdateCall, worldController.lastElapsedDuration);
      try {
        elapsedTimeSeconds =
            (worldController.lastElapsedDuration! - lastUpdateCall)
                .inMilliseconds /
                1000;
      } catch (_) {
        elapsedTimeSeconds = 0;
      }

      runDistance += runVelocity * elapsedTimeSeconds;
      if (runDistance < 0) runDistance = 0;
      runVelocity += acceleration * elapsedTimeSeconds;

      Size screenSize = MediaQuery.of(context).size;

      Rect dinoRect = dino.getRect(screenSize, runDistance);
      for (Cactus cactus in cacti) {
        Rect obstacleRect = cactus.getRect(screenSize, runDistance);
        if (dinoRect.overlaps(obstacleRect.deflate(20))) {
          _die();
        }

        if (obstacleRect.right < 0) {
          setState(() {
            cacti.remove(cactus);
            cacti.add(Cactus(
                worldLocation: Offset(
                    runDistance +
                        Random().nextInt(100) +
                        MediaQuery.of(context).size.width / worlToPixelRatio,
                    0)));
          });
        }
      }

      for (Ground groundlet in ground) {
        if (groundlet.getRect(screenSize, runDistance).right < 0) {
          setState(() {
            ground.remove(groundlet);
            ground.add(
              Ground(
                worldLocation: Offset(
                  ground.last.worldLocation.dx + groundSprite.imageWidth / 10,
                  0,
                ),
              ),
            );
          });
        }
      }

      for (Cloud cloud in clouds) {
        if (cloud.getRect(screenSize, runDistance).right < 0) {
          setState(() {
            clouds.remove(cloud);
            clouds.add(
              Cloud(
                worldLocation: Offset(
                  clouds.last.worldLocation.dx +
                      Random().nextInt(200) +
                      MediaQuery.of(context).size.width / worlToPixelRatio,
                  Random().nextInt(50) - 25.0,
                ),
              ),
            );
          });
        }
      }

      lastUpdateCall = worldController.lastElapsedDuration!;
    } catch (e) {
      //
    }
  }

  void _startAnimation() async {
    await _animationController.forward().orCancel;
    _startIndex += 2;
    if (_startIndex >= _lines.length) _startIndex = 0;
    _animationController.reset();
    _startAnimation();
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

      // Fluttertoast.showToast(msg: "99999999999999999999999");

      print('Video upload=response=${response.body}');
      if (response.statusCode == 200)
      {
        // Fluttertoast.showToast(msg: "11111111111111111111");

        print('Video uploaded successfully');



        deleteVideo(videoFile);
        setState(() {
          uploaded=true;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EyeFatigueThirdScreen()),
        );

        // MyProgressDialog.dismissProgressDialog(progressDialog!);

      }
      else {
        // Fluttertoast.showToast(msg: "222222222222222222");
        // MyProgressDialog.dismissProgressDialog(progressDialog!);
        Fluttertoast.showToast(msg: "Something went wrong !!, please test again");
        setState(() {
          isclose=false; uploaded=false;
          isLoading = false;startgame=false;gamepermission=false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage()),
        );
        print('Failed to upload video');
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: "3333333333333333333");

      isclose=false; uploaded=false;
      isLoading = false;startgame=false;gamepermission=false;
      print('Error uploading video: $e');
      Fluttertoast.showToast(msg: "something went wrong ! please do test again ..");

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage()),
      );

    }
  }


  Future<void> _startVideoRecording() async {
    if (!_controller!.value.isInitialized) {
      return;
    }
    final directory = await getTemporaryDirectory(); // Get temporary directory
     videoPath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.mp4'; // Set the path in the temporary directory

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
        // if ( await File(file.path).exists()) {
        if (File(file.path).existsSync()) {
          setState(() {

            gamepermission=true; isLoading=true;


            // Fluttertoast.showToast(msg: "77777777777");

            print("isLoading========$isLoading");
            _compressAndUploadVideo(file.path);

          });







        } else {
          // Fluttertoast.showToast(msg: "888888888888");

          Fluttertoast.showToast(msg: "Your Phone doesnt have sufficient storage or you haven't given permission to media access");
          print('File does not exist.');
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }
  void _compressAndUploadVideo(String videoPath) async {
    final String videoName =
        'MyVideo-${DateTime.now().millisecondsSinceEpoch}.mp4';

    final Result response = await _lightCompressor.compressVideo(
      path: videoPath,
      videoQuality: VideoQuality.low,
      isMinBitrateCheckEnabled: false,android: AndroidConfig(isSharedStorage: true, saveAt: SaveAt.Movies),
      ios: IOSConfig(saveInGallery: false), video: Video(videoName: videoName),
    );

    // Fluttertoast.showToast(msg: "6666666666666666");

    if (response is OnSuccess) {
      // setState(() async {
        final videoFile = File(response.destinationPath);
        final videoSizeBytes = await videoFile.length();
        print('Compressed Video size: ${videoSizeBytes / (1024 * 1024)} MB');
        _uploadVideo(response.destinationPath);
        // Fluttertoast.showToast(msg: "444444444444444");

        print('Compressed video path: ${response.destinationPath}');
      // });
    }else {
      // Fluttertoast.showToast(msg: "555555555555555555555");

      Fluttertoast.showToast(msg: "you phone may have insufficient storage");
    }
    // else if (response is OnFailure) {
    //
    //   setState(() {
    //     Fluttertoast.showToast(msg: "${response.message}");
    //
    //   });
    // }
    // else if (response is OnCancelled) {
    //   Fluttertoast.showToast(msg: "${response.isCancelled}");
    //   print(response.isCancelled);
    // }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    List<Widget> children = [];
    for (GameObject object in [...clouds, ...ground, ...cacti, dino]) {
      children.add(
        AnimatedBuilder(
          animation: worldController,
          builder: (context, _) {
            Rect objectRect = object.getRect(screenSize, runDistance);
            return Positioned(
              left: objectRect.left,
              top: objectRect.top,
              width: objectRect.width,
              height: objectRect.height,
              child: object.render(),
            );
          },
        ),
      );
    }
    return WillPopScope(
      onWillPop: () async {

        // Handle back button press here
        // Return true to allow back navigation, false to prevent it
        return false; // Set to false to prevent back navigation
      },
      child: MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [

              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/background_fatigue.png'), // Replace with your image path
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Text and clickable span
              Visibility(
                visible:gamepermission,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        startgame=true;
                      });

                    },
                    child:
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: RichText(
                        text: TextSpan(
                          text: 'Want to play a game while you wait? ',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                          children: [
                            TextSpan(
                              text: 'Launch Game',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.none, // Remove underline
                              ),
                            ),
                            TextSpan(text: ''),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),











              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/background_fatigue.png'), // Replace 'assets/background_image.jpg' with your image path
                    fit: BoxFit.cover,
                  ),
                ),
                child: isLoading
                    ?
                Visibility(
                  visible: startgame,
                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 5000),
                                        color: (runDistance ~/ dayNightOffest) % 2 == 0
                        ? Colors.white
                        : Colors.black,
                                        child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        if (dino.state != DinoState.dead) {
                          dino.jump();
                        }
                        if (dino.state == DinoState.dead) {
                          _newGame();
                        }
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ...children,
                          AnimatedBuilder(
                            animation: worldController,
                            builder: (context, _) {
                              return Positioned(
                                left: screenSize.width / 2 - 30,
                                top: 100,
                                child: Text(
                                  'Score: ' + runDistance.toInt().toString(),
                                  style: TextStyle(
                                    color: (runDistance ~/ dayNightOffest) % 2 == 0
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                          AnimatedBuilder(
                            animation: worldController,
                            builder: (context, _) {
                              return Positioned(
                                left: screenSize.width / 2 - 50,
                                top: 120,
                                child: Text(
                                  'High Score: ' + highScore.toString(),
                                  style: TextStyle(
                                    color: (runDistance ~/ dayNightOffest) % 2 == 0
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),

                        ],
                      ),
                                        ),
                                      ),
                    )

                    : Column(
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
                            children: List.generate(2, (index) {
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

                    Spacer(),
    if (_timercontroller != null && _timercontroller!.value != null)... {

    Builder(
                  builder: (context) {
                    progress = _timercontroller?.value;

                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * progress!,
                        height: 10.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: _animation?.value,
                        ),
                      ),
                    );
                  }
                ),},



                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 25),
                    //   child: Container(
                    //     height: 13,color: Colors.background.withOpacity(0.8),
                    //     width: MediaQuery.of(context).size.width,
                    //
                    //     child: Stack(
                    //       children: [
                    //         AnimatedPositioned(
                    //           duration: Duration(seconds: 30),
                    //           curve: Curves.linear,
                    //           right: 0, // Start from the left
                    //           left: MediaQuery.of(context).size.width * (1 - _position),
                    //           child: Container(
                    //             height: 13,
                    //             color: Colors.grey.withOpacity(0.8),
                    //
                    //             width:  _position,//MediaQuery.of(context).size.width *
                    //
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(height: 40),
                    SizedBox(height: 50,),
                  ],
                ),
              ),
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
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              //   child: ElevatedButton(
              //     onPressed: isclose ? () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => EyeFatigueThirdScreen(),
              //         ),
              //       );
              //     } : null,
              //
              //     style: ElevatedButton.styleFrom(
              //       foregroundColor: Colors.white,
              //       backgroundColor:  isclose ? Colors.purple.shade300 : Colors.grey.shade300 ,
              //
              //       // backgroundColor: Colors.purple.shade300,
              //       minimumSize: const Size(350, 50),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(25),
              //       ),
              //     ),
              //     child: const Text('Close'),
              //   ),
              // ),

            ],
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

  Future<void> deleteVideo(String videoPath) async {
    try {
      final file = File(videoPath);
      if (await file.exists()) {
        await file.delete();
        // Fluttertoast.showToast(msg: "9999999999");

        print('Video deleted successfully');
      } else {
        // Fluttertoast.showToast(msg: "10101010010");

        print('Video file does not exist at the specified path');
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: "2121212");

      print('Error deleting video: $e');
    }
  }}

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
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Center(
              // Centering the title horizontally
              child: Text("Eye Fatigue Test"),
            ),
          ),
          body:
           uploaded
        ? const Center(

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
  Future<void> sendReportDb()  async {
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

      // Fluttertoast.showToast(msg: "3131313131");

      if (response.statusCode == 200) {

        setState(()  {
        int  report_id=responseData['data']['report_id'];

        sharedPref.setInt('report_id', report_id);
        print("report____--id${report_id.toString()}");
          uploaded=false;
          enable=true;
        });
        // Fluttertoast.showToast(msg: "414141441441411");





      }
      else if (response.statusCode == 401) {
        // Fluttertoast.showToast(msg: "5151515151");

        setState(() {
          isclose=false; uploaded=false;
          isLoading = false;startgame=false;gamepermission=false;
        });
        Fluttertoast.showToast(msg: "Session Expired");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      }
      else if(response.statusCode == 500) {
        // Fluttertoast.showToast(msg: "6161616161661616");

        setState(() {
          isclose=false; uploaded=false;
          isLoading = false;startgame=false;gamepermission=false;
        });
        Fluttertoast.showToast(msg: "Server error occurred, Please try again later.");
print("50000");

//TODO remove
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );

      }
      else{
        setState(() {
          isclose=false; uploaded=false;
          isLoading = false;startgame=false;gamepermission=false;
        });
        // Fluttertoast.showToast(msg: "71717711771717");

        if (responseData.containsKey('error')) {

          // Handle the case when no data is found
          String errorMessage = responseData['error'];
          if(responseData['msg']!=null){
          String message = responseData['msg'];
          print('$errorMessage: $message');
          Fluttertoast.showToast(msg:message );}
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
          // You can show an appropriate message to the user or take other actions as needed
        }
        throw Exception('Failed to load data');
      }
    }
    on DioError catch (e) {
      // Fluttertoast.showToast(msg: "8181818818181818");

      setState(() {
        isclose=false; uploaded=false;
        isLoading = false;startgame=false;gamepermission=false;
      });
      if (e.response != null || e.response!.statusCode == 401) {
        // Handle 401 error

        Fluttertoast.showToast(msg: "Session Expired");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      } else {
        // Fluttertoast.showToast(msg: "9191919199191919");

        // Handle other Dio errors
        print("DioError: ${e.error}");
      }
    } catch (e,Stacktrace) {
      // Handle other exceptions
      print("Exception---: $e======$Stacktrace");
    }
  }

  // Function to fetch demo data (replace with your actual API call)
  Future<Map<String, dynamic>> fetchData() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulating API call delay
    return {'message': 'Hello from API'}; // Demo data
  }
}
