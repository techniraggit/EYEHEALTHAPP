import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:project_new/profile/profileDashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/config.dart';

class UserProfile extends StatefulWidget {
  @override
  State<UserProfile> createState() => ProfileDetails();
}

class ProfileDetails extends State<UserProfile> {
  bool isMobileValid = true;
  String initialEmail = '';
  String initialPhone = '';
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNmeController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  bool isVerifiedphone = true;
  bool isVerifiedemail = true;
  TextEditingController _locationController = TextEditingController();
  TextEditingController referalController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  String pincode = '';
  double Latitude = 0.0;
  double Longitude = 0.0;
  bool isLoading = true;
  DateTime? _selectedDate;
  String user_id = '';
  Color buttonColor = Colors.disablebutton; // Default color

  bool _emailValid = true;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
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
    getProfile();
  }

  File? _imageFile;
  String imageUrl1 = "";
  File? imageFile;
  bool isVerifiedEmail =
      false; // Example boolean variable indicating verification status
  bool isVerifiedPhone =
      false; // Example boolean variable indicating verification status
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => UserDashboard()),
          // (route) => route.isFirst, // Remove until the first route (Screen 1)
        );

        return false;
      },
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              )
            : Scaffold(
                backgroundColor: Colors.background,
                body: Column(
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width / 3,
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(29, 3, 20, 20),
                            child: Text(
                              "Profile", // Your title text
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors
                                    .white, // Adjust the text color as needed
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          // top: MediaQuery.of(context).size.width / 3, // Adjust the top position as needed
                          left: 0,
                          right: 0,
                          child: Image.asset(
                            'assets/profileline.png', // Replace this with your image path
                          ),
                        ),
                        Positioned.fill(
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                _getImage();
                              },
                              child: Stack(
                                children: [
                                  // Circular image
                                  // CircleAvatar(
                                  //   radius: 50.0,
                                  //   backgroundColor: Colors.transparent,
                                  //   child: ClipOval(
                                  //     child: SizedBox(
                                  //       width: 80.0,
                                  //       height: 80.0,
                                  //       child: imageUrl1 != ''
                                  //           ? Image.network(
                                  //               imageUrl1,
                                  //               fit: BoxFit.cover,
                                  //             )
                                  //           : _imageFile == null && imageUrl1 == ""
                                  //               ? Image.asset(
                                  //                   'assets/profile_pic.png',
                                  //                   fit: BoxFit.cover,
                                  //                 )
                                  //               : Image.file(
                                  //                   _imageFile!,
                                  //                   fit: BoxFit.cover,
                                  //                 ),
                                  //     ),
                                  //   ),
                                  // ),
                                  // Icon for editing
                                  CircleAvatar(
                                    radius: 50.0,
                                    backgroundColor: Colors.transparent,
                                    child: ClipOval(
                                      child: SizedBox(
                                        width: 80.0,
                                        height: 80.0,
                                        child: _imageFile != null
                                            ? Image.file(
                                                _imageFile!,
                                                fit: BoxFit.cover,
                                              )
                                            : imageUrl1.isNotEmpty
                                                ? Image.network(
                                                    imageUrl1,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.asset(
                                                    'assets/profile_pic.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                      ),
                                    ),
                                  ),

                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(25),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 14),
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
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400),
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
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                // Builder(builder: (context) {
                                //   print("_phoneController=======${_phoneController.text}========initialPhone$initialPhone");
                                //   if( _phoneController.text.isNotEmpty &&
                                //       _phoneController.text.trim() != initialPhone)
                                //   {
                                //     isVerifiedphone=false;
                                //
                                //   }
                                //   else{
                                //     isVerifiedphone=true;
                                //   }
                                //   return SizedBox(
                                //     height: 55,
                                //     child: Padding(
                                //       padding: const EdgeInsets.symmetric(
                                //           horizontal: 10.0, vertical: 1),
                                //       child: TextField(
                                //         controller: _phoneController,
                                //         inputFormatters: [
                                //           LengthLimitingTextInputFormatter(10),
                                //           // Limits input length to 10 characters
                                //         ],
                                //         keyboardType: TextInputType.number,
                                //         textInputAction: TextInputAction.next,
                                //
                                //         onSubmitted: (_) {
                                //           // Call your API function when the user submits the text field
                                //           verifyUserphone();
                                //         },
                                //         onEditingComplete: () {
                                //           setState(() {
                                //             isVerifiedphone = false;
                                //           });
                                //           // Call your API function when the user completes editing the text field
                                //           verifyUserphone();
                                //         },
                                //
                                //         decoration: InputDecoration(
                                //           labelText: 'Phone',
                                //           hintText: 'Enter Phone Number',
                                //           labelStyle: const TextStyle(
                                //               fontSize: 14,
                                //               color: Colors.background,
                                //               fontWeight: FontWeight.w400),
                                //           hintStyle: const TextStyle(
                                //               fontSize: 16,
                                //               color: Colors.hinttext,
                                //               fontWeight: FontWeight.w400),
                                //           border: OutlineInputBorder(
                                //             borderRadius: BorderRadius.circular(
                                //                 27.0), // Add circular border
                                //           ),
                                //           // Set floatingLabelBehavior to always display the label
                                //           floatingLabelBehavior:
                                //               FloatingLabelBehavior.always,
                                //           suffixIcon: !isVerifiedphone
                                //               ? GestureDetector(
                                //                   onTap: () {
                                //                     getVerifyPhoneOtp();
                                //                   },
                                //                   child: getSuffixIconPhone(),
                                //                 )
                                //               : null,
                                //
                                //
                                //         ),
                                //         style: const TextStyle(
                                //             fontSize: 15,
                                //             fontWeight: FontWeight.w400),
                                //       ),
                                //     ),
                                //   );
                                // }),
                                Builder(builder: (context) {
                                  print("_phoneController=======${_phoneController.text}========initialPhone$initialPhone");

                                  // Add listener to _phoneController to update isVerifiedphone state
                                  _phoneController.addListener(() {
                                    setState(() {
                                      if (_phoneController.text.trim() != initialPhone) {
                                        isVerifiedphone = false;
                                      } else {
                                        isVerifiedphone = true;
                                      }
                                    });
                                  });

                                  return SizedBox(
                                    height: 55,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 1),
                                      child: TextField(
                                        controller: _phoneController,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(10),
                                          // Limits input length to 10 characters
                                        ],
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.next,
                                        onSubmitted: (_) {
                                          // Call your API function when the user submits the text field
                                          verifyUserphone();
                                        },
                                        onEditingComplete: () {
                                          setState(() {
                                            isVerifiedphone = false;
                                          });
                                          // Call your API function when the user completes editing the text field
                                          verifyUserphone();
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Phone',
                                          hintText: 'Enter Phone Number',
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
                                            borderRadius: BorderRadius.circular(27.0), // Add circular border
                                          ),
                                          // Set floatingLabelBehavior to always display the label
                                          floatingLabelBehavior: FloatingLabelBehavior.always,
                                          suffixIcon: !isVerifiedphone
                                              ? GestureDetector(
                                            onTap: () {
                                              getVerifyPhoneOtp();
                                            },
                                            child: getSuffixIconPhone(),
                                          )
                                              : null,
                                        ),
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  );
                                }),

                                const SizedBox(height: 25),
                                Builder(builder: (context) {
                                  if (_emailController.text.isNotEmpty &&
                                      _emailController.text != initialEmail) {
                                    // setState(() {
                                    isVerifiedemail = false;
                                    // });
                                  } else {
                                    isVerifiedemail = true;
                                  }

                                  return Padding(
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
                                      onSubmitted: (_) {
                                        // Call your API function when the user submits the text field
                                        verifyUseremail();
                                      },
                                      onEditingComplete: () {
                                        setState(() {
                                          isVerifiedemail = false;
                                        });
                                        // Call your API function when the user completes editing the text field
                                        verifyUseremail();
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        hintText: 'Enter Email Address',
                                        labelStyle: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.background,
                                            fontWeight: FontWeight.w400),

                                        hintStyle:  TextStyle(
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
                                        suffixIcon: !isVerifiedemail
                                            ? GestureDetector(
                                                onTap: () {
                                                  getVerifyEmailOtp();
                                                },
                                                child: getSuffixIconEmail(),
                                              )
                                            : null,

                                        errorText: _emailValid
                                            ? null
                                            : 'Please enter a valid email',
                                      ),
                                      style:  TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400),maxLines: null,
                                    ),
                                  );
                                }),
                                const SizedBox(height: 20),
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
                                        updateProfilePicture();
                                      },
                                      style: ButtonStyle(
                                        elevation: MaterialStateProperty.all<
                                                double>(
                                            0), // Set elevation to 0 to remove shadow
                                        backgroundColor: MaterialStateProperty
                                            .all<Color>(Colors
                                                .background), // Set your desired background color here
                                      ),
                                      child: const Text('Update',
                                          style: TextStyle(
                                              color: Colors.white,
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
      // Permissions are denied or denied forever, let's request it!
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permissions are still denied");
      } else if (permission == LocationPermission.deniedForever) {
        print("Location permissions are permanently denied");
      } else {
        _determinePosition().then((value) {
          print("User loation ${value.latitude} ,, ${value.longitude}");
          Latitude = value.latitude;
          Longitude = value.longitude;
          _getAddressFromLatLng(value.latitude, value.longitude);
        });
        // Permissions are granted (either can be whileInUse, always, restricted).
        print("Location permissions are granted after requesting");
      }
    } else {
      print("Location permissions are granted ");

      _determinePosition().then((value) {
        _getAddressFromLatLng(value.latitude, value.longitude);
        print("User loation ${value.latitude} ,, ${value.longitude}");
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
        _locationController.text =
            "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
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

  bool checkValidationForVerifyPhone(String phone) {
    // Simple email validation regex pattern
    final RegExp phoneRegex = RegExp(r'^\d{10}$');
    return phoneRegex.hasMatch(phone);
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      imageFile = _imageFile!;
      // await updateProfilePicture();
    }
  }

  Future<void> updateProfilePicture() async {
    const String apiUrl =
        '${ApiProvider.baseUrl + ApiProvider.updateUserProfile}';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken =
        // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
        prefs.getString('access_token') ?? '';

    var request = http.MultipartRequest('PATCH', Uri.parse(apiUrl));
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile!.path,
        ),
      );
    }
    request.headers['Authorization'] =
        'Bearer $authToken'; // Replace $authToken with your actual token
    request.fields['id'] = user_id;
    request.fields['email'] = _emailController.text;
    request.fields['phone_number'] = _phoneController.text;
    request.fields['last_name'] = _lastNmeController.text;
    request.fields['first_name'] = _firstNameController.text;
    request.fields['dob'] = '1982-12-11';
    print("request.fields===${request.fields}");

    try {
      // Send the request
      http.StreamedResponse response = await request.send();
      print("dsfds: ${response.stream}=======${response.statusCode}");

      // Check the response status code
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Profile Updated Sucessfully");
      } else {
        // Read the response body as a string
        String responseBody = await response.stream.bytesToString();

        Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

        // Extract and print error messages
        if (jsonResponse.containsKey("message")) {
          Map<String, dynamic> messages = jsonResponse["message"];
          messages.forEach((key, value) {
            print("$key: $value");
            Fluttertoast.showToast(msg: '${value}');
          });
        } else {
          print("Error: Unknown error occurred");
        }

        // Print the response body for debugging
        print("fail: $responseBody");

        // Handle different error scenarios based on status code
        if (response.statusCode == 404) {
          print("User does not exist");
        } else {
          print("Unknown error occurred");
        }
      }
    } catch (e) {
      // Handle exceptions
      print('Error: $e');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('id') ?? '';
      String token = prefs.getString('access_token') ?? '';
      // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";

      // prefs.getString('access_token') ?? '';

      print("id :$userId");
      final response = await http.get(
        Uri.parse('${ApiProvider.baseUrl + ApiProvider.getUserProfile}'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // _progressDialog!.hide();

        final jsonResponse = jsonDecode(response.body);
        setState(() {
          user_id = jsonResponse['data']['id'];
          _firstNameController.text = jsonResponse['data']['first_name'];
          if (jsonResponse['data']['last_name'] == null ||
              jsonResponse['data']['last_name'].toString().isNotEmpty) {
            _lastNmeController.text = jsonResponse['data']['last_name'];
          } else {
            _lastNmeController.text = "N/A";
          }
          _phoneController.text = jsonResponse['data']['phone_number'];
          _emailController.text = jsonResponse['data']['email'];
          initialEmail = jsonResponse['data']['email'];
          initialPhone = jsonResponse['data']['phone_number'];
          if (jsonResponse['data']['image'] != null) {
            imageUrl1 =
                "${ApiProvider.baseUrl}" + jsonResponse['data']['image'];
          } else {
            imageUrl1 = '';
          }

          isLoading = false; //replace url
        });
        /** String imageData=data['profile_pic'];

            imageUrl = imageData;
            print("imageurl:"+imageUrl);**/
        print("responseviewprofile:${response.body}");

        return json.decode(response.body);
      } else {
        // _progressDialog!.hide();

        print(response.body);
      }
    } catch (e) {
      // _progressDialog!.hide();

      print("exception:$e");
    }
    throw Exception('');
  }

  void getVerifyPhoneOtp() async {
    if (checkValidationForVerifyPhone(_phoneController.text)) {
      EasyLoading.show();
      try {
        Response response = await post(
          Uri.parse('${ApiProvider.baseUrl + ApiProvider.verifyEmailOtp}'),
          body: {
            "username": _phoneController.text.trim(),
          },
          // headers: {
          //   'Authorization': 'Bearer $accessToken',
          //
          // },
        );
        print('Response Status Code: ${response.statusCode}');
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
                                  // ResendOtp();
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  // padding: const EdgeInsets.fromLTRB(150, 14, 30, 20),
                                  color: Colors.transparent,

                                  child: const Text(
                                    textAlign: TextAlign.center,
                                    'Didn’t you receive the OTP? Resend OTP',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
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
    }
  }

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
        print('Response Status Code: ${response.statusCode}');
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
                                  // ResendOtp();
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  // padding: const EdgeInsets.fromLTRB(150, 14, 30, 20),
                                  color: Colors.transparent,

                                  child: const Text(
                                    textAlign: TextAlign.center,
                                    'Didn’t you receive the OTP? Resend OTP',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
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

        print('Response Status Code: ${response.statusCode}');
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
            "username": _phoneController.text.trim(),
            "otp": pincode // _otpController.text.trim(),
          },
          // headers: {
          //   'Authorization': 'Bearer $accessToken',
          //
          // },
        );

        print('Response Status Code: ${response.statusCode}');
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
    if (_locationController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: " Enter Location");
      return false;
    }

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
        print('Response Status Code: ${response.statusCode}');
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
    }
  }

  void verifyUserphone() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiProvider.baseUrl + ApiProvider.verifyuser}${_phoneController.text.trim()}'),
      );

      if (response.statusCode == 200) {
        // _progressDialog!.hide();

        final jsonResponse = jsonDecode(response.body);

        // Access the value of is_verified
        isVerifiedphone = jsonResponse['is_verified'];
        setState(() {});

        print("responseviewprofile:${response.body}");

        return json.decode(response.body);
      } else {
        // _progressDialog!.hide();

        print(response.body);
      }
    } catch (e) {
      // _progressDialog!.hide();

      print("exception:$e");
    }
    throw Exception('');
  }

  Future<void> verifyUseremail() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiProvider.baseUrl + ApiProvider.verifyuser}${_emailController.text.trim()}'),
      );

      if (response.statusCode == 200) {
        // _progressDialog!.hide();

        final jsonResponse = jsonDecode(response.body);

        // Access the value of is_verified
        isVerifiedemail = jsonResponse['is_verified'];
        setState(() {});

        print("responseviewprofile:${response.body}");

        return json.decode(response.body);
      } else {
        // _progressDialog!.hide();

        print(response.body);
      }
    } catch (e) {
      // _progressDialog!.hide();

      print("exception:$e");
    }
    throw Exception('');
  }
}
