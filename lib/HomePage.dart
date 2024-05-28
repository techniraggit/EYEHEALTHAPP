import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:project_new/myPlanPage.dart';
import 'package:project_new/testScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Api.dart';
import 'Custom_navbar/bottom_navbar.dart';
import 'eyeFatigueTest.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool isSelected = false;
  bool isLeftEyeSelected = false;
  List<double> data1 = [10, 30, 20, 40, 30]; // Sample data for line 1
  List<double> data2 = [30, 50, 60, 50, 60];
  int currentHour = DateTime.now().hour;
  late DateTime selectedDate;

  // Define selectedDate within the _CalendarButtonState class

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentHour = DateTime.now().hour;
    // Determine the appropriate salutation based on the current hour
    String salutation = '';
    if (currentHour >= 0 && currentHour < 12) {
      salutation = 'Good morning';
    } else if (currentHour >= 12 && currentHour < 17) {
      salutation = 'Good afternoon';
    } else {
      salutation = 'Good evening';
    }
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: Stack(
          children: [
            Image.asset(
              'assets/pageBackground.png',
              // Replace 'background_image.jpg' with your image asset
              fit: BoxFit.fill,
              width: double.infinity,
              height: 250,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 20.0, 0, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap:(){
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) =>
                                        setReminder()),
                              );                            } ,
                            child: Text(
                              salutation,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ),
                          Image.asset('assets/notification.png')
                        ],
                      ),
                      const Text(
                        'Name',
                        style: TextStyle(
                            color: Colors.lightBlueAccent, fontSize: 18),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Your Eye Health Score',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          Text(
                            '2034',
                            style: TextStyle(
                              color: Colors.yellowAccent,
                              fontSize: 28,
                              decoration: TextDecoration.combine(
                                [TextDecoration.underline],
                              ),
                              decorationColor: Colors
                                  .yellow, // Set the underline color to yellow
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            GestureDetector(
              onTap: ()  {
                //sendcustomerDetails(context);
                //_showTestChoiceDialog(context);
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCustomerPage()),
                ); // Call the API
              },
              child: Image.asset('assets/digital_eye_exam.png'),
            ),
            GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EyeFatigueStartScreen()),
                );
              },
                child: Image.asset('assets/eyeFatigueTest.png')),
            Padding(
              padding: EdgeInsets.all(1.0),
              child: GestureDetector(
                  onTap: ()  {

                     Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyPlan()),
                ); // Call the API
                  },
                  child: Image.asset('assets/find_near_by_store.png')),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 10, 15, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'EYE HEALTH STATUS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        //_fromDates[index] != null ? _fromDates[index]! : DateTime(2000),

                        // firstDate:_fromDates[index] != null?? DateTime(2000), // Set the first selectable date to the current date
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        // _toDates[index] = picked;

                        setState(() {});
                      }
                    },
                    child: Image.asset('assets/calender.png'),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Card(
                child: ListTile(
                  title: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('No. of eye fatigue test'),
                              Text(
                                'value',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.end,
                          //   children: [
                          //     Text('No. of digital eye test'),
                          //     Text(
                          //       'Value ',
                          //       style: TextStyle(
                          //         fontSize: 16,
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Add spacing between the row and the additional columns
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Prescription uploaded'),
                              Text(
                                'value',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.end,
                          //   children: [
                          //     Text('visit to optemistist'),
                          //     Text(
                          //       'Value',
                          //       style: TextStyle(
                          //         fontSize: 16,
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 10, 0, 10),
              child: Text(
                'EYE HEALTH GRAPH OVERVIEW', // Display formatted current date
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 1),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(1),
                        child: ListTile(
                          title: Text(
                            'Right Eye Health',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text('April 30-May 30'),
                        ),
                      ),

                      // Container with fixed height to contain the LineChart
                      Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width,

                        // Adjust the height as needed
                        child: AspectRatio(
                          aspectRatio: 1.40,
                          child: LineChart(
                            LineChartData(
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    FlSpot(0, 4),
                                    FlSpot(2, 4),
                                    FlSpot(4, 6),
                                    FlSpot(6, 3),
                                    FlSpot(8, 4),
                                    FlSpot(10, 5),
                                  ],
                                  isCurved: true,
                                  colors: [Colors.deepPurple],
                                  barWidth: 4,
                                  isStrokeCapRound: true,
                                  belowBarData: BarAreaData(
                                    show: true,
                                    colors: [
                                      Colors.deepPurple.withOpacity(0.1)
                                    ],
                                  ),
                                ),
                              ],
                              titlesData: FlTitlesData(
                                bottomTitles: SideTitles(
                                  showTitles: true,
                                  getTitles: (value) {
                                    switch (value.toInt()) {
                                      case 0:
                                        return 'Mon';
                                      case 2:
                                        return 'Tue';
                                      case 4:
                                        return 'Wed';
                                      case 6:
                                        return 'Thu';
                                      case 8:
                                        return 'Fri';
                                      case 10:
                                        return 'Sat';
                                    }
                                    return '';
                                  },
                                ),
                                leftTitles: SideTitles(
                                  showTitles: false,
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: true,
                                drawHorizontalLine: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 10, 0, 0),
              child: Text(
                'YOU HAVE TESTED SO FAR', // Display formatted current date
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SizedBox(
                height: 200, // Adjust height as needed
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 180,
                      width: 140,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/interview.png'),
                          // Replace with your image asset
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              '300',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.0),
                            child: Text(
                              'Eye Test',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 180,
                      width: 140,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/eye_bg.png'),
                          // Replace with your image asset
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 4.0),
                            child: Text(
                              '300',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 2.0, horizontal: 4.0),
                            child: Text(
                              'Eye Fatigue Test',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
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
          ],
        ),
      ),

      bottomNavigationBar:
      CustomBottomAppBar(),



    );
  }
  Future<void> sendcustomerDetails(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken =
    // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
    prefs.getString('access_token') ?? '';
    final String apiUrl = '${Api.baseurl}/api/eye/add-customer';
// Replace these headers with your required headers
    Map<String, String> headers = {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json',

    };

    var body = json.encode({
      "is_self": true,
    });


    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );
      print('response === ' + response.body);
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('sddd ${response.body}');
        }
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Extract the customer ID
        String customerId = jsonResponse['customer_id'];
        prefs.setString('customer_id', customerId);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GiveInfo()),
        );

      } else {
        print('Failed with status code: ${response.statusCode}');
        print('Failed sddd ${response.body}');
      }
    } catch (e) {
// Handle exceptions here (e.g., network errors)
      print('Exception: $e');
    }
  }
}


class setReminder extends StatefulWidget {

  @override
  State<setReminder> createState() => ReminderState();
}

class ReminderState extends State<setReminder> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Plugin example app'),
            ),
            body: Builder(builder: (context) {
              return Center(

              );
            }
            )
        ));
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}



class AddCustomerPage extends StatefulWidget {
  @override
  _AddCustomerPageState createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();




  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: Colors.bluebutton, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: Colors.bluebutton, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: Colors.bluebutton, width: 2),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a name';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your age';
    }
    final age = int.tryParse(value);
    if (age == null || age <= 0) {
      return 'Please enter a valid age';
    }
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    }
    final mobileRegExp = RegExp(r'^[0-9]{10}$');
    if (!mobileRegExp.hasMatch(value)) {
      return 'Please enter a valid mobile number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Customer'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                 
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('Name'),
                    validator: _validateName,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _ageController,
                    decoration: _inputDecoration('Age'),
                    keyboardType: TextInputType.number,
                    validator: _validateAge,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        sendcustomerDetails(context,false, name: _nameController.text, age: _ageController.text);
                      }
                    },
                    child: Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.bluebutton,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> sendcustomerDetails(BuildContext context, bool isSelf, {String? name, String? age}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('access_token') ?? '';
    final String apiUrl = '${Api.baseurl}/api/eye/add-customer';

    Map<String, String> headers = {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json',
    };

    var body = json.encode({
      'is_self': isSelf,
      if (!isSelf) 'name': name,
      if (!isSelf) 'age': age,
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

          // Navigate to GiveInfo screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GiveInfo()),
          );
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

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    
    super.dispose();
  }
}


void _showTestChoiceDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Choose Test Option'),
        content: Text('Is this test for yourself or for someone else?'),
        actions: <Widget>[
          TextButton(
            child: Text('Test for Self'),
            onPressed: () {
              Navigator.of(context).pop();
              sendcustomerDetails(context, true);
            },
          ),
          TextButton(
            child: Text('Test for Others'),
            onPressed: () {
              Navigator.of(context).pop();
              _showOtherFormDialog(context);
            },
          ),
        ],
      );
    },
  );
}

void _showOtherFormDialog(BuildContext context) {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Enter Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Submit'),
            onPressed: () {
              final String name = _nameController.text;
              final String age = _ageController.text;
              Navigator.of(context).pop();
              sendcustomerDetails(context, false, name: name, age: age);
            },
          ),
        ],
      );
    },
  );
}
Future<void> sendcustomerDetails(BuildContext context, bool isSelf, {String? name, String? age}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String authToken = prefs.getString('access_token') ?? '';
  final String apiUrl = '${Api.baseurl}/api/eye/add-customer';

  Map<String, String> headers = {
    'Authorization': 'Bearer $authToken',
    'Content-Type': 'application/json',
  };

  var body = json.encode({
    'is_self': isSelf,
    if (!isSelf) 'name': name,
    if (!isSelf) 'age': age,
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

        // Navigate to GiveInfo screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GiveInfo()),
        );
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


