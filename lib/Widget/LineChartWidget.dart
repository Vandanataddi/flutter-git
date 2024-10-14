import 'dart:convert';

import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'POJO.dart';

class LineChartWidget extends StatefulWidget {
  LineChartWidget({@required this.templateJson, @required this.listData, this.isMultiline = false, this.onItemClick});

  Map<String, dynamic> templateJson;
  List<dynamic> listData;
  bool isMultiline;
  Function onItemClick;

  @override
  _ScreenState createState() =>
      _ScreenState(templateJson: templateJson, listData: listData, isMultiline: isMultiline, onItemClick: onItemClick);
}

class _ScreenState extends State<LineChartWidget> {
  _ScreenState({@required this.templateJson, @required this.listData, this.isMultiline, this.onItemClick});

  Map<String, dynamic> templateJson;
  List<dynamic> listData;
  bool isMultiline;
  Function onItemClick;

  DarkThemeProvider themeChange;
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    // templateJson = {
    //   "id": 3,
    //   "title": "Month Wise Sales By TA (Last 12 Months)",
    //   "widget_type": "barchart",
    //   "x_axis": "date",
    //   "y_axis": "sales",
    //   "barColor": "#6495ED",
    //   "isTrendLine": "Y",
    //   "TrendLineType": "Exponential",
    //   "rotate_x": "0",
    //   "rotate_y": "0",
    //   "isShowTooltip": "Y",
    //   "isShowLegend": "Y",
    //   "legendPosition": "bottom",
    //   "enablePitching": "Y",
    //   "enableDoubleTapZooming": "Y",
    //   "enableSelectionZooming": "Y",
    //   "trackballBehavior": "N",
    //   "isShowMarker": "Y",
    //   "data": [
    //     {"id": 1, "date": "Jan 2020", "sales": "3133312"},
    //     {"id": 1, "date": "Feb 2020", "sales": "3233312"},
    //     {"id": 2, "date": "Mar 2020", "sales": "679488"},
    //     {"id": 2, "date": "Apr 2020", "sales": 979488},
    //     {"id": 3, "date": "May 2020", "sales": 156292},
    //     {"id": 3, "date": "Jun 2020", "sales": 206292},
    //     {"id": 4, "date": "Jul 2020", "sales": 317664},
    //     {"id": 4, "date": "Aug 2020", "sales": 407664}
    //   ]
    // };
    //listData = templateJson["data"];

    TrendlineType trendLine = TrendlineType.movingAverage;
    if (templateJson["TrendLineType"] == "Linear") {
      trendLine = TrendlineType.linear;
    } else if (templateJson["TrendLineType"] == "MovingAverage") {
      trendLine = TrendlineType.movingAverage;
    } else if (templateJson["TrendLineType"] == "Exponential") {
      trendLine = TrendlineType.exponential;
    } else if (templateJson["TrendLineType"] == "Logarithmic") {
      trendLine = TrendlineType.logarithmic;
    } else if (templateJson["TrendLineType"] == "Polynomial") {
      trendLine = TrendlineType.polynomial;
    } else if (templateJson["TrendLineType"] == "Power") {
      trendLine = TrendlineType.power;
    }

    Legend legend;
    bool isShowLegend = true;

    if (templateJson["isShowLegend"] == "N") {
      isShowLegend = false;
    }

    LegendPosition pos = LegendPosition.bottom;
    if (templateJson["legendPosition"] == "top") {
      pos = LegendPosition.top;
    } else if (templateJson["legendPosition"] == "bottom") {
      pos = LegendPosition.bottom;
    } else if (templateJson["legendPosition"] == "left") {
      pos = LegendPosition.left;
    } else if (templateJson["legendPosition"] == "right") {
      pos = LegendPosition.right;
    } else if (templateJson["legendPosition"] == "auto") {
      pos = LegendPosition.auto;
    }
    legend =
        Legend(isVisible: isShowLegend, position: pos, textStyle: TextStyle(color: themeData.textTheme.caption.color));

    bool enablePitching = false;
    if (templateJson["enablePitching"] == "Y") {
      enablePitching = true;
    }

    bool enableDoubleTapZooming = false;
    if (templateJson["enableDoubleTapZooming"] == "Y") {
      enableDoubleTapZooming = true;
    }

    bool enableSelectionZooming = false;
    if (templateJson["enableSelectionZooming"] == "Y") {
      enableSelectionZooming = true;
    }

    bool trackballBehavior = false;
    if (templateJson["trackballBehavior"] == "Y") {
      trackballBehavior = true;
    }

    bool isShowMarker = false;
    if (templateJson["isShowMarker"] == "Y") {
      isShowMarker = true;
    }

    bool isSplineChart = false;
    if (templateJson["isSpline"] == "Y") {
      isSplineChart = true;
    }

    bool isShowTitle = false;
    if (templateJson["isShowTitle"] == "Y") {
      isShowTitle = true;
    }

    List<ChartSeries> getMultiLineSeries(templateJson, listData, trendLine) {
      List<ChartSeries> listCharts = [];
      if (listData != null) {
        var arr_y_axis = templateJson["y_axis"].toString().split("~");
        for (int axis = 0; axis < arr_y_axis.length; axis++) {
          List<SalesData> chartData = [];
          print("AAAAAAA " + arr_y_axis[axis].toString());
          int count_null = 0, count_remaining = 0;
          ;
          for (int i = 0; i < listData.length; i++) {
            if (listData[i][arr_y_axis[axis].toString()] == null) {
              count_null++;
            }
            if (count_null > 0) {
              count_remaining++;
            }
          }
          bool null_is_zero = false;
          if (count_remaining > count_null) {
            null_is_zero = true;
          } else if (count_null == listData.length) {
            null_is_zero = true;
          }
          for (int i = 0; i < listData.length; i++) {
            print("data : ${listData[i][arr_y_axis[axis].toString()]}");

            if (listData[i][arr_y_axis[axis].toString()] == null) {
              if (null_is_zero) {
                chartData.add(SalesData(listData[i][templateJson["x_axis"].toString()], 0.0));
              } else {
                break;
              }
            } else {
              chartData.add(SalesData(
                  listData[i][templateJson["x_axis"].toString()], listData[i][arr_y_axis[axis].toString()] * 1.0));
            }
          }

          if (isSplineChart) {
            listCharts.add(SplineSeries<SalesData, String>(
              dataSource: chartData,
              markerSettings: MarkerSettings(isVisible: isShowMarker),
              xValueMapper: (SalesData sales, _) => sales.year,
              yValueMapper: (SalesData sales, _) => sales.sales,
              color: AppColors.getCircularChartColor(axis),
              name: arr_y_axis[axis].toString(),
              animationDuration: 1500,
              enableTooltip: true,
              width: 2,
            ));
          } else {
            listCharts.add(LineSeries<SalesData, String>(
              dataSource: chartData,
              markerSettings: MarkerSettings(isVisible: isShowMarker),
              xValueMapper: (SalesData sales, _) => sales.year,
              yValueMapper: (SalesData sales, _) => sales.sales,
              color: AppColors.getCircularChartColor(axis),
              name: arr_y_axis[axis].toString(),
              animationDuration: 1500,
              enableTooltip: true,
              width: 2,
            ));
          }
        }
      }
      return listCharts;
    }
    List<ChartSeries> getDefaultLineSeries(templateJson, listData, trendLine) {
      print("ListData : ${jsonEncode(listData)}");
      List<SalesData> chartData = [];
      if (listData != null) {
        for (int i = 0; i < listData.length; i++) {
          if (listData[i][templateJson["y_axis"]].toString() == null) {
            break;
          }
          chartData.add(SalesData(
            listData[i][templateJson["x_axis"].toString()].toString(),
            double.parse(listData[i][templateJson["y_axis"]].toString()) * 1.0,
          ));
        }
      }

      List<ChartSeries> listCharts = [];
      if (isSplineChart) {
        listCharts.add(SplineSeries<SalesData, String>(
          dataSource: chartData,
          markerSettings: MarkerSettings(isVisible: isShowMarker),
          xValueMapper: (SalesData sales, _) => sales.year,
          yValueMapper: (SalesData sales, _) => sales.sales,
          name: templateJson["y_axis"].toString(),
          animationDuration: 1500,
          enableTooltip: true,
          width: 2,
          trendlines: templateJson["isTrendLine"] != null && templateJson["isTrendLine"] == "Y"
              ? <Trendline>[Trendline(type: trendLine, name: "Trendline", color: AppColors.trend_line_color)]
              : null,
        ));
      } else {
        listCharts.add(LineSeries<SalesData, String>(
          dataSource: chartData,
          markerSettings: MarkerSettings(isVisible: isShowMarker),
          xValueMapper: (SalesData sales, _) => sales.year,
          yValueMapper: (SalesData sales, _) => sales.sales,
          name: templateJson["y_axis"].toString(),
          animationDuration: 1500,
          enableTooltip: true,
          width: 2,
          trendlines: templateJson["isTrendLine"] != null && templateJson["isTrendLine"] == "Y"
              ? <Trendline>[Trendline(type: trendLine, name: "Trendline", color: AppColors.trend_line_color)]
              : null,
        ));
      }
      return listCharts;
    }

    return SfCartesianChart(

      title: isShowTitle ? ChartTitle(text:templateJson["title"]) : null,
      zoomPanBehavior: ZoomPanBehavior(
        // Enables pinch zooming
        enablePinching: enablePitching,
        enableDoubleTapZooming: enableDoubleTapZooming,
        enableSelectionZooming: enableSelectionZooming,
      ),
      legend: legend,
      trackballBehavior: TrackballBehavior(
          // Enables the trackball
          enable: trackballBehavior,
          tooltipSettings: InteractiveTooltip(enable: true, color: AppColors.red_color)),
      tooltipBehavior: TooltipBehavior(
          enable: templateJson["isShowTooltip"] != null ? templateJson["isShowTooltip"].toString() == "Y" : true),
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        majorGridLines: MajorGridLines(width: 0),
        labelRotation: templateJson["rotate_x"] != null ? int.parse(templateJson["rotate_x"].toString()) : 0,
      ),
      onDataLabelTapped : onItemClick != null
          ? (DataLabelTapDetails args) {
        onItemClick(listData[args.pointIndex], args.pointIndex);
      }
          : null,
      // onPointTapped: onItemClick != null
      //     ? (PointTapArgs args) {
      //         onItemClick(listData[args.pointIndex], args.pointIndex);
      //       }
      //     : null,
      primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compact(),
          labelRotation: templateJson["rotate_y"] != null ? int.parse(templateJson["rotate_y"].toString()) : 0,
          // axisLine: AxisLine(width: 0),
          majorGridLines: MajorGridLines(width: 0.3,color: themeData.hintColor),
          maximumLabels: 6),
      series: isMultiline
          ? getMultiLineSeries(templateJson, listData, trendLine)
          : getDefaultLineSeries(templateJson, listData, trendLine),
    );
  }
}
