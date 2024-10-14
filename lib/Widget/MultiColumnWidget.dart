import 'dart:convert';

import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'POJO.dart';

class MultiColumnChartWidget extends StatefulWidget {
  MultiColumnChartWidget({@required this.templateJson, @required this.listData});

  Map<String, dynamic> templateJson;
  List<dynamic> listData;

  @override
  _ScreenState createState() => _ScreenState(templateJson: templateJson, listData: listData);
}

class _ScreenState extends State<MultiColumnChartWidget> {
  _ScreenState({@required this.templateJson, @required this.listData});

  Map<String, dynamic> templateJson;
  List<dynamic> listData;

  DarkThemeProvider themeChange;
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    print("Template Json : ${jsonEncode(templateJson)}");
    print("Data : ${jsonEncode(listData)}");
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
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

    bool showSideBySide = false;
    if (templateJson["showSideBySide"] == "Y") {
      trackballBehavior = true;
    }

    bool isShowTitle = false;
    if (templateJson["isShowTitle"] == "Y") {
      isShowTitle = true;
    }

    return SfCartesianChart(
        title: isShowTitle ? ChartTitle(text:templateJson["title"]) : null,
        plotAreaBorderWidth: 0,
        enableSideBySideSeriesPlacement: showSideBySide,
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
        primaryXAxis: CategoryAxis(
          majorGridLines: MajorGridLines(width: 0),
          labelRotation: templateJson["rotate_x"] != null ? int.parse(templateJson["rotate_x"].toString()) : 0,
        ),
        primaryYAxis: NumericAxis(
          labelRotation: templateJson["rotate_y"] != null ? int.parse(templateJson["rotate_y"].toString()) : 0,
          majorTickLines: MajorTickLines(size: 0),
          numberFormat: NumberFormat.compact(),
          majorGridLines: MajorGridLines(width: 0.3, color: themeData.hintColor),
        ),
        series: getBackToBackColumn(templateJson, listData));
  }

  List<ColumnSeries<ChartSampleData, String>> getBackToBackColumn(templateJson, listData) {
    List<ChartSampleData> chartData = [];
    List<String> yaxis = templateJson["y_axis"].toString().split("~");
    if (listData != null) {
      for (int i = 0; i < listData.length; i++) {
        chartData.add(ChartSampleData(
            x: listData[i][templateJson["x_axis"].toString()],
            yValue: double.parse(listData[i][yaxis[0]].toString()),
            yValue2: double.parse(listData[i][yaxis[1]].toString())));
      }
    }

    return <ColumnSeries<ChartSampleData, String>>[
      ColumnSeries<ChartSampleData, String>(
          borderRadius: const BorderRadius.all(Radius.circular(3)),
          animationDuration: 1500,
          enableTooltip: true,
          dataSource: chartData,
          width: 0.7,
          color: AppColors.light_main_color1,
          xValueMapper: (ChartSampleData sales, _) => sales.x,
          yValueMapper: (ChartSampleData sales, _) => sales.yValue2,
          name: yaxis[1].toString()),
      ColumnSeries<ChartSampleData, String>(
          borderRadius: const BorderRadius.all(Radius.circular(3)),
          animationDuration: 1500,
          enableTooltip: true,
          dataSource: chartData,
          width: 0.5,
          color: AppColors.multicolumn_chart_color,
          xValueMapper: (ChartSampleData sales, _) => sales.x,
          yValueMapper: (ChartSampleData sales, _) => sales.yValue ,
          name: yaxis[0].toString()),
    ];
  }
}
