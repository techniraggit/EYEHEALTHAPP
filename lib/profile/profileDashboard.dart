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
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:second_eye/HomePage.dart';
import 'package:second_eye/profile/myPlanPage.dart';
import 'package:second_eye/Rewards/rewardStatus.dart';
import 'package:second_eye/Rewards/rewards_sync.dart';
import 'package:second_eye/sign_up.dart';
import 'package:second_eye/profile/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Custom_navbar/bottom_navbar.dart';
import '../api/config.dart';
import '../notification/notification_dashboard.dart';

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
    return  Scaffold(
              backgroundColor: Colors.bluebutton,

              body:  isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              )
                  :Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
        Container(
          width: double.infinity, // Ensure the container takes the full width
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Profile",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    Logout();

                    // Replace with your logout logic
                    print("Logout tapped");
                  },
                  child: Container(
                    child: Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
SizedBox(height: 5,),
                  Stack(
                    children: [
                      Container(

                        child: Image.asset(
                          'assets/profileline.png', // Replace this with your image path
                        ),
                      ),

                      Column(
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 50.0,
                              backgroundColor: Colors.transparent,
                              child: ClipOval(
                                child: Column(
                                  children: [

                                    Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
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
                                            :
                                        Icon(
                                          Icons.account_circle,
                                          // Use the account circle icon from the Icons class
                                          size: MediaQuery.of(context).size.width/3.8,  // Adjust the size of the icon as needed
                                          color: Colors.white,

                                          // Adjust the color of the icon as needed
                                        ),
                                        // Image.asset(
                                        //   'assets/profile.png',
                                        //   // 'assets/profile_pic.png',
                                        //   fit: BoxFit.cover,
                                        // ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
                        ],
                      ),

                    ],
                  ),

                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration:  BoxDecoration(
                        color: Colors.white.withOpacity(0.97),
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
                                child: Material(
                                  elevation: 5, borderRadius:BorderRadius.circular(22),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(22),
                                      // Half of the height for oval shape
                                      color: Colors.white.withOpacity(0.8),
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
                                child: Material(
                                  elevation: 5, borderRadius:BorderRadius.circular(22),

                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(22),
                                      // Half of the height for oval shape
                                      color: Colors.white.withOpacity(0.8),
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
                                child: Material(
                                  elevation: 5, borderRadius:BorderRadius.circular(22),

                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(22),
                                      // Half of the height for oval shape
                                      color: Colors.white.withOpacity(0.8),
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
                                child: Material(
                                  elevation: 5, borderRadius:BorderRadius.circular(22),

                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(22),
                                      // Half of the height for oval shape
                                      color: Colors.white.withOpacity(0.8),
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
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) => AboutUs()));
                                },
                                child: Material(
                                  elevation: 5, borderRadius:BorderRadius.circular(22),

                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(22),
                                      // Half of the height for oval shape
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              'About Us',
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
                                child: Material(
                                  elevation: 5, borderRadius:BorderRadius.circular(22),

                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(22),
                                      // Half of the height for oval shape
                                      color: Colors.white.withOpacity(0.8),
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
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              GestureDetector(
                                onTap: () {
                                  _showConfirmationDialog();
                                  // deleteUser();
                                },
                                child: Material(
                                  elevation: 5, borderRadius:BorderRadius.circular(22),

                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(22),
                                      // Half of the height for oval shape
                                      color: Colors.white.withOpacity(0.8),
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
                              ),
                              SizedBox(
                                height: 80,
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(height: 80,),

                ],
              ),
              // bottomNavigationBar: CustomBottomAppBar(
              //   currentScreen: 'ProfileDashboard',
              // ),
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


    navigateToSignInScreen(context);
    // Navigator.of(context).pushAndRemoveUntil(
    //     MaterialPageRoute(builder: (context) => SignIn()),
    //     (Route<dynamic> route) => false);
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
  void navigateToSignInScreen(BuildContext context) {
    if (mounted) {
      pushNewScreenWithRouteSettings(
        context,
        settings:  RouteSettings(name: 'music_player_page'),
        screen: SignIn(),
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    }
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

        if (context.mounted) {
          pushNewScreenWithRouteSettings(
            context,
            settings: const RouteSettings(name: 'music_player_page'),
            screen: SignIn(),
            withNavBar: false,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        }


        // Navigator.of(context).pushAndRemoveUntil(
        //   MaterialPageRoute(builder: (context) => SignIn()),
        //   (Route<dynamic> route) => false,
        // );
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
  String privacyContent = ''; final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey();
  int? isReadFalseCount = 0;

  @override
  void initState() {
    super.initState();
    loadPrivacyPolicy();
    getNotifactionCount();

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

  Future<void> loadPrivacyPolicy() async {
    try {
      final response = await http.get(
        Uri.parse(ApiProvider.baseUrl + ApiProvider.privacyPage),
        headers: <String, String>{},
      );
      print("waaa" + response.body);

      if (response.statusCode == 200) {
        // _progressDialog!.hide();

        final jsonResponse = jsonDecode(response.body);
        privacyContent = jsonResponse['content'];
        // List<dynamic> dataList = jsonResponse['data'];

// Assuming you want to retrieve content from the first item in the data array
//         if (dataList.isNotEmpty) {
//
//
//           privacyContent = dataList[2]['content'];
//           print('Content from API: $privacyContent');
//
//         }
        setState(() {
          // privacyContent = jsonResponse['privacy_policy']['content'].toString();
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
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
                 Navigator.of(context).pop();                 },
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
                    'Privacy Policy',
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
                      height: 35,
                      width: 35,
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

      // appBar: AppBar(
      //   title: Padding(
      //     padding: const EdgeInsets.symmetric(vertical: 10.0),
      //     child: Center(child: Text('Privacy Policy',style: TextStyle(fontWeight: FontWeight.w700,fontSize: 18),)),
      //   ),
      // ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 2),
        child: Column(
          children: [
            Html(data: privacyContent),
            SizedBox(height: 80,)

          ],
        ),
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
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey();
  int? isReadFalseCount = 0;
  @override
  void initState() {
    super.initState();
    loadTerms();
    getNotifactionCount();

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

  Future<void> loadTerms() async {
    try {
      final response = await http.get(
        Uri.parse(ApiProvider.baseUrl + ApiProvider.termsPage),
        headers: <String, String>{},
      );
      print("waaa" + response.body);

      if (response.statusCode == 200) {
        // _progressDialog!.hide();

        final jsonResponse = jsonDecode(response.body);
        termsContent = jsonResponse['content'];

//         List<dynamic> dataList = jsonResponse['data'];
//
// // Assuming you want to retrieve content from the first item in the data array
//         if (dataList.isNotEmpty) {
//           termsContent = dataList[1]['content'];
//           print('Content from API: $termsContent');
//         }
        setState(() {

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
        preferredSize: const Size.fromHeight(60),
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
                    'Terms and Conditions',
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
                      height: 35,
                      width: 35,
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

      // appBar: AppBar(
      //   title: Padding(
      //     padding: const EdgeInsets.symmetric(vertical: 10.0),
      //     child: Center(child: Text('Terms and Conditions',style: TextStyle(fontWeight: FontWeight.w700,fontSize: 17),)),
      //   ),
      // ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 2),
        child: Column(
          children: [
            Html(data: termsContent),
            SizedBox(height: 80,)
          ],
        ),
      ),
    );
  }
}











class AboutUs extends StatefulWidget {
  @override
  AboutPage createState() => AboutPage();
}

class AboutPage extends State<AboutUs> {
  String aboutusContent = '';
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey();
  int? isReadFalseCount = 0;

  @override
  void initState() {
    super.initState();
    aboutUs();
    Future.delayed(const Duration(seconds: 1), () {})
        .then((_) => getNotifactionCount())
        .then((_) {
      if (mounted) {
        setState(() {});
      }
    });
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

  Future<void> aboutUs() async {
    try {
      final response = await http.get(
        Uri.parse(ApiProvider.baseUrl + ApiProvider.aboutPage),
        headers: <String, String>{},
      );
      print("waaa" + response.body);

      if (response.statusCode == 200) {
        // _progressDialog!.hide();

        final jsonResponse = jsonDecode(response.body);
//         List<dynamic> dataList = jsonResponse['data'];
//
// // Assuming you want to retrieve content from the first item in the data array
//         if (dataList.isNotEmpty) {
//           aboutusContent = dataList[0]['content'];
//           print('Content from API: $aboutusContent');
//         }


          setState(() {

          aboutusContent =
              jsonResponse['content'].toString();
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
        preferredSize: const Size.fromHeight(60),
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
                  Navigator.pop(context);
                },
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10, // Adjust height as needed
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'About Us',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        // Adjust size as needed
                        // Add other styling properties as needed
                      ),
                    ),
                  ),
                ),
                // SizedBox(
                //   height: 10,
                // ),

              ],
            ),
            Positioned(
              right: 16,
              top: 7,
              child: GestureDetector(
                onTap: () {
                  _scafoldKey.currentState!.openEndDrawer();
                },
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffF9F9FA),
                        borderRadius: BorderRadius.circular(17.0),
                      ),
                      height: 40,
                      width: 40,
                      child: Center(
                        child: Icon(
                          Icons.notifications,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: -1, // Adjust this value to position the text properly
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


      // appBar: AppBar(
      //   title: Padding(
      //     padding: const EdgeInsets.symmetric(vertical: 10.0),
      //     child: Center(child: Text('About Us',style: TextStyle(fontWeight: FontWeight.w700,fontSize: 17),)),
      //   ),
      // ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 2),
        child: Column(
          children: [
            Html(data: aboutusContent),
            SizedBox(height: 80,)

          ],
        ),
      ),
    );
  }
}