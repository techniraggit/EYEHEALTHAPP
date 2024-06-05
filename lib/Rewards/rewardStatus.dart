import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_new/api/config.dart';
import 'package:project_new/main.dart';
import 'package:project_new/Rewards/rewards_sync.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Custom_navbar/bottom_navbar.dart';
import '../HomePage.dart';
import '../Custom_navbar/customDialog.dart'; // Import intl package
class OfferDetail {
  final String id;
  final String offerId;
  final String title;
  final String image;
  final String description;
  final String status;
  final String redeemedOn;
  final String address;

  OfferDetail({
    required this.id,
    required this.offerId,
    required this.title,
    required this.image,
    required this.description,
    required this.status,
    required this.redeemedOn,
    required this.address,
  });

  factory OfferDetail.fromJson(Map<String, dynamic> json) {
    return OfferDetail(
      id: json['id'],
      offerId: json['offer']['offer_id'],
      title: json['offer']['title'],
      image: json['offer']['image'],
      description: json['offer']['description'],
      status: json['status'],
      redeemedOn: json['redeemed_on'],
      address: json['address'] ?? '', // Handle null case for address
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
      print('Failed to send data $e $stacktrace');
      throw Exception('Failed to send data $e $stacktrace');
    }}
  // Sample data for line 2
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMMM').format(DateTime.now());
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding:  EdgeInsets.all(8.0), // Add padding
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
                    padding:  EdgeInsets.all(8.0), // Add padding for the icon
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
      body: Column(
          children: <Widget>[
          FutureBuilder<List<OfferDetail>>(
          future: futureOffers,
          builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
          );
          }
          else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
          }
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No offers found'));
          }
          else {
          return Builder(
            builder: (context) {
                 print("data=lenght=${snapshot.data!.length}");
                 return Expanded(
                   child: ListView.builder(
                   shrinkWrap: true, // Add this line to prevent the ListView from taking more space than necessary
                   itemCount: snapshot.data?.length,
                   itemBuilder: (context, index) {
                   final offerDetail = snapshot.data![index];
                   return Padding(
                   padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 18),
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
                   offerDetail.title,
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
                   offerDetail.description,
                   style: TextStyle(
                   fontSize: 12,
                   fontWeight: FontWeight.w400,
                   color: Colors.grey,
                   ),
                   ),
                   ),
                   Row(
                   children: [
                   Padding(
                   padding: EdgeInsets.all(5.0),
                   child: ElevatedButton(
                   onPressed: () {
                   // Handle button press
                   },
                   child: Text('${offerDetail.status.capitalize()}', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
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
                   SizedBox(width: 20,),
                   Padding(
                   padding: EdgeInsets.all(5.0),
                   child: SizedBox(
                   child: Text('Redeemed On : ${offerDetail.redeemedOn.substring(0,10)}', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
                   ),
                   ),
                   ],
                   ),
                   ],
                   ),
                   ),
                   // Image on the right side
                   if (offerDetail.image != null)
                   Padding(
                   padding:  EdgeInsets.all(3.0),
                   child: Image.network(
                   '${ApiProvider.baseUrl}${offerDetail.image}',
                   width: 30,
                   fit: BoxFit.cover,
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
          );
          }
          },
          ),
          ],
          ),



    bottomNavigationBar:
      CustomBottomAppBar(),
    );
  }
}
