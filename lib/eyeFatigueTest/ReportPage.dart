import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:project_new/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Custom_navbar/bottom_navbar.dart';
import '../FatigueReportDetails.dart';
import '../api/config.dart';

class ReportPage extends StatefulWidget {
  @override
  ReportPageState createState() => ReportPageState();
}

class ReportPageState extends State<ReportPage> {

  List<dynamic> itemsdata = [];



  List<dynamic> percentage = [];

   List<dynamic> items = [];
  List<dynamic> ReportIds = [];
  String testResult='Good';

@override
void initState() {

    super.initState();

    getReports();
  }
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMMM').format(DateTime.now());
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
        title: const Text('Report and Statistics'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notification icon pressed
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Builder(
              builder: (context) {

                return Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 10, 0, 8),
                  child: Text(
                    'Today $formattedDate', // Display formatted current date
                    style: TextStyle(
                      fontStyle: FontStyle.normal,fontSize: 15,fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                );
              }
            ),

            // SizedBox(height: 20),

            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 10, 15, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Eye Fatigue Reports',
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
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        setState(() {});
                      }
                    },
                    child: Image.asset('assets/calender.png'),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              // physics: NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 1,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17.0), // Adjust the radius as needed
                  ),
                  child: Container(
                    // color: Colors.white, // Background color of the box
                    padding: EdgeInsets.symmetric(horizontal: 2,vertical: 11), // Padding around the content
                    child: ListTile(
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                        child: Text(
                            'Date: '+ items[index].toString().substring(0,10) , style: TextStyle(fontStyle: FontStyle.normal),),//items[index].substring(items[index].indexOf('-') + 2


                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Text(
                                'Test Result : ',
                                style: TextStyle(
                                  color: Colors.black,fontWeight: FontWeight.w700,fontSize: 16
                                )),
                              Builder(
                                builder: (context) {
                                  print("percentage[index]====n ${percentage[index]}");
                                  if(percentage[index]>50.0){
                                    testResult="Good";
                                  }else{
                                    testResult="Bad";
                                  }
                                  return Text(
                                       testResult,
                                      style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16,
                                        color: testResult == 'Good' ? Colors.green : Colors.red,
                                      ));
                                }
                              ),
                              Expanded(

                                // alignment: Alignment.centerRight,
                                child: Align(
                                  alignment: Alignment.centerRight,

                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context, CupertinoPageRoute(
                                        builder: (context) => ReportDetails(reportId: ReportIds[index]
                                        ),
                                      ),

                                      );

                                      // Add button onPressed logic here
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white, backgroundColor: Colors.background,
                                      shape: CircleBorder(),
                                      minimumSize: Size(30, 30), // Adjust the size as needed
                                    ),
                                    child: Transform.rotate(
                                      angle: -pi / 1, // Angle in radians. Use negative angle for counter-clockwise rotation.
                                      child: Transform.scale(
                                        scale: 0.6, // Adjust the scale factor as needed
                                        child: Icon(Icons.arrow_back_ios_new),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),

                        ],
                      ),
                    ),
                  ),
                );

              },
            ),
          ],
        ),
      ),

      bottomNavigationBar:
      CustomBottomAppBar(),




    );
  }
  Future<void> getReports() async {
    // try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken = prefs.getString('access_token') ?? '';
      final response = await http.get(
        Uri.parse('${ApiProvider.baseUrl}/api/fatigue/fatigue-reports'),
        headers: <String, String>{
          'Authorization': 'Bearer $authToken',


        },

      );

      if (response.statusCode == 200) {

        final responseData = json.decode(response.body);

        setState(() {
          // Update your state variable with the response data
          itemsdata = responseData['data'];
          for(int i=0;i<itemsdata.length;i++){
            int id=json.decode(response.body)['data'][i]['report_id'];
           String date=json.decode(response.body)['data'][i]['created_on'];
           double percentage_=json.decode(response.body)['data'][i]['percentage'];
           ReportIds.add(id);//.toString().substring(0,10);
            items.add(date);
            percentage.add(percentage_);
          }
          // Assuming 'items' is your state variable
        });

        print("graphdata===:${response.body}");
        print("itemsdata.length===:${itemsdata.length}");


        return json.decode(response.body);

      }
      else {

        print(response.body);
      }
    // }
    // catch (e) {     // _progressDialog!.hide();

      print("exception:$e");
    }
  //   throw Exception('');
  // }

}

class LeftEyeHealthWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Second Card for Heading and Graph
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 1),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: EdgeInsets.all(1),
                    child :ListTile(
                      title: Text(
                        'Left Eye Health',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('April 30-May 30'),
                    ),),

                  // Container with fixed height to contain the LineChart
                  SizedBox(
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
                                colors: [Colors.deepPurple.withOpacity(0.2)],
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
      ],
    );
  }
}

class RightEyeHealthWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 1),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: EdgeInsets.all(1),
                    child :ListTile(
                      title: Text(
                        'Right Eye Health',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('April 30-May 30'),
                    ),),

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
                                colors: [Colors.deepPurple.withOpacity(0.2)],
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
      ],
    );
  }

}