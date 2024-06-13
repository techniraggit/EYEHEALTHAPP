import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:action_broadcast/action_broadcast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_new/Rewards/rewards_sync.dart';
import 'package:project_new/api/config.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../Custom_navbar/bottom_navbar.dart';
import '../Custom_navbar/customDialog.dart';
import '../HomePage.dart';
import '../api/Api.dart';
import '../digitalEyeTest/testScreen.dart';
import '../eyeFatigueTest/eyeFatigueTest.dart';
import '../notification/notification_dashboard.dart';
import '../sign_up.dart';
// Import intl package

class Offer {
  final String offerId;
  final String title;
  final String image;
  final String description;
  final int requiredPoints;

  Offer({
    required this.offerId,
    required this.title,
    required this.image,
    required this.description,
    required this.requiredPoints,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      offerId: json['offer_id'],
      title: json['title'],
      image: json['image'],
      description: json['description'],
      requiredPoints: json['required_points'],
    );
  }
}

class RewardsScreen extends StatefulWidget {
  @override
  RewardsScreenState createState() => RewardsScreenState();
}

class RewardsScreenState extends State<RewardsScreen>  with AutoCancelStreamMixin{

  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey();
  int? isReadFalseCount = 0;

  @override
  Iterable<StreamSubscription> get registerSubscriptions sync* {
    yield registerReceiver(['actionMusicPlaying']).listen(
          (intent) {
        switch (intent.action) {
          case 'actionMusicPlaying':
            setState(() {
              getNotifactionCount();
            });
            break;
        }
      },
    );
  }


  late Future<List<Offer>> futureOffers = Future.value([]);

  String eyeHealthScore = '0';
  @override
  void initState() {
    super.initState();
    getNotifactionCount();

    futureOffers = fetchOffers();
  }
  Future<void> getNotifactionCount() async {
    try{
      String userToken = '';
      var sharedPref = await SharedPreferences.getInstance();
      userToken = sharedPref.getString("access_token") ?? '';
      String url = "'${ApiProvider.baseUrl}/api/helping/get-count";
      print("URL: $url");

      Map<String, String> headers = {
        'Authorization': 'Bearer $userToken', // Bearer token type
        'Content-Type': 'application/json',
      };
      var response = await Dio().get(url, options: Options(headers: headers));
      print('drf gfbt Count: $response');

      if (response.statusCode == 200) {
        final responseData = response.data;
        // Map<String, dynamic> responseData = json.decode(response.data);
        int unreadNotificationCount = responseData['unread_notification_count'];
        isReadFalseCount = unreadNotificationCount;
        print('Unread Notification Count: $unreadNotificationCount');
        print('Unread gfbt Count: $response');
        if(mounted){
          setState(() {});

        }
      }else if (response.statusCode == 401) {

        Fluttertoast.showToast(msg: "Session Expired");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      }   else if (response.statusCode == 401) {

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
      }

      else {
        // Handle other Dio errors
        print("DioError: ${e.error}");
      }
    } catch (e) {
      // Handle other exceptions
      print("Exception---: $e");
    }
  }

  Future<List<Offer>> fetchOffers() async {
    String access_token = '';
    var sharedPref = await SharedPreferences.getInstance();
    access_token =
    // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE2MjcyODc2LCJpYXQiOjE3MTYxODY0NzYsImp0aSI6ImYyMjJhM2VlZDNjYTRlZjc4MmNmNmEyNTYzOGQxMmU1IiwidXNlcl9pZCI6IjkxOTNhOTE1LWY5YzItNDQ0MC04MDVlLTQxNDBhYTc5ZDQzOSJ9.2Gj1laeNGLhy0FxYQCQVoB_Idt5W0F0X621BVPtNaic";
    sharedPref.getString("access_token") ?? '';
    final String apiUrl = '${ApiProvider.baseUrl}/api/offers';

    Map<String, String> headers = {
      'Authorization': 'Bearer $access_token',
    };

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        print(response.body);
        Map<String, dynamic> data = jsonDecode(response.body);
        int score = data['eye_health_score'];
        print('jjjjj$score');

        // Update the state to display the score
        setState(() {
          eyeHealthScore = score.toString();
        });
        return jsonResponse.map((offer) => Offer.fromJson(offer)).toList();

      } else {
        throw Exception('Failed to load offers');
      }
    } catch (e) {
      if (e is SocketException) {
        CustomAlertDialog.attractivepopup(
            context, 'poor internet connectivity , please try again later!');
      }
      throw Exception('Failed to send data');
    }
  }


  // Sample data for line 2
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMMM').format(DateTime.now());
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
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0), // Add padding
        child: ClipOval(
          child: Material(
            color: Colors.white, // Background color
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
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
            Center(
              child: Text('Rewards', style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                // Adjust size as needed
                // Add other styling properties as needed
              ),),
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
                        color: const Color(0xffF9F9FA),
                        borderRadius: BorderRadius.circular(17.0),
                      ),
                      height: 40,
                      width: 40,
                      child: Center(
                        child: Image(
                          image: AssetImage('assets/notification.png'),
                          height: 20,
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 0, 0, 8),
              child: Text(
                'Today $formattedDate', // Display formatted current date
                style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.asset(
                    'assets/reward.png',
                    fit: BoxFit.contain,
                    // Add any additional properties to style the image
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Your Eye Health Score',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white // Adjust size as needed
                        // Add other styling properties as needed
                      ),
                    ),
                    Text(
                      eyeHealthScore, // Convert double to String
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.amber, // Adjust size as needed
                        // Add other styling properties as needed
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Add spacing between titles and dynamic list
            Padding(
              padding: EdgeInsets.fromLTRB(16.0,0, 0, 0),
              child: Text(
                'Redeem Offers', // Display formatted current date
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            Padding(
              padding:  EdgeInsets.all(8.0),
              child: FutureBuilder<List<Offer>>(
                future: futureOffers,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No offers found'));
                  } else {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height/2.3, // Set a fixed height or any height you deem appropriate
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final offer = snapshot.data![index];
                          return Padding(
                            padding:  EdgeInsets.all(8.0),
                            child: Card(
                           color: Colors.white,
                              child: Row(
                                children: [
                                  // Image on the left side
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Image.network(
                                      '${ApiProvider.baseUrl}${offer.image}',
                                      width: 80, // Set the desired width
                                      height: 80, // Set the desired height
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  // Columns on the right side
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:  EdgeInsets.symmetric(
                                              vertical: 4.0, horizontal: 8.0),
                                          child: Text(
                                            offer.title,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:  EdgeInsets.symmetric(
                                              vertical: 4.0, horizontal: 8.0),
                                          child: Text(
                                            offer.description,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:  EdgeInsets.all(2.0),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => RewardSpecs(offer_id:offer.offerId)),
                                              );

                                            },
                                            child: Text('Explore More'),
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                                              // Text color
                                              padding: EdgeInsets.all(10),
                                              minimumSize: Size(100, 20),
                                              // Button padding
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(26),
                                                // Button border radius
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),

            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 0, 0, 10),
              child: Text(
                'Perform EyeTest', // Display formatted current date
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Card(
                color: Colors.white,
                child: Row(
                  children: [
                    // Image on the left side
                    Image.asset(
                      'assets/eyetest.png',
                      // Add any additional properties to style the image
                    ),
                    // Columns on the right side
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 8.0,
                              ),
                              child: Text(
                                'Eye Test',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 8.0,
                              ),
                              child: Text(
                                '',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(2.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Choose a Test'),
                                        content: Container(
                                          height: 200, // Adjust the height as needed
                                          width: MediaQuery.of(context).size.width * 0.8, // Adjust the width as needed
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  sendcustomerDetails( true) ;

                                                },
                                                child: Image.asset(
                                                  'assets/digital_eye_exam.png',
                                                  // height: 100,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => EyeFatigueStartScreen()),
                                                  );
                                                },
                                                child: Image.asset(
                                                  'assets/eyeFatigueTest.png',
                                                  // height: 100,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Text('Start Test'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.deepPurple,
                                  // Background color
                                  // Text color
                                  padding: EdgeInsets.all(10),
                                  minimumSize: Size(100, 20),
                                  // Button padding
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(26),
                                    // Button border radius
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
            ),// Add spacing between titles and dynamic list
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 0, 0, 10),
              child: Text(
                'Refer and Earn', // Display formatted current date
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Card(color: Colors.white,
                child: Row(
                  children: [

                    // Image on the left side
                    Image.asset(
                      'assets/refer_earn.png',
                      // Add any additional properties to style the image
                    ),
                    // Columns on the right side
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 8.0,
                              ),
                              child: Text(
                                'Refer and Earn',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 8.0,
                              ),
                              child: Text(
                                '',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(2.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RewardContact(),
                                    ),
                                  );
                                },
                                child: Text('Explore More'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.deepPurple,
                                  // Background color
                                  // Text color
                                  padding: EdgeInsets.all(10),
                                  minimumSize: Size(100, 20),
                                  // Button padding
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(26),
                                    // Button border radius
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
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 0, 0, 10),
              child: Text(
                'Upload Prescription', // Display formatted current date
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Card(
                color: Colors.white ,
                child: Row(
                  children: [
                    // Image on the left side
                    Image.asset(
                      'assets/prescription.png',
                      // Add any additional properties to style the image
                    ),
                    // Columns on the right side
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 8.0,
                              ),
                              child: Text(
                                'Upload Prescription',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 8.0,
                              ),
                              child: Text(
                                '',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(2.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PrescriptionUpload(),
                                    ),
                                  );
                                },
                                child: Text('Explore More'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.deepPurple,
                                  // Background color
                                  // Text color
                                  padding: EdgeInsets.all(10),
                                  minimumSize: Size(100, 20),
                                  // Button padding
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(26),
                                    // Button border radius
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
            ),

          ],
        ),
      ),

      bottomNavigationBar:
      CustomBottomAppBar(),
    );
  }
  Future<void> sendcustomerDetails( bool isSelf) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('access_token') ?? '';
    final String apiUrl = '${Api.baseurl}/api/eye/add-customer';

    Map<String, String> headers = {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json',
    };

    var body = json.encode({
      'is_self': isSelf,

    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      print('API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('customer_id')) {
          String customerId = jsonResponse['customer_id'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('customer_id', customerId);

          print('Customer ID: $customerId');

          // Check if the context is still mounted before navigating
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GiveInfo()),
            );
          }
        } else {
          print('Customer ID not found in response.');
        }
      } else {
        print('API call failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }
}