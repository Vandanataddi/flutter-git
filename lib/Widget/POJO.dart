import 'dart:ui';

class SalesData {
  SalesData(this.year, this.sales);

  final String year;
  final double sales;
}

class SalesDataWithColor {
  SalesDataWithColor(this.year, this.sales, this.color);

  final String year;
  final String color;
  final double sales;
}

class ChartSampleData {
  ChartSampleData(
      {this.x, this.y, this.xValue, this.yValue, this.yValue2, this.yValue3, this.pointColor, this.size, this.text});

  final dynamic x;
  final num y;
  final dynamic xValue;
  final num yValue;
  final num yValue2;
  final num yValue3;
  final Color pointColor;
  final num size;
  final String text;
}

class PieChartSampleData {
  PieChartSampleData({this.x, this.y, this.text});

  final dynamic x;
  final double y;
  final String text;
}
