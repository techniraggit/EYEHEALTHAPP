import 'dart:convert';
import 'dart:ffi' hide Size;
import 'dart:io' ;

import 'package:dio/dio.dart' hide Response;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart'hide Location;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:location/location.dart'hide LocationAccuracy;
import 'package:second_eye/Rewards/rewards_sync.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../api/config.dart';
import '../notification/notification_dashboard.dart';
import '../sign_up.dart';


class NewAddressScreen extends StatefulWidget {
  @override
  State<NewAddressScreen> createState() => AddADressSCreen();
}

class AddADressSCreen extends State<NewAddressScreen> {
  String address_type = ''; // Variable to store the selected text value



  bool isChecked = false;

  TextEditingController _phoneController = TextEditingController();
  bool isMobileValid = true;
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _houseNoController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _localityController = TextEditingController();
  TextEditingController _addressname = TextEditingController();

  TextEditingController _stateController = TextEditingController();


  TextEditingController _cityController = TextEditingController();
  TextEditingController _pinCodeController = TextEditingController();
  TextEditingController _countryController = TextEditingController();

  String pincode='';
  double Latitude=0.0;double Longitude=0.0;

  DateTime ? _selectedDate;

  Color buttonColor = Colors.disablebutton; // Default color

  bool _emailValid = true;
  @override
  void initState() {
    super.initState();
    getNotifactionCount();
  }
  bool isVerifiedEmail = false; // Example boolean variable indicating verification status
  bool isVerifiedPhone = false; // Example boolean variable indicating verification status
  String device_id="";String device_type="";String device_token="";
  Icon getSuffixIconEmail() {
    // Return different icon based on verification status
    return isVerifiedEmail
        ? Icon(Icons.verified_rounded, color: Colors.green)
        : Icon(Icons.warning, color: Colors.red);
  }
  Icon getSuffixIconPhone() {
    // Return different icon based on verification status
    return isVerifiedPhone
        ? Icon(Icons.verified_rounded, color: Colors.green)
        : Icon(Icons.warning, color: Colors.red);
  }

  Future<void> getNotifactionCount() async {
    try {
      String userToken = '';
      var sharedPref = await SharedPreferences.getInstance();
      userToken = sharedPref.getString("access_token") ?? '';
      String url = "${ApiProvider.baseUrl}/api/user_notification";
      print("URL: $url");
      print("userToken: $userToken");
      Map<String, String> headers = {
        'Authorization': 'Bearer $userToken', // Bearer token type
        'Content-Type': 'application/json',
      };
      var response = await Dio().get(url, options: Options(headers: headers));
      print('drf gfbt Count: $response');

      if (response.statusCode == 200) {
        final responseData = response.data;
        // Map<String, dynamic> responseData = json.decode(response.data);
        int unreadNotificationCount = responseData['is_read_false_count'];
        isReadFalseCount = unreadNotificationCount;
        print('Unread Notification Count: $unreadNotificationCount');
        print('Unread gfbt Count: $response');
        if (mounted) {
          setState(() {});
        }
      }
      else if (response.statusCode == 401) {
        Fluttertoast.showToast(msg: "Session Expired");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      }
      else {
        throw Exception('Failed to load data');
      }
    } on DioError catch (e) {
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
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey();
  int? isReadFalseCount = 0;
  @override
  Widget build(BuildContext context) {



    return
      // MaterialApp(
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      //   visualDensity: VisualDensity.adaptivePlatformDensity,
      // ),
      // home:
      WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);

          return true;
        },
        child: Scaffold(
          key: _scafoldKey,
          endDrawer: NotificationSideBar(
            onNotificationUpdate: () {
              setState(() {
                if (isReadFalseCount != null) {
                  if (isReadFalseCount! > 0) {
                    isReadFalseCount = isReadFalseCount! - 1;
                  }
                }
              });
            },
          ),
          endDrawerEnableOpenDragGesture: false,
          appBar: PreferredSize(
            preferredSize:  Size.fromHeight(60),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                    iconSize: 28, // Back button icon
                    onPressed: () {
                      Navigator.of(context).pop();                  },
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 18, // Adjust height as needed
                    ),
                    Center(
                      child: Text(
                        'Address',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          // Adjust size as needed
                          // Add other styling properties as needed
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),

                  ],
                ),
                Positioned(
                  right: 16,
                  top: 16,
                  child: GestureDetector(
                    onTap: () {
                      _scafoldKey.currentState!.openEndDrawer();
                    },
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: Colors.grey, // Border color
                              width: 1.0, // Border width
                            ),
                          ),
                          height: 30,
                          width: 30,
                          child: Center(
                            child: Icon(
                              Icons.notifications_none,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: -1,
                          // Adjust this value to position the text properly
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            child: Text(
                              '${isReadFalseCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),


          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [


                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 1),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Add your address or select an existing one to redeem your prize. We will send it to your chosen location.',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 23),

                        SizedBox(
                          height: 50,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 1),
                            child: TextField(
                              controller: _firstNameController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'Name',
                                labelStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.background,
                                  fontWeight: FontWeight.w400,
                                ),
                                hintText: 'Name',
                                hintStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.hinttext,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(27.0),                               borderSide: BorderSide(color: Colors.grey, width: 0.7), // Set border color and width
        // Add circular border
                                ),
                                // Set floatingLabelBehavior to always display the label
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                // Add button to the end of the TextField

                              ),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),


                        const SizedBox(height: 25),

                        SizedBox(
                          height: 50,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 1),
                            child: TextField(
                              controller: _phoneController,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10), // Limits input length to 10 characters
                              ],keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'Phone',
                                hintText: 'Phone Number',
                                labelStyle: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.background,

                                    fontWeight: FontWeight.w400),
                                hintStyle: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.hinttext,
                                    fontWeight: FontWeight.w400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      27.0),                              borderSide: BorderSide(color: Colors.grey, width: 0.7), // Set border color and width
                                  // Add circular border
                                ),
                                // Set floatingLabelBehavior to always display the label
                                floatingLabelBehavior:
                                FloatingLabelBehavior.always,
                                // suffixIcon: GestureDetector(
                                //     onTap: () {
                                //       getVerifyPhoneOtp();
                                //
                                //     },
                                //     child: getSuffixIconPhone())
                              ),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 1),
                          child: TextField(
                            controller: _emailController,
                            textInputAction: TextInputAction.next,
                            onChanged: (value) {
                              setState(() {
                                _emailValid = isValidEmail(value); // Validate email on change
                              });
                            },                              decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Email Address',
                            labelStyle: const TextStyle(
                                fontSize: 12,
                                color: Colors.background,
                                fontWeight: FontWeight.w400),

                            hintStyle: const TextStyle(
                                fontSize: 12,
                                color: Colors.hinttext,
                                fontWeight: FontWeight.w400),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  27.0),                               borderSide: BorderSide(color: Colors.grey, width: 0.7), // Set border color and width
                                // Add circular border
                            ),
                            // Set floatingLabelBehavior to always display the label
                            floatingLabelBehavior:
                            FloatingLabelBehavior.always,
                            // suffixIcon:GestureDetector(
                            //     onTap: () {
                            //       getVerifyEmailOtp();
                            //       print('Icon tapped');
                            //     },child: getSuffixIconEmail()),
                            errorText: _emailValid ? null : 'Please enter a valid email',

                          ),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w400),
                          ),
                        ),

                        const SizedBox(height: 55),
                        SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width/1.2,

                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 1),
                            child: TextField(
                              controller: _houseNoController,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                setState(() {
                                });
                              },                              decoration: InputDecoration(
                              labelText: '',
                              hintText: 'House No, Building Name.',
                              labelStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.background,
                                  fontWeight: FontWeight.w400),

                              hintStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.hinttext,
                                  fontWeight: FontWeight.w400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    27.0),
                                borderSide: BorderSide(color: Colors.grey, width: 0.7), // Set border color and width
        // Add circular border
                              ),
                              // Set floatingLabelBehavior to always display the label
                              floatingLabelBehavior:
                              FloatingLabelBehavior.always,


                            ),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),


                        const SizedBox(height: 20),
                        SizedBox(
                          height: 50,                            width: MediaQuery.of(context).size.width/1.2,

                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 1),
                            child: TextField(
                              controller: _localityController,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                setState(() {
                                });
                              },                              decoration: InputDecoration(
                              labelText: '',
                              hintText: 'Locality, Town.',
                              labelStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.background,
                                  fontWeight: FontWeight.w400),

                              hintStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.hinttext,
                                  fontWeight: FontWeight.w400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    27.0),                               borderSide: BorderSide(color: Colors.grey, width: 0.7), // Set border color and width
        // Add circular border
                              ),
                              // Set floatingLabelBehavior to always display the label
                              floatingLabelBehavior:
                              FloatingLabelBehavior.always,


                            ),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),


                        const SizedBox(height: 20),
                        SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width/1.2,

                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 1),
                            child: TextField(
                              controller: _pinCodeController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(6), // Limits input length to 10 characters
                              ],
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                setState(() {
                                });
                              },                              decoration: InputDecoration(
                              labelText: '',
                              hintText: 'Pincode',
                              labelStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.background,
                                  fontWeight: FontWeight.w400),

                              hintStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.hinttext,
                                  fontWeight: FontWeight.w400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    27.0),                               borderSide: BorderSide(color: Colors.grey, width: 0.7), // Set border color and width
        // Add circular border
                              ),
                              // Set floatingLabelBehavior to always display the label
                              floatingLabelBehavior:
                              FloatingLabelBehavior.always,


                            ),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),


                        Row(
                          children: [
                            SizedBox(
                              height: 49,
                              width: MediaQuery.of(context).size.width/2.5,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 3),
                                child: TextField(
                                  controller: _countryController,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (value) {
                                    setState(() {
                                    });
                                  },                              decoration: InputDecoration(
                                  labelText: '',
                                  hintText: 'Country',
                                  labelStyle: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.background,
                                      fontWeight: FontWeight.w400),

                                  hintStyle: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.hinttext,
                                      fontWeight: FontWeight.w400),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        27.0),                              borderSide: BorderSide(color: Colors.grey, width: 0.7), // Set border color and width
                                    // Add circular border
                                  ),
                                  // Set floatingLabelBehavior to always display the label
                                  floatingLabelBehavior:
                                  FloatingLabelBehavior.always,


                                ),
                                  style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),


                            SizedBox(width: 3,),
                            SizedBox(
                              height: 49,
                              width: MediaQuery.of(context).size.width/2.5,


                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 3),
                                child: TextField(
                                  controller: _stateController,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (value) {
                                    setState(() {
                                    });
                                  },                              decoration: InputDecoration(
                                  labelText: '',
                                  hintText: 'State',
                                  labelStyle: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.background,
                                      fontWeight: FontWeight.w400),

                                  hintStyle: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.hinttext,
                                      fontWeight: FontWeight.w400),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        27.0),                              borderSide: BorderSide(color: Colors.grey, width: 0.7), // Set border color and width
                                    // Add circular border
                                  ),
                                  // Set floatingLabelBehavior to always display the label
                                  floatingLabelBehavior:
                                  FloatingLabelBehavior.always,


                                ),
                                  style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),

                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width/1.2,

                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 1),
                            child: TextField(
                              controller: _cityController,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                setState(() {
                                });
                              },                              decoration: InputDecoration(
                              labelText: '',
                              hintText: 'City',
                              labelStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.background,
                                  fontWeight: FontWeight.w400),

                              hintStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.hinttext,
                                  fontWeight: FontWeight.w400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    27.0),
                                borderSide: BorderSide(color: Colors.grey, width: 0.7), // Set border color and width
        // Add circular border
                              ),
                              // Set floatingLabelBehavior to always display the label
                              floatingLabelBehavior:
                              FloatingLabelBehavior.always,


                            ),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        SizedBox(height: 18,),


                        Row(
                          children: [
                            SelectableContainer(
                              text: 'Home',
                              isSelected: address_type == 'Home',
                              onTap: () => setSelectedValue('Home'),
                            ),
                            SelectableContainer(
                              text: 'Custom',
                              isSelected: address_type == 'Custom',
                              onTap: () => setSelectedValue('Custom'),
                            ),
                            SelectableContainer(
                              text: 'Work',
                              isSelected: address_type == 'Work',
                              onTap: () => setSelectedValue('Work'),
                            ),
                          ],
                        ),



                        SizedBox(height: 18,),



                        SizedBox(
                          height: 54,
                          width: MediaQuery.of(context).size.width/0.9,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 3),
                            child: TextField(
                              inputFormatters: [ LengthLimitingTextInputFormatter(20),],
                              controller: _addressname,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                setState(() {
                                });
                              },                              decoration: InputDecoration(
                              labelText: '',
                              hintText: 'Save as - New Home, Dad’s workplace  ',
                              labelStyle: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.background,
                                  fontWeight: FontWeight.w400),

                              hintStyle: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.hinttext,
                                  fontWeight: FontWeight.w400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    27.0),                              borderSide: BorderSide(color: Colors.grey, width: 0.7), // Set border color and width
                                // Add circular border
                              ),
                              // Set floatingLabelBehavior to always display the label
                              floatingLabelBehavior:
                              FloatingLabelBehavior.always,


                            ),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),



                        SizedBox(height: 8,),



                        Container(
                          padding: EdgeInsets.only(top: 10.0,left: 10),
                          child: Column(
                            children: <Widget>[
                              CheckboxListTile(
                                title: Text(
                                  'Make this as default',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                value: isChecked,
                                onChanged: (newValue) {
                                  setState(() {
                                    isChecked = newValue!;
                                  });
                                },
                                controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                              )
                            ],
                          ),
                        ),








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

                                AddAddress();

                              },
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all<double>(
                                    0), // Set elevation to 0 to remove shadow

                                backgroundColor:
                                MaterialStateProperty.all<Color>(Colors
                                    .background), // Set your desired background color here
                              ),
                              child: const Text('Save',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 80),

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    // );
  }
  bool isValidEmail(String email) {
    // Simple email validation regex pattern
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
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

  bool checkValidationForVerifyPhone(String phone) {
    // Simple email validation regex pattern
    final RegExp phoneRegex =RegExp(r'^\d{10}$');
    return phoneRegex.hasMatch(phone);
  }







  void AddAddress() async {

    var sharedPref = await SharedPreferences.getInstance();
    String  token =
    // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE2MjcyODc2LCJpYXQiOjE3MTYxODY0NzYsImp0aSI6ImYyMjJhM2VlZDNjYTRlZjc4MmNmNmEyNTYzOGQxMmU1IiwidXNlcl9pZCI6IjkxOTNhOTE1LWY5YzItNDQ0MC04MDVlLTQxNDBhYTc5ZDQzOSJ9.2Gj1laeNGLhy0FxYQCQVoB_Idt5W0F0X621BVPtNaic";
    sharedPref.getString("access_token") ?? '';
  String offer_id= sharedPref.getString("offer_id") ?? '';
    if(_emailController.text.trim().isEmpty && _emailController.text.trim().isEmpty ){
      Fluttertoast.showToast(msg: "enter the details");

    }
   else if(address_type.isEmpty){
      Fluttertoast.showToast(msg: "select address type");
    }
    else if(_firstNameController.text.trim().isEmpty){
      Fluttertoast.showToast(msg: " Enter Name");

    }
    else if(_localityController.text.trim().isEmpty){
      Fluttertoast.showToast(msg: " Enter locality");

    }

   else if(_phoneController.text.trim().isEmpty){
      Fluttertoast.showToast(msg: " Enter Phone Number");

    }
   else if(_emailController.text.trim().isEmpty){
      Fluttertoast.showToast(msg: " Enter Email");

    }
   else if(_pinCodeController.text.trim().isEmpty){
      Fluttertoast.showToast(msg: " Enter Pincode");

    }
   else if(_countryController.text.trim().isEmpty){
      Fluttertoast.showToast(msg: " Enter Country");

    }
    else if(_houseNoController.text.trim().isEmpty){
      Fluttertoast.showToast(msg: " Enter House No./Building Name");

    }
    else if(_stateController.text.trim().isEmpty){
      Fluttertoast.showToast(msg: " Enter State");


    }
    else if(_cityController.text.trim().isEmpty){
      Fluttertoast.showToast(msg: " Enter City");


    }
    // if(checkValidationForAddAddress()){






      EasyLoading.show();
      try {
        Map<String, dynamic> requestBody = {
          "full_name": _firstNameController.text.trim(),
          "phone_number": _phoneController.text.trim(),
          "email": _emailController.text.trim(),
          "locality":  _localityController.text.trim(),
          "address":  _houseNoController.text.trim(),
          "postal_code":  _pinCodeController.text.trim(),
          "city": _cityController.text.trim(),
          "state":  _stateController.text.trim(),
          "country":  _countryController.text.trim(),
          "is_default": isChecked,
          "address_type": address_type
        };
        Response response = await post(
            Uri.parse('${ApiProvider.baseUrl+ApiProvider.getaddress}'),
            body: jsonEncode(requestBody),
            headers: {
              "Content-Type":"application/json",
              'Authorization': 'Bearer $token',
            }

        );
        print('Response Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        print('requestBody e: ${requestBody}');

        EasyLoading.dismiss();
        if (response.statusCode == 201) {

          Map<String, dynamic> data = json.decode(response.body);
          Fluttertoast.showToast(msg: "Address added successfully !!, now you can Redeem ");//data['message']

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RewardSpecs(offer_id: offer_id)),
          );

          // Navigator.pop(context, );




          print("Email verified $data");

        } else {
          Map<String, dynamic> responseMap = json.decode(response.body);

          if (responseMap['status'] == false) {
            // Check if the response data contains the 'phone_number' field
            if (responseMap.containsKey('data') && responseMap['data'] != null) {
              // Check if the 'phone_number' field is a list and not empty
              if (responseMap['data']['phone_number'] is List && responseMap['data']['phone_number'].isNotEmpty) {
                // Fetch the message from the 'phone_number' list
                String errorMessage = responseMap['data']['phone_number'][0];
                print(errorMessage);
                Fluttertoast.showToast(msg: '${responseMap['data']['phone_number'][0]}');// Print the error message
              }
              if (responseMap['data']['email'] is List && responseMap['data']['email'].isNotEmpty) {
                // Fetch the message from the 'phone_number' list
                String errorMessage = responseMap['data']['email'][0];
                print(errorMessage); // Print the error message
                Fluttertoast.showToast(msg: '${responseMap['data']['email'][0]}');// Print the error message

              }



              if (responseMap['data']['address_type'] is List && responseMap['data']['address_type'].isNotEmpty) {
                Fluttertoast.showToast(msg: 'Select Address type');// Print the error message
                String errorMessage = responseMap['data']['address_type'][0];
                print("eroooooooooo"+errorMessage); // Print the error message

              }

            }
          }
        }
      } catch (e) {
        EasyLoading.dismiss();
        print('Error: $e');
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
    // }
  }








  bool checkValidationForAddAddress() {
    if(_emailController.text.trim().isEmpty && _emailController.text.trim().isEmpty ){
      Fluttertoast.showToast(msg: "enter the details");
      return false;

    }
    if(address_type.isEmpty){
      Fluttertoast.showToast(msg: "select address type");
      return false;
    }
    if(_firstNameController.text.trim().isEmpty){
      Fluttertoast.showToast(msg: " Enter Name");
      return false;

    }
    if(_localityController.text.trim().isEmpty){
      Fluttertoast.showToast(msg: " Enter locality");
      return false;

    }

    if(_phoneController.text.trim().isEmpty){
      Fluttertoast.showToast(msg: " Enter Phone Number");
      return false;

    }
    if(_emailController.text.trim().isEmpty){
      Fluttertoast.showToast(msg: " Enter Email");
      return false;

    }
    if(_pinCodeController.text.trim().isEmpty){
      Fluttertoast.showToast(msg: " Enter Pincode");
      return false;

    }
    if(_countryController.text.trim().isEmpty){
      Fluttertoast.showToast(msg: " Enter Country");
      return false;

    }
    if(_houseNoController.text.trim().isEmpty){
      Fluttertoast.showToast(msg: " Enter House No./Building Name");
      return false;

    }
    if(_stateController.text.trim().isEmpty){
      Fluttertoast.showToast(msg: " Enter State");
      return false;

    }
    if(_cityController.text.trim().isEmpty){
      Fluttertoast.showToast(msg: " Enter City");
      return false;

    }
    return true;
  }



  void setSelectedValue(String value) {
    setState(() {
      address_type = value;
    });
  }




}



class SelectableContainer extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableContainer({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color? containerColor = isSelected ? Colors.background : Colors.grey[200];

    return GestureDetector(
      onTap: onTap,
      child: Container(

        margin: EdgeInsets.all(10),
        padding: EdgeInsets.symmetric(horizontal: 19,vertical: 12),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
