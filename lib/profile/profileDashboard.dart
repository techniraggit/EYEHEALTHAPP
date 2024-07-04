import 'dart:convert';
import 'dart:io';
import 'package:alarm/alarm.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';

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
  String name = '';

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
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : Scaffold(
              backgroundColor: Colors.background,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: Padding(
                padding: const EdgeInsets.all(8.0), // Add padding
                child: ClipOval(
                  child: Material(
                    color: Colors.white70.withOpacity(0.9), // Background color
                    elevation: 4.0, // Shadow
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => HomePage(),
                          ),
                        );
                      },
                      child: SizedBox(
                        width: 53.0, // Width of the FloatingActionButton
                        height: 50.0, // Height of the FloatingActionButton
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(
                                8.0), // Add padding for the icon
                            child: Image.asset(
                              "assets/home_icon.jpeg",
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
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.arrow_back, // Replace with your icon
                          color: Colors.white,
                          size: 30, // Adjust icon color as needed
                        ),
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width /
                              3), // Adjust the width as needed for the space between Icon and Text

                      Text(
                        "Profile", // Your title text
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color:
                              Colors.white, // Adjust the text color as needed
                        ),
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width /
                              4), // Adjust the width as needed for the space between Icon and Text

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
                  SizedBox(
                    height: 6,
                  ),
                  CircleAvatar(
                    radius: 50.0,
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: Column(
                        children: [
                          SizedBox(
                            width: 100.0,
                            height: 100.0,
                            child: isLoading
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : (imageUrl1.isNotEmpty && imageUrl1 != '')
                                    ? Image.network(
                                        imageUrl1,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/profile_pic.png',
                                        fit: BoxFit.fill,
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    name.toString(),
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
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
                                  ).then((value){
                                    getProfile();
                                  });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    // Half of the height for oval shape
                                    color: Colors.grey.withOpacity(0.1),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            'Personal Details',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                            ),
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
                                          ).then((value){
                                            getProfile();
                                          });
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
                                              RewardStatusScreen()));
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    // Half of the height for oval shape
                                    color: Colors.grey.withOpacity(0.1),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            'Reward Details',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                            ),
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
                                height: 20,
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
                                  width: MediaQuery.of(context).size.width,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    // Half of the height for oval shape
                                    color: Colors.grey.withOpacity(0.1),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          child: Center(
                                        child: Text(
                                          'Plans',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                          ),
                                        ),
                                      )),
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
                                  width: MediaQuery.of(context).size.width,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    // Half of the height for oval shape
                                    color: Colors.grey.withOpacity(0.1),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            'Terms and Condition',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                            ),
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
                                  width: MediaQuery.of(context).size.width,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    // Half of the height for oval shape
                                    color: Colors.grey.withOpacity(0.1),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            'Privacy Policy',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                            ),
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
                                  _showConfirmationDialog();
                                  // deleteUser();
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    // Half of the height for oval shape
                                    color: Colors.grey.withOpacity(0.1),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            'Delete Account',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                            ),
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

  void _showConfirmationDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Confirm"),
          content: Text("Are you sure you want to delete your account?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                // Perform delete operation
                deleteUser();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void Logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String access_token = prefs.getString('access_token') ?? '';
    Alarm.stopAll();

    prefs.remove("isLoggedIn");
    prefs.remove("access_token");

    await prefs.clear();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SignIn()),
        (Route<dynamic> route) => false);
  }

  void getProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('access_token') ?? '';
      final response = await http.get(
        Uri.parse('${ApiProvider.baseUrl + ApiProvider.getUserProfile}'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey('data')) {
          var data = responseData['data'];
          if (data.containsKey('points')) {
            points_.text = data['points'].toString();
            print("points=:${data['points'].toString()}");
          }

          if (data.containsKey('image') && data['image'] != null) {
            imageUrl1 = ApiProvider.baseUrl + data['image'].toString();

          } else {
            imageUrl1 = '';
            print("imageUrl1:${imageUrl1}");
          }

          if (data.containsKey('first_name') || data.containsKey('last_name')) {
            name = data['first_name'].toString() +
                ' ' +
                data['last_name'].toString();
            print(
                "responseviewprofile:${data['first_name'].toString() + ' ' + data['last_name'].toString()}");
          }
        }

        print("responseviewprofile:${response.body}");

        // return json.decode(response.body);
      } else {
        print(response.body);
      }
      setState(() {

      });
      print("isLoading=$isLoading");
    } catch (e) {
      // _progressDialog!.hide();

      print("exception:$e");
    }
    // throw Exception('');
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
        Fluttertoast.showToast(msg: "User Account Deleted Succesfully!!");

        // Alarm.stopAll();
        prefs.remove("isLoggedIn");
        prefs.remove("access_token");
        await prefs.clear();
        print("response--------${response.body}");
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
          termsContent =
              jsonResponse['term_and_condition']['content'].toString();
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
  void dispose() {
    super.dispose();
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
