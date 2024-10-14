import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'POJO.dart';

class BarChartWidget extends StatefulWidget {
  BarChartWidget({@required this.templateJson, @required this.listData, this.isHorizontal = false, this.onItemClick});

  Map<String, dynamic> templateJson;
  List<dynamic> listData;
  bool isHorizontal;
  Function onItemClick;

  @override
  _ScreenState createState() => _ScreenState(
      templateJson: templateJson, listData: listData, isHorizontal: isHorizontal, onItemClick: onItemClick);
}

class _ScreenState extends State<BarChartWidget> {
  _ScreenState({@required this.templateJson, @required this.listData, this.isHorizontal, this.onItemClick});

  Map<String, dynamic> templateJson;
  List<dynamic> listData;
  bool isHorizontal;
  Function onItemClick;

  DarkThemeProvider themeChange;
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    List<SalesDataWithColor> chartData = [];
    // print("TemplateJson BarChart : ${jsonEncode(templateJson)}");
    // templateJson = {
    //   "id": 3,
    //   "title": "Month Wise Sales By TA (Last 12 Months)",
    //   "widget_type": "barchart",
    //   "x_axis": "date",
    //   "y_axis": "sales",
    //   "isTrendLine": "Y",
    //   "barColor": "#6495ED",
    //   "TrendLineType": "Exponential",
    //   "rotate_x": "45",
    //   "rotate_y": "0",
    //   "isShowTooltip": "Y",
    //   "isShowLegend": "Y",
    //   "legendPosition": "bottom",
    //   "enablePitching": "Y",
    //   "enableDoubleTapZooming": "Y",
    //   "enableSelectionZooming": "N",
    //   "trackballBehavior": "Y",
    //   "data": [
    //     {"id": 1, "date": "Sep 2020", "sales": 3133312},
    //     {"id": 2, "date": "Oct 2020", "sales": 679488},
    //     {"id": 3, "date": "Nov 2020", "sales": 156292},
    //     {"id": 4, "date": "Dec 2020", "sales": 317664}
    //   ]
    // };
    // listData = templateJson["data"];

    for (int i = 0; i < listData.length; i++) {
      Map<String, dynamic> map = listData[i];

      chartData.add(SalesDataWithColor(
          map[templateJson["x_axis"].toString()],
          double.parse(map[templateJson["y_axis"]].toString()) * 1.0,
          map.containsKey("color") && map['color'] != null && map['color'] != ""
              ? map['color']
              : templateJson["barColor"] == null || templateJson["barColor"] == ""
                  ? "#1976D2"
                  : templateJson["barColor"]));
    }

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

    bool isShowTitle = false;
    if (templateJson["isShowTitle"] == "Y") {
      isShowTitle = true;
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
      plotAreaBorderWidth: 0,
      enableAxisAnimation: true,
      isTransposed: isHorizontal,
      tooltipBehavior: TooltipBehavior(
          enable: templateJson["isShowTooltip"] != null ? templateJson["isShowTooltip"].toString() == "Y" : true),
      primaryXAxis: CategoryAxis(
        majorGridLines: MajorGridLines(width: 0),
        labelRotation: templateJson["rotate_x"] != null ? int.parse(templateJson["rotate_x"].toString()) : 0,
      ),
      // tap
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
        labelIntersectAction: AxisLabelIntersectAction.multipleRows,
        maximumLabels: 5,
        majorGridLines: MajorGridLines(width: 0.3, color: themeData.hintColor),
        labelRotation: templateJson["rotate_y"] != null ? int.parse(templateJson["rotate_y"].toString()) : 0,
        numberFormat: NumberFormat.compact(),
      ),
      series: <ChartSeries>[
        ColumnSeries<SalesDataWithColor, String>(
          borderRadius: const BorderRadius.all(Radius.circular(3)),
          dataSource: chartData,
          pointColorMapper: (SalesDataWithColor sales, _) => Constants_data.hexToColor(sales.color),
          xValueMapper: (SalesDataWithColor sales, _) => sales.year,
          yValueMapper: (SalesDataWithColor sales, _) => sales.sales,
          animationDuration: 1500,
          enableTooltip: true,
          // onPointTap: (pointInteractionDetails) {
          //   Fluttertoast.showToast(
          //       msg: "This is Center Short Toast",
          //       toastLength: Toast.LENGTH_SHORT,
          //       gravity: ToastGravity.CENTER,
          //       timeInSecForIosWeb: 1,
          //       backgroundColor: Colors.red,
          //       textColor: Colors.white,
          //       fontSize: 16.0
          //   );
          // },
          trendlines: templateJson["isTrendLine"] != null && templateJson["isTrendLine"] == "Y"
              ? <Trendline>[Trendline(type: trendLine, name: "Trendline", color: AppColors.trend_line_color)]
              : null,
          name: templateJson["y_axis"].toString(),
        )
      ],
      enableSideBySideSeriesPlacement: false,
    );
  }
}
