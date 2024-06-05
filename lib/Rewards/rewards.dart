import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
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

class RewardsScreenState extends State<RewardsScreen> {
  late Future<List<Offer>> futureOffers = Future.value([]);

  String eyeHealthScore = '0';
  @override
  void initState() {
    super.initState();
    futureOffers = fetchOffers();
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Rewards', style: TextStyle(
          fontSize: 26.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          // Adjust size as needed
          // Add other styling properties as needed
        ),),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notification icon pressed
            },
          ),
        ],
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
                Image.asset(
                  'assets/reward.png',
                  fit: BoxFit.contain,
                  // Add any additional properties to style the image
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
              padding: EdgeInsets.fromLTRB(16.0, 10, 0, 10),
              child: Text(
                'Offers', // Display formatted current date
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
                              child: Row(
                                children: [
                                  // Image on the left side
                                  Image.network(
                                    '${ApiProvider.baseUrl}${offer.image}',
                                    width: 100, // Set the desired width
                                    height: 100, // Set the desired height
                                    fit: BoxFit.cover,
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

            ), // Add spacing between titles and dynamic list
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Card(
                child: Row(
                  children: [
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
                                'Second Text',
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
                                'Second Text',
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
}