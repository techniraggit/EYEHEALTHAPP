import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_new/ReportPage.dart';
import 'package:project_new/eyeHealthTrack.dart';
import 'package:project_new/rewards.dart';
import 'package:project_new/user_profile.dart';

import '../notification/notification_dashboard.dart';
import '../profileDashboard.dart';
import '../rewards_sync.dart';


class CustomBottomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65.0, // Adjust the height here
      color: Colors.white70, // Set the background color
      child: BottomAppBar(
        color: Colors.white.withOpacity(0.9), // Make the BottomAppBar transparent
        elevation: 0, // Remove any shadow

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
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context, CupertinoPageRoute(
                              builder: (context) => ReportPage(
                              ),
                            ),
                              // CupertinoPageRoute(
                              //   builder: (context) => NotificationSideBar(
                              //     onNotificationUpdate: () {},
                              //   ),
                              // ),
                            );
                          },
                          child: Image.asset(
                            'assets/reports.png',
                            width: MediaQuery.of(context).size.width / 15,
                          ),
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
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context, CupertinoPageRoute(
                              builder: (context) => EyeHealthTrackDashboard(
                              ),
                            ),

                            );
                          },
                          child: Image.asset(
                            'assets/health.png',
                            width: MediaQuery.of(context).size.width / 15,
                          ),
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 12,
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) =>  RewardsScreen()),
                            );
                          },
                          child: Image.asset(
                            'assets/rewards.png',
                            width: MediaQuery.of(context).size.width / 15,
                          ),
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
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) =>  UserDashboard()),
                            );
                          },
                          child: Image.asset(
                            'assets/account.png',
                            width: MediaQuery.of(context).size.width / 15,
                          ),
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
