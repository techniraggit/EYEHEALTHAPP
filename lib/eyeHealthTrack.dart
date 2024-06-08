import 'dart:async';
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:http/http.dart' as http;

import 'package:fl_chart/fl_chart.dart'hide AxisTitle;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Custom_navbar/bottom_navbar.dart';
import 'HomePage.dart';
import 'api/config.dart';
import 'models/fatigueGraphModel.dart';

class EyeHealthTrackDashboard extends StatefulWidget {
  @override
  EyeHealthTrackDashboardState createState() => EyeHealthTrackDashboardState();
}

class EyeHealthTrackDashboardState extends State<EyeHealthTrackDashboard> {
  bool fatigue_left=false; List<double>? _data;int i=0;
  bool fatigue_right=false;fatigueGraph? fatigueGraphData;
  bool midtiredness_right= false;List<double> todaygraphData = [];
  List<double> firstTestgraphData = [];
  bool midtiredness_left=false;
  String no_of_eye_test="0";String eye_health_score="";String name="";String no_of_fatigue_test="0";


  // Future<List<double>> getGraph() async {
  //   // try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String authToken = prefs.getString('access_token') ?? '';
  //     final response = await http.get(
  //       Uri.parse('${ApiProvider.baseUrl}/api/fatigue/fatigue-graph?user_timezone=Asia/Kolkata'),
  //       headers: <String, String>{
  //         'Authorization': 'Bearer $authToken',
  //       },
  //
  //     );
  //
  //     if (response.statusCode == 200) {
  //
  //       final responseData = json.decode(response.body);
  //       fatigueGraphData = fatigueGraph.fromJson(responseData);
  //
  //
  //       print("graphdata===:${response.body}");
  //
  //       Map<String, dynamic> jsonData = jsonDecode(response.body);
  //       List<dynamic> data = jsonData['data'];
  //       // name=jsonData['name'];
  //
  //       // fatigue_left=data[0]['is_fatigue_left'];
  //       // fatigue_right=data[0]['is_fatigue_right'];
  //       // midtiredness_right=data[0]['is_mild_tiredness_right'];
  //       // midtiredness_left=data[0]['is_mild_tiredness_left'];
  //       int no_of_fatigue=jsonData['no_of_fatigue_test'];
  //       int  no_of_eye_=jsonData['no_of_eye_test'];
  //       double eye_hscore=jsonData['eye_health_score'];
  //       setState(() {
  //         no_of_fatigue_test=no_of_fatigue.toString();
  //         no_of_eye_test=no_of_eye_.toString();
  //         eye_health_score=eye_hscore.toString();
  //       });
  //
  //       return data.map((item) => double.parse(item['value'].toString())).toList();
  //
  //     }
  //     else {
  //
  //       print(response.body);
  //     }
  //   // }
  //   // catch (e) {     // _progressDialog!.hide();
  //
  //     // print("exception:$e");
  //   // }
  //   throw Exception('');
  // }
  Future<void> getGraph() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('access_token') ?? '';
    final response = await http.get(
      Uri.parse('${ApiProvider.baseUrl}/api/fatigue/fatigue-graph?user_timezone=Asia/Kolkata'),
      headers: <String, String>{
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);


      if (responseData.containsKey('status') && responseData['status']) {
        if (responseData.containsKey('first_day_data') && responseData['first_day_data'].containsKey('value')) {
          List<dynamic> firstDayValue = responseData['first_day_data']['value'];
          firstTestgraphData.addAll(firstDayValue.map((value) => value.toDouble()));
        }
        if (responseData.containsKey('current_day_data') && responseData['current_day_data'].containsKey('value')) {
          List<dynamic> currentDayValue = responseData['current_day_data']['value'];
          todaygraphData.addAll(currentDayValue.map((value) => value.toDouble()));
        }
      }
print("fffffffffffffff$todaygraphData");
      setState(() {
        chartData = <_ChartData>[
          _ChartData('6 AM', firstTestgraphData[0], 9,7,todaygraphData[0]),
          _ChartData('12 PM', firstTestgraphData[1], 8.5,10,todaygraphData[1]),
          _ChartData('6 PM', firstTestgraphData[2], 6.5,5,todaygraphData[2]),
          _ChartData('12 AM', firstTestgraphData[3],6, 2,todaygraphData[3]),

        ];
      });

      // return graphData;
    } else {
      throw Exception('Failed to load graph data');
    }
  }
  List<_ChartData>? chartData;

  @override
  void initState() {
    super.initState();

    getGraph();


  }





  bool isSelected = false;
  bool isLeftEyeSelected = false;
  List<double> data1 = [10, 30, 20, 40, 30]; // Sample data for line 1
  List<double> data2 = [30, 50, 60, 50, 60]; // Sample data for line 2
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
        title: const Text('Eye Health Track'),
        actions: <Widget>[
          // ExampleAlarmHomeShortcutButton(refreshAlarms: loadAlarms),

          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () async {
              print("asdklaskldjaskldasjkdjlkas");
              // navigateToAlarmScreen(null);



            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 6, 0, 8),
              child: Text(
                'Today $formattedDate', // Display formatted current date
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                color: Colors.white,
                child: ListTile(
                  title: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Fatigue Right'),
                              Text(
                                fatigue_right ? 'Yes' : 'No',

                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 3,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Mild Tiredness Right'),
                              Text(
                                midtiredness_right ? 'Yes' : 'No',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Add spacing between the row and the additional columns
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Fatigue left'),
                              Text(

                                fatigue_left ? 'Yes' : 'No',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Mild Tiredness Left'),
                              Text(
                                midtiredness_left ? 'Yes' : 'No',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
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
                ),
              ),
            ),
            Container(
              color: Colors.white,

              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 16.0, vertical: 1),
                child: Container(
                  color: Colors.white,

                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    color: Colors.white,
                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // Padding(
                        //   padding: EdgeInsets.all(1),
                        //   child: ListTile(
                        //     title: Text(
                        //       'Right Eye Health',
                        //       style: TextStyle(
                        //         fontSize: 16.0,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //     subtitle: Text('April 30-May 30'),
                        //   ),
                        // ),
                                  if(chartData!=null)...{
                                      Center(

                    child: Container(
                    color: Colors.white,

                        child: _buildVerticalSplineChart(),


                    ),
                                      ),
                        SizedBox(height: 10), // Adjust spacing between chart and color descriptions

                        // Color descriptions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildColorDescription(Colors.black, 'First Test'),
                            _buildColorDescription(Colors.green, 'Ideal'),
                            _buildColorDescription(Colors.orange, 'Percentile'),
                            _buildColorDescription(Colors.blue, 'User avg'),
                          ],
                        ),},
                        SizedBox(height: 29),
                      ],
                    ),
                  ),
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
  Widget _buildColorDescription(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          color: color,
          margin: EdgeInsets.only(right: 5),
        ),
        Text(text),
      ],
    );
  }


  SfCartesianChart _buildVerticalSplineChart() {
    return SfCartesianChart(
      isTransposed: false,
      // title: ChartTitle(text:  'EYE Health Graph - 2024'),
      plotAreaBorderWidth: 0,
      legend: Legend(isVisible:true),
      primaryXAxis: const CategoryAxis(
        majorTickLines: MajorTickLines(size: 0),
        axisLine: AxisLine(width: 1),
        majorGridLines: MajorGridLines(width: 0),
        title:  AxisTitle(text: 'time slots'), // Description for X axis
      ),// Disable vertical inner gridlines

      primaryYAxis: const NumericAxis(
          minimum: 0,
          maximum: 11,
          interval: 1,
          labelFormat: '{value}',      title: AxisTitle(text: 'eye score'), // Description for X axis

          majorGridLines: MajorGridLines(width: 1)),
      series: _getVerticalSplineSeries(),
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }


  List<SplineSeries<_ChartData, String>> _getVerticalSplineSeries() {
    return <SplineSeries<_ChartData, String>>[
      SplineSeries<_ChartData, String>(
          markerSettings: const MarkerSettings(isVisible: true),
          dataSource: chartData,color: Colors.black,
          xValueMapper: (_ChartData sales, _) => sales.x,
          yValueMapper: (_ChartData sales, _) => sales.y,
          name: 'First Test'),
      SplineSeries<_ChartData, String>(
        markerSettings: const MarkerSettings(isVisible: true),
        dataSource: chartData,
        name: 'Ideal',color: Colors.green,
        xValueMapper: (_ChartData sales, _) => sales.x,
        yValueMapper: (_ChartData sales, _) => sales.y2,
      ),
      SplineSeries<_ChartData, String>(
        markerSettings: const MarkerSettings(isVisible: true),
        dataSource: chartData,
        name: 'over 3.5 lac users',color:Colors.orange ,
        xValueMapper: (_ChartData sales, _) => sales.x,
        yValueMapper: (_ChartData sales, _) => sales.y3,
      ),
      SplineSeries<_ChartData, String>(
        markerSettings: const MarkerSettings(isVisible: true),
        dataSource: chartData,color: Colors.blue,
        name: 'User avg',
        xValueMapper: (_ChartData sales, _) => sales.x,
        yValueMapper: (_ChartData sales, _) => sales.y4,
      )
    ];
  }

  @override
  void dispose() {
    chartData!.clear();
    super.dispose();
  }
}
/// Private class for storing the spline series data points.
class _ChartData {
  _ChartData(this.x, this.y, this.y2, this.y3, this.y4);
  final String x;
  final double y;
  final double y2;
  final double y3;
  final double y4;

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
                title: const Column(
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
                  const Padding(padding: EdgeInsets.all(1),
                    child :ListTile(
                      title: Text(
                        'Left Eye Health',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // subtitle: Text('April 30-May 30'),
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
                title: const Column(
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
                  // Padding(padding: EdgeInsets.all(1),
                    // child :ListTile(
                    //   title: Text(
                    //     'Right Eye Health',
                    //     style: TextStyle(
                    //       fontSize: 16.0,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    //   subtitle: Text('April 30-May 30'),
                    // ),),

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

