import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_new/api/config.dart';
import 'package:project_new/rewards_sync.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Custom_navbar/bottom_navbar.dart';
import 'HomePage.dart';
import 'Custom_navbar/customDialog.dart'; // Import intl package

class OfferDetail {
  String id;
  Offer offer;
  String createdOn;
  String updatedOn;
  String status;
  String redeemedOn;
  String user;
  String? address; // Nullable

  OfferDetail({
    required this.id,
    required this.offer,
    required this.createdOn,
    required this.updatedOn,
    required this.status,
    required this.redeemedOn,
    required this.user,
    this.address,
  });

  factory OfferDetail.fromJson(Map<String, dynamic> json) {
    return OfferDetail(
      id: json['id'],
      offer: Offer.fromJson(json['offer']),
      createdOn: json['created_on'],
      updatedOn: json['updated_on'],
      status: json['status'],
      redeemedOn: json['redeemed_on'],
      user: json['user'],
      address: json['address'],
    );
  }
}

class Offer {
  String offerId;
  String expiry;
  String createdOn;
  String updatedOn;
  String title;
  String image;
  String description;
  String expiryDate;
  String status;
  int requiredPoints;
  String createdBy;
  String updatedBy;

  Offer({
    required this.offerId,
    required this.expiry,
    required this.createdOn,
    required this.updatedOn,
    required this.title,
    required this.image,
    required this.description,
    required this.expiryDate,
    required this.status,
    required this.requiredPoints,
    required this.createdBy,
    required this.updatedBy,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      offerId: json['offer_id'],
      expiry: json['expiry'],
      createdOn: json['created_on'],
      updatedOn: json['updated_on'],
      title: json['title'],
      image: json['image'],
      description: json['description'],
      expiryDate: json['expiry_date'],
      status: json['status'],
      requiredPoints: json['required_points'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
    );
  }
}



class RewardStatusScreen extends StatefulWidget {
  @override
  RewardsStatusScreenState createState() => RewardsStatusScreenState();
}

class RewardsStatusScreenState extends State<RewardStatusScreen> {
  late Future<List<OfferDetail>> futureOffers = Future.value([]);

  String eyeHealthScore = '0';
  @override
  void initState() {
    super.initState();
    futureOffers = fetchOffers();
  }

  Future<List<OfferDetail>> fetchOffers() async {
    String access_token = '';
    var sharedPref = await SharedPreferences.getInstance();
    access_token = sharedPref.getString("access_token") ?? '';
    final String apiUrl = '${ApiProvider.baseUrl}/api/redeemed-offers';

    Map<String, String> headers = {
      'Authorization': 'Bearer $access_token',
    };

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // List jsonResponse = json.decode(response.body)['data'];
        print('Response Body: ${response.body}');

        List<dynamic> jsonResponse = json.decode(response.body)['data'];
        List<OfferDetail> offers = [];
        for (var item in jsonResponse) {
          offers.add(OfferDetail.fromJson(item));
        }
        return offers;
      } else {
        throw Exception('Failed to load offers');
      }
    } catch (e, stacktrace) {
      if (e is SocketException) {
        CustomAlertDialog.attractivepopup(
            context, 'Poor internet connectivity, please try again later!');
      }
      print('Failed to send data $e $stacktrace');
      throw Exception('Failed to send data $e $stacktrace');
    }
  }


  // Sample data for line 2
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMMM').format(DateTime.now());
    return Scaffold(
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
        title: Center(
          child: Text('Reward Details', style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Adjust size as needed
            // Add other styling properties as needed
          ),),
        ),
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
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            Padding(
              padding: const EdgeInsets.only(bottom: 28.0),
              child: FutureBuilder<List<OfferDetail>>(
                future: futureOffers,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No offers found'));
                  } else {
                    return SingleChildScrollView(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height*1.5, // Set a fixed height or any height you deem appropriate
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final offerDetail = snapshot.data![index];
                            final offer = offerDetail.offer;
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 18),
                              child: Card(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                            child: Text(
                                              offer.title,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                            child: Text(
                                              offer.description,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(5.0),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                // Navigator.push(
                                                //   context,
                                                //   MaterialPageRoute(builder: (context) => RewardSpecs(offer_id: offerDetail.id)),
                                                // );
                                              },
                                              child: Text('Know Status',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12),),
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor: Colors.deepPurple,
                                                padding: EdgeInsets.all(10),
                                                minimumSize: Size(80, 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(26),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Image on the right side
                                    if (offer?.image != null)
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.network(
                                          '${ApiProvider.baseUrl}${offer!.image}',
                                          width: 30, // Set the desired width
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );


                          },
                        ),
                      ),
                    );
                  }
                },
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
