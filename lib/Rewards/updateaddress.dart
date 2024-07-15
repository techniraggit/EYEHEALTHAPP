
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' hide Response ;
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:second_eye/sign_up.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'new_address_screen.dart';
import 'rewards_sync.dart';
import '../api/Api.dart';
import '../api/config.dart';
import '../models/OfferData.dart';
import '../models/address_list.dart';
import '../notification/notification_dashboard.dart';
class Address {
  final String addressId;
  final String address;
  final String postalCode;
  final String city;
  final String state;
  final String country;
  final String fullAddress;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String locality;
  final bool isDefault;
  final String addressType;

  Address({
    required this.addressId,
    required this.address,
    required this.postalCode,
    required this.city,
    required this.state,
    required this.country,
    required this.fullAddress,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.locality,
    required this.isDefault,
    required this.addressType,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressId: json['address_id'],
      address: json['address'],
      postalCode: json['postal_code'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      fullAddress: json['full_address'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      locality: json['locality'],
      isDefault: json['is_default'],
      addressType: json['address_type'],
    );
  }
}

class updateAddressScreen extends StatefulWidget {
  final String? address_id; // Declare variable to hold received data

  updateAddressScreen({required this.address_id});

  @override
  updatedADdress createState() => updatedADdress();
}

class updatedADdress extends State<updateAddressScreen> {
  String address_type = ''; // Variable to store the selected text value
String? address_id = '';
  String offer_id='';
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

  String pincode = '';
  double Latitude = 0.0;
  double Longitude = 0.0;

  DateTime ? _selectedDate;

  Color buttonColor = Colors.disablebutton; // Default color

  bool _emailValid = true;

  @override
  void initState() {

    super.initState();

    address_id=widget.address_id;
    getaddress(address_id!);

    print("address_id= $address_id");
    getNotifactionCount();
  }

  bool isVerifiedEmail = false; // Example boolean variable indicating verification status
  bool isVerifiedPhone = false; // Example boolean variable indicating verification status
  String device_id = "";
  String device_type = "";
  String device_token = "";

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
       offer_id= sharedPref.getString("offer_id") ?? '';

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
            preferredSize: Size.fromHeight(60),
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
                      Navigator.of(context).pop();
                    },
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 10),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 1),
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
                                  borderRadius: BorderRadius.circular(27.0),
                                  borderSide: BorderSide(color: Colors.grey,
                                      width: 0.7), // Set border color and width
        // Add circular border
                                ),
                                // Set floatingLabelBehavior to always display the label
                                floatingLabelBehavior: FloatingLabelBehavior
                                    .always,
                                // Add button to the end of the TextField

                              ),
                              style: const TextStyle(fontSize: 13,
                                  fontWeight: FontWeight.w400),
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
                                LengthLimitingTextInputFormatter(10),
                                // Limits input length to 10 characters
                              ],
                              keyboardType: TextInputType.number,
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
                                      27.0),
                                  borderSide: BorderSide(color: Colors.grey,
                                      width: 0.7), // Set border color and width
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
                                _emailValid = isValidEmail(
                                    value); // Validate email on change
                              });
                            },
                            decoration: InputDecoration(
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
                                    27.0),
                                borderSide: BorderSide(color: Colors.grey,
                                    width: 0.7), // Set border color and width
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
                              errorText: _emailValid
                                  ? null
                                  : 'Please enter a valid email',

                            ),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w400),
                          ),
                        ),

                        const SizedBox(height: 55),
                        SizedBox(
                          height: 50,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width / 1.2,

                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 1),
                            child: TextField(
                              controller: _houseNoController,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                labelText: 'House No, Building Name.',
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
                                  borderSide: BorderSide(color: Colors.grey,
                                      width: 0.7), // Set border color and width
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
                          width: MediaQuery
                              .of(context)
                              .size
                              .width / 1.2,

                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 1),
                            child: TextField(
                              controller: _pinCodeController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(6),
                                // Limits input length to 10 characters
                              ],
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                labelText: 'Pincode',
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
                                      27.0),
                                  borderSide: BorderSide(color: Colors.grey,
                                      width: 0.7), // Set border color and width
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
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width / 2.5,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 3),
                                child: TextField(
                                  controller: _countryController,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Country',
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
                                          27.0),
                                      borderSide: BorderSide(color: Colors.grey,
                                          width: 0.7), // Set border color and width
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
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width / 2.5,


                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 3),
                                child: TextField(
                                  controller: _stateController,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'State',
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
                                          27.0),
                                      borderSide: BorderSide(color: Colors.grey,
                                          width: 0.7), // Set border color and width
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
                          width: MediaQuery
                              .of(context)
                              .size
                              .width / 1.2,

                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 1),
                            child: TextField(
                              controller: _cityController,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                labelText: 'City',
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
                                  borderSide: BorderSide(color: Colors.grey,
                                      width: 0.7), // Set border color and width
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

                        const SizedBox(height: 20),
                        SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width / 1.2,

                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 1),
                            child: TextField(
                              controller: _localityController,
                              maxLines: null, // Allows multiline input
                              enabled: false,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                labelText: 'Full Address',
                                hintText: 'Full Address',
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
                                  borderSide: BorderSide(color: Colors.grey,
                                      width: 0.7), // Set border color and width
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

                        // Row(
                        //   children: [
                        //     SelectableContainer(
                        //       text: 'Home',
                        //       isSelected: address_type == 'Home',
                        //       onTap: () => setSelectedValue('Home'),
                        //     ),
                        //     SelectableContainer(
                        //       text: 'Custom',
                        //       isSelected: address_type == 'Custom',
                        //       onTap: () => setSelectedValue('Custom'),
                        //     ),
                        //     SelectableContainer(
                        //       text: 'Work',
                        //       isSelected: address_type == 'Work',
                        //       onTap: () => setSelectedValue('Work'),
                        //     ),
                        //   ],
                        // ),
                        //
                        //
                        // SizedBox(height: 18,),





                        // SizedBox(height: 8,),


                        // Container(
                        //   padding: EdgeInsets.only(top: 10.0, left: 10),
                        //   child: Column(
                        //     children: <Widget>[
                        //       CheckboxListTile(
                        //         title: Text(
                        //           'Make this as default',
                        //           style: TextStyle(
                        //             color: Colors.black87,
                        //             fontSize: 13,
                        //             fontWeight: FontWeight.w400,
                        //           ),
                        //         ),
                        //         value: isChecked,
                        //         onChanged: (newValue) {
                        //           setState(() {
                        //             isChecked = newValue!;
                        //           });
                        //         },
                        //         controlAffinity: ListTileControlAffinity
                        //             .leading, //  <-- leading Checkbox
                        //       )
                        //     ],
                        //   ),
                        // ),


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

                                updateAddress(address_id) ;




                              },
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all<double>(
                                    0), // Set elevation to 0 to remove shadow

                                backgroundColor:
                                MaterialStateProperty.all<Color>(Colors
                                    .background), // Set your desired background color here
                              ),
                              child: const Text('Update Address',
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


  bool checkValidationForVerifyEmail(String email) {
    // Simple email validation regex pattern
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool checkValidationForVerifyPhone(String phone) {
    // Simple email validation regex pattern
    final RegExp phoneRegex = RegExp(r'^\d{10}$');
    return phoneRegex.hasMatch(phone);
  }


  void AddAddress() async {
    var sharedPref = await SharedPreferences.getInstance();
    String token =
    // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE2MjcyODc2LCJpYXQiOjE3MTYxODY0NzYsImp0aSI6ImYyMjJhM2VlZDNjYTRlZjc4MmNmNmEyNTYzOGQxMmU1IiwidXNlcl9pZCI6IjkxOTNhOTE1LWY5YzItNDQ0MC04MDVlLTQxNDBhYTc5ZDQzOSJ9.2Gj1laeNGLhy0FxYQCQVoB_Idt5W0F0X621BVPtNaic";
    sharedPref.getString("access_token") ?? '';
    String offer_id = sharedPref.getString("offer_id") ?? '';
    if (_emailController.text
        .trim()
        .isEmpty && _emailController.text
        .trim()
        .isEmpty) {
      Fluttertoast.showToast(msg: "enter the details");
    }
    else if (address_type.isEmpty) {
      Fluttertoast.showToast(msg: "select address type");
    }
    else if (_firstNameController.text
        .trim()
        .isEmpty) {
      Fluttertoast.showToast(msg: " Enter Name");
    }
    else if (_localityController.text
        .trim()
        .isEmpty) {
      Fluttertoast.showToast(msg: " Enter locality");
    }

    else if (_phoneController.text
        .trim()
        .isEmpty) {
      Fluttertoast.showToast(msg: " Enter Phone Number");
    }
    else if (_emailController.text
        .trim()
        .isEmpty) {
      Fluttertoast.showToast(msg: " Enter Email");
    }
    else if (_pinCodeController.text
        .trim()
        .isEmpty) {
      Fluttertoast.showToast(msg: " Enter Pincode");
    }
    else if (_countryController.text
        .trim()
        .isEmpty) {
      Fluttertoast.showToast(msg: " Enter Country");
    }
    else if (_houseNoController.text
        .trim()
        .isEmpty) {
      Fluttertoast.showToast(msg: " Enter House No./Building Name");
    }
    else if (_stateController.text
        .trim()
        .isEmpty) {
      Fluttertoast.showToast(msg: " Enter State");
    }
    else if (_cityController.text
        .trim()
        .isEmpty) {
      Fluttertoast.showToast(msg: " Enter City");
    }
    // if(checkValidationForAddAddress()){


    EasyLoading.show();
    try {
      Map<String, dynamic> requestBody = {
        "full_name": _firstNameController.text.trim(),
        "phone_number": _phoneController.text.trim(),
        "email": _emailController.text.trim(),
        "locality": _localityController.text.trim(),
        "address": _houseNoController.text.trim(),
        "postal_code": _pinCodeController.text.trim(),
        "city": _cityController.text.trim(),
        "state": _stateController.text.trim(),
        "country": _countryController.text.trim(),
        "is_default": isChecked,
        "address_type": address_type
      };
      Response response = await post(
          Uri.parse('${ApiProvider.baseUrl + ApiProvider.getaddress}'),
          body: jsonEncode(requestBody),
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $token',
          }

      );
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('requestBody e: ${requestBody}');

      EasyLoading.dismiss();
      if (response.statusCode == 201) {
        Map<String, dynamic> data = json.decode(response.body);
        Fluttertoast.showToast(
            msg: "Address added successfully !!, now you can Redeem "); //data['message']

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => RewardSpecs(offer_id: offer_id)),
        );

        // Navigator.pop(context, );


        print("Email verified $data");
      } else {
        Map<String, dynamic> responseMap = json.decode(response.body);

        if (responseMap['status'] == false) {
          // Check if the response data contains the 'phone_number' field
          if (responseMap.containsKey('data') && responseMap['data'] != null) {
            // Check if the 'phone_number' field is a list and not empty
            if (responseMap['data']['phone_number'] is List &&
                responseMap['data']['phone_number'].isNotEmpty) {
              // Fetch the message from the 'phone_number' list
              String errorMessage = responseMap['data']['phone_number'][0];
              print(errorMessage);
              Fluttertoast.showToast(
                  msg: '${responseMap['data']['phone_number'][0]}'); // Print the error message
            }
            if (responseMap['data']['email'] is List &&
                responseMap['data']['email'].isNotEmpty) {
              // Fetch the message from the 'phone_number' list
              String errorMessage = responseMap['data']['email'][0];
              print(errorMessage); // Print the error message
              Fluttertoast.showToast(
                  msg: '${responseMap['data']['email'][0]}'); // Print the error message

            }


            if (responseMap['data']['address_type'] is List &&
                responseMap['data']['address_type'].isNotEmpty) {
              Fluttertoast.showToast(
                  msg: 'Select Address type'); // Print the error message
              String errorMessage = responseMap['data']['address_type'][0];
              print("eroooooooooo" + errorMessage); // Print the error message

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
    if (_emailController.text
        .trim()
        .isEmpty && _emailController.text
        .trim()
        .isEmpty) {
      Fluttertoast.showToast(msg: "enter the details");
      return false;
    }
    if (address_type.isEmpty) {
      Fluttertoast.showToast(msg: "select address type");
      return false;
    }
    if (_firstNameController.text
        .trim()
        .isEmpty) {
      Fluttertoast.showToast(msg: " Enter Name");
      return false;
    }
    if (_localityController.text
        .trim()
        .isEmpty) {
      Fluttertoast.showToast(msg: " Enter locality");
      return false;
    }

    if (_phoneController.text
        .trim()
        .isEmpty) {
      Fluttertoast.showToast(msg: " Enter Phone Number");
      return false;
    }
    if (_emailController.text
        .trim()
        .isEmpty) {
      Fluttertoast.showToast(msg: " Enter Email");
      return false;
    }
    if (_pinCodeController.text
        .trim()
        .isEmpty) {
      Fluttertoast.showToast(msg: " Enter Pincode");
      return false;
    }
    if (_countryController.text
        .trim()
        .isEmpty) {
      Fluttertoast.showToast(msg: " Enter Country");
      return false;
    }
    if (_houseNoController.text
        .trim()
        .isEmpty) {
      Fluttertoast.showToast(msg: " Enter House No./Building Name");
      return false;
    }
    if (_stateController.text
        .trim()
        .isEmpty) {
      Fluttertoast.showToast(msg: " Enter State");
      return false;
    }
    if (_cityController.text
        .trim()
        .isEmpty) {
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


  Future<void> getaddress(String address) async {


    try {
      String userToken = '';
      var sharedPref = await SharedPreferences.getInstance();
      userToken =
      sharedPref.getString("access_token") ?? '';
      Map<String, String> headers = {
        'Authorization': 'Bearer $userToken', // Bearer token type
      };
      print("statusCode================${userToken}");

      final response = await http.get(
        Uri.parse('${ApiProvider.baseUrl}${ApiProvider.getaddress}?address_id=$address'),
        headers: headers,
      );
      print("statusCode================${response.statusCode}");
      print("responsebody================${response.body}");

      if (response.statusCode == 200) {
        Map<String, dynamic> responseMap = jsonDecode(response.body);
        List<dynamic> addressData = responseMap['data'];

// Assuming you have only one address in the response as per your example
        Address address = Address.fromJson(addressData[0]);

        _phoneController.text=address.phoneNumber;
        _firstNameController.text=address.fullName;
        _houseNoController.text=address.address;
        _emailController.text=address.email;
        _localityController.text=address.fullAddress;
        _addressname.text=address.address;
        _stateController.text=address.state;
        _cityController.text=address.city;
        _pinCodeController.text=address.postalCode;
        _countryController.text=address.country;
        address_type=address.addressType;




        setState(() {});
      } else if (response.statusCode == 401) {
        Fluttertoast.showToast(msg: "Session Expired");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      } else {
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

  Future<void> updateAddress(String? addressId) async {
    address_id = widget.address_id;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('access_token') ?? '';
    var headers = {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json'
    };

    var url = Uri.parse('${Api.baseurl}/api/address');

    var data = json.encode({
      "address_id": address_id,
      "address": _houseNoController.text,
      "postal_code": _pinCodeController.text,
      "city": _cityController.text,
      "state": _stateController.text,
      "country": _countryController.text,
      // "full_address": _localityController.text,
      "full_name": _firstNameController.text,
      "phone_number": _phoneController.text,
      "email": _emailController.text,
      // "locality": _localityController.text,
      "is_default": isChecked,
      "address_type": address_type
    });
if(_houseNoController.text.trim().isEmpty ||_pinCodeController.text.trim().isEmpty||
    _cityController.text.trim().isEmpty ||_stateController.text.trim().isEmpty||
    _countryController.text.trim().isEmpty ||_firstNameController.text.trim().isEmpty||
    _phoneController.text.trim().isEmpty ||_emailController.text.trim().isEmpty){
  Fluttertoast.showToast(msg: "Enter all details..");

}
else{

  try {
    var response = await http.patch(
      url,
      headers: headers,
      body: data,
    );

    print("RESPONSE: ${response.body}");
    print("REQUEST DATA: $data");

    if (response.statusCode == 200) {
      print("Address updated successfully");
      Fluttertoast.showToast(msg: "Address updated successfully!!");
      setState(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RewardSpecs(offer_id: offer_id)),
        );
      });
    }
    else if (response.statusCode == 400) {
      print("Address updated successfully");
      var jsonResponse = json.decode(response.body);

      if (jsonResponse.containsKey('message')) {
        var message = jsonResponse['message'];
        if (message is Map) {
          // Assuming 'locality' is always present in the message
          var localityError = message['locality'];
          if (localityError is List && localityError.isNotEmpty) {
            var errorMessage = localityError[0]; // Assuming only one error message is returned
            print('Error: $errorMessage');
            Fluttertoast.showToast(msg: errorMessage);

          }
        }
      }
    }

    else  {
      print('Request failed with status: ${response.statusCode}');
      print('Response data: ${response.body}');
      Fluttertoast.showToast(msg: "Failed to update address. Please try again.");
    }
  } catch (e) {
    print('Error sending request: $e');
    Fluttertoast.showToast(msg: "Failed to update address. Please check your internet connection.");
  }

}
}


}