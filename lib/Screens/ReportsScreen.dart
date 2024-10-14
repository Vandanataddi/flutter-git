import 'dart:collection';
import 'dart:convert';
import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flexi_profiler/Theme/StyleClass.dart';
import 'package:flexi_profiler/Widget/BarChartWidget.dart';
import 'package:flexi_profiler/Widget/DateTimePickerDialog.dart';
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
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../ChatConnectyCube/pref_util.dart';
import '../Constants/StateManager.dart';
import 'AccountDetailsScreen.dart';
import 'Login.dart';

class ReportsScreen extends StatelessWidget {
  Map<String, dynamic> argsData;

  ReportsScreen(this.argsData);

  @override
  Widget build(BuildContext context) {
    return Reports(argsData);
  }
}

class Reports extends StatefulWidget {
  Map<String, dynamic> argsData;

  Reports(this.argsData);

  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Reports> with TickerProviderStateMixin {
  Map<String, dynamic> argsData;

  bool isCardView = true;
  double height;
  double width;
  List<dynamic> dataMain = [];
  List<dynamic> filterData = [];
  bool check_once = true;
  String WidgetId = '';
  Map<String, dynamic> selectedFilter;
  AnimationController _hideFabAnimController;
  bool isScrolled = false;
  ScrollController _hideButtonController;

  List<Map<String, dynamic>> divisions = [];
   //dynamic divisions;
  String selectedDivision;
  bool isLoading = true;
  String selectedDivisionDesc;
  String titlename = '';

  bool isApiCalled = false;

  @override
  void initState() {
    super.initState();
    argsData = widget.argsData;
    selectedDate = argsData["selectedDate"];
    selectedFilter = argsData["selectedFilter"]/*["dimension"]*/;
    titlename = argsData["title_value"];

    _hideFabAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      value: 1,
    );
    _hideButtonController = new ScrollController();
    _hideButtonController.addListener(() {
      if (_hideButtonController.position.userScrollDirection == ScrollDirection.reverse) {
        _hideFabAnimController.reverse();
      }
    });
    initUser();

    selectedDivision = Constants_data.selectedDivisionId;
    //selectedDivisionDesc = Constants_data.selectedDivisionName;
    getDivisionData();
  }

  DarkThemeProvider themeChange;
  ThemeData themeData;
  bool isLoaded = false;

  initUser() async {
    if (Constants_data.app_user == null) {
      dataUser = await StateManager.getLoginUser();
    } else {
      dataUser = Constants_data.app_user;
    }
  }
    @override
  Widget build(BuildContext context) {
    Constants_data.currentScreenContext = context;
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    // getDivisionData();
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Constants_data.getFlexibleAppBar(themeChange.darkTheme),
          title: Text(
            //'$titlename ' '(${Constants_data.selectedDivisionName})',
            '$titlename (${selectedDivisionDesc ?? Constants_data.selectedDivisionName})',
           // argsData["title_value"] ${Constants_data.selectedDivisionName},
            style: TextStyle(color: AppColors.white_color, fontSize: 16),
          ),
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: AppColors.white_color,
              )),
          actions: <Widget>[
            filterData != null && filterData.length > 1
                ? PopupMenuButton<dynamic>(
                    offset: const Offset(0, 50),
                    icon: Icon(
                      Icons.filter_list,
                      color: AppColors.white_color,
                    ),
                    onSelected: (value) {
                      if (WidgetId != value["WidgetId"]) {
                        setState(() {
                          isLoaded = false;
                          WidgetId = value["WidgetId"];
                        });
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return filterData.map((dynamic choice) {
                        return PopupMenuItem<dynamic>(
                          value: choice,
                          child: Text(choice["WidgetDesc"],
                              style: WidgetId == choice["WidgetId"]
                                  ? TextStyle(color: AppColors.main_color, fontWeight: FontWeight.bold, fontSize: 15)
                                  : TextStyle(fontWeight: FontWeight.normal, fontSize: 15)),
                        );
                      }).toList();
                    },
                  )
                : Container(),
            argsData["ParentWidgetId"] == ""
                ? IconButton(
                    icon: Icon(Icons.more_time),
                    onPressed: () {
                      timeFilterBottomSheet();
                    })
                : Container()
          ],
        ),
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
                    child: Lottie.asset('assets/Lotti/scroll_animation.json', width: 60, height: 60),
                  ),
                ),
              )
            : null,
        body: Stack(children: <Widget>[
          Container(
            height: height,
            width: width,
            child: Container(
                child: isLoaded
                    ? getMainView()
                    : FutureBuilder<dynamic>(
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
          )
        ]));
  }
  ApiBaseHelper _helper = ApiBaseHelper();
  Future<Null> makeApiCall() async {
    // if (!isApiCalled) {
    //   isApiCalled = true; // Set the flag to true o
      String type = "";
      String year = "";
      String from_date = "";
      String to_date = "";
      if (selectedFilter != null) {
        print("FilterData : ${filterData}");
        if (selectedFilter["dimension"]["id"] == "1") {
          type = "D";
          //year = Constants_data.stringToDate("${selectedFilter["start"]}", "yyyy-MM-dd")
          year = Constants_data .stringToDate("${selectedFilter["start"]}", "yyyy-MM-dd").year.toString();
          from_date = "${selectedFilter["start"]}";
          to_date = "${selectedFilter["end"]}";
        }
        else if (selectedFilter["dimension"]["id"] == "2") {
          type = "M${selectedFilter["month"]["id"]}";
          year = "${selectedFilter["year"]["id"]}";
        }
        else if (selectedFilter["dimension"]["id"] == "3") {
          type = "Y";
          year = "${selectedFilter["year"]["id"]}";
        }
        else if (selectedFilter["dimension"]["id"] == "4") {
          type = "S${selectedFilter["semester"]["id"]}";
          year = "${selectedFilter["year"]["id"]}";
        }
        else if (selectedFilter["dimension"]["id"] == "5") {
          type = "Q${selectedFilter["quarter"]["id"]}";
          year = "${selectedFilter["year"]["id"]}";
        }
      }
      else {
        year = DateTime.now().year.toString(); // Set current year
        type = "M${DateTime.now().month}";     // Set type to "M" + current month number
      }
      // else {
      //   year = DateTime.now().year.toString();
      //   type = "Y";
      // }
      print("type : $type");
      print("year : $year");
      print("from_date : $from_date");
      print("to_date : $to_date");

      bool isOnline = await Constants_data.checkNetworkConnectivity();
      if (isOnline) {
        try {
          //Constants_data.toastNormal("Api call started");
          String routeUrl = '/Profiler/GetConfigReportData?RepId=${argsData["Rep_Id"]}&ParentWidget=${argsData["ParentWidgetId"]}&WidgetId=${WidgetId}' +
              "&type=$type" +
              "&Year=$year" +
              // "&Year=2019" +
              "&from_date=$from_date" +
              "&to_date=$to_date" +
              "&divisionCode=${selectedDivision}";
          var response;
          if (argsData["jsonParam"] == "")
            response =
            await _helper.post(routeUrl, argsData["jsonParam"], false);
          else
            response =
            await _helper.post(routeUrl, argsData["jsonParam"], true);
          isLoaded = true;
          // var data = {"dt_ReturnedTables":[{"id":1,"title":"Top 10 Travel Agents","widget_type":"listview","template_json":{"LeadingIconFrom":"Growth","TrailIconFrom":"Growth","currency_symbol":"₹","currency_formate":"##,##,##,###.##","isShowLeadingIcon":"N","isShowTailIcon":"N","isClickable":"Y","ScreenName":"ReportScreen","Params":"AccountId","ParentWidgetId":"TopTA","Row":[[{"is_expandble":"Y","bg_color":"","label":"","flex":10,"txt_color":"#3b75c4","txt_size":"13","txt_style":"Bold","value":"","widget_id":"AccountName","widget_type":"Text","is_currency":"N","align":"left"}],[{"is_expandble":"Y","bg_color":"","label":"","flex":10,"txt_color":"#000000","txt_size":"13","txt_style":"normal","value":"","widget_id":"Sales","widget_type":"Text","is_currency":"Y","align":"left"}]]},"data":[{"id":1,"AccountId":"U0001049","AccountName":"SMILE N FLY TRAVEL","Sales":4286756.0,"Growth":"equal","isHyperLink":"Y","AccountType":"RMT"},{"id":2,"AccountId":"U000224","AccountName":"GETAWAY HOLIDAYS","Sales":2169940.0,"Growth":"equal","isHyperLink":"Y","AccountType":"RMT"},{"id":3,"AccountId":"U0001181","AccountName":"Dattu Tours & Travels","Sales":2093806.0,"Growth":"equal","isHyperLink":"Y","AccountType":"RMT"},{"id":4,"AccountId":"T0001641","AccountName":"KRISHNA TRAVELS","Sales":1981402.0,"Growth":"equal","isHyperLink":"Y","AccountType":"RMT"},{"id":5,"AccountId":"T0002186","AccountName":"HAPPENING HOLIDAYS","Sales":1946016.0,"Growth":"equal","isHyperLink":"Y","AccountType":"RMT"},{"id":6,"AccountId":"U0001146","AccountName":"Blu-Wings Tourism","Sales":1848886.0,"Growth":"equal","isHyperLink":"Y","AccountType":"RMT"},{"id":7,"AccountId":"T0002253","AccountName":"BHAVYAS LEISURE PVT LTD","Sales":931550.0,"Growth":"equal","isHyperLink":"Y","AccountType":"RMT"},{"id":8,"AccountId":"U000856","AccountName":"Eco Tours and Travels","Sales":783340.0,"Growth":"equal","isHyperLink":"Y","AccountType":"RMT"},{"id":9,"AccountId":"U0001211","AccountName":"TRAVEL VACATIONS","Sales":776230.0,"Growth":"equal","isHyperLink":"Y","AccountType":"RMT"},{"id":10,"AccountId":"T0001511","AccountName":"tanishq tours and travels","Sales":714354.0,"Growth":"equal","isHyperLink":"Y","AccountType":"RMT"}]}],"ObjRetArgs":[[{"WidgetId":"TopTA","WidgetDesc":"Top 10 TA"},{"WidgetId":"TopHotel","WidgetDesc":"Top 10 Hotel"}]],"Status":1,"Message":"Data retrive successfully.","CSRF_TOKEN":""};
          // dataMain = response["dt_ReturnedTables"];
          // dataMain = response["dt_ReturnedTables"];
          if (response["Status"] == 2) {
            Constants_data.toastError(response["Message"]);
          }
          else if (response["Status"] == 0) {
            Constants_data.toastError(response["Message"]);
          }
          else if (response["Status"] == 1){
            dataMain = response["dt_ReturnedTables"];
          if (check_once) {
            filterData = response["ObjRetArgs"];
            filterData = filterData[0];
            WidgetId = filterData[0]["WidgetId"];
            check_once = false;
          }
          // Constants_data.toastNormal("Api call Ended");
        }
          else if (response["status"].toString() == "8") {
            print("There Is No Products for This Division");
            //Constants_data.toastError(response["message"]);
            await StateManager.logout();
            SharedPrefs.instance.deleteUser();
            Constants_data.selectedDivisionName = " ";
            Constants_data.selectedDivisionId = "";
            Constants_data.selectedHQCode = "";
            Constants_data.repId = null;
            Constants_data.SessionId = null;
            Constants_data.app_user= null;
            await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,  // This removes all previous routes
            );
          }
          else if (response["status"].toString() == "4") {
            print("There Is No Products for This Division");
            //Constants_data.toastError(response["message"]);
            await StateManager.logout(); // Wait for logout to complete
            //await SharedPrefs.instance.deleteUser();
            Constants_data.selectedDivisionName = "";
            Constants_data.selectedDivisionId = "";
            Constants_data.selectedHQCode = "";
            Constants_data.repId = null;
            Constants_data.SessionId = null;
            Constants_data.app_user= null;
            await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,  // This removes all previous routes
            );
          }
          else if (response["status"].toString() == "5") {
            //Constants_data.toastError(response["message"]);
            await StateManager.logout(); // Wait for logout to complete
            //await SharedPrefs.instance.deleteUser();
            Constants_data.selectedDivisionName = "";
            Constants_data.selectedDivisionId = "";
            Constants_data.selectedHQCode = "";
            Constants_data.repId = null;
            Constants_data.SessionId = null;
            Constants_data.app_user= null;
            await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,  // This removes all previous routes
            );
            //await Navigator.pushReplacementNamed(context, "/Login");
          }
        }
        on Exception catch (err) {
          print("Error in  GetSalesSummaryData: $err");
          dataMain = [];
          isLoaded = true;
        }
      }
 //      if (isOnline) {
 //        try {
 //          String routeUrl = '/Profiler/GetConfigReportData?RepId=${argsData["Rep_Id"]}&ParentWidget=${argsData["ParentWidgetId"]}&WidgetId=${WidgetId}' +
 //              "&type=$type" +
 //              "&Year=$year" +
 //              "&from_date=$from_date" +
 //              "&to_date=$to_date" +
 //              "&divisionCode=${selectedDivision}";
 //
 //          var response;
 //          if (argsData["jsonParam"] == "") {
 //            response = await _helper.post(routeUrl, argsData["jsonParam"], false);
 //          } else {
 //            response = await _helper.post(routeUrl, argsData["jsonParam"], true);
 //          }
 //          isLoaded = true;
 //
 //          // Check if WidgetId is 'FGOList' for static data
 //          if (WidgetId == "FGOList") {
 //            dataMain = [
 //              {
 //                "id": 1,
 //                "title": "FGO list customer wise",
 //                "widget_type": "listview",
 //                "template_json": {
 //                  "LeadingIconFrom": "Growth",
 //                  "TrailIconFrom": "Growth",
 //                  "currency_symbol": "₹",
 //                  "currency_formate": "##,##,##,###.##",
 //                  "isShowLeadingIcon": "N",
 //                  "isShowTailIcon": "N",
 //                  "isClickable": "Y",
 //                  "ScreenName": "ReportScreen",
 //                  "Params": "CustomerId",
 //                  "ParentWidgetId": "FGOList",
 //                  "Row": [
 //                    [
 //                      {
 //                        "is_expandble": "Y",
 //                        "bg_color": "",
 //                        "label": "",
 //                        "flex": 10,
 //                        "txt_color": "#3b75c4",
 //                        "txt_size": "13",
 //                        "txt_style": "Bold",
 //                        "value": "",
 //                        "widget_id": "AccountName",
 //                        "widget_type": "Text",
 //                        "is_currency": "N",
 //                        "align": "left"
 //                      }
 //                    ],
 //                    [
 //                      {
 //                        "is_expandble": "Y",
 //                        "bg_color": "",
 //                        "label": "Sales",
 //                        "flex": 4,
 //                        "txt_color": "#000000",
 //                        "txt_size": "13",
 //                        "txt_style": "normal",
 //                        "value": "",
 //                        "widget_id": "Sales",
 //                        "widget_type": "Text",
 //                        "orientation": "V",
 //                        "is_currency": "Y",
 //                        "align": "left"
 //                      },
 //                      {
 //                        "is_expandble": "Y",
 //                        "bg_color": "",
 //                        "label": "Sales %",
 //                        "flex": 3,
 //                        "txt_color": "#000000",
 //                        "txt_size": "13",
 //                        "txt_style": "normal",
 //                        "value": "",
 //                        "widget_id": "percentage",
 //                        "widget_type": "Text",
 //                        "orientation": "V",
 //                        "is_currency": "N",
 //                        "align": "left"
 //                      },
 //                      {
 //                        "is_expandble": "Y",
 //                        "bg_color": "",
 //                        "label": "Cumulative %",
 //                        "flex": 3,
 //                        "txt_color": "#000000",
 //                        "txt_size": "13",
 //                        "txt_style": "normal",
 //                        "value": "",
 //                        "widget_id": "cum_per",
 //                        "widget_type": "Text",
 //                        "orientation": "V",
 //                        "is_currency": "N",
 //                        "align": "left"
 //                      }
 //                    ]
 //                  ]
 //                },
 //                "data": [
 //                  {
 //                    "id": 1,
 //                    "AccountId": "MIBO_CJ007",
 //                    "AccountName": "Jyoti Pharmaceuticals (Cj007)",
 //                    "Sales": 306447.0,
 //                    "percentage": "15.21 %",
 //                    "cum_per": "15.21 %",
 //                    "isHyperLink": "Y",
 //                    "AccountType": "Customer"
 //                  },
 //                  {
 //                    "id": 2,
 //                    "AccountId": "MIBO_CD011",
 //                    "AccountName": "D.S. Agencies",
 //                    "Sales": 304879.0,
 //                    "percentage": "15.13 %",
 //                    "cum_per": "30.34 %",
 //                    "isHyperLink": "Y",
 //                    "AccountType": "Customer"
 //                  },
 //                  {
 //                    "id": 3,
 //                    "AccountId": "MIBO_CJ005",
 //                    "AccountName": "Jyothi Medical Agencies (Cj005)",
 //                    "Sales": 265477.0,
 //                    "percentage": "13.18 %",
 //                    "cum_per": "43.51 %",
 //                    "isHyperLink": "Y",
 //                    "AccountType": "Customer"
 //                  },
 //                  {
 //                    "id": 4,
 //                    "AccountId": "MIBO_CJ004",
 //                    "AccountName": "Jyothi Distributors (Cj004)",
 //                    "Sales": 234767.0,
 //                    "percentage": "11.65 %",
 //                    "cum_per": "55.17 %",
 //                    "isHyperLink": "Y",
 //                    "AccountType": "Customer"
 //                  },
 //                  {
 //                    "id": 5,
 //                    "AccountId": "MIBO_CP013",
 //                    "AccountName": "Poddar Distributors",
 //                    "Sales": 229100.0,
 //                    "percentage": "11.37 %",
 //                    "cum_per": "66.54 %",
 //                    "isHyperLink": "Y",
 //                    "AccountType": "Customer"
 //                  },
 //                  {
 //                    "id": 6,
 //                    "AccountId": "MIBO_CS011",
 //                    "AccountName": "Siddhartha Medical Agencies (Cs011)",
 //                    "Sales": 221560.0,
 //                    "percentage": "11.00 %",
 //                    "cum_per": "77.53 %",
 //                    "isHyperLink": "Y",
 //                    "AccountType": "Customer"
 //                  },
 //                  {
 //                    "id": 7,
 //                    "AccountId": "MIBO_CH001",
 //                    "AccountName": "Hind Medical Stores (Ch001)",
 //                    "Sales": 186286.0,
 //                    "percentage": "9.25 %",
 //                    "cum_per": "86.78 %",
 //                    "isHyperLink": "Y",
 //                    "AccountType": "Customer"
 //                  },
 //                ]
 //              }
 //            ];
 //          }
 //          else if (argsData["ParentWidgetId"]=="FGOList"){
 //             dataMain = [
 //  {
 //    "id": 3,
 //    "title": "Sales History (upto 10 years)",
 //    "widget_type": "barchart",
 //    "x_axis": "year",
 //    "y_axis": "sales",
 //    "isTrendLine": "N",
 //    "barColor": "#6495ED",
 //    "TrendLineType": "",
 //    "data": [
 //  {
 //    "id": 1,
 //    "year": "2021",
 //    "sales": 1286976.0
 //  },
 //  {
 //    "id": 2,
 //    "year": "2022",
 //    "sales": 1424343.0
 //  },
 //  {
 //    "id": 3,
 //    "year": "2023",
 //    "sales": 165248
 //  },
 //  {
 //    "id": 4,
 //    "year": "2024",
 //    "sales": 765432
 //  }
 //    ]
 //  },
 //  {
 //    "id": 1,
 //    "title": "YoY Comparison (Last 5 Year)",
 //    "widget_type": "multiline",
 //    "isShowMarker": "Y",
 //    "x_axis": "month",
 //    "y_axis": "2024~2023~2022~2021",
 //    "data": [
 //  {
 //    "month": "Jan",
 //    "2024": 132670.9,
 //    "2023": 138006.25,
 //    "2022": 5465644.5,
 //    "2021": 28652.0
 //  },
 //  {
 //    "month": "Feb",
 //    "2024": 193857.8,
 //    "2023": 2234.0,
 //    "2022": 83019.17,
 //    "2021": 49209.81
 //  },
 //  {
 //    "month": "Mar",
 //    "2024": null,
 //    "2023": null,
 //    "2022": null,
 //    "2021": null
 //  },
 //  {
 //    "month": "Apr",
 //    "2024": 76566,
 //    "2023": 87876,
 //    "2022": 34567,
 //    "2021": 76566
 //  },
 //  {
 //    "month": "May",
 //    "2024": 6755,
 //    "2023": 6556,
 //    "2022": 87876,
 //    "2021": 4587
 //  },
 //  {
 //    "month": "Jun",
 //    "2024": 65678,
 //    "2023": 6757,
 //    "2022": 98754,
 //    "2021": 78676
 //  },
 //  {
 //    "month": "Jul",
 //    "2024": 65456,
 //    "2023": 76563,
 //    "2022": 27833,
 //    "2021": 5466
 //  },
 //  {
 //    "month": "Aug",
 //    "2024": 6567,
 //    "2023": 76754,
 //    "2022": 56522,
 //    "2021": 86725
 //  },
 //  {
 //    "month": "Sep",
 //    "2024": 756456,
 //    "2023": 87678,
 //    "2022": 23445,
 //    "2021": 3456
 //  },
 //  {
 //    "month": "Oct",
 //    "2024": 3456577,
 //    "2023": 6775,
 //    "2022": 987676,
 //    "2021": 2347
 //  },
 //  {
 //    "month": "Nov",
 //    "2024": 344556,
 //    "2023": 78790,
 //    "2022": 555567,
 //    "2021": 3456
 //  },
 //  {
 //    "month": "Dec",
 //    "2024": 65453,
 //    "2023": 121,
 //    "2022": 12,
 //    "2021": 2334345
 //  }
 //    ]
 //  },
 //  {
 //    "id": 3,
 //    "title": "Sales Contribution",
 //    "widget_type": "doughnut",
 //    "x_axis": "product",
 //    "y_axis": "sales",
 //    "legendPosition": "top",
 //    "iconType": "legendIconType.pentagon",
 //    "data": [
 //  {
 //    "product": "BACTOCLAV DS 457 DRY SYRUP COMP.PACK",
 //    "sales": 52683.9
 //  },
 //  {
 //    "product": "eye ointments",
 //    "sales": 14823.13
 //  },
 //  {
 //    "product": "allercet tablets",
 //    "sales": 14688.13
 //  },
 //      {
 //    "product": "Other",
 //    "sales": 63533.13
 //  }
 //    ]
 //  },
 //  {
 //    "id": 3,
 //    "title": "Month Wise Sales By Product",
 //    "widget_type": "barchart",
 //    "x_axis": "date",
 //    "y_axis": "sales",
 //    "isTrendLine": "N",
 //    "barColor": "#6495ED",
 //    "TrendLineType": "",
 //    "data": [
 //  {
 //    "id": 1,
 //    "date": "Jan 2024",
 //    "sales": 132670.9
 //  },
 //  {
 //    "id": 2,
 //    "date": "Feb 2024",
 //    "sales": 193857.8
 //  },
 //  {
 //    "id": 3,
 //    "date": "Mar 2024",
 //    "sales": 67484.3
 //  },
 //  {
 //    "id": 4,
 //    "date": "Apr 2024",
 //    "sales": 105013.4
 //  },
 //    ]
 //  },
 //  ];
 // }
 //          else {
 //            // Otherwise, use response data for other widgets
 //            if (response["Status"] == 1) {
 //              dataMain = response["dt_ReturnedTables"];
 //            } else if (response["Status"] == 2 || response["Status"] == 0) {
 //             // Constants_data.toastError(response["Message"]);
 //            }
 //          }
 //          // Handle ObjRetArgs for filters
 //          if (check_once) {
 //            filterData = response["ObjRetArgs"];
 //            filterData = filterData[0];
 //            WidgetId = filterData[0]["WidgetId"];
 //            check_once = false;
 //          }
 //
 //          // Handle other status responses
 //          if (response["status"].toString() == "8") {
 //            //await _handleNoProducts();
 //          } else if (response["status"].toString() == "4" || response["status"].toString() == "5") {
 //           // await _handleSessionExpiry();
 //          }
 //        } catch (e) {
 //          // Handle API call error
 //        //  Constants_data.toastError("Error occurred while fetching data.");
 //        }
 //      }
      else {
        await Constants_data.openDialogNoInternetConection(context);
        Navigator.pop(context);
      }
      if (dataMain.length > 2 && !isScrolled) {
        this.setState(() {
          isScrolled = true;
        });
      }
      this.setState(() {
        isLoaded = true;
      });
    //}
  }
  DateTime selectedDate = DateTime.now();
  final DateFormat formatter_final = DateFormat('MM-yyyy');
  Widget getMainView() {
    return Column(
      children: <Widget>[
        Expanded(
            child: ListView.builder(
            controller: _hideButtonController,
            itemCount: dataMain?.length ?? 0,
            padding: EdgeInsets.all(0.0),
            itemBuilder: (BuildContext context, int index) {
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
                                        borderRadius:
                                            new BorderRadius.only(topLeft: const Radius.circular(10.0), topRight: const Radius.circular(10.0))),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                            child: Container(
                                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                                child: Text(
                                                  "${dataMain[index]["title"]}",
                                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: themeData.accentColor),
                                                )))
                                      ],
                                    )),
                                Expanded(
                                    child: Container(
//                          padding: EdgeInsets.symmetric(vertical: 5),
                                        child: getChildView(dataMain[index])))
                              ],
                            )))));
          },
        )),
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
      return BarChartWidget(
        listData: data["data"],
        templateJson: data,
        onItemClick: (item, index) {
          print("pointIndex ({$index}) : ${item}");
        },
      );
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
      // return LineChart(data, data["data"], true);
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
      // var templateJson = Constants_data.templateData;
      return ListViewWidget(
          templateJson: templateJson,
          listData: listItems,
          onItemClick: templateJson["isClickable"] == "Y"
              ? (data, index) async {
                  print("Clicked$index Data Receive : ${data}");
                  Map<String, dynamic> dataToSend = new HashMap();

                  List<String> params = [];
                  if (templateJson["Params"].toString().contains(",")) {
                    params = templateJson["Params"].toString().split(",");
                  } else {
                    params.add(templateJson["Params"].toString());
                  }

                  print("All Data  : ${data}");
                  print("Template Json  : ${templateJson}");

                  Map<String, dynamic> jsonParam = argsData["jsonParam"];
                  for (int i = 0; i < params.length; i++) {
                    jsonParam[params[i]] = data["AccountId"];
                  }

                  dataToSend["ParentWidgetId"] = templateJson["ParentWidgetId"];
                  dataToSend["jsonParam"] = jsonParam;
                  dataToSend["Rep_Id"] = dataUser["RepId"];
                  dataToSend["title_value"] = data["AccountName"];
                  dataToSend["selectedFilter"] = selectedFilter;
                  // dataToSend["selectedDate"] = argsData["selectedDate"];

                  print("Data to send : ${dataToSend}");
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportsScreen(dataToSend),
                      fullscreenDialog: true,
                    ),
                  ).then((value) => (value) {
                    setState(() {
                    });
                  });
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
  List<dynamic> dimensions = [
    {"name": "Date", "id": "1"},
    {"name": "Month", "id": "2"},
    {"name": "Year", "id": "3"},
    {"name": "Semester", "id": "4"},
    {"name": "Quarter", "id": "5"}
  ];
  List<dynamic> months = [
    {"name": "January", "id": "1"},
    {"name": "February", "id": "2"},
    {"name": "March", "id": "3"},
    {"name": "April", "id": "4"},
    {"name": "May", "id": "5"},
    {"name": "June", "id": "6"},
    {"name": "July", "id": "7"},
    {"name": "August", "id": "8"},
    {"name": "September", "id": "9"},
    {"name": "October", "id": "10"},
    {"name": "November", "id": "11"},
    {"name": "December", "id": "12"}
  ];
  List<dynamic> years = [
    for (int i = 2010; i <= DateTime.now().year; i++) {"name": "$i", "id": "$i"}
  ];
  List<dynamic> semester = [
    {"name": "Semester 1", "id": "1"},
    {"name": "Semester 2", "id": "2"}
  ];
  List<dynamic> quarter = [
    {"name": "Quarter 1", "id": "1"},
    {"name": "Quarter 2", "id": "2"},
    {"name": "Quarter 3", "id": "3"},
    {"name": "Quarter 4", "id": "4"}
  ];
  // Map<String, dynamic> selectedFilter;
  String formatDate(String date) {
    DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(date);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }
  void timeFilterBottomSheet() {
    dynamic selectedDimension = selectedFilter != null ? selectedFilter["dimension"] : dimensions[1];
    dynamic selectedYear = selectedFilter != null ? selectedFilter["year"] : years[years.length - 1];
    dynamic selectedMonth = selectedFilter != null ? selectedFilter["month"] : months[DateTime.now().month - 1];
    dynamic selectedQuarter = selectedFilter != null ? selectedFilter["quarter"] : null;
    dynamic selectedSemester = selectedFilter != null ? selectedFilter["semester"] : null;

    var date1Template = {
      "selected_date":  selectedFilter != null && selectedFilter["dimension"]["id"] == "1" ? formatDate(selectedFilter["start"]) : "today",
     // selectedFilter != null && selectedFilter["dimension"]["id"] == "1" ? selectedFilter["start"] : "today",
      "first_date": "01-01-2010",
      "last_date": "today",
      "format": "DD-MM-YYYY",
      // "format": "yyyy-MM-dd",
      "widget_id": "date",
    };
    var date2Template = {
      "selected_date": selectedFilter != null && selectedFilter["dimension"]["id"] == "1" ? formatDate(selectedFilter["end"]) : "today",
      //selectedFilter != null && selectedFilter["dimension"]["id"] == "1" ? selectedFilter["end"] : "today",
      "first_date": "01-01-2010",
      "last_date": "today",
      "format": "DD-MM-YYYY",
       //"format": "yyyy-MM-dd",
      "widget_id": "date",
    };

    createViewBaseDimension(selectedDimension, setState) {
      if (selectedDimension["id"] == "1") {
        return Container(
            child: Row(children: [
          Expanded(
              child: InkWell(
                  onTap: () async {
                    String strDate = await DateTimePickerDialog.selectDate(context: context, themeChange: themeChange, template: date1Template);
                    if (strDate != null) {
                      setState(() {
                        date1Template["selected_date"] = strDate;
                      });
                    }
                  },
                  child: Container(
                    height: 45,
                    margin: EdgeInsets.all(2),
                    padding: EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(width: 1, color: AppColors.grey_color)),
                    child: Row(
                      children: <Widget>[
                        Container(
                            child: Text(
                          "",
                          style: Styles.caption1,
                        )),
                        Expanded(
                            child: Text("${date1Template["selected_date"] == "today" ? "Start Date" : date1Template["selected_date"]}",
                                style: Styles.h4)),
                        Icon(
                          Icons.date_range_outlined,
                          color: AppColors.grey_color,
                        )
                      ],
                    ),
                  ))),
               Expanded(
              child: InkWell(
                  onTap: () async {
                    String strDate = await DateTimePickerDialog.selectDate(context: context, themeChange: themeChange, template: date2Template);
                    if (strDate != null) {
                      setState(() {
                        date2Template["selected_date"] = strDate;
                      });
                    }
                  },
                  child: Container(
                    height: 45,
                    margin: EdgeInsets.all(2),
                    padding: EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(width: 1, color: AppColors.grey_color)),
                    child: Row(
                      children: <Widget>[
                        Container(
                            child: Text(
                          "",
                          style: Styles.caption1,
                        )),
                        Expanded(
                            child:
                                Text("${date2Template["selected_date"] == "today" ? "End Date" : date2Template["selected_date"]}", style: Styles.h4)),
                        Icon(
                          Icons.date_range_outlined,
                          color: AppColors.grey_color,
                        )
                      ],
                    ),
                  )))
        ]));
      }
      else if (selectedDimension["id"] == "2") {
        return Container(
            child: Row(children: [
                  Expanded(
              child: Container(
                  height: 45,
                  margin: EdgeInsets.all(2),
                  padding: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(width: 1, color: AppColors.grey_color)),
                  child: DropdownButton<dynamic>(
                    underline: SizedBox(),
                    hint: Text("Select Month"),
                    value: selectedMonth,
                    isExpanded: true,
                    onChanged: (newValue) {
                      setState(() {
                        selectedMonth = newValue;
                      });
                    },
                    items: months.map((dynamic lang) {
                      return DropdownMenuItem<dynamic>(
                        value: lang,
                        child: Text(
                          lang["name"],
                          style: Styles.h3,
                        ),
                      );
                    }).toList(),
                  ))),
                  Expanded(
              child: Container(
                  height: 45,
                  margin: EdgeInsets.all(2),
                  padding: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(width: 1, color: AppColors.grey_color)),
                  child: DropdownButton<dynamic>(
                    underline: SizedBox(),
                    hint: Text("Select Year"),
                    value: selectedYear,
                    isExpanded: true,
                    onChanged: (newValue) {
                      print("SelectedAccount : ${newValue}");
                      setState(() {
                        selectedYear = newValue;
                      });
                    },
                    items: years.map((dynamic lang) {
                      return DropdownMenuItem<dynamic>(
                        value: lang,
                        child: Text(
                          lang["name"],
                          style: Styles.h3,
                        ),
                      );
                    }).toList(),
                  )))
        ]));
      }
      else if (selectedDimension["id"] == "3") {
        return Container(
            height: 45,
            margin: EdgeInsets.all(2),
            padding: EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(width: 1, color: AppColors.grey_color)),
            child: DropdownButton<dynamic>(
              underline: SizedBox(),
              hint: Text("Select Year"),
              value: selectedYear,
              isExpanded: true,
              onChanged: (newValue) {
                setState(() {
                  selectedYear = newValue;
                });
              },
              items: years.map((dynamic lang) {
                return DropdownMenuItem<dynamic>(
                  value: lang,
                  child: Text(
                    lang["name"],
                    style: Styles.h3,
                  ),
                );
              }).toList(),
            ));
      }
      else if (selectedDimension["id"] == "4") {
        return Row(children: [
          Expanded(
              child: Container(
                  height: 45,
                  margin: EdgeInsets.all(2),
                  padding: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(width: 1, color: AppColors.grey_color)),
                  child: DropdownButton<dynamic>(
                    underline: SizedBox(),
                    hint: Text("Select Semester"),
                    value: selectedSemester,
                    isExpanded: true,
                    onChanged: (newValue) {
                      setState(() {
                        selectedSemester = newValue;
                      });
                    },
                    items: semester.map((dynamic lang) {
                      return DropdownMenuItem<dynamic>(
                        value: lang,
                        child: Text(
                          lang["name"],
                          style: Styles.h3,
                        ),
                      );
                    }).toList(),
                  ))),
          Expanded(
              child: Container(
                  height: 45,
                  margin: EdgeInsets.all(2),
                  padding: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(width: 1, color: AppColors.grey_color)),
                  child: DropdownButton<dynamic>(
                    underline: SizedBox(),
                    hint: Text("Select Year"),
                    value: selectedYear,
                    isExpanded: true,
                    onChanged: (newValue) {
                      print("SelectedAccount : ${newValue}");
                      setState(() {
                        selectedYear = newValue;
                      });
                    },
                    items: years.map((dynamic lang) {
                      return DropdownMenuItem<dynamic>(
                        value: lang,
                        child: Text(
                          lang["name"],
                          style: Styles.h3,
                        ),
                      );
                    }).toList(),
                  )))
        ]);
      }
      else if (selectedDimension["id"] == "5") {
        return Row(children: [
          Expanded(
              child: Container(
                  height: 45,
                  margin: EdgeInsets.all(2),
                  padding: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(width: 1, color: AppColors.grey_color)),
                  child: DropdownButton<dynamic>(
                    underline: SizedBox(),
                    hint: Text("Select Quarter"),
                    value: selectedQuarter,
                    isExpanded: true,
                    onChanged: (newValue) {
                      setState(() {
                        selectedQuarter = newValue;
                      });
                    },
                    items: quarter.map((dynamic lang) {
                      return DropdownMenuItem<dynamic>(
                        value: lang,
                        child: Text(
                          lang["name"],
                          style: Styles.h3,
                        ),
                      );
                    }).toList(),
                  ))),
          Expanded(
              child: Container(
                  height: 45,
                  margin: EdgeInsets.all(2),
                  padding: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(width: 1, color: AppColors.grey_color)),
                  child: DropdownButton<dynamic>(
                    underline: SizedBox(),
                    hint: Text("Select Year"),
                    value: selectedYear,
                    isExpanded: true,
                    onChanged: (newValue) {
                      print("SelectedAccount : ${newValue}");
                      setState(() {
                        selectedYear = newValue;
                      });
                    },
                    items: years.map((dynamic lang) {
                      return DropdownMenuItem<dynamic>(
                        value: lang,
                        child: Text(
                          lang["name"],
                          style: Styles.h3,
                        ),
                      );
                    }).toList(),
                  )))
        ]);
      }
    }

    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter state) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
               //height: 250,
              height: 270,
              child: Column(children: [
                Container(margin: EdgeInsets.all(5), child: Text("Time Dimension Filter", style: Styles.h2)),
                SizedBox(height: 10),
                Container(
                    height: 45,
                    margin: EdgeInsets.all(2),
                    padding: EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(width: 1, color: AppColors.grey_color)),
                    child: DropdownButton<dynamic>(
                      underline: SizedBox(),
                      hint: Text("Select Account"),
                      value: selectedDimension,
                      isExpanded: true,
                      onChanged: (newValue) {
                        print("SelectedAccount : ${newValue}");
                        state(() {
                          selectedDimension = newValue;
                        });
                      },
                      items: dimensions.map((dynamic lang) {
                        return DropdownMenuItem<dynamic>(
                          value: lang,
                          child: Text(
                            lang["name"],
                            style: Styles.h3,
                          ),
                        );
                      }).toList(),
                    )),
                SizedBox(height: 10),
                createViewBaseDimension(selectedDimension, state),
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Container(
                      height: 45,
                      margin: EdgeInsets.all(2),
                      padding: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(width: 1, color: Colors.grey),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedDivision,
                        hint: Text(
                          selectedDivisionDesc ?? "Select division",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        items: divisions.map((division) {
                          return DropdownMenuItem<String>(
                            value: division["division_id"],
                            child: Text(division["division_desc"] ?? '',
                              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold), // Ensure bold and black for items
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDivision = value; // Update selected division_id
                            selectedDivisionDesc = divisions.firstWhere(
                                    (division) => division["division_id"] == value)["division_desc"];
                          });
                          print("Selected division: $value");
                        },
                        // selectedItemBuilder: (BuildContext context) {
                        //   return divisions.map((division) {
                        //     return Text(
                        //       division["division_desc"] ?? "Select division",
                        //       style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500), // Style for selected item
                        //     );
                        //   }).toList();
                        // },
                      ),
                    );
                  },
                ),
                Row(children: [
                  Container(
                    child: MaterialButton(
                      child: Text(
                        "Clear",
                        style: Styles.h4.copyWith(color: themeData.primaryColor),
                      ),
                      onPressed: () {
                        selectedFilter = null;
                        Navigator.pop(context);
                      },
                      color: themeData.accentColor,
                    ),
                  ),
                  Expanded(child: Container()),
                  Container(
                    alignment: Alignment.centerRight,
                    child: MaterialButton(
                      child: Text(
                        "Submit",
                        style: Styles.h4.copyWith(color: themeData.primaryColor),
                      ),
                      onPressed: () {
                        selectedFilter = new HashMap();
                        selectedFilter["dimension"] = selectedDimension;
                        if (selectedDimension["id"] == "1") {
                          if (date1Template["selected_date"] == "today") {
                            Constants_data.toastError("Please select Start date");
                            selectedFilter = null;
                            return;
                          } else if (date2Template["selected_date"] == "today") {
                            Constants_data.toastError("Please select End date");
                            selectedFilter = null;
                            return;
                          }
                          try {
                            // Parse the start and end dates from 'dd-MM-yyyy'
                            DateTime start = Constants_data.stringToDate(date1Template["selected_date"], "dd-MM-yyyy");
                            DateTime end = Constants_data.stringToDate(date2Template["selected_date"], "dd-MM-yyyy");
                            // Ensure start and end variables are valid before proceeding
                            if (start == null || end == null) {
                              Constants_data.toastError("Error parsing date.");
                              selectedFilter = null;
                              return;
                            }
                            if (start.isAfter(end)) {
                              Constants_data.toastError("Start date can't be after End date");
                              selectedFilter = null;
                              return;
                            }
                            // Convert the dates to 'yyyy-MM-dd' format and store them in selectedFilter
                            selectedFilter["start"] = Constants_data.dateToString(start, "yyyy-MM-dd");
                            selectedFilter["end"] = Constants_data.dateToString(end, "yyyy-MM-dd");
                          } catch (ex) {
                            Constants_data.toastError("Please select proper date");
                            selectedFilter = null;
                            return;
                          }
                        }
                        // if (selectedDimension["id"] == "1") {
                        //   if (date1Template["selected_date"] == "today") {
                        //     Constants_data.toastError("Please select Start date");
                        //     selectedFilter = null;
                        //     return;
                        //   } else if (date2Template["selected_date"] == "today") {
                        //     Constants_data.toastError("Please select End date");
                        //     selectedFilter = null;
                        //     return;
                        //   }
                        //   try {
                        //      DateTime start = Constants_data.stringToDate(date1Template["selected_date"], "dd-MM-yyyy");
                        //      DateTime end = Constants_data.stringToDate(date2Template["selected_date"], "dd-MM-yyyy");
                        //     //DateTime start = Constants_data.stringToDate(date1Template["selected_date"], "yyyy-MM-dd");
                        //     //DateTime end = Constants_data.stringToDate(date2Template["selected_date"], "yyyy-MM-dd");
                        //     if (start.isAfter(end)) {
                        //       Constants_data.toastError("Start date can't be after End date");
                        //       selectedFilter = null;
                        //       return;
                        //     }
                        //   } catch (ex) {
                        //     Constants_data.toastError("Please select proper date");
                        //     selectedFilter = null;
                        //     return;
                        //   }
                        //   selectedFilter["start"] = "${date1Template["selected_date"]}";
                        //   selectedFilter["end"] = "${date2Template["selected_date"]}";
                        // }
                        else if (selectedDimension["id"] == "2") {
                          if (selectedMonth == null) {
                            Constants_data.toastError("Please select Month");
                            selectedFilter = null;
                            return;
                          } else if (selectedYear == null) {
                            Constants_data.toastError("Please select Year");
                            selectedFilter = null;
                            return;
                          }
                          selectedFilter["month"] = selectedMonth;
                          selectedFilter["year"] = selectedYear;
                        }
                        else if (selectedDimension["id"] == "3") {
                          if (selectedYear == null) {
                            Constants_data.toastError("Please select Year");
                            selectedFilter = null;
                            return;
                          }
                          selectedFilter["year"] = selectedYear;
                        }
                        else if (selectedDimension["id"] == "4") {
                          if (selectedSemester == null) {
                            Constants_data.toastError("Please select Semester");
                            selectedFilter = null;
                            return;
                          } else if (selectedYear == null) {
                            Constants_data.toastError("Please select Year");
                            selectedFilter = null;
                            return;
                          }
                          selectedFilter["semester"] = selectedSemester;
                          selectedFilter["year"] = selectedYear;
                        }
                        else if (selectedDimension["id"] == "5") {
                          if (selectedQuarter == null) {
                            Constants_data.toastError("Please select Semester");
                            selectedFilter = null;
                            return;
                          } else if (selectedYear == null) {
                            Constants_data.toastError("Please select Year");
                            selectedFilter = null;
                            return;
                          }
                          selectedFilter["quarter"] = selectedQuarter;
                          selectedFilter["year"] = selectedYear;
                        }
                        print("Selected Dimension : ${selectedFilter}");
                        // Pass selected division ID to the API
                        if (selectedDivision == null) {
                          Constants_data.toastError("Please select a division");
                          return;
                        }
                        selectedFilter["division_id"] = selectedDivision;
                        this.setState(() {
                          isLoaded = false;
                        });
                        Navigator.pop(context);
                      },
                      color: themeData.accentColor,
                    ),
                  )
                ])
              ]),
            );
          });
        });
  }
  Future<void> getDivisionData() async {
    bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
    if (isNetworkAvailable) {
      try {
        // Use StateManager to get the divisions instead of calling the API directly
        List<dynamic> divisionData = await StateManager.getDivisionManager();

        // Assuming divisionData contains the list in the same structure
        setState(() {
          divisions = divisionData.map((division) {
            return {
              "division_id": division["division"],
              "division_desc": division["division_name"]
            };
          }).toList();
          isLoading = false; // Stop loading when data is fetched
        });

        print('Division Data: $divisions');
      } catch (error) {
        print('Error: $error');
        setState(() {
          isLoading = false; // Ensure loading stops in case of an error
        });
      }
    } else {
      await Constants_data.openDialogNoInternetConection(context);
    }
  }
  Future<void> getDivisionDatass() async {

    bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
    if (isNetworkAvailable) {
      // final String url = 'http://122.170.7.252/MicroDishaWebApiPublish/api/Dashboard/GetDivisionListRepWise?repId=${dataUser["RepId"]}';
      // Map<String, String> headers = {
      //   "Content-type": "application/json",
      //   "Authorization": Constants_data.SessionId,
      //   "CountryCode": Constants_data.Country,
      //   "IPAddress": Constants_data.deviceId,
      //   "UserId": Constants_data.repId,
      // };
      String url = '/Dashboard/GetDivisionListRepWise?repId=${dataUser["RepId"]}';

      try {
       // final response = await http.get(Uri.parse(url), headers: headers);
        final divisiondata = await _helper.get(url);
        // if (response.statusCode == 200) {
        // var divisiondata = jsonDecode(response.body);
        if (divisiondata["status"].toString() == "8") {
          Constants_data.toastError(divisiondata["message"]);
        }if (divisiondata["status"].toString() == "5") {
          Constants_data.toastError(divisiondata["message"]);
        }else if (divisiondata["status"].toString() == "4") {
          Constants_data.toastError(divisiondata["message"]);
        }else if (divisiondata["Status"] == 1) {
        List<dynamic> divisionList = divisiondata["dt_ReturnedTables"][0];
        setState(() {
          divisions = divisionList.map((division) {
            return {
              "division_id": division["division_id"],
              "division_desc": division["division_desc"]
            };
          }).toList();
          isLoading = false; // Stop loading when data is fetched
        });
        print('Division Data: $divisions');}
        //}
         // else {
         //   print('Failed to load division data');
         //   setState(() {
         //     isLoading = false;
         //   });
         // }
      } catch (error) {
        print('Error: $error');
        setState(() {
          isLoading = false;
        });
      }
    }
    else {
      await Constants_data.openDialogNoInternetConection(context);
    }
  }
  void showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alert Message"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                this.setState((){});
              },
            ),
          ],
        );
      },
    );
  }
}
