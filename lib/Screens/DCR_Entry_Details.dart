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

class DCR_Entry_Details extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<DCR_Entry_Details> {
  List<dynamic> mainData = [];
  var ObjRetArgs;
  TextStyle titleStyle = TextStyle(color: AppColors.main_color, fontSize: 14, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold);

  TextStyle normalText;
  List<dynamic> sampleDetails = [];
  List<dynamic> doctorList = [];
  List<dynamic> workType = [];
  List<dynamic> MtpDetails = [];
  ApiBaseHelper _helper = ApiBaseHelper();
  var currentData;

  //double totalWidth = MediaQuery.of(context).size.width;

  @override
  void initState() {
    super.initState();
  }

  bool isSubmitted = false;

  getSubmitStatus() {
    if (this.ObjRetArgs != null && this.ObjRetArgs.isEmpty) {
      isSubmitted = null;
      temp = "Blank";
    } else if (this.ObjRetArgs != null && this.ObjRetArgs["status"] != null && this.ObjRetArgs["status"] == "C") {
      isSubmitted = true;
      temp = "C";
    } else if (this.ObjRetArgs != null && this.ObjRetArgs["status"] != null && this.ObjRetArgs["status"] == "O") {
      isSubmitted = false;
      temp = "O";
    } else {
      temp = "nothing ${this.ObjRetArgs}";
      isSubmitted = false;
    }
  }

  bool isLoaded = false;
  bool isDateChanged = false;
  DarkThemeProvider themeChange;
  ThemeData themeData;
  String userId;

  @override
  Widget build(BuildContext context) {
    Constants_data.currentScreenContext = context;
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    normalText = TextStyle(color: themeData.primaryColorLight, fontSize: 14, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold);
    getSubmitStatus();
    if (!isDateChanged) {
      dynamic date = ModalRoute.of(context).settings.arguments;
      print("Date as args : ${date}");
      if (date != null) {
        finaldate = date["date"];
        userId = date["user"];
      }
    }
    return Scaffold(
        appBar: AppBar(
            flexibleSpace: Constants_data.getFlexibleAppBar(themeChange.darkTheme),
            title: Row(children: <Widget>[
              Text(finaldate.toString()),
            ]),
            actions: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      print("Tap Calander");
                      if (Platform.isIOS) {
                        selectDateiOS();
                      } else {
                        callDatePicker();
                      }
                    },
                    child: Icon(
                      Icons.calendar_today,
                      size: 26.0,
                    ),
                  )),
              MaterialButton(
                onPressed: () {
                  if (mainData != null && mainData.length > 0 && isSubmitted != null && !isSubmitted) {
                    submitData();
                  }
                },
//                icon: Icon(
//                  Icons.save,
//                  color: isSubmitted != null && !isSubmitted
//                      ? AppColors.white_color
//                      : AppColors.grey_color,
//                ),
                child: Text(
                  "Submit",
                  style: TextStyle(
                      color: mainData != null && mainData.length > 0 && isSubmitted != null && !isSubmitted
                          ? AppColors.white_color
                          : AppColors.grey_color),
                ),
              )
            ]),
        body: !isLoaded
            ? FutureBuilder<List<dynamic>>(
                future: getDemoResponse(finaldate),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return getView();
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
                })
            : getView());
  }

  String temp = "initial";
  Map<String, String> _route = new HashMap();

  Future<List<dynamic>> getDemoResponse(String date) async {
    String query = "SELECT * FROM RouteMst";
    var routeDetails = await DBProfessionalList.prformQueryOperation(query, []);
    print("Route Details Main: $routeDetails");

    for (int i = 0; i < routeDetails.length; i++) {
      _route["${routeDetails[i]["route_code"]}"] = "${routeDetails[i]["route_desc"]}";
    }
    print("Route Details Map: $_route");
    try {
      String url = '/GetDCRDetail?RepId=$userId&date=$date';
      final response = await _helper.get(url);
      var mainData = response["dt_ReturnedTables"];
      print("Main Data : $mainData");

      var ObjRetArgs = response["ObjRetArgs"];
      if (ObjRetArgs.toString() == "[]") {
        this.ObjRetArgs = [];
        this.mainData = [];
      } else {
        this.ObjRetArgs = ObjRetArgs[0];
        this.mainData = mainData[0];
      }
    } on Exception catch (err) {
      print("Error in GetDCRDetail : ${err}");
    }

    this.mainData.sort((a, b) {
      bool temp = (a['Visit_type'] == "Dr" || a['Visit_type'] == "Doctor") && (b['Visit_type'] == "Dr" || b['Visit_type'] == "Doctor");
      return !temp
          ? a['Visit_type'].toLowerCase().compareTo(b['Visit_type'].toLowerCase())
          : a['dcs_type'].toLowerCase().compareTo(b['dcs_type'].toLowerCase());
    });

    doctorList = await DBProfessionalList.prformQueryOperation(
        "select distinct CustomerId, CustomerName, AccountType from ProfessionalList where AccountType = 'HCP' or AccountType = 'Customer'", []);

    workType = await DBProfessionalList.prformQueryOperation("select work_type_code,work_type_desc from tblWorkTypeMst", []);

    sampleDetails = await DBProfessionalList.prformQueryOperation("select * from SampleProductDetails", []);

    this.setState(() {
      isLoaded = true;
    });

    return mainData;
  }

  getView() {
    return mainData != null && mainData.length > 0
        ? OrientationBuilder(builder: (context, orientation) {
            return Stack(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[
                      new Container(
                          margin: EdgeInsets.all(5),
                          child: Table(
                            columnWidths: {
                              1: FixedColumnWidth(65),
                              2: FixedColumnWidth(75),
                              3: FixedColumnWidth(40),
                            },
//                  border: TableBorder.all(),
                            children: [
                              TableRow(children: [
                                new Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(bottom: 5),
                                  child: new Text(
                                    'Visit Type',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                new Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(bottom: 5),
                                  child: new Text(
                                    'To Meet',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                new Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(bottom: 5),
                                  child: new Text(
                                    'POB',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                new Container(),
                              ]),
                              TableRow(children: [
                                Column(children: [
                                  new Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.only(top: 5, bottom: 5),
                                    child: new Text(
                                      "Chemist",
                                      //style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ]),
                                getTableRow(ObjRetArgs != null && ObjRetArgs != [] ? ObjRetArgs["no_chemist_meet"] : "0"),
                                getTableRow(ObjRetArgs != null && ObjRetArgs != [] ? ObjRetArgs["pob_chemist"] : "0"),
                                Column(children: [
                                  new Container(
                                    margin: EdgeInsets.all(5),
                                    width: 15.0,
                                    height: 15.0,
                                    decoration: new BoxDecoration(
                                      color: AppColors.visit_type_chemist,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                ]),
                              ]),
                              TableRow(children: [
                                Column(children: [
                                  new Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.only(top: 5, bottom: 5),
                                    child: new Text(
                                      'MCR Doctor',
                                      //style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ]),
                                getTableRow(ObjRetArgs != null && ObjRetArgs != [] ? ObjRetArgs["no_mcr_dr_meet"] : "0"),
                                getTableRow(ObjRetArgs != null && ObjRetArgs != [] ? ObjRetArgs["pob_mcr_dr"] : "0"),
                                Column(children: [
                                  new Container(
                                    margin: EdgeInsets.all(5),
                                    width: 15.0,
                                    height: 15.0,
                                    decoration: new BoxDecoration(
                                      color: AppColors.visit_type_doctor_mcr,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                ]),
                              ]),
                              TableRow(children: [
                                Column(children: [
                                  new Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.only(top: 5, bottom: 5),
                                    child: new Text(
                                      'Non-MCR Doctor',
                                      //style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ]),
                                getTableRow(ObjRetArgs != null && ObjRetArgs != [] ? ObjRetArgs["no_nonmcr_dr_meet"] : "0"),
                                getTableRow(ObjRetArgs != null && ObjRetArgs != [] ? ObjRetArgs["pob_nonmcr_dr"] : "0"),
                                Column(children: [
                                  new Container(
                                    margin: EdgeInsets.all(5),
                                    width: 15.0,
                                    height: 15.0,
                                    decoration: new BoxDecoration(
                                      color: AppColors.visit_type_doctor_non_mcr,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                ]),
                              ]),
                              TableRow(children: [
                                Column(children: [
                                  new Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.only(top: 5, bottom: 5),
                                    child: new Text(
                                      'Stockist',
                                      //style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ]),
                                getTableRow(ObjRetArgs != null && ObjRetArgs != [] ? ObjRetArgs["no_stockiest_meet"] : "0"),
                                getTableRow(ObjRetArgs != null && ObjRetArgs != [] ? ObjRetArgs["pob_stockiest"] : "0"),
                                Column(children: [
                                  new Container(
                                    margin: EdgeInsets.all(5),
                                    width: 15.0,
                                    height: 15.0,
                                    decoration: new BoxDecoration(
                                      color: AppColors.visit_type_stockiest,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                ]),
                              ]),
                            ],
                          )),
                      new Container(
                          height: MediaQuery.of(context).size.height - 255,
                          child: ListView(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            children: initListItems(MediaQuery.of(context).size.width * 0.9),
                          ))
                    ],
                  ),
                ),
                isSubmitted != null && isSubmitted
                    ? Positioned(
                        top: 35,
                        left: 100,
                        child: Container(
                          child: Image.asset(
                            "assets/images/stamps/submitted_stamp.png",
                            height: 100,
                            width: 100,
                          ),
                        ))
                    : SizedBox()
              ],
            );
          })
        : Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Image.asset(
                "assets/images/error_icon.png",
                height: Constants_data.getHeight(context, 150),
                width: Constants_data.getWidth(context, 150),
              ),
              SizedBox(
                height: Constants_data.getHeight(context, 10),
              ),
              Text(
                "Whoops!",
                style: TextStyle(
                  color: AppColors.black_color,
                  fontSize: Constants_data.getFontSize(context, 18),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: Constants_data.getHeight(context, 5),
              ),
              Text(
                "We couldn't find any DCR details for selected date",
                style: TextStyle(color: AppColors.grey_color, fontSize: Constants_data.getFontSize(context, 14)),
                textAlign: TextAlign.center,
              )
            ]),
          );
  }

  getTableRow(String text) {
    return Column(children: [
      new Container(
        margin: EdgeInsets.all(5),
        width: 60.0,
        height: 15.0,
        alignment: Alignment.center,
        child: new Text(text),
      )
    ]);
  }

  var finaldate;

  void callDatePicker() async {
    var order = await getDate();
    print("Order : ${order}");
    var formatter = new DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(order);

    setState(() {
      finaldate = formatted;
      isLoaded = false;
      isDateChanged = true;
    });
  }

  Future<DateTime> getDate() {
    return showDatePicker(
      builder: (BuildContext context, Widget child) {
        return Constants_data.timeDatePickerTheme(child, themeChange.darkTheme, context);
      },
      context: context,
      initialDate: finaldate != null ? Constants_data.stringToDate(finaldate, "yyyy-MM-dd") : DateTime.now(),
      firstDate: DateTime(2018),
      lastDate: DateTime.now(),
    );
  }

  selectDateiOS() async {
    DateTime picked = finaldate != null ? Constants_data.stringToDate(finaldate, "yyyy-MM-dd") : DateTime.now();
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
                              margin: EdgeInsets.only(top: 15), child: new Text("Select Date", style: TextStyle(color: AppColors.black_color))),
                          alignment: Alignment.center,
                        ),
                      ),
                      new Positioned(
                          child: new Align(
                        child: MaterialButton(
                          onPressed: () {
                            setState(() {
                              finaldate = Constants_data.dateToString(picked, "yyyy-MM-dd");
                              isLoaded = false;
                              isDateChanged = true;
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
                          initialDateTime: picked,
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

  getColor(int index, bool isMCR) {
    if (mainData[index]["Visit_type"] == "Customer") {
      return AppColors.visit_type_chemist;
    } else if (mainData[index]["Visit_type"] == "Stockiest") {
      return AppColors.visit_type_stockiest;
    } else if (mainData[index]["Visit_type"] == "HCP" || mainData[index]["Visit_type"] == "Doctor" || mainData[index]["Visit_type"] == "Dr") {
      if (isMCR) {
        return AppColors.visit_type_doctor_mcr;
      } else {
        return AppColors.visit_type_doctor_non_mcr;
      }
    }
  }

  initListItems(double width) {
    List<Widget> listItems = [];
    for (int i = 0; i < mainData.length; i++) {
      bool isMCR = mainData[i]["dcs_type"] == "MCR";

      List<dynamic> listProductItems = mainData[i]["items"] != "" ? mainData[i]["items"] : [];
      List<dynamic> sampleDetails = [];
      List<dynamic> promotionalItem = [];

      for (int j = 0; j < listProductItems.length; j++) {
        if (listProductItems[j]["item_type"] == "S") {
          sampleDetails.add(listProductItems[j]);
        } else if (listProductItems[j]["item_type"] == "G") {
          promotionalItem.add(listProductItems[j]);
        }
      }

      print("----- Main Data ($i) : ${mainData[i]}");

      listItems.add(Card(
        child: new GestureDetector(
          onTap: () async {
            showItemDetails(isMCR, promotionalItem, width, i, sampleDetails, mainData);
          },
          child: new Card(
            elevation: 2,
            color: getColor(i, isMCR),
            margin: EdgeInsets.zero,
            child: new Container(
                color: getColor(i, isMCR),
                padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 5),
                child: new Row(
                  children: <Widget>[
                    Expanded(
                      flex: 6,
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            "Account Name",
                            style: TextStyle(fontSize: 11, color: AppColors.grey_color),
                          ),
                          new Text(isMCR
                              ? getDoctorName(mainData[i]["mcr_dcs_code"], mainData[i]["Visit_type"]) == null
                                  ? "N/A"
                                  : getDoctorName(mainData[i]["mcr_dcs_code"], mainData[i]["Visit_type"])
                              : mainData[i]["non_mcr_dcs_name"])
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 2,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Text(
                              "Visit Type",
                              style: TextStyle(fontSize: 11, color: AppColors.grey_color),
                            ),
                            new Text("${mainData[i]["Visit_type"] == "HCP" ? "Doctor" : "Pharmacy"}")
                          ],
                        )),
                    Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Text(
                              "Visit Time",
                              style: TextStyle(fontSize: 11, color: AppColors.grey_color),
                            ),
                            new Text(mainData[i]["visit_time"])
                          ],
                        ))
                  ],
                )),
          ),
        ),
      ));
    }
    return listItems;
  }

  getProductDetails(int index, List<dynamic> brands, group) {
    List<TableRow> rows = [];
    rows.add(new TableRow(children: [
      new Container(
          padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),
          color: AppColors.grey_color,
          child: new Text(
            "Product Name",
            style: normalText,
          )),
      new Container(
          padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),
          color: AppColors.grey_color,
          child: new Text(
            "Remarks",
            style: normalText,
          )),
    ]));

    for (int i = 0; i < brands.length; i++) {
      String product = getProduct(brands[i]["product_brand"], "S");
      rows.add(new TableRow(children: [
        new Container(
          padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),
          child: new Text(
            product == "" ? "N/A" : product,
            style: normalText,
          ),
        ),
        new Container(
            padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),
            child: new Text(
              brands[i]["Remark"] == "" ? brands[i]["OtherRemark"] : brands[i]["Remark"],
              style: normalText,
            ))
      ]));
    }
    return rows;
  }

  getItemDetails(List<dynamic> sampleDetails) {
    List<TableRow> rows = [];
    rows.add(new TableRow(children: [
      new Container(
          padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),
          color: AppColors.grey_color,
          child: new Text(
            "Product Name",
            style: normalText,
          )),
      new Container(
          padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),
          color: AppColors.grey_color,
          child: new Text(
            "Qty",
            style: normalText,
          )),
    ]));

    for (int i = 0; i < sampleDetails.length; i++) {
      String product = getProduct(sampleDetails[i]["item_code"], "G");
      rows.add(new TableRow(children: [
        new Container(
          padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),
          child: new Text(
            product == "" ? "N/A" : product,
            style: normalText,
          ),
        ),
        new Container(
            padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),
            child: new Text(
              sampleDetails[i]["qty"] == "" ? "N/A" : sampleDetails[i]["qty"],
              style: normalText,
            ))
      ]));
    }
    return rows;
  }

  getDoctorName(String docId, visitType) {
    //CustomerId, CustomerName
    for (int i = 0; i < doctorList.length; i++) {
      if (doctorList[i]["CustomerId"] == docId && doctorList[i]["AccountType"] == visitType) {
        return doctorList[i]["CustomerName"];
      }
    }
  }

  getWorkTypeName(String workTypeId) {
    //CustomerId, CustomerName
    for (int i = 0; i < workType.length; i++) {
      if (workType[i]["work_type_code"] == workTypeId) {
        return workType[i]["work_type_desc"];
      }
    }
    return workTypeId;
  }

  getProduct(id, key) {
    String product = "";
    for (int index = 0; index < sampleDetails.length; index++) {
      if (sampleDetails[index]["product_brand_code"] == id || sampleDetails[index]["product_code"] == id) {
        product = key == "S" ? sampleDetails[index]["product_brand_name"] : sampleDetails[index]["product_description"];
      }
    }
    return product;
  }

//  submitData() async{
//
//    String uuid = Constants_data.getUUID();
//    print("UUID : $uuid");
//
//    Map<String,dynamic> mainMap = new HashMap();
//
//
//    Map<String,dynamic> ObjectProfile = new HashMap();
//    ObjectProfile["TransactionType"] = "";
//    ObjectProfile["ViewSerialNo"] = 0;
//    ObjectProfile["TransactionSubType"] = "";
//    ObjectProfile["TransactionMethod"] = "UpdateData";
//    ObjectProfile["TransactionID"] = "standard";
//    ObjectProfile["TransactionLabel"] = "Save";
//    ObjectProfile["TransactionPageName"] = "OrderEntry";
//    ObjectProfile["UserID"] = "sandip";
//    ObjectProfile["MethodName"] = "";
//    ObjectProfile["MethodParameter"] = "";
//    ObjectProfile["SessionID"] = "81b407be11574d37ab9969005ddb1c2f";
//
//    List<dynamic> dcrDetailsList = [];
//
//    for(int i=0;i<mainData.length;i++){
//      Map<String,dynamic> dcrEntry = new HashMap();
//      dcrEntry = mainData[i];
////      dcrEntry["UniqueId"] = mainData[i]["UniqueId"];
////      dcrEntry["POB"] = mainData[i]["POB"];
////      dcrEntry["brands"] = mainData[i]["brands"];
////      dcrEntry["work_date"] = mainData[i]["work_date"];
////      dcrEntry["visit_time"] = mainData[i]["visit_time"];
////      dcrEntry["doc_no"] = mainData[i]["doc_no"];
////      dcrEntry["sr_no"] = mainData[i]["sr_no"];
////      dcrEntry["work_type"] = mainData[i]["work_type"];
////      dcrEntry["dcs_type"] = mainData[i]["dcs_type"];
////      dcrEntry["mcr_dcs_code"] = mainData[i]["mcr_dcs_code"];
////      dcrEntry["mcr_no"] = mainData[i]["mcr_no"];
////      dcrEntry["rout_actual"] = mainData[i]["rout_actual"];
////      dcrEntry["sendToSuperior"] = mainData[i]["sendToSuperior"];
////      dcrEntry["isJointWork"] = mainData[i]["isJointWork"];
////      dcrEntry["work_with"] = mainData[i]["work_with"];
////      dcrEntry["rout_planned"] = mainData[i]["rout_planned"];
////      dcrEntry["Visit_type"] = mainData[i]["Visit_type"];
////      dcrEntry["items"] = mainData[i]["items"];
//      dcrEntry["status"] = "C";
////      dcrEntry["non_mcr_dcs_name"] = mainData[i]["non_mcr_dcs_name"];
//      dcrDetailsList.add(dcrEntry);
//
//    }
//
//    mainMap["ObjectProfile"] = ObjectProfile;
//    mainMap["DCRDetail"] = dcrDetailsList;
//
//
//    String data = jsonEncode(mainMap);
//    print("MainMap : ${data}");
//
//    String json_temp = "${jsonEncode(mainData).toString()}";
//    json_temp = json_temp.replaceAll("\"", "\\\"");
//    json_temp = "\"${json_temp}\"";
//
//    print("Main data final : $json_temp");
//
//    var dataUser = await StateManager.getLoginUser();
//
//    bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
//    if (isNetworkAvailable) {
//      Map<String, String> headers = {"Content-type": "application/json"};
//
//      var response = await http.post(
//          "${ConstUrls.baseUrl}SaveDCRDetail?RepId=${dataUser["Rep_Id"]}",
//          headers: headers,
//          body: json_temp);
//
//      var data = jsonDecode(response.body);
//      if (data["Status"] == 1) {
//        Constants_data.toastNormal(data["Message"]);
//      } else {
//        Constants_data.toastError(data["Message"]);
//      }
//
//      print("Response Success : ${data}");
//    } else {
//      await DBProfessionalList.prformQueryOperation("INSERT INTO tblDCREntryTemp (id,data) VALUES (?,?)", [UUID,json_temp]);
//      Constants_data.toastNormal("Data saved successfully");
//      print("Network is not available");
//    }
//
//  }

  Future<bool> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.only(top: 15, bottom: 10, right: 15, left: 15),
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Text(
                  "Are you Sure? ",
                  style: TextStyle(color: AppColors.black_color, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                child: Text(
                    "You want to submit DCR for $finaldate. Please save all DCR of this date before submit because, After submmited you can't save any DCR for this date"),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
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
                    onPressed: () {
                      Navigator.pop(context, 0);
                    },
                    child: Text("SUBMIT", style: TextStyle(color: AppColors.main_color, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
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

  submitData() async {
    bool result = await openDialog();
    print("Result : $result");
    if (result) {
      String uuid = Constants_data.getUUID();
      var data = {
        "ObjectProfile": {
          "TransactionType": "",
          "ViewSerialNo": 0,
          "TransactionSubType": "",
          "TransactionMethod": "UpdateData",
          "TransactionID": "standard",
          "TransactionLabel": "Save",
          "TransactionPageName": "OrderEntry",
          "UserID": "sandip",
          "MethodName": "",
          "MethodParameter": "",
          "SessionID": "81b407be11574d37ab9969005ddb1c2f"
        },
        "DCRDetail": [
          {
            "UniqueId": "$uuid",
            "POB": "",
            "brands": [],
            "work_date": "$finaldate 00:00:00",
            "visit_time": "",
            "doc_no": "",
            "sr_no": "",
            "work_type": "",
            "dcs_type": "",
            "mcr_dcs_code": "",
            "mcr_no": "",
            "rout_actual": "",
            "sendToSuperior": "",
            "isJointWork": "",
            "work_with": "",
            "rout_planned": "",
            "Visit_type": "",
            "items": [],
            "status": "C",
            "non_mcr_dcs_name": ""
          }
        ]
      };

      var dataUser;
      if (Constants_data.app_user == null) {
        dataUser = await StateManager.getLoginUser();
      } else {
        dataUser = Constants_data.app_user;
      }

      print("Main Data : ${jsonEncode(data)}");

      String json_temp = "${jsonEncode(data).toString()}";
      json_temp = json_temp.replaceAll("\"", "\\\"");
      json_temp = "\"${json_temp}\"";

      print("Main data final : $json_temp");

      bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
      if (isNetworkAvailable) {
        try {
          String url = "/SaveDCRDetail?RepId=${dataUser["Rep_Id"]}";
          var dt = await _helper.post(url, data, true);
          if (dt["Status"] == 1) {
            Constants_data.toastNormal(dt["Message"]);
            this.setState(() {
              isLoaded = false;
            });
          } else {
            Constants_data.toastError(dt["Message"]);
          }
        } on Exception catch (err) {
          print("Error in SaveDCRDetail : $err");
        }
      } else {
        await DBProfessionalList.prformQueryOperation("INSERT INTO tblDCREntryTemp (id,data) VALUES (?,?)", [uuid, json_temp]);
        Constants_data.toastNormal("Data saved successfully");
        print("Network is not available");
      }
    }
  }

  void showItemDetails(isMCR, promotionalItem, width, i, sampleDetails, mainData) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(0.01),
      barrierDismissible: false,
      barrierLabel: "Dialog",
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        // your widget implementation
        return Material(
            color: Colors.black12.withOpacity(0.5),
            child: Center(
              child: Container(
                  decoration: new BoxDecoration(
                      color: themeData.cardColor,
                      borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(10.0),
                        topRight: const Radius.circular(10.0),
                        bottomLeft: const Radius.circular(10.0),
                        bottomRight: const Radius.circular(10.0),
                      )),
                  height: MediaQuery.of(context).size.height * 0.9,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        new Stack(
                          children: <Widget>[
                            new Container(
                              decoration: new BoxDecoration(
                                  color: AppColors.light_grey_color,
                                  borderRadius: new BorderRadius.only(
                                    topLeft: const Radius.circular(10.0),
                                    topRight: const Radius.circular(10.0),
                                  )),
                              height: 40,
                              width: MediaQuery.of(context).size.width * 0.9,
                              padding: EdgeInsets.only(left: 15),
                              child: new Align(
                                alignment: Alignment.centerLeft,
                                child: new Text(
                                  isMCR
                                      ? getDoctorName(mainData[i]["mcr_dcs_code"], mainData[i]["Visit_type"]) == null
                                          ? "N/A"
                                          : getDoctorName(mainData[i]["mcr_dcs_code"], mainData[i]["Visit_type"])
                                      : mainData[i]["non_mcr_dcs_name"],
                                  style:
                                      TextStyle(fontSize: 16, color: AppColors.black_color, fontWeight: FontWeight.bold, fontStyle: FontStyle.normal),
                                ),
                              ),
                            ),
                            new Container(
                              height: 40,
                              padding: EdgeInsets.only(right: 5),
                              child: new Align(
                                alignment: Alignment.centerRight,
                                child: new MaterialButton(
                                  child: new Text("Close", style: TextStyle(fontSize: 14, color: AppColors.main_color, fontStyle: FontStyle.normal)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                        new Container(
                            margin: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
                            child: new Row(
                              children: <Widget>[
                                new Container(
                                  width: (width - 20) / 2,
                                  child: new Row(
                                    children: <Widget>[
                                      new Text(
                                        "Date: ",
                                        style: titleStyle,
                                      ),
                                      new Text(
                                        mainData[i]["work_date"],
                                        style: normalText,
                                      ),
                                    ],
                                  ),
                                ),
                                new Container(
                                  width: (width - 20) / 2,
                                  child: new Row(
                                    children: <Widget>[
                                      new Text(
                                        "Time: ",
                                        style: titleStyle,
                                      ),
                                      new Text(
                                        mainData[i]["visit_time"],
                                        style: normalText,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )),
                        new Container(
                            margin: EdgeInsets.all(10),
                            child: new Row(
                              children: <Widget>[
                                new Container(
                                  width: (width - 20) / 1,
                                  child: new Row(
                                    children: <Widget>[
                                      new Text(
                                        "Route: ",
                                        style: titleStyle,
                                      ),
                                      new Text(
                                        "${_route[mainData[i]["rout_actual"]]}",
                                        style: normalText,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                        Container(
                            margin: EdgeInsets.all(10),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: (width - 20) / 1,
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        "Work With: ",
                                        style: titleStyle,
                                      ),
                                      Text(
                                        mainData[i]["work_with"] == "" ? "N/A" : mainData[i]["work_with"],
                                        style: normalText,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                        Container(
                            margin: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Container(
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        "Work Type",
                                        style: titleStyle,
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 5),
                                        child: Text(
                                          getWorkTypeName(mainData[i]["work_type"]),
                                          style: normalText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        "Doctor Type",
                                        style: titleStyle,
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 5),
                                        child: Text(
                                          mainData[i]["dcs_type"] == "" ? "N/A" : mainData[i]["dcs_type"],
                                          style: normalText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                new Container(
                                  child: Align(
                                    child: new Column(
                                      children: <Widget>[
                                        new Text(
                                          "POB",
                                          style: titleStyle,
                                        ),
                                        new Container(
                                          margin: EdgeInsets.only(top: 5),
                                          child: new Text(
                                            mainData[i]["POB"],
                                            style: normalText,
                                          ),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                  ),
                                )
                              ],
                            )),
                        mainData[i]["brands"] != "" && mainData[i]["brands"].length > 0
                            ? new Container(
                                margin: EdgeInsets.only(top: 15, right: 10, left: 10, bottom: 10),
                                child: new Row(
                                  children: <Widget>[
                                    new Container(
                                      width: (width - 20) / 1,
                                      child: new Row(
                                        children: <Widget>[
                                          new Text(
                                            "Product Group Details: ",
                                            style: TextStyle(
                                                color: AppColors.main_color, fontSize: 16, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ))
                            : new Container(),
                        mainData[i]["brands"] != "" && mainData[i]["brands"].length > 0
                            ? new Container(
                                margin: EdgeInsets.only(top: 0, right: 10, left: 10, bottom: 10),
                                child: Table(
                                    border: new TableBorder(
                                        right: BorderSide(color: AppColors.light_grey_color, width: 0.5),
                                        left: BorderSide(color: AppColors.light_grey_color, width: 0.5),
                                        bottom: BorderSide(color: AppColors.light_grey_color, width: 0.5),
                                        horizontalInside: BorderSide(color: AppColors.light_grey_color, width: 0.5),
                                        verticalInside: BorderSide(color: AppColors.light_grey_color, width: 0.5)),
                                    columnWidths: {
                                      0: FixedColumnWidth(150),
                                    },
                                    children: getProductDetails(i, mainData[i]["brands"], "S")))
                            : new Container(),
                        sampleDetails.length > 0
                            ? new Container(
                                margin: EdgeInsets.only(top: 15, right: 10, left: 10, bottom: 10),
                                child: new Row(
                                  children: <Widget>[
                                    new Container(
                                      width: (width - 20) / 1,
                                      child: new Row(
                                        children: <Widget>[
                                          new Text(
                                            "Sample Details: ",
                                            style: TextStyle(
                                                color: AppColors.main_color, fontSize: 16, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ))
                            : new Container(),
                        sampleDetails.length > 0
                            ? new Container(
                                margin: EdgeInsets.only(top: 0, right: 10, left: 10, bottom: 10),
                                child: Table(
                                    border: new TableBorder(
                                        right: BorderSide(color: AppColors.light_grey_color, width: 0.5),
                                        left: BorderSide(color: AppColors.light_grey_color, width: 0.5),
                                        bottom: BorderSide(color: AppColors.light_grey_color, width: 0.5),
                                        horizontalInside: BorderSide(color: AppColors.light_grey_color, width: 0.5),
                                        verticalInside: BorderSide(color: AppColors.light_grey_color, width: 0.5)),
                                    columnWidths: {
                                      1: FixedColumnWidth(80),
                                    },
                                    children: getItemDetails(sampleDetails)))
                            : new Container(),
                        promotionalItem.length > 0
                            ? new Container(
                                margin: EdgeInsets.only(top: 15, right: 10, left: 10, bottom: 10),
                                child: new Row(
                                  children: <Widget>[
                                    new Container(
                                      width: (width - 20) / 1,
                                      child: new Row(
                                        children: <Widget>[
                                          new Text(
                                            "Promotional Items: ",
                                            style: TextStyle(
                                                color: AppColors.main_color, fontSize: 16, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ))
                            : new Container(),
                        promotionalItem.length > 0
                            ? new Container(
                                margin: EdgeInsets.only(top: 0, right: 10, left: 10, bottom: 10),
                                child: Table(
                                    border: new TableBorder(
                                        right: BorderSide(color: AppColors.light_grey_color, width: 0.5),
                                        left: BorderSide(color: AppColors.light_grey_color, width: 0.5),
                                        bottom: BorderSide(color: AppColors.light_grey_color, width: 0.5),
                                        horizontalInside: BorderSide(color: AppColors.light_grey_color, width: 0.5),
                                        verticalInside: BorderSide(color: AppColors.light_grey_color, width: 0.5)),
                                    columnWidths: {
                                      1: FixedColumnWidth(80),
                                    },
                                    children: getItemDetails(promotionalItem)))
                            : new Container(),
                      ],
                    ),
                  )),
            ));
      },
    );
  }
}
