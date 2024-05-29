
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_new/rewardStatus.dart';

import 'Custom_navbar/bottom_navbar.dart';
import 'HomePage.dart';

class RedeemSuccessPage extends StatefulWidget {
  @override
  RedeemSuccess createState() => RedeemSuccess();
}

class RedeemSuccess extends State<RedeemSuccessPage> {
  bool isActivePlan=false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Confirmation',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Add your back button functionality here
          },
        ),
      ),
      body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0,vertical: 10),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 50), // Add some space between the image and text

                  Image.asset(
                    'assets/redeem_success.png', // Replace 'your_image.png' with your image path
                    width: 200, // Adjust the width as needed
                    height: 200, // Adjust the height as needed
                  ),
                  SizedBox(height: 20), // Add some space between the image and text
                  Text(
                    'We have recvied your request',
                    style: TextStyle(
                      fontSize: 20,color: Colors.background,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20), // Add some space between the image and text
                  Text(
                    'Our representative will connect with you within 3-5 working days to arrange for your reward to be sent to the mailing address you provided.',
                    style: TextStyle(
                      fontSize: 13,color: Colors.greytext.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
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

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => RewardStatusScreen()),
                          );

                        },
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all<double>(
                              0), // Set elevation to 0 to remove shadow

                          backgroundColor:
                          MaterialStateProperty.all<Color>(Colors
                              .background), // Set your desired background color here
                        ),
                        child: const Text('Know the status',
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
      bottomNavigationBar:
      CustomBottomAppBar(),
    );
  }










}