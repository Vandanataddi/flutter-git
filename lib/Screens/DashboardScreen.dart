import 'dart:collection';
import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Constants/MonthPicker/month_picker_dialog.dart';
import 'package:flexi_profiler/Constants/StateManager.dart';
import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
import 'package:flexi_profiler/Screens/DashBoardFullScreen.dart';
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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
// import 'package:wave/config.dart';
// import 'package:wave/wave.dart';
import 'ChartItemDetailsScreen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DetailsScreen createState() => _DetailsScreen();
}

class _DetailsScreen extends State<DashboardScreen> with TickerProviderStateMixin {
  double height;
  double width;
  final currancy_format = new NumberFormat("#,##,##,##,###.##", "en_IN");
  var result;
  List<dynamic> dataMain = [];
  ApiBaseHelper _helper = ApiBaseHelper();
  bool isCardView = true;

  AnimationController _hideFabAnimController;
  bool isScrolled = false;
  ScrollController _hideButtonController;

  String dashboardValue = "";

  Map<String, dynamic> args;

  // DateTime selectedDate = DateTime.now();
  DateTime selectedDate = new DateTime(2019, 12, 01);
  final DateFormat formatter_final = DateFormat('MM-yyyy');

  @override
  void initState() {
    super.initState();
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

  DarkThemeProvider themeChange;
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    Constants_data.currentScreenContext = context;
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    args = ModalRoute.of(context).settings.arguments;
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
                    child: Lottie.asset('assets/Lotti/scroll_animation.json', width: 100, height: 100),
                  ),
                ),
              )
            : null,
        body: Container(
          decoration: BoxDecoration(
            image: themeChange.darkTheme
                ? DecorationImage(
                    image: AssetImage("assets/images/menu_bg_dark.png"),
                    fit: BoxFit.cover,
                  )
                : DecorationImage(
                    image: AssetImage("assets/images/menu_bg.png"),
                    fit: BoxFit.cover,
                  ),
          ),
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
        ));
  }

  Future<Null> makeApiCall() async {
    bool isOnline = await Constants_data.checkNetworkConnectivity();
    if (isOnline) {
      var dataUser;
      if (Constants_data.app_user == null) {
        dataUser = await StateManager.getLoginUser();
      } else {
        dataUser = Constants_data.app_user;
      }
      ApiBaseHelper _helper = ApiBaseHelper();
      try {
        String routeUrl =
            '/Profiler/GetSalesSummaryData?RepId=${dataUser["RepId"]}&GridId=${args["grid_id"]}&monthYear=${formatter_final.format(selectedDate)}&divisionCode=${Constants_data.selectedDivisionId}';
        var response = await _helper.get(routeUrl);
        isLoaded = true;
        dataMain = response["dt_ReturnedTables"];
        // dataMain.add({
        //   "id": 3,
        //   "widget_type": "grid",
        //   "title": "title",
        //   "sub_title": "count",
        //   "icon": "img",
        //   "isShowSubTitle": "Y",
        //   "title_color": "#0000FF",
        //   "title_size": "15",
        //   "sub_title_color": "#000000",
        //   "sub_title_size": "13",
        //   "bg_color": "#FFFFFF",
        //   "num_of_cols":"3",
        //   "data": [
        //     {
        //       "id": 1,
        //       "title": "Title 1",
        //       "img": "https://image.freepik.com/free-vector/pack-colorful-square-emoticons_23-2147589525.jpg",
        //       "count": "20",
        //       "color": "#00FF00"
        //     },
        //     {
        //       "id": 2,
        //       "title": "Title 2",
        //       "img": "https://i.pinimg.com/originals/39/44/6c/39446caa52f53369b92bc97253d2b2f1.png",
        //       "count": "",
        //     },
        //     {
        //       "id": 3,
        //       "title": "Title 3",
        //       "img": "https://i.pinimg.com/originals/39/44/6c/39446caa52f53369b92bc97253d2b2f1.png",
        //       "count": ""
        //     },
        //     {
        //       "id": 4,
        //       "title": "Title 4",
        //       "img": "https://i.pinimg.com/originals/39/44/6c/39446caa52f53369b92bc97253d2b2f1.png",
        //       "count": ""
        //     },
        //     {
        //       "id": 5,
        //       "title": "Title 5",
        //       "img": "https://image.freepik.com/free-vector/pack-colorful-square-emoticons_23-2147589525.jpg",
        //       "count": ""
        //     },
        //     {
        //       "id": 6,
        //       "title": "Title 6",
        //       "img": "https://i.pinimg.com/originals/39/44/6c/39446caa52f53369b92bc97253d2b2f1.png",
        //       "count": "",
        //       "color": "#FF0000"
        //     },
        //     {
        //       "id": 7,
        //       "title": "Title 7",
        //       "img": "https://i.pinimg.com/originals/39/44/6c/39446caa52f53369b92bc97253d2b2f1.png",
        //       "count": "this is sample description text."
        //     },
        //     {
        //       "id": 8,
        //       "title": "This is demo title of tile 8",
        //       "img": "https://i.pinimg.com/originals/39/44/6c/39446caa52f53369b92bc97253d2b2f1.png",
        //       "count": ""
        //     },
        //     {
        //       "id": 9,
        //       "title": "Title 9",
        //       "img": "https://i.pinimg.com/originals/39/44/6c/39446caa52f53369b92bc97253d2b2f1.png",
        //       "count": ""
        //     },
        //     {
        //       "id": 10,
        //       "title": "Title 10",
        //       "img": "https://image.freepik.com/free-vector/pack-colorful-square-emoticons_23-2147589525.jpg",
        //       "count": ""
        //     }
        //   ]
        // });
        // ObjRetArgs
        if (args["is_currency"] == "Y") {
          dashboardValue = "${args["currency"]}" + currancy_format.format(double.parse(response["ObjRetArgs"][0]));
        } else {
          dashboardValue = response["ObjRetArgs"][0].toString();
        }
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

  bool isLoaded = false;

  Widget getMainView() {
    final DateFormat formatter = DateFormat('MMMM yyyy');
    return Column(
      children: <Widget>[
        Container(
            height: height,
            child: CustomScrollView(
                controller: _hideButtonController,
                physics: const BouncingScrollPhysics(),
                slivers: <Widget>[
                  SliverAppBar(
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
                        onPressed: () async {
                          print("Tap Calendar");
                          showMonthPicker(
                                  context: context,
                                  firstDate: DateTime(DateTime.now().year - 5),
                                  lastDate: DateTime(DateTime.now().year, DateTime.now().month),
                                  initialDate: selectedDate)
                              .then((date) {
                            if (date != null) {
                              print("Selected Date : " + formatter_final.format(date));
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
                    expandedHeight: 150.0,
                    flexibleSpace: FlexibleSpaceBar(
                      stretchModes: <StretchMode>[
                        StretchMode.zoomBackground,
                        StretchMode.blurBackground,
                        StretchMode.fadeTitle,
                      ],
                      centerTitle: true,
                      title: Container(
                          height: 55,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Statistics of ${formatter.format(selectedDate)}",
                                  maxLines: 1,
                                  style: TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'Gameboard'),
                                ),
                                Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: Text(
                                      "${dashboardValue}",
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: AppColors.white_color,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Roboto'),
                                    )),
                              ])),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Container(
                            height: dataMain.length == 1 ? height * 0.75 : height * 0.4,
                            margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Hero(
                                    tag: "photo${dataMain[index]["title"]}",
                                    child: Material(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(10.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                                decoration: new BoxDecoration(
                                                    // color:
                                                    //     themeChange.darkTheme ? Color(0xFF636363) : Color(0xFFE0DFDF),
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
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: themeData.accentColor),
                                                            ))),
                                                    Container(
                                                      height: 35,
                                                      width: 40,
                                                      child: Center(
                                                          child: IconButton(
                                                        icon: Icon(
                                                          Icons.zoom_out_map,
                                                          color: themeData.textTheme.caption.color,
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context).push(_createRoute(dataMain[index]));
                                                        },
                                                      )),
                                                    )
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

  Route _createRoute(data) {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => DashBoardFullScreen(
              msgData: data,
              selectedDate: selectedDate,
            ),
        fullscreenDialog: false,
        transitionDuration: Duration(milliseconds: 1000));
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
    } else if (data["widget_type"] == "doughnut") {
      return DonutChartWidget(templateJson: data, listData: data["data"]);
    } else if (data["widget_type"] == "pie") {
      return PieChartWidget(templateJson: data, listData: data["data"]);
    } else if (data["widget_type"] == "line") {
      return LineChartWidget(templateJson: data, listData: data["data"]);
    } else if (data["widget_type"] == "multiline") {
      return LineChartWidget(templateJson: data, listData: data["data"], isMultiline: true);
    } else if (data["widget_type"] == "gauge") {
      return GaugeChartWidget(templateJson: data, listData: data["data"]);
    } else if (data["widget_type"] == "grid") {
      return GridViewWidget(
        listData: data["data"],
        numOfCols: int.parse(data["num_of_cols"].toString()),
        templateJson: data,
      );
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
                  Map<String, dynamic> dataToSend = new HashMap();

                  List<String> params = [];
                  if (templateJson["Params"].toString().contains(",")) {
                    params = templateJson["Params"].toString().split(",");
                  } else {
                    params.add(templateJson["Params"].toString());
                  }
                  print("All Data  : ${data}");

                  Map<String, dynamic> jsonParam = new HashMap();
                  for (int i = 0; i < params.length; i++) {
                    jsonParam[params[i]] = data["AccountId"];
                  }

                  dataToSend["ParentWidgetId"] = templateJson["ParentWidgetId"];
                  dataToSend["jsonParam"] = jsonParam;
                  dataToSend["Rep_Id"] = Constants_data.repId;
                  dataToSend["title_value"] = dataToSend["title_value"] = data["AccountName"];
                  dataToSend["selectedDate"] = selectedDate;

                  print("DataToSend : ${dataToSend}");

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
