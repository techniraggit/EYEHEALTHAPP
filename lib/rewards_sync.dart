// ignore_for_file: use_build_context_synchronously, avoid_print, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:contacts_service/contacts_service.dart';
// import 'package:flutter_contacts/flutter_contacts.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_new/models/OfferData.dart';
import 'package:project_new/models/address_list.dart';
import 'package:project_new/sign_up.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Custom_navbar/bottom_navbar.dart';
import 'api/config.dart';

class RewardContact extends StatefulWidget {
  const RewardContact({super.key});

  @override
  _RewardsContactsSync createState() => _RewardsContactsSync();
}

class _RewardsContactsSync extends State<RewardContact> {
  int points = 10;
  int totalPoints = 100;
  final String appStoreLink = 'https://yourappstorelink.com';

  List<Contact> _contacts = [];String ? ReferCode="";
  bool _permissionDenied = false;
  final Map<int, bool> _invitationStatus = {};
@override
  void initState()  {
    // TODO: implement initState
    super.initState();
    getReferCode();
    _fetchContacts();
}







  void shareAppLink(int i) async {
    try {
        Share.share('Check out our awesome app: $appStoreLink'
          'Use Referal Code $ReferCode');
      // If the share is successful, set isShareSuccess to true
      // _invitationStatus[i] = true ;
      setState(() {
        _invitationStatus[i] =
        !(_invitationStatus[i] ?? false);
      });

    } catch (e) {
      // If there's an error during sharing, set isShareSuccess to false
      setState(() {
        _invitationStatus[i] = false;

      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share the app.'),
        ),
      );


      _invitationStatus[i] =
          !(_invitationStatus[i] ?? false);

    }}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: AppBar(
            backgroundColor:
                Colors.white, // Set app bar background color to white
            elevation: 0, // Remove app bar shadow
            // Add any other app bar properties as needed
          ),
        ),
        body:
        Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 110,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          "assets/rewards_back.png"), // Add your background image path
                      fit: BoxFit.cover,
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
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => const RewardSpecs()),
                            );
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
                                    fontSize: 15, fontWeight: FontWeight.w400),
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
                                    fontSize: 15, fontWeight: FontWeight.w400),
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
                'Total earn point by Prescription uplaod',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
              ),
            ),
            const SizedBox(
              height: 35,
            ),



if(ReferCode!.isNotEmpty)
  GestureDetector(
    onTap: () {
      Share.share(ReferCode!);

      // Your action when clicking on the left end or center
    },
    child: Container(
      height: 44,
      width: MediaQuery.of(context).size.width / 2.2, // Set a width for the container
      child: Stack(
        children: [
          // Image widget as the background
          Center(
            child: Image.asset(
              'assets/referoutline.png', // Replace with your image asset path
              width: MediaQuery.of(context).size.width / 1.5, // Set a width for the container
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
                onTap: (){
                  Clipboard.setData(ClipboardData(text: ReferCode! ?? ""));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Referral code copied to clipboard'),
                    ),
                  );
                },
                child: Text(
                  ReferCode!,
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                  ),
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
                    await [
                    Permission.contacts
                    ].request();

setState(() {

});
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Invite Via Whatsapp ',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(
                        width: 9,
                      ),
                      Image.asset('assets/wp_icon.png',
                          width: 19,
                          color: Colors.white70), // Add your icon here
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Contacts',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.background,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            // if (_permissionDenied)
            //   const Center(child: Text('Permission denied')),
            if (_contacts != null) ...{
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _contacts.length,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.white,
                      elevation: 0.9,
                      child: ListTile(
                        leading: _contacts[i].avatar!=null && _contacts[i].avatar!.isNotEmpty?
                        Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle
                          ),
                          child: Image.memory(_contacts[i].avatar!))
                        : Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle
                          ),
                          child: Image.asset('assets/contact.png'))
                        ,
                        // leading: CircleAvatar(
                        //   backgroundImage: _contacts[i].avatar != null &&
                        //           _contacts[i].avatar!.isNotEmpty
                        //       ? MemoryImage(_contacts[i].avatar!)
                        //       : const AssetImage('assets/contact.png')
                        //           as ImageProvider,
                        // ),
                        title: Text(
                          _contacts[i].displayName??'',
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: Colors.black),
                        ),
                        subtitle: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '+91 ${_contacts[i].phones!.isNotEmpty ? _contacts[i].phones!.first.value : 'N/A'}',
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
                                    print("===${_invitationStatus[i].toString()}");
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
                                            .green, // Green background color
                                        borderRadius: BorderRadius.circular(
                                            20), // Rounded border
                                      ),
                                      child: const Icon(Icons.check,
                                          color: Colors
                                              .white)) // Display verified icon
                                  : const Text(
                                      'INVITE',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          color: Color(0xFF667085)),
                                    ), // Display "INVITE" text
                            ),
                          ],
                        ),
                        onTap: () async {

                        },
                      ),
                    ),
                  ),
                ),
              ),
            }
          ],
        ),
        bottomNavigationBar: CustomBottomAppBar(), // Include the persistent bottom bar here

      ),
    );
  }

  Future _fetchContacts() async {

    // if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
      print("_permissionDenied");
    // } else {
    //   print("_permissionGranted");

      // final contacts = await FlutterContacts.getContacts();
      if (await Permission.contacts.isGranted) {
        List<Contact> contacts = await ContactsService.getContacts();

        setState(() => _contacts = contacts);
        print("_permissionGranted${_contacts.length}");      }
      else{

      }

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
        Uri.parse('${ApiProvider.baseUrl+ApiProvider.getUserProfile}'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',


        },
      );

      if (response.statusCode == 200) {
        // _progressDialog!.hide();

        final jsonResponse = jsonDecode(response.body);
        setState(() {
          ReferCode=jsonResponse['data']['referral_code'];

        });

        print("responseviewprofile:${response.body}");


        return json.decode(response.body);

      } else {     // _progressDialog!.hide();

        print(response.body);

      }
    }
    catch (e) {     // _progressDialog!.hide();

      print("exception:$e");
    }
    throw Exception('');

  }


}



class RewardSpecs extends StatefulWidget {
  const RewardSpecs({super.key});

  @override
  RewardSpecsSync createState() => RewardSpecsSync();
}

class RewardSpecsSync extends State<RewardSpecs> {
  int ? EyeHealthPoints ;
  int ? totalPoints ;
   OfferData? offerData;
  AddressList? address_list;

  double ? userPercentage;
  bool isReedemButtonEnabled = false; // Set your condition here

  String offer_id="19225502-2a98-42e4-8744-a0bc0fb1cc01";
  final double _currentTime = 80.0; // Initial time
  int _countdownValue = 0;
  Timer? _timer;
   String ? image_url,title,description;
  Color buttonColor = Colors.disablebutton; // Default color
  int? hours, minutes, seconds;
  bool isSelected = false;

  @override
  void initState()  {
    super.initState();
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
      String userToken = '';
      var sharedPref = await SharedPreferences.getInstance();
      userToken =
      // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE2MjcyODc2LCJpYXQiOjE3MTYxODY0NzYsImp0aSI6ImYyMjJhM2VlZDNjYTRlZjc4MmNmNmEyNTYzOGQxMmU1IiwidXNlcl9pZCI6IjkxOTNhOTE1LWY5YzItNDQ0MC04MDVlLTQxNDBhYTc5ZDQzOSJ9.2Gj1laeNGLhy0FxYQCQVoB_Idt5W0F0X621BVPtNaic";
          sharedPref.getString("access_token") ?? '';
      Map<String, String> headers = {
        'Authorization': 'Bearer $userToken', // Bearer token type
        'Content-Type': 'application/json',
      };
      final response = await http.get(
        Uri.parse('${ApiProvider.baseUrl}${ApiProvider.getOffers_detail+"?offer_id=$offer_id"}'),
        headers: headers,
      );
      print("statusCode================${response.statusCode}");
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        offerData = OfferData.fromJson(responseData);
        print("statusCode================${offerData?.data?.description}");
          image_url=offerData!.data!.image!;
        EyeHealthPoints=offerData!.userPoints!;
        totalPoints=offerData!.data!.requiredPoints!;
        title=offerData!.data!.title!;
        description=offerData!.data!.description!;

        userPercentage = double.tryParse(offerData?.userPercentage.toString() ?? '0.0') ?? 0.0;
if(userPercentage==100.0){
  isReedemButtonEnabled=true;
}else{
  isReedemButtonEnabled=false;

}

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
    } on DioError catch (e) {
      if (e.response != null || e.response!.statusCode == 401) {
        // Handle 401 error

        Fluttertoast.showToast(msg: "Session Expired");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      }

      else {
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
      final response = await http.get(
        Uri.parse('${ApiProvider.baseUrl}${ApiProvider.getaddress}'),
        headers: headers,
      );
      print("statusCode================${response.statusCode}");
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        address_list = AddressList.fromJson(responseData);
        print("statusCode================${address_list?.data?[0].address}");

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
    } on DioError catch (e) {
      if (e.response != null || e.response!.statusCode == 401) {
        // Handle 401 error

        Fluttertoast.showToast(msg: "Session Expired");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      }

      else {
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
    return MaterialApp(
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: AppBar(
            backgroundColor:
                Colors.white, // Set app bar background color to white
            elevation: 0, // Remove app bar shadow
            // Add any other app bar properties as needed
          ),
        ),
        body: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 110,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          "assets/rewards_back.png"), // Add your background image path
                      fit: BoxFit.cover,
                    ),)
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
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) =>  PrescriptionUpload()),
                            );
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
                        padding: EdgeInsets.fromLTRB(18.0,5,18,10),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Total earn point by Prescription uplaod',
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
                        child:
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            image: image_url != null
                                ? DecorationImage(
                              image: NetworkImage("${ApiProvider.baseUrl}$image_url"),
                              // fit: BoxFit.cover,
                            )
                                : null,
                          ),
                        )
                  

                      ),

                       Padding(
                         padding: EdgeInsets.fromLTRB(18.0,10,18,10),
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
                       Padding(
                         padding: EdgeInsets.fromLTRB(18.0,10,18,10),
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
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            SliderTheme(
                              data: const SliderThemeData(
                                trackHeight: 8.0, // Increase the slider height
                                thumbColor: Colors.blue, // Set thumb color to blue
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 6.0), // Adjust thumb size
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
                                value: userPercentage?? 0.0,
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
                              padding: const EdgeInsets.only(left: 18.0,right: 50),
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

                            Padding(
                              padding: EdgeInsets.fromLTRB(18.0,10,18,10),
                              child: Align(
                                alignment: Alignment.center,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.background, // Change the color as needed
                                        width: 1.5, // Change the width as needed
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Test your eye fatigue',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.background,
                                      fontWeight: FontWeight.w500,
                                    ),
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
                      onTap: (){
                        RedeemaddressSheet(context);
                      },
                      // isReedemButtonEnabled ? () {
                      //   RedeemaddressSheet(context);
                      // } : null,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isReedemButtonEnabled ? Colors.background :  buttonColor, // Change color when disabled
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
        bottomNavigationBar: CustomBottomAppBar(), // Include the persistent bottom bar here

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
                          padding: const EdgeInsets.only(left: 16.0,top: 10,bottom: 8),
                          child: Text(
                            'Select address',
                            style: TextStyle(
                              fontSize: 16.0,color: Colors.background,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close,color: Colors.black87,),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics:
                    const ScrollPhysics(),
                    itemCount: address_list?.data?.length, // Replace with your item count
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        margin: EdgeInsets.all(8.0),
                     child:  Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[



                        Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: false, // Replace with your checkbox value
                                  onChanged: (newValue) {
                                    isSelected = !isSelected;
                                  },
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected ? Colors.background : Colors.grey,                              width: 0.3, // Specify the width of the border
                                    ),
                                    borderRadius: BorderRadius.circular(8), // Specify the border radius
                                    color: isSelected ? Colors.background : Colors.grey,                          ),
                                  child:SizedBox(
                                      height: 25,
                                      width: 50,
                                      // Specify the desired height
                                      child: Center(
                                        child: Text(
                                          'Home',
                                          style: TextStyle(
                                            fontSize: 12,color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),),
                              ],
                            ),



                            // Padding(
                            //   padding: const EdgeInsets.only(left: 20, right: 20),
                            //   child: Container(
                            //     decoration: BoxDecoration(
                            //       border: Border.all(
                            //           color: const Color(0xff95a2b6), width: 1.0),
                            //     ),
                            //     child: Padding(
                            //       padding: const EdgeInsets.symmetric(
                            //           horizontal: 12, vertical: 12),
                            //       child: Row(
                            //         children: [
                            //           Expanded(
                            //             child: Text(
                            //               '${address_list?.data?[index].address}  ${address_list?.data?[index].city},   ${address_list?.data?[index].state}, ${address_list?.data?[index].country}, ${address_list?.data?[index].postalCode}',
                            //               maxLines: null,
                            //               style: const TextStyle(
                            //                   color: Color(0xff112f5c), fontSize: 16,fontWeight: FontWeight.w400),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // ),

                            Padding(
                              padding: const EdgeInsets.only(top: 5.0,left: 10,right: 10),
                              child: Text(
                                '${address_list?.data?[index].address}  ${address_list?.data?[index].city},  ${address_list?.data?[index].state}, ${address_list?.data?[index].country}, ${address_list?.data?[index].postalCode}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.background, // Text color based on selection
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: null,
                              ),
                            ),


                            Padding(
                              padding: const EdgeInsets.only(top: 5.0,left: 10),
                              child: Text(
                                '${address_list?.data?[index].address}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:Colors.black , // Text color based on selection
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),


                            Padding(
                              padding: const EdgeInsets.only(top: 5.0,left: 10),
                              child: Text(
                                '${address_list?.data?[index].state}',
                                style: TextStyle(
                                  fontSize: 14,color: Colors.black,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),

                          ],
                        ),










                            Align(
                              alignment: Alignment.centerRight,

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
                ],
              ),
            );
          },
        );
      },
    );

  }
}
























class PrescriptionUpload extends StatefulWidget {
  const PrescriptionUpload({super.key});

  @override
  PresUpload createState() => PresUpload();
}

class PresUpload extends State<PrescriptionUpload> {
  int ? EyeHealthPoints ;
  int ? totalPoints ;
  OfferData? offerData;
  double ? userPercentage;
  bool isReedemButtonEnabled = false; // Set your condition here
  List<File> _files1 = [];
  List<PlatformFile> _files = [];String Date='1 May, 2024 ';String Time="2 days";
  String offer_id="19225502-2a98-42e4-8744-a0bc0fb1cc01";int points=10;
  final double _currentTime = 80.0; // Initial time
  int _countdownValue = 0;String userToken='';
  List<String> dates = [];
  List<String> statuses = [];
  List<String> prescriptionid = [];
  Timer? _timer;
  String ? image_url,title,description;
  Color buttonColor = Colors.disablebutton; // Default color
  int? hours, minutes, seconds;
  @override
  void initState()  {
    super.initState();
    getOffersDetail();

    getPrescriptionFiles();

  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  Future<void> getOffersDetail() async {
    try {
      String userToken = '';
      var sharedPref = await SharedPreferences.getInstance();
      userToken =
      // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE2MjcyODc2LCJpYXQiOjE3MTYxODY0NzYsImp0aSI6ImYyMjJhM2VlZDNjYTRlZjc4MmNmNmEyNTYzOGQxMmU1IiwidXNlcl9pZCI6IjkxOTNhOTE1LWY5YzItNDQ0MC04MDVlLTQxNDBhYTc5ZDQzOSJ9.2Gj1laeNGLhy0FxYQCQVoB_Idt5W0F0X621BVPtNaic";
      sharedPref.getString("access_token") ?? '';
      Map<String, String> headers = {
        'Authorization': 'Bearer $userToken', // Bearer token type
        'Content-Type': 'application/json',
      };
      final response = await http.get(
        Uri.parse('${ApiProvider.baseUrl}${ApiProvider.getOffers_detail+"?offer_id=$offer_id"}'),
        headers: headers,
      );
      print("statusCode================${response.statusCode}");
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        offerData = OfferData.fromJson(responseData);
        print("statusCode================${offerData?.data?.description}");
        image_url=offerData!.data!.image!;
        EyeHealthPoints=offerData!.userPoints!;
        totalPoints=offerData!.data!.requiredPoints!;
        title=offerData!.data!.title!;
        description=offerData!.data!.description!;

        userPercentage = double.tryParse(offerData?.userPercentage.toString() ?? '0.0') ?? 0.0;
        if(userPercentage==100.0){
          isReedemButtonEnabled=true;
        }else{
          isReedemButtonEnabled=false;

        }

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
    } on DioError catch (e) {
      if (e.response != null || e.response!.statusCode == 401) {
        // Handle 401 error

        Fluttertoast.showToast(msg: "Session Expired");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignIn()),
        );
      }

      else {
        // Handle other Dio errors
        print("DioError: ${e.error}");
      }
    } catch (e) {
      // Handle other exceptions
      print("Exception---: $e");
    }
  }

  void _removeFile(int index, String file_id) {
    setState(() {
      _files.removeAt(index);
      // delFile(file_id);
    });
  }

  // Future<String?> delFile(String mdid) async {
  //   try {
  //     var sharedPref = await SharedPreferences.getInstance();
  //     userToken =
  //     // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE2MjcyODc2LCJpYXQiOjE3MTYxODY0NzYsImp0aSI6ImYyMjJhM2VlZDNjYTRlZjc4MmNmNmEyNTYzOGQxMmU1IiwidXNlcl9pZCI6IjkxOTNhOTE1LWY5YzItNDQ0MC04MDVlLTQxNDBhYTc5ZDQzOSJ9.2Gj1laeNGLhy0FxYQCQVoB_Idt5W0F0X621BVPtNaic";
  //     sharedPref.getString("access_token") ?? '';
  //     Map<String, String> headers = {
  //       'Authorization': 'Bearer $userToken', // Bearer token type
  //       //  'Content-Type': 'application/json',
  //     };
  //     Map<String, dynamic> requestBody = {
  //       "file_id": mdid,
  //     };
  //     print('requestbody body: ${requestBody.toString()}');
  //
  //     String apiUrl = "${ApiProvider.baseUrl}/api/admin/invoice-remove";
  //     var response = await http.put(Uri.parse(apiUrl),
  //         body: requestBody, headers: headers);
  //
  //     // Make the API request to fetch project sites
  //
  //     // Check the response status code
  //     if (response.statusCode == 200) {
  //       print("api response : $response");
  //       Fluttertoast.showToast(msg: "file deleted sucessfully!");
  //     } else {
  //       // If the request was not successful, throw an error
  //       throw Exception('Failed to load data: ${response.statusCode}');
  //     }
  //   } catch (e, stacktrace) {
  //     print('Failed to load data: $stacktrace');
  //
  //     // If an error occurs during the request, throw the error
  //     throw Exception('Failed to load data: $e');
  //   }
  // }


























  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: AppBar(
            backgroundColor:
            Colors.white, // Set app bar background color to white
            elevation: 0, // Remove app bar shadow
            // Add any other app bar properties as needed
          ),
        ),
        body: Column(
          children: [
            Stack(
              children: [
                Container(
                    height: 110,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            "assets/rewards_back.png"), // Add your background image path
                        fit: BoxFit.cover,
                      ),)
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
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => const RewardContact()),
                            );
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
                        padding: EdgeInsets.fromLTRB(18.0,5,18,10),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Total earn point by Prescription uplaod',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(18.0,5,18,10),
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
                        height: 145,
                        width: MediaQuery.of(context).size.width/1.4,
                        color: Colors.lightgrey,
                        child: Align(
                            alignment: Alignment.center,
                            child:
                            Column(
                              children: [
                    SizedBox(height: 10,),
                                GestureDetector(
                                  onTap:_pickFiles ,
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage('assets/upload_icon.png'), // Replace with your image asset path
                                        fit: BoxFit.contain, // Adjust the fit as needed
                                      ),
                                    ),
                                  ),
                                ),

                          Padding(
                              padding: EdgeInsets.fromLTRB(18.0,7,18,3),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Drag & drop files or Browse',
                                  // 'Win a cool pair of sunglasses of worth rs 1000 free',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),)),


                                Padding(
                                    padding: EdgeInsets.fromLTRB(18.0,0,18,4),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Supported formates: JPEG, PNG, Word, PPT',
                                        // 'Win a cool pair of sunglasses of worth rs 1000 free',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.greytext,
                                            fontWeight: FontWeight.w400),
                                      ),)),
                              ],
                            )




                        ),
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

                SizedBox(height: 15,),

                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics:
                          const ScrollPhysics(),
                          itemCount: _files.length,
                          itemBuilder:
                              (context, index) {
                            return ListTile(
                              leading: const Icon(
                                  Icons.picture_as_pdf_outlined),
                              title: Text(
                                  _files[index]
                                      .name ??
                                      '',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 11),),

                              subtitle:
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Text('${dates[index].toString().substring(0,10)} , ${dates[index].toString().substring(12,19)} ago',

                                  style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12)),
                                ),

                                trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if(statuses[index].toLowerCase()=="approved")
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      '$points Points',
                                      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                                    ),
                                  ),
                                  if(statuses[index].toLowerCase()=="pending")
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        '${statuses[index]}',
                                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                                      ),
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
        bottomNavigationBar: CustomBottomAppBar(), // Include the persistent bottom bar here

      ),
    );

  }



  void _pickFiles() async {
    FilePickerResult? pickedFiles = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        // 'jpg',
        // 'jpeg',
        // 'png'
      ], // Specify allowed file types
    );

    if (pickedFiles != null) {
      List<File> files = pickedFiles.paths.map((path) => File(path!)).toList();

      List<PlatformFile> pdfFiles =
      pickedFiles.files.where((file) => file.extension == 'pdf').toList();
      setState(() {});
      if (pdfFiles.length < pickedFiles.files.length) {
        Fluttertoast.showToast(
          msg: "Only PDF files are allowed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {

        _files1.addAll(files);
        uploadPrescription( pickedFiles.files);






      }
    }
  }


  Future<void> uploadPrescription(List<PlatformFile> _files) async {
    var sharedPref = await SharedPreferences.getInstance();
    String userToken = sharedPref.getString("access_token") ?? '';

    var request = http.MultipartRequest(
        "POST",
        Uri.parse('${ApiProvider.baseUrl}${ApiProvider.uploadPrescription}')
    );

    Map<String, String> headers = {
      'Authorization': 'Bearer $userToken',
    };
    request.headers.addAll(headers);

    // for (var i = 0; i <1; i++) {
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        _files[0].path!,
      ));


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

      if (statusCode == 201) {
        Fluttertoast.showToast(msg: "File uploaded Successfully");

        getPrescriptionFiles();
      }
      else {
        print("Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      // Handle any errors that occur during the request
      print("Error uploading file: $e");
    }














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


        List<dynamic> prescriptionFiles =data['data'];// Specify the file name
        List<String> prescriptionNames = [];


        for (var fileEntry in prescriptionFiles) {
          String invoiceFile = fileEntry['file'];
          String date = fileEntry['created_on'];
          String status = fileEntry['status'];
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
          String invoiceFilePath = fileEntry['file'];
          PlatformFile platformFile = PlatformFile(
            name: invoiceFilePath.split('/').last,
            size: 0, // Set appropriate file size
            bytes: null, // Set appropriate file bytes
          );
          platformFiles.add(platformFile);
        }
        _files.addAll(platformFiles);

        setState(() {
        });





      } else {
        // If the request was not successful, throw an error
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e,stacktrace) {

      // If an error occurs during the request, throw the error
      throw Exception('Failed to load data: $e    $stacktrace');
    }
  }
}