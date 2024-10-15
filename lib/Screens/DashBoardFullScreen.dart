import 'dart:collection';

import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flexi_profiler/Widget/BarChartWidget.dart';
import 'package:flexi_profiler/Widget/DonutChartWidget.dart';
import 'package:flexi_profiler/Widget/GaugeChartWidget.dart';
import 'package:flexi_profiler/Widget/GridViewWidget.dart';
import 'package:flexi_profiler/Widget/LineChartWidget.dart';
import 'package:flexi_profiler/Widget/ListViewWidget.dart';
import 'package:flexi_profiler/Widget/MultiColumnWidget.dart';
import 'package:flexi_profiler/Widget/PieChartWidget.dart';
import 'package:flexi_profiler/Widget/RadialChartWidget.dart';
import 'package:flexi_profiler/Widget/TableWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ChartItemDetailsScreen.dart';

class DashBoardFullScreen extends StatefulWidget {
  final dynamic msgData;
  final DateTime selectedDate;

  DashBoardFullScreen({Key key, @required this.msgData, this.selectedDate}) : super(key: key);

  @override
  State createState() => _DetailsScreen(msgData: msgData, selectedDate: selectedDate);
}

class _DetailsScreen extends State<DashBoardFullScreen> {
  _DetailsScreen({@required this.msgData, this.selectedDate});

  final dynamic msgData;
  final DateTime selectedDate;

  bool isChangableChart = false;
  bool isOriginal = true;

  double height;
  double width;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("Received Data : $msgData");
  }

  DarkThemeProvider themeChange;
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    Constants_data.currentScreenContext = context;
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    Constants_data.currentScreenContext = context;
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    IconData icon;
    if (msgData["widget_type"] == "barchart") {
      if (!isOriginal) {
        icon = Icons.bar_chart;
      }
      else {
        icon = Icons.timeline;
      }
    }
    // TODO: implement build
    return Hero(
      tag: "photo${msgData["title"]}",
      child: Material(
          child: Scaffold(appBar: AppBar(
          flexibleSpace: Constants_data.getFlexibleAppBar(themeChange.darkTheme),
          // actions: [
          //   InkWell(
          //       onTap: () {
          //         this.setState(() {
          //           isOriginal = !isOriginal;
          //         });
          //       },
          //       child: Container(
          //         margin: EdgeInsets.only(right: 10, left: 10),
          //         child: Icon(icon),
          //       ))
          // ],
          title: Text("${msgData["title"]}"),
        ),
        body: Container(child: getChildView(msgData)),
      )),
    );
  }

  Widget getChildView(var data) {
    if (data["data"].length == 0) {
      return Center(
        child: Container(
          child: Text("Data not available"),
        ),
      );
    } else if (data["widget_type"] == "multicolumn") {
      return MultiColumnChartWidget(templateJson: data, listData: data["data"]);
    } else if (data["widget_type"] == "barchart") {
      return BarChartWidget(listData: data["data"], templateJson: data);
    } else if (data["widget_type"] == "Table") {
      return TableWidget(templateJson: data, listData: data["data"]);
    } else if (data["widget_type"] == "pie") {
      data["legendPosition"] = "bottom";
      return PieChartWidget(templateJson: data, listData: data["data"]);
    } else if (data["widget_type"] == "doughnut") {
      data["legendPosition"] = "bottom";
      return DonutChartWidget(templateJson: data, listData: data["data"]);
    } else if (data["widget_type"] == "line") {
      return LineChartWidget(templateJson: data, listData: data["data"]);
    } else if (data["widget_type"] == "multiline") {
      return LineChartWidget(templateJson: data, listData: data["data"], isMultiline: true);
    } else if (data["widget_type"] == "gauge") {
      return GaugeChartWidget(templateJson: data, listData: data["data"]);
    } else if (data["widget_type"] == "horizontalbarchart") {
      return BarChartWidget(
        listData: data["data"],
        templateJson: data,
        isHorizontal: true,
      );
    } else if (data["widget_type"] == "radial") {
      data["legendPosition"] = "bottom";
      return RadialChartWidget(templateJson: data, listData: data["data"]);
    } else if (data["widget_type"] == "grid") {
      return GridViewWidget(
        listData: data["data"],
        numOfCols: int.parse(data["num_of_cols"].toString()),
        templateJson: data,
      );
    } else if (data["widget_type"] == "listview") {
      List<dynamic> listItems = data["data"];
      var templateJson = data["template_json"];
      return ListViewWidget(
          templateJson: templateJson,
          listData: listItems,
          onItemClick: templateJson["isClickable"] == "Y"
              ? (data, index) async {
                  Map<String, dynamic> dataToSend = new HashMap();
                  List<String> params = [];
                  if (templateJson["Params"].toString().contains(",")) {
                    params = templateJson["Params"].toString().split(",");
                  } else {
                    params.add(templateJson["Params"].toString());
                  }
                  print("All Data  : $data");

                  Map<String, dynamic> jsonParam = new HashMap();
                  for (int i = 0; i < params.length; i++) {
                    jsonParam[params[i]] = data["AccountId"];
                  }
                  dataToSend["ParentWidgetId"] = templateJson["ParentWidgetId"];
                  dataToSend["jsonParam"] = jsonParam;
                  dataToSend["Rep_Id"] = Constants_data.repId;
                  dataToSend["title_value"] = dataToSend["title_value"] = data["AccountName"];
                  dataToSend["selectedDate"] = selectedDate;
                  print("DataToSend : $dataToSend");
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChartItemDetailsScreen(dataToSend),
                    ),
                  );
                }
              : null);
    } else {
      return Center(
        child: Container(
          child: Text("Widget not available"),
        ),
      );
    }
  }
}
