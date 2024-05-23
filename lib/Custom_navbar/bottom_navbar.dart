import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_new/user_profile.dart';

import '../notification/notification_dashboard.dart';
import '../rewards_sync.dart';

// class CustomBottomAppBar extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BottomAppBar(
//       color: Colors.white,
//
//       child: Stack(
//
//         alignment: Alignment.center,
//         children: [
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(12)),
//             child: Container(
//               width: double.infinity,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   Column(
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             CupertinoPageRoute(
//                                 builder: (context) =>NotificationSideBar(
//                                   onNotificationUpdate: () {
//                                     // setState(() {
//                                     //   if (isReadFalseCount != null) {
//                                     //     if (isReadFalseCount! > 0) {
//                                     //       isReadFalseCount = isReadFalseCount! - 1;
//                                     //     }
//                                     //   }
//                                     // });
//                                   },
//                                 ),),
//                           );                        },
//                         child: Image.asset(
//                           'assets/reports.png',
//                           width: MediaQuery.of(context).size.width / 13,
//                         ),
//                       ),
//                       const Text(
//                         "Report",
//                         style: TextStyle(
//                           fontWeight: FontWeight.w400,
//                           fontSize: 12,
//                           color: Colors.grey,
//                         ),
//                       )
//                     ],
//                   ),
//                   Column(
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//
//                                                   },
//                         child: Image.asset(
//                           'assets/health.png',
//                           width: MediaQuery.of(context).size.width / 13,
//                         ),
//                       ),
//                       const Text(
//                         "Health",
//                         style: TextStyle(
//                           fontWeight: FontWeight.w400,
//                           fontSize: 12,
//                           color: Colors.grey,
//                         ),
//                       )
//                     ],
//                   ),
//                   SizedBox(
//                     width: MediaQuery.of(context).size.width / 12,
//                   ),
//                   Column(
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             CupertinoPageRoute(
//                                 builder: (context) => const RewardContact()),
//                           );
//                        },
//                         child: Image.asset(
//                           'assets/rewards.png',
//                           width: MediaQuery.of(context).size.width / 13,
//                         ),
//                       ),
//                       const Text(
//                         "Rewards",
//                         style: TextStyle(
//                           fontWeight: FontWeight.w400,
//                           fontSize: 12,
//                           color: Colors.grey,
//                         ),
//                       )
//                     ],
//                   ),
//                   Column(
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             CupertinoPageRoute(
//                                 builder: (context) =>  UserProfile()),
//                           );                        },
//                         child: Image.asset(
//                           'assets/account.png',
//                           width: MediaQuery.of(context).size.width / 13,
//                         ),
//                       ),
//                       const Text(
//                         "Account",
//                         style: TextStyle(
//                           fontWeight: FontWeight.w400,
//                           fontSize: 12,
//                           color: Colors.grey,
//                         ),
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
class CustomBottomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65.0, // Adjust the height here
      color: Colors.white70, // Set the background color
      child: BottomAppBar(
        color: Colors.transparent, // Make the BottomAppBar transparent
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
                              context,
                              CupertinoPageRoute(
                                builder: (context) => NotificationSideBar(
                                  onNotificationUpdate: () {},
                                ),
                              ),
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
                          onTap: () {},
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
                                  builder: (context) => const RewardContact()),
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
                                  builder: (context) =>  UserProfile()),
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
