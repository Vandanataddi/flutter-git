import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Constants/StateManager.dart';
import 'package:flexi_profiler/Constants/bottom_sheet.dart';
import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
import 'package:flexi_profiler/DBClasses/DBProfessionalList.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class DeviationScreen extends StatefulWidget {
  @override
  _DeviationScreen createState() => _DeviationScreen();
}

class _DeviationScreen extends State<DeviationScreen> {
  TextEditingController cnt_remarks = new TextEditingController();
  int flex_heading = 2;
  int flex_container = 7;
  List<dynamic> patches = [];
  List<dynamic> work_type = [];
  List<dynamic> route_details = [];
  List<dynamic> list_distict_routes = [];
  String currentDate = "09-05-2020";
  Map<String, dynamic> currentPatches;
  Map<String, dynamic> currentCalendarData;
  bool isLoaded = false;
  List<dynamic> calendarData;
  Map<String, dynamic> selectedFieldWork;
  dynamic selectedRoute;
  bool isNonWorkingDay = false;
  ApiBaseHelper _helper = ApiBaseHelper();

  TextStyle labelStyle = TextStyle(fontSize: 13, color: Color(0xFFB3B1B1));
  TextStyle containerStyle = TextStyle(fontSize: 13);

  @override
  void initState() {
    super.initState();
  }

  ThemeData themeData;
  DarkThemeProvider themeChange;

  @override
  Widget build(BuildContext context) {
    Constants_data.currentScreenContext = context;
    themeData = Theme.of(context);
    themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Constants_data.getFlexibleAppBar(themeChange.darkTheme),
        title: Text("Deviation"),
        actions: [
          MaterialButton(
            child: Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              saveData();
            },
          )
        ],
      ),
      body: !isLoaded
          ? FutureBuilder<dynamic>(
              future: getData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          getDateRow(),
                          getWorkType(),
                          getPlannedRoute(),
                          getDeviatedRoute(),
                          getRemarks(),
                          isNonWorkingDay ? Container() : getListView(),
                        ],
                      ));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            )
          : Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  getDateRow(),
                  getWorkType(),
                  getPlannedRoute(),
                  getDeviatedRoute(),
                  getRemarks(),
                  isNonWorkingDay ? Container() : getListView(),
                ],
              )),
    );
  }

  Future<Null> getData() async {
    list_distict_routes = [];
    currentPatches = new HashMap();
    work_type = [];
    route_details = [];
    patches = [];
    DateTime cDate = Constants_data.stringToDate(currentDate, "dd-MM-yyyy");

    String month = cDate.month < 10 ? "0${cDate.month}" : "${cDate.month}";
    String date = "${month}-${cDate.year}";
    print("Months : ${date}");

    var dataUser;
    if (Constants_data.app_user == null) {
      dataUser = await StateManager.getLoginUser();
    } else {
      dataUser = Constants_data.app_user;
    }

    try {
      String url = '/GetSavedMTPData_ForCalendar?RepId=${dataUser["RepId"]}&monthYear=${date}';
      var mainData = await _helper.get(url);
      calendarData = mainData["dt_ReturnedTables"][0];
    } on Exception catch (err) {
      print("Error in GetSavedMTPData_ForCalendar : ${err}");
      calendarData = [];
    }

    var listwork_type =
        await DBProfessionalList.prformQueryOperation("select work_type_code,work_type_desc from tblWorkTypeMst", []);

    work_type = listwork_type.toSet().toList();

    route_details = await DBProfessionalList.prformQueryOperation("select * from RouteDetailsMst", []);

    Map<String, dynamic> routeDetails = new HashMap();
    for (int i = 0; i < route_details.length; i++) {
      if (route_details[i]["route_code"].toString().trim() != "" &&
          route_details[i]["route_desc"].toString().trim() != "")
        routeDetails[route_details[i]["route_code"].toString().trim()] = route_details[i]["route_desc"];
    }

    routeDetails.forEach((key, value) {
      Map<String, dynamic> routeDetails = new HashMap();
      routeDetails["route_code"] = key;
      routeDetails["route_desc"] = value;
      list_distict_routes.add(routeDetails);
    });

    print("list_distict_routes : ${routeDetails}");
    print("work_type : ${work_type}");
    print("route_details : ${route_details}");

    for (int i = 0; i < calendarData.length; i++) {
      if (calendarData[i]["date"] == currentDate && calendarData[i]["showInDeviation"] == "Y") {
        currentCalendarData = calendarData[i];
      }
    }
    for (int i = 0; i < work_type.length; i++) {
      if (work_type[i]["work_type_code"] == currentCalendarData["work_type_code"]) {
        selectedFieldWork = work_type[i];
        isNonWorkingDay = work_type[i]["work_type_desc"] != "Field Work";
      }
    }

    if (!isNonWorkingDay) {
      for (int i = 0; i < list_distict_routes.length; i++) {
        if (list_distict_routes[i]["route_code"] == currentCalendarData["route_code"])
          selectedRoute = list_distict_routes[i];
      }
    } else {
      selectedRoute = null;
    }

    print("CurrentCalendarData : ${currentCalendarData}");

    if (!isNonWorkingDay) {
      for (int i = 0; i < route_details.length; i++) {
        if (route_details[i]["date"] == currentDate) {
          currentPatches = route_details[i];
          patches = jsonDecode(route_details[i]["patches"]);
          for (int j = 0; j < patches.length; j++) {
            List<dynamic> professional = patches[j]["professionals"];
            for (int k = 0; k < professional.length; k++) {
              List<dynamic> professionalCalendar = currentCalendarData["data"];
              for (int l = 0; l < professionalCalendar.length; l++) {
                if (professionalCalendar[l]["prof_code"].toString() == professional[k]["dcs_code"].toString()) {
                  professional[k]["selected"] = true;
                  break;
                } else {
                  professional[k]["selected"] = false;
                }
              }
            }
            patches[j]["professionals"] = professional;
          }
        }
      }
    }

    print("patches : ${patches}");

    isLoaded = true;
  }

  Widget getDateRow() {
    return Container(
      child: Row(
        children: [
          Expanded(flex: flex_heading, child: Container(child: Text("Date", style: labelStyle))),
          Container(margin: EdgeInsets.only(right: 10), child: Text(":")),
          Expanded(
              flex: flex_container,
              child: Row(
                children: [
                  Expanded(child: Text("$currentDate")),
                  Container(
                      height: 35,
                      child: MaterialButton(
                        color: themeData.accentColor,
                        child: Text("Change"),
                        onPressed: () {
                          if (Platform.isIOS) {
                            selectDateiOS();
                          } else {
                            _selectDate();
                          }
                        },
                      ))
                ],
              )),
        ],
      ),
    );
  }

  Widget getWorkType() {
    return Container(
      child: Row(
        children: [
          Expanded(flex: flex_heading, child: Container(child: Text("Work Type", style: labelStyle))),
          Container(margin: EdgeInsets.only(right: 10), child: Text(":")),
          Expanded(
              flex: flex_container,
              child: Container(
                  alignment: Alignment.centerLeft,
                  height: 35,
                  child: DropdownButton<dynamic>(
                    hint: Text("Select Field Work"),
                    value: selectedFieldWork,
                    isExpanded: true,
                    onChanged: (newValue) {
                      setState(() {
                        selectedFieldWork = newValue;
                        isNonWorkingDay = newValue["work_type_desc"] != "Field Work";
                      });
                    },
                    items: work_type.map((dynamic lang) {
                      return DropdownMenuItem<dynamic>(
                        value: lang,
                        child: Text(lang["work_type_desc"]),
                      );
                    }).toList(),
                  ))),
        ],
      ),
    );
  }

  Widget getPlannedRoute() {
    return Container(
      child: Row(
        children: [
          Expanded(flex: flex_heading, child: Container(child: Text("Planned", style: labelStyle))),
          Container(margin: EdgeInsets.only(right: 10), child: Text(":")),
          Expanded(
              flex: flex_container,
              child: Container(
                  alignment: Alignment.centerLeft,
                  height: 35,
                  child: Text(
                      "${currentCalendarData["route_desc"] == "" ? "Sunday" : currentCalendarData["route_desc"]}",
                      style: containerStyle))),
        ],
      ),
    );
  }

  Widget getDeviatedRoute() {
    return Container(
      child: Row(
        children: [
          Expanded(flex: flex_heading, child: Container(child: Text("Deviated", style: labelStyle))),
          Container(margin: EdgeInsets.only(right: 10), child: Text(":")),
          Expanded(
              flex: flex_container,
              child: Container(
                  alignment: Alignment.centerLeft,
                  height: 35,
                  child: DropdownButton<dynamic>(
                    hint: Text("Select Route"),
                    value: selectedRoute,
                    isExpanded: true,
                    style: TextStyle(color: AppColors.black_color),
                    onChanged: isNonWorkingDay
                        ? null
                        : (newValue) {
                            setState(() {
                              selectedRoute = newValue;
                              for (int i = 0; i < route_details.length; i++) {
                                if (route_details[i]["route_code"] == newValue["route_code"]) {
                                  currentPatches = route_details[i];
                                  patches = jsonDecode(route_details[i]["patches"]);
                                  for (int j = 0; j < patches.length; j++) {
                                    List<dynamic> professional = patches[j]["professionals"];
                                    for (int k = 0; k < professional.length; k++) {
                                      List<dynamic> professionalCalendar = currentCalendarData["data"];
                                      for (int l = 0; l < professionalCalendar.length; l++) {
                                        if (professionalCalendar[l]["prof_code"].toString() ==
                                            professional[k]["dcs_code"].toString()) {
                                          professional[k]["selected"] = true;
                                          break;
                                        } else {
                                          professional[k]["selected"] = false;
                                        }
                                      }
                                    }
                                    patches[j]["professionals"] = professional;
                                  }
                                }
                              }
                            });
                          },
                    items: list_distict_routes.map((dynamic lang) {
                      return DropdownMenuItem<dynamic>(
                        value: lang,
                        child: Text(lang["route_desc"]),
                      );
                    }).toList(),
                  ))),
        ],
      ),
    );
  }

  Widget getRemarks() {
    return Container(
      height: 40,
      margin: EdgeInsets.all(5),
      child: TextField(
        keyboardType: TextInputType.text,
        controller: cnt_remarks,
        style: TextStyle(fontSize: 13, color: AppColors.black_color),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(width: 0.5, color: Colors.green),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(width: 0.5, color: AppColors.main_color),
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              borderSide: BorderSide(
                width: 0.5,
              )),
          hintText: "Enter remarks",
          hintStyle: TextStyle(fontSize: 13, color: Color(0xFFB3B1B1)),
        ),
      ),
    );
  }

  Widget getListView() {
    return Expanded(
        child: Container(
      child: ListView.builder(
        itemCount: patches.length,
        itemBuilder: (context, index) {
          int selectedCount = 0;
          List<dynamic> professionals = patches[index]["professionals"];
          for (int i = 0; i < professionals.length; i++) {
            if (professionals[i]["selected"]) {
              selectedCount++;
            }
          }
          return new ExpansionTile(
            title: new Text(
              "${patches[index]["patch_desc"]}  (${(selectedCount)}/${professionals.length})",
              style: new TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: AppColors.main_color),
            ),
            children: <Widget>[
              new Column(
                children: _buildExpandableContent(professionals),
              ),
            ],
          );
        },
      ),
    ));
  }

  _buildExpandableContent(List<dynamic> professionals) {
    List<Widget> columnContent = [];
    for (int i = 0; i < professionals.length; i++) {
      columnContent.add(
        new Row(children: [
          Checkbox(
            onChanged: (bool value) {
              setState(() {
                professionals[i]["selected"] = value;
              });
            },
            activeColor: AppColors.main_color,
            value: professionals[i]["selected"],
          ),
          Expanded(
              child: InkWell(
                  onTap: () {
                    setState(() {
                      professionals[i]["selected"] = !professionals[i]["selected"];
                    });
                  },
                  child: Text(
                    professionals[i]["prof_name"],
                    style: containerStyle,
                  )))
        ]),
      );
    }
    return columnContent;
  }

  selectDateiOS() async {
    DateTime picked = Constants_data.stringToDate(currentDate, "dd-MM-yyyy");
    await showModalBottomSheet1(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter state) {
            return Container(
              height: 250,
              child: Column(
                children: <Widget>[
                  new Stack(
                    children: <Widget>[
                      new Positioned(
                        child: new Align(
                          child: Container(
                              margin: EdgeInsets.only(top: 15),
                              child: new Text("Select Date", style: TextStyle(color: AppColors.black_color))),
                          alignment: Alignment.center,
                        ),
                      ),
                      new Positioned(
                          child: new Align(
                        child: MaterialButton(
                          onPressed: () {
                            if (picked != null && Constants_data.dateToString(picked, "dd-MM-yyyy") != currentDate)
                              setState(() {
                                currentDate = Constants_data.dateToString(picked, "dd-MM-yyyy");
                                print("Picked date : ${currentDate}");
                                isLoaded = false;
                              });
                            Navigator.pop(context);
                          },
                          child: new Text(
                            "Done",
                            style: TextStyle(color: AppColors.main_color),
                          ),
                        ),
                        alignment: Alignment.centerRight,
                      )),
                    ],
                  ),
                  Expanded(
                      child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          minimumDate: DateTime(2020, 5, 7),
                          maximumDate: DateTime(2020, 5, 31),
                          initialDateTime: Constants_data.stringToDate(currentDate, "dd-MM-yyyy"),
                          onDateTimeChanged: (date) {
                            picked = date;
                            print("Selected Date  : ${date}");
                          }))
                ],
              ),
            );
          });
        });
  }

  Future<Null> _selectDate() async {
    final DateTime picked = await showDatePicker(
        builder: (BuildContext context, Widget child) {
          return Constants_data.timeDatePickerTheme(child, themeChange.darkTheme,context);
        },
        context: context,
        initialDate: Constants_data.stringToDate(currentDate, "dd-MM-yyyy"),
        firstDate: DateTime(2020, 5, 7),
        lastDate: DateTime(2020, 5, 31));

    if (picked != null && Constants_data.dateToString(picked, "dd-MM-yyyy") != currentDate)
      setState(() {
        currentDate = Constants_data.dateToString(picked, "dd-MM-yyyy");
        print("Picked date : ${currentDate}");
        isLoaded = false;
      });
  }

  Future<Null> openDialogMobileNumber() async {
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
            return SimpleDialog(
              contentPadding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(0.0),
                  padding: EdgeInsets.only(bottom: 25.0, top: 25.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(bottom: 25.0),
                          child: Text(
                            'Saving Data',
                            style: TextStyle(color: AppColors.main_color, fontSize: 20.0, fontWeight: FontWeight.bold),
                          )),
                      Container(
                        child: CircularProgressIndicator(),
                        margin: EdgeInsets.only(bottom: 25.0),
                      ),
                      Container(
                          child: Text(
                        'Please wait...',
                        style: TextStyle(color: AppColors.black_color, fontSize: 18.0, fontWeight: FontWeight.bold),
                      )),
                    ],
                  ),
                ),
              ],
            );
          });
        });
  }

  saveData() async {
    openDialogMobileNumber();
    Map<String, dynamic> mainData = new HashMap();
    mainData["date"] = currentDate;
    mainData["work_type"] = selectedFieldWork["work_type_code"];
    mainData["planned_route"] = currentCalendarData["route_code"];
    mainData["deviated_route"] = selectedRoute["route_code"];
    mainData["remarks"] = cnt_remarks.text;
    bool isSingleSelected = false;
    List<dynamic> selectedProf = [];
    for (int i = 0; i < patches.length; i++) {
      List<dynamic> professionals = patches[i]["professionals"];
      for (int j = 0; j < professionals.length; j++) {
        if (professionals[j]["selected"]) {
          Map<String, dynamic> prof = new HashMap();
          prof["account_type"] = professionals[j]["prof_type"];
          prof["prof_code"] = professionals[j]["dcs_code"];
          prof["patch_id"] = patches[i]["patch_id"];
          selectedProf.add(prof);
          isSingleSelected = true;
        }
      }
    }
    if (isSingleSelected || isNonWorkingDay) {
      mainData["professionals"] = selectedProf;
      print("mainData Request: ${jsonEncode(mainData)}");

      var currentUser;

      if (Constants_data.app_user == null) {
        currentUser = await StateManager.getLoginUser();
      } else {
        currentUser = Constants_data.app_user;
      }

      try {
        String url =
            "/SaveDeviationData?RepId=${currentUser["RepId"]}&monthYear=${Constants_data.dateToString(Constants_data.stringToDate(currentDate, "dd-MM-yyyy"), "MM-yyyy")}";
        var data = await _helper.post(url, mainData, true);
        if (data["Status"] == 1) {
          Constants_data.toastNormal(data["Message"].toString());
        } else {
          Constants_data.toastError(data["Message"].toString());
        }
      } on Exception catch (err) {
        print("Error in ");
      }
    } else {
      Constants_data.toastError("Must need to select atleast one Doctor");
    }
    Navigator.pop(context);
  }
}
