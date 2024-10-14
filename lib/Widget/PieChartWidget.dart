import 'dart:convert';

import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'POJO.dart';

class PieChartWidget extends StatefulWidget {
  PieChartWidget({@required this.templateJson, @required this.listData});

  Map<String, dynamic> templateJson;
  List<dynamic> listData;

  @override
  _ScreenState createState() => _ScreenState(templateJson: templateJson, listData: listData);
}

class _ScreenState extends State<PieChartWidget> {
  _ScreenState({@required this.templateJson, @required this.listData});

  Map<String, dynamic> templateJson;
  List<dynamic> listData;

  DarkThemeProvider themeChange;
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    print("Template Json : ${jsonEncode(templateJson)}");
    print("Data : ${listData}");
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
    legend = Legend(isVisible: isShowLegend, position: pos, overflowMode: LegendItemOverflowMode.wrap, textStyle: TextStyle(color: themeData.textTheme.caption.color));

    bool isShowTitle = false;
    if (templateJson["isShowTitle"] == "Y") {
      isShowTitle = true;
    }

    return SfCircularChart(
        title: isShowTitle ? ChartTitle(text:templateJson["title"]) : null,
        tooltipBehavior: TooltipBehavior(enable: true, format: 'point.x'),
        legend: legend,
        series: <PieSeries<PieChartSampleData, String>>[
          PieSeries<PieChartSampleData, String>(
              radius: "90%",
              explode: true,
              explodeIndex: 0,
              explodeOffset: '10%',
              dataSource: getDataSourcePieChart(
                listData,
                templateJson["x_axis"].toString(),
                templateJson["y_axis"].toString(),
              ),
              xValueMapper: (PieChartSampleData data, _) => data.x,
              yValueMapper: (PieChartSampleData data, _) => data.y,
              pointColorMapper: (PieChartSampleData data, int index) {
                return AppColors.getCircularChartColor(index);
              },
              dataLabelMapper: (PieChartSampleData data, _) => data.text,
              startAngle: 90,
              endAngle: 90,
              // enableSmartLabels: true,
              dataLabelSettings: DataLabelSettings(isVisible: true, textStyle: TextStyle(color: AppColors.white_color)))
        ]);
  }

  getDataSourcePieChart(List<dynamic> listData, String xAxis, String yAxis) {
    List<PieChartSampleData> list = [];
    double total = 0;
    for (int i = 0; i < listData.length; i++) {
      total += double.parse(listData[i][yAxis].toString());
    }

    for (int i = 0; i < listData.length; i++) {
      double per = double.parse(listData[i][yAxis].toString()) * 100 / total;
      list.add(PieChartSampleData(
          x: listData[i][xAxis].toString(),
          y: double.parse(listData[i][yAxis].toString()),
          text: "${double.parse((per).toStringAsFixed(2))} %"));
    }
    return list;
  }
}
