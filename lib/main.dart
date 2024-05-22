import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:project_new/HomePage.dart';
import 'package:project_new/eyeHealthTrack.dart';
import 'package:project_new/myPlanPage.dart';
import 'package:project_new/rewards.dart';
import 'dart:convert' as convert;

import 'package:project_new/testScreen.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51OJvAESInaGLb0MUv9RqwK5GqS1LhAWLWPfP2OVRyOzuVPepwaN9L58rWq3ixOUq39RKjkkjf2qUNjl782PntLLX00npNk74Y8';
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Camera Inside Movable Box',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyPlan(),
    );
  }
}

class CameraInsideBoxScreen extends StatefulWidget {
  @override
  _CameraInsideBoxScreenState createState() => _CameraInsideBoxScreenState();
}

class _CameraInsideBoxScreenState extends State<CameraInsideBoxScreen> {
  late CameraController _controller;
  double _boxLeft = 20;
  double _boxTop = 20;
  String alert = "";

  @override
  void initState() {
    super.initState();
    _controller = CameraController(cameras[1], ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _captureImagePerSecond();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      body: Stack(
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            child: Text(
              alert,
              style: TextStyle(
                color: Colors.green,
                fontSize: 16,
              ),
            ),
          ),
          Positioned(
            top: _boxTop,
            left: _boxLeft,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _boxLeft += details.delta.dx;
                  _boxTop += details.delta.dy;
                });
              },
              child: Container(
                width: 180,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.center,
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
              ),
            ),
          ),
        ],
      ),
    );
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

  void capturePhoto(XFile photo) async {
    // Note: `controller` being initialized as shown in readme
    // https://pub.dev/packages/camera#example

    List<int> photoAsBytes = await photo.readAsBytes();
    String photoAsBase64 = convert.base64Encode(photoAsBytes);
    sendDistanceRequest(photoAsBase64);
  }

  Future<void> sendDistanceRequest(String image) async {
    var apiUrl =
        'https://testing.backend.zuktiinnovations.com/testing-client-user-count/';
    //String access_token='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzAyNzQ5NTUxLCJpYXQiOjE3MDI3NDIzNTEsImp0aSI6IjIxMzkzZDRmYzQ3ZDQ1MjM4NDc3Y2VmNzQ4ZTU1NDdhIiwidXNlcl9pZCI6ImZjNTUyNmEwLWFmMGUtNGVkNC04MjI4LTM1ZDhmYzdhYjNkNiJ9.zLipkYla_S2wko9GcrsGho80rlaa0DA_lIz-akHf-7o';
    try {
      var frameData =
          image; // Replace this with your frame data as a base64 string
      // var distanceType = testname//'neardistance'; // Replace this with the distance type

      var requestBody = jsonEncode({
        'frameData': frameData,
      });

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );
      print("response-camera" + response.body);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        String alertMessage = data['message'];
        String dis = data['distance'];

        // print(alertMessage);
        // Handle the response data here
        //   print('Request sucxsss with status: ${response.body}');

        //  print("alert$alertMessage");
        setState(() {
          alert = alertMessage + " " + dis;
        });
      } else {
        Map<String, dynamic> data = jsonDecode(response.body);

        String alertMessage = data['message'];
        String dis = data['distance'];
        alert = alertMessage + " " + dis;
        //   print('Request failed with status: ${response.statusCode}');
        //   print('Request failed with status: ${response.body}');
        setState(() {
          alert = alertMessage;
        });

        // Handle error response
      }
    } catch (e) {}

// If the server returns an error response, throw an exception
    //throw Exception('Failed to send data');
  }
}

/*

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
  'pk_test_51JFH9zSGTdxZA1VVPlzCM1b4ztYvbz452v792r5iofLUkOdc15YdKHAv6VLSkt7qT5l643GIanpkbi8YCAQo47fm004YSyva3s';

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: Payment(),
    );
  }
}

class Payment extends StatefulWidget {
  const Payment({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Payment> {
  Map<String, dynamic>? paymentIntent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Payment'),
      ),
      body: Center(
        child: TextButton(
          child: const Text('Make Payment'),
          onPressed: () async {
            await makePayment();
          },
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      paymentIntent = await createPaymentIntent('10', 'INR');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(

          paymentIntentClientSecret: paymentIntent!['client_secret'],
          googlePay: const PaymentSheetGooglePay(
              testEnv: true, currencyCode: "USD", merchantCountryCode: "IN"),
          merchantDisplayName: 'anjali',
          customerEphemeralKeySecret: paymentIntent!['ephemeralKey'],
          returnURL: 'flutterstripe://redirect',
        ),
      );
      displayPaymentSheet();
    } catch (e) {
      print("exception $e");
      if (kDebugMode) {
        if (e is StripeConfigException) {
          print("Stripe exception ${e.message}");
        } else {
          print("exception $e");
        }
      }
    }
  }

  displayPaymentSheet() async {
    try {
      print("Display payment sheet");
      await Stripe.instance.presentPaymentSheet();
      print("Displayed successfully");
      // showDialog(
      //   context: context,
      //   builder: (_) => const AlertDialog(
      //     content: Column(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         Row(
      //           children: [
      //             Icon(Icons.check_circle, color: Colors.green),
      //             Text("Payment Successful"),
      //           ],
      //         ),
      //       ],
      //     ),
      //   ),
      // );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paid successfully")),
      );
      paymentIntent = null;
    } on StripeException catch (e) {
      print('Error: $e');

      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          content: Text("Cancelled"),
        ),
      );
    } catch (e) {
      print("Error in displaying");
      print('$e');
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      var secretKey =
          "sk_test_51JFH9zSGTdxZA1VV3MtP5wDpatKDerB7R6gdV2Vk4h5Qs6AMpng9Yke15xZzDQveyqt8NFPQ36pAiEgAfn8x5nNh00i7PPFMej";
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      print('Payment Intent Body: ${response.body.toString()}');
      return jsonDecode(response.body.toString());
    } catch (err) {
      print('Error charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount)) * 100;
    return calculatedAmount.toString();
  }
// Implement other methods here
}
*/
