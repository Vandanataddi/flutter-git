import 'dart:collection';

import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Constants/MonthPicker/month_picker_dialog.dart';
import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
import 'package:flexi_profiler/Widget/BarChartWidget.dart';
import 'package:flexi_profiler/Widget/DonutChartWidget.dart';
import 'package:flexi_profiler/Widget/GaugeChartWidget.dart';
import 'package:flexi_profiler/Widget/LineChartWidget.dart';
import 'package:flexi_profiler/Widget/ListViewWidget.dart';
import 'package:flexi_profiler/Widget/MultiColumnWidget.dart';
import 'package:flexi_profiler/Widget/PieChartWidget.dart';
import 'package:flexi_profiler/Widget/RadialChartWidget.dart';
import 'package:flexi_profiler/Widget/TableWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class ChartItemDetailsScreen extends StatelessWidget {
  Map<String, dynamic> argsData;

  ChartItemDetailsScreen(this.argsData);

  @override
  Widget build(BuildContext context) {
    return ChartItemDetails(argsData);
  }
}

class ChartItemDetails extends StatefulWidget {
  Map<String, dynamic> argsData;

  ChartItemDetails(this.argsData);

  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<ChartItemDetails> with TickerProviderStateMixin {
  Map<String, dynamic> argsData;
  bool isCardView = true;
  String header_bg_color = "#d3d3d3";
  String header_text_color = "#000000";
  double height;
  double width;
  List<dynamic> dataMain = [];

  AnimationController _hideFabAnimController;
  bool isScrolled = false;
  ScrollController _hideButtonController;

  @override
  void initState() {
    super.initState();
    argsData = widget.argsData;
    selectedDate = argsData["selectedDate"];
    _hideFabAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      value: 1,
    );
    _hideButtonController = new ScrollController();
    _hideButtonController.addListener(() {
      if (_hideButtonController.position.userScrollDirection == ScrollDirection.reverse) {
        _hideFabAnimController.reverse();
      } else if (_hideButtonController.position.userScrollDirection == ScrollDirection.forward) {
        // _hideFabAnimController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: isScrolled
            ? FadeTransition(
                opacity: _hideFabAnimController,
                child: ScaleTransition(
                  scale: _hideFabAnimController,
                  child: FloatingActionButton(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    onPressed: () {},
                    child: Lottie.asset('assets/Lotti/scroll_animation.json', width: 50, height: 50),
                  ),
                ),
              )
            : null,
        body: Stack(children: <Widget>[
          Container(
            color: AppColors.main_color,
            height: height,
            width: width,
            child: Container(
                child: FutureBuilder<dynamic>(
              future: makeApiCall(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return getMainView();
                } else {
                  return Center(
                      child: CircularProgressIndicator(
                    backgroundColor: AppColors.white_color,
                  ));
                }
              },
            )),
          ),
        ]));
  }

  ApiBaseHelper _helper = ApiBaseHelper();

  Future<Null> makeApiCall() async {
    print("Args Received : ${argsData}");

    bool isOnline = await Constants_data.checkNetworkConnectivity();
    if (isOnline) {
      try {
        String routeUrl =
            '/GetConfigDashboardData?RepId=${argsData["RepId"]}&ParentWidgetId=${argsData["ParentWidgetId"]}&monthYear=${formatter_final.format(selectedDate)}';
        var response = await _helper.post(routeUrl, argsData["jsonParam"], true);
        isLoaded = true;
        dataMain = response["dt_ReturnedTables"];
      } on Exception catch (err) {
        print("Error in  GetSalesSummaryData: $err");
        dataMain = [];
        isLoaded = true;
      }
    } else {
      await Constants_data.openDialogNoInternetConection(context);
      Navigator.pop(context);
    }
    if (dataMain.length > 2 && !isScrolled) {
      this.setState(() {
        isScrolled = true;
      });
    }
  }

  DateTime selectedDate = DateTime.now();
  final DateFormat formatter_final = DateFormat('MM-yyyy');
  bool isLoaded = false;

  Widget getMainView() {
    return Column(
      children: <Widget>[
        Container(
            height: height,
            child: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: <Widget>[
              SliverAppBar(
                title: Text(
                  argsData["title_value"],
                  style: TextStyle(color: AppColors.white_color, fontSize: 16),
                ),
                stretch: true,
                onStretchTrigger: () {
                  return;
                },
                backgroundColor: Colors.transparent,
                floating: false,
                leading: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.white_color,
                    )),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    tooltip: 'Select Month Year',
                    onPressed: () {
                      print("Tap Calendar");
                      showMonthPicker(
                              context: context,
                              firstDate: DateTime(DateTime.now().year, -12),
                              lastDate: DateTime(DateTime.now().year, DateTime.now().month),
                              initialDate: selectedDate)
                          .then((date) {
                        if (date != null) {
                          // print("Selected Date : " + formatter_final.format(date));
                          setState(() {
                            isLoaded = false;
                            isScrolled = false;
                            selectedDate = date;
                          });
                        }
                      });
                    },
                  ),
                ],
                expandedHeight: 45.0,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: <StretchMode>[
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                    StretchMode.fadeTitle,
                  ],
                  centerTitle: true,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Container(
                        height: dataMain.length == 1 ? height - 95 : (height - 100) * 0.5,
                        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Hero(
                                tag: "photo${dataMain[index]["title"]}",
                                child: Material(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                            decoration: new BoxDecoration(
                                                //new Color.fromRGBO(255, 0, 0, 0.0),
                                                borderRadius: new BorderRadius.only(
                                                    topLeft: const Radius.circular(10.0),
                                                    topRight: const Radius.circular(10.0))),
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                    child: Container(
                                                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                                        child: Text(
                                                          "${dataMain[index]["title"]}",
                                                          style:
                                                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold,color: Theme.of(context).accentColor),
                                                        )))
                                              ],
                                            )),
                                        Expanded(child: Container(child: getChildView(dataMain[index])))
                                      ],
                                    )))));
                  },
                  childCount: dataMain.length,
                ),
              ),
            ])),
      ],
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
      return PieChartWidget(templateJson: data, listData: data["data"]);
    } else if (data["widget_type"] == "doughnut") {
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
      return RadialChartWidget(templateJson: data, listData: data["data"]);
    } else if (data["widget_type"] == "listview") {
      List<dynamic> listItems = data["data"];
      var templateJson = data["template_json"];
      return ListViewWidget(
          templateJson: templateJson,
          listData: listItems,
          onItemClick: templateJson["isClickable"] == "Y"
              ? (data, index) async {
                  if (templateJson["isClickable"] == "Y") {
                    Map<String, dynamic> dataToSend = new HashMap();

                    List<String> params = [];
                    if (templateJson["Params"].toString().contains(",")) {
                      params = templateJson["Params"].toString().split(",");
                    } else {
                      params.add(templateJson["Params"].toString());
                    }
                    print("All Data  : ${data}");

                    Map<String, dynamic> jsonParam =
                        argsData["jsonParam"] == null ? new HashMap() : argsData["jsonParam"];
                    for (int i = 0; i < params.length; i++) {
                      jsonParam[params[i]] = data["AccountId"];
                    }

                    dataToSend["ParentWidgetId"] = templateJson["ParentWidgetId"];
                    dataToSend["jsonParam"] = jsonParam;
                    dataToSend["RepId"] = Constants_data.repId;
                    dataToSend["title_value"] = dataToSend["title_value"] = data["AccountName"];
                    dataToSend["selectedDate"] = selectedDate;

                    print("DataToSend ChartItemDetailsScreen : ${dataToSend}");

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChartItemDetailsScreen(dataToSend),
                        fullscreenDialog: true,
                      ),
                    );
                  }
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
