import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:location/location.dart' hide LocationAccuracy, PermissionStatus;
import 'package:permission_handler/permission_handler.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:platform_device_id_v2/platform_device_id_v2.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:project_new/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/config.dart';

class SignIn extends StatefulWidget {
  @override
  State<SignIn> createState() => SignInScreen();
}

class SignInScreen extends State<SignIn> {
  TextEditingController _phoneController = TextEditingController();

  bool isMobileValid = true;
  bool isEmailValid = true;
String username='';
  String pincode = '';
  Color buttonColor = Colors.disablebutton; // Default color

  // @override
  // void dispose() {
  //   _phoneController.dispose();
  //   super.dispose();
  // }

  @override
  void initState() {
    super.initState();
    getFirebaseLoginToken();
  }

  Future<void> getFirebaseLoginToken() async {
    await [Permission.notification].request();
    // await [Permission.contacts].request();
    await [Permission.location].request();

    final fcmToken = await FirebaseMessaging.instance.getToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('device_token', fcmToken!);
    print("FCM token $fcmToken");
  }
  void requestNotificationPermission() async {

    PermissionStatus status = await Permission.notification.status;

    if((status==PermissionStatus.granted) ){
      getVerifyLoginOtp();

    }
    if (!status.isGranted ) {
      status = await Permission.notification.request();
    }
    if (status == PermissionStatus.denied ||
        status == PermissionStatus.permanentlyDenied) {
      await [Permission.notification].request();

      // Permissions are denied or denied forever, let's request it!
      status =  await Permission.notification.status;
      if (status == PermissionStatus.denied) {
        await [Permission.notification].request();
        print("notification permissions are still denied");
      } else if (status ==PermissionStatus.permanentlyDenied) {
        print("notification permissions are permanently denied");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("notification permissions required"),
              content: Text("notification permissions are permanently denied. Please go to app settings to enable notification permissions."),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .background, // Set your desired background color here
                    // You can also customize other button properties here if needed
                  ),
                  onPressed: () async {
                    Navigator.pop(context); // Close the dialog
                    await openAppSettings();
                  },
                  child: Text("OK",

                    style: TextStyle(
                        color: Colors.white, fontSize: 16),
                  ),
                ),

              ],
            );
          },
        );
      }
    }



  }

  String deviceId = '';
  String deviceToken = '';
  String deviceType = '';
  String device_id = "";
  String device_token = "";
  String device_type = "";

  Future<void> initPlatformState() async {
    String? deviceId_;
    String? deviceName_;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      deviceId_ = await PlatformDeviceId.getDeviceId;
      if (Platform.isAndroid) {
        deviceName_ = "android";
      }
      if (Platform.isIOS) {
        deviceName_ = "ios";
      }
    } on PlatformException {
      deviceId_ = null;
    }

    if (!mounted) return;

    setState(() async {
      deviceId = deviceId_!;
      deviceType = deviceName_!;
      print("deviceId->$deviceId");
      print("device_type->$deviceType");
      print("device_type->${prefs.getString('device_token')}");

      await prefs.setString('device_id', deviceId);
      await prefs.setString('device_type', deviceType);

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.id}'); // e.g. "Moto G (4)"
      if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        print('Running on ${iosInfo.identifierForVendor}');
      } // e.g. "iPod7,1"

// WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
// print('Running on ${webBrowserInfo.userAgent}');  // e.g. "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:61.0) Gecko/20100101 Firefox/61.0"
    });
  }

// String device_id="";String device_token="";String device_type="";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.background,
        body: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                "assets/back_sp.png",
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(36.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.background),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Please sign in to your registered account',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.greytext),
                              ),
                            ),
                            const SizedBox(height: 50),
                            SizedBox(
                              height: 67,
                              child: TextField(
                                controller: _phoneController,
                                maxLength: isNumeric(_phoneController.text)
                                    ? 10
                                    : null,
                                textInputAction: TextInputAction.done,

                                // keyboardType: TextInputType.number,
                                // inputFormatters: [
                                //   LengthLimitingTextInputFormatter(10), // Limits input length to 10 characters
                                // ],
                                decoration: InputDecoration(
                                  labelText: 'Phone/Email',
                                  labelStyle: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.background,
                                      fontWeight: FontWeight.w400),
                                  hintText: 'Enter Phone/Email',
                                  hintStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.hinttext,
                                      fontWeight: FontWeight.w400),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        27.0), // Add circular border
                                  ),
                                  // Set floatingLabelBehavior to always display the label
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w400),
                                // Limiting to 10 digits ],
                                onSubmitted: (_) {
                                  FocusScope.of(context)
                                      .unfocus(); // Close keyboard when "Done" is pressed
                                },
                                onChanged: (_) {
                                  // Perform validation on text change
                                  setState(() {
                                    isMobileValid = true;
                                    isEmailValid = true;
                                    if (isNumeric(_phoneController.text)) {
                                      isMobileValid = isValidPhoneNumber(
                                          _phoneController.text);
                                      if (_phoneController.text.length == 10) {
                                        // isEmailValid=false;
                                      }
                                    } else {
                                      isEmailValid =
                                          isEmailIdValid(_phoneController.text);
                                      // isMobileValid=false;
                                    }
                                  });
                                },
                              ),
                            ),
                            if (!isMobileValid &&
                                !isEmailValid &&
                                _phoneController.text.length > 5)
                              const Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 5, left: 5),
                                  child: Text(
                                    'Invalid Phone',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ),
                            if (!isEmailValid &&
                                !isMobileValid &&
                                _phoneController.text.length > 5)
                              const Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 5, left: 5),
                                  child: Text(
                                    'Invalid Email',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(
                              height: 5,
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 17.0, vertical: 17),
                              child: Container(
                                height: 50,
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors
                                        .background, // Set your desired background color here
                                    // You can also customize other button properties here if needed
                                  ),
                                  onPressed: () {
                                    initPlatformState();
                                    requestNotificationPermission();

                                    getVerifyLoginOtp();


                                  },
                                  child: const Text(
                                    'Get Otp',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'Don’t have an account?',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25.0, vertical: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color:
                                    Colors.background), // Set border properties
                            borderRadius: BorderRadius.circular(
                                27), // Set border radius for rounded corners
                          ),
                          height: 50,
                          width: 300,
                          child: ElevatedButton(
                            onPressed: () {
                              initPlatformState();
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => SignUp()),
                              );
                            },
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all<double>(
                                  0), // Set elevation to 0 to remove shadow

                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white.withOpacity(
                                      1)), // Set your desired background color here
                            ),
                            child: const Text('Sign Up',
                                style: TextStyle(
                                    color: Colors.background,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16)),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isNumeric(String data) {
    if (data == null) {
      return false;
    }

    return double.tryParse(data) != null;
  }

  bool isEmailIdValid(String email) {
    String emailPattern =
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'; // Regular expression for email validation
    RegExp regExp = RegExp(emailPattern);
    return regExp.hasMatch(email);
  }

  bool isPhoneNumberValid(String phoneNumber) {
    String phonePattern =
        r'^\d{10}$'; // Regular expression for phone number validation (assuming 10 digits)
    RegExp regExp = RegExp(phonePattern);
    return regExp.hasMatch(phoneNumber);
  }

  bool checkValidationForLogin() {
    // setState(() {});
    // if(_otpController.text.trim().isEmpty || _otpController.text.trim().length!=4){
    //   Fluttertoast.showToast(msg: "Enter Otp");
    //   return false;
    //
    // }
    if (isEmail(_phoneController.text.trim())) {
      // Handle email logic
      username= _phoneController.text.trim();
  } else if (isPhoneNumber(_phoneController.text.trim())) {
    // Handle phone number logic
      username= '+91' + _phoneController.text.trim();

    }
    if (isNumeric(_phoneController.text)) {
      if (_phoneController.text.isEmpty || _phoneController.text.length != 10) {
        Fluttertoast.showToast(msg: "Enter valid Phone Number");
        return false;
      }
    } else {
      if (!isEmailIdValid(_phoneController.text)) {
        Fluttertoast.showToast(msg: "Enter Valid Email");
        return false;
      }
    }
    return true;
  }

  void getVerifyLoginOtp() async {
    if (checkValidationForLogin()) {
      print('username Body: ${_phoneController.text.trim()}');

      EasyLoading.show();
      try {
        Response response = await post(
          Uri.parse('${ApiProvider.baseUrl + ApiProvider.sendLoginOtp}'),
          body: {

            "username": username,
          },
          // headers: {
          //   'Authorization': 'Bearer $accessToken',
          //
          // },
        );
        print('Response Status Code1====: ${response.statusCode}');
        print('Response Body: ${response.body}');
        // Close the loading dialog
        EasyLoading.dismiss();
        if (response.statusCode == 200) {
          pincode = '';

          showDialog(
            barrierDismissible: false,
            // Set this to false to make the dialog non-cancellable

            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                // title: Center(
                //   child: Text('OTP Verification',
                //     style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600,color: Colors.background),),
                // ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 21.0),
                      child: Text(
                        'OTP Verification',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.background,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.cancel),
                    ),
                  ],
                ),
                content: Row(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: Container(
                        // width:MediaQuery.of(context).size.width/1.5,
                        // height: MediaQuery.of(context).size.height/2,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 20,
                              ),
                              // const Align(
                              //   alignment: Alignment.center,
                              //   child: Text(
                              //     'Enter the OTP',
                              //     style: TextStyle(
                              //       fontSize: 14.0,
                              //       color: Colors.background,
                              //     ),
                              //   ),
                              // ),
                              const SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: PinCodeTextField(
                                    appContext: context,
                                    length: 4,
                                    // controller: _otpController,
                                    obscureText: false,
                                    keyboardType: TextInputType.number,
                                    animationType: AnimationType.fade,
                                    pinTheme: PinTheme(
                                      shape: PinCodeFieldShape.underline,
                                      borderRadius: BorderRadius.circular(3),
                                      fieldHeight: 25,
                                      fieldWidth: 25,
                                      activeColor: Colors.blue,
                                      inactiveColor: Colors.grey,
                                      activeFillColor: Colors.white,
                                      inactiveFillColor: Colors.white,
                                    ),
                                    textStyle: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black),
                                    // Set the font size here

                                    onChanged: (String pin) {
                                      if (pin.length == 4) {
                                        pincode = pin;
                                        buttonColor = Colors
                                            .background; // Change button color to green when enabled
                                      } else {
                                        buttonColor = Colors
                                            .disablebutton; // Change button color to red when disabled
                                      } // Handle changes in the OTP input
                                    },
                                    onCompleted: (String pin) {
                                      // Handle OTP submission
                                      print('Entered OTP: $pin');
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              GestureDetector(
                                onTap: () {
                                  print("verify2----");
                                  getVerifyLoginOtp();
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  // padding: const EdgeInsets.fromLTRB(150, 14, 30, 20),
                                  color: Colors.transparent,

                                  child:  RichText(
                                    text: const TextSpan(
                                      text: 'Didn’t you receive the OTP? ',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: 'Resend OTP',
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold),
                                          // Add onTap if you want to make the term clickable
                                          // onTap: () {
                                          //   // Add your onTap logic here
                                          // },
                                        ),

                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.width / 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 22.0),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: SizedBox(
                                    width: 150, // Set the desired width here
                                    height: 39,
                                    child: GestureDetector(
                                      onTap: () {
                                        VerifyLoginOtp();
                                        // Handle onPressed action
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: buttonColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          'Verify',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );

          Map<String, dynamic> data = json.decode(response.body);

          print("Otp Sent$data");
        }
        if (response.statusCode == 404) {
          Fluttertoast.showToast(msg: "User does not exists");
        } else {
          Map<String, dynamic> data = json.decode(response.body);

          print("Otp Sent failed");
          Fluttertoast.showToast(msg: data['message'] ?? "");
        }
      } catch (e) {
        EasyLoading.dismiss();
        print('Error1: $e');
        if (e is SocketException) {
          print('No Internet Connection');
// Show error message as toast
          Fluttertoast.showToast(msg: "No Internet Connection");
        }
        if (e is FormatException) {
          print('Invalid JSON Format333$e');
          EasyLoading.dismiss();
        }
      }
    }
  }
  bool isEmail(String input) {
    // Regular expression to check if input matches an email format
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(input);
  }

  bool isPhoneNumber(String input) {

    // Regular expression to check if input is a 10-digit number

    final RegExp phoneRegex = RegExp(r'^\d{10}$');

    return phoneRegex.hasMatch(input);

  }


  bool checkValidationForLoginOtp() {
    if (pincode.isEmpty || pincode.length != 4) {
      Fluttertoast.showToast(msg: "Enter Otp");
      return false;
    }
    return true;
  }

  Future<void> setLoggedIn(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', value);
  }

  void VerifyLoginOtp() async {
    if (checkValidationForLoginOtp()) {
      EasyLoading.show();
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        device_type = prefs.getString('device_type')!;
        device_id = prefs.getString('device_id')!;
        device_token = prefs.getString('device_token')!;
        print(
            "valuesss===========$device_type=====#$device_id======++++$device_token");
        Response response = await post(
          Uri.parse('${ApiProvider.baseUrl + ApiProvider.verifyLoginOtp}'),
          body: {
            "username": '+91'+_phoneController.text.trim(),
            "otp": pincode,
            "device_type": device_type,
            "device_token": device_token,
            // "device_id":  device_id// cahnge device_token
          },
          // headers: {
          //   'Authorization': 'Bearer $accessToken',
          //
          // },
        );
        print('Response Status Code2: ${response.statusCode}');
        print('Response Body: ${response.body}');

        // Close the loading dialog
        EasyLoading.dismiss();
        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: "Login Successfully");

          pincode = '';
          Map<String, dynamic> data = json.decode(response.body);
          setLoggedIn(true);
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('access_token', data['tokens']['access_token']);
          prefs.setString('refresh_token', data['tokens']["refresh_token"]);
          prefs.setString('stripe_customer_id', data['data']['stripe_customer_id']);
          prefs.setString('user_id', data['data']['id']);
          Navigator.of(context).pop();
          //  print("Otp Sent${ data['data']['id']}${data['data']['stripe_customer_id']}");
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false);
        }
        else {
          Map<String, dynamic> data = json.decode(response.body);
          if (data['status'] == false && data['status_code'] == 400) {
            // Display the error message to the user
            String errorMessage1 = data['data']['non_field_errors'][0];
            print("-------------$errorMessage1");

            Fluttertoast.showToast(msg: errorMessage1);
// Output the error message to the console
            // You can show this message in a Snackbar, AlertDialog, or any other way you prefer
          }
        }
      } catch (e, StackTrace) {
        EasyLoading.dismiss();
        print('Error2: $e========$StackTrace');
        if (e is SocketException) {
          print('No Internet Connection');
// Show error message as toast
          Fluttertoast.showToast(msg: "No Internet Connection");
        }
        if (e is FormatException) {
          print('Invalid JSON Format333$e');
          EasyLoading.dismiss();
        }
      }
    }
  }

  bool isValidPhoneNumber(String value) {
    // Regular expression to match a phone number pattern
    const phonePattern =
        r'^\s*\d{10}\s*$'; // This pattern allows optional leading/trailing whitespaces

    RegExp regExp = RegExp(phonePattern);
    return regExp.hasMatch(value);
  }
}

class SignUp extends StatefulWidget {
  @override
  State<SignUp> createState() => SignUpScreen();
}

class SignUpScreen extends State<SignUp> {
  TextEditingController _phoneController = TextEditingController();
  bool isMobileValid = true;
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNmeController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController referalController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  String pincode = '';
  double Latitude = 0.0;
  double Longitude = 0.0;

  DateTime? _selectedDate;

  Color buttonColor = Colors.disablebutton; // Default color

  bool _emailValid = true;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? DateTime.now().subtract(Duration(days: 10 * 365)),
      // Default to 20 years ago
      firstDate: DateTime.now().subtract(Duration(days: 70 * 365)),
      // 70 years ago
      lastDate: DateTime.now().subtract(Duration(days: 10 * 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = _selectedDate
            .toString()
            .substring(0, 10); // Update the TextField with selected date
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneNumberChanged);
    _emailController.addListener(_onEmailChanged);

  }

  bool isVerifiedEmail =
      false; // Example boolean variable indicating verification status
  bool isVerifiedPhone =
      false; // Example boolean variable indicating verification status
  String device_id = "";
  String device_type = "";
  String device_token = "";


  // Icon getSuffixIconEmail() {
    // Return different icon based on verification status
  //   return isVerifiedEmail
  //       ? Icon(Icons.verified_rounded, color: Colors.green)
  //       : Icon(Icons.warning, color: Colors.red);
  // }
    Widget getSuffixIconEmail() {
      return isVerifiedEmail
          ? SizedBox(
        height: 30, // Set the desired height
        width: 90, // Set the desired width
        child: ElevatedButton(
          onPressed: () {
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.background,
          ),
          child: Text(
            'Verified',
            style: TextStyle(color: Colors.white,fontSize: 11),
          ),
        ),
      )

      : SizedBox(
        height: 30, // Set the desired height
        width: 80, // Set the desired width
        child: ElevatedButton(
          onPressed: () {
            print("getVerifyEmailOtp====");
            getVerifyEmailOtp();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.background,
          ),
          child: Text(
            'Verify',
            style: TextStyle(color: Colors.white,fontSize: 11),
          ),
        ),
      );

    }

  // Icon getSuffixIconPhone() {
  //   // Return different icon based on verification status
  //   return isVerifiedPhone
  //       ? Icon(Icons.verified_rounded, color: Colors.green)
  //       : Icon(Icons.warning, color: Colors.red);
  // }
  Widget getSuffixIconPhone() {
    return isVerifiedPhone
        ? SizedBox(
      height: 20,
      width: 90,
      child: ElevatedButton(
        onPressed: () {
          // Logic for "Verified" button, if any
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.bluebutton, // Use a color of your choice
        ),
        child: Text(
          'Verified',
          style: TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    )
        : SizedBox(
      height: 20,
      width: 80,
      child: ElevatedButton(
        onPressed:(){
          if (_phoneController.text.trim().isEmpty ||
              _phoneController.text.trim().length!=10 ) {

            Fluttertoast.showToast(msg: 'please enter a valid phone no..');

          }else{

          getVerifyPhoneOtp();}},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.bluebutton, // Use a color of your choice
        ),
        child: Text(
          'Verify',
          style: TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }



  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneNumberChanged);
    _phoneController.dispose();
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    super.dispose();
  }
  void _onEmailChanged() {
    if (_emailController.text.isEmpty) {
      setState(() {
        isVerifiedEmail = false;
      });
    }
  }
  void _onPhoneNumberChanged() {
    if (_phoneController.text.isEmpty) {
      setState(() {
        isVerifiedPhone = false;
      });
    }
  }

/*  Widget getSuffixIconPhone() {
    return isVerifiedPhone
        ? SizedBox(
      height: 30, // Set the desired height
      width: 90, // Set the desired width
      child: ElevatedButton(
        onPressed: () {
          // getVerifyEmailOtp();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.background,
        ),
        child: Text(
          'Verified',
          style: TextStyle(color: Colors.white,fontSize: 11),
        ),
      ),
    )

        : Container(
      height: 30, // Set the desired height
      width: 80, // Set the desired width
      child: ElevatedButton(
        onPressed: () {
          getVerifyPhoneOtp();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.background,
        ),
        child: Text(
          'Verify',
          style: TextStyle(color: Colors.white,fontSize: 11),
        ),
      ),
    );

  }*/

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        backgroundColor: Colors.background,
        body: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                "assets/back_sp.png",
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 1),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Apply the Referral code here',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.background),
                            ),
                          ),
                        ),
                        const SizedBox(height: 23),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors
                                    .grey, // Set your desired border color
                                width: 1, // Set your desired border width
                              ),
                              borderRadius: BorderRadius.circular(
                                  25.0), // Add circular border
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 59, // Set the height as needed

                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8.0),
                                      child: TextField(
                                        controller: referalController,
                                        decoration: InputDecoration(
                                          labelText: 'Referral Code',
                                          labelStyle: TextStyle(
                                            fontSize: 12,
                                            color: Colors.background,
                                            // Set your desired hint text color
                                            fontWeight: FontWeight.w400,
                                          ),
                                          hintText: 'Referral Code',
                                          hintStyle: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            // Set your desired hint text color
                                            fontWeight: FontWeight.w400,
                                          ),
                                          border: InputBorder.none,
                                          // Remove the border for the text field
                                          // Set floatingLabelBehavior to always display the label
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                        ),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 3.0, horizontal: 4),
                                  child: Container(
                                    width: 69,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          22.0), // Add circular border

                                      // borderRadius: BorderRadius.only(
                                      //   topRight: Radius.circular(27.0),
                                      //   bottomRight: Radius.circular(27.0),
                                      // ),
                                      color: Colors
                                          .background, // Set your desired button background color
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        validateReferralCode();
                                      },
                                      child: const Text(
                                        'Validate',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 9,
                        ),
                        const Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(8.0, 23, 8, 0),
                                child: Divider(
                                  thickness: 2,
                                  color: Colors
                                      .lightgrey, // Adjust thickness as needed
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 13),
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 1),
                            child: Text(
                              'Create an Account',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.background),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 1),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Please sign in to your registered account',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.greytext),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 55,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 1),
                            child: TextField(
                              controller: _firstNameController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'First Name',
                                labelStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.background,
                                  fontWeight: FontWeight.w400,
                                ),
                                hintText: 'Enter First Name',
                                hintStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.hinttext,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      27.0), // Add circular border
                                ),
                                // Set floatingLabelBehavior to always display the label
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                // Add button to the end of the TextField
                              ),
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          height: 55,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 1),
                            child: TextField(
                              controller: _lastNmeController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'Last Name',
                                hintText: 'Enter Last Name',
                                labelStyle: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.background,
                                    fontWeight: FontWeight.w400),
                                hintStyle: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.hinttext,
                                    fontWeight: FontWeight.w400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      27.0), // Add circular border
                                ),
                                // Set floatingLabelBehavior to always display the label
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          height: 55,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 1),
                            child: TextField(
                              controller: _dobController,
                              readOnly: true,
                              // Make the TextField read-only
                              onTap: () {
                                _selectDate(
                                    context); // Show date picker when the TextField is tapped
                              },
                              decoration: InputDecoration(
                                labelText: 'D.O.B',
                                hintText: 'YYYY-MM-DD',
                                labelStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.background,
                                  fontWeight: FontWeight.w400,
                                ),
                                hintStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.hinttext,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      27.0), // Add circular border
                                ),
                                // Set floatingLabelBehavior to always display the label
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        height: 55,
                        child: TextField(
                          controller: _phoneController,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                          ],
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Phone',
                            hintText: 'Enter Phone Number',
                            labelStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.bluebutton,
                              fontWeight: FontWeight.w400,
                            ),
                            hintStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(27.0),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            suffixIcon: getSuffixIconPhone(),
                          ),
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),

                        const SizedBox(height: 25),
                        SizedBox(
                          height: 69,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 1),
                            child: TextField(
                              controller: _emailController,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                setState(() {
                                  _emailValid = isValidEmail(
                                      value); // Validate email on change
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Email',
                                hintText: 'Enter Email Address',
                                labelStyle: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.background,
                                    fontWeight: FontWeight.w400),

                                hintStyle: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.hinttext,
                                    fontWeight: FontWeight.w400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      27.0), // Add circular border
                                ),
                                // Set floatingLabelBehavior to always display the label
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                suffixIcon: GestureDetector(
                                    onTap: () {
                                      getVerifyEmailOtp();
                                      print('Icon tapped');
                                    },
                                    child: getSuffixIconEmail()),
                                errorText: _emailValid
                                    ? null
                                    : 'Please enter a valid email',
                              ),
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        // SizedBox(
                        //   child: Padding(
                        //     padding: const EdgeInsets.symmetric(
                        //         horizontal: 10.0, vertical: 1),
                        //     child: Row(
                        //       children: [
                        //         Expanded(
                        //           child: TextField(
                        //             controller: _locationController,
                        //             maxLines: null,
                        //             decoration: InputDecoration(
                        //               labelText: 'Location',
                        //               hintText: 'Location',
                        //               labelStyle: const TextStyle(
                        //                   fontSize: 14,
                        //                   color: Colors.background,
                        //                   fontWeight: FontWeight.w400),
                        //               hintStyle: const TextStyle(
                        //                   fontSize: 16,
                        //                   color: Colors.grey,
                        //                   fontWeight: FontWeight.w400),
                        //               border: OutlineInputBorder(
                        //                 borderRadius: BorderRadius.circular(
                        //                     27.0), // Add circular border
                        //               ),
                        //               // Set floatingLabelBehavior to always display the label
                        //               floatingLabelBehavior:
                        //                   FloatingLabelBehavior.always,
                        //               // Add location icon at the end of the text field
                        //               suffixIcon: GestureDetector(
                        //                 onTap: () {
                        //                   requestLocationPermission();
                        //                 },
                        //                 child: const Icon(Icons.my_location),
                        //               ),
                        //             ),
                        //             style: const TextStyle(
                        //                 fontSize: 14,
                        //                 fontWeight: FontWeight.w400),
                        //             readOnly: true, // Disable manual input
                        //             // controller: TextEditingController(text: ""),
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25.0, vertical: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors
                                      .background), // Set border properties
                              borderRadius: BorderRadius.circular(
                                  27), // Set border radius for rounded corners
                            ),
                            height: 50,
                            width: 300,
                            child: ElevatedButton(
                              onPressed: () {

                                requestLocationPermission();
                                initPlatformState();

                                RegisterUser();
                              },
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all<double>(
                                    0), // Set elevation to 0 to remove shadow

                                backgroundColor:
                                    MaterialStateProperty.all<Color>(Colors
                                        .background), // Set your desired background color here
                              ),
                              child: const Text('Sign Up',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: RichText(
                            text: const TextSpan(
                              text: 'By tapping “Sign Up” you accept our ',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'terms',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                  // Add onTap if you want to make the term clickable
                                  // onTap: () {
                                  //   // Add your onTap logic here
                                  // },
                                ),
                                TextSpan(
                                  text: ' and ',
                                ),
                                TextSpan(
                                  text: 'conditions',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                  // Add onTap if you want to make the term clickable
                                  // onTap: () {
                                  //   // Add your onTap logic here
                                  // },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 9,
                        ),
                        const Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(8.0, 18, 8, 0),
                                child: Divider(
                                  thickness: 2,
                                  color: Colors
                                      .lightgrey, // Adjust thickness as needed
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        const Text(
                          'Already have an account?',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25.0, vertical: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors
                                      .background), // Set border properties
                              borderRadius: BorderRadius.circular(
                                  27), // Set border radius for rounded corners
                            ),
                            height: 50,
                            width: 300,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => SignIn()),
                                );
                              },
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all<double>(
                                    0), // Set elevation to 0 to remove shadow

                                backgroundColor: MaterialStateProperty
                                    .all<Color>(Colors.white.withOpacity(
                                        1)), // Set your desired background color here
                              ),
                              child: const Text('Sign In',
                                  style: TextStyle(
                                      color: Colors.background,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16)),
                            ),
                          ),
                        ),
                      ],
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

  bool isValidEmail(String email) {
    // Simple email validation regex pattern
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await [Permission.location].request();

      // Permissions are denied or denied forever, let's request it!
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        await [Permission.location].request();
        print("Location permissions are still denied");
      } else if (permission == LocationPermission.deniedForever) {
        print("Location permissions are permanently denied");
        // Prompt the user to open app settings to enable location permissions manually
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Location permissions required"),
              content: Text("Location permissions are permanently denied. Please go to app settings to enable location permissions."),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .background, // Set your desired background color here
                    // You can also customize other button properties here if needed
                  ),
                  onPressed: () async {
                    Navigator.pop(context); // Close the dialog
                    await openAppSettings();
                  },
            child: Text("OK",

            style: TextStyle(
                        color: Colors.white, fontSize: 16),
                  ),
                ),

              ],
            );
          },
        );
      } else {
        // Permissions are granted (either whileInUse, always, restricted).
        _determinePosition().then((value) {
          print("User location ${value.latitude} ,, ${value.longitude}");
          Latitude = value.latitude;
          Longitude = value.longitude;
          _getAddressFromLatLng(value.latitude, value.longitude);
        });
        print("Location permissions are granted after requesting");
      }
    } else {
      print("Location permissions are granted ");

      _determinePosition().then((value) {
        _getAddressFromLatLng(value.latitude, value.longitude);
        print("User location ${value.latitude} ,, ${value.longitude}");
        Latitude = value.latitude;
        Longitude = value.longitude;
      });
    }
  }

  Future<void> _getAddressFromLatLng(double Latitude, double Longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(Latitude, Longitude);
      Placemark place = placemarks[0];
      setState(() {
        print(
            "location++++++++++${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}");
        // _locationController.text =
        //     "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  bool isValidPhoneNumber(String value) {
    // Regular expression to match a phone number pattern
    const phonePattern =
        r'^[0-9]{10}$'; // Change this pattern based on your requirements

    RegExp regExp = RegExp(phonePattern);
    return regExp.hasMatch(value);
  }

  Future<Position> _determinePosition() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Location location = Location();
      if (await location.serviceEnabled()) {
        await location.requestService();
      }
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // If permissions are granted, return the current location
    return await Geolocator.getCurrentPosition();
  }

  bool checkValidationForVerifyEmail(String email) {
    // Simple email validation regex pattern
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // bool checkValidationForVerifyPhone(String phone) {
  //   // Simple email validation regex pattern
  //   final RegExp phoneRegex = RegExp(r'^\d{10}$');
  //
  //   return phoneRegex.hasMatch(phone);
  // }



  void resendEmailOtp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username')!;
    if (checkValidationForVerifyEmail(username)) {
      EasyLoading.show();
      try {
        Response response = await post(
          Uri.parse('${ApiProvider.baseUrl + ApiProvider.verifyEmailOtp}'),
          body: {
            "username":username,
          },

        );
        print('Response Status Code4: ${response.statusCode}');
        print('Response Body: ${response.body}');
        EasyLoading.dismiss();
        if (response.statusCode == 200) {



          Map<String, dynamic> data = json.decode(response.body);

          print("Otp Sent$data");
          Fluttertoast.showToast(msg: data['message'] ?? "");

        } else {
          Map<String, dynamic> data = json.decode(response.body);

          print("Otp Sent failed");
          Fluttertoast.showToast(msg: data['message'] ?? "");
        }
      } catch (e) {
        EasyLoading.dismiss();
        print('Error4: $e');
        if (e is SocketException) {
          print('No Internet Connection');
// Show error message as toast
          Fluttertoast.showToast(msg: "No Internet Connection");
        }
        if (e is FormatException) {
          print('Invalid JSON Format333$e');
          EasyLoading.dismiss();
        }
      }
    }
  }
  void resendPhoneOtp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
   String username = prefs.getString('username')!;
    // if (checkValidationForVerifyPhone(username)) {
      EasyLoading.show();
      try {

        Response response = await post(
          Uri.parse('${ApiProvider.baseUrl + ApiProvider.verifyEmailOtp}'),
          body: {
            "username": username,
          },

        );
        print('Response Status Code33: ${response.statusCode}');
        print('Response Body: ${response.body}');
        // Close the loading dialog
        EasyLoading.dismiss();
        if (response.statusCode == 200) {



          Map<String, dynamic> data = json.decode(response.body);
          Fluttertoast.showToast(msg: data['message'] ?? "");

          print("Otp Sent$data");
        } else {
          Map<String, dynamic> data = json.decode(response.body);

          print("Otp Sent failed");
          Fluttertoast.showToast(msg: data['message'] ?? "");
        }
      } catch (e) {
        EasyLoading.dismiss();
        print('Error3: $e');
        if (e is SocketException) {
          print('No Internet Connection');
// Show error message as toast
          Fluttertoast.showToast(msg: "No Internet Connection");
        }
        if (e is FormatException) {
          print('Invalid JSON Format333$e');
          EasyLoading.dismiss();
        }
      }
    }
  // }









  void getVerifyPhoneOtp() async {

    // if (checkValidationForVerifyPhone(_phoneController.text)) {
      EasyLoading.show();
      try {
        Response response = await post(
          Uri.parse('${ApiProvider.baseUrl + ApiProvider.verifyEmailOtp}'),
          body: {
            "username":'+91${_phoneController.text.trim()}',
          },
          // headers: {
          //   'Authorization': 'Bearer $accessToken',
          //
          // },
        );
        print('Response Status Code3: ${response.statusCode}');
        print('Response Body: ${response.body}');
        // Close the loading dialog
        EasyLoading.dismiss();
        if (response.statusCode == 200) {
          pincode = '';
          SharedPreferences prefs = await SharedPreferences.getInstance();

          await prefs.setString('username', _phoneController.text.trim()!);
          showDialog(
            barrierDismissible: false,
            // Set this to false to make the dialog non-cancellable

            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                // title: Center(
                //   child: Text('OTP Verification',
                //     style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600,color: Colors.background),),
                // ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 21.0),
                      child: Text(
                        'OTP Verification',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.background,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.cancel),
                    ),
                  ],
                ),
                content: Row(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: Container(
                        // width:MediaQuery.of(context).size.width/1.5,
                        // height: MediaQuery.of(context).size.height/2,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 20,
                              ),
                              // const Align(
                              //   alignment: Alignment.center,
                              //   child: Text(
                              //     'Enter the OTP',
                              //     style: TextStyle(
                              //       fontSize: 14.0,
                              //       color: Colors.background,
                              //     ),
                              //   ),
                              // ),
                              const SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: PinCodeTextField(
                                    appContext: context,
                                    length: 4,
                                    // controller: _otpController,
                                    obscureText: false,
                                    keyboardType: TextInputType.number,
                                    animationType: AnimationType.fade,
                                    pinTheme: PinTheme(
                                      shape: PinCodeFieldShape.underline,
                                      borderRadius: BorderRadius.circular(3),
                                      fieldHeight: 25,
                                      fieldWidth: 25,
                                      activeColor: Colors.blue,
                                      inactiveColor: Colors.grey,
                                      activeFillColor: Colors.white,
                                      inactiveFillColor: Colors.white,
                                    ),
                                    textStyle: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black),
                                    // Set the font size here

                                    onChanged: (String pin) {
                                      if (pin.length == 4) {
                                        pincode = pin;
                                        buttonColor = Colors
                                            .background; // Change button color to green when enabled
                                      } else {
                                        buttonColor = Colors
                                            .disablebutton; // Change button color to red when disabled
                                      } // Handle changes in the OTP input
                                    },
                                    onCompleted: (String pin) {
                                      // Handle OTP submission
                                      print('Entered OTP: $pin');
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10.0),

                              GestureDetector(
                                onTap: () {
                                  print("verify1----");
                                  if (_phoneController.text.trim().isEmpty ||
                                      _phoneController.text.trim().length!=10 ) {

                                    Fluttertoast.showToast(msg: 'please enter a valid phone no.');

                                  }else{
                                  resendPhoneOtp();        }                        },
                                child: Container(
                                  alignment: Alignment.center,
                                  // padding: const EdgeInsets.fromLTRB(150, 14, 30, 20),
                                  color: Colors.transparent,

                                  child:  RichText(
                                    text: const TextSpan(
                                      text: 'Didn’t you receive the OTP? ',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: 'Resend OTP',
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold),
                                          // Add onTap if you want to make the term clickable
                                          // onTap: () {
                                          //   // Add your onTap logic here
                                          // },
                                        ),

                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.width / 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 22.0),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: SizedBox(
                                    width: 150, // Set the desired width here
                                    height: 39,
                                    child: GestureDetector(
                                      onTap: () {
                                        VerifyPhone();
                                        // Handle onPressed action
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: buttonColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          'Verify',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );

          Map<String, dynamic> data = json.decode(response.body);

          print("Otp Sent$data");
        } else {
          Map<String, dynamic> data = json.decode(response.body);

          print("Otp Sent failed");
          Fluttertoast.showToast(msg: data['message'] ?? "");
        }
      } catch (e) {
        EasyLoading.dismiss();
        print('Error3: $e');
        if (e is SocketException) {
          print('No Internet Connection');
// Show error message as toast
          Fluttertoast.showToast(msg: "No Internet Connection");
        }
        if (e is FormatException) {
          print('Invalid JSON Format333$e');
          EasyLoading.dismiss();
        }
      }
    }
  // }

  void getVerifyEmailOtp() async {
    if (checkValidationForVerifyEmail(_emailController.text)) {
      EasyLoading.show();
      try {
        Response response = await post(
          Uri.parse('${ApiProvider.baseUrl + ApiProvider.verifyEmailOtp}'),
          body: {
            "username": _emailController.text.trim(),
          },
          // headers: {
          //   'Authorization': 'Bearer $accessToken',
          //
          // },
        );
        print('Response Status Code4: ${response.statusCode}');
        print('Response Body: ${response.body}');
        // Close the loading dialog
        EasyLoading.dismiss();
        if (response.statusCode == 200) {
          pincode = '';
          SharedPreferences prefs = await SharedPreferences.getInstance();

          await prefs.setString('username', _emailController.text.trim()!);
          showDialog(
            barrierDismissible: false,
            // Set this to false to make the dialog non-cancellable

            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                // title: Center(
                //   child: Text('OTP Verification',
                //     style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600,color: Colors.background),),
                // ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 21.0),
                      child: Text(
                        'OTP Verification',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.background,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.cancel),
                    ),
                  ],
                ),
                content: Row(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: Container(
                        // width:MediaQuery.of(context).size.width/1.5,
                        // height: MediaQuery.of(context).size.height/2,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 20,
                              ),
                              // const Align(
                              //   alignment: Alignment.center,
                              //   child: Text(
                              //     'Enter the OTP',
                              //     style: TextStyle(
                              //       fontSize: 14.0,
                              //       color: Colors.background,
                              //     ),
                              //   ),
                              // ),
                              const SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: PinCodeTextField(
                                    appContext: context,
                                    length: 4,
                                    // controller: _otpController,
                                    obscureText: false,
                                    keyboardType: TextInputType.number,
                                    animationType: AnimationType.fade,
                                    pinTheme: PinTheme(
                                      shape: PinCodeFieldShape.underline,
                                      borderRadius: BorderRadius.circular(3),
                                      fieldHeight: 25,
                                      fieldWidth: 25,
                                      activeColor: Colors.blue,
                                      inactiveColor: Colors.grey,
                                      activeFillColor: Colors.white,
                                      inactiveFillColor: Colors.white,
                                    ),
                                    textStyle: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black),
                                    // Set the font size here

                                    onChanged: (String pin) {
                                      if (pin.length == 4) {
                                        pincode = pin;
                                        buttonColor = Colors
                                            .background; // Change button color to green when enabled
                                      } else {
                                        buttonColor = Colors
                                            .disablebutton; // Change button color to red when disabled
                                      } // Handle changes in the OTP input
                                    },
                                    onCompleted: (String pin) {
                                      // Handle OTP submission
                                      print('Entered OTP: $pin');
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              GestureDetector(
                                onTap: () {
                                  print("verify5----");
                                  resendEmailOtp();
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  // padding: const EdgeInsets.fromLTRB(150, 14, 30, 20),
                                  color: Colors.transparent,

                                  child:  RichText(
                                    text: const TextSpan(
                                      text: 'Didn’t you receive the OTP? ',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: 'Resend OTP',
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold),
                                          // Add onTap if you want to make the term clickable
                                          // onTap: () {
                                          //   // Add your onTap logic here
                                          // },
                                        ),

                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.width / 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 22.0),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: SizedBox(
                                    width: 150, // Set the desired width here
                                    height: 39,
                                    child: GestureDetector(
                                      onTap: () {
                                        VerifyEmail();
                                        // Handle onPressed action
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: buttonColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          'Verify',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );

          Map<String, dynamic> data = json.decode(response.body);

          print("Otp Sent$data");
        } else {
          Map<String, dynamic> data = json.decode(response.body);

          print("Otp Sent failed");
          Fluttertoast.showToast(msg: data['message'] ?? "");
        }
      } catch (e) {
        EasyLoading.dismiss();
        print('Error4: $e');
        if (e is SocketException) {
          print('No Internet Connection');
// Show error message as toast
          Fluttertoast.showToast(msg: "No Internet Connection");
        }
        if (e is FormatException) {
          print('Invalid JSON Format333$e');
          EasyLoading.dismiss();
        }
      }
    }
  }

  void VerifyEmail() async {
    if (checkValidationForVerifyEmailOtp()) {
      EasyLoading.show();
      try {
        print('otp Status Code: ${pincode.toString()}');

        Response response = await patch(
          Uri.parse('${ApiProvider.baseUrl + ApiProvider.verifyEmailOtp}'),
          body: {
            "username": _emailController.text.trim(),
            "otp": pincode // _otpController.text.trim(),
          },
          // headers: {
          //   'Authorization': 'Bearer $accessToken',
          //
          // },
        );

        print('Response Status Code5: ${response.statusCode}');
        print('Response Body: ${response.body}');
        // Close the loading dialog
        EasyLoading.dismiss();
        if (response.statusCode == 200) {
          setState(() {
            isVerifiedEmail = true;
            getSuffixIconEmail();
          });
          Navigator.pop(context);
        } else {
          Map<String, dynamic> data = json.decode(response.body);

          print("Email verification failed");
          Fluttertoast.showToast(msg: data['message'] ?? "");
        }
      } catch (e) {
        EasyLoading.dismiss();
        print('Error5: $e');
        if (e is SocketException) {
          print('No Internet Connection');
// Show error message as toast
          Fluttertoast.showToast(msg: "No Internet Connection");
        }
        if (e is FormatException) {
          print('Invalid JSON Format333$e');
          EasyLoading.dismiss();
        }
      }
    }
  }

  void VerifyPhone() async {
    if (checkValidationForVerifyPhoneOtp()) {
      EasyLoading.show();
      try {
        print('otp Status Code: ${pincode.toString()}');

        Response response = await patch(
          Uri.parse('${ApiProvider.baseUrl + ApiProvider.verifyEmailOtp}'),
          body: {
            "username": '+91${_phoneController.text.trim()}',
            "otp": pincode // _otpController.text.trim(),
          },
          // headers: {
          //   'Authorization': 'Bearer $accessToken',
          //
          // },
        );

        print('Response Status Code6: ${response.statusCode}');
        print('Response Body: ${response.body}');
        // Close the loading dialog
        EasyLoading.dismiss();
        if (response.statusCode == 200) {
          setState(() {
            isVerifiedPhone = true;
            getSuffixIconPhone();
          });
          Navigator.pop(context);
        } else {
          Map<String, dynamic> data = json.decode(response.body);

          print("Email verification failed");
          Fluttertoast.showToast(msg: data['message'] ?? "");
        }
      } catch (e) {
        EasyLoading.dismiss();
        print('Error6: $e');
        if (e is SocketException) {
          print('No Internet Connection');
// Show error message as toast
          Fluttertoast.showToast(msg: "No Internet Connection");
        }
        if (e is FormatException) {
          print('Invalid JSON Format333$e');
          EasyLoading.dismiss();
        }
      }
    }
  }

  String deviceId = '';
  String deviceToken = '';
  String deviceType = '';

  Future<void> initPlatformState() async {
    String? deviceId_;
    String? deviceName_;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      deviceId_ = await PlatformDeviceId.getDeviceId;
      if (Platform.isAndroid) {
        deviceName_ = "android";
      }
      if (Platform.isIOS) {
        deviceName_ = "ios";
      }
    } on PlatformException {
      deviceId_ = null;
    }

    if (!mounted) return;

    setState(() async {
      deviceId = deviceId_!;
      deviceType = deviceName_!;
      print("deviceId->$deviceId");
      print("device_type->$deviceType");
      print("device_type->${prefs.getString('device_token')}");

      await prefs.setString('device_id', deviceId);
      await prefs.setString('device_type', deviceType);

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.id}'); // e.g. "Moto G (4)"
      if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        print('Running on ${iosInfo.identifierForVendor}');
      } // e.g. "iPod7,1"

// WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
// print('Running on ${webBrowserInfo.userAgent}');  // e.g. "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:61.0) Gecko/20100101 Firefox/61.0"
    });
  }

  void RegisterUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    device_type = prefs.getString('device_type')!;
    device_id = prefs.getString('device_id')!;
    device_token = prefs.getString('device_token')!;
    print(
        "valuessss===device_type$device_type=========device_id$device_id=====device_token$device_token");

    if (checkValidationForSignup()) {
      String LastName = "";
      String ReferralCode = "";

      if (_lastNmeController.text.trim().isEmpty) {
        LastName = "N/A";
      } else {
        LastName = _lastNmeController.text.trim();
      }
      if (referalController.text.trim().isEmpty ||
          referalController.text == '') {
        ReferralCode = "";
      } else {
        ReferralCode = referalController.text.trim();
      }
      if (_phoneController.text.trim().isEmpty ||
          _phoneController.text.trim().length!=10 ) {

        Fluttertoast.showToast(msg: 'please enter a valid phone no..');

      }

      EasyLoading.show();
      try {
        Map<String, dynamic> requestBody = {
          "first_name": _firstNameController.text.trim(),
          "last_name": LastName,
          "phone_number":'+91${_phoneController.text.trim()}',
          "email": _emailController.text.trim(),
          "latitude": Latitude,
          "longitude": Longitude,
          if (ReferralCode.isNotEmpty) ...{
            "referral_code": ReferralCode,
          },
          "dob": _dobController.text,
          // You might need to format this date correctly
          "device_token": {
            "token": device_token.toString(),
            "device_type": device_type,
          }
        };
        Response response = await post(
            Uri.parse('${ApiProvider.baseUrl + ApiProvider.register}'),
            body: jsonEncode(requestBody),
            headers: {"Content-Type": "application/json"});
        print('Response Status Code7: ${response.statusCode}');
        print('Response Body: ${response.body}');
        print('requestBody e: ${requestBody}');

        EasyLoading.dismiss();
        if (response.statusCode == 201) {
          Fluttertoast.showToast(msg: 'user registered successfully..');

          Map<String, dynamic> data = json.decode(response.body);

          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (context) => SignIn()),
          );
          // print("Email verified $data");
        } else {
          Map<String, dynamic> responseMap = json.decode(response.body);

          if (responseMap['status'] == false) {
            // Check if the response data contains the 'phone_number' field
            if (responseMap.containsKey('data') &&
                responseMap['data'] != null) {
              if (responseMap['data']['dob'] is List &&
                  responseMap['data']['dob'].isNotEmpty) {
                String errorMessage = responseMap['data']['dob'][0];
                print(errorMessage);
                Fluttertoast.showToast(msg: '${responseMap['data']['dob'][0]}');
              }

              // Check if the 'phone_number' field is a list and not empty
              if (responseMap['data']['phone_number'] is List &&
                  responseMap['data']['phone_number'].isNotEmpty) {
                // Fetch the message from the 'phone_number' list
                String errorMessage = responseMap['data']['phone_number'][0];
                print(errorMessage);
                Fluttertoast.showToast(
                    msg:
                        '${responseMap['data']['phone_number'][0]}'); // Print the error message
              }
              if (responseMap['data']['email'] is List &&
                  responseMap['data']['email'].isNotEmpty) {
                // Fetch the message from the 'phone_number' list
                String errorMessage = responseMap['data']['email'][0];
                print(errorMessage); // Print the error message
                Fluttertoast.showToast(
                    msg:
                        '${responseMap['data']['email'][0]}'); // Print the error message
              }
            }
          }
        }
      } catch (e) {
        EasyLoading.dismiss();
        print('Error7: $e');
        if (e is SocketException) {
          print('No Internet Connection');
// Show error message as toast
          Fluttertoast.showToast(msg: "No Internet Connection");
        }
        if (e is FormatException) {
          print('Invalid JSON Format333$e');
          EasyLoading.dismiss();
        }
      }
    }
  }

  bool checkValidationForVerifyEmailOtp() {
    // if(_otpController.text.trim().isEmpty || _otpController.text.trim().length!=4){
    //   Fluttertoast.showToast(msg: "Enter Otp");
    //   return false;
    //
    // }
    setState(() {});
    if (pincode.isEmpty || pincode.length != 4) {
      Fluttertoast.showToast(msg: "Enter Otp");
      return false;
    }
    return true;
  }

  bool checkValidationForVerifyPhoneOtp() {
    setState(() {});
    // if(_otpController.text.trim().isEmpty || _otpController.text.trim().length!=4){
    //   Fluttertoast.showToast(msg: "Enter Otp");
    //   return false;
    //
    // }

    if (pincode.isEmpty || pincode.length != 4) {
      Fluttertoast.showToast(msg: "Enter Otp");
      return false;
    }
    return true;
  }

  bool checkValidationForSignup() {
    if (_emailController.text.trim().isEmpty &&
        _emailController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "enter the details");
      return false;
    }
    if (_firstNameController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: " Enter First Name");
      return false;
    }

    if (_dobController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: " Enter D.O.B");
      return false;
    }

    if (_phoneController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: " Enter Phone Number");
      return false;
    }
    if (_emailController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: " Enter Email");
      return false;
    }
    // if (_locationController.text.trim().isEmpty) {
    //   Fluttertoast.showToast(msg: " Enter Location");
    //   return false;
    // }

    return true;
  }

  bool checkValidationForRefferalCode() {
    if (referalController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Enter Referral code");
      return false;
    }

    return true;
  }

  void validateReferralCode() async {
    if (checkValidationForRefferalCode()) {
      EasyLoading.show();
      try {
        Response response = await get(
          Uri.parse(
              '${ApiProvider.baseUrl + ApiProvider.validateReferralCode_ + "?referral_code=${referalController.text}"}'),

          // headers: {
          //   'Authorization': 'Bearer $accessToken',
          //
          // },
        );
        print('Response Status Code8: ${response.statusCode}');
        print('Response Body: ${response.body}');
        // Close the loading dialog
        EasyLoading.dismiss();
        if (response.statusCode == 200) {
          Map<String, dynamic> data = json.decode(response.body);
          if (data['is_valid'].toString() == "false") {
            Fluttertoast.showToast(msg: "invalid referral code");
            referalController.text = '';
          } else {
            Fluttertoast.showToast(msg: " referral code verified");
          }

          print("referal code verified$data");
        } else {
          Map<String, dynamic> data = json.decode(response.body);

          print("referal code not verified");
          Fluttertoast.showToast(msg: data['message'] ?? "");
        }
      } catch (e) {
        EasyLoading.dismiss();
        print('Error8: $e');
        if (e is SocketException) {
          print('No Internet Connection');
// Show error message as toast
          Fluttertoast.showToast(msg: "No Internet Connection");
        }
        if (e is FormatException) {
          print('Invalid JSON Format333$e');
          EasyLoading.dismiss();
        }
      }
    }
  }

  void getVerifyLoginOtp() async {
    if (checkValidationForLogin()) {
      print('username Body: ${_phoneController.text.trim()}');

      EasyLoading.show();
      try {
        Response response = await post(
          Uri.parse('${ApiProvider.baseUrl + ApiProvider.sendLoginOtp}'),
          body: {
            "username": '+91${_phoneController.text.trim()}',
          },
          // headers: {
          //   'Authorization': 'Bearer $accessToken',
          //
          // },
        );
        print('Response Status Code1====: ${response.statusCode}');
        print('Response Body: ${response.body}');
        // Close the loading dialog
        EasyLoading.dismiss();
        if (response.statusCode == 200) {
          pincode = '';

          showDialog(
            barrierDismissible: false,
            // Set this to false to make the dialog non-cancellable

            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                // title: Center(
                //   child: Text('OTP Verification',
                //     style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600,color: Colors.background),),
                // ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 21.0),
                      child: Text(
                        'OTP Verification',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.background,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.cancel),
                    ),
                  ],
                ),
                content: Row(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: Container(
                        // width:MediaQuery.of(context).size.width/1.5,
                        // height: MediaQuery.of(context).size.height/2,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 20,
                              ),
                              // const Align(
                              //   alignment: Alignment.center,
                              //   child: Text(
                              //     'Enter the OTP',
                              //     style: TextStyle(
                              //       fontSize: 14.0,
                              //       color: Colors.background,
                              //     ),
                              //   ),
                              // ),
                              const SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: PinCodeTextField(
                                    appContext: context,
                                    length: 4,
                                    // controller: _otpController,
                                    obscureText: false,
                                    keyboardType: TextInputType.number,
                                    animationType: AnimationType.fade,
                                    pinTheme: PinTheme(
                                      shape: PinCodeFieldShape.underline,
                                      borderRadius: BorderRadius.circular(3),
                                      fieldHeight: 25,
                                      fieldWidth: 25,
                                      activeColor: Colors.blue,
                                      inactiveColor: Colors.grey,
                                      activeFillColor: Colors.white,
                                      inactiveFillColor: Colors.white,
                                    ),
                                    textStyle: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black),
                                    // Set the font size here

                                    onChanged: (String pin) {
                                      if (pin.length == 4) {
                                        pincode = pin;
                                        buttonColor = Colors
                                            .background; // Change button color to green when enabled
                                      } else {
                                        buttonColor = Colors
                                            .disablebutton; // Change button color to red when disabled
                                      } // Handle changes in the OTP input
                                    },
                                    onCompleted: (String pin) {
                                      // Handle OTP submission
                                      print('Entered OTP: $pin');
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              GestureDetector(
                                onTap: () {
                                  print("verify4----");
                                  getVerifyLoginOtp();
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  // padding: const EdgeInsets.fromLTRB(150, 14, 30, 20),
                                  color: Colors.transparent,

                                  child:  RichText(
                                    text: const TextSpan(
                                      text: 'Didn’t you receive the OTP? ',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: 'Resend OTP',
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold),
                                          // Add onTap if you want to make the term clickable
                                          // onTap: () {
                                          //   // Add your onTap logic here
                                          // },
                                        ),

                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  height:
                                  MediaQuery.of(context).size.width / 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 22.0),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: SizedBox(
                                    width: 150, // Set the desired width here
                                    height: 39,
                                    child: GestureDetector(
                                      onTap: () {
                                        VerifyLoginOtp();
                                        // Handle onPressed action
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: buttonColor,
                                          borderRadius:
                                          BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          'Verify',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );

          Map<String, dynamic> data = json.decode(response.body);

          print("Otp Sent$data");
        }
        if (response.statusCode == 400) {
          Fluttertoast.showToast(msg: "User does not exists");
        } else {
          Map<String, dynamic> data = json.decode(response.body);

          print("Otp Sent failed");
          Fluttertoast.showToast(msg: data['message'] ?? "");
        }
      } catch (e) {
        EasyLoading.dismiss();
        print('Error1: $e');
        if (e is SocketException) {
          print('No Internet Connection');
// Show error message as toast
          Fluttertoast.showToast(msg: "No Internet Connection");
        }
        if (e is FormatException) {
          print('Invalid JSON Format333$e');
          EasyLoading.dismiss();
        }
      }
    }
  }

  bool checkValidationForLogin() {
    setState(() {});
    // if(_otpController.text.trim().isEmpty || _otpController.text.trim().length!=4){
    //   Fluttertoast.showToast(msg: "Enter Otp");
    //   return false;
    //
    // }
    if (isNumeric(_phoneController.text)) {
      if (_phoneController.text.isEmpty || _phoneController.text.length != 10) {
        Fluttertoast.showToast(msg: "Enter valid Phone Number");
        return false;
      }
    } else {
      if (!isEmailIdValid(_phoneController.text)) {
        Fluttertoast.showToast(msg: "Enter Valid Email");
        return false;
      }
    }
    return true;
  }
  bool isNumeric(String data) {
    if (data == null) {
      return false;
    }

    return double.tryParse(data) != null;
  }

  bool isEmailIdValid(String email) {
    String emailPattern =
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'; // Regular expression for email validation
    RegExp regExp = RegExp(emailPattern);
    return regExp.hasMatch(email);
  }

  void VerifyLoginOtp() async {
    if (checkValidationForLoginOtp()) {
      EasyLoading.show();
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        device_type = prefs.getString('device_type')!;
        device_id = prefs.getString('device_id')!;
        device_token = prefs.getString('device_token')!;
        print(
            "valuesss===========$device_type=====#$device_id======++++$device_token");
        Response response = await post(
          Uri.parse('${ApiProvider.baseUrl + ApiProvider.verifyLoginOtp}'),
          body: {
            "username": '+91${_phoneController.text.trim()}',
            "otp": pincode,
            "device_type": device_type,
            "device_token": device_token,
            // "device_id":  device_id// cahnge device_token
          },
          // headers: {
          //   'Authorization': 'Bearer $accessToken',
          //
          // },
        );
        print('Response Status Code2: ${response.statusCode}');
        print('Response Body: ${response.body}');

        // Close the loading dialog
        EasyLoading.dismiss();
        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: "Login Successfully");

          pincode = '';
          Map<String, dynamic> data = json.decode(response.body);
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('access_token', data['tokens']['access_token']);
          prefs.setString('refresh_token', data['tokens']["refresh_token"]);
          prefs.setString('stripe_customer_id', data['data']['stripe_customer_id']);
          prefs.setString('user_id', data['data']['id']);
          Navigator.of(context).pop();
          //  print("Otp Sent${ data['data']['id']}${data['data']['stripe_customer_id']}");
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false);
        }
        else {
          Map<String, dynamic> data = json.decode(response.body);
          if (data['status'] == false && data['status_code'] == 400) {
            // Display the error message to the user
            String errorMessage1 = data['data']['non_field_errors'][0];
            print("-------------$errorMessage1");

            Fluttertoast.showToast(msg: errorMessage1);
// Output the error message to the console
            // You can show this message in a Snackbar, AlertDialog, or any other way you prefer
          }
        }
      } catch (e, StackTrace) {
        EasyLoading.dismiss();
        print('Error2: $e========$StackTrace');
        if (e is SocketException) {
          print('No Internet Connection');
// Show error message as toast
          Fluttertoast.showToast(msg: "No Internet Connection");
        }
        if (e is FormatException) {
          print('Invalid JSON Format333$e');
          EasyLoading.dismiss();
        }
      }
    }
  }

  bool checkValidationForLoginOtp() {
    if (pincode.isEmpty || pincode.length != 4) {
      Fluttertoast.showToast(msg: "Enter Otp");
      return false;
    }
    return true;
  }
}

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OtpVerificationScreen> {
  ProgressDialog? _progressDialog;
  TextEditingController otpcontoler = TextEditingController();

  late String _getEnteredOTP1 = "";
  Color buttonColor = Colors.disablebutton; // Default color

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.background,
        body: Column(
          children: [
            // Container(
            //   child: SvgPicture.asset(
            //     "assets/background_image.svg",
            //     fit: BoxFit.cover,
            //     // height: 150,
            //   ),
            // ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                "assets/back_sp.png",
                fit: BoxFit.cover,
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 2, 30, 10),
                        child: Column(
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'OTP Verification',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.background,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 9.0),
                            const Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Enter the OTP sent to +91 98xxxxxxxxx',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.background,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(20.0),
                                child: PinCodeTextField(
                                  appContext: context,
                                  length: 4,
                                  obscureText: false,
                                  keyboardType: TextInputType.number,

                                  animationType: AnimationType.fade,
                                  textStyle: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black),
                                  // Set the font size here

                                  pinTheme: PinTheme(
                                    shape: PinCodeFieldShape.underline,
                                    borderRadius: BorderRadius.circular(5),
                                    fieldHeight: 50,
                                    fieldWidth: 30,
                                    activeColor: Colors.blue,
                                    inactiveColor: Colors.grey,
                                    activeFillColor: Colors.white,
                                    inactiveFillColor: Colors.white,
                                  ),
                                  onChanged: (String pin) {
                                    if (pin.length == 4) {
                                      buttonColor = Colors
                                          .background; // Change button color to green when enabled
                                    } else {
                                      buttonColor = Colors
                                          .disablebutton; // Change button color to red when disabled
                                    } // Handle changes in the OTP input
                                  },
                                  onCompleted: (String pin) {
                                    // Handle OTP submission
                                    print('Entered OTP: $pin');
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            GestureDetector(
                              onTap: () {
                                print("verify3----");
                                // ResendOtp();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                // padding: const EdgeInsets.fromLTRB(150, 14, 30, 20),
                                color: Colors.transparent,

                                child:  RichText(
                                  text: const TextSpan(
                                    text: 'Didn’t you receive the OTP? ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: 'Resend OTP',
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold),
                                        // Add onTap if you want to make the term clickable
                                        // onTap: () {
                                        //   // Add your onTap logic here
                                        // },
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.width / 1.8),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: SizedBox(
                                width: 250, // Set the desired width here
                                height: 50,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) =>
                                              SignIn() //Dashboard()
                                          ),
                                    );
                                    // Handle onPressed action
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: buttonColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Verify',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
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
}
