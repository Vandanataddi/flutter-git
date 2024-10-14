import 'dart:collection';

import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Constants/MonthPicker/month_picker_dialog.dart';
import 'package:flexi_profiler/Constants/StateManager.dart';
import 'package:flexi_profiler/Constants/const.dart';
import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
import 'package:flexi_profiler/DBClasses/DBProfessionalList.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flexi_profiler/Theme/StyleClass.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class DCR_Summary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DCR_Summary1();
  }
}

class DCR_Summary1 extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<DCR_Summary1> with TickerProviderStateMixin {
  List<dynamic> mainData = [];

  // ignore: non_constant_identifier_names
  var ObjRetArgs;
  TextStyle titleStyle = TextStyle(color: AppColors.main_color, fontSize: 14, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold);

  DateTime selectedDate = DateTime.now();
  ApiBaseHelper _helper = ApiBaseHelper();
  AnimationController _hideFabAnimController;

  dynamic selectedCustomer;
  dynamic selectedUser;
  dynamic selectedAccount;
  String monthYear = Constants_data.dateToString(DateTime.now(), "MM-yyyy");

  List<dynamic> accountType = [
    {"id": "HCP", "name": "Doctor"},
    {"id": "Customer", "name": "Pharmacy"}
  ];

  List<dynamic> listCustomers;
  List<dynamic> listDoctors;
  List<dynamic> listMainData;

  @override
  initState() {
    super.initState();
    selectedDate = DateTime.now();
    _hideFabAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      value: 1,
    );

    //selectedAccount = accountType[0];

    _hideButtonController = new ScrollController();
    _hideButtonController.addListener(() {
      if (_hideButtonController.position.userScrollDirection == ScrollDirection.reverse) {
        _hideFabAnimController.reverse();
      } else if (_hideButtonController.position.userScrollDirection == ScrollDirection.forward) {
        _hideFabAnimController.forward();
      }
    });
  }

  void dispose() {
    _hideButtonController.dispose();
    _hideFabAnimController.dispose();
    super.dispose();
  }

  bool isLoaded = false;
  ScrollController _hideButtonController;
  DarkThemeProvider themeChange;
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    Constants_data.currentScreenContext = context;
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    return Scaffold(
        floatingActionButton: Constants_data.app_user["Designation"] == "MR"
            ? FadeTransition(
                opacity: _hideFabAnimController,
                child: ScaleTransition(
                  scale: _hideFabAnimController,
                  child: FloatingActionButton(
                    backgroundColor: themeColor,
                    child: Icon(Icons.add),
                    onPressed: () {
                      Navigator.pushNamed(context, "/DCR_Entry");
                    },
                  ),
                ),
              )
            : null,
        appBar: AppBar(
          flexibleSpace: Constants_data.getFlexibleAppBar(themeChange.darkTheme),
          title: new Text("DCR Summary"),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    print("Tap Calendar");
                    filterBottomSheet(context);
                    // showMonthPicker(
                    //         context: context,
                    //         firstDate: DateTime(DateTime.now().year - 3),
                    //         lastDate: DateTime(
                    //             DateTime.now().year, DateTime.now().month),
                    //         initialDate: selectedDate)
                    //     .then((date) {
                    //   if (date != null) {
                    //     print(date);
                    //     setState(() {
                    //       isLoaded = false;
                    //       selectedDate = date;
                    //     });
                    //   }
                    // });
                  },
                  child: Icon(
                    Icons.filter_alt,
                    size: 26.0,
                  ),
                )),
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    showInfo();
                  },
                  child: Icon(
                    Icons.info,
                    size: 26.0,
                  ),
                )),
          ],
        ),
        body: SingleChildScrollView(
          controller: _hideButtonController,
          child: isLoaded
              ? Column(
                  children: getTableView(),
                )
              : FutureBuilder<List<dynamic>>(
                  future: getDemoResponse(Constants_data.dateToString(selectedDate, "MM-yyyy")),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.data != null && snapshot.data.length > 0) {
                        return new Column(
                          children: getTableView(),
                        );
                      } else if (snapshot.data == null) {
                        return Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Container(
                              margin: EdgeInsets.only(top: 10),
                              child: new Text("DATA LOADING ERROR"),
                            )
                          ],
                        ));
                      } else {
                        return Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Container(
                              margin: EdgeInsets.only(top: 10),
                              child: new Text("Empty list"),
                            )
                          ],
                        ));
                      }
                    } else if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircularProgressIndicator(),
                              new Container(
                                margin: EdgeInsets.only(top: 10),
                                child: new Text("Loading..."),
                              )
                            ],
                          ));
                    } else {
                      return Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Container(
                            margin: EdgeInsets.only(top: 10),
                            child: new Text("Data loading error"),
                          )
                        ],
                      ));
                    }
                  }),
        ));
  }

  bool isLoadedCustomer = false;
  bool isLoadedDoctors = false;
  List<dynamic> userFilter = [];
  bool isShowUserFilter = false;
  bool isUserLoaded = false;

  Future<List<dynamic>> getDemoResponse(String s) async {
    var dataUser;
    if (Constants_data.app_user == null) {
      dataUser = await StateManager.getLoginUser();
    } else {
      dataUser = Constants_data.app_user;
    }

    if (dataUser["Designation"] != "MR") isShowUserFilter = true;

    if (!isLoadedCustomer) {
      listCustomers = await DBProfessionalList.prformQueryOperation(
          "select distinct CustomerId, CustomerName from ProfessionalList where AccountType = 'Customer'", []);
      listCustomers = listCustomers.toSet().toList();
      isLoadedCustomer = true;
    }

    if (!isLoadedDoctors) {
      listDoctors = await DBProfessionalList.prformQueryOperation(
          "select distinct CustomerId, CustomerName from ProfessionalList where AccountType = 'HCP'", []);
      listDoctors = listDoctors.toSet().toList();
      isLoadedDoctors = true;
    }

    if (selectedAccount == null) listMainData = [];

    if (isShowUserFilter && !isUserLoaded) {
      try {
        String url = '/GetUserListForPOBFilter?RepId=${dataUser["Rep_Id"]}"}';
        final response = await _helper.get(url);
        print("GetUserListForPOBFilter : $response");
        userFilter = response["dt_ReturnedTables"][0];
        userFilter = userFilter.toSet().toList();
        isUserLoaded = true;
      } on Exception catch (err) {
        print("Error in GetUserListForPOBFilter : $err");
      }
    }

    try {
      String url;
      if (isShowUserFilter && selectedUser != null) {
        url =
            '/GetDCRMonthlySummary?RepId=${dataUser["Rep_Id"]}&monthYear=${s}&user_id=${selectedUser["UserId"]}&dcs_code=${selectedCustomer != null ? selectedCustomer["CustomerId"] : "ALL"}&visit_type=${selectedAccount == null ? "ALL" : selectedAccount["id"]}';
      } else {
        url =
            '/GetDCRMonthlySummary?RepId=${dataUser["Rep_Id"]}&monthYear=${s}&user_id=${dataUser["Rep_Id"]}&dcs_code=${selectedCustomer != null ? selectedCustomer["CustomerId"] : "ALL"}&visit_type=${selectedAccount == null ? "ALL" : selectedAccount["id"]}';
      }

      final response = await _helper.get(url);
      var mainData = response["dt_ReturnedTables"];
      var ObjRetArgs = response["ObjRetArgs"];
      this.ObjRetArgs = ObjRetArgs[0];
      this.mainData = mainData[0];
      isLoaded = true;
      return mainData;
    } on Exception catch (err) {
      print("Error in GetDCRMonthlySummary : ${err}");
      isLoaded = true;
      return null;
    }
  }

  filterBottomSheet(context) async {
    var selectedCustomer = this.selectedCustomer;
    var selectedUser = this.selectedUser;
    var selectedAccount = this.selectedAccount;
    switch (await showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter state) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                        flex: 20,
                        child: Container(
                          child: Text(
                            "Date",
                            style: Styles.subtitle1,
                          ),
                        )),
                    Text(
                      " :  ",
                      style: Styles.subtitle1,
                    ),
                    Expanded(
                        flex: 80,
                        child: Container(
                            child: InkWell(
                                onTap: () async {
                                  await monthPicker(state);
                                },
                                child: Container(
                                  height: 40,
                                  margin: EdgeInsets.all(2),
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5), border: Border.all(width: 1, color: AppColors.grey_color)),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                          child: Text("${monthYear == null ? "Select Month-Year" : monthYear}",
                                              style: monthYear == null ? Styles.subtitle1 : Styles.h4)),
                                      Icon(
                                        Icons.date_range_outlined,
                                        color: AppColors.grey_color,
                                      )
                                    ],
                                  ),
                                ))))
                  ]),
                  isShowUserFilter
                      ? SizedBox(
                          height: 10,
                        )
                      : Container(),
                  isShowUserFilter
                      ? Row(children: [
                          Expanded(
                              flex: 20,
                              child: Container(
                                child: Text(
                                  "User",
                                  style: Styles.subtitle1,
                                ),
                              )),
                          Text(
                            " :  ",
                            style: Styles.subtitle1,
                          ),
                          Expanded(
                              flex: 80,
                              child: DropdownButton<dynamic>(
                                hint: Text("Select User"),
                                isExpanded: true,
                                value: selectedUser,
                                onChanged: (newValue) {
                                  print("Selected User : $newValue");
                                  state(() {
                                    selectedUser = newValue;
                                  });
                                },
                                items: userFilter.map((dynamic val) {
                                  return DropdownMenuItem<dynamic>(
                                    value: val,
                                    child: Text(
                                      val["Name"],
                                      style: Styles.h3.copyWith(color: themeData.primaryColorLight),
                                    ),
                                  );
                                }).toList(),
                              ))
                        ])
                      : Container(),
                  SizedBox(
                    height: 10,
                  ),
                  Row(children: [
                    Expanded(
                        flex: 20,
                        child: Container(
                          child: Text(
                            "Visit Type",
                            style: Styles.subtitle1,
                          ),
                        )),
                    Text(
                      " :  ",
                      style: Styles.subtitle1,
                    ),
                    Expanded(
                        flex: 80,
                        child: DropdownButton<dynamic>(
                          hint: Text("Account Type"),
                          isExpanded: true,
                          value: selectedAccount,
                          onChanged: (newValue) {
                            print("Selected AccountType : $newValue");
                            state(() {
                              selectedCustomer = null;
                              selectedAccount = newValue;
                              if (newValue["id"] == "HCP") {
                                listMainData = listDoctors;
                              } else {
                                listMainData = listCustomers;
                              }
                            });
                          },
                          items: accountType.map((dynamic val) {
                            return DropdownMenuItem<dynamic>(
                              value: val,
                              child: Text(
                                val["name"],
                                style: Styles.h3.copyWith(color: themeData.primaryColorLight),
                              ),
                            );
                          }).toList(),
                        ))
                  ]),
                  SizedBox(
                    height: 10,
                  ),
                  Row(children: [
                    Expanded(
                        flex: 20,
                        child: Container(
                          child: Text(
                            "Account",
                            style: Styles.subtitle1,
                          ),
                        )),
                    Text(
                      " :  ",
                      style: Styles.subtitle1,
                    ),
                    Expanded(
                        flex: 80,
                        child: DropdownButton<dynamic>(
                          hint: Text("Select Account"),
                          isExpanded: true,
                          value: selectedCustomer,
                          onChanged: (newValue) {
                            print("Selected Account : $newValue");
                            state(() {
                              selectedCustomer = newValue;
                            });
                          },
                          items: listMainData.map((dynamic val) {
                            return DropdownMenuItem<dynamic>(
                              value: val,
                              child: Text(
                                val["CustomerName"],
                                style: Styles.h3.copyWith(color: themeData.primaryColorLight),
                              ),
                            );
                          }).toList(),
                        ))
                  ]),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      child: Row(children: [
                    Container(
                      color: themeData.indicatorColor,
                      height: 15,
                      width: 15,
                      margin: EdgeInsets.only(right: 10),
                    ),
                    Container(child: Text("Filtered records Highlighted with this color"))
                  ])),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: MaterialButton(
                          color: themeData.accentColor,
                          onPressed: () {
                            this.setState(() {
                              this.selectedCustomer = null;
                              this.selectedUser = null;
                              this.selectedAccount = null;
                              monthYear = Constants_data.dateToString(DateTime.now(), "MM-yyyy");
                              selectedDate = DateTime.now();
                              isLoaded = false;
                            });

                            Navigator.pop(context, 1);
                          },
                          child: Text(
                            "Clear",
                            style: TextStyle(color: themeData.primaryColor),
                          ),
                        ),
                      ),
                      Expanded(child: Container()),
                      Container(
                        alignment: Alignment.centerRight,
                        child: MaterialButton(
                          color: themeData.accentColor,
                          onPressed: () {
                            if (selectedAccount != null && selectedCustomer == null) {
                              Constants_data.toastError("Please select account");
                              return null;
                            }

                            setState(() {
                              this.selectedCustomer = selectedCustomer;
                              this.selectedUser = selectedUser;
                              this.selectedAccount = selectedAccount;
                              isLoaded = false;
                            });
                            Navigator.pop(context, 0);
                          },
                          child: Text(
                            "Filter",
                            style: TextStyle(color: themeData.primaryColor),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            );
          });
        })) {
      case 0:
        return true;
        break;
      case 1:
        return false;
        break;
    }
  }

  monthPicker(state) async {
    await showMonthPicker(
            context: context,
            firstDate: DateTime(DateTime.now().year - 5),
            lastDate: DateTime(DateTime.now().year, DateTime.now().month),
            initialDate: selectedDate)
        .then((date) {
      if (date != null) {
        state(() {
          selectedDate = date;
          monthYear = Constants_data.dateToString(date, "MM-yyyy");
        });
      }
    });
  }

  BoxDecoration decorationPopup = BoxDecoration(
    border: Border(
      top: BorderSide(width: 0.2, color: Color(0xFFFFAAAAAA)),
      left: BorderSide(width: 0.2, color: Color(0xFFFFAAAAAA)),
      right: BorderSide(width: 0.2, color: Color(0xFFFFAAAAAA)),
      bottom: BorderSide(width: 0.2, color: Color(0xFFFFAAAAAA)),
    ),
  );
  BoxDecoration decorationPopupLastLeft = BoxDecoration(
    border: Border(
      top: BorderSide(width: 0.2, color: Color(0xFFFFAAAAAA)),
      right: BorderSide(width: 0.2, color: Color(0xFFFFAAAAAA)),
    ),
  );
  BoxDecoration decorationPopupLastRight = BoxDecoration(
    border: Border(
      top: BorderSide(width: 0.2, color: Color(0xFFFFAAAAAA)),
      left: BorderSide(width: 0.2, color: Color(0xFFFFAAAAAA)),
    ),
  );

  BoxDecoration decoration = BoxDecoration(
    border: Border(
      top: BorderSide(width: 0.2, color: Color(0xFFFFAAAAAA)),
      left: BorderSide(width: 0.2, color: Color(0xFFFFAAAAAA)),
      right: BorderSide(width: 0.2, color: Color(0xFFFFAAAAAA)),
      bottom: BorderSide(width: 0.2, color: Color(0xFFFFAAAAAA)),
    ),
  );

  static double popup_spacing = 15.0;
  static double data_text_size = 12.0;
  static double worktype_text_size = 12.0;

  getTableView() {
    BoxDecoration decorationHeader = BoxDecoration(
      color: themeChange.darkTheme ? Color(0xFF636363) : Color(0xFFB3B2B2),
      border: Border(
        top: BorderSide(width: 0.2, color: Color(0xFFFF888888)),
        left: BorderSide(width: 0.2, color: Color(0xFFFF888888)),
        right: BorderSide(width: 0.2, color: Color(0xFFFF888888)),
        bottom: BorderSide(width: 0.2, color: Color(0xFFFF888888)),
      ),
    );
    TextStyle header = Theme.of(context).textTheme.bodyText2;
    List<Widget> listColumns = [];
    listColumns.add(new Row(
      children: <Widget>[
        new Container(
          decoration: decorationHeader,
          height: 35,
          width: MediaQuery.of(context).size.width / 6,
          child: new Center(
            child: new Text(
              "Date",
              style: header,
            ),
          ),
        ),
        new Container(
          decoration: decorationHeader,
          height: 35,
          width: MediaQuery.of(context).size.width / 6,
          child: new Center(
            child: new Text(
              "MCR",
              style: header,
            ),
          ),
        ),
        new Container(
          decoration: decorationHeader,
          height: 35,
          width: MediaQuery.of(context).size.width / 6,
          child: new Center(
            child: new Text(
              "NONMCR",
              style: header,
            ),
          ),
        ),
        new Container(
          decoration: decorationHeader,
          height: 35,
          width: MediaQuery.of(context).size.width / 6,
          child: new Center(
            child: new Text(
              "Chemist",
              style: header,
            ),
          ),
        ),
        new Container(
          decoration: decorationHeader,
          height: 35,
          width: MediaQuery.of(context).size.width / 6,
          child: new Center(
            child: new Text(
              "Stockiest",
              style: header,
            ),
          ),
        ),
        new Container(
          decoration: decorationHeader,
          height: 35,
          width: MediaQuery.of(context).size.width / 6,
          child: new Center(
            child: new Text(
              "POB",
              style: header,
            ),
          ),
        ),
      ],
    ));
    for (int i = 0; i < mainData.length; i++) {
      if (mainData[i]["work_type"] == "") {
        listColumns.add(GestureDetector(
            onTap: () {
              List<String> temp = mainData[i]["date"].toString().split("/");
              String date = '${selectedDate.year}-' + temp[1] + '-' + temp[0];
              print("Date to send : ${date}");
              Map<String, dynamic> _map = new HashMap();
              _map["date"] = date;
              _map["user"] = isShowUserFilter && selectedUser != null ? selectedUser["UserId"].toString() : Constants_data.repId;
              Navigator.of(context).pushNamed('/DCR_Entry_Details', arguments: _map);
            },
            child: Container(
                color: mainData[i]["isFiltered"] == "Y" ? themeData.indicatorColor : null,
                child: Row(
                  children: <Widget>[
                    new Container(
                      decoration: decoration,
                      height: 30,
                      width: MediaQuery.of(context).size.width / 6,
                      child: new Center(
                        child: new Text(
                          mainData[i]["date"],
                          style: TextStyle(color: AppColors.main_color, fontSize: data_text_size),
                        ),
                      ),
                    ),
                    new Container(
                      decoration: decoration,
                      height: 30,
                      width: MediaQuery.of(context).size.width / 6,
                      child: new Center(
                        child: new Text(
                          mainData[i]["MCR"],
                          style: TextStyle(fontSize: data_text_size),
                        ),
                      ),
                    ),
                    new Container(
                      decoration: decoration,
                      height: 30,
                      width: MediaQuery.of(context).size.width / 6,
                      child: new Center(
                        child: new Text(
                          mainData[i]["NONMCR"],
                          style: TextStyle(fontSize: data_text_size),
                        ),
                      ),
                    ),
                    new Container(
                      decoration: decoration,
                      height: 30,
                      width: MediaQuery.of(context).size.width / 6,
                      child: new Center(
                        child: new Text(
                          mainData[i]["Chemist"],
                          style: TextStyle(fontSize: data_text_size),
                        ),
                      ),
                    ),
                    new Container(
                      decoration: decoration,
                      height: 30,
                      width: MediaQuery.of(context).size.width / 6,
                      child: new Center(
                        child: new Text(
                          mainData[i]["Stockiest"],
                          style: TextStyle(fontSize: data_text_size),
                        ),
                      ),
                    ),
                    new Container(
                      decoration: decoration,
                      height: 30,
                      width: MediaQuery.of(context).size.width / 6,
                      child: new Center(
                        child: new Text(
                          mainData[i]["POB"],
                          style: TextStyle(fontSize: data_text_size),
                        ),
                      ),
                    ),
                  ],
                ))));
      } else {
        Color col = AppColors.white_color;
        if (mainData[i]["work_type"] == "Sunday") {
          col = AppColors.work_type_sunday;
        } else if (mainData[i]["work_type"] == "Leave") {
          col = AppColors.work_type_leave;
        } else if (mainData[i]["work_type"] == "Holiday") {
          col = AppColors.work_type_holiday;
        }
        listColumns.add(new Container(
          decoration: BoxDecoration(
            color: col,
//            border: Border(
//              top: BorderSide(width: 1.0, color: Color(0xFFFFFFFFFF)),
//              left: BorderSide(width: 1.0, color: Color(0xFFFFFFFFFF)),
//              right: BorderSide(width: 1.0, color: Color(0xFFFF000000)),
//              bottom: BorderSide(width: 1.0, color: Color(0xFFFF000000)),
//            ),
          ),
          height: 35,
          width: MediaQuery.of(context).size.width,
          child: new Center(
            child: new Text(
              mainData[i]["work_type"],
              style: TextStyle(fontSize: worktype_text_size),
            ),
          ),
        ));
      }
    }
    return listColumns;
  }

  void showInfo() {
    TextStyle titleStylePopup = TextStyle(color: themeChange.darkTheme ? Colors.grey : AppColors.dark_grey_color, fontSize: data_text_size);
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(0.01),
      barrierLabel: "Dialog",
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return Material(
            color: Colors.black12.withOpacity(0.5),
            child: SizedBox.expand(
                // makes widget fullscreen
                child: new GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Align(
                        alignment: Alignment.center,
                        child: InkWell(
                            onTap: () {},
                            child: Container(
                                decoration: new BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: new BorderRadius.only(
                                      topLeft: const Radius.circular(10.0),
                                      topRight: const Radius.circular(10.0),
                                      bottomLeft: const Radius.circular(10.0),
                                      bottomRight: const Radius.circular(10.0),
                                    )),
                                height: 325,
                                width: MediaQuery.of(context).size.width - popup_spacing,
                                child: new Column(
                                  children: <Widget>[
                                    new Container(
                                      decoration: new BoxDecoration(
                                          color: themeChange.darkTheme ? Color(0xFF636363) : Color(0xFFB3B2B2),
                                          borderRadius: new BorderRadius.only(
                                            topLeft: const Radius.circular(10.0),
                                            topRight: const Radius.circular(10.0),
                                          )),
                                      height: 45,
                                      child: new Stack(
                                        children: <Widget>[
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: new Container(
                                              padding: EdgeInsets.only(left: 10),
                                              child: new Text(
                                                "Summary Data",
                                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Align(
                                              alignment: Alignment.centerRight,
                                              child: new GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: new Container(
                                                  padding: EdgeInsets.only(right: 10),
                                                  child: new Text(
                                                    "Close",
                                                  ),
                                                ),
                                              ))
                                        ],
                                      ),
                                    ),
                                    new Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        new Container(
                                          width: (MediaQuery.of(context).size.width - popup_spacing) / 2,
                                          height: 40,
                                          decoration: decorationPopup,
                                          child: new Stack(
                                            children: <Widget>[
                                              new Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(left: 5),
                                                    child: new Text(
                                                      "TOTAL DR. MEET",
                                                      style: titleStylePopup,
                                                    ),
                                                  )),
                                              new Align(
                                                  alignment: Alignment.centerRight,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    child: new Text(
                                                      ObjRetArgs["totalDrMeet"],
                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: data_text_size),
                                                    ),
                                                  ))
                                            ],
                                          ),
                                        ),
                                        new Container(
                                          width: (MediaQuery.of(context).size.width - popup_spacing) / 2,
                                          height: 40,
                                          decoration: decorationPopup,
                                          child: new Stack(
                                            children: <Widget>[
                                              new Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(left: 5),
                                                    child: new Text(
                                                      "CHEMIST MEET",
                                                      style: titleStylePopup,
                                                    ),
                                                  )),
                                              new Align(
                                                  alignment: Alignment.centerRight,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    child: new Text(
                                                      ObjRetArgs["totalChemistMeet"],
                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: data_text_size),
                                                    ),
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    new Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        new Container(
                                          width: (MediaQuery.of(context).size.width - popup_spacing) / 2,
                                          height: 40,
                                          decoration: decorationPopup,
                                          child: new Stack(
                                            children: <Widget>[
                                              new Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(left: 5),
                                                    child: new Text(
                                                      "DR. CALL AVERAGE",
                                                      style: titleStylePopup,
                                                    ),
                                                  )),
                                              new Align(
                                                  alignment: Alignment.centerRight,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    child: new Text(
                                                      ObjRetArgs["drCallAvg"],
                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: data_text_size),
                                                    ),
                                                  ))
                                            ],
                                          ),
                                        ),
                                        new Container(
                                          width: (MediaQuery.of(context).size.width - popup_spacing) / 2,
                                          height: 40,
                                          decoration: decorationPopup,
                                          child: new Stack(
                                            children: <Widget>[
                                              new Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(left: 5),
                                                    child: new Text(
                                                      "CHEMIST CALL AVG",
                                                      style: titleStylePopup,
                                                    ),
                                                  )),
                                              new Align(
                                                  alignment: Alignment.centerRight,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    child: new Text(
                                                      ObjRetArgs["chemistCallAvg"],
                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: data_text_size),
                                                    ),
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    new Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        new Container(
                                          width: (MediaQuery.of(context).size.width - popup_spacing) / 2,
                                          height: 40,
                                          decoration: decorationPopup,
                                          child: new Stack(
                                            children: <Widget>[
                                              new Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(left: 5),
                                                    child: new Text(
                                                      "STOCKIEST MEET",
                                                      style: titleStylePopup,
                                                    ),
                                                  )),
                                              new Align(
                                                  alignment: Alignment.centerRight,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    child: new Text(
                                                      ObjRetArgs["totalStockiestMeet"],
                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: data_text_size),
                                                    ),
                                                  ))
                                            ],
                                          ),
                                        ),
                                        new Container(
                                          width: (MediaQuery.of(context).size.width - popup_spacing) / 2,
                                          height: 40,
                                          decoration: decorationPopup,
                                          child: new Stack(
                                            children: <Widget>[
                                              new Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(left: 5),
                                                    child: new Text(
                                                      "MCR DR. COVERAGE",
                                                      style: titleStylePopup,
                                                    ),
                                                  )),
                                              new Align(
                                                  alignment: Alignment.centerRight,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    child: new Text(
                                                      ObjRetArgs["MCRDrCoverage"],
                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: data_text_size),
                                                    ),
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    new Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        new Container(
                                          width: (MediaQuery.of(context).size.width - popup_spacing) / 2,
                                          height: 40,
                                          decoration: decorationPopup,
                                          child: new Stack(
                                            children: <Widget>[
                                              new Align(
                                                alignment: Alignment.centerLeft,
                                                child: new Container(
                                                  margin: EdgeInsets.only(left: 5),
                                                  child: new Text("FIELD WORK DAY", style: titleStylePopup),
                                                ),
                                              ),
                                              new Align(
                                                  alignment: Alignment.centerRight,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    child: new Text(
                                                      ObjRetArgs["fieldWorkDay"],
                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: data_text_size),
                                                    ),
                                                  ))
                                            ],
                                          ),
                                        ),
                                        new Container(
                                          width: (MediaQuery.of(context).size.width - popup_spacing) / 2,
                                          height: 40,
                                          decoration: decorationPopup,
                                          child: new Stack(
                                            children: <Widget>[
                                              new Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(left: 5),
                                                    child: new Text(
                                                      "MCR COVERAGE %",
                                                      style: titleStylePopup,
                                                    ),
                                                  )),
                                              new Align(
                                                  alignment: Alignment.centerRight,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    child: new Text(
                                                      ObjRetArgs["MCRCoveragePr"],
                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: data_text_size),
                                                    ),
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    new Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        new Container(
                                          width: (MediaQuery.of(context).size.width - popup_spacing) / 2,
                                          height: 40,
                                          decoration: decorationPopup,
                                          child: new Stack(
                                            children: <Widget>[
                                              new Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(left: 5),
                                                    child: new Text(
                                                      "CONFERENCE",
                                                      style: titleStylePopup,
                                                    ),
                                                  )),
                                              new Align(
                                                  alignment: Alignment.centerRight,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    child: new Text(
                                                      ObjRetArgs["conference"],
                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: data_text_size),
                                                    ),
                                                  ))
                                            ],
                                          ),
                                        ),
                                        new Container(
                                          width: (MediaQuery.of(context).size.width - popup_spacing) / 2,
                                          height: 40,
                                          decoration: decorationPopup,
                                          child: new Stack(
                                            children: <Widget>[
                                              new Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(left: 5),
                                                    child: new Text(
                                                      "LEAVE",
                                                      style: titleStylePopup,
                                                    ),
                                                  )),
                                              new Align(
                                                  alignment: Alignment.centerRight,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    child: new Text(
                                                      ObjRetArgs["leave"],
                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: data_text_size),
                                                    ),
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    new Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        new Container(
                                          width: (MediaQuery.of(context).size.width - popup_spacing) / 2,
                                          height: 40,
                                          decoration: decorationPopup,
                                          child: new Stack(
                                            children: <Widget>[
                                              new Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(left: 5),
                                                    child: new Text(
                                                      "HOLIDAY",
                                                      style: titleStylePopup,
                                                    ),
                                                  )),
                                              new Align(
                                                  alignment: Alignment.centerRight,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    child: new Text(
                                                      ObjRetArgs["holiday"],
                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: data_text_size),
                                                    ),
                                                  ))
                                            ],
                                          ),
                                        ),
                                        new Container(
                                          width: (MediaQuery.of(context).size.width - popup_spacing) / 2,
                                          height: 40,
                                          decoration: decorationPopup,
                                          child: new Stack(
                                            children: <Widget>[
                                              new Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(left: 5),
                                                    child: new Text(
                                                      "POB",
                                                      style: titleStylePopup,
                                                    ),
                                                  )),
                                              new Align(
                                                  alignment: Alignment.centerRight,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    child: new Text(
                                                      ObjRetArgs["pob"],
                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: data_text_size),
                                                    ),
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    new Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        new Container(
                                          width: (MediaQuery.of(context).size.width - popup_spacing) / 2,
                                          height: 40,
                                          decoration: decorationPopupLastLeft,
                                          child: new Stack(
                                            children: <Widget>[
                                              new Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(left: 5),
                                                    child: new Text(
                                                      "OTHER",
                                                      style: titleStylePopup,
                                                    ),
                                                  )),
                                              new Align(
                                                  alignment: Alignment.centerRight,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    child: new Text(
                                                      ObjRetArgs["other"],
                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: data_text_size),
                                                    ),
                                                  ))
                                            ],
                                          ),
                                        ),
                                        new Container(
                                          width: (MediaQuery.of(context).size.width - popup_spacing) / 2,
                                          height: 40,
                                          decoration: decorationPopupLastRight,
                                          child: new Stack(
                                            children: <Widget>[
                                              new Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: new Container(
                                                    margin: EdgeInsets.only(left: 5),
                                                    child: new Text(""),
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )))))));
      },
    );
  }
}
