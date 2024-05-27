
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Custom_navbar/bottom_navbar.dart';
import 'HomePage.dart';

class KnowStatus extends StatefulWidget {
  @override
  KnowStatus_ createState() => KnowStatus_();
}

class KnowStatus_ extends State<KnowStatus> {
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
        title: Text('Reward details',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
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
          children: <Widget>[




          ],
        ),

      ),

      bottomNavigationBar:
      CustomBottomAppBar(),
    );


  }










}