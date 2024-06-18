// ignore_for_file: use_build_context_synchronously, avoid_print, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
//import 'package:flutter_sms/flutter_sms.dart';

import 'package:contacts_service/contacts_service.dart';
// import 'package:flutter_contacts/flutter_contacts.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_new/Rewards/redeem_sucess.dart';
import 'package:project_new/models/OfferData.dart';
import 'package:project_new/models/address_list.dart';
import 'package:project_new/sign_up.dart';
import 'package:rename/platform_file_editors/abs_platform_file_editor.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Custom_navbar/bottom_navbar.dart';
import '../HomePage.dart';
import '../api/Api.dart';
import '../api/config.dart';
import '../digitalEyeTest/testScreen.dart';
import '../eyeFatigueTest/eyeFatigueTest.dart';
import 'new_address_screen.dart';

class RewardContact extends StatefulWidget {
  const RewardContact({super.key});

  @override
  _RewardsContactsSync createState() => _RewardsContactsSync();
}

class _RewardsContactsSync extends State<RewardContact> {
  int points = 10;
  int totalPoints = 100;
  final String appStoreLink = 'https://yourappstorelink.com';

  List<Contact> _contacts = [];
  String? ReferCode = "";
  bool _permissionDenied = false;
  final Map<int, bool> _invitationStatus = {};
  final Map<int, bool> condition = {};
  List<dynamic> _refferconatcts = [];
  bool sendDirect = false; String? _message;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getReferCode();
    _fetchContacts();
    getMyRefferConatcts();
  }


  void shareAppLink(int i) async {
    try {
      // File imageFile = File('assets/banner1.png'); // Replace 'assets/image.png' with the path to your image file
      //
      // // Resize the image to reduce its size (optional)
      // File resizedImage = await FlutterNativeImage.compressImage(
      //   imageFile.path,
      //   quality: 70, // Adjust the quality as needed
      //   percentage: 50, // Adjust the percentage as needed
      // );
      // await Share.shareFiles(
      //   [resizedImage.path],
      //   text: 'Check out our awesome app: $appStoreLink\n'
      //       'Use Referral Code: $ReferCode',
      //   subject: 'Check out our awesome app',
      // );
      Directory tempDir = await getTemporaryDirectory();

      // Prepare the image file path in the temporary directory
      String imagePath = '${tempDir.path}/banner1.png'; // Adjust the file name as needed

      // Check if the image file already exists in the temporary directory
      bool fileExists = await File(imagePath).exists();
      if (!fileExists) {
        // Image file doesn't exist, so we need to copy it from the assets to the temporary directory
        ByteData imageData = await rootBundle.load('assets/banner1.png'); // Replace 'banner1.png' with your image asset path
        List<int> bytes = imageData.buffer.asUint8List();
        await File(imagePath).writeAsBytes(bytes);
      }

      // Share the app link along with the image and other details
      await Share.shareFiles(
        [imagePath],
        text: 'Check out our awesome app: $appStoreLink\nUse Referral Code: $ReferCode',
        subject: 'Check out our awesome app',
      );
      setState(() {
        _invitationStatus[i] = !(_invitationStatus[i] ?? false);
      });
    } catch (e) {
      print("88888888888888$e");
      // If there's an error during sharing, handle it
      // Set _invitationStatus to false to indicate failure
      setState(() {
        _invitationStatus[i] = false;
      });

      // Show a SnackBar to inform the user about the failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share the app.'),
        ),
      );

      // Revert the state change if sharing fails
      _invitationStatus[i] = !(_invitationStatus[i] ?? false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return

      DefaultTabController(
        length: 2,
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation
              .centerDocked,
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
                      builder: (context) =>
                          HomePage(
                          ),
                    ),

                    );
                  },
                  child: SizedBox(
                    width: 53.0, // Width of the FloatingActionButton
                    height: 50.0, // Height of the FloatingActionButton
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        // Add padding for the icon
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
          // appBar: PreferredSize(
          //   preferredSize: const Size.fromHeight(10),
          //   child: AppBar(
          //     backgroundColor:
          //     Colors.white, // Set app bar background color to white
          //     elevation: 0, // Remove app bar shadow
          //     // Add any other app bar properties as needed
          //   ),
          // ),

          body: Column(
            children: [

              Stack(
                children: [
                  Container(
                    height: 125,
                    // width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            "assets/rewards_back.png"),
                        // Add your background image path
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 110,
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 15),

                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            iconSize: 28, // Back button icon
                            onPressed: () {
                              Navigator.pop(context);
                              // Navigator.push(
                              //   context,
                              //   CupertinoPageRoute(
                              //       builder: (context) =>  RewardSpecs()),
                              // );
                              // Navigator.of(context).pop();
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Invite a friend and get ',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return const RadialGradient(
                                        radius: 1.0,
                                        colors: [
                                          Color(0xFFFFF400),
                                          Color(0xFFFFE800),
                                          Color(0xFFFFCA00),
                                          Color(0xFFFF9A00),
                                          Color(0xFFFF9800),
                                        ],
                                      ).createShader(bounds);
                                    },
                                    child: Text(
                                      ' $points ',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors
                                            .white, // Specify a color for the text
                                      ),
                                    ),
                                  ),
                                ),
                                const TextSpan(
                                  text: ' Points',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Add more Text widgets as needed
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.center,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [
                        Colors.bluegradient,
                        Colors.greengradient
                      ], // Your gradient colors
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds);
                  },
                  child: Text(
                    '$totalPoints',
                    style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              const Align(
                alignment: Alignment.center,
                child: Text(
                  'Total Point Earned Till Now',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w400),
                ),
              ),
              const SizedBox(
                height: 35,
              ),

              if (ReferCode!.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    Share.share(ReferCode!);

                    // Your action when clicking on the left end or center
                  },
                  child: Container(
                    height: 44,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width /
                        2.2, // Set a width for the container
                    child: Stack(
                      children: [
                        // Image widget as the background
                        Center(
                          child: Image.asset(
                            'assets/referoutline.png',
                            // Replace with your image asset path
                            width: MediaQuery
                                .of(context)
                                .size
                                .width /
                                1.5,
                            // Set a width for the container
                            // height: 65, // Set height to match container height
                            fit: BoxFit.fill,
                          ),
                        ),
                        // Text overlay
                        Positioned(
                          bottom: 10,
                          left: 15,
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                colors: [
                                  Colors.bluegradient,
                                  Colors.greengradient
                                ], // Your gradient colors
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ).createShader(bounds);
                            },
                            child: GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: ReferCode! ?? ""));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                    Text('Referral code copied to clipboard'),
                                  ),
                                );
                              },
                              child: Text(
                                ReferCode!,
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 27),
                child: SizedBox(
                  height: 45,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors
                          .background, // Set your desired background color here
                      // You can also customize other button properties here if needed
                    ),
                    onPressed: () async {
                      await [Permission.contacts].request();
                      await [Permission.sms].request();

                      requestSmsPermission();




                      // Call the method here

                      // Share.share(
                      //   'Hi , I am using the Zukti eye health app to track my eye health. Why dont you join me and together we can work towards improving our eye health? Use my code to sign up and get a one-month subscription free.',
                      //   // $appStoreLink Use Referal Code $ReferCode',
                      //   subject: 'Share via WhatsApp',
                      //   sharePositionOrigin: Rect.fromLTRB(0, 0, 0, 0),
                      // );




                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Invite Via SMS ',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(
                          width: 9,
                        ),
                        Icon(
                          Icons.sms,
                          size: 19,
                          color: Colors.white70,
                        ),// Add your icon here
                      ],
                    ),
                  ),
                ),
              ),


              PreferredSize(
                preferredSize:
                Size.fromHeight(MediaQuery
                    .of(context)
                    .size
                    .height / 2),
                child: TabBar(
                  isScrollable: false,
                  tabs: [
                    Tab(text: 'Contacts'),
                    Tab(text: 'Joined'),
                  ],
                ),
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    Center(
                        child: _contacts.isNotEmpty
                            ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: _contacts.length,
                          itemBuilder: (context, i) =>
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  color: Colors.white,
                                  elevation: 0.9,
                                  child: ListTile(
                                    leading: _contacts[i].avatar != null &&
                                        _contacts[i].avatar!.isNotEmpty
                                        ? Container(
                                        height: 50,
                                        width: 50,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle),
                                        child: Image.memory(
                                            _contacts[i].avatar!))
                                        : Container(
                                        height: 50,
                                        width: 50,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle),
                                        child: Image.asset(
                                            'assets/contact.png')),

                                    title: Text(
                                      _contacts[i].displayName ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                          color: Colors.black),
                                    ),
                                    subtitle: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '+91 ${_contacts[i].phones!.isNotEmpty
                                              ? _contacts[i].phones!.first.value
                                              : 'N/A'}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              color: Color(0xFF667085)),
                                        ),
                                        const Spacer(),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              // if(  _invitationStatus[i] ==false){
                                              print(
                                                  "===${_invitationStatus[i]
                                                      .toString()}");
                                              // _invitationStatus[i] =
                                              //     !(_invitationStatus[i] ?? false);
                                              shareAppLink(i);
                                              // }
                                            });
                                          },
                                          child: _invitationStatus[i] == true
                                              ? Container(
                                              decoration: BoxDecoration(
                                                color: Colors
                                                    .green,
                                                // Green background color
                                                borderRadius:
                                                BorderRadius.circular(
                                                    20), // Rounded border
                                              ),
                                              child: const Icon(
                                                  Icons.check,
                                                  color: Colors
                                                      .white)) // Display verified icon
                                              : const Text(
                                            'INVITE',
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight.w400,
                                                fontSize: 14,
                                                color:
                                                Color(0xFF667085)),
                                          ), // Display "INVITE" text
                                        ),
                                      ],
                                    ),
                                    onTap: () async {

                                    },
                                  ),
                                ),
                              ),
                        )
                            : Container(
                          // Set constraints, width, height, etc. for the Container
                          child: Center(
                            child: Text(
                              'Sync Contacts to see contact list here',
                              textAlign: TextAlign.center,
                              // You can specify other text properties here like style, fontSize, etc.
                            ),
                          ),
                        )

                      // if (_permissionDenied)
                      //   const Center(child: Text('Permission denied')),
                      // if (_contacts != null) ...{

                    ),


                    Center(
                        child: _refferconatcts.isNotEmpty
                            ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: _refferconatcts.length,
                          itemBuilder: (context, i) =>
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  color: Colors.white,
                                  elevation: 0.9,
                                  child: ListTile(
                                    leading:

                                    Container(
                                        height: 50,
                                        width: 50,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle),
                                        child: Image.asset(
                                            'assets/contact.png')),

                                    title: Text(
                                      _refferconatcts[i]['full_name'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                          color: Colors.black),
                                    ),
                                    subtitle: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '+91 ${ _refferconatcts[i]['phone']}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              color: Color(0xFF667085)),
                                        ),
                                        const Spacer(),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors
                                                .green.withOpacity(0.5),
                                            // Green background color
                                            borderRadius:
                                            BorderRadius.circular(
                                                20), // Rounded border
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              'Accepted',
                                              style: TextStyle(
                                                  fontWeight:
                                                  FontWeight.w400,
                                                  fontSize: 14,
                                                  color:
                                                  Color(0xFF667085)),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    onTap: () async {},
                                  ),
                                ),
                              ),
                        )
                            : Container()
                      // if (_permissionDenied)
                      //   const Center(child: Text('Permission denied')),
                      // if (_contacts != null) ...{

                    ),
                    // Content of Tab 2


                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar:
          CustomBottomAppBar(currentScreen: "Rewards"),    )

      );
  }





  Future<List<String>> _getContactNumbers() async {
    List<String> numbers = [];
    Iterable<Contact> contacts = await ContactsService.getContacts();
    for (var contact in contacts) {
      for (var phone in contact.phones!) {
        numbers.add(phone.value!.replaceAll(RegExp(r'\D'), ''));
      }
    }
    return numbers;
  }
  void requestSmsPermission() async {
    PermissionStatus status = await Permission.sms.status;
    PermissionStatus status1 = await Permission.contacts.status;

    if (!status.isGranted ) {
      status = await Permission.sms.request();
    }
    if (!status1.isGranted ) {
      status1 = await Permission.contacts.request();
    }
    if (status == PermissionStatus.denied ||
        status == PermissionStatus.permanentlyDenied) {
      await [Permission.sms].request();

      // Permissions are denied or denied forever, let's request it!
      status =  await Permission.sms.status;
      if (status == PermissionStatus.denied) {
        await [Permission.sms].request();
        print("Location permissions are still denied");
      } else if (status ==PermissionStatus.permanentlyDenied) {
        print("Location permissions are permanently denied");
        // Prompt the user to open app settings to enable location permissions manually
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("SMS permissions required"),
              content: Text("SMS permissions are permanently denied. Please go to app settings to enable location permissions."),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .background, // Set your desired background color here
                    // You can also customize other button properties here if needed
                  ),
                  onPressed: () async {
                    Navigator.pop(context); // Close the dialog
                    await openAppSettings();
                  },
                  child: Text("OK",

                    style: TextStyle(
                        color: Colors.white, fontSize: 16),
                  ),
                ),

              ],
            );
          },
        );
      } else {
        // Permissions are granted (either whileInUse, always, restricted).

        print("SMS permissions are granted after requesting");
      }
    }
    if (status1 == PermissionStatus.denied ||
        status1 == PermissionStatus.permanentlyDenied) {
      await [Permission.contacts].request();

      // Permissions are denied or denied forever, let's request it!
      status1 =  await Permission.contacts.status;
      if (status1 == PermissionStatus.denied) {
        await [Permission.contacts].request();
        print("contacts permissions are still denied");
      }
      else if (status1 ==PermissionStatus.permanentlyDenied) {
        print("contacts permissions are permanently denied");
        // Prompt the user to open app settings to enable location permissions manually
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("contacts permissions required"),
              content: Text("contacts permissions are permanently denied. Please go to app settings to enable location permissions."),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .background, // Set your desired background color here
                    // You can also customize other button properties here if needed
                  ),
                  onPressed: () async {
                    Navigator.pop(context); // Close the dialog
                    await openAppSettings();
                  },
                  child: Text("OK",

                    style: TextStyle(
                        color: Colors.white, fontSize: 16),
                  ),
                ),

              ],
            );
          },
        );
      } else {
        // Permissions are granted (either whileInUse, always, restricted).

        print("contacts permissions are granted after requesting");
      }
    }



    else if(status1.isGranted && status.isGranted) {
      print("SMS permissions are granted ");
      sendSMSToAllContacts();

    }
  }
  Future<void> sendSMSToAllContacts() async {
    try {
      List<String> allContactNumbers = await _getContactNumbers();
     await _sendSMS(allContactNumbers);
    } catch (error) {
      print("erooooorrrrrrrrrr"+error.toString());
    }
  }

  Future<void> _sendSMS(List<String> recipients) async {
    try {
      String _result = await sendSMS(
        message: 'Hi , I am using the Zukti eye health app to track my eye health. Why dont you join me and together we can work towards improving our eye health? Use my code to sign up and get a one-month subscription free.',
        recipients: recipients,
        sendDirect: sendDirect,
      );
      setState(() => _message = _result);
    } catch (error) {
      setState(() => _message = error.toString());
    }
  }
  Future _fetchContacts() async {
    await [Permission.contacts].request();
    // if (!await FlutterContacts.requestPermission(readonly: true)) {
    setState(() => _permissionDenied = true);
    print("_permissionDenied");
    // } else {
    //   print("_permissionGranted");

    // final contacts = await FlutterContacts.getContacts();
    if (await Permission.contacts.isGranted) {
      List<Contact> contacts = await ContactsService.getContacts();

      setState(() => _contacts = contacts);
      sendContacts();
      // for(int i=0;i<=_contacts.length;i++) {
      //   print("_permissionGranted${_contacts[i].phones?.first
      //       .value?.replaceAll(" ", '')}=========${_contacts[i].displayName}");
      // }
    } else {}

    // }
  }

  Future<Map<String, dynamic>> getReferCode() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('id') ?? '';
      String token =
// "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE2Mjg5OTcxLCJpYXQiOjE3MTYyMDM1NzEsImp0aSI6IjRjMGQwZmNkMGZmNTQ4NWRiNThjODM5YzBjODM0OGU3IiwidXNlcl9pZCI6ImYzNWE2Y2Y2LTA2ODYtNDdhMS05ZTAwLTkzNWQwNWIwMWE3MCJ9.rX_Vcm0Q0DQRmT_4fC8YCRj-gxBHaM5ofYvawiuWl_4";
      prefs.getString('access_token') ?? '';

      print("id :$userId");
      final response = await http.get(
        Uri.parse('${ApiProvider.baseUrl + ApiProvider.getUserProfile}'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );
      print("statusCode================${token}");

      if (response.statusCode == 200) {
        // _progressDialog!.hide();

        final jsonResponse = jsonDecode(response.body);
        setState(() {
          ReferCode = jsonResponse['data']['referral_code'];
        });

        print("responseviewprofile:${response.body}");

        return json.decode(response.body);
      } else {
        // _progressDialog!.hide();

        print(response.body);
      }
    } catch (e) {
      // _progressDialog!.hide();

      print("exception:$e");
    }
    throw Exception('');
  }


  Future<dynamic> getMyRefferConatcts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token =
          prefs.getString('access_token') ?? '';

      final response = await http.get(
        Uri.parse('${ApiProvider.baseUrl + ApiProvider.myReffrealcontacts}'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );
      print("statusCode================${token}");

      if (response.statusCode == 200) {
        // _progressDialog!.hide();

        final jsonResponse = jsonDecode(response.body);
        _refferconatcts = jsonResponse['data'];

        print("responseviewprofile:${response.body}");

        return json.decode(response.body);
      } else {
        // _progressDialog!.hide();

        print(response.body);
      }
    } catch (e) {
      // _progressDialog!.hide();

      print("exception:$e");
    }
    throw Exception('');
  }

  Future<void> sendContacts() async {
    List<Map<String, dynamic>> dataList = [];


    for (var contact in _contacts) {
      Map<String, dynamic> contactData = {}; // Create a map for each contact

      if (contact.displayName != null) {
        contactData["name"] = contact.displayName!;
      }

      int phoneCount = 1;
      Map<String, String> phoneNumbersMap = {
      }; // Change the type to Map<String, String>
      if (contact.phones != null) {
        for (var phone in contact.phones!) {
          String phoneType = phone.label ??
              "Phone"; // Default to "Phone" if label is null
          String phoneNumber = phone.value!.replaceAll(" ", '');
          phoneNumbersMap["$phoneType$phoneCount"] = phoneNumber;
          phoneCount++;
        }
      }
      contactData["phone_numbers"] =
          phoneNumbersMap; // Assign the Map<String, String> to "phone_numbers"

      if (contact.emails != null) {
        List<String> emailsList = [];
        for (var email in contact.emails!) {
          emailsList.add(email.value!);
        }
        contactData["emails"] = emailsList.join(", ");
      }

      if (contact.postalAddresses?.isNotEmpty ?? false) {
        final address = contact.postalAddresses!.first;
        contactData["address"] =
        '${address.street ?? ''}, ${address.city ?? ''}, ${address.postcode ??
            ''}, ${address.country ?? ""}';
      }

      if (contact.avatar != null && contact.avatar!.isNotEmpty) {
        final image = MemoryImage(contact.avatar!);
        // Use the image where needed
      }

      dataList.add(contactData); // Add the contact data map to dataList
    }

    logger.d("object========${dataList.toString()}");

    // Replace with your API endpoint
    String userToken = '';
    var sharedPref = await SharedPreferences.getInstance();
    userToken =
        sharedPref.getString("access_token") ?? '';
    String apiUrl = '${Api
        .baseurl}/api/contact-upload'; // replace with your API endpoint
    String jsonString = json.encode(dataList);

    try {
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $userToken',

        },
        body: jsonString,
      );

      if (response.statusCode == 200) {

        await _sendMessageToAll( 'hello');

        print('Data sent successfully');
      } else {
        print('Failed to send data. Error code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<Contact>> fetchContacts() async {
    // Fetch contacts from the phone's contact list
    Iterable<Contact> contacts = await ContactsService.getContacts();
    return contacts.toList();
  }

  Future<void> _sendMessageToAll( String message) async {
    List<Contact> contacts = await fetchContacts(); // Fetch contacts from the phone's contact list
    for (var contact in contacts) {
      for (var phoneNumber in contact.phones ?? []) {
        if (phoneNumber != null && phoneNumber.isNotEmpty) {
          print("phone-----no-----------$phoneNumber");
          // Construct and send the WhatsApp message
          var whatsappUrl = "whatsapp://send?phone=$phoneNumber&text=$message";
          if (await canLaunch(whatsappUrl)) {
            await launch(whatsappUrl);
          } else {
            throw 'Could not launch $whatsappUrl';
          }
        } else {
          // Handle empty or null phone numbers
          print("Skipping invalid phone number for contact: $contact");
        }
      }

    }


  }









  }

  Future<List<Contact>> fetchContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    return contacts.toList();
  }






// }

class RewardSpecs extends StatefulWidget {
  final String offer_id; // Declare variable to hold received data

  RewardSpecs({required this.offer_id});
  // const RewardSpecs({super.key});

  @override
  RewardSpecsSync createState() => RewardSpecsSync();
}

class RewardSpecsSync extends State<RewardSpecs> {

  int? EyeHealthPoints;
  int? totalPoints;
  OfferData? offerData;
  AddressList? address_list;
  bool isChecked = false;
  SharedPreferences? prefs;
  double? userPercentage;
  bool isReedemButtonEnabled = false; // Set your condition here

  String offer_id =''; //"19225502-2a98-42e4-8744-a0bc0fb1cc01";
  final double _currentTime = 80.0; // Initial time
  int _countdownValue = 0;
  Timer? _timer;

  String? image_url, title, description;
  Color buttonColor = Colors.disablebutton; // Default color
  int? hours, minutes, seconds;
  bool isSelected = false;
  List<bool> isSelectedList = [];
  bool isLoading = true;
  int selectedCount = 0;
  bool selectedCount_=false; int ino=0;
  @override
  void initState() {
    super.initState();
    initSharedPreferences(); // Initialize SharedPreferences when widget is created

    getOffersDetail();
    getAddress();
    _countdownValue = _currentTime.toInt();
    hours = (_currentTime / 3600).floor();
    minutes = ((_currentTime % 3600) / 60).floor();
    seconds = (_currentTime % 60).floor();
    startCountdown();

  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> getOffersDetail() async {
    try {
      offer_id=widget.offer_id;



      String userToken = '';
      var sharedPref = await SharedPreferences.getInstance();
      userToken =
      // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE2MjcyODc2LCJpYXQiOjE3MTYxODY0NzYsImp0aSI6ImYyMjJhM2VlZDNjYTRlZjc4MmNmNmEyNTYzOGQxMmU1IiwidXNlcl9pZCI6IjkxOTNhOTE1LWY5YzItNDQ0MC04MDVlLTQxNDBhYTc5ZDQzOSJ9.2Gj1laeNGLhy0FxYQCQVoB_Idt5W0F0X621BVPtNaic";
      sharedPref.getString("access_token") ?? '';
      sharedPref.setString("offer_id", offer_id);
      Map<String, String> headers = {
        'Authorization': 'Bearer $userToken', // Bearer token type
        'Content-Type': 'application/json',
      };
      final response = await http.get(
        Uri.parse(
            '${ApiProvider.baseUrl}${ApiProvider.getOffers_detail + "?offer_id=$offer_id"}'),
        headers: headers,
      );
      print("statusCode================${response.statusCode}");
      if (response.statusCode == 200) {

        final responseData = json.decode(response.body);
        offerData = OfferData.fromJson(responseData);
        isLoading = false;

        print("statusCode================${offerData?.data?.description}");
        image_url = offerData!.data!.image!;
        EyeHealthPoints = offerData!.userPoints!;
        totalPoints = offerData!.data!.requiredPoints!;
        title = offerData!.data!.title!;
        description = offerData!.data!.description!;

        userPercentage =
            double.tryParse(offerData?.userPercentage.toString() ?? '0.0') ??
                0.0;
        if (userPercentage == 100.0) {
          isReedemButtonEnabled = true;
        } else {
          isReedemButtonEnabled = false;
        }

        setState(() {});
      } else if (response.statusCode == 401) {
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
      } else {
        // Handle other Dio errors
        print("DioError: ${e.error}");
      }
    } catch (e) {
      // Handle other exceptions
      print("Exception---: $e");
    }
  }

  Future<void> getAddress() async {
    try {
      String userToken = '';
      var sharedPref = await SharedPreferences.getInstance();
      userToken =
      // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE2MjcyODc2LCJpYXQiOjE3MTYxODY0NzYsImp0aSI6ImYyMjJhM2VlZDNjYTRlZjc4MmNmNmEyNTYzOGQxMmU1IiwidXNlcl9pZCI6IjkxOTNhOTE1LWY5YzItNDQ0MC04MDVlLTQxNDBhYTc5ZDQzOSJ9.2Gj1laeNGLhy0FxYQCQVoB_Idt5W0F0X621BVPtNaic";
      sharedPref.getString("access_token") ?? '';
      Map<String, String> headers = {
        'Authorization': 'Bearer $userToken', // Bearer token type
      };
      print("statusCode================${userToken}");

      final response = await http.get(
        Uri.parse('${ApiProvider.baseUrl}${ApiProvider.getaddress}'),
        headers: headers,
      );
      print("statusCode================${response.statusCode}");
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        address_list = AddressList.fromJson(responseData);
        print("statusCode================${address_list?.data?[0].isDefault}");

        if(address_list!.data!.isNotEmpty){
          isSelectedList = List.generate(
            address_list?.data?.length ?? 0,
                (_) => false,);
          for(int index=0;index< address_list!.data!.length;index++){
            isSelectedList[index] = address_list?.data?[index].isDefault ?? false;
          }}

        print("statusCode================${address_list?.data?[0].address}");

        setState(() {});
      } else if (response.statusCode == 401) {
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
      } else {
        // Handle other Dio errors
        print("DioError: ${e.error}");
      }
    } catch (e) {
      // Handle other exceptions
      print("Exception---: $e");
    }
  }

  void startCountdown() {
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneSecond, (timer) {
      setState(() {
        if (_countdownValue > 0) {
          _countdownValue--;
        }
        if (_currentTime == 100) {
          buttonColor =
              Colors.background; // Change button color to green when enabled
        }
        hours = (_currentTime / 3600).floor();
        minutes = ((_currentTime % 3600) / 60).floor();
        seconds = (_currentTime % 60).floor();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
      child: CircularProgressIndicator(
        color: Colors.black,
      ),
    )
        :





    MaterialApp(
      home: Scaffold(
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

        // appBar: PreferredSize(
        //   preferredSize: const Size.fromHeight(10),
        //   child: AppBar(
        //     backgroundColor:
        //     Colors.white70, // Set app bar background color to white
        //     elevation: 0, // Remove app bar shadow
        //     // Add any other app bar properties as needed
        //   ),
        // ),
        body: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 125,
                  // width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          "assets/rewards_back.png"), // Add your background image path
                      fit: BoxFit.fill,
                    ),
                  ),
                ),

                SizedBox(
                  height: 110,
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 5),

                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          iconSize: 28, // Back button icon
                          onPressed: () {
                            Navigator.pop(context);

                            // Navigator.of(context).pop();
                          },
                        ),
                      ),
                      const SizedBox(height: 5),
                      Align(
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return const RadialGradient(
                                      radius: 1.0,
                                      colors: [
                                        Color(0xFFFFF400),
                                        Color(0xFFFFE800),
                                        Color(0xFFFFCA00),
                                        Color(0xFFFF9A00),
                                        Color(0xFFFF9800),
                                      ],
                                    ).createShader(bounds);
                                  },
                                  child: Text(
                                    ' $EyeHealthPoints ',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .white, // Specify a color for the text
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(
                                text: 'Eye health points loading ',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Add more Text widgets as needed
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 7,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              colors: [
                                Colors.bluegradient,
                                Colors.greengradient
                              ], // Your gradient colors
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds);
                          },
                          child: Text(
                            '$totalPoints',
                            style: const TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(18.0, 5, 18, 10),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Total Point Earned Till Now',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              image: image_url != null
                                  ? DecorationImage(
                                image: NetworkImage(
                                    "${ApiProvider.baseUrl}$image_url"),
                                // fit: BoxFit.cover,
                              )
                                  : null,
                            ),
                          )),
                      Padding(
                        padding: EdgeInsets.fromLTRB(18.0, 10, 18, 10),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '${title}',
                            // 'Win a cool pair of sunglasses of worth rs 1000 free',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                 /*     Padding(
                        padding: EdgeInsets.fromLTRB(18.0, 10, 18, 10),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '${description}',

                            // 'Such as a new pair of sunglasses for completing 8 eye fatigue tests, in row maximum 4  eye test in you can do in one day ',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.greytext,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),*/
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SliderTheme(
                              data: const SliderThemeData(
                                trackHeight: 8.0, // Increase the slider height
                                thumbColor:
                                Colors.blue, // Set thumb color to blue
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius:
                                    6.0), // Adjust thumb size
                                trackShape:
                                RoundedRectSliderTrackShape(), // Customize track shape
                                overlayShape: RoundSliderOverlayShape(
                                    overlayRadius: 20.0), // Adjust overlay size
                                valueIndicatorShape:
                                PaddleSliderValueIndicatorShape(), // Customize value indicator shape
                                valueIndicatorTextStyle: TextStyle(
                                    color: Colors
                                        .white), // Text style of value indicator
                              ),
                              child: Slider(
                                value: userPercentage ?? 0.0,
                                min: 0.0,
                                max:
                                100.0, // Adjust the max value according to your requirement
                                // divisions: 10,
                                label: '$_currentTime',
                                onChanged:
                                    (_) {}, // Empty function to disable interaction
                                activeColor: const Color(
                                    0xFF8925CD), // Set the color for moved slider to blue
                              ),
                            ),
                            // const SizedBox(
                            //     height: 8), // Add some spacing between icon and text

                            Padding(
                              padding:
                              const EdgeInsets.only(left: 18.0, right: 50),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // const Icon(
                                  //   Icons.watch_later,
                                  //   color: Colors.purple,
                                  // ), // Watch icon
                                  // const SizedBox(
                                  //     width:
                                  //         8), // Add some spacing between icon and text
                                  // Text(
                                  //   '$hours h:${minutes.toString().padLeft(2, '0')} m:${seconds.toString().padLeft(2, '0')} s',
                                  //   style: const TextStyle(
                                  //       fontSize: 16, color: Colors.purple),
                                  // ),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '$userPercentage %',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.purple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            GestureDetector(
                              onTap: () {
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
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(18.0, 10, 18, 10),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.background,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                   /* child: Text(
                                      'Click Here To Start',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.background,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),*/
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            Align(
                              alignment: Alignment.bottomCenter,
                              child: SizedBox(
                                width: 250, // Set the desired width here
                                height: 45,
                                child: GestureDetector(
                                  onTap: isReedemButtonEnabled ? () {
                                    RedeemaddressSheet(context);
                                  } : null,


                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isReedemButtonEnabled
                                          ? Colors.background
                                          : buttonColor, // Change color when disabled
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Redeem',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
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
              ),
            ),
          ],
        ),
        bottomNavigationBar:
        CustomBottomAppBar(currentScreen: "Rewards"),
// Include the persistent bottom bar here
      ),
    );
  }

  void RedeemaddressSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[

                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, top: 10, bottom: 8),
                          child: Text(
                            'Select address',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.background,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.black87,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),

                  //TODO INcorrect Parentage

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: address_list?.data?.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Builder(builder: (context) {
                                //   bool isSelected = address_list?.data?[index].isDefault ?? false;
                                //   return Checkbox(
                                //     value: isSelected,
                                //     onChanged: (newValue) {
                                //       setState(() {
                                //         isSelected = newValue ?? false; // Update the state of isSelected
                                //       });
                                //     },
                                //   );
                                // }),

                                Builder(
                                    builder: (context) {

                                      ino=index;
                                      print("--------${isSelectedList[index]} ");
                                      if(isSelectedList[index]==true){
                                        if(prefs==null){}else{
                                          prefs?.setString('address_id', address_list!.data![ino].addressId!);

                                        }
                                        // address_id
                                        print("selcted_id====inntyyyyn====+${ address_list?.data?[ino].addressId}");
                                      }


                                      for(int i=0;i<address_list!.data!.length;i++){
                                        if(isSelectedList[index]==true){
                                          selectedCount_=true;
                                        }
                                      }



                                      return Checkbox(
                                        value: isSelectedList[index],
                                        onChanged: (newValue) {
                                          // isSelectedList[index] = newValue ?? false;

                                          setState(() {
                                            for (int i = 0; i < isSelectedList.length; i++) {
                                              isSelectedList[i] = (i == index && newValue == true);
                                              if (newValue == true) {
                                                selectedCount++;
                                                selectedCount_=true;
                                                // print("selcted_id========+${ address_list?.data?[i].addressId}");

                                                // Increment count when checkbox is selected
                                              } else {
                                                selectedCount--;
                                                selectedCount_=false;// Decrement count when checkbox is deselected
                                              }

                                            }
                                            if(prefs==null){}else{
                                              prefs?.setString('address_id', address_list!.data![ino].addressId!);

                                            }                                              print("selcted_id====00000====+${ address_list?.data?[ino].addressId}");

                                            // isSelectedList[index] = newValue ?? false;
                                          });




                                        },
                                      );
                                    }
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.background
                                            : Colors.grey,
                                        width: 0.3,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: isSelected
                                          ? Colors.background
                                          : Colors.grey,
                                    ),
                                    child: SizedBox(
                                      height: 25,
                                      width: 59,
                                      child: Center(
                                        child: Text(
                                          '${address_list?.data?[index].addressType}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width /
                                          2.2,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5.0, left: 10, right: 10),
                                        child: Text(
                                          '${address_list?.data?[index].address}  ${address_list?.data?[index].city},  ${address_list?.data?[index].state}, ${address_list?.data?[index].country}, ${address_list?.data?[index].postalCode}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isSelected
                                                ? Colors.background
                                                : Colors.black,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          maxLines: null,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width /
                                          2.2,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5.0, left: 10),
                                        child: Text(
                                          '${address_list?.data?[index].phoneNumber}  ${address_list?.data?[index].email}   ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5.0, left: 10),
                                      child: Text(
                                        '${address_list?.data?[index].state}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  // Handle edit button press
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  Container(
                    padding: EdgeInsets.only(top: 10.0, left: 10),
                    child: Column(
                      children: <Widget>[
                        CheckboxListTile(
                          title: Text(
                            'Billing address same as shipping',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          enabled:selectedCount_ ,
                          value: isChecked,
                          onChanged: (newValue) {
                            setState(() {
                              isChecked = newValue!;

                              if(isChecked==true){


                                callredeemApi();
                                // Navigator.push(context, MaterialPageRoute(
                                //     builder: (context) => RedeemSuccessPage()),
                                // );
                              }

                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewAddressScreen()),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.only(top: 5.0, left: 14),
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NewAddressScreen()),
                              );
                            },
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Add new address',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 28.0),
                    child: ElevatedButton(

                      onPressed: () {
                        callredeemApi();
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => NewAddressScreen()),
                        // );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.background, // Background color
                        padding: EdgeInsets.zero, // No padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25), // Adjust the border radius as needed
                        ),
                      ),
                      child: SizedBox(
                        width: 100,
                        height: 50,
                        child: Padding(
                          padding: EdgeInsets.only(top: 5.0, left: 14),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Next',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),


                ],
              ),
            );
          },
        );
      },
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
  Future<void> callredeemApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken =
        prefs.getString('access_token') ?? '';
    String offer_id = prefs.getString('offer_id')??"";
    String address_id = prefs.getString('address_id')??"";

    final String apiUrl = '${Api.baseurl}/api/redeemed-offers';
// Replace these headers with your required headers
    Map<String, String> headers = {
      'Authorization': 'Bearer $authToken',

    };



    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          "offer_id": offer_id,
          "address_id": address_id,

          // "device_id":  device_id// cahnge device_token

        },

        headers: headers,
      );

      print('response === ' + response.body);
      if (response.statusCode == 201) {
        Fluttertoast.showToast(msg: "Offer redeemed successfully. Please wait for an admin response.");
        if (kDebugMode) {
          print('sddd ${response.body}');
        }
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => RedeemSuccessPage()),
        );
        // Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        //
        // // Extract the customer ID
        // String customerAccessToken = jsonResponse['data']['token']['access'];
        // prefs.setString('customer_token', customerAccessToken);
        // print('customer_acess_token === ' + customerAccessToken);

      } else {
        print('Failed with status code: ${response.statusCode}');
        print('Failed sddd ${response.body}');
      }
    } catch (e) {
// Handle exceptions here (e.g., network errors)
      print('Exception: $e');
    }
  }

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance(); // Initialize SharedPreferences
  }}

class PrescriptionUpload extends StatefulWidget {
  const PrescriptionUpload({super.key});

  @override
  PresUpload createState() => PresUpload();
}

class PresUpload extends State<PrescriptionUpload> {
  int? EyeHealthPoints;
  int? totalPoints;  TextEditingController _commentController = TextEditingController();

  OfferData? offerData;
  double? userPercentage;
  bool isReedemButtonEnabled = false; // Set your condition here
  List<File> _files1 = [];
  List<PlatformFile> _files = [];
  String Date = '1 May, 2024 ';
  String Time = "2 days";
  // String offer_id = "aa8e1bb0-c7cd-4732-81c0-09de236c05ec";
  int points = 10;
  final double _currentTime = 80.0; // Initial time
  int _countdownValue = 0;
  String userToken = '';
  List<String> dates = [];
  List<String> statuses = [];
  List<String> image = [];

  bool isLoading = true;

  List<String> prescriptionid = [];
  Timer? _timer;

  String? image_url, title, description;
  Color buttonColor = Colors.disablebutton; // Default color
  int? hours, minutes, seconds;bool isEnabled=true;
  @override
  void initState() {
    super.initState();
    getPrescriptionFiles();
  }

  @override
  void dispose() {
    _timer?.cancel();_commentController.dispose();
    super.dispose();
  }
  Future getPrescriptionFiles() async {
    var sharedPref = await SharedPreferences.getInstance();
    String userToken = sharedPref.getString("access_token") ?? '';
    try {
      setState(() {
        _files1.clear();
        _files.clear();
      });
      Map<String, String> headers = {
        'Authorization': 'Bearer $userToken', // Bearer token type
        // 'Content-Type': 'application/json',
      };
      // Make the API request to fetch project sites
      var response = await Dio().get(
          "${ApiProvider.baseUrl}${ApiProvider.uploadPrescription}",
          options: Options(headers: headers));

      // Check the response status code
      if (response.statusCode == 200) {

        Map<String, dynamic> data = json.decode(response.toString());
        totalPoints   =data['total_points_by_prescription_upload'];
        EyeHealthPoints=data['you_can_get_points_by_prescription_upload'];
        List<dynamic> prescriptionFiles = data['data']; // Specify the file name
        List<String> prescriptionNames = [];
        isLoading = false;
        if(prescriptionFiles.isNotEmpty ||prescriptionFiles!=null) {
          for (var fileEntry in prescriptionFiles) {
            String invoiceFile = fileEntry['uploaded_file'];
            String date = fileEntry['created_on'];
            String status = fileEntry['status'];

            String images = fileEntry['uploaded_file'];
            image.add(images);
            String prescription_id = fileEntry['prescription_id'];

            prescriptionNames.add(invoiceFile);
            dates.add(date);
            statuses.add(status);
            prescriptionid.add(prescription_id);
          }
          print('Purchase Orderdd: $prescriptionNames');
          // Extract the invoice_file values and create PlatformFile objects
          List<PlatformFile> platformFiles = [];
          for (var fileEntry in prescriptionFiles) {
            String invoiceFilePath = fileEntry['uploaded_file'];
            PlatformFile platformFile = PlatformFile(
              name: invoiceFilePath
                  .split('/')
                  .last,
              size: 0, // Set appropriate file size
              bytes: null, // Set appropriate file bytes
            );
            platformFiles.add(platformFile);
          }
          _files.addAll(platformFiles);
        }
        setState(() {});
      } else {
        // If the request was not successful, throw an error
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      // If an error occurs during the request, throw the error
      throw Exception('Failed to load data: $e    $stacktrace');
    }
  }





  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:
      isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      )
          :
      Scaffold(
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
        // appBar: PreferredSize(
        //   preferredSize: const Size.fromHeight(10),
        //   child: AppBar(
        //     backgroundColor:
        //     Colors.white, // Set app bar background color to white
        //     elevation: 0, // Remove app bar shadow
        //     // Add any other app bar properties as needed
        //   ),
        // ),
        body: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 125,
                  // width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/rewards_back.png"), // Add your background image path
                      fit: BoxFit.fill,
                    ),
                  ),
                ),

                SizedBox(
                  height: 110,
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 5),

                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          iconSize: 28, // Back button icon
                          onPressed: () {
                            Navigator.pop(context);
                            // Navigator.of(context).pop();
                          },
                        ),
                      ),
                      const SizedBox(height: 5),
                      Align(
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return const RadialGradient(
                                      radius: 1.0,
                                      colors: [
                                        Color(0xFFFFF400),
                                        Color(0xFFFFE800),
                                        Color(0xFFFFCA00),
                                        Color(0xFFFF9A00),
                                        Color(0xFFFF9800),
                                      ],
                                    ).createShader(bounds);
                                  },
                                  child: Text(
                                    ' $EyeHealthPoints ',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .white, // Specify a color for the text
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(
                                text: 'Every visit to Optometrist ',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Add more Text widgets as needed
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                // child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 7,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            colors: [
                              Colors.bluegradient,
                              Colors.greengradient
                            ], // Your gradient colors
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds);
                        },
                        child: Text(
                          '$totalPoints',
                          style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.fromLTRB(18.0, 5, 18, 10),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Total Point Earned Till Now',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(18.0, 5, 18, 10),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Upload',
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),

                    Container(
                      height: MediaQuery.of(context).size.width / 2.1,
                      width: MediaQuery.of(context).size.width / 1.3,
                      color: Colors.grey.withOpacity(0.2),
                      child: Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                onTap: isEnabled ? _pickFiles : null,

                                // onTap: _pickFiles,
                                child: Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image:AssetImage(
                                        isEnabled ? 'assets/upload_icon.png' : 'assets/upload_success.png', // Change the paths accordingly
                                      ),
                                      // AssetImage(
                                      //     'assets/upload_icon.png'), // Replace with your image asset path
                                      fit: BoxFit
                                          .contain, // Adjust the fit as needed
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: isEnabled ? 10 : 0, // Adjust height based on condition
                              ),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(18.0, 7, 18, 3),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      isEnabled ? 'Drag & drop files or Browse' : 'Prescription upload' ,

                                            // 'Drag & drop files or Browse',
                                            // 'Win a cool pair of sunglasses of worth rs 1000 free',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        )),
                                    SizedBox(
                                      height: isEnabled
                                          ? 10
                                          : 0, // Adjust height based on condition
                                    ),
                                    Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(18.0, 0, 18, 4),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            isEnabled
                                                ? 'Supported formates: JPG, JPEG, PNG, WEBP, SVG, BMP'
                                                : 'Your prescription has been uploaded and is currently being verified by our team. This process will take approximately 24 hours. ',

                                            // 'Win a cool pair of sunglasses of worth rs 1000 free',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.greytext,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        )),
                                  ],
                                )),
                          ),
// TODO REPLACEMENT ===add progress bar for uploading files

                          // Padding(
                          //   padding: EdgeInsets.fromLTRB(18.0,10,18,10),
                          //   child: Text(
                          //     'Uploading - 1/1 files',
                          //     // 'Win a cool pair of sunglasses of worth rs 1000 free',
                          //     style: TextStyle(
                          //         fontSize: 13,
                          //         color: Colors.greytext,
                          //         fontWeight: FontWeight.w500),
                          //   ),
                          // ),

                          SizedBox(
                            height: 15,
                          ),

                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const ScrollPhysics(),
                              itemCount: _files.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading:
                                      const Icon(Icons.picture_as_pdf_outlined),
                                  title: Text(
                                    _files[index].name ?? '',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 11),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Text(
                                        '${dates[index].toString().substring(0, 10)} , ${dates[index].toString().substring(12, 19)} ago',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12)),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          if (statuses[index].toLowerCase() ==
                                              "approved")
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                '$points Points',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12),
                                              ),
                                            ),
                                          if (statuses[index].toLowerCase() ==
                                              "pending")
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                '${statuses[index]}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12),
                                              ),
                                            ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          // if (statuses[index].toLowerCase() == "pending")
                                          GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                    child: SizedBox(
                                                      height: MediaQuery.of(context).size.height * 0.9, // Set height to half of screen height
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Center(
                                                            child: Container(
                                                              height: MediaQuery.of(context).size.height * 0.8, // Set the height of the image container
                                                              child: ClipRect(
                                                                child: FittedBox(
                                                                  fit: BoxFit.contain,
                                                                  alignment: Alignment.center,
                                                                  child: Image.network(
                                                                    "https://eyehealth.backend.zuktiinnovations.com" + image[index],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () => Navigator.of(context).pop(),
                                                            child: Text('Close'),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.black),
                                                borderRadius: BorderRadius.circular(5.0),
                                              ),
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'Preview',
                                                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Add your text here
                                      // IconButton(
                                      //   icon: Icon(Icons.more_vert),
                                      //   onPressed: () {
                                      //     // _removeFile(index, _files[index].identifier ?? '');
                                      //   },
                                      // ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                // ),
              ),
            ),
          ],
        ),
        bottomNavigationBar:
        CustomBottomAppBar(currentScreen: "Rewards"),
      ),

    );
  }

  void _pickFiles() async {
    FilePickerResult? pickedFiles = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [

        'jpg',
        'jpeg',
        'png',
        'bmp',
        'svg',
        'webp'
      ], // Specify allowed file types
    );

    if (pickedFiles != null) {
      List<File> files = pickedFiles.paths.map((path) => File(path!)).toList();

      List<PlatformFile> pdfFiles =
          pickedFiles.files.where((file) => file.extension == 'pdf').toList();
      setState(() {});
      // if (pdfFiles.length < pickedFiles.files.length) {
      //   Fluttertoast.showToast(
      //     msg: "Only PDF files are allowed",
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Colors.red,
      //     textColor: Colors.white,
      //     fontSize: 16.0,
      //   );
      // } else {
      _files1.addAll(files);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
          padding: EdgeInsets.all(16
              //  bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
          child: Wrap(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Prescription Upload Feedback',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(thickness: 1, color: Colors.grey.shade500),
              Padding(
                padding: EdgeInsets.all(4.0),
                child: Text(
                  "Please provide additional comments while uploading your prescription:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.bluebutton,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.0),
                child:
                    Text("1.Kindly enter the name of the Doctor you visited. "),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
                child: TextField(
                  controller: _doctorController,
                  decoration: InputDecoration(
                    hintText: "Enter Doctor Name...",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 10),
                child: Text("2.Kindly enter the date of your eye test."),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 55,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14.0, vertical: 1),
                  child: TextField(
                    controller: _dateController,
                    readOnly: true,
                    // Make the TextField read-only
                    onTap: () {
                      _selectDate(
                          context); // Show date picker when the TextField is tapped
                    },
                    decoration: InputDecoration(
                      labelText: 'Visited Date',
                      hintText: 'YYYY-MM-DD',
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.background,
                        fontWeight: FontWeight.w400,
                      ),
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.hinttext,
                        fontWeight: FontWeight.w400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(6.0), // Add circular border
                      ),
                      // Set floatingLabelBehavior to always display the label
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.0),
                child: Text("3.Why you visited for the eyetest?"),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: "Type your problem here...",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Retrieve the user's comment
                      String comment = _commentController.text;
                      // You can do something with the comment here
                      print("User comment: $comment");
                      uploadPrescription(pickedFiles.files, comment);

                      Navigator.of(context).pop(); // Close the dialog
                    },
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all<double>(
                          0), // Set elevation to 0 to remove shadow

                      backgroundColor: MaterialStateProperty.all<Color>(Colors
                          .background), // Set your desired background color here
                    ),
                    child: const Text('Submit',
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
      );

      // uploadPrescription(pickedFiles.files);
      // }
    }
  }

  DateTime? _selectedDate;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _doctorController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _selectedDate
            .toString()
            .substring(0, 10); // Update the TextField with selected date
      });
    }
  }

  Future<void> uploadPrescription(List<PlatformFile> _files, Comment) async {
    var sharedPref = await SharedPreferences.getInstance();
    String userToken = sharedPref.getString("access_token") ?? '';

    var request = http.MultipartRequest("POST",
        Uri.parse('${ApiProvider.baseUrl}${ApiProvider.uploadPrescription}'));

    Map<String, String> headers = {
      'Authorization': 'Bearer $userToken',
    };
    request.headers.addAll(headers);

    for (var i = 0; i < _files.length; i++) {
      request.files.add(await http.MultipartFile.fromPath(
        'uploaded_file',
        _files[i].path!,
      ));
    }
    request.fields['problem_faced'] = Comment;
    request.fields['doctor_name'] = _doctorController.text;
    request.fields['visit_date'] = _dateController.text;

    print("Request==: ${request.toString()}");

    try {
      var response = await request.send();

      // Get the status code
      int statusCode = response.statusCode;

      // Handle the response asynchronously
      response.stream.transform(utf8.decoder).listen((value) {
        var data = jsonDecode(value);
        print("data: $data");

        // Process the response data as needed
      });

      // Handle the status code
      print("Status Code: $statusCode");
      print("Status Code: $_files");

      if (statusCode == 201) {
        Fluttertoast.showToast(msg: "File uploaded Successfully");
        isEnabled=false;

        getPrescriptionFiles();
      } else {
        print("Error: ${response.reasonPhrase}");
      }
    } catch (e,Stacktrace) {
      Fluttertoast.showToast(msg: "please upload image max upto 10 Mb");
      // Handle any errors that occur during the request
      print("Error uploading file: $e================$Stacktrace================");
    }
  }

}
class ImagePreviewDialog extends StatelessWidget {
  final String imageUrl;

  ImagePreviewDialog({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return
     Dialog(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

