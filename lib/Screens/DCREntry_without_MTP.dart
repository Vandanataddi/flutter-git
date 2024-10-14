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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DCREntry_without_MTP extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<DCREntry_without_MTP> {
  TextStyle lableStyle;
  TextStyle contentStyle;
  TextStyle sectionHeadingStyle;

  List<dynamic> productGroupData = [];
  List<dynamic> sampleData = [];
  List<dynamic> promotionalItemsData = [];
  List<dynamic> listPromotionalItems = [];
  List<dynamic> calendarData = [];
  List<dynamic> doctorList = [];
  List<dynamic> workType = [];
  List<dynamic> route = [];

  ApiBaseHelper _helper = ApiBaseHelper();

  String date = Constants_data.dateToString(Constants_data.appName == "Microlabs" ? new DateTime(2020, 5, 1) : DateTime.now(), "dd-MM-yyyy");
  String time = Constants_data.dateToString(DateTime.now(), "hh:mm a");
  String _selectedAccount = "HCP";
  String selectedAccountName = "Doctor";
  dynamic selectedWorkType;
  dynamic selectedRoute;
  String strSelectedWorkType;
  String strSelectedRoute;

  bool isLoaded = false;
  bool ckb_sendToSuperior = false;
  bool ckb_jointWork = false;

  dynamic dropdownValueDoctorType;

  TextEditingController cnt_jointWork = new TextEditingController();
  TextEditingController cnt_non_mcr_dr = new TextEditingController();
  TextEditingController cnt_pob = new TextEditingController();

  final GlobalKey<AppExpansionTileState> gKey_productGroup = new GlobalKey();
  final GlobalKey<AppExpansionTileState> gKey_productSanmple = new GlobalKey();
  final GlobalKey<AppExpansionTileState> gKey_productPromotional = new GlobalKey();

  var selectedDoctorfromArgs;

  DateTime selectedDate = Constants_data.appName == "Microlabs" ? new DateTime(2020, 5, 1) : DateTime(DateTime.now().year, DateTime.now().month, 1);

  int _radioValue = 0;

  bool isShowDoctorDetails = true;

  List<dynamic> choices = <dynamic>[
    {"name": "Doctor", "accout_id": "HCP"},
    {"name": "Customer", "accout_id": "Pharmacy"},
  ];

  void _select(dynamic choice) {
    setState(() {
      isLoaded = false;
      _selectedAccount = choice["accout_id"];
    });
    print("Selected Choice : $choice");
  }

  ThemeData themeData;
  DarkThemeProvider themeChange;

  initStyles(context) {
    themeData = Theme.of(context);
    themeChange = Provider.of<DarkThemeProvider>(context);
    lableStyle = TextStyle(color: AppColors.grey_color, fontWeight: FontWeight.bold);
    contentStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: themeData.textTheme.bodyText2.color);
    sectionHeadingStyle = TextStyle(color: AppColors.grey_color, fontWeight: FontWeight.bold, fontSize: 16);
  }

  bool onlyOnce = true;

  @override
  Widget build(BuildContext context) {
    isShowDoctorDetails = true;

    Constants_data.currentScreenContext = context;
    Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    print("Received Argument : ${args}");
    initStyles(context);

    if (args != null && args.containsKey("date") && onlyOnce) {
      date = args["date"];
      selectedDoctorfromArgs = args["doctor"];
      selectedDate = Constants_data.stringToDate(args["date"], "yyyy-MM-dd");
      date = Constants_data.dateToString(selectedDate, "dd-MM-yyyy");
      onlyOnce = false;
    }
    for (int i = 0; i < choices.length; i++) {
      if (choices[i]["accout_id"] == _selectedAccount) {
        selectedAccountName = choices[i]["name"];
        break;
      }
    }
    return Scaffold(
        appBar: AppBar(
            flexibleSpace: Constants_data.getFlexibleAppBar(themeChange.darkTheme),
            actions: [
              PopupMenuButton(
                onSelected: _select,
                padding: EdgeInsets.zero,
                // initialValue: choices[_selection],
                child: Row(
                  children: [
                    Container(
                        alignment: Alignment.center,
                        child: Text(
                          selectedAccountName,
                          style: TextStyle(color: AppColors.white_color, fontWeight: FontWeight.bold),
                        )),
                    Icon(
                      Icons.more_vert,
                      color: AppColors.white_color,
                    ),
                  ],
                ),
                itemBuilder: (BuildContext context) {
                  return choices.map((dynamic choice) {
                    return PopupMenuItem<dynamic>(
                      value: choice,
                      child: Text(choice["name"]),
                    );
                  }).toList();
                },
              )
            ],
            title: Text(
              "DCR Entry",
            )),
        body: !isLoaded
            ? FutureBuilder<dynamic>(
                future: getData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Container(
                      padding: EdgeInsets.all(10),
                      child: getView(),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              )
            : Container(
                padding: EdgeInsets.all(10),
                child: getView(),
              ));
  }

  Future<Null> getData() async {
    sampleData = [];
    promotionalItemsData = [];
    listPromotionalItems = [];
    cnt_pob.text = "";
    cnt_non_mcr_dr.text = "";
    cnt_jointWork.text = "";
    ckb_jointWork = false;
    ckb_sendToSuperior = false;
    _radioValue = 0;
    try {
      List<dynamic> sampledt = await DBProfessionalList.prformQueryOperation(
          "select distinct product_brand_code, product_brand_name from SampleProductDetails where product_category = 'S'", []);
      String sampleStr = jsonEncode(sampledt);
      productGroupData = jsonDecode(sampleStr);

      for (int i = 0; i < productGroupData.length; i++) {
        productGroupData[i]["selected"] = "false";
        productGroupData[i]["fromDD"] = "true";
        productGroupData[i]["DDValue"] = null;
        productGroupData[i]["txtValue"] = "";
      }

      doctorList = [];
      dropdownValueDoctorType = null;
      doctorList = await DBProfessionalList.prformQueryOperation(
          "select distinct CustomerId, CustomerName from ProfessionalList where AccountType = '${_selectedAccount}'", []);
      doctorList = doctorList.toSet().toList();

      List<dynamic> promotional = await DBProfessionalList.prformQueryOperation(
          "select distinct product_code, product_description from SampleProductDetails where product_category = 'G'", []);

      try {
        workType = await DBProfessionalList.prformQueryOperation("select work_type_code,work_type_desc from tblWorkTypeMst", []);
        workType = workType.toSet().toList();
        for (int i = 0; i < workType.length; i++) {
          if (workType[i]["work_type_desc"].toString().trim().toLowerCase() == "field work") {
            selectedWorkType = workType[i];
            strSelectedWorkType = selectedWorkType["work_type_desc"];
            break;
          }
        }
        print("tblWorkTypeMst : ${jsonEncode(workType)}");
      } catch (e) {
        workType = [];
        print("Error in getting data from tblWorkTypeMst : ${e.toString()}");
      }

      // try {
      //   route =
      //       await DBProfessionalList.prformQueryOperation("select * from RouteMst", []);
      //   route = route.toSet().toList();
      //   print("RouteMst : ${jsonEncode(route)}");
      // } catch (e) {
      //   route = [];
      //   print("Error in getting data from RouteMst : ${e.toString()}");
      // }

      String promotionalStr = jsonEncode(promotional);
      listPromotionalItems = jsonDecode(promotionalStr);
    } on Exception catch (err) {
      print("Err : ${err.toString()}");
    }

    print("PromotionalItems details : $listPromotionalItems");

    // try {
    //   String monthYear;
    //   if (Constants_data.appName == "Microlabs") {
    //     monthYear = "05-2020";
    //   } else {
    //     monthYear = Constants_data.dateToString(selectedDate, "MM-yyyy");
    //   }
    //
    //   String url = "/GetSavedMTPData_ForCalendar?RepId=${Constants_data.app_user["RepId"]}&monthYear=$monthYear";
    //   final dynamic response = await _helper.get(url);
    //   if (response["dt_ReturnedTables"] == null) {
    //     currentCalenderData = null;
    //   }
    //   List<dynamic> mainData = response["dt_ReturnedTables"][0];
    //   currentCalenderData = mainData[0];
    //   for (int i = 0; i < mainData.length; i++) {
    //     if (Constants_data.stringToDate(mainData[i]["date"].toString(), "dd-MM-yyyy") ==
    //         Constants_data.stringToDate(date.toString(), "dd-MM-yyyy")) {
    //       currentCalenderData = mainData[i];
    //     }
    //   }
    //   strSelectedWorkType = currentCalenderData["work_type_desc"];
    //   if (strSelectedWorkType != "") {
    //     for (int i = 0; i < workType.length; i++) {
    //       if (selectedDate.weekday != 7 && workType[i]["work_type_desc"] == "Sunday") {
    //         workType.removeAt(i);
    //       }
    //       if (workType[i]["work_type_desc"] == strSelectedWorkType) {
    //         selectedWorkType = workType[i];
    //       }
    //     }
    //   } else {
    //     selectedWorkType = null;
    //   }
    //   print("Selected WorkType : $strSelectedWorkType");
    // } on Exception catch (err) {
    //   print("Error in GetSavedMTPData_ForCalendar : ${err}");
    // }

    isLoaded = true;
  }

  Widget getView() {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            children: <Widget>[
              Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: themeChange.darkTheme ? 2 : 8,
                  child: getDateTimeRow()),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: themeChange.darkTheme ? 2 : 8,
                child: Column(
                  children: [
                    //getRouteRow(),
                    getWorkTypeRow(),
                    isShowDoctorDetails ? getDoctorType() : Container(),
                    // isShowDoctorDetails ? getPOB() : Container(),
                  ],
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: themeChange.darkTheme ? 2 : 8,
                child: Column(
                  children: [
                    getProductGroupDetails(),
                    getSampleDetails(),
                    getPromotionalDetails(),
                  ],
                ),
              )
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          //height: 40,
          child: MaterialButton(
            child: Text(
              "Save",
            ),
            onPressed: () {
              saveData();
            },
            color: AppColors.main_color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget getDateTimeRow() {
    return Row(
      children: <Widget>[
        Expanded(
            child: InkWell(
                onTap: () {
                  if (Platform.isIOS) {
                    selectDateiOS();
                  } else {
                    _selectDate();
                  }
                },
                child: Container(
                  margin: EdgeInsets.all(7),
                  child: Row(
                    children: <Widget>[
                      Container(
                          child: Text(
                        "Date : ",
                        style: sectionHeadingStyle,
                      )),
                      Container(child: Text("$date", style: contentStyle))
                    ],
                  ),
                ))),
        Expanded(
            child: InkWell(
                onTap: () {
                  if (Platform.isIOS) {
                    selectTimeiOS();
                  } else {
                    _selectTime();
                  }
                },
                child: Container(
                  margin: EdgeInsets.all(7),
                  child: Row(
                    children: <Widget>[
                      Container(
                          child: Text(
                        "Time : ",
                        style: sectionHeadingStyle,
                      )),
                      Container(child: Text("$time", style: contentStyle))
                    ],
                  ),
                ))),
        Container(
          width: 70,
          height: 30,
          margin: EdgeInsets.only(top: 7, bottom: 7, right: 5),
          child: MaterialButton(
            child: Text(
              "Show",
              style: TextStyle(color: AppColors.white_color, fontSize: 12),
            ),
            onPressed: () {
              Map<String, dynamic> _map = new HashMap();
              _map["date"] = Constants_data.dateToString(Constants_data.stringToDate(date, "dd-MM-yyyy"), "yyyy-MM-dd");
              _map["user"] = Constants_data.repId;
              Navigator.pushNamed(context, "/DCR_Entry_Details", arguments: _map);
            },
            color: AppColors.main_color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        )
      ],
    );
  }

  Widget getRouteRow() {
    return strSelectedWorkType == "Field Work"
        ? Container(
            margin: EdgeInsets.only(top: 5),
            child: Row(
              children: <Widget>[
                Expanded(
                    flex: 7,
                    child: Container(
                        margin: EdgeInsets.only(top: 7, left: 7),
                        child: Text(
                          "Route",
                          style: sectionHeadingStyle,
                        ))),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      " : ",
                      style: sectionHeadingStyle,
                    )),
                Expanded(
                    flex: 14,
                    child: DropdownButton<dynamic>(
                      hint: Text("Select Route"),
                      value: selectedRoute,
                      isExpanded: true,
                      style: contentStyle,
                      onChanged: (newValue) {
                        print("Selected Route : ${newValue}");
                        setState(() {
                          selectedRoute = newValue;
                          strSelectedRoute = selectedRoute["route_desc"];
                        });
                      },
                      items: route.map((dynamic val) {
                        return DropdownMenuItem<dynamic>(
                          value: val,
                          child: Text(
                            val["route_desc"],
                            style: contentStyle,
                          ),
                        );
                      }).toList(),
                    ))
                //Put DD here
                // Expanded(
                //   flex: 14,
                //   child: Container(child: Text("${currentCalenderData["route_desc"]}", style: contentStyle)),
                // )
              ],
            ),
          )
        : Container();
  }

  Widget getWorkTypeRow() {
    workType = workType.toSet().toList();
    for (int i = 0; i < workType.length; i++) {
      if (selectedWorkType != null && selectedWorkType["work_type_code"].toString() == workType[i]["work_type_code"].toString())
        selectedWorkType = workType[i];
    }
    return Container(
        margin: EdgeInsets.only(top: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                    flex: 7,
                    child: Container(
                      margin: EdgeInsets.only(top: 7, bottom: 7, left: 7, right: 0),
                      child: Text(
                        "Work Type",
                        style: sectionHeadingStyle,
                      ),
                    )),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      " : ",
                      style: sectionHeadingStyle,
                    )),
                workType.length > 0
                    ? Expanded(
                        flex: 14,
                        child: DropdownButton<dynamic>(
                          hint: Text("Select Work Type"),
                          value: selectedWorkType,
                          isExpanded: true,
                          style: contentStyle,
                          onChanged: (newValue) {
                            print("SelectedWorkType : ${newValue}");
                            setState(() {
                              selectedWorkType = newValue;
                              strSelectedWorkType = selectedWorkType["work_type_desc"];
                            });
                          },
                          items: workType.map((dynamic val) {
                            return DropdownMenuItem<dynamic>(
                              value: val,
                              child: Text(
                                val["work_type_desc"],
                                style: contentStyle,
                              ),
                            );
                          }).toList(),
                        ))
                    : Container(),
                workType.length == 0
                    ? Expanded(
                        flex: 14,
                        child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 0, vertical: 7),
                            child: Container(child: Text("$strSelectedWorkType", style: contentStyle))))
                    : Container()
              ],
            ),
            strSelectedWorkType == "Field Work" && isShowDoctorDetails
                ? Container(
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              Checkbox(
                                value: ckb_jointWork,
                                onChanged: (val) {
                                  this.setState(() {
                                    ckb_jointWork = val;
                                    if (!ckb_jointWork) {
                                      cnt_jointWork.text = "";
                                    }
                                  });
                                },
                              ),
                              Text(
                                "Joint Work",
                                style: contentStyle,
                              )
                            ],
                          ),
                        ),
                        Container(
                          child: Row(
                            children: <Widget>[
                              Checkbox(
                                value: ckb_sendToSuperior,
                                onChanged: (val) {
                                  this.setState(() {
                                    ckb_sendToSuperior = val;
                                  });
                                },
                              ),
                              Text(
                                "Send to Superior",
                                style: contentStyle,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(),
            ckb_jointWork && strSelectedWorkType == "Field Work"
                ? Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      controller: cnt_jointWork,
                      style: new TextStyle(color: AppColors.black_color, fontSize: 14),
                      decoration: new InputDecoration(hintText: "Work With", hintStyle: new TextStyle(color: AppColors.grey_color)),
                    ),
                  )
                : Container()
          ],
        ));
  }

  Widget getDoctorType() {
    if (strSelectedWorkType == "Field Work") {
      return Column(
        children: <Widget>[
          _selectedAccount != "Customer"
              ? Row(
                  children: <Widget>[
                    Expanded(
                        flex: 7,
                        child: Container(
                          margin: EdgeInsets.only(top: 7, bottom: 3, left: 7, right: 7),
                          child: Text(
                            "Doctor Type",
                            style: sectionHeadingStyle,
                          ),
                        )),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          " : ",
                          style: sectionHeadingStyle,
                        )),
                    Expanded(
                        flex: 14,
                        child: Container(
                          child: new Row(
                            children: <Widget>[
                              new Radio(
                                value: 0,
                                groupValue: _radioValue,
                                onChanged: _handleRadioValueChange,
                              ),
                              new Text(
                                "MCR",
                                style: contentStyle,
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              new Radio(
                                value: 1,
                                groupValue: _radioValue,
                                onChanged: _handleRadioValueChange,
                              ),
                              new Text(
                                "NON-MCR",
                                style: contentStyle,
                              ),
                            ],
                          ),
                        )),
                  ],
                )
              : SizedBox.shrink(),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: selectedDoctorfromArgs != null
                          ? Text("Account Name : ${selectedDoctorfromArgs["prof_name"]}")
                          : _radioValue == 0
                              ? DropdownButton<dynamic>(
                                  hint: Text("Select Account"),
                                  value: dropdownValueDoctorType,
                                  isExpanded: true,
                                  style: contentStyle,
                                  onChanged: (newValue) {
                                    print("SelectedAccount : ${newValue}");
                                    setState(() {
                                      dropdownValueDoctorType = newValue;
                                    });
                                  },
                                  items: doctorList.map((dynamic lang) {
                                    return DropdownMenuItem<dynamic>(
                                      value: lang,
                                      child: Text(
                                        lang["CustomerName"],
                                        style: contentStyle,
                                      ),
                                    );
                                  }).toList(),
                                )
                              : TextField(
                                  controller: cnt_non_mcr_dr,
                                  style: new TextStyle(fontSize: 14),
                                  decoration: new InputDecoration(hintText: "Doctor Name", hintStyle: new TextStyle(color: AppColors.grey_color)),
                                )),
                  selectedDoctorfromArgs != null ? Container() : Container()
//                    width: 75,
//                    margin: EdgeInsets.all(3),
//                    child: MaterialButton(
//                      child: Text(
//                        "More",
//                        style: TextStyle(color: AppColors.main_color),
//                      ),
//                      onPressed: () {},
//                    ),
//                  ),
                ],
              ))
        ],
      );
    } else {
      return SizedBox();
    }
  }

  Widget getPOB() {
    if (strSelectedWorkType == "Field Work") {
      return Container(
          margin: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
          child: Row(
            children: <Widget>[
              Expanded(
                  flex: 7,
                  child: Container(
                    child: Text(
                      "POB",
                      style: sectionHeadingStyle,
                    ),
                  )),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    " : ",
                    style: sectionHeadingStyle,
                  )),
              Expanded(
                  flex: 14,
                  child: TextField(
                    controller: cnt_pob,
                    style: contentStyle,
                    keyboardType: TextInputType.number,
                    decoration: new InputDecoration(
                      hintStyle: new TextStyle(color: AppColors.grey_color),
                    ),
                  ))
            ],
          ));
    } else {
      return SizedBox();
    }
  }

  Widget getProductGroupDetails() {
    if (strSelectedWorkType == "Field Work") {
      return Container(margin: EdgeInsets.symmetric(horizontal: 0), child: getProductGroupColumns());
    } else {
      return SizedBox();
    }
  }

  Widget getSampleDetails() {
    if (strSelectedWorkType == "Field Work") {
      return Container(margin: EdgeInsets.symmetric(horizontal: 0), child: getSampleProductColumns());
    } else {
      return SizedBox();
    }
  }

  Widget getPromotionalDetails() {
    if (strSelectedWorkType == "Field Work") {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 0),
        child: getPromotionalItemsColumns(),
      );
    } else {
      return SizedBox();
    }
  }

  Widget getProductGroupColumns() {
    List<Widget> listCols = [];

    for (int i = 0; i < productGroupData.length; i++) {
      if (productGroupData[i]["selected"] == "true") {
        TextEditingController cnt = new TextEditingController();
        cnt.text = productGroupData[i]["txtValue"];
        listCols.add(Stack(
          clipBehavior: Clip.none, children: <Widget>[
            Card(
              color: AppColors.light_blue_card_background,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                              flex: 5,
                              child: Container(
                                margin: EdgeInsets.all(5),
                                child: Text(
                                  "Brand:",
                                  style: lableStyle,
                                ),
                              )),
                          Expanded(
                              flex: 15,
                              child: Container(
                                margin: EdgeInsets.all(5),
                                child: Text(
                                  "${productGroupData[i]["product_brand_name"]}",
                                  style: contentStyle,
                                ),
                              ))
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                              flex: 5,
                              child: Container(
                                margin: EdgeInsets.all(5),
                                child: Text(
                                  "Remark:",
                                  style: lableStyle,
                                ),
                              )),
                          Expanded(
                              flex: 15,
                              child: Container(
                                margin: EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 5),
                                child: productGroupData[i]["fromDD"] == "true"
                                    ? DropdownButton<String>(
                                        hint: Text("Select remark"),
                                        value: productGroupData[i]["DDValue"],
                                        isExpanded: true,
                                        style: contentStyle,
                                        onChanged: (String newValue) {
                                          setState(() {
                                            this.setState(() {
                                              productGroupData[i]["DDValue"] = newValue;
                                            });
                                          });
                                        },
                                        items: <String>[
                                          'Less availability in area',
                                          'Some side effects',
                                          'Good Product',
                                          'Bad Product',
                                          'Effective Results'
                                        ].map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      )
                                    : TextField(
                                        controller: cnt,
                                        onChanged: (val) {
                                          productGroupData[i]["txtValue"] = val;
                                        },
                                        style: new TextStyle(
                                          color: AppColors.black_color,
                                        ),
                                        decoration: new InputDecoration(
                                            hintText: "Enter Other Remarks here", hintStyle: new TextStyle(color: AppColors.grey_color)),
                                      ),
                              )),
                          InkWell(
                              onTap: () {
                                this.setState(() {
                                  productGroupData[i]["fromDD"] = productGroupData[i]["fromDD"] == "true" ? "false" : "true";
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0), border: Border.all(width: 0.5, color: Color(0xFFFFAAAAAA))),
                                height: 30,
                                width: 30,
                                child: Center(
                                    child: Icon(
                                  Icons.edit,
                                  color: AppColors.main_color,
                                )),
                              ))
                        ],
                      )
                    ],
                  )),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: InkWell(
                  onTap: () {
                    this.setState(() {
                      productGroupData[i]["selected"] = "false";
                    });
                  },
                  child: Image.asset(
                    'assets/images/ic_delete.png',
                    width: 18,
                    height: 18,
                  )),
            )
          ],
        ));
      }
    }

    if (listCols.length == 0) {
      listCols.add(Container(
        margin: EdgeInsets.only(top: 10, bottom: 20),
        child: Text(
          "Item not available",
          style: lableStyle,
        ),
      ));
    }

    return new AppExpansionTile(
        key: gKey_productGroup,
        onExpansionChanged: (isExpanded) {
          if (isExpanded) {
            gKey_productPromotional.currentState.collapse();
            gKey_productSanmple.currentState.collapse();
          }
        },
        title: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                "Product Group Details",
                style: sectionHeadingStyle,
              ),
            ),
            IconButton(
              onPressed: () async {
                await showSampleProductList();
                this.setState(() {
                  gKey_productGroup.currentState.expand();
                });
              },
              color: AppColors.main_color,
              icon: Icon(
                Icons.add_circle,
                color: AppColors.main_color,
              ),
            )
          ],
        ),
        children: <Widget>[new Column(children: listCols)]);
  }

  Widget getSampleProductColumns() {
    List<Widget> listCols = [];

    for (int i = 0; i < sampleData.length; i++) {
      TextEditingController cnt_qty = new TextEditingController();
      cnt_qty.text = sampleData[i]["qty"] == null ? "" : sampleData[i]["qty"].toString();
      listCols.add(Stack(
        clipBehavior: Clip.none, children: <Widget>[
          Card(
            color: AppColors.light_blue_card_background,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                            flex: 5,
                            child: Container(
                              margin: EdgeInsets.all(5),
                              child: Text(
                                "Brand:",
                                style: lableStyle,
                              ),
                            )),
                        Expanded(
                            flex: 15,
                            child: Container(
                                margin: EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 5),
                                child: DropdownButton<dynamic>(
                                  hint: Text("Select Brand"),
                                  value: sampleData[i]["selectedBrand"],
                                  isExpanded: true,
                                  style: contentStyle,
                                  onChanged: (dynamic newValue) async {
                                    List<dynamic> listChild = await DBProfessionalList.prformQueryOperation(
                                        "select product_code, product_description from SampleProductDetails where product_brand_code = ?",
                                        [newValue["product_brand_code"]]);

                                    print("Selected product Brand : $listChild");
                                    setState(() {
                                      this.setState(() {
                                        listChild = listChild.toSet().toList();
                                        sampleData[i]["childProducts"] = listChild;
                                        sampleData[i]["selectedBrand"] = newValue;
                                      });
                                    });
                                  },
                                  items: productGroupData.map((dynamic lang) {
                                    return DropdownMenuItem<dynamic>(
                                      value: lang,
                                      child: Text(lang["product_brand_name"]),
                                    );
                                  }).toList(),
                                ))),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                            flex: 5,
                            child: Container(
                              margin: EdgeInsets.all(5),
                              child: Text(
                                "Product:",
                                style: lableStyle,
                              ),
                            )),
                        Expanded(
                            flex: 15,
                            child: Container(
                                margin: EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 5),
                                child: DropdownButton<dynamic>(
                                  hint: Text("Select Product"),
                                  value: sampleData[i]["selectedProduct"],
                                  isExpanded: true,
                                  style: contentStyle,
                                  onChanged: (dynamic newValue) {
                                    setState(() {
                                      this.setState(() {
                                        sampleData[i]["selectedProduct"] = newValue;
                                      });
                                    });
                                  },
                                  items: sampleData[i]["childProducts"] == null
                                      ? [].map((dynamic lang) {
                                          print("dt : $lang");
                                          return DropdownMenuItem<dynamic>(
                                            value: lang,
                                            child: Text(lang["product_description"]),
                                          );
                                        }).toList()
                                      : getList(sampleData[i]["childProducts"]).map((dynamic lang) {
                                          print("dt : $lang");
                                          return DropdownMenuItem<dynamic>(
                                            value: lang,
                                            child: Text(lang["product_description"]),
                                          );
                                        }).toList(),
                                ))),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                            flex: 5,
                            child: Container(
                              margin: EdgeInsets.all(5),
                              child: Text(
                                "Qty :",
                                style: lableStyle,
                              ),
                            )),
                        Expanded(
                            flex: 15,
                            child: Container(
                                margin: EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 5),
                                child: TextField(
                                  controller: cnt_qty,
                                  onChanged: (val) {
                                    sampleData[i]["qty"] = val;
                                  },
                                  style: new TextStyle(
                                    color: AppColors.black_color,
                                  ),
                                  keyboardType: TextInputType.number,
                                  decoration: new InputDecoration(hintText: "Add Quantity", hintStyle: new TextStyle(color: AppColors.grey_color)),
                                ))),
                      ],
                    )
                  ],
                )),
          ),
          Positioned(
            top: -0,
            right: -0,
            child: InkWell(
                onTap: () {
                  this.setState(() {
                    sampleData.removeAt(i);
                  });
                },
                child: Image.asset(
                  'assets/images/ic_delete.png',
                  width: 18,
                  height: 18,
                )),
          )
        ],
      ));
    }

    if (listCols.length == 0) {
      listCols.add(Container(
        margin: EdgeInsets.only(top: 10, bottom: 20),
        child: Text(
          "Item not available",
          style: lableStyle,
        ),
      ));
    }

    return new AppExpansionTile(
        key: gKey_productSanmple,
        onExpansionChanged: (isExpanded) {
          if (isExpanded) {
            gKey_productPromotional.currentState.collapse();
            gKey_productGroup.currentState.collapse();
          }
        },
        title: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                "Sample Details",
                style: sectionHeadingStyle,
              ),
            ),
            IconButton(
              onPressed: () async {
                gKey_productSanmple.currentState.expand();
                Map<String, dynamic> sample = new HashMap();
                sample["selectedBrand"] = null;
                sample["childProducts"] = null;
                sample["selectedProduct"] = null;
                sample["qty"] = "";
                int i = sampleData.length - 1;

                if (i != -1) {
                  if (sampleData[i]['selectedBrand'] != null && sampleData[i]['selectedProduct'] != null && sampleData[i]['qty'] != "") {
                    this.setState(() {
                      sampleData.add(sample);
                    });
                  } else {
                    Constants_data.toastError("Please fill existing sample details");
                  }
                } else {
                  this.setState(() {
                    sampleData.add(sample);
                  });
                }
              },
              color: AppColors.main_color,
              icon: Icon(
                Icons.add_circle,
                color: AppColors.main_color,
              ),
            )
          ],
        ),
        children: <Widget>[new Column(children: listCols)]);
  }

  Widget getPromotionalItemsColumns() {
    List<Widget> listCols = [];

    for (int i = 0; i < promotionalItemsData.length; i++) {
      TextEditingController cnt_qty = new TextEditingController();
      cnt_qty.text = promotionalItemsData[i]["qty"] == null ? "" : promotionalItemsData[i]["qty"].toString();
      listCols.add(Stack(
        clipBehavior: Clip.none, children: <Widget>[
          Card(
            color: AppColors.light_blue_card_background,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                            flex: 5,
                            child: Container(
                              margin: EdgeInsets.all(5),
                              child: Text(
                                "Item:",
                                style: lableStyle,
                              ),
                            )),
                        Expanded(
                            flex: 15,
                            child: Container(
                                margin: EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 5),
                                child: DropdownButton<dynamic>(
                                  hint: Text("Select Promotional Item"),
                                  value: promotionalItemsData[i]["selectedPromotion"],
                                  isExpanded: true,
                                  style: contentStyle,
                                  onChanged: (dynamic newValue) async {
                                    setState(() {
                                      this.setState(() {
                                        promotionalItemsData[i]["selectedPromotion"] = newValue;
                                      });
                                    });
                                  },
                                  items: listPromotionalItems.map((dynamic lang) {
                                    return DropdownMenuItem<dynamic>(
                                      value: lang,
                                      child: Text(lang["product_description"]),
                                    );
                                  }).toList(),
                                ))),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                            flex: 5,
                            child: Container(
                              margin: EdgeInsets.all(5),
                              child: Text(
                                "Qty :",
                                style: lableStyle,
                              ),
                            )),
                        Expanded(
                            flex: 15,
                            child: Container(
                                margin: EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 5),
                                child: TextField(
                                  controller: cnt_qty,
                                  onChanged: (val) {
                                    promotionalItemsData[i]["qty"] = val;
                                  },
                                  style: new TextStyle(
                                    color: AppColors.black_color,
                                  ),
                                  keyboardType: TextInputType.number,
                                  decoration: new InputDecoration(hintText: "Add Quantity", hintStyle: new TextStyle(color: AppColors.grey_color)),
                                ))),
                      ],
                    )
                  ],
                )),
          ),
          Positioned(
            top: -0,
            right: -0,
            child: InkWell(
                onTap: () {
                  this.setState(() {
                    promotionalItemsData.removeAt(i);
                  });
                },
                child: Image.asset(
                  'assets/images/ic_delete.png',
                  width: 18,
                  height: 18,
                )),
          )
        ],
      ));
    }

    if (listCols.length == 0) {
      listCols.add(Container(
        margin: EdgeInsets.only(top: 10, bottom: 20),
        child: Text(
          "Item not available",
          style: lableStyle,
        ),
      ));
    }

    return new AppExpansionTile(
        key: gKey_productPromotional,
        onExpansionChanged: (isExpanded) {
          if (isExpanded) {
            gKey_productGroup.currentState.collapse();
            gKey_productSanmple.currentState.collapse();
          }
        },
        title: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                "Promotional Items",
                style: sectionHeadingStyle,
              ),
            ),
            IconButton(
              onPressed: () async {
                gKey_productPromotional.currentState.expand();
                Map<String, dynamic> sample = new HashMap();
                sample["selectedPromotion"] = null;
                sample["qty"] = "";
                int index = promotionalItemsData.length - 1;

                if (index != -1) {
                  if (promotionalItemsData[index]["selectedPromotion"] != null && promotionalItemsData[index]["qty"] != "") {
                    this.setState(() {
                      promotionalItemsData.add(sample);
                    });
                  } else {
                    Constants_data.toastError("Please fill existing promotional item details");
                  }
                } else {
                  this.setState(() {
                    promotionalItemsData.add(sample);
                  });
                }
              },
              color: AppColors.main_color,
              icon: Icon(
                Icons.add_circle,
                color: AppColors.main_color,
              ),
            )
          ],
        ),
        children: <Widget>[new Column(children: listCols)]);
  }

  List<dynamic> getList(arr) {
    List<dynamic> test = arr;
    return test;
  }

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue = value;
    });
  }

  showSampleProductList() async {
    await showModalBottomSheet1(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter state) {
            return Container(
              height: 350,
              child: Column(
                children: <Widget>[
                  Container(
                      color: AppColors.main_color,
                      child: new Stack(
                        children: <Widget>[
                          new Positioned(
                            child: new Align(
                              child: Container(margin: EdgeInsets.only(top: 15), child: new Text("Select Product")),
                              alignment: Alignment.center,
                            ),
                          ),
                          new Positioned(
                              child: new Align(
                            child: MaterialButton(
                              onPressed: () {
                                //resetRequestData(jsonTemplate);
                                Navigator.pop(context);
                              },
                              child: new Text(
                                "Done",
                              ),
                            ),
                            alignment: Alignment.centerRight,
                          )),
                        ],
                      )),
                  Expanded(
                      child: ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () {
                            state(() {
                              productGroupData[index]["selected"] = productGroupData[index]["selected"] == "true" ? "false" : "true";
                            });
                          },
                          child: Container(
                            child: Row(
                              children: <Widget>[
                                Expanded(child: Container(height: 40, child: Text("${productGroupData[index]["product_brand_name"]}"))),
                                productGroupData[index]["selected"] == "true" ? Icon(Icons.check_box, color: AppColors.main_color) : Container()
                              ],
                            ),
                          ));
                    },
                    itemCount: productGroupData.length,
                  ))
                ],
              ),
            );
          });
        });
  }

  Future<Null> _selectDate() async {
    final DateTime picked = await showDatePicker(
        builder: (BuildContext context, Widget child) {
          return Constants_data.timeDatePickerTheme(child, themeChange.darkTheme, context);
        },
        context: context,
        initialDate: selectedDate,
        firstDate: Constants_data.appName == "Microlabs" ? new DateTime(2020, 1, 1) : DateTime(DateTime.now().year, DateTime.now().month - 1, 1),
        lastDate: Constants_data.appName == "Microlabs" ? new DateTime(2020, 12, 31) : DateTime(DateTime.now().year, DateTime.now().month + 1, 0));

    if (picked != null && picked != selectedDate)
      setState(() {
        var date = new DateFormat("dd-MM-yyyy").format(picked);
        selectedDate = picked;
        this.date = date;
        print("Picked date : ${date}");
        //isLoaded = false;
      });
  }

  Future<Null> _selectTime() async {
    TimeOfDay time = await showTimePicker(
      builder: (BuildContext context, Widget child) {
        return Constants_data.timeDatePickerTheme(child, themeChange.darkTheme, context);
      },
      initialTime: TimeOfDay.now(),
      context: context,
    );
    if (time != null && time != TimeOfDay.now()) {
      setState(() {
        final now = new DateTime.now();
        final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
        final format = DateFormat("hh:mm a"); //"6:00 AM"

        this.time = format.format(dt);
        print("Picked Time : ${time.format(context)}");
      });
    }
    //print("Time of the day : ${time.hour>12 ? time.hour-12 : time.hour}");
  }

  //static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  saveData() async {
    Map<String, dynamic> mainData = new HashMap();
    // String deviceId = await Constants_data.getDeviceId();

    // String imei = await ImeiPlugin.getImei();
    // List<String> multiImei =
    //     await ImeiPlugin.getImeiMulti(); //for double-triple SIM phones
    // String uuid = await ImeiPlugin.getId();
    //
    // // print("imei : $imei");
    // // print("multiImei : $multiImei");
    // print("uuid : $uuid");
    // print("DeviceId : $deviceId");

    String UUID = Constants_data.getUUID();

    if (strSelectedWorkType == "Field Work") {
      if (ckb_jointWork && cnt_jointWork.text.trim() == "") {
        Constants_data.toastError("Please enter work with.");
        return;
      } else if (_radioValue == 1 && cnt_non_mcr_dr.text.trim() == "") {
        Constants_data.toastError("Enter NON-MCR doctor name");
        return;
      } else if (dropdownValueDoctorType == null && selectedDoctorfromArgs == null && _radioValue == 0) {
        Constants_data.toastError("Please select doctor");
        return;
      }
      Map<String, dynamic> ObjectProfile = {
        "TransactionMethod": "UpdateData",
        "TransactionType": "",
        "TransactionID": "standard",
        "TransactionPageName": "OrderEntry",
        "SessionID": "",
        "UserID": "${Constants_data.app_user["RepId"]}",
        "HostName": "000000",
        "HostIP": "000000",
        "ViewSerialNo": 0,
        "MethodName": "",
        "MethodParameter": "",
        "TransactionLabel": "Save",
        "TransactionSubType": ""
      };

      List<dynamic> DCRDetailList = [];
      Map<String, dynamic> DCRDetail = new HashMap();
      DCRDetail["status"] = "O";
      DCRDetail["doc_no"] = "";
      DCRDetail["sr_no"] = "";
      DCRDetail["mcr_no"] = "";
      DCRDetail["Visit_type"] = _selectedAccount;

      DCRDetail["work_date"] = Constants_data.dateToString(Constants_data.stringToDate(date, "dd-MM-yyyy"), "yyyy-MM-dd") + " 00:00:00";
      DCRDetail["visit_time"] = time;
      DCRDetail["rout_actual"] = "";
      DCRDetail["rout_planned"] = "";
      DCRDetail["work_type"] = selectedWorkType["work_type_code"];
      DCRDetail["isJointWork"] = ckb_jointWork ? "Y" : "N";
      DCRDetail["sendTosuperior"] = ckb_sendToSuperior ? "Y" : "N";
      DCRDetail["work_with"] = cnt_jointWork.text;
      DCRDetail["dcs_type"] = _radioValue == 0 || _selectedAccount == "Customer" ? "MCR" : "NON-MCR";
      DCRDetail["mcr_dcs_code"] = _radioValue == 0
          ? selectedDoctorfromArgs != null
              ? selectedDoctorfromArgs["prof_code"]
              : dropdownValueDoctorType["CustomerId"]
          : "";
      DCRDetail["non_mcr_dcs_name"] = _radioValue == 0 ? "" : cnt_non_mcr_dr.text;
      DCRDetail["POB"] = cnt_pob.text == "" ? "0" : cnt_pob.text;
      DCRDetail["UniqueId"] = UUID;

      print("DCREntry123 : ${jsonEncode(DCRDetail)}");

      List<dynamic> brands = [];
      for (int i = 0; i < productGroupData.length; i++) {
        if (productGroupData[i]["selected"] == "true") {
          Map<String, String> mapBrand = new HashMap();
          mapBrand["OtherRemark"] = productGroupData[i]["txtValue"];
          mapBrand["product_brand"] = productGroupData[i]["product_brand_code"];
          mapBrand["Remark"] = productGroupData[i]["DDValue"] == null ? "" : productGroupData[i]["DDValue"];
          brands.add(mapBrand);
        }
      }
      print("Brands : ${brands}");
      DCRDetail["brands"] = brands;

      List<dynamic> items = [];
      for (int i = 0; i < sampleData.length; i++) {
        Map<String, String> mapItems = new HashMap();
        if (sampleData[i]["selectedProduct"] == null || sampleData[i]["qty"] == "") {
          print("*************** Selected Product null found : ${sampleData[i]}");
          Constants_data.toastError("Please fill the sample product details");
          return;
        }
        mapItems["item_type"] = "S";
        mapItems["item_code"] = sampleData[i]["selectedProduct"]["product_code"].toString();
        mapItems["qty"] = sampleData[i]["qty"] == null ? "" : sampleData[i]["qty"];
        items.add(mapItems);
      }

      for (int i = 0; i < promotionalItemsData.length; i++) {
        Map<String, String> mapItems = new HashMap();
        if (promotionalItemsData[i]["selectedPromotion"] == null || promotionalItemsData[i]["qty"] == "") {
          print("*************** Selected Promotion null found : ${promotionalItemsData[i]}");
          Constants_data.toastError("Please fill the Promotional Item details");
          return;
        }
        mapItems["item_type"] = "G";
        mapItems["item_code"] = promotionalItemsData[i]["selectedPromotion"]["product_code"].toString();
        mapItems["qty"] = promotionalItemsData[i]["qty"] == null ? "" : promotionalItemsData[i]["qty"];
        items.add(mapItems);
      }

      print("Sample data : ${items}");

      DCRDetail["items"] = items;
      DCRDetailList.add(DCRDetail);
      mainData["ObjectProfile"] = ObjectProfile;
      mainData["DCRDetail"] = DCRDetailList;
    } else {
      mainData = {
        "DCRDetail": [
          {
            "status": "O",
            "work_date": "${Constants_data.dateToString(Constants_data.stringToDate(date, "dd-MM-yyyy"), "yyyy-MM-dd") + " 00:00:00"}",
            "UniqueId": "${UUID}",
            "work_with": "",
            "dcs_type": "",
            "doc_no": "",
            "non_mcr_dcs_name": "",
            "isJointWork": "",
            "mcr_dcs_code": "",
            "mcr_no": "",
            "sendTosuperior": "",
            "POB": "0",
            "visit_time": "$time",
            "Visit_type": "Doctor",
            "work_type": "${selectedWorkType["work_type_code"]}",
            "rout_actual": "",
            "rout_planned": "",
            "sr_no": "",
            "items": [],
            "brands": []
          }
        ],
        "ObjectProfile": {
          "TransactionMethod": "UpdateData",
          "TransactionType": "",
          "TransactionID": "standard",
          "TransactionPageName": "OrderEntry",
          "SessionID": "",
          "UserID": "${Constants_data.app_user["RepId"]}",
          "HostName": "000000",
          "HostIP": "000000",
          "ViewSerialNo": 0,
          "MethodName": "",
          "MethodParameter": "",
          "TransactionLabel": "Save",
          "TransactionSubType": ""
        }
      };
    }

    var dataUser;
    if (Constants_data.app_user == null) {
      dataUser = await StateManager.getLoginUser();
    } else {
      dataUser = Constants_data.app_user;
    }
    print("Request Json Main : ${jsonEncode(mainData)}");
    bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
    if (isNetworkAvailable) {
      try {
        String url = "/SaveDCRDetail?RepId=${dataUser["Rep_Id"]}";
        var data = await _helper.post(url, mainData, true);
        if (data["Status"] == 1) {
          Constants_data.toastNormal(data["Message"]);
        } else if (data["Status"] == 5) {
          await openDialog(data["Message"].toString());
        } else {
          Constants_data.toastError(data["Message"]);
        }
      } on Exception catch (err) {
        print("Error in ");
      }
    } else {
      String doctorName = _radioValue == 0
          ? selectedDoctorfromArgs != null
              ? selectedDoctorfromArgs["prof_name"]
              : dropdownValueDoctorType["CustomerName"]
          : cnt_non_mcr_dr.text;
      await DBProfessionalList.prformQueryOperation(
          "INSERT INTO tblDCREntryTemp (id,data,doc_name) VALUES (?,?,?)", [UUID, jsonEncode(mainData).toString(), doctorName]);
      Constants_data.toastNormal("Data saved successfully");
      print("Network is not available");
    }
  }

  selectDateiOS() async {
    DateTime picked = selectedDate;
    await showModalBottomSheet1(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter state) {
            return Container(
              color: themeData.cardColor,
              height: 250,
              child: Column(
                children: <Widget>[
                  new Stack(
                    children: <Widget>[
                      new Positioned(
                        child: new Align(
                          child: Container(
                              margin: EdgeInsets.only(top: 15),
                              child: new Text(
                                "Select Date",
                              )),
                          alignment: Alignment.center,
                        ),
                      ),
                      new Positioned(
                          child: new Align(
                        child: MaterialButton(
                          onPressed: () {
                            if (picked != null && picked != selectedDate)
                              setState(() {
                                var date = new DateFormat("dd-MM-yyyy").format(picked);
                                selectedDate = picked;
                                this.date = date;
                                print("Picked date : ${date}");
                                //isLoaded = false;
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
                      child: CupertinoTheme(
                          data: CupertinoThemeData(
                            brightness: themeChange.darkTheme ? Brightness.dark : Brightness.light,
                          ),
                          child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.date,
                              initialDateTime: selectedDate,
                              onDateTimeChanged: (date) {
                                picked = date;
                                print("Selected Date  : ${date}");
                              })))
                ],
              ),
            );
          });
        });
  }

  selectTimeiOS() async {
    DateTime picked;
    await showModalBottomSheet1(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter state) {
            return Container(
              color: themeData.cardColor,
              height: 250,
              child: Column(
                children: <Widget>[
                  new Stack(
                    children: <Widget>[
                      new Positioned(
                        child: new Align(
                          child: Container(margin: EdgeInsets.only(top: 15), child: new Text("Select Date")),
                          alignment: Alignment.center,
                        ),
                      ),
                      new Positioned(
                          child: new Align(
                        child: MaterialButton(
                          onPressed: () {
                            if (picked == null) {
                              picked = DateTime.now();
                            }
                            setState(() {
                              this.time = Constants_data.dateToString(picked, "hh:mm a");
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
                      child: CupertinoTheme(
                          data: CupertinoThemeData(
                            brightness: themeChange.darkTheme ? Brightness.dark : Brightness.light,
                          ),
                          child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.time,
                              initialDateTime: new DateTime.now(),
                              onDateTimeChanged: (date) {
                                picked = date;
                                print("Selected time  : ${date}");
                              })))
                ],
              ),
            );
          });
        });
  }

  Future<bool> openDialog(msg) async {
    TextEditingController cnt_remarks = new TextEditingController();
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: AppColors.main_color,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 98.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.lock,
                        size: 30.0,
                        color: AppColors.white_color,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'DCR Entry Blocked',
                      style: TextStyle(color: AppColors.white_color, fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.all(15),
                child: Text("$msg"),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  controller: cnt_remarks,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: new InputDecoration(
                    alignLabelWithHint: true,
                    hintText: 'Remarks',
                    hintStyle: TextStyle(fontSize: 16),
                    labelText: "Remarks",
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: themeData.accentColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.all(15),
                    //fillColor: Color(0xFFEEEEEE),
                  ),
                  maxLines: 5,
                ),
              ),
              Container(
                  margin: EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context, 1);
                        },
                        child: Text(
                          "CANCEL",
                          style: TextStyle(color: AppColors.main_color, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SimpleDialogOption(
                        onPressed: () async {
                          bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
                          if (isNetworkAvailable) {
                            try {
                              String url = "/RequestForDCRUnlock?RepId=${Constants_data.app_user["Rep_Id"]}&Remark=${cnt_remarks.text}";
                              var data = await _helper.get(url);
                              if (data["Status"] == 1) {
                                Constants_data.toastNormal(data["Message"]);
                              } else {
                                Constants_data.toastError(data["Message"]);
                              }
                            } on Exception catch (err) {
                              print("Error in Unblocking request : ${err.toString()}");
                            }
                          } else {
                            Constants_data.toastError("Internet not available");
                          }
                          Navigator.pop(context, 0);
                        },
                        child: Text("SEND", style: TextStyle(color: AppColors.main_color, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ))
            ],
          );
        })) {
      case 0:
        return true;
        break;
      case 1:
        return false;
        break;
    }
    return false;
  }
}

const Duration _kExpand = const Duration(milliseconds: 200);

class AppExpansionTile extends StatefulWidget {
  const AppExpansionTile({
    Key key,
    this.leading,
    @required this.title,
    this.backgroundColor,
    this.onExpansionChanged,
    this.children: const <Widget>[],
    this.trailing,
    this.initiallyExpanded: false,
  })  : assert(initiallyExpanded != null),
        super(key: key);

  final Widget leading;
  final Widget title;
  final ValueChanged<bool> onExpansionChanged;
  final List<Widget> children;
  final Color backgroundColor;
  final Widget trailing;
  final bool initiallyExpanded;

  @override
  AppExpansionTileState createState() => new AppExpansionTileState();
}

class AppExpansionTileState extends State<AppExpansionTile> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  CurvedAnimation _easeOutAnimation;
  CurvedAnimation _easeInAnimation;
  ColorTween _borderColor;
  ColorTween _headerColor;
  ColorTween _iconColor;
  ColorTween _backgroundColor;
  Animation<double> _iconTurns;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(duration: _kExpand, vsync: this);
    _easeOutAnimation = new CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _easeInAnimation = new CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _borderColor = new ColorTween();
    _headerColor = new ColorTween();
    _iconColor = new ColorTween();
    _iconTurns = new Tween<double>(begin: 0.0, end: 0.5).animate(_easeInAnimation);
    _backgroundColor = new ColorTween();

    _isExpanded = PageStorage.of(context)?.readState(context) ?? widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void expand() {
    _setExpanded(true);
  }

  void collapse() {
    _setExpanded(false);
  }

  void toggle() {
    _setExpanded(!_isExpanded);
  }

  void _setExpanded(bool isExpanded) {
    if (_isExpanded != isExpanded) {
      setState(() {
        _isExpanded = isExpanded;
        if (_isExpanded)
          _controller.forward();
        else {
          _controller.reverse().then<void>((dynamic value) {
            setState(() {
              // Rebuild without widget.children.
            });
          });
        }
        PageStorage.of(context)?.writeState(context, _isExpanded);
      });
      if (widget.onExpansionChanged != null) {
        widget.onExpansionChanged(_isExpanded);
      }
    }
  }

  Widget _buildChildren(BuildContext context, Widget child) {
    final Color borderSideColor = _borderColor.evaluate(_easeOutAnimation) ?? Colors.transparent;
    final Color titleColor = _headerColor.evaluate(_easeInAnimation);

    return new Container(
      decoration: new BoxDecoration(
          color: _backgroundColor.evaluate(_easeOutAnimation) ?? Colors.transparent,
          border: new Border(
            top: new BorderSide(color: borderSideColor),
            bottom: new BorderSide(color: borderSideColor),
          )),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconTheme.merge(
            data: new IconThemeData(color: _iconColor.evaluate(_easeInAnimation)),
            child: new ListTile(
              onTap: toggle,
              leading: widget.leading,
              title: new DefaultTextStyle(
                style: Theme.of(context).textTheme.subtitle1.copyWith(color: titleColor),
                child: widget.title,
              ),
              trailing: widget.trailing ??
                  new RotationTransition(
                    turns: _iconTurns,
                    child: const Icon(
                      Icons.expand_more,
                      color: Colors.grey,
                    ),
                  ),
            ),
          ),
          new ClipRect(
            child: new Align(
              heightFactor: _easeInAnimation.value,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    _borderColor.end = theme.dividerColor;
    _headerColor
      ..begin = theme.textTheme.subtitle1.color
      ..end = theme.accentColor;
    _iconColor
      ..begin = theme.unselectedWidgetColor
      ..end = theme.accentColor;
    _backgroundColor.end = widget.backgroundColor;

    final bool closed = !_isExpanded && _controller.isDismissed;
    return new AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : new Column(children: widget.children),
    );
  }
}
