import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package

class ReportPage extends StatefulWidget {
  @override
  ReportPageState createState() => ReportPageState();
}

class ReportPageState extends State<ReportPage> {
  bool isSelected = false;
  bool isLeftEyeSelected = false;
  List<double> data1 = [10, 30, 20, 40, 30]; // Sample data for line 1
  List<double> data2 = [30, 50, 60, 50, 60]; // Sample data for line 2

  final List<String> items = [
  'Item 1 - 10:00 AM, 2024-05-14',
  'Item 2 - 11:30 AM, 2024-05-15',
  'Item 3 - 02:45 PM, 2024-05-16',
  ];
  String testResult='Good';

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMMM').format(DateTime.now());
    return Scaffold(
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
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 0, 0, 8),
              child: Text(
                'Today $formattedDate', // Display formatted current date
                style: TextStyle(
                  fontStyle: FontStyle.normal,
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.grey[200],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isLeftEyeSelected = true;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(35),
                            color: isLeftEyeSelected ? Colors.white : Colors
                                .transparent,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 8),
                            child: Text(
                              'Left Eye Health',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isLeftEyeSelected = false;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(23),
                            color: !isLeftEyeSelected ? Colors.white : Colors
                                .transparent,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Right Eye Health',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
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
              padding: EdgeInsets.fromLTRB(16.0, 10, 15, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Eye Fatigue Statistics',
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
            SizedBox(height: 20),
            // Add spacing between the row and the eye health widgets
            isLeftEyeSelected ? LeftEyeHealthWidget() : RightEyeHealthWidget(),
            // Text and toggle button below the graph
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
              physics: NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Container(
                    color: Colors.white, // Background color of the box
                    padding: EdgeInsets.all(8), // Padding around the content
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                items[index].substring(items[index].indexOf('-') + 2),
                                style: TextStyle(fontStyle: FontStyle.normal),
                              ),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: 'Test Result: ',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    TextSpan(
                                      text: testResult,
                                      style: TextStyle(
                                        color: testResult == 'Good' ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0,0,0),
                            child: ElevatedButton(
                              onPressed: () {
                                // Add button onPressed logic here
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white, backgroundColor: Colors.indigo.shade900,
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
                          )
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
    );
  }}

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