/// Package import
import 'package:flutter/material.dart';

/// Chart import
import 'package:syncfusion_flutter_charts/charts.dart';

class SplineDefault extends StatefulWidget {
  const SplineDefault({super.key});

  @override
  State<SplineDefault> createState() => _SplineDefaultState();
}



///Chart sample data

/// Chart Sales Data


class _SplineDefaultState extends State<SplineDefault> {



















  List<_ChartData>? chartData;

  @override
  void initState() {
    chartData = <_ChartData>[
      _ChartData('6 AM', 2, 7,7,9),
      _ChartData('12 PM', 1, 2,10,7),
      _ChartData('6 PM', 5, 3,5,1),
      _ChartData('12 AM', 3,1, 2,1),

    ];
    super.initState();
  }

  @override

  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 350,
          height: 290,
          child: Center(
            child: SizedBox(
              width: 330,
              height: 250,
              child: _buildVerticalSplineChart(),
            ),
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
        ),
      ],
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
  /// Returns the vertical spline chart.
SfCartesianChart _buildVerticalSplineChart() {
    return SfCartesianChart(
      isTransposed: false,
      title: ChartTitle(text:  'EYE Health Graph - 2024'),
      plotAreaBorderWidth: 0,
      legend: Legend(isVisible:true),
      primaryXAxis: const CategoryAxis(
          majorTickLines: MajorTickLines(size: 0),
          axisLine: AxisLine(width: 1),
        majorGridLines: MajorGridLines(width: 0),      title: AxisTitle(text: 'time slots'), // Description for X axis
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
        name: 'Percentile',color:Colors.orange ,
        xValueMapper: (_ChartData sales, _) => sales.x,
        yValueMapper: (_ChartData sales, _) => sales.y3,
      ),
      SplineSeries<_ChartData, String>(
        markerSettings: const MarkerSettings(isVisible: true),
        dataSource: chartData,color: Colors.background,
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
