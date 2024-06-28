import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:project_new/HomePage.dart';
import 'package:project_new/profile/myPlanPage.dart';
import 'package:project_new/Rewards/rewardStatus.dart';
import 'package:project_new/Rewards/rewards_sync.dart';
import 'package:project_new/sign_up.dart';
import 'package:project_new/profile/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Custom_navbar/bottom_navbar.dart';
import '../api/config.dart';

class UserDashboard extends StatefulWidget {
  @override
  State<UserDashboard> createState() => UserProfiledash();
}

class UserProfiledash extends State<UserDashboard> {
  bool isMobileValid = true;
  TextEditingController points_ = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  File? _imageFile;
  String imageUrl1 = '';
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : Scaffold(
              backgroundColor: Colors.background,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0), // Add padding
          child: ClipOval(
            child: Material(
              color: Colors.white70.withOpacity(0.9), // Background color
              elevation: 4.0, // Shadow
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context, CupertinoPageRoute(
                    builder: (context) => HomePage(
                    ),
                  ),

                  );
                },
                child: SizedBox(
                  width: 53.0, // Width of the FloatingActionButton
                  height: 50.0, // Height of the FloatingActionButton
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0), // Add padding for the icon
                      child: Image.asset(
                        "assets/home_icon.png",
                        width: 20,
                        // fit: BoxFit.cover, // Uncomment if you want the image to cover the button
                        // color: Colors.grey, // Uncomment if you want to apply a color to the image
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
              body: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),

                  Row(
                    children: [
                      SizedBox(width: 10,),
                      GestureDetector(
                        onTap: (){
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.arrow_back, // Replace with your icon
                          color: Colors.white,
                          size: 30,// Adjust icon color as needed
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width/3), // Adjust the width as needed for the space between Icon and Text


                      Text(
                        "Profile", // Your title text
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color:
                              Colors.white, // Adjust the text color as needed
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width/4), // Adjust the width as needed for the space between Icon and Text

                      GestureDetector(
                        onTap: () {
                          Logout();
                        },
                        child: IconButton(
                          icon: Icon(Icons.logout_rounded),
                          color: Colors.white,
                          iconSize: 28,
                          onPressed: () {
                            Logout();
                          },
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 16,),

                  //             Image.asset(
                  // height: 30,
                  //               'assets/profileline.png', // Replace this with your image path
                  //             ),
                  ClipOval(
                    child: SizedBox(
                      width: 86.0, height: 86,
                      // height: 80.0,
                      child: imageUrl1 != ""
                          ? Image.network(
                              imageUrl1,
                              fit: BoxFit.cover,
                            )
                          : _imageFile == null && imageUrl1 == ""
                              ? Image.asset(
                                  'assets/profile_pic.png',
                                  width: 50,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const RadialGradient(
                        radius: 1.0,
                        colors: [
                          Color(0xFFFFF400),
                          Color(0xFFFFE800),
                          Color(0xFFFFCA00),
                          Color(0xFFFF9A00),
                          Color(0xFFFF9800),
                        ],
                      ).createShader(bounds);
                    },
                    child: Text(
                      '${points_.text}',
                      style: const TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
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
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => UserProfile()),
                                  );
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.3,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    // Half of the height for oval shape
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          'Personal Details',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                            Icons.arrow_forward_ios_outlined),
                                        color: Colors.black,
                                        iconSize: 14,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) =>
                                                    UserProfile()),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) =>
                                              RewardStatusScreen()));
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.3,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    // Half of the height for oval shape
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          'Reward Details',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                            Icons.arrow_forward_ios_outlined),
                                        color: Colors.black,
                                        iconSize: 14,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) =>
                                                    RewardStatusScreen()),
                                          );
                                          // Navigate to next screen
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => MyPlan()),
                                  );
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.3,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    // Half of the height for oval shape
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          'Plans',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                            Icons.arrow_forward_ios_outlined),
                                        color: Colors.black,
                                        iconSize: 14,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) => MyPlan()),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) => TermsScreen()));
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.3,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    // Half of the height for oval shape
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          'Terms and Condition',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                            Icons.arrow_forward_ios_outlined),
                                        color: Colors.black,
                                        iconSize: 14,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) =>
                                                    TermsScreen()),
                                          );
                                          // Navigate to next screen
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) =>
                                              PrivacyScreen()));
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.3,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    // Half of the height for oval shape
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          'Privacy Policy',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                            Icons.arrow_forward_ios_outlined),
                                        color: Colors.black,
                                        iconSize: 14,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) =>
                                                   PrivacyScreen()),
                                          );
                                          // Navigate to next screen
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              GestureDetector(
                                onTap: () {
                                 deleteUser();
                                },
                                child: Container(
                                  width:
                                  MediaQuery.of(context).size.width / 1.3,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    // Half of the height for oval shape
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          'Delete Account',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                            Icons.arrow_forward_ios_outlined),
                                        color: Colors.black,
                                        iconSize: 14,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) =>
                                                    PrivacyScreen()),
                                          );
                                          // Navigate to next screen
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              // GestureDetector(
                              //   onTap: () {
                              //     Logout();
                              //   },
                              //   child: Container(
                              //     width:
                              //         MediaQuery.of(context).size.width / 1.3,
                              //     height: 60,
                              //     decoration: BoxDecoration(
                              //       borderRadius: BorderRadius.circular(22),
                              //       // Half of the height for oval shape
                              //       color: Colors.grey.withOpacity(0.3),
                              //     ),
                              //     child: Row(
                              //       // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //       children: [
                              //         IconButton(
                              //           icon: Icon(Icons.logout_rounded),
                              //           color: Colors.background,
                              //           iconSize: 14,
                              //           onPressed: () {
                              //             Logout();
                              //           },
                              //         ),
                              //         Padding(
                              //           padding: const EdgeInsets.symmetric(
                              //               horizontal: 3.0, vertical: 12),
                              //           child: Text(
                              //             'Sign Out',
                              //             style: TextStyle(
                              //               color: Colors.background,
                              //               fontSize: 15,
                              //             ),
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        bottomNavigationBar: CustomBottomAppBar(
          currentScreen: 'ProfileDashboard',
        ),
            ),
    );
  }

  void Logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String access_token = prefs.getString('access_token') ?? '';
    prefs.remove("isLoggedIn");
    prefs.remove("access_token");
    await prefs.clear();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SignIn()),
        (Route<dynamic> route) => false);
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('id') ?? '';
      String token = prefs.getString('access_token') ?? '';
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
          points_.text = jsonResponse['data']['points'].toString();
          if (jsonResponse['data']['image'] != null) {
            imageUrl1 = "${ApiProvider.baseUrl}" +
                jsonResponse['data']['image']; //replace url
          }
          isLoading = false;
        });

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

  Future<Map<String, dynamic>> deleteUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('id') ?? '';
      String token = prefs.getString('access_token') ?? '';
      print("id :$userId");
      final response = await http.get(
        Uri.parse('${ApiProvider.baseUrl + ApiProvider.deleteUser}'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print("response--------${response.body}");
        Fluttertoast.showToast(msg: "User Account Deleted Succesfully!!");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => SignIn()),
              (Route<dynamic> route) => false,
        );
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

class PrivacyScreen extends StatefulWidget {
  @override
  _PrivacyScreenState createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  String privacyContent = '';

  @override
  void initState() {
    super.initState();
    loadPrivacyPolicy();
  }

  Future<void> loadPrivacyPolicy() async {
    try {
      final response = await http.get(
        Uri.parse(ApiProvider.baseUrl + ApiProvider.isAgreement),
        headers: <String, String>{},
      );
      print("waaa" + response.body);

      if (response.statusCode == 200) {
        // _progressDialog!.hide();

        final jsonResponse = jsonDecode(response.body);
        setState(() {
          privacyContent = jsonResponse['privacy_policy']['content'].toString();

        });

      } else {
        // _progressDialog!.hide();

        print(response.body);
      }
    } catch (e) {
      print('Error loading privacy policy: $e');
      // Handle error loading privacy policy
    }
    if (mounted) {
      setState(() {}); // Refresh UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Html(data: privacyContent),
      ),
    );
  }
}

class TermsScreen extends StatefulWidget {
  @override
  _TermsScreenState createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  String termsContent = '';

  @override
  void initState() {
    super.initState();
    loadTerms();
  }

  Future<void> loadTerms() async {
    try {
      final response = await http.get(
        Uri.parse(ApiProvider.baseUrl + ApiProvider.isAgreement),
        headers: <String, String>{},
      );
      print("waaa" + response.body);

      if (response.statusCode == 200) {
        // _progressDialog!.hide();

        final jsonResponse = jsonDecode(response.body);
        setState(() {
          termsContent = jsonResponse['term_and_condition']['content'].toString();

        });

      } else {
        // _progressDialog!.hide();

        print(response.body);
      }
    } catch (e) {
      print('Error loading privacy policy: $e');
      // Handle error loading privacy policy
    }
    if (mounted) {
      setState(() {}); // Refresh UI
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Html(data: termsContent),
      ),
    );
  }
}
