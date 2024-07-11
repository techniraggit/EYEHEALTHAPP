import 'dart:convert';

import 'package:action_broadcast/action_broadcast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:second_eye/sign_up.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/config.dart';
import 'notification_model.dart';


class NotificationSideBar extends StatefulWidget {
  const NotificationSideBar({Key? key, required this.onNotificationUpdate}) : super(key: key);

  final Function() onNotificationUpdate;

  @override
  State<NotificationSideBar> createState() => _NotificationSideBarState();
}

class _NotificationSideBarState extends State<NotificationSideBar> {
  NotificationModel? notificationModel;
  int? isReadFalseCount1 = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override

  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width * 0.75,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(12.0,30,2,2),
                    child: Text(
                      'NOTIFICATIONS',
                      style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: Colors.background),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(2.0,30,2,2),
                    child: ElevatedButton(
                      onPressed: _makeAllRead, // Call _makeAPICall function when button is pressed
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(1.0), // Adjust padding as needed
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Adjust border radius as needed
                        ),
                      ),
                      child: Text('Read all'),
                    ),
                  )
                  ,
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2.0,30,2,2),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          Navigator.of(context).pop([0]);
                        });
                        // Add functionality to close the UI
                      },
                    ),
                  ),
                ],
              ),
              Expanded(
                child: notificationModel == null
                    ? const Center(
                  child: CircularProgressIndicator(),
                )
                    : (notificationModel!.data == null ||
                    notificationModel!.data!.isEmpty)
                    ?  Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/notification_icon.png', // Replace this with your image path
                        width:MediaQuery.of(context).size.width,
                      ),
                  SizedBox(height: 10,),
                  Text(
                      'No Notifications Yet',
                      style: TextStyle(color: Colors.background,fontSize: 14,fontWeight: FontWeight.w600),
                    ),
                      SizedBox(height: 10,),

                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'You have no notifications right now. Come back later',
                          style: TextStyle(color: Colors.grey,fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  // Text(
                  //   'No notification found',
                  //   style: TextStyle(color: Colors.black),
                  // ),
                )
                    : ListView.builder(
                  itemCount: notificationModel!.data!.length,
                  itemBuilder: (context, index) {
                    return notificationCard(
                      notificationModel!.data![index],
                          () {
                        notificationModel!.data![index].isExpanded =
                        !notificationModel!.data![index].isExpanded;
                        setState(() {});
                      },
                      index,
                    );
                  },
                ),
              ),
              SizedBox(height: 80,)

            ],
          ),
        ),
      ],
    );
  }


  Widget notificationCard(NotificationData? notificationData, Function onPressed,int position) {
    return
      // Container(
      // margin: const EdgeInsets.all(10),
      // decoration: BoxDecoration(
      //     color: Colors.white.withOpacity(0.05),
      //     border: notificationData!.isRead! ? Border.all(
      //       color: Colors.background.withOpacity(0.5),
      //       width:  0.6,
      //     ) : Border.all(
      //       color: Colors.grey,
      //       width:  0.6,
      //     ),
      //     borderRadius: BorderRadius.circular(12)
      // ),
      // child:
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            GestureDetector(
              onTap: (){
                if(!notificationData!.isRead!) {

                  widget.onNotificationUpdate();
                  String id=notificationData.id!;
                  print("JHGNVm${id}");
                  updateNotificationStatus(
                      id, position);
                }
              },
              child: Material(
                color: Colors.white,
                elevation: 5,borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding:  EdgeInsets.only(bottom: 6.0,left: 4,right: 4),
                  child: ListTile(
                    leading: Icon(
                      Icons.message, // Replace with your desired icon
                      color: Colors.blue, // Replace with your desired color
                    ),
                      title: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${notificationData?.title}',
                              style: const TextStyle(
                                fontSize: 16, // Example font size
                                fontWeight: FontWeight.bold, // Example font weight for the first part
                                color: Colors.black, // Example text color
                              ),
                            ),
                        // notificationData!.isRead! ? Border.all(
                          //       color: Colors.background.withOpacity(0.5),
                          //       width:  0.6,
                          //     ) : Border.all(
                          //       color: Colors.grey,
                          //       width:  0.6,
                          //     ),
                            TextSpan(
                              text: '\n${notificationData?.message!}',
                              //'\n${getTimeDifference(notificationData.created ?? '')}' ?? 'No title',
                              style:  TextStyle(
                                fontSize: 16, // Example font size
                                color:notificationData!.isRead! ?  Colors.black45:Colors.background.withOpacity(0.4), // Example text color
                              ),
                            ),
                          ],
                        ),
                      ),
                      // trailing: IconButton(
                      //   icon: Icon(notificationData.isExpanded ? Icons.expand_less : Icons
                      //       .expand_more),
                      //   onPressed: () {
                      //     onPressed();
                      //     if(!notificationData.isRead!) {
                      //
                      //       widget.onNotificationUpdate();
                      //       String id=notificationData.id!;
                      //       print("JHGNVm${id}");
                      //       updateNotificationStatus(
                      //           id, position);
                      //     }
                      //   },
                      // )


                  ),
                ),
              ),
            ),
            // if (notificationData.isExpanded && notificationData.message !=
            //     null ) // if (_expanded && widget.data.data != null && widget.data.data!.isNotEmpty) {
            //   Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //     child: Text(notificationData.message!),
            //   ),
            // const SizedBox(
            //   height: 15,
            // ),
          ],
        ),
      );
    // );
  }






  String getTimeDifference(String dateString) {
    // Parse the provided date string
    DateTime date = DateTime.parse(dateString);

    // Calculate the time difference
    Duration difference = DateTime.now().difference(date);

    // Convert the time difference to a human-readable format
    if (difference.inSeconds < 60) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} minutes ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hours ago";
    } else if (difference.inDays < 4) {
      return "${difference.inDays} days ago";
    } else {
      // If more than a week, return the actual date
      return DateFormat.yMMMd().format(date);
    }
  }
  Future<void> fetchData() async {
    // try {
      String userToken = '';
      var sharedPref = await SharedPreferences.getInstance();
      userToken = sharedPref.getString("access_token") ?? '';
      Map<String, String> headers = {
        'Authorization': 'Bearer $userToken', // Bearer token type
        'Content-Type': 'application/json',
      };
      final response = await http.get(
        Uri.parse('${ApiProvider.baseUrl}${ApiProvider.get_notification}'),
        headers: headers,
      );
      print("statusCode================${response.body}");
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        notificationModel = NotificationModel.fromJson(responseData);
        isReadFalseCount1 = notificationModel?.isReadFalseCount;

        // print("kjuhygfcvbb" + isReadFalseCount1.toString());

        setState(() {});
      }
      else if (response.statusCode == 401) {

        Fluttertoast.showToast(msg: "Session Expired");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      } else {
        throw Exception('Failed to load data');
      }
    }
  //   on DioError catch (e) {
  //     if (e.response != null || e.response!.statusCode == 401) {
  //       // Handle 401 error
  //
  //       Fluttertoast.showToast(msg: "Session Expired");
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => SignIn()),
  //       );
  //     }
  //
  //     else {
  //       // Handle other Dio errors
  //       print("DioError: ${e.error}");
  //     }
  //   // } catch (e) {
  //   //   // Handle other exceptions
  //   //   print("Exception---: $e");
  //   // }
  // }
  Future<void> updateNotificationStatus(String id, int position) async {
    print("kjhgfc" + id.toString());
    notificationModel!.data![position].isRead = true;
    setState(() {});

    String userToken = '';
    var sharedPref = await SharedPreferences.getInstance();
    userToken = sharedPref.getString("access_token") ?? '';

    Map<String, String> headers = {
      'Authorization': 'Bearer $userToken',
      'Content-Type': 'application/json',
    };

    final url = '${ApiProvider.baseUrl}${ApiProvider.update_notification_status}';
    print('URL: $url');

    Map<String, dynamic> requestBody = {
      "id": id.toString(), // Convert id to String
    };

    final response = await http.put(
      Uri.parse(url),
      body: jsonEncode(requestBody),
      headers: headers,
    );
    sendBroadcast('actionMusicPlaying');

    print("okijuhgfc" + response.body);
  }
  Future<void> _makeAllRead() async {
    String userToken = '';
    var sharedPref = await SharedPreferences.getInstance();
    userToken = sharedPref.getString("access_token") ?? '';

    Map<String, String> headers = {
      'Authorization': 'Bearer $userToken',
      'Content-Type': 'application/json',
    };
    // Replace 'your_api_endpoint' with your actual API endpoint
    var url = Uri.parse('${ApiProvider.baseUrl}${ApiProvider.update_notification_status}');

    // Make GET request
    var response = await http.patch(url,headers: headers);

    // Check if request was successful
    if (response.statusCode == 200) {

      for(int i=0;i<notificationModel!.data!.length  ;i++){
        notificationModel!.data![i].isRead = true;
      }
      setState(() {

        sendBroadcast('actionMusicPlaying');
        widget.onNotificationUpdate();

        isReadFalseCount1=0;

      });
      // API call successful
      print('API call successful${response.body}');
      // You can handle the response data here
    } else {
      // API call failed
      print('Failed to make API call');
      // You can handle errors here
    }
  }

}