import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'POJO.dart';

class RadialChartWidget extends StatefulWidget {
  RadialChartWidget({@required this.templateJson, @required this.listData});

  Map<String, dynamic> templateJson;
  List<dynamic> listData;

  @override
  _ScreenState createState() => _ScreenState(templateJson: templateJson, listData: listData);
}

class _ScreenState extends State<RadialChartWidget> {
  _ScreenState({@required this.templateJson, @required this.listData});

  Map<String, dynamic> templateJson;
  List<dynamic> listData;

  DarkThemeProvider themeChange;
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);

    Legend legend;
    bool isShowLegend = true;

    if (templateJson["isShowLegend"] == "N") {
      isShowLegend = false;
    }

    LegendPosition pos = LegendPosition.right;
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

    bool isShowTitle = false;
    if (templateJson["isShowTitle"] == "Y") {
      isShowTitle = true;
    }

    return SfCircularChart(
      title: isShowTitle ? ChartTitle(text:templateJson["title"]) : null,
      legend: legend,
      series: getRadialBarDefaultSeries(templateJson, listData),
      tooltipBehavior: TooltipBehavior(enable: true, format: 'point.x : point.y'),
    );
  }

  List<RadialBarSeries<ChartSampleData, String>> getRadialBarDefaultSeries(templateJson, listData) {
    List<ChartSampleData> chartData = [];

    if (listData != null) {
      for (int i = 0; i < listData.length; i++) {
        chartData.add(ChartSampleData(
            x: listData[i]["title"],
            y: listData[i]["sales"],
            text: '100%',
            pointColor: Constants_data.hexToColor(listData[i]["color"])));
      }
    }

    return <RadialBarSeries<ChartSampleData, String>>[
      RadialBarSeries<ChartSampleData, String>(
          maximumValue: templateJson["max_value"] * 1.05,
          dataLabelSettings: DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(
                  fontSize: Constants_data.getFontSize(context, 12),
                  color: themeData.textTheme.caption.color,
                  fontWeight: FontWeight.bold)),
          dataSource: chartData,
          gap: '10%',
          radius: '90%',
          legendIconType: LegendIconType.circle,
          cornerStyle: CornerStyle.bothCurve,
          xValueMapper: (ChartSampleData data, _) => data.x,
          yValueMapper: (ChartSampleData data, _) => data.y,
          pointRadiusMapper: (ChartSampleData data, _) => data.text,
          pointColorMapper: (ChartSampleData data, _) => data.pointColor,
          trackColor: Colors.transparent)
    ];
  }
}
