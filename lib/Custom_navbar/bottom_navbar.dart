import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:second_eye/eyeFatigueTest/ReportPage.dart';
import 'package:second_eye/eyeHealthTrack.dart';
import 'package:second_eye/Rewards/rewards.dart';
import 'package:second_eye/profile/user_profile.dart';

import '../notification/notification_dashboard.dart';
import '../profile/profileDashboard.dart';
import '../Rewards/rewards_sync.dart';


class CustomBottomAppBar extends StatelessWidget {
  final String currentScreen;

  CustomBottomAppBar({required this.currentScreen});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white70,
      child: BottomAppBar(
        color: Colors.white.withOpacity(0.9), // Make the BottomAppBar transparent
        elevation: 0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12)),
              child: Container(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (currentScreen != "ReportPage"){

                          Navigator.push(
                            context, CupertinoPageRoute(
                            builder: (context) => ReportPage(
                            ),
                          ),

                          );}
                      },

                      child: Column(
                        children: [
                          Image.asset(
                            'assets/report.png',
                            width: MediaQuery.of(context).size.width / 17,
                          ),
                          const Text(
                            "Report",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (currentScreen != "EyeHealth"){

                          Navigator.push(
                            context, CupertinoPageRoute(
                            builder: (context) => EyeHealthTrackDashboard(
                            ),
                          ),

                          );}
                      },
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/health.png',
                            width: MediaQuery.of(context).size.width / 17,
                          ),
                          const Text(
                            "Health",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 16,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (currentScreen != "Rewards"){
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) =>  RewardsScreen()),
                          );}
                      },                      child: Column(
                        children: [
                          Image.asset(
                            'assets/rewards.png',
                            width: MediaQuery.of(context).size.width / 17,
                          ),
                          const Text(
                            "Rewards",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {

                        if (currentScreen != "ProfileDashboard")
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) =>  UserDashboard()),
                          );
                      },                      child: Column(
                        children: [
                          Image.asset(
                            'assets/user.png',
                            width: MediaQuery.of(context).size.width / 16,
                          ),
                          const Text(
                            "Account",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
