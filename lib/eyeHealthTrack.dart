import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package

class EyeHealthTrackDashboard extends StatefulWidget {
  @override
  EyeHealthTrackDashboardState createState() => EyeHealthTrackDashboardState();
}

class EyeHealthTrackDashboardState extends State<EyeHealthTrackDashboard> {
  bool isSelected = false;
  bool isLeftEyeSelected = false;
  List<double> data1 = [10, 30, 20, 40, 30]; // Sample data for line 1
  List<double> data2 = [30, 50, 60, 50, 60]; // Sample data for line 2
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMMM').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: Text('Eye Health Track'),
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
              padding: EdgeInsets.fromLTRB(16.0, 6, 0, 8),
              child: Text(
                'Today $formattedDate', // Display formatted current date
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Image.asset('assets/banner1.png'),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 10, 0, 10),
              child: Text(
                'EYE HEALTH STATUS', // Display formatted current date
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
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
                              Text('value',style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('No. of digital eye test'),
                              Text('Value ',style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16), // Add spacing between the row and the additional columns
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Prescription uploaded'),
                              Text('value',style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('visit to optemistist'),
                              Text('Value',style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 10, 0, 10),
              child: Text(
                'EYE HEALTH GRAPH OVERVIEW', // Display formatted current date
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            AspectRatio(
              aspectRatio: 1.40,
              child:Padding(padding: EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16,15,16,4),
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              for (int i = 0; i < data1.length; i++)
                                FlSpot(i.toDouble(), data1[i]),
                            ],
                            isCurved: true,
                            colors: [Colors.lightBlue],
                            barWidth: 4,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(
                              show: true,
                              colors: [Colors.lightBlue.withOpacity(0.2)],
                            ),
                          ),
                          LineChartBarData(
                            spots: [
                              for (int i = 0; i < data2.length; i++)
                                FlSpot(i.toDouble(), data2[i]),
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
                          leftTitles: SideTitles(
                            showTitles: false,
                          ),
                          bottomTitles: SideTitles(
                            showTitles: true,
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          drawHorizontalLine: false,
                          // Remove horizontal lines
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
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
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(23),
                            color: isLeftEyeSelected ? Colors.white : Colors.transparent,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
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

                            color: !isLeftEyeSelected ? Colors.white : Colors.transparent,
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

            SizedBox(height: 20), // Add spacing between the row and the eye health widgets
            isLeftEyeSelected ? LeftEyeHealthWidget() : RightEyeHealthWidget(),
      // Text and toggle button below the graph
          ],
        ),
      ),
     );
  }
}

class LeftEyeHealthWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First Card for Image, Label, and Text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 1),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListTile(
                leading: Image.asset('assets/lefteye.png'),
                title: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Label 1:'),
                            Text('value'),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Label 2'),
                            Text('Value '),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16), // Add spacing between the row and the additional columns
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Label'),
                            Text('value'),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Label'),
                            Text('Value'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
        // First Card for Image, Label, and Text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical:1),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListTile(
                leading: Image.asset('assets/righteye.png'),
                title: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Label 1:'),
                            Text('value'),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Label 2'),
                            Text('Value '),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16), // Add spacing between the row and the additional columns
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Label'),
                            Text('value'),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Label'),
                            Text('Value'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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

