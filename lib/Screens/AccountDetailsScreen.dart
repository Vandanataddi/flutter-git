import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Constants/StateManager.dart';
import 'package:flexi_profiler/Constants/bottom_sheet.dart';
import 'package:flexi_profiler/Constants/const.dart';
import 'package:flexi_profiler/Constants/custom_context_menu.dart';
import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
import 'package:flexi_profiler/DBClasses/DBProfessionalList.dart';
import 'package:flexi_profiler/Services/CallEmailWebService.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flexi_profiler/Theme/StyleClass.dart';
import 'package:flexi_profiler/Widget/BarChartWidget.dart';
import 'package:flexi_profiler/Widget/DropDownWidget.dart';
import 'package:flexi_profiler/Widget/LineChartWidget.dart';
import 'package:flexi_profiler/Widget/MultiColumnWidget.dart';
import 'package:flexi_profiler/Widget/PieChartWidget.dart';
import 'package:flexi_profiler/Widget/RadialChartWidget.dart';
import 'package:flexi_profiler/Widget/TableWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../ChatConnectyCube/pref_util.dart';
import '../Widget/TableWidget1.dart';
import '../Widget/TableWidget2.dart';
import 'InvoiceUploadScreen.dart';
import 'Login.dart';
import 'ReportsScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class AccountDetailsScreen extends StatefulWidget {
  @override
  _AccountDetailsScreen createState() => _AccountDetailsScreen();
}

List<dynamic> jsonStringData = new List<dynamic>();
Map<String, String> listCategoryCode = new HashMap();
var dataUser;

class _AccountDetailsScreen extends State<AccountDetailsScreen>
    with SingleTickerProviderStateMixin, CustomPopupMenu {
  bool _isDropdownVisible = false;

  List<TextEditingController> quantityControllers = [];
  List<TextEditingController> fgoValueControllers = [];
  List<TextEditingController> invoiceValueControllers = [];

  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  // List<dynamic> _filteredProductGroupData = [];

  bool _isImageVisible = false;
  String _buttonLabel = 'Upload';
  //File _selectedFile;
  PlatformFile _selectedFile;
  List<Map<String, dynamic>> productDetails = [];
  Map<String, dynamic> currentProduct = {};
  TabController _tabController;
  var pos;

  final currancy_format = new NumberFormat("#,##,##,##,###.##", "en_IN");
  final currancy_symbol = "TSh ";

  List<dynamic> productGroupData = [];
  List<dynamic> productData = [];
  bool isLoaded = false;
  bool loadingForApproval = false;
  bool loadingForReject = false;
  bool loadingForsendmail = false;
  ApiBaseHelper _helper = ApiBaseHelper();
  Map<String, dynamic> customerData;
  bool isLoading = false;
  List<TextEditingController> listController;
  dynamic selectedCustomer;
  List<dynamic> listCustomers;
  TextEditingController cntRemarks = new TextEditingController();
  DarkThemeProvider themeChange;
  ThemeData themeData;
  String divisionCode;
  String selectedDivision;
  List<Map<String, dynamic>> divisions = [];
  List<dynamic> configDetails = [];
  List<dynamic> keys;
  var fgotype;
  List<Map<String, dynamic>> tables = [];
  // themeChange = Provider.of<DarkThemeProvider>(context);
  // themeData = Theme.of(context);

  @override
  // void initState() {
  //   super.initState();
  //   Constants_data.categoryList;
  //   getMenu();
  //   initUser();
  //   _tabController =
  //       TabController(vsync: this, length: Constants_data.categoryList.length);
  //   //quantityController.addListener(_onQuantityChanged);
  //   quantityControllers = List.generate(productDetails.length, (index) => TextEditingController());
  //   invoiceValueControllers = List.generate(productDetails.length, (index) => TextEditingController());
  //   fgoValueControllers = List.generate(productDetails.length, (index) => TextEditingController());
  //  // loadDataAndInitializeMenu();
  // }
  void initState() {
    super.initState();
    initUser();
   // getDivisionData();
    _filteredProductGroupData = productGroupData; // Initialize with full data
    if (productDetails != null) {
      for (var i = 0; i < productDetails.length; i++) {
        // quantityControllers.add(TextEditingController());
        // fgoValueControllers.add(TextEditingController());
        // invoiceValueControllers.add(TextEditingController());
        for (var i = 0; i < productDetails.length; i++) {
          _filteredProductGroupData = productGroupData; // Initialize with full data
          quantityControllers.add(TextEditingController());
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access the arguments here
    Map<String, dynamic> arguments = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    print("Argument Data : $arguments");

    data = arguments["data"];
    approvedstatus = data["fgo_request_status"];
    Constants_data.customerid = data["CustomerId"];
    keys = arguments["keys"];
    accountType = arguments["accountType"];
    apiname = arguments["apiname"];
    jsonparameters = arguments["apiparameters"];
    headerdata = arguments["jsonHeader"];
    doctorCode = arguments["doctor_code"];

    if (jsonparameters is List && jsonparameters.isNotEmpty && jsonparameters[0] is Map) {
      jsonparameters1 = Map<String, dynamic>.from(jsonparameters[0]);

      keyNames = jsonparameters1.keys.toList();
      String key1 = keyNames[0]; // doctorCode
      String key2 = keyNames[1]; // accountType
      jsonparameters1[key2] = accountType;
      jsonparameters1[key1] = Constants_data.customerid;
      if (accountType == 'Customer') {
        jsonparameters1['uniqueCode'] = data['UniqueDepoCustCode'];
      }
      // if (accountType == 'FGO') {
      //   jsonparameters1['doctorCode'] = data['doctor_code'];
      // }
    }
  }

  initUser() async {
    if (Constants_data.app_user == null) {
      dataUser = await StateManager.getLoginUser();
    }
    else {
      dataUser = Constants_data.app_user;
    }

    restorePreviousSelections();
    quantityControllers = List.generate(productDetails.length, (index) => TextEditingController());
    invoiceValueControllers = List.generate(productDetails.length, (index) => TextEditingController());
    fgoValueControllers = List.generate(productDetails.length, (index) => TextEditingController());
    // getMenu();
    _tabController = TabController(
        vsync: this, length: Constants_data.categoryList.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    quantityControllers.forEach((controller) => controller.dispose());
    fgoValueControllers.forEach((controller) => controller.dispose());
    invoiceValueControllers.forEach((controller) => controller.dispose());
    for (var controller in quantityControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  var approvedstatus;
  var data;
  var accountType;
  var apiname;
  var doctorCode;

  var jsonparameters;
  Map<String, dynamic> jsonparameters1 ;
  List<String> data_map = [];
  LocationData currentLocation;
  List<String> keyNames;
  Map<String, dynamic> headerdata;

  var tabIndex = 0;
  //TabController _tabController;

  GlobalKey btnKey = GlobalKey();
  List<CustomData> menuList = new List<CustomData>();
  List<Map<String, String>> listCoreFGO = [];

  @override
  Widget build(BuildContext context) {
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    Constants_data.currentScreenContext = context;
    print("Data: ${data}");
    print("accountType: ${accountType}");

    getMenu();
    return Container(
        child: Hero(
            tag: "hero${data["CustomerId"]}",
            child: Material(
              child: Scaffold(
                // floatingActionButton: FloatingActionButton(
                //   key: btnKey,
                //   heroTag: null,
                //   onPressed: () {
                //     showCategoryDialog();
                //   },
                //   child: Icon(
                //     Icons.note_add,
                //     color: AppColors.white_color,
                //   ),
                // ),
                body: Container(
                    decoration: BoxDecoration(
                      image: themeChange.darkTheme
                          ? DecorationImage(
                        image:
                        AssetImage("assets/images/menu_bg_dark.png"),
                        fit: BoxFit.cover,
                      )
                          : DecorationImage(
                        image: AssetImage("assets/images/menu_bg.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top: 35),

                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: [
                              Container(
                                  child: IconButton(
                                      icon: Icon(
                                        PlatformIcons(context).back,
                                        color: AppColors.white_color,
                                        size: 30,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      })),
                              getViewFromListTemplateHeader(data, keys, headerdata),
                              Constants_data.appFlavour == 0 ||
                                  Constants_data.appFlavour == 2
                                  ? Container( //todo null is vsisible from here
                                margin: EdgeInsets.only(right: 10),
                                alignment: Alignment.centerRight,
                                child: FutureBuilder<dynamic>(
                                  future: getDistance(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      return Text(
                                        "${snapshot.data == "N/A" ||
                                            snapshot.data.toString()
                                                .toUpperCase() == "NULL"
                                            ? ""
                                            : snapshot.data}",
                                        style: TextStyle(
                                            color: AppColors.white_color,
                                            fontSize: Constants_data
                                                .getFontSize(context, 12),
                                            fontWeight: FontWeight.normal),
                                      );
                                    }
                                    else {
                                      return Container(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator());
                                    }
                                  },
                                ),
                              )
                                  : SizedBox.shrink()
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: TabBar(
                            controller: _tabController,
                            indicatorColor: AppColors.light_main_color2,
                            indicatorPadding: EdgeInsets.only(bottom: 5.0),
                            indicatorWeight: 4.0,
                            isScrollable: listMenu.length > 3,
                            tabs: listMenu,
                          ),
                        ),
                        Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              //physics: NeverScrollableScrollPhysics(),
                              children: listMenuItems,
                            )),
                        // Container(
                        //   width: double.infinity,
                        //   height: 57,
                        //   child: new Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                        //     children: <Widget>[
                        //       IconButton(
                        //         icon: Icon(Icons.map,
                        //             color: AppColors.white_color),
                        //         onPressed: () async {
                        //           Map<String, dynamic> arg = new HashMap();
                        //           arg["latLng"] =
                        //               new LatLng(21.775293, 72.170195);
                        //           arg["title"] = data["FullName"];
                        //           arg["detail"] = data["mobile"] == null
                        //               ? "N/A"
                        //               : data["mobile"];
                        //
                        //           await Navigator.of(context).pushNamed(
                        //               "/GoogleMapDirectionScreen",
                        //               arguments: arg);
                        //         },
                        //       ),
                        //       IconButton(
                        //         disabledColor: transWhiteColor,
                        //         icon: Icon(
                        //           accountType == "Customer"
                        //               ? Icons.shopping_cart_sharp
                        //               : Icons.phone,
                        //           color: accountType == "Customer" &&
                        //                       Constants_data.appFlavour == 0 ||
                        //                   Constants_data.appFlavour == 2
                        //               ? AppColors.white_color
                        //               : accountType == "RMT"
                        //                   ? AppColors.white_color
                        //                   : transWhiteColor,
                        //         ),
                        //         onPressed: () {
                        //           print("Account type : ${accountType}");
                        //           if (Constants_data.appFlavour == 1 &&
                        //               accountType == "RMT") {
                        //             Navigator.pushNamed(
                        //                 context, "/RMTCallScreen",
                        //                 arguments: data);
                        //           } else {
                        //             if (accountType == "Customer") {
                        //               Navigator.of(context).pushNamed(
                        //                   "/POB_Screen",
                        //                   arguments: data);
                        //             }
                        //           }
                        //         },
                        //       ),
                        //       IconButton(
                        //         icon: Icon(
                        //           Icons.insert_chart,
                        //           color: (accountType == "RMT" ||
                        //                       accountType == "Service" ||
                        //                       accountType == "Customer" ||
                        //                       accountType == "Drug") &&
                        //                   Constants_data.appName != "Heko"
                        //               ? AppColors.white_color
                        //               : transWhiteColor,
                        //         ),
                        //         onPressed: () async {
                        //           if (Constants_data.appName == "Heko") {
                        //             return;
                        //           }
                        //
                        //           print("Account type : ${accountType}");
                        //           bool click = false;
                        //           Map<String, dynamic> dataToSend =
                        //               new HashMap();
                        //           if (Constants_data.appFlavour == 1 &&
                        //               accountType == "RMT") {
                        //             click = true;
                        //             Map<String, dynamic> jsonParam =
                        //                 new HashMap();
                        //             jsonParam["ta_id"] = data["CustomerId"];
                        //             dataToSend["ParentWidgetId"] = "TopTA";
                        //             dataToSend["jsonParam"] = jsonParam;
                        //             dataToSend["Rep_Id"] = Constants_data.repId;
                        //             dataToSend["title_value"] =
                        //                 data["CustomerName"];
                        //             print(jsonEncode(dataToSend));
                        //             // dataToSend["selectedDate"] = selectedDate;
                        //           } else if (Constants_data.appFlavour == 1 &&
                        //               accountType == "Service") {
                        //             click = true;
                        //             Map<String, dynamic> jsonParam =
                        //                 new HashMap();
                        //             jsonParam["service_type"] =
                        //                 data["CustomerId"];
                        //             dataToSend["ParentWidgetId"] =
                        //                 data["CustomerId"];
                        //             dataToSend["jsonParam"] = jsonParam;
                        //             dataToSend["Rep_Id"] = Constants_data.repId;
                        //             dataToSend["title_value"] =
                        //                 data["CustomerName"];
                        //             print(jsonEncode(dataToSend));
                        //           } else if (Constants_data.appFlavour == 0 &&
                        //               accountType == "Customer") {
                        //             click = true;
                        //             Map<String, dynamic> jsonParam =
                        //                 new HashMap();
                        //             jsonParam["CustomerId"] =
                        //                 data["CustomerId"];
                        //             dataToSend["ParentWidgetId"] =
                        //                 "TopCustomer";
                        //             dataToSend["jsonParam"] = jsonParam;
                        //             dataToSend["Rep_Id"] = Constants_data.repId;
                        //             dataToSend["title_value"] =
                        //                 data["CustomerName"];
                        //             print(jsonEncode(dataToSend));
                        //           } else if (Constants_data.appFlavour == 0 &&
                        //               accountType == "Drug") {
                        //             click = true;
                        //             Map<String, dynamic> jsonParam =
                        //                 new HashMap();
                        //             jsonParam["product_group_id"] =
                        //                 data["CustomerId"];
                        //             dataToSend["ParentWidgetId"] = accountType;
                        //             dataToSend["jsonParam"] = jsonParam;
                        //             dataToSend["Rep_Id"] = Constants_data.repId;
                        //             dataToSend["title_value"] =
                        //                 data["CustomerName"];
                        //             print(jsonEncode(dataToSend));
                        //           }
                        //
                        //           if (click) {
                        //             await Navigator.push(
                        //               context,
                        //               MaterialPageRoute(
                        //                 builder: (context) =>
                        //                     ReportsScreen(dataToSend),
                        //               ),
                        //             );
                        //           }
                        //         },
                        //       ),
                        //       IconButton(
                        //         icon: Icon(
                        //           Icons.add_location_alt_sharp,
                        //           color: accountType == 'Customer' ||
                        //                   accountType == 'HCP'
                        //               ? AppColors.white_color
                        //               : transWhiteColor,
                        //         ),
                        //         onPressed: () async {
                        //           if (accountType == 'Customer' ||
                        //               accountType == 'HCP') {
                        //             Location location = new Location();
                        //             PermissionStatus permission =
                        //                 await location.hasPermission();
                        //
                        //             if (permission !=
                        //                 PermissionStatus.granted) {
                        //               await location.requestPermission();
                        //             }
                        //
                        //             try {
                        //               this.currentLocation = await location
                        //                   .onLocationChanged.first;
                        //               // this.currentLocation = await location.onLocationChanged.single;
                        //               print(
                        //                   "Current Location :${currentLocation}");
                        //             } catch (err) {
                        //               print(
                        //                   "Error in getting current user location : ${err}");
                        //             }
                        //
                        //             try {
                        //               print(
                        //                   "Current Location  Lat: ${currentLocation.latitude} Lng: ${currentLocation.longitude}");
                        //               print("AccountType : $accountType");
                        //               print(
                        //                   "CustomerId : ${data["CustomerId"]}");
                        //               print(
                        //                   "Lat : ${currentLocation.latitude}");
                        //               print(
                        //                   "Lng : ${currentLocation.longitude}");
                        //               saveLocationDialog(
                        //                   currentLocation.latitude,
                        //                   currentLocation.longitude,
                        //                   accountType,
                        //                   data["CustomerId"],
                        //                   data["CustomerName"]);
                        //             } catch (err) {
                        //               print("Error in : ${err}");
                        //             }
                        //           }
                        //         },
                        //       ),
                        //       FutureBuilder<bool>(
                        //         future: getConfigData(),
                        //         builder: (context, snapshot) {
                        //           print("SnapShotData : ${snapshot.data}");
                        //           if (snapshot.connectionState ==
                        //               ConnectionState.done) {
                        //             return snapshot.data
                        //                 ? IconButton(
                        //                     icon: Icon(
                        //                       Icons.event_available_sharp,
                        //                       color:
                        //                           accountType == 'Customer' ||
                        //                                   accountType == 'HCP'
                        //                               ? AppColors.white_color
                        //                               : transWhiteColor,
                        //                     ),
                        //                     onPressed: () async {
                        //                       saveTheEvent(data["CustomerId"],
                        //                           accountType);
                        //                     },
                        //                   )
                        //                 : Container();
                        //           } else {
                        //             return Container();
                        //           }
                        //         },
                        //       ),
                        //       new Container(
                        //         width: 60,
                        //         height: 65,
                        //       ),
                        //     ],
                        //   ),
                        // )
                      ],
                    )),
              ),
            )));
  }

  Future<bool> getConfigData() async {
    bool response =
    await Constants_data.checkConfigAvailability("isShowAddReminder");
    print("Response Data for config : ${response}");
    return response != null && response;
  }

  Future<bool> saveLocationDialog(lat, lng, accountType, customerId,
      customerName) async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
            EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: AppColors.main_color,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 90.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.add_location_alt_sharp,
                        size: 30.0,
                        color: AppColors.white_color,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Update Location',
                      style: TextStyle(
                          color: AppColors.white_color,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(15),
                child: Center(
                    child: Text(
                        "Do you want to set your current location as '$customerName' Location?")),
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
                          "No",
                          style: TextStyle(
                              color: AppColors.main_color,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SimpleDialogOption(
                        onPressed: () async {
                          String query =
                              "UPDATE ProfessionalList set Latitude = $lat, Longitude = $lng WHERE CustomerId = '$customerId' AND AccountType = '$accountType'";
                          await DBProfessionalList.prformQueryOperation(
                              query, []);
                          bool isConnectionAvailable =
                          await Constants_data.checkNetworkConnectivity();
                          if (isConnectionAvailable) {
                            try {
                              var _requestJson = {
                                "data": [
                                  {
                                    "AccountType": "$accountType",
                                    "AccountId": "$customerId",
                                    "Latitude": "$lat",
                                    "Longitude": "$lng"
                                  }
                                ]
                              };
                              var data = await _helper.post(
                                  "/updateLatlong?RepId=${Constants_data
                                      .app_user["RepId"]}",
                                  _requestJson,
                                  true);
                              if (data["Status"] == 1) {
                                Constants_data.toastNormal(data["Message"]);
                                Navigator.pop(context);
                              } else {
                                Constants_data.toastError(data["Message"]);
                              }
                            } catch (e) {
                              print("Error : ${e}");
                              Constants_data.toastError("Error in saving data");
                            }
                            Navigator.pop(context, 0);
                          } else {
                            Constants_data.toastError("Internet not available");
                          }
                        },
                        child: Text("Yes",
                            style: TextStyle(
                                color: AppColors.main_color,
                                fontWeight: FontWeight.bold)),
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
  Future<String> getDistance() async {
    Location location = new Location();
    PermissionStatus permission = await location.hasPermission();

    if (permission != PermissionStatus.granted) {
      await location.requestPermission();
    }

    this.currentLocation = await location.onLocationChanged.first;
    print(
        "Current Location  Lat: ${currentLocation
            .latitude} Lng: ${currentLocation.longitude}");

    if (data["Latitude"].toString() != "" &&
        data["Longitude"].toString() != "" &&
        data["Latitude"].toString() != 'null' &&
        data["Longitude"].toString() != "null") {
      // double lat = 21.783710, lng = 72.152388;
      print("Lat : '${data["Latitude"].toString()}'");
      print("Lng : '${data["Longitude"].toString()}'");

      double lat = double.parse(data["Latitude"].toString());
      double lng = double.parse(data["Longitude"].toString());

      try {
        double distance = Constants_data.calculateDistance(
            lat, lng, currentLocation.latitude, currentLocation.longitude);

        return "${double.parse((distance).toStringAsFixed(2))} km";
      } catch (err) {
        print("Error in getting current user location : ${err}");
        return "N/A";
      }
    } else {
      return "N/A";
    }
  }
  showCategoryDialog() {
    double singleViewHeight = 50;
    double availableHeight = MediaQuery
        .of(context)
        .size
        .height - 100;
    int totalItems = categoryList.length;
    double heightToAssign = (totalItems * singleViewHeight) + 50;
    if (heightToAssign > availableHeight) {
      heightToAssign = availableHeight;
    }
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(0.01),
      barrierDismissible: false,
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
                        child: new Stack(
                          children: <Widget>[
                            new Positioned(
                                right: 20,
                                bottom: 80,
                                child: new Container(
                                  decoration: new BoxDecoration(
                                      color: themeData.cardColor,
                                      borderRadius: new BorderRadius.only(
                                        topLeft: const Radius.circular(10.0),
                                        topRight: const Radius.circular(10.0),
                                        bottomLeft: const Radius.circular(10.0),
                                        bottomRight:
                                        const Radius.circular(10.0),
                                      )),
                                  height: heightToAssign,
                                  child: SingleChildScrollView(
                                      child: new Column(
                                        children: getViewItems(),
                                      )),
                                ))
                          ],
                        )))));
      },
    );
  }
  getViewItems() {
    List<Widget> cols = [];
    for (int i = 0; i < categoryList.length; i++) {
      print("Category : ${categoryList[i]}");
      cols.add(new GestureDetector(
          onTap: () {
            print("Menu Index : ${i}");
            _tabController.index = i;
            pos = i;
            Navigator.pop(context);
          },
          child: new Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(width: 0.3, color: Color(0xFFAAAAAA))
                )
            ),
            margin: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
            width: MediaQuery
                .of(context)
                .size
                .width * 0.5,
            height: 50,
            child: Row(
              children: <Widget>[
                Image.network(
                    "${categoryList[i]["ImageURL"]}", height: 20, width: 20),
                SizedBox(width: 5),
                Text(
                  "${categoryList[i]["CategoryDescription"]}",
                  style: TextStyle(
                      fontWeight: _tabController.index == i
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _tabController.index == i
                          ? AppColors.main_color
                          : themeData.textTheme.caption.color),
                )
              ],
            ),
          )));
    }
    return cols;
  }
  getCategoryViewForDialog() {
    List<Widget> rows = [];
    for (int i = 0; i < categoryList.length; i++) {
      rows.add(new Container(
        child: new Text("${categoryList[i]["CategoryDescription"]}"),
      ));
    }
    return rows;
  }

  List<Widget> listMenu = [];
  List<Widget> listMenuItems = [];
  List<dynamic> categoryList = [];

  getMenu() {
    categoryList = Constants_data.categoryList;
    listMenu = [];
    listMenuItems = [];
    double menuWidth;
    if (categoryList.length <= 3) {
      menuWidth = MediaQuery
          .of(context)
          .size
          .width / categoryList.length;
    }
    for (int i = 0; i < categoryList.length; i++) {
      listMenu.add(new Container(
        height: 50,
        width: menuWidth,
        child: new Center(
          child: new Text(
            "${categoryList[i]["CategoryDescription"]}",
            style: TextStyle(color: AppColors.white_color),
          ),
        ),
      ));
      if (!isDataLoaded)
        createMenuChildDetailScreen(i);
      else
        createMenuChildDetailScreen(i);
      // createMenuChildDetailScreenDirect(i);
    }
    isDataLoaded = true;
    // setState(() {
    //   isDataLoaded = true; // Update state only after all operations are complete
    // });
    // if (!isDataLoaded) {
    //   // Set isDataLoaded to true only after the first load is complete
    //   setState(() {
    //     isDataLoaded = true;
    //   });
    // }
  }
  bool isDataLoaded = false;
  // void createMenuChildDetailScreenss(index) {
  //   listMenuItems.add(new Container(
  //     //color: themeData.primaryColor,
  //     color: Colors.white,
  //     height: 50,
  //     child: new SingleChildScrollView(
  //       child:
  //       FutureBuilder<dynamic>(
  //         future: getTemplateJson(
  //             categoryList[index]["CategoryCode"], index, accountType),
  //         builder: (context, snapshot) {
  //           if (snapshot.connectionState == ConnectionState.done) {
  //             return snapshot.data;
  //           } else {
  //             return Center(child: CircularProgressIndicator());
  //           }
  //         },
  //       ),
  //     ),
  //   ));
  // }
  void createMenuChildDetailScreen(index) {
    listMenuItems.add(
      Container(
        color: Colors.white,
        height: 50,
        child: SingleChildScrollView(
          child: FutureBuilder<dynamic>(
            future: getTemplateJson(
                categoryList[index]["CategoryCode"], index, accountType),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(child: Text("Data not available"));
                }
                if (snapshot.hasData) {
                  // Check if listCoreFGO or listCoreData is empty
                  if ((accountType == "FGO" && listCoreFGO.isEmpty) ||
                      (accountType != "FGO" && listCoreData.isEmpty)) {
                    return Center(child: Text("Data not available"));
                  }
                  return snapshot.data;
                }
                else {
                  return Center(child: Text("Data not available"));
                }
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
  void createMenuChildDetailScreenDirect(index) async {
    var json = jsonStringData[index];
    listMenuItems.add(new Container(
      color: themeData.primaryColor,
      height: 50,
      child: new SingleChildScrollView(
        child: json != ""
            ? createViewFromTemplateJson(
            json["body"]["Row"], listCoreData, listCategoryCode, index, listCoreFGO)
            : new Center(
            child: new Container(
              padding: EdgeInsets.all(10),
              child: new Text("Template Json Not Found"),
            )),
      ),
    ));
  }

  Widget mainView;
  Map<String, dynamic> dataList;
  List dataforleve1 = [];
  Map<String, String> listCoreData = {};
  // List<Map<String, String>> listCoreFGO = [];
  Map<String, String> listCategoryCode = new HashMap();
  List getDoctorDetailsForApproval = [];
  dynamic productDetailData;

  List<bool> showGetDoctorDetailsForApproval = [];

  Future<dynamic> GetDoctorDetailsForApproval({String divisionCode = "", String doctorCode = ""}) async {
    bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
    if (isNetworkAvailable) {
      divisionCode = divisionCode.isEmpty ? Constants_data.selectedDivisionId : divisionCode;
      doctorCode = doctorCode.isEmpty ? Constants_data.customerid : doctorCode;
      final String url = '/Dashboard/GetRequestDetailsForApproval?repId=${dataUser["RepId"]}&divisionCode=${divisionCode}&designationCode=${dataUser["Designation"]}&Status=ALL&doctorCode=${doctorCode}';

      try {
        var response = await _helper.get(url);

        if (response["Status"].toString() == "1") {
           getDoctorDetailsForApproval = response["dt_ReturnedTables"][0];
          return getDoctorDetailsForApproval;
        }
        else if (response["Status"].toString() == "0") {
          //Constants_data.toastNormal("${response["Message"]}");
        }
        else if (response["Status"].toString() == "8") {
         // Constants_data.toastNormal("${response["message"]}");
          await StateManager.logout();
          Constants_data.selectedDivisionName= "";
          Constants_data.selectedDivisionId = null;
          Constants_data.selectedHQCode = null;
          Constants_data.repId = null;
          Constants_data.SessionId = null;
          Constants_data.app_user= null;
          await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,  // This removes all previous routes
          );
         // await Navigator.pushReplacementNamed(context, "/Login");
        }else if (response["Status"].toString() == "4") {
          Constants_data.toastNormal("${response["message"]}");
          await StateManager.logout(); // Wait for logout to complete
          //await SharedPrefs.instance.deleteUser(); // Wait for deletion to complete
          Constants_data.selectedDivisionName = "";
          Constants_data.selectedDivisionId = "";
          Constants_data.selectedHQCode = null;
          Constants_data.repId = null;
          Constants_data.SessionId = null;
          Constants_data.app_user= null;
          await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,  // This removes all previous routes
          );
          //await Navigator.pushReplacementNamed(context, "/Login");
        }else if (response["Status"].toString() == "5") {
          //Constants_data.toastNormal("${response["message"]}");
          await StateManager.logout(); // Wait for logout to complete
          //await SharedPrefs.instance.deleteUser(); // Wait for deletion to complete
          Constants_data.selectedDivisionName = "";
          Constants_data.selectedDivisionId = null;
          Constants_data.selectedHQCode = null;
          Constants_data.repId = null;
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
        else {
          if (response["Status"].toString() == "7") {
            Navigator.pushReplacementNamed(context, "/Login");
          }
        }
      } catch (error) {
        // Handle any exceptions
        print('Error: $error');
        //showAlertDialog("An error occurred while fetching doctor details.");
      }
    } else {
      await Constants_data.openDialogNoInternetConection(context);
    }
  }
  GetproductDetailData({docNo,divisionCode,stateCode,hqCode,monthCode}) async {
    bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
    if (isNetworkAvailable) {
      String url = '/Dashboard/GetDoctorApprovalDetails';

      DateTime now = DateTime.now();
      // Map<String, dynamic> requestData = {
      var requestData = {
        "doc_no": docNo,
        "doctorCode": Constants_data.customerid,
        "divisionCode": divisionCode,
        "hqCode": hqCode,
        "stateCode": stateCode,
        'yearCode': '24-25',
       // 'monthCode': "${DateFormat('MM').format(now)}",
        'monthCode': monthCode,
      };
      try {
        final productjson = await _helper.postMethod(
          url,
          requestData,
          true, // Indicates JSON serialization is required
        );
        if(productjson["Status"] ==1){
          print('Response: $productjson');
          productDetailData = productjson["dt_ReturnedTables"][0]["Table1"];
          // productDetailData = List<Map<String, dynamic>>.from(rawProductData);
          return productDetailData;
        } else if(productjson["Status"] ==0){
           Constants_data.toastError(productjson["Message"]);
        }else if(productjson["Status"] ==2){
           Constants_data.toastError(productjson["Message"]);
        }else if(productjson["status"].toString() =="3"){
           Constants_data.toastError(productjson["message"]);
        }else if(productjson["status"].toString() =="4"){
           Constants_data.toastError(productjson["message"]);
           await StateManager.logout(); // Wait for logout to complete
           //await SharedPrefs.instance.deleteUser(); // Wait for deletion to complete
           Constants_data.selectedDivisionName = "";
           Constants_data.selectedDivisionId = null;
           Constants_data.selectedHQCode = null;
           Constants_data.repId = null;
           Constants_data.SessionId = null;
           Constants_data.app_user= null;
           await Navigator.pushAndRemoveUntil(
             context,
             MaterialPageRoute(builder: (context) => LoginScreen()),
                 (Route<dynamic> route) => false,  // This removes all previous routes
           );

          //await Navigator.pushReplacementNamed(context, "/Login");
        }else if(productjson["status"].toString() =="5"){
           //Constants_data.toastError(productjson["message"]);
           await StateManager.logout(); // Wait for logout to complete
           //await SharedPrefs.instance.deleteUser(); // Wait for deletion to complete
           Constants_data.selectedDivisionName = "";
           Constants_data.selectedDivisionId = null;
           Constants_data.selectedHQCode = null;
           Constants_data.repId = null;
           Constants_data.SessionId = null;
           Constants_data.app_user= null;
           await Navigator.pushAndRemoveUntil(
             context,
             MaterialPageRoute(builder: (context) => LoginScreen()),
                 (Route<dynamic> route) => false,  // This removes all previous routes
           );
          // await Navigator.pushReplacementNamed(context, "/Login");
        }
      } catch (error) {
        print('Error: $error');
      }
    }else {
      await Constants_data.openDialogNoInternetConection(context);
    }
  }

  String purchaseorder="";
  Map<String, dynamic> filteredData ={};
  Map<String, dynamic> orderdata ={};

  Future<List<dynamic>> getapprovaldataforlevel1(List<dynamic> listcoredetails) async {
    bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
    if (isNetworkAvailable) {
      final firstRecord = listcoredetails.isNotEmpty
          ? listcoredetails.first
          : null;

      if (firstRecord == null) {
        print('No data available in listcoredetails');
        return [];
      }
      final String url = '/Dashboard/GetDoctorApprovalDetails';
      DateTime now = DateTime.now();
     // Map<String, dynamic> requestData = {
       var requestData = {
        "doc_no": Constants_data.customerid,
        "doctorCode": firstRecord["doctor_code"],
        "divisionCode": firstRecord["division_code"],
        "hqCode": firstRecord["hq_code"],
        "stateCode": firstRecord["state_code"],
        'yearCode': '24-25',
        'monthCode': "${DateFormat('MM').format(now)}",
      };
      try {
        final productjson = await _helper.postMethod(
          url,
          requestData,
          true, // Indicates JSON serialization is required
        );
          if (productjson["Status"] == 1) {
            List<dynamic> productDetailDataforapproval = productjson["dt_ReturnedTables"][0]["Table2"];
            List<dynamic> purchaseorderforapproval = productjson["dt_ReturnedTables"][0]["Table1"];
            String purchaseorderdata = purchaseorderforapproval[0]["po_document_proof"];
            purchaseorder =
            "http://122.170.7.252/MicroDishaWebApiPublish/Content/PurchaseOrders/$purchaseorderdata";
            print("$purchaseorder");

            if (productDetailDataforapproval.isNotEmpty) {
              // Get the first entry and filter required fields
              var firstEntry = productDetailDataforapproval[0];
              // Extracting the required fields
              filteredData = {
                "supply_through": firstEntry["stockiest_name"],
                "repnam": firstEntry["employee_name"],
                "totaldoctorlimit": firstEntry["Doctor_limit"],
                "consumeddoctorlimit": firstEntry["consumed_doctor_limit"],
                "totalstatelimit": firstEntry["State_Limit"],
                "consumedstatelimit": firstEntry["consumed_state_limit"],
                "availablestatelimit": firstEntry["state_available_limit"],
                "availabledoctorlimit": firstEntry["doctor_available_limit"],
                //  "purchaseorder": firstEntry["consumed_state_limit"],
              };

              return [filteredData]; // Return as a list of filtered data
            }
            else {
              print('No data available in Table2');
              return [];
            }
          }
          else if (productjson["status"] == 0) {
          Constants_data.toastError(productjson["Message"]);
          }
          else if (productjson["status"] == 2) {
          Constants_data.toastError(productjson["Message"]);
          }
          else if (productjson["status"].toString() == "8") {
           // Constants_data.toastError(productjson["message"]);
            await StateManager.logout(); // Wait for logout to complete
            //await SharedPrefs.instance.deleteUser(); // Wait for deletion to complete
            Constants_data.selectedDivisionName = "";
            Constants_data.selectedDivisionId = null;
            Constants_data.selectedHQCode = null;
            Constants_data.repId = null;
            Constants_data.SessionId = null;
            Constants_data.app_user= null;
            await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,  // This removes all previous routes
            );
           // await Navigator.pushReplacementNamed(context, "/Login");
          }
          else if (productjson["status"].toString() == "4") {
            Constants_data.toastError(productjson["message"]);
            await StateManager.logout(); // Wait for logout to complete
            //await SharedPrefs.instance.deleteUser(); // Wait for deletion to complete
            Constants_data.selectedDivisionName = "";
            Constants_data.selectedDivisionId = null;
            Constants_data.selectedHQCode = null;
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
          else if (productjson["status"].toString() == "5") {
            //Constants_data.toastError(productjson["message"]);
            await StateManager.logout(); // Wait for logout to complete
           //await SharedPrefs.instance.deleteUser(); // Wait for deletion to complete
            Constants_data.selectedDivisionName = "";
            Constants_data.selectedDivisionId = null;
            Constants_data.selectedHQCode = null;
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
        //}
        // else {
        //   print('Failed to load product details: ${response.statusCode}');
        //   return []; // Return an empty list in case of failure
        // }
      } catch (error) {
        print('Error: $error');
        return []; // Return an empty list in case of an exception
      }
    }else {
      await Constants_data.openDialogNoInternetConection(context);
    }
  }
  getTemplateJson(viewID, int index, String accType) async {
    jsonStringData = [];
    var jsonString = await DBProfessionalList.getTemplateFromViewId(
        viewID, accType);

    dataList = await getAccountDetailsData(apiname, jsonparameters1);
    dataforleve1 = await getapprovaldataforlevel1(listCoreFGO);

    if (jsonString == "") {
      mainView = new Center(
          child: new Container(
            padding: EdgeInsets.all(10),
            child: new Text("Template Json not Found"),
          ));
      jsonStringData.add(jsonString);
    }
    else {
      var json = jsonDecode(jsonString);
      jsonStringData.add(json);

      mainView = createViewFromTemplateJson(
          json["body"]["Row"], listCoreData, listCategoryCode, index, listCoreFGO);
    }
    isDataLoaded = true;
    return mainView;
  }
  //present working code//
  Future<Map<String, dynamic>> getAccountDetailsData(String apiname, Map<String, dynamic> jsonparameters1) async {
    bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
    if (isNetworkAvailable) {
      String queryString = Uri(queryParameters: jsonparameters1).query;
      String url = "/Profiler/$apiname?$queryString";

      String accountType = jsonparameters1['accountType'];

      try {
        var response = await _helper.get(url);

        if (response["Status"] == 1) {
          listCoreFGO = [];
          listCoreData = {};
          Map<String, dynamic> data = response["dt_ReturnedTables"];
          if (accountType == "FGO") {
            if (data.containsKey("dt_CategoryDetails") &&
                data["dt_CategoryDetails"] is List) {
              List<dynamic> categoryDetails = data["dt_CategoryDetails"];
              for (var detail in categoryDetails) {
                if (detail is Map<String, dynamic>) {
                  Map<String, String> mappedDetail = detail.map((key, value) =>
                      MapEntry(key, value.toString()));
                  listCoreFGO.add(mappedDetail);
                }
              }
            } else {
              print("Error: dt_CategoryDetails is not a List for FGO.");
            }
          } else {
            if (data.containsKey("dt_CategoryDetails") &&
                data["dt_CategoryDetails"] is List) {
              List<dynamic> categoryDetails = data["dt_CategoryDetails"];
              for (var detail in categoryDetails) {
                if (detail is Map<String, dynamic>) {
                  listCoreData.addAll(detail.map((key, value) =>
                      MapEntry(key, value.toString())));
                }
              }
            } else {
              print("Error: dt_CategoryDetails is not a List.");
            }
          }

          if (data.containsKey("CategoryCodeDetails") &&
              data["CategoryCodeDetails"] is Map) {
            Map<String,
                dynamic> categoryCodeDetails = data["CategoryCodeDetails"];
            listCategoryCode.addAll(categoryCodeDetails.map((key, value) =>
                MapEntry(key, value.toString())));
          } else {
            print("Error: CategoryCodeDetails is not a Map.");
          }

          // Return different maps depending on accountType
          if (accountType == "FGO") {
            return {
              "listCoreFGO": listCoreFGO,
              "listCategoryCode": listCategoryCode,
            };
          } else {
            return {
              "listCoreData": listCoreData,
              "listCategoryCode": listCategoryCode,
            };
          }
        }
        else if (response["status"].toString() == "8") {
          print("There Is No Products for This Division");
         // showAlertDialog(response["message"]);
          await StateManager.logout();
          Constants_data.selectedDivisionName = null;
          Constants_data.selectedDivisionId = null;
          Constants_data.selectedHQCode = null;
          Constants_data.repId = null;
          Constants_data.SessionId = null;
          Constants_data.app_user= null;
          await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,  // This removes all previous routes
          );
          //Navigator.pushReplacementNamed(context, "/Login");
        }
        else if (response["status"].toString() == "4") {
          print("There Is No Products for This Division");
          showAlertDialog(response["message"]);
          await StateManager.logout(); // Wait for logout to complete
          //await SharedPrefs.instance.deleteUser(); // Wait for deletion to complete
          Constants_data.selectedDivisionName = null;
          Constants_data.selectedDivisionId = null;
          Constants_data.selectedHQCode = null;
          Constants_data.repId = null;
          Constants_data.SessionId = null;
          Constants_data.app_user= null;
          await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,  // This removes all previous routes
          );
         // await Navigator.pushReplacementNamed(context, "/Login");
        }
        else if (response["status"].toString() == "5") {
          //showAlertDialog(response["message"]);
          await StateManager.logout(); // Wait for logout to complete
          //await SharedPrefs.instance.deleteUser(); // Wait for deletion to complete
          Constants_data.selectedDivisionName = null;
          Constants_data.selectedDivisionId = null;
          Constants_data.selectedHQCode = null;
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
        else {
          print("Error: ${response["Status"]}");
          return {};
        }
      } catch (e) {
        print('Exception: $e');
        return {};
      }
    }else {
      await Constants_data.openDialogNoInternetConection(context);
    }
  }
  Future<List<dynamic>> getListDataFromTable(String tableName,
      String condition) async {
    List<dynamic> listData = await DBProfessionalList.getTableDataForChart(
        tableName, data["CustomerId"].toString(), condition);
    return listData;
  }
  getDataSourceLineChart(String xAxis, String columns, List<dynamic> listData) {
    List<SalesData> list = [];
    for (int i = 0; i < listData.length; i++) {
      list.add(
          SalesData(listData[i][xAxis], double.parse(listData[i][columns])));
    }
    return list;
  }
  getDataSourceCircularChart(List<dynamic> listData) {
    List<RedialChartSampleData> list = [];
    for (int i = 0; i < listData.length; i++) {
      list.add(
        RedialChartSampleData(
            x: listData[i]["date"],
            y: double.parse(listData[i]["value"]),
            text: listData[i]["value"],
            pointColor: const Color.fromRGBO(248, 177, 149, 1.0)),
      );
    }
    return list;
  }
  getDataSourcePieChart(List<dynamic> listData, String column, String xAxis) {
    List<PieChartSampleData> list = [];
    double total = 0;
    for (int i = 0; i < listData.length; i++) {
      total += double.parse(listData[i][xAxis]);
    }

    for (int i = 0; i < listData.length; i++) {
      double per = double.parse(listData[i][xAxis]) * 100 / total;
      list.add(PieChartSampleData(
          x: listData[i][column],
          y: double.parse(listData[i][xAxis]),
          text: "${double.parse((per).toStringAsFixed(2))} %"));
    }
    return list;
  }
  resetRequestData(jsonTemplate) {
    for (int i = 0; i < jsonTemplate.length; i++) {
      var widgetJson = jsonTemplate[i][0];
      if (widgetJson["widget_type"] == "Field") {
        jsonTemplate[i][0]["value"] = "";
      } else if (jsonTemplate[i][0]["widget_type"] == "Dropdown") {
        jsonTemplate[i][0]["defaultSelection"] = 0;
      }
    }
  }
  createRequestView(List<dynamic> dialogTemplate, List<dynamic> tableData,
      List<String> columns, String tableName) {
    List<Widget> cols = [];
    String str = jsonEncode(dialogTemplate);
    var template = jsonDecode(str);
    List<dynamic> listTemplates = [];

    for (int i = 0; i < tableData.length; i++) {
      List<Widget> formCol = [];
      for (int j = 0; j < template.length; j++) {
        if (template[j][0]["widget_type"] == "Field") {
          template[j][0]["value"] =
              tableData[i][template[j][0]["widget_id"]].toString();
        } else if (template[j][0]["widget_type"] == "Dropdown") {
          int defaultSelection = 0;
          List<dynamic> options = template[j][0]["options"];
          for (int k = 0; k < options.length; k++) {
            if (options[k]["name"] ==
                tableData[i][template[j][0]["widget_id"]].toString()) {
              defaultSelection = k;
            }
          }
          template[j][0]["defaultSelection"] = defaultSelection;
        }
        formCol.add(new Row(
          children: <Widget>[
            new Expanded(
                flex: 30,
                child: InkWell(
                    onLongPress: () {
                      showCustomMenu(template[j][0]["label"]);
                    },
                    // Have to remember it on tap-down.
                    onTapDown: storePosition,
                    child: new Text(template[j][0]["label"]))),
            new Expanded(flex: 10, child: new Text(" : ")),
            new Expanded(
                flex: 60,
                child: new Text(
                    tableData[i][template[j][0]["widget_id"]].toString()))
          ],
        ));
        formCol.add(new SizedBox(
          height: 15,
        ));
      }
      listTemplates.add(jsonEncode(template));
      Widget v = new Card(
          elevation: 5,
          margin: EdgeInsets.all(5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          child: Padding(
              padding: EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
              child: new Stack(
                children: <Widget>[
                  new Column(
                    children: formCol,
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: new GestureDetector(
                        onTap: () {
                          print("Data : ${tableData[i]}");
                          var editTableData = tableData[i];
                          _settingModalBottomSheetEdit(
                              context,
                              jsonDecode(listTemplates[i]),
                              tableName,
                              true,
                              editTableData);
                        },
                        child: new Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.main_color, width: 1)),
                          height: 27,
                          width: 27,
                          child: Center(
                            child: new Icon(
                              Icons.edit,
                              color: AppColors.main_color,
                              size: 20,
                            ),
                          ),
                        ),
                      ))
                ],
              )));

      cols.add(v);
    }

    Widget vi = new Container(
      padding: EdgeInsets.only(bottom: 5),
      child: new Column(
        children: cols,
      ),
    );
    return vi;
  }
  void _settingModalBottomSheet(context, list, String tableName) {
    showModalBottomSheet1(
//        shape: RoundedRectangleBorder(
//          borderRadius: BorderRadius.circular(10.0),
//        ),
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter state) {
                return SingleChildScrollView(
                    child: InkWell(
                        onTap: () {},
                        child: Container(
                            color: themeData.cardColor,
                            margin:
                            EdgeInsets.only(left: 10, right: 10, bottom: 10),
                            child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: createDialogViewFromTemplate(
                                    list, state, tableName)))));
              });
        });
  }
  void _settingModalBottomSheetEdit(context, list, String tableName,
      bool isEdit, var editTableData) {
    showModalBottomSheet1(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter state) {
                return SingleChildScrollView(
                    child: InkWell(
                        onTap: () {},
                        child: Container(
                            margin:
                            EdgeInsets.only(left: 10, right: 10, bottom: 10),
                            child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: createDialogViewFromTemplateEdit(list,
                                    state, tableName, isEdit,
                                    editTableData)))));
              });
        });
  }
  createDialogViewFromTemplate(jsonTemplate, StateSetter setState, String tableName) {
    List<Widget> col = [];
    col.add(new Stack(
      children: <Widget>[
        new Positioned(
//            top: -5.0,
//            left: -5.0,
            child: new Align(
              child: ElevatedButton.icon(
                icon: Icon(Icons.save),
                onPressed: () {
                  onSaveRequestData(jsonTemplate, tableName);

                },
                label: new Text("Save"),
              ),
              alignment: Alignment.centerLeft,
            )),
        new Positioned(
            child: new Align(
              child: ElevatedButton.icon(
                icon: Icon(Icons.close),
                onPressed: () {
                  //resetRequestData(jsonTemplate);
                  Navigator.pop(context);
                },
                label: new Text("Close"),
              ),
              alignment: Alignment.centerRight,
            )),
      ],
    ));

    for (int i = 0; i < jsonTemplate.length; i++) {
      List<Widget> row = [];
      row.add(new Expanded(
        flex: 26,
        child: new Text(
            jsonTemplate[i][0]["label"] != null
                ? jsonTemplate[i][0]["label"]
                : "N/A",
            style: new TextStyle(color: themeData.textTheme.caption.color)),
      ));
      row.add(new Expanded(
        flex: 4,
        child: new Text(":"),
      ));
      if (jsonTemplate[i][0]["widget_type"] == "Text") {
        row.add(new Expanded(
          flex: 60,
          child: new Text(
//            jsonData[jsonTemplate[i][0]["widget_id"]] != null
//                ? jsonData[jsonTemplate[i][0]["widget_id"]]
//                : "-",
            "",
            style: new TextStyle(
              // color: Constants_data.hexToColor(jsonTemplate[i][0]["txt_color"]),
                fontWeight: jsonTemplate[i][0]["txt_style" == "Bold"
                    ? FontWeight.bold
                    : FontWeight.normal]),
          ),
        ));
      }
        else if (jsonTemplate[i][0]["widget_type"] == "Field") {
        TextInputType type = TextInputType.text;
        List<TextInputFormatter> inputFormatter = [];
        if (jsonTemplate[i][0]["inputType"] == "Phone") {
          type = TextInputType.phone;
          inputFormatter = [
            FilteringTextInputFormatter.allow(RegExp('[0-9+]')),
          ];
        }
        else if (jsonTemplate[i][0]["inputType"] == "Email") {
          type = TextInputType.emailAddress;
        }
        else {
          type = TextInputType.text;
        }

        final myController = TextEditingController();
        row.add(new Expanded(
            flex: 60,
            child: new Container(
              height: 30.0,
              child: new TextField(
                controller: myController,
                keyboardType: type,
                inputFormatters: inputFormatter,
                onChanged: (str) {
                  jsonTemplate[i][0]["value"] = str;
                },
                style: new TextStyle(
                    fontSize: 13,
                    // color: Constants_data.hexToColor(jsonTemplate[i][0]["txt_color"]),
                    fontWeight: jsonTemplate[i][0]["txt_style" == "Bold"
                        ? FontWeight.bold
                        : FontWeight.normal]),
              ),
            )));
        myController.text = jsonTemplate[i][0]["value"];
      }
        else if (jsonTemplate[i][0]["widget_type"] == "Dropdown") {
        List<DropdownMenuItem> items = [];
        List<dynamic> listItems = [];

        listItems = jsonTemplate[i][0]["options"];

        for (int k = 0; k < listItems.length; k++) {
          items.add(
              DropdownMenuItem(value: k, child: Text(listItems[k]["name"])));
          //print(listItems[k]);
        }
        if (listItems.length > 0) {
          row.add(new Expanded(
              flex: 70,
              child: new Container(
                  height: 35.0,
                  width: 100,
                  margin: EdgeInsets.only(bottom: 10.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: new DropdownButton(
                        isExpanded: true,
                        hint: Text('Please choose a location'),
                        // Not necessary for Option 1
                        value: jsonTemplate[i][0]["defaultSelection"],
                        onChanged: (newValue) {
                          setState(() {
                            print("Selected Value 2: ${newValue}");
                            jsonTemplate[i][0]["defaultSelection"] = newValue;
                          });
                        },
                        items: items,
                      )))));
        } else {
          row.add(new Container(child: new Text("listItems.length = 0")));
        }
      }
      col.add(new Container(
          margin: EdgeInsets.only(left: 5, top: 10, bottom: 10, right: 5),
          child: new Row(
            children: row,
          )));
    }
    return col;
  }
  createDialogViewFromTemplateEdit(jsonTemplate, StateSetter setState,
      String tableName, bool isEdit, var editTableData) {
    List<Widget> col = [];

    col.add(new Stack(
      children: <Widget>[
        new Positioned(
//            top: -5.0,
//            left: -5.0,
            child: new Align(
              child: ElevatedButton.icon(
                icon: Icon(Icons.save),
                onPressed: () {
                  onSaveRequestDataEdit(
                      jsonTemplate, tableName, isEdit, editTableData);
                },
                label: new Text("Save"),
              ),
              alignment: Alignment.centerLeft,
            )),
        new Positioned(
            child: new Align(
              child: ElevatedButton.icon(
                icon: Icon(Icons.close),
                onPressed: () {
                  //resetRequestData(jsonTemplate);
                  Navigator.pop(context);
                },
                label: new Text("Close"),
              ),
              alignment: Alignment.centerRight,
            )),
      ],
    ));

    for (int i = 0; i < jsonTemplate.length; i++) {
      List<Widget> row = [];
      row.add(new Expanded(
        flex: 26,
        child: new Text(
            jsonTemplate[i][0]["label"] != null
                ? jsonTemplate[i][0]["label"]
                : "N/A",
            style: new TextStyle(color: Colors.black45)),
      ));
      row.add(new Expanded(
        flex: 4,
        child: new Text(":"),
      ));
      if (jsonTemplate[i][0]["widget_type"] == "Text") {
        row.add(new Expanded(
          flex: 60,
          child: new Text(
//            jsonData[jsonTemplate[i][0]["widget_id"]] != null
//                ? jsonData[jsonTemplate[i][0]["widget_id"]]
//                : "-",
            "",
            style: new TextStyle(
                color:
                Constants_data.hexToColor(jsonTemplate[i][0]["txt_color"]),
                fontWeight: jsonTemplate[i][0]["txt_style" == "Bold"
                    ? FontWeight.bold
                    : FontWeight.normal]),
          ),
        ));
      } else if (jsonTemplate[i][0]["widget_type"] == "Field") {
        TextInputType type = TextInputType.text;
        List<TextInputFormatter> inputFormatter = [];
        if (jsonTemplate[i][0]["inputType"] == "Phone") {
          type = TextInputType.phone;
          inputFormatter = [
            FilteringTextInputFormatter.allow(RegExp('[0-9+]')),
          ];
        } else if (jsonTemplate[i][0]["inputType"] == "Email") {
          type = TextInputType.emailAddress;
        } else {
          type = TextInputType.text;
        }

        final myController = TextEditingController();
        row.add(new Expanded(
            flex: 60,
            child: new Container(
              height: 30.0,
              child: new TextField(
                controller: myController,
                keyboardType: type,
                inputFormatters: inputFormatter,
                onChanged: (str) {
                  jsonTemplate[i][0]["value"] = str;
                },
                style: new TextStyle(
                  //color: Constants_data.hexToColor(jsonTemplate[i][0]["txt_color"]),
                    fontWeight: jsonTemplate[i][0]["txt_style" == "Bold"
                        ? FontWeight.bold
                        : FontWeight.normal]),
              ),
            )));
        if (isEdit) myController.text = jsonTemplate[i][0]["value"];
      } else if (jsonTemplate[i][0]["widget_type"] == "Dropdown") {
        List<DropdownMenuItem> items = [];
        List<dynamic> listItems = [];

        listItems = jsonTemplate[i][0]["options"];

        for (int k = 0; k < listItems.length; k++) {
          items.add(
              DropdownMenuItem(value: k, child: Text(listItems[k]["name"])));
          //print(listItems[k]);
        }
        if (listItems.length > 0) {
          row.add(new Expanded(
              flex: 70,
              child: new Container(
                  height: 35.0,
                  width: 100,
                  margin: EdgeInsets.only(bottom: 10.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: new DropdownButton(
                        isExpanded: true,
                        hint: Text('Please choose a location'),
                        // Not necessary for Option 1
                        value: jsonTemplate[i][0]["defaultSelection"],
                        onChanged: (newValue) {
                          setState(() {
                            print("Selected Value 3: ${newValue}");
                            jsonTemplate[i][0]["defaultSelection"] = newValue;
                          });
                        },
                        items: items,
                      )))));
        } else {
          row.add(new Container(child: new Text("listItems.length = 0")));
        }
      }
      col.add(new Container(
          margin: EdgeInsets.only(left: 5, top: 10, bottom: 10, right: 5),
          child: new Row(
            children: row,
          )));
    }
    return col;
  }
  void onSaveRequestData(jsonTemplate, String tableName) {
    Map<String, String> dataToSave = new HashMap();
    //bool isValid = true;
    for (int i = 0; i < jsonTemplate.length; i++) {
      var widgetJson = jsonTemplate[i][0];
      if (widgetJson["widget_type"] == "Field") {
        if (widgetJson["value"] == "") {
          dataToSave[widgetJson["widget_id"]] = "";
//          isValid = false;
//          Constants_data.toastError("${widgetJson["label"]} can't be blank");
        } else {
          dataToSave[widgetJson["widget_id"]] = widgetJson["value"];
        }
        jsonTemplate[i][0]["value"] = "";
      } else if (jsonTemplate[i][0]["widget_type"] == "Dropdown") {
        List<dynamic> options = jsonTemplate[i][0]["options"];
        dataToSave[widgetJson["widget_id"]] =
            options[widgetJson["defaultSelection"]]["name"].toString();
        jsonTemplate[i][0]["defaultSelection"] = 0;
      }
    }
    print("Data to save ${dataToSave}");
    dataToSave["Uniqueid"] = Constants_data.getUUID();
    addDataInRequestTable(tableName, dataToSave);
    Navigator.pop(context);
    //resetRequestData(jsonTemplate);
  }
  void onSaveRequestDataEdit(jsonTemplate, String tableName, bool isEdit,
      var editTableData) {
    Map<String, String> dataToSave = new HashMap();
    //bool isValid = true;
    for (int i = 0; i < jsonTemplate.length; i++) {
      var widgetJson = jsonTemplate[i][0];
      if (widgetJson["widget_type"] == "Field") {
        if (widgetJson["value"] == "") {
          dataToSave[widgetJson["widget_id"]] = "";
//          isValid = false;
//          Constants_data.toastError("${widgetJson["label"]} can't be blank");
        } else {
          dataToSave[widgetJson["widget_id"]] = widgetJson["value"];
        }
        jsonTemplate[i][0]["value"] = "";
      } else if (jsonTemplate[i][0]["widget_type"] == "Dropdown") {
        List<dynamic> options = jsonTemplate[i][0]["options"];
        dataToSave[widgetJson["widget_id"]] =
            options[widgetJson["defaultSelection"]]["name"].toString();
        jsonTemplate[i][0]["defaultSelection"] = 0;
      }
    }
    print("Data to save ${dataToSave}");
    addDataInRequestTableEdit(tableName, dataToSave, isEdit, editTableData);
    Navigator.pop(context);
    //resetRequestData(jsonTemplate);
  }
  addDataInRequestTable(String tableName, Map<String, String> columns) async {
    //Map<String, String> columns = new HashMap();
    columns["MDMID"] = data["CustomerId"];
    columns["isSaved"] = "No";
    print("columns : ${columns}");

//    if (isEdit) {
//      List<dynamic> params = [];
//      String query = "UPDATE ${tableName} SET ";
//      columns.forEach((k, v) {
//        if (k != "MDMID") {
//          query = query + "${k}=?, ";
//          params.add(v.toString());
//        }
//      });
//
//      query = query.substring(0, query.length - 2);
//
//      query = query +
//          " WHERE MDMID=? AND Uniqueid=?";
//      params.add(data["CustomerId"]);
//      params.add(editTableData["Uniqueid"]);
//
//      print("update query : ${query}");
//      print("update parms : ${params}");
//
//      var res =
//      await DBProfessionalList.prformQueryOperation(query, params);
//      print("Got the response : ${res}");
//    } else {
    var res = await DBProfessionalList.insertDataIntoTable(tableName, columns);
    print("Got the response : ${res}");
//    }
    this.setState(() {});
  }
  addDataInRequestTableEdit(String tableName, Map<String, String> columns,
      bool isEdit, var editTableData) async {
    //Map<String, String> columns = new HashMap();
    columns["MDMID"] = data["CustomerId"];
    columns["isSaved"] = "No";
    print("columns : ${columns}");

    if (isEdit) {
      List<dynamic> params = [];
      String query = "UPDATE ${tableName} SET ";
      columns.forEach((k, v) {
        if (k != "MDMID") {
          query = query + "${k}=?, ";
          params.add(v.toString());
        }
      });

      query = query.substring(0, query.length - 2);

      query = query + " WHERE MDMID=? AND Uniqueid=?";
      params.add(data["CustomerId"]);
      params.add(editTableData["Uniqueid"]);
      print("update query : ${query}");
      print("update query : ${query}");
      print("editTableData : ${editTableData}");

      var res = await DBProfessionalList.prformQueryOperation(query, params);
      print("Got the response : ${res}");
    } else {
      var res =
      await DBProfessionalList.insertDataIntoTable(tableName, columns);
      print("Got the response : ${res}");
    }
    this.setState(() {});
  }
  Future<List<dynamic>> getTableData(jsonObject) async {
    String query =
        "SELECT ${jsonObject["ColumnList"]} FROM ${jsonObject["data_table"]} WHERE ${jsonObject["UniqueIdColumn"]}=?";
    var res = await DBProfessionalList.prformQueryOperation(
        query, [data["CustomerId"]]);
    print("TableData Respose : $res");

    return res.isNotEmpty ? res : [];
  }
  List<Widget> getGridWidget(List<dynamic> imageData, String table) {
    List<Widget> listWidget = [];

    for (int i = 0; i < imageData.length; i++) {
      listWidget.add(getSingleImageItem(imageData[i], i, table));
    }

    return listWidget;
  }
  Widget getSingleImageItem(var data, int index, String table) {
    Uint8List bytes;
    if (data["IsSaved"] == "N") bytes = base64.decode(data["ThumbImageURL"]);
    return new Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
            height: Constants_data.getFontSize(context, 125),
            width: Constants_data.getFontSize(context, 125),
            decoration: BoxDecoration(
                border: Border.all(
                    color: AppColors.main_color,
                    width: Constants_data.getFontSize(context, 1))),
            //color: AppColors.black_color.withOpacity(0.5),
            margin: EdgeInsets.all(Constants_data.getFontSize(context, 10)),
            child: data["IsSaved"] == "Y"
                ? Image.network(
              "${data["ThumbImageURL"]}",
              fit: BoxFit.cover,
            )
                : Image.memory(
              bytes,
              fit: BoxFit.cover,
            )),
        Positioned(
            top: Constants_data.getFontSize(context, -7),
            bottom: 1,
            left: 1,
            right: Constants_data.getFontSize(context, -7),
            child: new Container(
                margin: EdgeInsets.all(Constants_data.getFontSize(context, 5)),
                width: double.infinity,
                child: new Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.remove_circle,
                      color: AppColors.red_color,
                      size: Constants_data.getFontSize(context, 17),
                    ),
                    onPressed: () async {
                      bool result = await showCaptureDeleteDialog();
                      if (result) {
                        if (data["IsSaved"] == "Y") {
                          Map<String, String> headers = {
                            "Content-type": "application/json"
                          };

                          print(
                              "Calling API for delete : ${"${Constants_data
                                  .baseUrl}/DeleteAccountImage?RepId=${dataUser["RepId"]}&image_id=${data["ImageId"]
                                  .toString()}"}");
                          var response = await http.delete(
                              Uri.parse(
                                  "${Constants_data
                                      .baseUrl}/DeleteAccountImage?RepId=${dataUser["RepId"]}&image_id=${data["ImageId"]
                                      .toString()}"),
                              headers: headers);

                          print(
                              "Response from DeleteAccountImage: ${response
                                  .body}");
                          var responseData = jsonDecode(response.body);

                          if (responseData["Status"] == 1) {
                            String query = "DELETE from $table WHERE ImageId=?";
                            await DBProfessionalList.prformQueryOperation(
                                query, [data["ImageId"]]);

                            this.setState(() {});
                          } else {
                            Constants_data.toastError("Error in delete image");
                          }
                        } else {
                          String query = "DELETE from $table WHERE ImageId=?";
                          await DBProfessionalList.prformQueryOperation(
                              query, [data["ImageId"]]);
                          this.setState(() {});
                        }
                      }
                    },
                  ),
                )))
      ],
    );
  }
  Future<bool> showCaptureDeleteDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SimpleDialog(
                  title: Text("Delete Image"),
                  contentPadding:
                  EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
                  children: <Widget>[
                    Container(
                      margin:
                      EdgeInsets.only(top: 25, bottom: 10, left: 25, right: 25),
                      child:
                      Text("Are you Sure, Do you want to delete this image?"),
                    ),
                    Container(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            SimpleDialogOption(
                              onPressed: () {
                                Navigator.pop(context, 0);
                              },
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    'NO',
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                            SimpleDialogOption(
                              onPressed: () async {
                                Navigator.pop(context, 1);
                              },
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    'YES',
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ],
                        )),
                  ],
                );
              });
        })) {
      case 0:
        return false;
        break;
      case 1:
        return true;
        break;
    }
    return false;
  }
  Future<List<dynamic>> getCaptureData(String table) async {
    List<dynamic> data = [];
    data = await DBProfessionalList.prformQueryOperation(
        "SELECT * from $table WHERE AccountId=?", [this.data["CustomerId"]]);
    print("************ Capture data : ${data}");
    return data;
  }
  Future<Null> openDialogMobileNumber() async {
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SimpleDialog(
                  contentPadding:
                  EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(0.0),
                      padding: EdgeInsets.only(bottom: 25.0, top: 25.0),
                      child: Column(
                        children: <Widget>[
                          Container(
                              margin: EdgeInsets.only(bottom: 25.0),
                              child: Text(
                                'Uploading Image',
                                style: TextStyle(
                                    color: AppColors.main_color,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              )),
                          Container(
                            child: CircularProgressIndicator(),
                            margin: EdgeInsets.only(bottom: 25.0),
                          ),
                          Container(
                              child: Text(
                                'Please wait...',
                                style: TextStyle(
                                    color: AppColors.black_color,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              )),
                        ],
                      ),
                    ),
                  ],
                );
              });
        });
  }
  String docNo;
  final String _baseprofileUrl = Constants_data.profileUrl;
  createViewFromTemplateJson(List<dynamic> jsonTemplate,
      Map<String, String> jsonData, Map<String, String> categotyCode, index,List<Map<String, String>>listCoreFGO ) {
    List<Widget> col = [];
    List<Widget> col1 = [];
    int count = 0;
    for (int i = 0; i < jsonTemplate.length; i++) {
      if (jsonTemplate[i][0]["widget_type"] == "Table" && jsonTemplate[i][0]["widget_id"] == "Product") {
        var jsonObject = jsonTemplate[i][0];
        Widget vi;
        String viewdoc = listCoreFGO[0]["invoice_path"];
        String doc = "$_baseprofileUrl/content/Invoices/$viewdoc";

        // Check if jsonData is null or empty
        if (listCoreFGO == null || listCoreFGO.isEmpty) {
          vi = Center(
            child: Text("Data not available"),
          );
        }
        else if (jsonObject != null && jsonObject.length > 0) {
          //  GetDoctorDetailsForApproval(doctorCode: listCoreFGO[0]["doctor_code"]);
          vi = StatefulBuilder(builder: (context, state) {
                bool showApprovalButtons = (Constants_data.app_user["designation_group_code"] != "MR" &&
                    ((listCoreFGO[0]["level1_approved_by"] == Constants_data.repId && listCoreFGO[0]["level1_approved"] == "N") ||
                        (listCoreFGO[0]["Is_level2_approval_required"] == "Y" &&
                            listCoreFGO[0]["level2_approved_by"] == Constants_data.repId &&
                            listCoreFGO[0]["level1_approved"] == "Y" &&
                            listCoreFGO[0]["level2_approved"] == "N")));
                //double containerHeight = showApprovalButtons ? MediaQuery.of(context).size.height - 435 : MediaQuery.of(context).size.height - 240;

                // Check if invoice is uploaded
                bool isInvoiceUploaded = listCoreFGO[0]["is_invoice_uploaded"] == "Y";
                double containerHeight;
                if (isInvoiceUploaded) {
                  containerHeight = MediaQuery.of(context).size.height - 340;
                }
                else if (showApprovalButtons) {
                  containerHeight = MediaQuery.of(context).size.height - 478;
                }
                else {
                  containerHeight = MediaQuery.of(context).size.height - 240;
                }
                return Column(
                  children: [
                    if (Constants_data.app_user["designation_group_code"] != "MR" &&
                        ((listCoreFGO[0]["level1_approved_by"] == Constants_data.repId && listCoreFGO[0]["level1_approved"] == "N") ||
                            (listCoreFGO[0]["Is_level2_approval_required"] == "Y" &&
                                listCoreFGO[0]["level2_approved_by"] == Constants_data.repId &&
                                listCoreFGO[0]["level1_approved"] == "Y" &&
                                listCoreFGO[0]["level2_approved"] == "N"))) ...[
                      Container(
                        decoration:  BoxDecoration(
                            color: themeData.cardColor,
                            ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Supply Through", style: TextStyle(fontWeight: FontWeight.bold)),
                                      SizedBox(height: 5),
                                      Text(filteredData["supply_through"] ?? "N/A",
                                          style: TextStyle(
                                          fontWeight: FontWeight.w500, // Bold text
                                          color: Colors.grey[850], // Black color
                                        ),
                                        ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Rep Name", style: TextStyle(fontWeight: FontWeight.bold)),
                                      SizedBox(height: 5),
                                      Text(filteredData["repnam"] ?? "N/A",
                                          style: TextStyle(
                                          fontWeight: FontWeight.w500, // Bold text
                                          color: Colors.grey[850], // Black color
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10), // Add space between rows
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Total Doctor Limit", style: TextStyle(fontWeight: FontWeight.bold)),
                                      SizedBox(height: 5),
                                      Text(filteredData["totaldoctorlimit"] ?? "N/A",
                              style: TextStyle(
                                          fontWeight: FontWeight.w500, // Bold text
                                          color: Colors.grey[850], // Black color
                                        ),
                            ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Consumed Doctor Limit", style: TextStyle(fontWeight: FontWeight.bold)),
                                      SizedBox(height: 5),
                                      Text(filteredData["consumeddoctorlimit"]?.toString() ?? "N/A",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500, // Bold text
                                          color: Colors.grey[850], // Black color
                                        ),

                                        ),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10), // Add space between rows
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Total State Limit", style: TextStyle(fontWeight: FontWeight.bold)),
                                      SizedBox(height: 5),
                                      Text(filteredData["totalstatelimit"] ?? "N/A",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500, // Bold text
                                          color: Colors.grey[850], // Black color
                                        ),),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Consumed State Limit", style: TextStyle(fontWeight: FontWeight.bold)),
                                      SizedBox(height: 5),
                                      Text(
                                        filteredData["consumedstatelimit"]?.toString() ?? "N/A",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500, // Bold text
                                          color: Colors.grey[850], // Black color
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Available State Limit", style: TextStyle(fontWeight: FontWeight.bold)),
                                      SizedBox(height: 5),
                                      Text(filteredData["availablestatelimit"] ?? "N/A",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500, // Bold text
                                          color: Colors.grey[850], // Black color
                                        ),),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Available Doctor Limit", style: TextStyle(fontWeight: FontWeight.bold)),
                                      SizedBox(height: 5),
                                      Text(
                                        filteredData["availabledoctorlimit"]?.toString() ?? "N/A",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500, // Bold text
                                          color: Colors.grey[850], // Black color
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "View Purchase order",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      InkWell(
                                        onTap: () {
                                          // Check if the file is an image
                                          if (purchaseorder.toLowerCase().endsWith('.jpg') ||
                                              purchaseorder.toLowerCase().endsWith('.jpeg') ||
                                              purchaseorder.toLowerCase().endsWith('.png')) {
                                            setState(() {
                                              _isImageVisible =
                                              !_isImageVisible; // Toggle image visibility
                                            });
                                          } else {
                                            // Open the file in an external application for non-image files
                                            openFile(purchaseorder);
                                          }
                                        },
                                        // onTap: () {
                                        //   setState(() {
                                        //     _isImageVisible = !_isImageVisible; // Toggle image visibility
                                        //   });
                                        //
                                        //   // Open the file in an external application for non-image files
                                        //   if (!purchaseorder.endsWith('.jpg') &&
                                        //       !purchaseorder.endsWith('.jpeg') &&
                                        //       !purchaseorder.endsWith('.png')) {
                                        //     openFile(purchaseorder); // Assuming `doc` is the file URL/path
                                        //   }
                                        // },
                                        child: Text(
                                          _isImageVisible ? "Close Purchase Order" : "View Purchase Order",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blue[900],
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                      if (_isImageVisible)
                                        Container(
                                          margin: EdgeInsets.only(top: 10),
                                          child: Image.network(
                                            purchaseorder,
                                            fit: BoxFit.cover,
                                            width: double.infinity, // Adjust as needed
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(thickness: 2),
                          ],
                        ),
                      ),
                    ],
                    if ((listCoreFGO[0]["level1_approved"] == "Y" && listCoreFGO[0]["Is_level2_approval_required"] == "N" && listCoreFGO[0]["is_invoice_uploaded"] == "Y") ||
                        (listCoreFGO[0]["Is_level2_approval_required"] == "Y" && listCoreFGO[0]["level2_approved"] == "Y" && listCoreFGO[0]["level1_approved"] == "Y" &&listCoreFGO[0]["is_invoice_uploaded"] == "Y"))...[
                      Container(
                        decoration:  BoxDecoration(
                          color: themeData.cardColor,
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildRow("Invoice No", listCoreFGO[0]["invoice_no"]),
                                _buildRow("Invoice Date", listCoreFGO[0]["invoice_date"] != null
                                    ? formatDate(listCoreFGO[0]["invoice_date"])
                                    : 'N/A'),
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "View Uploaded Invoice Document",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 13,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      InkWell(
                                        onTap: () {
                                          // Check if the file is an image
                                          if (doc.toLowerCase().endsWith('.jpg') ||
                                              doc.toLowerCase().endsWith('.jpeg') ||
                                              doc.toLowerCase().endsWith('.png')) {
                                            setState(() {
                                              _isImageVisible =
                                              !_isImageVisible; // Toggle image visibility
                                            });
                                          } else {
                                            openFile(doc);
                                          }
                                        },
                                        // onTap: () {
                                        //   setState(() {
                                        //     _isImageVisible = !_isImageVisible; // Toggle image visibility
                                        //   });
                                        //
                                        //   // Open the file in an external application for non-image files
                                        //   if (!doc.endsWith('.jpg') &&
                                        //       !doc.endsWith('.jpeg') &&
                                        //       !doc.endsWith('.png')) {
                                        //     openFile(doc); // Assuming `doc` is the file URL/path
                                        //   }
                                        // },
                                        child: Text(
                                          _isImageVisible ? "Close Uploaded Invoice" : "View Uploaded Invoice",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.blue[900],
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                      if (_isImageVisible)
                                        Container(
                                          margin: EdgeInsets.only(top: 10),
                                          child: Image.network(
                                            doc,
                                            fit: BoxFit.cover,
                                            width: double.infinity, // Adjust as needed
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(thickness: 2),
                          ],
                        ),
                      ),
                  ],
                    SizedBox(height:10,),
                    Container(
                      decoration:  BoxDecoration(
                        color: themeData.cardColor,
                      ),
                      height: containerHeight,
                      //height:450,
                      //height: MediaQuery.of(context).size.height - 240,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: listCoreFGO.length,
                        itemBuilder: (context, index) {
                          final fgodata = listCoreFGO[index];
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            decoration:  BoxDecoration(
                              color: themeData.cardColor,
                            ),
                            child: Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: themeData.cardColor,
                            //  color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fgodata['item_desc'] ?? 'No Description',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Divider(thickness: 2),
                                    SizedBox(height: 5),
                                    _buildRow("Request No", fgodata['doc_no']),
                                    _buildRow("Scheme Type", fgodata['scheme_type']),
                                    if (fgodata['scheme_type'] == 'Rate Difference' || fgodata['scheme_type'] == 'Extra Scheme') ...[
                                      _buildRow("Discount On", fgodata['discount_on']),
                                      _buildRow("Discount Value", fgodata['discount_value']),
                                    ],
                                    if (fgodata['scheme_type'] == 'Extra Scheme')...[
                                      _buildRow("Inclusive/Exclusive", fgodata['inclusive_exclusive']),
                                    ],
                                    // if (fgodata['scheme_type'] == 'Fixed Rate')...[
                                    //   _buildRow("Net/Fixed Rate", fgodata['net_fixedrate']),
                                    // ],
                                    if (fgodata['scheme_type'] == 'Trade Discount') ...[
                                      _buildRow("Discount Value", fgodata['discount_value']),
                                    ],
                                    _buildRow("Quantity", fgodata['quantity']),
                                    _buildRow("FGO Value", fgodata['fgo_value']),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                          decoration:  BoxDecoration(
                          color: themeData.cardColor,
                        ),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if ((listCoreFGO[0]["level1_approved"] == "Y" && listCoreFGO[0]["Is_level2_approval_required"] == "N") ||
                                (listCoreFGO[0]["Is_level2_approval_required"] == "Y" &&
                                    listCoreFGO[0]["level2_approved"] == "Y" &&
                                    listCoreFGO[0]["level1_approved"] == "Y")) ...[

                              if (loadingForsendmail) ...[
                                Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              ] else ...[
                                MaterialButton(
                                  onPressed: () async {
                                    loadingForsendmail = true;
                                    state(() {});  // Rebuild UI
                                    await sendemail();
                                  },
                                  color: Colors.blue,
                                  textColor: Colors.white,
                                  child: Text("Send Mail"),
                                ),
                              ],
                              SizedBox(width: 20),
                              // Conditionally show "Invoice" button only if `is_invoice_uploaded` is not "Y"
                              if (listCoreFGO[0]["is_invoice_uploaded"] != "Y") ...[
                                MaterialButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => InvoiceUploadScreen(),
                                        settings: RouteSettings(
                                          arguments: {
                                            "account_type": accountType,
                                            "doctor_docNo": Constants_data.customerid,
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  color: Colors.green,
                                  textColor: Colors.white,
                                  child: Text("Invoice"),
                                ),
                              ],
                            ],
                            // if ((listCoreFGO[0]["level1_approved"] == "Y" && listCoreFGO[0]["Is_level2_approval_required"] == "N") ||
                            //     (listCoreFGO[0]["Is_level2_approval_required"] == "Y" && listCoreFGO[0]["level2_approved"] == "Y" && listCoreFGO[0]["level1_approved"] == "Y")) ...[
                            //   if (loadingForsendmail) ...[
                            //     Center(
                            //       child: SizedBox(
                            //         width: 20,
                            //         height: 20,
                            //         child: CircularProgressIndicator(),
                            //       ),
                            //     )
                            //   ] else ...[
                            //     MaterialButton(
                            //       onPressed: () async {
                            //         loadingForsendmail = true;
                            //         state(() {});
                            //         await sendemail();
                            //       },
                            //       color: Colors.blue,
                            //       textColor: Colors.white,
                            //       child: Text("Send Mail"),
                            //     ),
                            //   ],
                            //   SizedBox(width: 20),
                            //   MaterialButton(
                            //     onPressed: () {
                            //       Navigator.pushReplacement(
                            //         context,
                            //         MaterialPageRoute(
                            //           builder: (context) => InvoiceUploadScreen(),
                            //           settings: RouteSettings(
                            //             arguments: {
                            //               "account_type": accountType,
                            //               "doctor_docNo": Constants_data.customerid,
                            //             },
                            //           ),
                            //         ),
                            //       );
                            //     },
                            //     color: Colors.green,
                            //     textColor: Colors.white,
                            //     child: Text("Invoice"),
                            //   ),
                            // ],
                            if (Constants_data.app_user["designation_group_code"] != "MR" &&
                                ((listCoreFGO[0]["level1_approved_by"] == Constants_data.repId && listCoreFGO[0]["level1_approved"] == "N") ||
                                    (listCoreFGO[0]["Is_level2_approval_required"] == "Y" &&
                                        listCoreFGO[0]["level2_approved_by"] == Constants_data.repId &&
                                        listCoreFGO[0]["level1_approved"] == "Y" &&
                                        listCoreFGO[0]["level2_approved"] == "N"))) ...[
                              MaterialButton(
                                onPressed: () async {
                                  await addComment();
                                },
                                color: Colors.blue,
                                textColor: Colors.white,
                                child: Text("Add Comment"),
                              ),
                              SizedBox(width: 20),
                              if (loadingForApproval) ...[
                                Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              ] else ...[
                                MaterialButton(
                                  onPressed: () async {
                                    loadingForApproval = true;
                                    state(() {});
                                    await approveFGO(listCoreFGO);
                                    state(() {});
                                  },
                                  color: Colors.blue,
                                  textColor: Colors.white,
                                  child: Text("Approve"),
                                ),
                              ],
                              SizedBox(width: 20),
                              if (loadingForReject) ...[
                                Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              ]
                              else ...[
                                MaterialButton(
                                  onPressed: () async {
                                    loadingForReject = true;
                                    state(() {});
                                    await rejectFGOapproval(listCoreFGO);
                                    state(() {});
                                  },
                                  color: Colors.blue,
                                  textColor: Colors.white,
                                  child: Text("Reject"),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                );
              },);
                // StatefulBuilder(builder: (context, state) {
          //       return  Column(
          //         children: [
          //           Container(
          //             height: MediaQuery.of(context).size.height - 240,
          //             child: ListView.builder(
          //               padding: EdgeInsets.zero,
          //               itemCount: listCoreFGO.length,
          //               itemBuilder: (context, index) {
          //                 final fgodata = listCoreFGO[index];
          //                 return Container(
          //                   width: MediaQuery.of(context).size.width,
          //                   child: Card(
          //                     elevation: 8,
          //                     shape: RoundedRectangleBorder(
          //                       borderRadius: BorderRadius.circular(15),
          //                     ),
          //                     color: Colors.white,
          //                     child: Padding(
          //                       padding: EdgeInsets.all(10),
          //                       child: Column(
          //                         crossAxisAlignment: CrossAxisAlignment.start,
          //                         children: [
          //                           Text(
          //                             fgodata['item_desc'] ?? 'No Description',
          //                             style: TextStyle(
          //                               fontSize: 16,
          //                               fontWeight: FontWeight.bold,
          //                               color: Colors.blue,
          //                             ),
          //                           ),
          //                           Divider(thickness: 2),
          //                           SizedBox(height: 5), // Space after title
          //                           _buildRow("Request No", fgodata['doc_no']),
          //                           _buildRow("Scheme Type", fgodata['scheme_type']),
          //                           _buildRow("Quantity", fgodata['quantity']),
          //                           if (fgodata['scheme_type'] == 'Extra Scheme' ||
          //                               fgodata['scheme_type'] == 'Free Goods') ...[
          //                             _buildRow("Discount On", fgodata['discount_on']),
          //                             _buildRow("Discount Value", fgodata['discount_value']),
          //                           ],
          //                           if (fgodata['scheme_type'] == 'Rate Difference') ...[
          //                             _buildRow("Discount Value", fgodata['discount_value']),
          //                           ],
          //                           if (fgodata['scheme_type'] == 'Free Goods') ...[
          //                             // Additional fields for Free Goods, if any
          //                           ],
          //                           _buildRow("FGO Value", fgodata['fgo_value']),
          //                           // _buildRow("Approval Status", fgodata['is_approved'] == 'Y' ? 'Approved' : 'Not Approved'),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 );
          //               },
          //             ),
          //           ),
          //           // if((listCoreFGO[0]["level1_approved_by"] == Constants_data.repId && listCoreFGO[0]["level1_approved"] == "N") ||
          //           //     (listCoreFGO[0]["level2_approved_by"] == Constants_data.repId && listCoreFGO[0]["level2_approved"] == "N" && listCoreFGO[0]["Is_level2_approval_required"] == "Y")) ...[
          //           //   Padding(
          //           //   padding: const EdgeInsets.all(8.0),
          //           //   child: Container(
          //           //     width: MediaQuery.of(context).size.width,
          //           //     child:  Row(
          //           //         crossAxisAlignment: CrossAxisAlignment.center,
          //           //         mainAxisAlignment: MainAxisAlignment.center,
          //           //         children : [
          //           //
          //           //           MaterialButton(
          //           //             onPressed: () async {
          //           //               await addComment();
          //           //             },
          //           //             color: Colors.blue,
          //           //             textColor: Colors.white,
          //           //             child: Text("Add Comment"),
          //           //           ),
          //           //           SizedBox(width: 20),
          //           //           MaterialButton(
          //           //             onPressed: () async {
          //           //             },
          //           //             color: Colors.blue,
          //           //             textColor: Colors.white,
          //           //             child: Text("View Comment"),
          //           //           )
          //           //
          //           //         ]
          //           //     ),
          //           //   ),
          //           // ),
          //           // ],
          //           //
          //           Padding(
          //             padding: const EdgeInsets.all(8.0),
          //             child: Container(
          //               width: MediaQuery.of(context).size.width,
          //               child: Row(
          //                 crossAxisAlignment: CrossAxisAlignment.center,
          //                 mainAxisAlignment: MainAxisAlignment.center,
          //                 children: [
          //                   if((listCoreFGO[0]["level1_approved"] == "Y" && listCoreFGO[0]["Is_level2_approval_required"] == "N") || (listCoreFGO[0]["Is_level2_approval_required"] == "Y" && listCoreFGO[0]["level2_approved"] == "Y" && listCoreFGO[0]["level1_approved"] == "Y")) ...[
          //                     if (loadingForsendmail) ...[
          //                       // return const CircularProgressIndicator();
          //                       Center(
          //                         child: SizedBox(
          //                             width: 20,
          //                             height: 20,
          //                             child: CircularProgressIndicator()),
          //                       )
          //                     ]
          //
          //                  else ...[
          //                     MaterialButton(
          //                       onPressed: () async {
          //                         loadingForsendmail = true;
          //                         state((){});
          //                         await sendemail();
          //                       },
          //                       color: Colors.blue,
          //                       textColor: Colors.white,
          //                       child: Text("Send Mail"),
          //                     ),
          //                     ],
          //                     SizedBox(width: 20,), // Add space between buttons
          //                     MaterialButton(
          //                       onPressed: () {
          //                         Navigator.pushReplacement(
          //                           context,
          //                           MaterialPageRoute(
          //                             builder: (context) => InvoiceUploadScreen(),
          //                             settings: RouteSettings(
          //                               arguments: {
          //                                 "account_type": accountType,
          //                                 // Replace with the actual accountType value
          //                                 "doctor_docNo": Constants_data
          //                                     .customerid,
          //                                 // Pass customer ID from Constants_data
          //                               },
          //                             ),
          //                           ),
          //                         );
          //                       },
          //                       color: Colors.green,
          //                       textColor: Colors.white,
          //                       child: Text("Invoice"),
          //                     ),
          //                   ],
          //
          //                   //             if(Constants_data.app_user["designation_group_code"] == "MR" && (listCoreFGO[0]["level1_approved"] == "Y" || listCoreFGO[0]["level2_approved"] == "Y")) ...[
          //                   //               MaterialButton(
          //                   //                 onPressed: () async {
          //                   //                   await sendemail();
          //                   //                 },
          //                   //                 color: Colors.blue,
          //                   //                 textColor: Colors.white,
          //                   //                 child: Text("Send Mail"),
          //                   //               ),
          //                   //
          //                   //               SizedBox(width: 20,), // Add space between buttons
          //                   //               MaterialButton(
          //                   //                 onPressed: () {
          //                   //                   Navigator.pushReplacement(
          //                   //                     context,
          //                   //                     MaterialPageRoute(
          //                   //                       builder: (context) => InvoiceUploadScreen(),
          //                   //                       settings: RouteSettings(
          //                   //                         arguments: {
          //                   //                           "account_type": accountType,
          //                   //                           // Replace with the actual accountType value
          //                   //                           "doctor_docNo": Constants_data
          //                   //                               .customerid,
          //                   //                           // Pass customer ID from Constants_data
          //                   //                         },
          //                   //                       ),
          //                   //                     ),
          //                   //                   );
          //                   //                 },
          //                   //                 color: Colors.green,
          //                   //                 textColor: Colors.white,
          //                   //                 child: Text("Invoice"),
          //                   //               ),
          //                   //
          //                   //             ]
          //                   //             else if((listCoreFGO[0]["level1_approved"] == "Y" && listCoreFGO[0]["level1_approved_by"] == Constants_data.repId) || (listCoreFGO[0]["level2_approved"] == "Y" && listCoreFGO[0]["level2_approved_by"] == Constants_data.repId)) ...[
          //                   //               MaterialButton(
          //                   //                 onPressed: () async {
          //                   //                   await sendemail();
          //                   //                 },
          //                   //                 color: Colors.blue,
          //                   //                 textColor: Colors.white,
          //                   //                 child: Text("Send Mail"),
          //                   //               ),
          //                   //
          //                   //               SizedBox(width: 20,), // Add space between buttons
          //                   //               MaterialButton(
          //                   //                 onPressed: () {
          //                   //                   Navigator.pushReplacement(
          //                   //                     context,
          //                   //                     MaterialPageRoute(
          //                   //                       builder: (context) => InvoiceUploadScreen(),
          //                   //                       settings: RouteSettings(
          //                   //                         arguments: {
          //                   //                           "account_type": accountType,
          //                   //                           // Replace with the actual accountType value
          //                   //                           "doctor_docNo": Constants_data
          //                   //                               .customerid,
          //                   //                           // Pass customer ID from Constants_data
          //                   //                         },
          //                   //                       ),
          //                   //                     ),
          //                   //                   );
          //                   //                 },
          //                   //                 color: Colors.green,
          //                   //                 textColor: Colors.white,
          //                   //                 child: Text("Invoice"),
          //                   //               ),
          //                   // ],
          //
          //
          //
          //                   // if ((!(listCoreFGO[0]["level1_approved"] == "N" && listCoreFGO[0]["level2_approved"] == "N")) || (listCoreFGO[0]["level1_approved"] == "Y" && (Constants_data.app_user["designation_group_code"] == "MR" || listCoreFGO[0]["level1_approved_by"] == Constants_data.repId)))...[
          //                   //
          //                   //   MaterialButton(
          //                   //     onPressed: () async {
          //                   //       await sendemail();
          //                   //     },
          //                   //     color: Colors.blue,
          //                   //     textColor: Colors.white,
          //                   //     child: Text("Send Mail"),
          //                   //   ),
          //                   //
          //                   //   SizedBox(width: 20,), // Add space between buttons
          //                   //   MaterialButton(
          //                   //     onPressed: () {
          //                   //       Navigator.pushReplacement(
          //                   //         context,
          //                   //         MaterialPageRoute(
          //                   //           builder: (context) => InvoiceUploadScreen(),
          //                   //           settings: RouteSettings(
          //                   //             arguments: {
          //                   //               "account_type": accountType,
          //                   //               // Replace with the actual accountType value
          //                   //               "doctor_docNo": Constants_data
          //                   //                   .customerid,
          //                   //               // Pass customer ID from Constants_data
          //                   //             },
          //                   //           ),
          //                   //         ),
          //                   //       );
          //                   //     },
          //                   //     color: Colors.green,
          //                   //     textColor: Colors.white,
          //                   //     child: Text("Invoice"),
          //                   //   ),
          //                   //
          //                   // ],
          //
          //                   if(Constants_data.app_user["designation_group_code"] != "MR") ...[
          //                     if((listCoreFGO[0]["level1_approved_by"] == Constants_data.repId && listCoreFGO[0]["level1_approved"] == "N") ||
          //                         (listCoreFGO[0]["Is_level2_approval_required"] == "Y" && listCoreFGO[0]["level2_approved_by"] == Constants_data.repId && listCoreFGO[0]["level1_approved"] == "Y" && listCoreFGO[0]["level2_approved"] == "N")) ...[
          //                       if (loadingForApproval) ...[
          //                         // return const CircularProgressIndicator();
          //                         Center(
          //                           child: SizedBox(
          //                               width: 20,
          //                               height: 20,
          //                               child: CircularProgressIndicator()),
          //                         )
          //                       ]
          //                       else ...[
          //                         MaterialButton(
          //                           onPressed: () async {
          //                             loadingForApproval = true;
          //                             state((){});
          //                             await approveFGO(listCoreFGO);
          //                             state((){});
          //                           },
          //                           color: Colors.blue,
          //                           textColor: Colors.white,
          //                           child: Text("Approve"),
          //                         ),
          //                       ],
          //                       SizedBox(width: 30,),
          //                       MaterialButton(
          //                         onPressed: () async {
          //                           await addComment();
          //                         },
          //                         color: Colors.blue,
          //                         textColor: Colors.white,
          //                         child: Text("Add Comment"),
          //                       ),
          //                     ]
          //                   ]
          //                 ],
          //               ),
          //             ),
          //           ),
          //           SizedBox(height:10),
          //         ],
          //       );
          //     },);
        }
        else {
          vi = Center(
            child: Text("Data not available"),
          );
        }
        col.add(vi);
      }
      else if (jsonTemplate[i][0]["widget_type"] == "Capture") {
        Widget vi = FutureBuilder<dynamic>(
          future: getCaptureData(jsonTemplate[i][0]["data_table"].toString()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              List<dynamic> imageData = snapshot.data;
              double cardHeight = Constants_data.getFontSize(context, 475);
              if (imageData.length == 0) {
                cardHeight = Constants_data.getFontSize(context, 50);
              } else if (imageData.length <= 3) {
                cardHeight = Constants_data.getFontSize(context, 200);
              } else if (imageData.length <= 6) {
                cardHeight = Constants_data.getFontSize(context, 320);
              }
              return Container(
                  height: cardHeight,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(
                            Constants_data.getFontSize(context, 5)),
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: () async {
                              var image = await ImagePicker().pickImage(
                                  source: ImageSource.camera);
                              File file = File(image.path);
                              file = await Constants_data.rotationChange(image);
                              if (image != null) {
                                openDialogMobileNumber();
                                // final bytes = image.readAsBytes();
                                File file = File(image.path);
                                final bytes = file.readAsBytesSync();
                                // final bytes = image.readAsBytes();
                                String img64 = base64Encode(bytes);
                                // String img64 = base64Encode(bytes as List<int>);
                                String uuid = Constants_data.getUUID();
                                bool isNetworkAvailable = await Constants_data
                                    .checkNetworkConnectivity();

                                if (isNetworkAvailable) {
                                  Map<String, dynamic> map = new HashMap();
                                  map["AccountId"] =
                                      this.data["CustomerId"].toString();
                                  map["AccountType"] = accountType;
                                  map["ImageId"] = uuid;
                                  map["ImageName"] = DateTime
                                      .now()
                                      .millisecondsSinceEpoch
                                      .toString();
                                  map["Base64"] = img64;

                                  try {
                                    String url =
                                        "/UploadAccountImage?RepId=${dataUser["RepId"]}";
                                    var data =
                                    await _helper.post(url, map, true);

                                    if (data["Status"] == 1) {
                                      var resData =
                                      data["dt_ReturnedTables"][0][0];
                                      await DBProfessionalList
                                          .prformQueryOperation(
                                          "INSERT INTO ${jsonTemplate[i][0]["data_table"]
                                              .toString()} (AccountId,AccountType,ImageId,ImageURL,ThumbImageURL,IsSaved) VALUES (?,?,?,?,?,?)",
                                          [
                                            resData["AccountId"],
                                            resData["AccountType"],
                                            resData["ImageId"],
                                            resData["ImageURL"],
                                            resData["ThumbImageURL"],
                                            resData["IsSaved"]
                                          ]);
                                      getCaptureData(
                                          jsonTemplate[i][0]["data_table"]
                                              .toString());
                                    } else {
                                      Constants_data.toastError(
                                          "Error in image upload");
                                    }
                                  } on Exception catch (err) {
                                    print("Error in UploadAccountImage : $err");
                                    Constants_data.toastError("$err");
                                  }
                                } else {
                                  Constants_data.toastError(
                                      "Internet is not available");
                                }
                                Navigator.pop(context);

                                //print("-------------- Base64Stirng: ${img64}");

//                              String query =
//                                  "INSERT INTO ${jsonTemplate[i][0]["data_table"].toString()} (AccountId,AccountType,ImageId,ImageURL,ThumbImageURL,created_by,created_date,IsSaved) VALUES (?,?,?,?,?,?,?,?)";
//                              await DBProfessionalList.prformQueryOperation(
//                                  query, [
//                                data["CustomerId"],
//                                accountType,
//                                uuid,
//                                img64,
//                                img64,
//                                "sandip",
//                                Constants_data.dateToString(
//                                    DateTime.now(), "dd/MM/yyyy hh:mm:ss a"),
//                                "N"
//                              ]);
                                this.setState(() {});
                              }
                            },
                            icon: Icon(
                              Icons.camera_enhance,
                              color: AppColors.main_color,
                              size: Constants_data.getFontSize(context, 25),
                            )),
                      ),
                      Expanded(
                          child: Container(
                              height: Constants_data.getFontSize(context, 300),
                              child: Card(
                                  elevation: 5,
                                  margin: EdgeInsets.all(
                                      Constants_data.getFontSize(context, 5)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0.0),
                                  ),
                                  child: Container(
                                      child: GridView.count(
                                          primary: false,
                                          padding: EdgeInsets.all(
                                              Constants_data.getFontSize(
                                                  context, 10)),
                                          crossAxisSpacing: 5,
                                          mainAxisSpacing: 5,
                                          crossAxisCount: 3,
                                          children: getGridWidget(
                                              snapshot.data,
                                              jsonTemplate[i][0]["data_table"]
                                                  .toString()))))))
                    ],
                  ));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        );
        col.add(vi);
//        return
      }
      else if (jsonTemplate[i][0]["widget_type"] == "Request" && jsonTemplate[i][0]["widget_id"] == "FGORequest") {
        col.add(
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    width: double.infinity, // or a fixed width
                    padding: EdgeInsets.all(10),
                    child: FutureBuilder(
                      future: GetDoctorDetailsForApproval(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.data != null && snapshot.data.length > 0) {
                            showGetDoctorDetailsForApproval = [];
                            return getView();
                          }
                          else if (snapshot.data == null) {
                            return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      //Padding(padding: EdgeInsets.zero),
                                      padding: EdgeInsets.only(top:0,),
                                      child: MaterialButton(
                                        onPressed: () async {
                                          await getProductNames();
                                          // setState((){});
                                        },
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: Colors.blue,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                        child: Text(
                                          "Select Product",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 30),
                                      child: new Text("Data not available"),
                                    ),
                                  ],
                                ));
                          }
                          else {
                            return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Container(
                                      margin: EdgeInsets.only(top: 10),
                                      child: new Text("Data not available"),
                                    )
                                  ],
                                ));
                          }
                        }
                        else if (snapshot.connectionState == ConnectionState.waiting) {
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
                        }
                        else {
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
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      else if (jsonTemplate[i][0]["widget_type"] == "Graph") {
        var data = jsonTemplate[i][0];
        if (data["graph_type"] == "multiColumn") {
          String tableName = data["data_table"];
          String condition = data["condition"];
          data["isShowTitle"] = "Y";
          Widget vi = FutureBuilder<List<dynamic>>(
              future: getListDataFromTable(tableName, condition),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data != null && snapshot.data.length > 0) {
                    return new Container(
                        child: new Card(
                            elevation: 5,
                            margin: EdgeInsets.all(5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                            child: MultiColumnChartWidget(
                                templateJson: data, listData: snapshot.data)
                          // MulticolumnChart(data, snapshot.data)
                          // SfCartesianChart(
                          //     legend: Legend(isVisible: true, position: LegendPosition.bottom),
                          //     plotAreaBorderWidth: 0,
                          //     enableSideBySideSeriesPlacement: false,
                          //     zoomPanBehavior: ZoomPanBehavior(
                          //       enableDoubleTapZooming: true,
                          //       enablePanning: true,
                          //       enablePinching: true,
                          //       enableSelectionZooming: true,
                          //     ),
                          //     title: ChartTitle(textStyle: TextStyle(fontSize: 10), text: data["title"]),
                          //     primaryXAxis: CategoryAxis(
                          //       labelStyle: TextStyle(fontSize: 9, color: AppColors.black_color),
                          //       majorGridLines: MajorGridLines(width: 0),
                          //     ),
                          //     primaryYAxis: NumericAxis(
                          //         labelStyle: TextStyle(fontSize: 9, color: AppColors.black_color),
                          //         majorTickLines: MajorTickLines(size: 0),
                          //         numberFormat: NumberFormat.compact(),
                          //         majorGridLines: MajorGridLines(width: 0)),
                          //     series: getBackToBackColumn(xAxis, columns, snapshot.data),
                          //     tooltipBehavior: TooltipBehavior(enable: true)),
                        ));
                  }
                  else if (snapshot.data == null) {
                    return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Container(
                              margin: EdgeInsets.only(top: 10),
                              child: new Text("Data not available"),
                            )
                          ],
                        ));
                  }
                  else {
                    return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Container(
                              margin: EdgeInsets.only(top: 10),
                              child: new Text("Data not available"),
                            )
                          ],
                        ));
                  }
                }
                else if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
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
                }
                else {
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
              });
          col.add(vi);
        }
        else if (data["graph_type"] == "line") {
          String tableName = data["data_table"];
          String condition = data["condition"];
          data["isShowTitle"] = "Y";
          Widget vi = FutureBuilder<List<dynamic>>(
              future: getListDataFromTable(tableName, condition),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data != null && snapshot.data.length > 0) {
                    print("Data line chart: ${jsonEncode(data)}");

                    return new Container(
                        child: new Card(
                          elevation: 5,
                          margin: EdgeInsets.all(5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                          child: LineChartWidget(
                            templateJson: data,
                            listData: snapshot.data,
                            onItemClick: (item, index) {
                              print("pointIndex ({$index}) : ${item}");
                            },
                          ),
                          // child: LineChart(data, snapshot.data, false)
//                       SfCartesianChart(
//                           title: ChartTitle(text: data["title"].toString()),
//                           tooltipBehavior: TooltipBehavior(enable: true),
//                           zoomPanBehavior: ZoomPanBehavior(
//                             // Performs zooming on double tap
// //                              enableSelectionZooming: true,
//                             enableDoubleTapZooming: true,
//                             enablePanning: true,
//                             enablePinching: true,
//                             enableSelectionZooming: true,
//
//                             selectionRectBorderColor: AppColors.red_color,
//                             selectionRectBorderWidth: 1,
//                             selectionRectColor: AppColors.grey_color,
//                           ),
//                           legend: Legend(isVisible: true, position: LegendPosition.bottom),
//                           primaryXAxis: CategoryAxis(),
//                           crosshairBehavior: CrosshairBehavior(enable: true),
//                           series: data["isTrendLine"] == "Y" && snapshot.data.length > 1
//                               ? <ChartSeries>[
//                                   SplineSeries<SalesData, String>(
//                                       dataSource: getDataSourceLineChart(xAxis, columns, snapshot.data),
//                                       xValueMapper: (SalesData sales, _) => sales.year,
//                                       yValueMapper: (SalesData sales, _) => sales.sales,
//                                       dataLabelSettings: DataLabelSettings(isVisible: false),
//                                       animationDuration: 1500,
//                                       name: data["title"].toString(),
//                                       enableTooltip: true,
//                                       trendlines: <Trendline>[
//                                         Trendline(type: trendLine, color: Constants_data.hexToColor("#ff6060"))
//                                       ])
//                                 ]
//                               : <ChartSeries>[
//                                   LineSeries<SalesData, String>(
//                                       legendItemText: columns,
//                                       dataSource: getDataSourceLineChart(xAxis, columns, snapshot.data),
//                                       xValueMapper: (SalesData sales, _) => sales.year,
//                                       yValueMapper: (SalesData sales, _) => sales.sales,
//                                       name: data["title"].toString(),
//                                       dataLabelSettings: DataLabelSettings(isVisible: false))
//                                 ]),
                        ));
                  } else if (snapshot.data == null) {
                    return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Container(
                              margin: EdgeInsets.only(top: 10),
                              child: new Text("Data not available"),
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
                              child: new Text("Data not available"),
                            )
                          ],
                        ));
                  }
                } else
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
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
              });
          col.add(vi);
        }
        else if (data["graph_type"] == "Redial") {
          String tableName = data["data_table"];
          String condition = data["condition"];
          data["isShowTitle"] = "Y";
          Widget vi = FutureBuilder<List<dynamic>>(
              future: getListDataFromTable(tableName, condition),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data != null && snapshot.data.length > 0) {
                    return new Container(
                        height: 450,
                        child: new Card(
                            elevation: 5,
                            margin: EdgeInsets.all(5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                            child: RadialChartWidget(
                                templateJson: data, listData: snapshot.data)
//                           SfCircularChart(
//                               // Initialize category axis
//                               title: ChartTitle(text: data["title"].toString()),
//                               tooltipBehavior: TooltipBehavior(enable: true, format: 'point.x'),
//                               legend: Legend(
//                                   textStyle: TextStyle(color: themeData.textTheme.caption.color),
//                                   isVisible: true,
//                                   iconHeight: 20,"
//                                   iconWidth: 20,
//                                   overflowMode: LegendItemOverflowMode.wrap),
//                               series: <RadialBarSeries<RedialChartSampleData, String>>[
//                                 RadialBarSeries<RedialChartSampleData, String>(
//                                     animationDuration: 0,
//                                     //pointRadiusMapper: (RedialChartSampleData data, _) => data.xValue,
//                                     maximumValue: 1500000,
//                                     radius: '100%',
//                                     gap: '5%',
//                                     innerRadius: '30%',
//                                     dataSource: getDataSourceCircularChart(snapshot.data),
//                                     cornerStyle: CornerStyle.bothCurve,
//                                     xValueMapper: (RedialChartSampleData data, _) => data.x,
//                                     yValueMapper: (RedialChartSampleData data, _) => data.y,
// //                                pointColorMapper: (RedialChartSampleData data, _) => data.pointColor,
//                                     dataLabelMapper: (RedialChartSampleData data, _) => data.text,
//                                     dataLabelSettings: DataLabelSettings(isVisible: true))
//                               ]),
                        ));
                  } else if (snapshot.data == null) {
                    return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Container(
                              margin: EdgeInsets.only(top: 10),
                              child: new Text("Data not available"),
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
                              child: new Text("Data not available"),
                            )
                          ],
                        ));
                  }
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
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
              });
          col.add(vi);
        }
        else if (data["graph_type"] == "Pie") {
          String tableName = data["data_table"];
          String condition = data["condition"];
          data["isShowTitle"] = "Y";
          Widget vi = FutureBuilder<List<dynamic>>(
              future: getListDataFromTable(tableName, condition),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data != null && snapshot.data.length > 0) {
                    return new Container(
                        height: 300,
                        child: new Card(
                          elevation: 5,
                          margin: EdgeInsets.all(5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                          child: PieChartWidget(
                              templateJson: data, listData: snapshot.data),
                        ));
                  } else if (snapshot.data == null) {
                    return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Container(
                              margin: EdgeInsets.only(top: 10),
                              child: new Text("Data not available"),
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
                              child: new Text("Data not available"),
                            )
                          ],
                        ));
                  }
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
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
              });
          col.add(vi);
        }
        else if (data["graph_type"] == "barchart") {
          //TODO: Bar Chart
          String columns = data["columns"].toString();
          String xAxis = data["x_axis"].toString();
          String tableName = data["data_table"];
          String condition = data["condition"];
          data["isShowTitle"] = "Y";
          Widget vi = FutureBuilder<List<dynamic>>(
              future: getListDataFromTable(tableName, condition),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data != null && snapshot.data.length > 0) {
                    return new Container(
                        child: new Card(
                          elevation: 5,
                          margin: EdgeInsets.all(5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                          ),

                          child: BarChartWidget(
                              listData: snapshot.data, templateJson: data),
                          // BarChart(data, snapshot.data, false, false)
                          // SfCartesianChart(
                          //     tooltipBehavior: TooltipBehavior(enable: true),
                          //     plotAreaBorderWidth: 0,
                          //     legend: Legend(isVisible: true, position: LegendPosition.bottom),
                          //     primaryXAxis: CategoryAxis(
                          //       majorGridLines: MajorGridLines(width: 0),
                          //     ),
                          //     primaryYAxis: NumericAxis(
                          //         axisLine: AxisLine(width: 1),
                          //         numberFormat: NumberFormat.compact(),
                          //         majorGridLines: MajorGridLines(width: 0)),
                          //     title: ChartTitle(textStyle: TextStyle(fontSize: 10), text: data["title"]),
                          //     series: <ChartSeries>[
                          //       // Renders column chart
                          //       ColumnSeries<SalesData, String>(
                          //         borderRadius: const BorderRadius.all(Radius.circular(5)),
                          //         dataSource: getDataForBarChart(columns, snapshot.data, xAxis),
                          //         color: Constants_data.hexToColor("#1f628f"),
                          //         xValueMapper: (SalesData sales, _) => sales.year,
                          //         yValueMapper: (SalesData sales, _) => sales.sales,
                          //         animationDuration: 1500,
                          //         enableTooltip: true,
                          //         name: columns,
                          //       )
                          //     ]),
                        ));
                  } else if (snapshot.data == null) {
                    return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Container(
                              margin: EdgeInsets.only(top: 10),
                              child: new Text("Data not available"),
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
                              child: new Text("Data not available"),
                            )
                          ],
                        ));
                  }
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
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
              });
          col.add(vi);
        }
      }
      else {
        count++;
        List<Widget> row = [];
        if (jsonTemplate[i][0]["widget_type"] == "Field" &&
            jsonTemplate[i][0]["isQA"] == "Y") {
          TextInputType type = TextInputType.text;
          List<TextInputFormatter> inputFormatter = [];
          if (jsonTemplate[i][0]["inputType"] == "Phone") {
            type = TextInputType.phone;
            inputFormatter = [
              FilteringTextInputFormatter.allow(RegExp('[0-9+]')),
            ];
          }
          else if (jsonTemplate[i][0]["inputType"] == "Email") {
            type = TextInputType.emailAddress;
          }
          else {
            type = TextInputType.text;
          }
          final myController = TextEditingController();
          row.add(new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                  jsonTemplate[i][0]["label"] != null
                      ? '⦿ ' + jsonTemplate[i][0]["label"]
                      : "N/A",
                  textAlign: TextAlign.start,
                  style:
                  new TextStyle(color: themeData.textTheme.caption.color)),
              new Container(
                height: 30.0,
                width: MediaQuery
                    .of(context)
                    .size
                    .width - 40,
                child: new TextField(
                  onEditingComplete: () async {
                    FocusScope.of(context).unfocus();
                    List<dynamic> checkDataAvailability =
                    await DBProfessionalList.prformQueryOperation(
                        "SELECT * from tblAccountListAttributesChanges WHERE CustomerId=? AND AccountType=? AND CategoryCode=? AND AttributeCode=?",
                        [
                          data["CustomerId"],
                          accountType,
                          listCategoryCode[jsonTemplate[i][0]["widget_id"]],
                          jsonTemplate[i][0]["widget_id"]
                        ]);

                    print("checkDataAvailability : ${checkDataAvailability}");

                    if (checkDataAvailability.length != 0) {
                      await DBProfessionalList.prformQueryOperation(
                          "DELETE from tblAccountListAttributesChanges WHERE CustomerId=? AND AccountType=? AND CategoryCode=? AND AttributeCode=?",
                          [
                            data["CustomerId"],
                            accountType,
                            listCategoryCode[jsonTemplate[i][0]["widget_id"]],
                            jsonTemplate[i][0]["widget_id"]
                          ]);
                    }

                    String query =
                        "INSERT INTO tblAccountListAttributesChanges (CustomerId,AccountType,CategoryCode,AttributeCode,AttributeValue) VALUES (?,?,?,?,?)";

                    await DBProfessionalList.prformQueryOperation(query, [
                      data["CustomerId"].toString(),
                      accountType,
                      listCategoryCode[jsonTemplate[i][0]["widget_id"]],
                      jsonTemplate[i][0]["widget_id"],
                      myController.text.toString()
                    ]);

                    DBProfessionalList.updateValueForAccount(
                        myController.text,
                        data["CustomerId"],
                        jsonTemplate[i][0]["widget_id"],
                        accountType,
                        listCategoryCode[jsonTemplate[i][0]["widget_id"]]);

                    setState(() {
                      print("Selected Value : ${myController.text}");
//                      jsonStringData[index]["body"]["Row"][i][0]
//                      ["defaultSelection"] = newValue;
                      listCoreData[jsonTemplate[i][0]["widget_id"]] =
                          myController.text.toString();
                    });
                  },
                  controller: myController,
                  keyboardType: type,
                  inputFormatters: inputFormatter,
                  style: new TextStyle(
                    //color: Constants_data.hexToColor(jsonTemplate[i][0]["txt_color"]),
                      fontWeight: jsonTemplate[i][0]["txt_style" == "Bold"
                          ? FontWeight.bold
                          : FontWeight.normal]),
                  onChanged: (val) {},
                ),
              )
            ],
          ));
          myController.text =
          jsonData[jsonTemplate[i][0]["widget_id"]] != null &&
              jsonData[jsonTemplate[i][0]["widget_id"]] != ""
              ? jsonData[jsonTemplate[i][0]["widget_id"]]
              : "-";
        }
        else if (jsonTemplate[i][0]["widget_type"] == "Dropdown" &&
            jsonTemplate[i][0]["isQA"] == "Y") {
          List<DropdownMenuItem> items = [];
          List<dynamic> listItems = [];

          listItems = jsonTemplate[i][0]["options"];

          for (int k = 0; k < listItems.length; k++) {
            if (listItems[k]["name"] ==
                jsonData[jsonTemplate[i][0]["widget_id"]]) {
              jsonTemplate[i][0]["defaultSelection"] = k;
            }
            items.add(
                DropdownMenuItem(value: k, child: Text(listItems[k]["name"])));
          }
          if (listItems.length > 0) {
            row.add(new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      child: new Text(
                          jsonTemplate[i][0]["label"] != null
                              ? '⦿ ' + jsonTemplate[i][0]["label"]
                              : "N/A",
                          textAlign: TextAlign.start,
                          style: new TextStyle(
                              color: themeData.textTheme.caption.color))),
                  new Container(
                      height: 35.0,
                      width: 150,
                      margin: EdgeInsets.only(bottom: 10.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: new DropdownButton(
                            isExpanded: true,
                            hint: Text('Please choose a location'),
                            // Not necessary for Option 1
                            value: jsonTemplate[i][0]["defaultSelection"],
                            onChanged: (newValue) async {
                              List<dynamic> checkDataAvailability =
                              await DBProfessionalList.prformQueryOperation(
                                  "SELECT * from tblAccountListAttributesChanges WHERE CustomerId=? AND AccountType=? AND CategoryCode=? AND AttributeCode=?",
                                  [
                                    data["CustomerId"],
                                    accountType,
                                    listCategoryCode[jsonTemplate[i][0]
                                    ["widget_id"]],
                                    jsonTemplate[i][0]["widget_id"]
                                  ]);

                              print(
                                  "checkDataAvailability : ${checkDataAvailability}");

                              if (checkDataAvailability.length != 0) {
                                await DBProfessionalList.prformQueryOperation(
                                    "DELETE from tblAccountListAttributesChanges WHERE CustomerId=? AND AccountType=? AND CategoryCode=? AND AttributeCode=?",
                                    [
                                      data["CustomerId"],
                                      accountType,
                                      listCategoryCode[jsonTemplate[i][0]
                                      ["widget_id"]],
                                      jsonTemplate[i][0]["widget_id"]
                                    ]);
                              }

                              String query =
                                  "INSERT INTO tblAccountListAttributesChanges (CustomerId,AccountType,CategoryCode,AttributeCode,AttributeValue) VALUES (?,?,?,?,?)";

                              await DBProfessionalList.prformQueryOperation(
                                  query, [
                                data["CustomerId"].toString(),
                                accountType,
                                listCategoryCode[jsonTemplate[i][0]
                                ["widget_id"]],
                                jsonTemplate[i][0]["widget_id"],
                                listItems[newValue]["name"].toString()
                              ]);

                              await DBProfessionalList.updateValueForAccount(
                                  listItems[newValue]["name"].toString(),
                                  data["CustomerId"],
                                  jsonTemplate[i][0]["widget_id"],
                                  accountType,
                                  listCategoryCode[jsonTemplate[i][0]
                                  ["widget_id"]]);

                              setState(() {
                                print("Selected Value : ${newValue}");
                                jsonTemplate[i][0]["defaultSelection"] =
                                    newValue;
//                              jsonStringData[index]["body"]["Row"][i][0]
//                                  ["defaultSelection"] = newValue;
                                listCoreData[jsonTemplate[i][0]["widget_id"]] =
                                    listItems[newValue]["name"].toString();
                              });

//                              setState(() {
//                                print("Selected Value : ${newValue}");
//                                jsonTemplate[i][0]["defaultSelection"] =
//                                    newValue;
//                              });
                            },
                            items: items,
                          )))
                ]));
          } else {
            row.add(new Container(child: new Text("listItems.length = 0")));
          }
        }
        else {
          row.add(new Expanded(
            flex: 30,
            child: InkWell(
                onLongPress: () {
                  showCustomMenu(jsonTemplate[i][0]["label"]);
                },
                onTap: () {
                  //showCustomMenu(jsonTemplate[i][0]["label"]);
                },
                onTapDown: storePosition,
                child: new Text(
                    jsonTemplate[i][0]["label"] != null
                        ? jsonTemplate[i][0]["label"]
                        : "N/A",
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                    style: new TextStyle(
                        fontWeight: FontWeight.normal,
                        color: themeData.textTheme.caption.color))),
          ));
          row.add(new Expanded(
            flex: 4,
            child: new Text(
              ":",
              textAlign: TextAlign.start,
            ),
          ));
          if (jsonTemplate[i][0]["widget_type"] == "Text") {
            row.add(new Expanded(
              flex: 56,
              child: new Text(
                jsonData[jsonTemplate[i][0]["widget_id"]] != null
                    ? jsonData[jsonTemplate[i][0]["widget_id"]]
                    : "-",
                style: new TextStyle(
                    fontWeight: jsonTemplate[i][0]["txt_style" == "Bold"
                        ? FontWeight.bold
                        : FontWeight.normal]),
              ),
            ));

            row.add(new Expanded(
                flex: 10,
                child: new GestureDetector(
                  onTap: () {
                    print("click: ${jsonTemplate[i][0]["valueType"]}");
                    CallsEmailWebService callService =
                    new CallsEmailWebService();
                    if (jsonTemplate[i][0]["valueType"] == "Phone") {
                      callService.call(
                          jsonData[jsonTemplate[i][0]["widget_id"]] != null
                              ? jsonData[jsonTemplate[i][0]["widget_id"]]
                              : "");
                    } else if (jsonTemplate[i][0]["valueType"] == "Email") {
                      callService.sendEmail(
                          jsonData[jsonTemplate[i][0]["widget_id"]] != null
                              ? jsonData[jsonTemplate[i][0]["widget_id"]]
                              : "");
                    } else if (jsonTemplate[i][0]["valueType"] == "Website") {
                      callService.openUrl(
                          jsonData[jsonTemplate[i][0]["widget_id"]] != null
                              ? jsonData[jsonTemplate[i][0]["widget_id"]]
                              : "");
                    }
                  },
                  child: new Center(
                    child: jsonTemplate[i][0]["valueType"] != "Text"
                        ? getWidgetIcon(jsonTemplate[i][0]["valueType"])
                        : new Container(),
                  ),
                )));
          }
          else if (jsonTemplate[i][0]["widget_type"] == "Field") {
            TextInputType type = TextInputType.text;
            List<TextInputFormatter> inputFormatter = [];
            if (jsonTemplate[i][0]["inputType"] == "Phone") {
              type = TextInputType.phone;
              inputFormatter = [
                FilteringTextInputFormatter.allow(RegExp('[0-9+]')),
              ];
            } else if (jsonTemplate[i][0]["inputType"] == "Email") {
              type = TextInputType.emailAddress;
            } else {
              type = TextInputType.text;
            }

            final myController = TextEditingController();
            row.add(new Expanded(
                flex: 56,
                child: new Container(
                  child: new TextField(
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    ),
                    maxLines: null,
                    onEditingComplete: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      List<dynamic> checkDataAvailability =
                      await DBProfessionalList.prformQueryOperation(
                          "SELECT * from tblAccountListAttributesChanges WHERE CustomerId=? AND AccountType=? AND CategoryCode=? AND AttributeCode=?",
                          [
                            data["CustomerId"],
                            accountType,
                            listCategoryCode[jsonTemplate[i][0]["widget_id"]],
                            jsonTemplate[i][0]["widget_id"]
                          ]);

                      print("checkDataAvailability : ${checkDataAvailability}");

                      if (checkDataAvailability.length != 0) {
                        await DBProfessionalList.prformQueryOperation(
                            "DELETE from tblAccountListAttributesChanges WHERE CustomerId=? AND AccountType=? AND CategoryCode=? AND AttributeCode=?",
                            [
                              data["CustomerId"],
                              accountType,
                              listCategoryCode[jsonTemplate[i][0]["widget_id"]],
                              jsonTemplate[i][0]["widget_id"]
                            ]);
                      }

                      String query =
                          "INSERT INTO tblAccountListAttributesChanges (CustomerId,AccountType,CategoryCode,AttributeCode,AttributeValue) VALUES (?,?,?,?,?)";

                      await DBProfessionalList.prformQueryOperation(query, [
                        data["CustomerId"].toString(),
                        accountType,
                        listCategoryCode[jsonTemplate[i][0]["widget_id"]],
                        jsonTemplate[i][0]["widget_id"],
                        myController.text.toString()
                      ]);

                      DBProfessionalList.updateValueForAccount(
                          myController.text,
                          data["CustomerId"],
                          jsonTemplate[i][0]["widget_id"],
                          accountType,
                          listCategoryCode[jsonTemplate[i][0]["widget_id"]]);

                      setState(() {
                        print("Selected Value : ${myController.text}");
//                      jsonStringData[index]["body"]["Row"][i][0]
//                      ["defaultSelection"] = newValue;
                        listCoreData[jsonTemplate[i][0]["widget_id"]] =
                            myController.text.toString();
                      });
                    },
                    controller: myController,
                    keyboardType: type,
                    inputFormatters: inputFormatter,
                    style: new TextStyle(
                      //color: Constants_data.hexToColor(jsonTemplate[i][0]["txt_color"]),
                        fontWeight: jsonTemplate[i][0]["txt_style" == "Bold"
                            ? FontWeight.bold
                            : FontWeight.normal]),
                  ),
                )));
            myController.text =
            jsonData[jsonTemplate[i][0]["widget_id"]] != null
                ? jsonData[jsonTemplate[i][0]["widget_id"]]
                : "";
            row.add(new Expanded(
                flex: 10,
                child: new GestureDetector(
                  onTap: () {
                    print("click: ${jsonTemplate[i][0]["valueType"]}");
                    CallsEmailWebService callService =
                    new CallsEmailWebService();
                    if (jsonTemplate[i][0]["valueType"] == "Phone") {
                      callService.call(
                          jsonData[jsonTemplate[i][0]["widget_id"]] != null
                              ? jsonData[jsonTemplate[i][0]["widget_id"]]
                              : "");
                    } else if (jsonTemplate[i][0]["valueType"] == "Email") {
                      callService.sendEmail(
                          jsonData[jsonTemplate[i][0]["widget_id"]] != null
                              ? jsonData[jsonTemplate[i][0]["widget_id"]]
                              : "");
                    } else if (jsonTemplate[i][0]["valueType"] == "Website") {
                      callService.openUrl(
                          jsonData[jsonTemplate[i][0]["widget_id"]] != null
                              ? jsonData[jsonTemplate[i][0]["widget_id"]]
                              : "");
                    }
                  },
                  child: new Center(
                    child: jsonTemplate[i][0]["valueType"] != "Text"
                        ? getWidgetIcon(jsonTemplate[i][0]["valueType"])
                        : new Container(),
                  ),
                )));
          }
          else if (jsonTemplate[i][0]["widget_type"] == "Dropdown") {
            print("Dropdown json Template : ${jsonTemplate[i][0]}");
            print("Dropdown jsonData : ${jsonData}");

            List<DropdownMenuItem> items = [];
            List<dynamic> listItems = [];

            listItems = jsonTemplate[i][0]["options"];

            for (int k = 0; k < listItems.length; k++) {
              if (listItems[k]["name"] ==
                  jsonData[jsonTemplate[i][0]["widget_id"]]) {
                jsonTemplate[i][0]["defaultSelection"] = k;
              }
              items.add(DropdownMenuItem(
                  value: k, child: Text(listItems[k]["name"])));
              //print(listItems[k]);
            }
            if (listItems.length > 0) {
              row.add(new Expanded(
                  flex: 66,
                  child: new Container(
                      height: 35.0,
                      width: 100,
//                    margin: EdgeInsets.only(bottom: 10.0),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: new DropdownButton(
                            isExpanded: true,
                            hint: Text('Please choose a location'),
                            value: jsonTemplate[i][0]["defaultSelection"],
                            onChanged: (newValue) async {
                              List<dynamic> checkDataAvailability =
                              await DBProfessionalList.prformQueryOperation(
                                  "SELECT * from tblAccountListAttributesChanges WHERE CustomerId=? AND AccountType=? AND CategoryCode=? AND AttributeCode=?",
                                  [
                                    data["CustomerId"],
                                    accountType,
                                    listCategoryCode[jsonTemplate[i][0]
                                    ["widget_id"]],
                                    jsonTemplate[i][0]["widget_id"]
                                  ]);

                              print(
                                  "checkDataAvailability : ${checkDataAvailability}");

                              if (checkDataAvailability.length != 0) {
                                await DBProfessionalList.prformQueryOperation(
                                    "DELETE from tblAccountListAttributesChanges WHERE CustomerId=? AND AccountType=? AND CategoryCode=? AND AttributeCode=?",
                                    [
                                      data["CustomerId"],
                                      accountType,
                                      listCategoryCode[jsonTemplate[i][0]
                                      ["widget_id"]],
                                      jsonTemplate[i][0]["widget_id"]
                                    ]);
                              }

                              String query =
                                  "INSERT INTO tblAccountListAttributesChanges (CustomerId,AccountType,CategoryCode,AttributeCode,AttributeValue) VALUES (?,?,?,?,?)";

                              await DBProfessionalList.prformQueryOperation(
                                  query, [
                                data["CustomerId"].toString(),
                                accountType,
                                listCategoryCode[jsonTemplate[i][0]
                                ["widget_id"]],
                                jsonTemplate[i][0]["widget_id"],
                                listItems[newValue]["name"].toString()
                              ]);

                              await DBProfessionalList.updateValueForAccount(
                                  listItems[newValue]["name"].toString(),
                                  data["CustomerId"],
                                  jsonTemplate[i][0]["widget_id"],
                                  accountType,
                                  listCategoryCode[jsonTemplate[i][0]
                                  ["widget_id"]]);

                              setState(() {
                                print("Selected Value : ${newValue}");
                                jsonTemplate[i][0]["defaultSelection"] =
                                    newValue;
//                              jsonStringData[index]["body"]["Row"][i][0]
//                                  ["defaultSelection"] = newValue;
                                listCoreData[jsonTemplate[i][0]["widget_id"]] =
                                    listItems[newValue]["name"].toString();
                              });

//                            setState(() {
//                              print("Selected Value 1: ${newValue}");
//                              jsonTemplate[i][0]["defaultSelection"] = newValue;
//                            });
                            },
                            items: items,
                          )))));
            } else {
              row.add(new Container(child: new Text("listItems.length = 0")));
            }
          }
        }
        col1.add(new Container(
            margin: EdgeInsets.only(left: 5, top: 10, bottom: 10, right: 5),
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: row,
            )));
      }
    }
//    print("--------- Column Size  ${col.length}");
    if (count == col1.length) {
      Widget vi = new Container(
          child: new Card(
              elevation: 5,
              margin: EdgeInsets.all(5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: new Column(
                children: col1,
              )));

      col.add(vi);
      col1 = [];
      count = 0;
    }
    return new Container(
        padding: EdgeInsets.only(left: 5, top: 5, bottom: 10, right: 5),
        child: new Column(
          children: col,
        ));
  }
  Future<void> openFile(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      print('Could not open the file: $url');
    }
  }
  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
    return formattedDate;
  }
  getDataForBarChart(String columns, List<dynamic> listChartData, xAxis) {
    final List<SalesData> chartData = [];
    print("Datalenght of BarChart : ${listChartData}");
    for (int i = 0; i < listChartData.length; i++) {
      chartData.add(SalesData(
          listChartData[i][xAxis], double.parse(listChartData[i][columns])));
    }
    print("chart data : ${chartData.length}");
    return chartData;
  }
  void showCustomMenu(String text) {
    Constants_data.label_txt = text;
    this.showMenu(
      context: context,
      items: <PopupMenuEntry<int>>[PopupLabelView()],
    ).then<void>((int delta) {
      if (delta == null) return;

      // setState(() {});
    });
  }
  getWidgetIcon(String valueType) {
    if (valueType == "Phone") {
      return Icon(
        Icons.phone,
        color: AppColors.grey_color,
      );
    } else if (valueType == "Email") {
      return Icon(
        Icons.alternate_email,
        color: AppColors.grey_color,
      );
    } else if (valueType == "Website") {
      return Icon(
        Icons.language,
        color: AppColors.grey_color,
      );
    } else {
      return Icon(
        Icons.edit,
        color: AppColors.grey_color,
      );
    }
  }
  getSubtitle(data, List<dynamic> keys) {
    print("---- Data: ${data}");
    print("---- Keys: ${keys}");
    List<Widget> listWidget = [];
    listWidget.add(new Container(
      width: 175,
      child: new Text(
        data[keys[0]],
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    ));
    for (int i = 1; i < 3; i++) {
      listWidget.add(new Container(
        width: 175,
        child: new Text(
          data[keys[i]],
          style: TextStyle(
            fontSize: 12,
          ),
        ),
      ));
    }
    return listWidget;
  }
  getViewFromListTemplateHeader(var dt, List<dynamic> keys, var json) {
    var data = json;
    if (data["ViewType"] == "Header") {
      List<Widget> dtColumn = [];
      List<dynamic> rowData = data["Row"];
      for (int i = 0; i < rowData.length; i++) {
        List<Widget> dtRow = [];
        List<dynamic> rowDataChild = rowData[i];
        for (int j = 0; j < rowDataChild.length; j++) {
          data_map.add(dt[rowDataChild[j]["widget_id"]]);
          dtRow.add(new Expanded(
              flex: rowDataChild[j]["maxWidht"],
              child: Container(
                padding: EdgeInsets.all(2),
                child: new Align(
                    alignment: rowDataChild[j]["align"] == "Left"
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: new Text(
                      "${dt[rowDataChild[j]["widget_id"]] == null
                          ? "N/A"
                          : dt[rowDataChild[j]["widget_id"]]} ",
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: rowDataChild[j]["txt_style"] == "Bold"
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: Constants_data.getFontSize(context, 13),
                        color: Constants_data.hexToColor(
                            rowDataChild[j]["txt_color"]),
                      ),
                    )),
              )));
        }
        dtColumn.add(new Container(
          child: new Row(children: dtRow),
        ));
      }
      return Expanded(
          child: new Row(
            children: <Widget>[
              data["isShowLeadingIcon"] == "Y"
                  ? new Container(
                child: new CircleAvatar(
                  backgroundColor: AppColors.light_grey_color,
                  radius: Constants_data.getFontSize(context, 25),
                  child: new Container(
                    margin: EdgeInsets.all(2),
                    child: dt[data["LeadingIconFrom"]] == null ||
                        dt[data["LeadingIconFrom"]] == ""
                        ? Image.asset(
                      "assets/images/default_user.png",
                    )
                        : Image.network(dt[data["LeadingIconFrom"]]),
                  ),
                ),
                margin: EdgeInsets.only(right: 5),
              )
                  : new Container(),
              new Expanded(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: dtColumn,
                ),
              ),
              data["isShowTailIcon"] == "Y"
                  ? new Center(
                child: Icon(
                  Icons.keyboard_arrow_right,
                  color: AppColors.grey_color,
                ),
              )
                  : new Container()
            ],
          ));
    }
  }

  String time = Constants_data.dateToString(DateTime.now(), "hh:mm a");
  String date = Constants_data.dateToString(DateTime.now(), "yyyy-MM-dd");
  DateTime selectedDate = DateTime.now();

  void saveTheEvent(AccountId, AccountType) {
    time = Constants_data.dateToString(DateTime.now(), "hh:mm a");
    date = Constants_data.dateToString(DateTime.now(), "yyyy-MM-dd");
    selectedDate = DateTime.now();
    var dropDownTemplateJson = {
      "label": "",
      "flex": 10,
      "txt_style": "caption1",
      "defaultSelection": "0",
      "widget_id": "mobile",
      "widget_type": "DropDown",
      "selected_id": "1",
      "options": [
        {"id": "1", "name": "Birthday"},
        {"id": "2", "name": "Anniversary"},
        {"id": "3", "name": "Reminder Note"}
      ]
    };

    TextEditingController cntTitle = new TextEditingController();
    TextEditingController cntDesc = new TextEditingController();
    Map<String, dynamic> requestJson = {
      "EventData": [
        {
          "AccountId": "$AccountId",
          "AccountType": "$AccountType",
          "EventType": "",
          "EventTitle": "",
          "EventDesc": "",
          "EventDate": "yyyy-MM-dd",
          "EventTime": "9:00 AM"
        }
      ]
    };

    showModalBottomSheet1(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter state) {
                Widget dropDown = CustomDropdown(
                  onChanged: (val, item) {
                    state(() {
                      dropDownTemplateJson["defaultSelection"] = val;
                      dropDownTemplateJson["selected_id"] = item["id"];
                    });

                    print("Item$val : $item");
                  },
                  templateJson: dropDownTemplateJson,
                  isHideUnderline: true,
                );
                return SingleChildScrollView(
                    child: Column(children: [
                      Stack(
                        children: <Widget>[
                          new Positioned(
                              child: new Align(
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.save),
                                  onPressed: () async {
                                    if (cntTitle.text.trim() == "") {
                                      Constants_data.toastError(
                                          "Title can't be blank");
                                      return;
                                    } else if (cntDesc.text.trim() == "") {
                                      Constants_data.toastError(
                                          "Description can't be blank");
                                      return;
                                    }
                                    print(
                                        dropDownTemplateJson["defaultSelection"]);
                                    requestJson["EventData"][0]["EventType"] =
                                        dropDownTemplateJson["selected_id"]
                                            .toString();
                                    requestJson["EventData"][0]["EventTitle"] =
                                        cntTitle.text.toString();
                                    requestJson["EventData"][0]["EventDesc"] =
                                        cntDesc.text.toString();
                                    requestJson["EventData"][0]["EventDate"] =
                                        date;
                                    requestJson["EventData"][0]["EventTime"] =
                                        time;
                                    print("RequestJson : ${jsonEncode(
                                        requestJson)}");
                                    try {
                                      var data = await _helper.post(
                                          "/SaveNewCalenderEvent?RepId=${Constants_data
                                              .app_user["RepId"]}",
                                          requestJson,
                                          true);
                                      if (data["Status"] == 1) {
                                        Constants_data.toastNormal(
                                            data["Message"]);
                                        Navigator.pop(context);
                                      } else {
                                        Constants_data.toastError(
                                            data["Message"]);
                                      }
                                    } catch (e) {
                                      print("Error : ${e}");
                                      Constants_data.toastError(
                                          "Error in saving data");
                                    }
                                  },
                                  label: new Text("Save"),
                                ),
                                alignment: Alignment.centerLeft,
                              )),
                          new Positioned(
                              child: new Align(
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    //resetRequestData(jsonTemplate);
                                    Navigator.pop(context);
                                  },
                                  label: new Text("Close"),
                                ),
                                alignment: Alignment.centerRight,
                              )),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          children: [
                            Container(
                                child: Text(
                                  "Add new Reminder",
                                  style: Styles.h3,
                                )),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      width: 1, color: AppColors.grey_color)),
                              child: dropDown,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              child: TextField(
                                controller: cntTitle,
                                onChanged: (val) {},
                                decoration: new InputDecoration(
                                  counterText: "",
                                  contentPadding: EdgeInsets.only(
                                      left: 10, right: 10),
                                  hintText: "Title of Reminder",
                                  hintStyle: new TextStyle(
                                      color: AppColors.grey_color),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(
                                      color: themeData.accentColor,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(
                                      color: AppColors.grey_color,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              child: TextField(
                                controller: cntDesc,
                                onChanged: (val) {},
                                maxLines: 3,
                                decoration: new InputDecoration(
                                    counterText: "",
                                    contentPadding: EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 10,
                                        bottom: 10),
                                    hintText: "Description of reminder",
                                    hintStyle:
                                    new TextStyle(color: AppColors.grey_color),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: themeData.accentColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: BorderSide(
                                        color: AppColors.grey_color,
                                        width: 1.0,
                                      ),
                                    )),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                      child: InkWell(
                                          onTap: () {
                                            _selectDate(state);
                                            // if (!Platform.isIOS) {
                                            //   selectDateiOS(state);
                                            // } else {
                                            //   _selectDate(state);
                                            // }
                                          },
                                          child: Container(
                                            height: 45,
                                            padding:
                                            EdgeInsets.only(
                                                left: 10, right: 10),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius
                                                    .circular(5),
                                                border: Border.all(
                                                    width: 1,
                                                    color: AppColors
                                                        .grey_color)),
                                            child: Row(
                                              children: <Widget>[
                                                Container(
                                                    child: Text(
                                                      "Date : ",
                                                      style: Styles.caption1,
                                                    )),
                                                Expanded(
                                                    child: Text("$date",
                                                        style: Styles.h4)),
                                                Icon(
                                                  Icons.date_range_outlined,
                                                  color: AppColors.grey_color,
                                                )
                                              ],
                                            ),
                                          ))),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                      child: InkWell(
                                          onTap: () {
                                            _selectTime(state);
                                            // if (Platform.isIOS) {
                                            //   selectTimeiOS(state);
                                            // } else {
                                            //   _selectTime(state);
                                            // }
                                          },
                                          child: Container(
                                            height: 45,
                                            padding:
                                            EdgeInsets.only(
                                                left: 10, right: 10),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius
                                                    .circular(5),
                                                border: Border.all(
                                                    width: 1,
                                                    color: AppColors
                                                        .grey_color)),
                                            child: Row(
                                              children: <Widget>[
                                                Container(
                                                    child: Text(
                                                      "Time : ",
                                                      style: Styles.caption1,
                                                    )),
                                                Expanded(
                                                    child: Text(
                                                      "$time",
                                                      style:
                                                      Styles.h4,
                                                    )),
                                                Icon(
                                                  Icons.access_time_outlined,
                                                  color: Colors.grey,
                                                )
                                              ],
                                            ),
                                          ))),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Text(
                                "* Added reminder tasks show in calendar screen with MTP Schedule.",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      )
                    ]));
              });
        });
  }
  selectDateiOS(state) async {
    DateTime picked = selectedDate;
    await showModalBottomSheet1(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter state) {
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
                                    if (picked != null &&
                                        picked != selectedDate)
                                      state(() {
                                        var date =
                                        new DateFormat("dd-MM-yyyy").format(
                                            picked);
                                        selectedDate = picked;
                                        this.date = date;
                                        print("Picked date : ${date}");
                                        print(
                                            "selectedDate date : ${selectedDate}");
                                        print("date : ${this.date}");
                                      });
                                    Navigator.pop(context);
                                  },
                                  child: new Text(
                                    "Done",
                                    style: TextStyle(
                                        color: AppColors.main_color),
                                  ),
                                ),
                                alignment: Alignment.centerRight,
                              )),
                        ],
                      ),
                      Expanded(
                          child: CupertinoTheme(
                              data: CupertinoThemeData(
                                brightness: themeChange.darkTheme
                                    ? Brightness.dark
                                    : Brightness.light,
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
  selectTimeiOS(state) async {
    DateTime picked;
    await showModalBottomSheet1(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter state) {
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
                                  child: new Text("Select Date")),
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
                                    state(() {
                                      this.time = Constants_data.dateToString(
                                          picked, "hh:mm a");
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: new Text(
                                    "Done",
                                    style: TextStyle(
                                        color: AppColors.main_color),
                                  ),
                                ),
                                alignment: Alignment.centerRight,
                              )),
                        ],
                      ),
                      Expanded(
                          child: CupertinoTheme(
                              data: CupertinoThemeData(
                                brightness: themeChange.darkTheme
                                    ? Brightness.dark
                                    : Brightness.light,
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

  Future<Null> _selectDate(state) async {
    final DateTime picked = await showDatePicker(
      builder: (BuildContext context, Widget child) {
        return Constants_data.timeDatePickerTheme(
            child, themeChange.darkTheme, context);
      },
      context: context,
      initialDate: selectedDate,
      firstDate: new DateTime(selectedDate.year - 1),
      lastDate: new DateTime(selectedDate.year + 1),
    );

    if (picked != null && picked != selectedDate)
      state(() {
        var date = new DateFormat("yyyy-MM-dd").format(picked);
        selectedDate = picked;
        this.date = date;
        print("Picked date : ${date}");
      });
  }

  Future<Null> _selectTime(state) async {
    TimeOfDay time = await showTimePicker(
      builder: (BuildContext context, Widget child) {
        return Constants_data.timeDatePickerTheme(
            child, themeChange.darkTheme, context);
      },
      initialTime: TimeOfDay.now(),
      context: context,
    );
    if (time != null && time != TimeOfDay.now()) {
      state(() {
        final now = new DateTime.now();
        final dt =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
        final format = DateFormat("hh:mm a"); //"6:00 AM"
        this.time = format.format(dt);
        print("Picked Time : ${time.format(context)}");
      });
    }
    //print("Time of the day : ${time.hour>12 ? time.hour-12 : time.hour}");
  }

  bool isShowRate = true;
  bool isShowDescription = true;
  bool isShowRateEntryEditText = false;
  bool isShowPaymentOption = true;

  List<dynamic> choices = <dynamic>[
    {"name": "Customer", "accout_id": "Customer"},
    {"name": "Hospital", "accout_id": "HCO"},
  ];
  String _selectedAccount = "Customer";
  String selectedAccountName = "Customer";

  Future<Null> getData() async {
    productGroupData = [];
    var dataUser;
    if (Constants_data.app_user == null) {
      dataUser = await StateManager.getLoginUser();
    }
    else {
      dataUser = Constants_data.app_user;
    }
    configDetails = await DBProfessionalList.getConfigDetails();
    for (int i = 0; i < configDetails.length; i++) {
      print("ConfigDetails : ${jsonEncode(configDetails[i])}");
      if (configDetails[i]["Parameter_Code"] == "IsRateAvl" &&
          configDetails[i]["Parameter_Value"] == "N" &&
          configDetails[i]["is_active"] == "Y") {
        isShowRate = false;
      }
      if (configDetails[i]["Parameter_Code"] == "POBDescription" &&
          configDetails[i]["Parameter_Value"] == "N" &&
          configDetails[i]["is_active"] == "Y") {
        isShowDescription = false;
      }
      if (configDetails[i]["Parameter_Code"] == "ManualRateInPOB" &&
          configDetails[i]["Parameter_Value"] == "Y" &&
          configDetails[i]["is_active"] == "Y") {
        isShowRateEntryEditText = true;
      }

      if (configDetails[i]["Parameter_Code"] == "is_payment_option_pob" &&
          configDetails[i]["Parameter_Value"] == "N" &&
          configDetails[i]["is_active"] == "Y") {
        isShowPaymentOption = false;
      }
    }

    Map<String, List<dynamic>> response =
    await DBProfessionalList.getAttributes(
        "$_selectedAccount", false, null);
    listCustomers = response["data"].toSet().toList();

    try {
      String routeUrl = '/GetDataForCustomerPOB?RepId=${dataUser["RepId"]}';
      var response = await _helper.get(routeUrl);
      productGroupData = response["dt_ReturnedTables"][0];
      _filteredProductGroupData = productGroupData;
    } on Exception catch (err) {
      print("Error in GetDataForCustomerPOB : $err");
      //dataMain = [];
    }
    listController = [];
    for (int i = 0; i < productGroupData.length; i++) {
      productGroupData[i]["selected"] = "false";
      productGroupData[i]["fromDD"] = "true";
      productGroupData[i]["DDValue"] = null;
      productGroupData[i]["txtValue"] = "";
      productGroupData[i]["qty"] = 0;
      productGroupData[i]["total"] = 0;
      TextEditingController cnt = new TextEditingController();
      listController.add(cnt);
    }
    isLoaded = true;
  }
  Map<String, List<dynamic>> doctorProductDetails = {};
  Widget getView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 180,
      child: StatefulBuilder(builder: (context, setState) {
        return Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: MaterialButton(
                onPressed: () async {
                  await getProductNames();
                 // setState(() {});
                },
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Colors.blue,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  "Select Product",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 0),
                itemCount: getDoctorDetailsForApproval.length,
                itemBuilder: (context, index) {
                  if (showGetDoctorDetailsForApproval.length <= index) {
                  }
                    showGetDoctorDetailsForApproval.add(false);
                  String status = "NA";
                  if (getDoctorDetailsForApproval[index]["level1_approved"].toString() == "N" &&
                      getDoctorDetailsForApproval[index]["level2_approved"].toString() == "N") {
                    //status = "Pending";
                    status = "Level1 Pending";
                  }
                  else if (getDoctorDetailsForApproval[index]["level1_approved"].toString() == "Y" &&
                      getDoctorDetailsForApproval[index]["level2_approved"].toString() == "N") {
                    //status = "Level1 Approved";
                    status = "Level2 Pending";
                  }
                  else if (getDoctorDetailsForApproval[index]["level1_approved"].toString() == "Y" &&
                      getDoctorDetailsForApproval[index]["level2_approved"].toString() == "Y") {
                    status = "Level2 Approved";
                  }
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 12,
                    margin: EdgeInsets.only(top: 15),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      "Request No: ",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14, // Adjust the font size as needed
                                      ),
                                    ),
                                    Text(
                                      "${getDoctorDetailsForApproval[index]["doc_no"] ?? 'N/A'}",  // Display 'N/A' if null
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal, // Normal weight for value
                                        fontSize: 14, // Adjust the font size as needed
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height:10),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      "Request Date: ",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14, // Adjust the font size as needed
                                      ),
                                    ),
                                    Text(
                                      "${formatDate(getDoctorDetailsForApproval[index]["doc_date"])}",  // Display 'N/A' if null
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal, // Normal weight for value
                                        fontSize: 14, // Adjust the font size as needed
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height:10),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    // Label for "Total FGO"
                                    Text(
                                      "Total FGO: ",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14, // Adjust font size if needed
                                      ),
                                    ),
                                    // Value for "total_fgo_value"
                                    Text(
                                      "${getDoctorDetailsForApproval[index]["total_fgo_value"] ?? 'N/A'}", // Display 'N/A' if null
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal, // Normal weight for value
                                        fontSize: 14, // Adjust font size if needed
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      "Status: ",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14, // Adjust font size if needed
                                      ),
                                    ),
                                    Text(
                                      status ?? 'N/A', // Display 'N/A' if status is null
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal, // Normal weight for value
                                        fontSize: 14, // Adjust font size if needed
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child:  Row(
                                  children: [
                                    Text(
                                      "Speciality: ",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14, // Adjust the font size as needed
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        getDoctorDetailsForApproval[index]["SPECIALITY"] ?? "N/A", // Display 'N/A' if null
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal, // Normal weight for value
                                          fontSize: 14, // Adjust the font size as needed
                                        ),
                                        softWrap: true,  // Enable text wrapping
                                        overflow: TextOverflow.ellipsis, // Add ellipsis if text exceeds 2 lines
                                        maxLines: 2, // Allow up to 2 lines
                                      ),
                                    ),

                                    // Text(
                                    //   "${getDoctorDetailsForApproval[index]["SPECIALITY"]}",  // Display 'N/A' if null
                                    //   style: TextStyle(
                                    //     color: Colors.black,
                                    //     fontWeight: FontWeight.normal, // Normal weight for value
                                    //     fontSize: 14, // Adjust the font size as needed
                                    //   ),
                                    //   softWrap: true,
                                    //   overflow: TextOverflow.ellipsis,
                                    //   maxLines: 2,
                                    // ),
                                  ],
                                )
                              ),
                              InkWell(
                                onTap: () async {
                                  String docNo = getDoctorDetailsForApproval[index]["doc_no"];
                                  if (!showGetDoctorDetailsForApproval[index]) {
                                    showGetDoctorDetailsForApproval[index] = true;
                                    if (!doctorProductDetails.containsKey(docNo)) {
                                      doctorProductDetails[docNo] = await GetproductDetailData(
                                        docNo: docNo,
                                        divisionCode: getDoctorDetailsForApproval[index]["division_code"],
                                        stateCode: getDoctorDetailsForApproval[index]["state_code"],
                                        hqCode: getDoctorDetailsForApproval[index]["hq_code"],
                                        monthCode: getDoctorDetailsForApproval[index]["month_code"],
                                      );
                                    }
                                  } else {
                                    showGetDoctorDetailsForApproval[index] = false;
                                  }
                                  setState(() {});
                                },
                                child: showGetDoctorDetailsForApproval[index]
                                    ? Icon(Icons.remove_circle, color: Colors.red, size: 28)
                                    : Icon(Icons.add_circle_sharp, color: Colors.green, size: 28),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                          SizedBox(height: 10),
                          showGetDoctorDetailsForApproval[index]
                              ? (doctorProductDetails[getDoctorDetailsForApproval[index]["doc_no"]] == null ||
                              doctorProductDetails[getDoctorDetailsForApproval[index]["doc_no"]].isEmpty)
                              ? ConstrainedBox(
                               constraints: BoxConstraints(
                                maxHeight: 50,
                               ),
                               child: Text("No data available"),)
                              : ConstrainedBox(
                               constraints: BoxConstraints(
                               maxHeight: 250,
                               ),
                            child: ListView.builder(
                              itemCount: doctorProductDetails[getDoctorDetailsForApproval[index]["doc_no"]].length,
                              padding: EdgeInsets.only(top: 0),
                              itemBuilder: (context, j) {
                                return Card(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  elevation: 12,
                                  margin: EdgeInsets.only(top: 6),
                                  child:
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: RichText(
                                                text: TextSpan(
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: "Item Name : ",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: "${doctorProductDetails[getDoctorDetailsForApproval[index]["doc_no"]][j]["Product_Name"]}",
                                                      style: TextStyle(color: Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: RichText(
                                                text: TextSpan(
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: "Scheme Type : ",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: "${doctorProductDetails[getDoctorDetailsForApproval[index]["doc_no"]][j]["scheme_type"]}",
                                                      style: TextStyle(color: Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: RichText(
                                                text: TextSpan(
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: "Quantity : ",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: "${doctorProductDetails[getDoctorDetailsForApproval[index]["doc_no"]][j]["quantity"]}",
                                                      style: TextStyle(color: Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: RichText(
                                                text: TextSpan(
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: "Discount : ",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: "${doctorProductDetails[getDoctorDetailsForApproval[index]["doc_no"]][j]["discount_value"]}",
                                                      style: TextStyle(color: Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: RichText(
                                                text: TextSpan(
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: "FGO Value : ",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: "${doctorProductDetails[getDoctorDetailsForApproval[index]["doc_no"]][j]["fgo_value"]}",
                                                      style: TextStyle(color: Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                              : SizedBox.shrink(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
  void _filterProducts(String query) {
    List results = [];
    if (query.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = productGroupData;
    }
    else {
      results = productGroupData.where((product) {
        String itemDesc = product["item_desc"]?.toLowerCase() ?? '';
        return itemDesc.contains(query.toLowerCase());
      }).toList();
    }
    if (kDebugMode) {
      print(results);
    }
    _filteredProductGroupData = results;
  }
  dynamic _filteredProductGroupData;
  List<String> selectedProductIds = [];

  showSampleProductList() async {
    // Ensure the selected product IDs are preserved across multiple invocations
    // selectedProductIds.clear();  // Do not clear this list when revisiting
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return StatefulBuilder(builder: (context, state) {
          return Container(
            height: 550,
            color: Theme.of(context).cardColor,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    // Search Icon and Bar
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(top: 15),
                        child: _isSearching
                            ? TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: 'Search products...',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                state(() {
                                  _isSearching = false;
                                  _searchController.clear();
                                  _filteredProductGroupData = productGroupData; // Reset to full data
                                });
                              },
                            ),
                          ),
                          onChanged: (value) {
                            _filterProducts(value);
                            state(() {});
                          },
                        )
                            : IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            state(() {
                              _isSearching = true;
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: EdgeInsets.only(top: 15),
                        child: Text(
                          "Select Product",
                          style: TextStyle(fontSize: Constants_data.getFontSize(context, 12)),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: MaterialButton(
                        onPressed: () async {
                          await DisplayProductDetails(Constants_data.customerid, selectedProductIds);
                          // if (productDetails == null || productDetails.isEmpty) {
                          if (selectedProductIds == null || selectedProductIds.isEmpty) {
                            showAlertDialog('Please select at least one product.');
                            state(() {
                              selectedProductIds.clear();
                            });
                          } else  if (allSelectedProducts == null || allSelectedProducts.isEmpty) {
                            showAlertDialog('Data not available for selected products..');
                            // Clear selectedProductIds and update the UI
                            state(() {
                              selectedProductIds.clear();
                            });
                          }
                          else {
                            Navigator.pop(context);
                            showFGOCardDialog();
                            restorePreviousSelections();
                            calculateTotalFGO();
                            state(() {});
                          }
                        },
                        child: Text(
                          "Done",
                          style: TextStyle(
                            color: AppColors.main_color,
                            fontSize: Constants_data.getFontSize(context, 14),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) {
                      String itemDesc = _filteredProductGroupData[index]["item_desc"] ?? '';
                      String mrpRate = _filteredProductGroupData[index]["mrp_rate"]?.toString() ?? '';

                      String displayText = mrpRate.isEmpty
                          ? '$itemDesc (Rates Are Not Available)'
                          : '$itemDesc';

                      bool isSelected = selectedProductIds.contains(_filteredProductGroupData[index]["item_code"]);
                      return
                        InkWell(
                          onTap: () {
                            state(() {
                              if (mrpRate.isEmpty) {
                                // If the product has no rates available, show an alert
                                showAlertDialog(
                                    'For the selected products,rates are not available'
                                        '.Please ask hs user to provide rates..');
                              } else {
                                // Toggle selection
                                String itemCode = _filteredProductGroupData[index]["item_code"].toString();
                                if (selectedProductIds.contains(itemCode)) {
                                  // Deselect product
                                  selectedProductIds.remove(itemCode);
                                  // Clear values for the deselected product
                                  productQuantities.remove(itemCode);
                                  productFgoValues.remove(itemCode);
                                  productInvoiceValues.remove(itemCode);
                                } else {
                                  // Select product
                                  selectedProductIds.add(itemCode);
                                }
                              }
                              print("Selected Products: $selectedProductIds");
                                DisplayProductDetails(Constants_data.customerid, selectedProductIds);
                            });
                          },
                          child: Container(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(bottom: 12, top: 12),
                                    child: Text(
                                      displayText,
                                      maxLines: 3,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                selectedProductIds.contains(_filteredProductGroupData[index]["item_code"])
                                    ? Icon(Icons.check_box, color: AppColors.main_color)
                                    : Container(),
                              ],
                            ),
                          ),
                        );
                      //InkWell(
                      //   onTap: () {
                      //     state(() {
                      //       if (mrpRate.isEmpty) {
                      //         // If the product has no rates available, show an alert
                      //         showAlertDialog('For the selected products,rates are not available.Please ask hs user to provide rates..');
                      //       } else {
                      //         // Toggle selection if rates are available
                      //         if (isSelected) {
                      //           selectedProductIds.remove(_filteredProductGroupData[index]["item_code"]);
                      //         } else {
                      //           selectedProductIds.add(_filteredProductGroupData[index]["item_code"]);
                      //         }
                      //       }
                      //       print("products: $selectedProductIds");
                      //     });
                      //   },
                      //   child: Container(
                      //     child: Row(
                      //       children: <Widget>[
                      //         Expanded(
                      //           child: Container(
                      //             padding: EdgeInsets.only(bottom: 12, top: 12),
                      //             child: Text(
                      //               displayText,
                      //               maxLines: 3,
                      //               style: TextStyle(
                      //                 fontSize: 16,
                      //                 color: Colors.black,
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //         isSelected
                      //             ? Icon(Icons.check_box, color: AppColors.main_color)
                      //             : Container(),
                      //       ],
                      //     ),
                      //   ),
                      // );
                    },
                    itemCount: _filteredProductGroupData.length,
                  ),

                  // child: ListView.builder(
                  //   padding: EdgeInsets.all(10.0),
                  //   itemBuilder: (context, index) {
                  //     String itemDesc = _filteredProductGroupData[index]["item_desc"] ?? '';
                  //     String mrpRate = _filteredProductGroupData[index]["mrp_rate"]?.toString() ?? '';
                  //
                  //     String displayText = mrpRate.isEmpty
                  //         ? '$itemDesc (Rates Are Not Available)'
                  //         : '$itemDesc';
                  //
                  //     bool isSelected = selectedProductIds.contains(_filteredProductGroupData[index]["item_code"]);
                  //
                  //     return InkWell(
                  //       onTap: () {
                  //         state(() {
                  //           if (isSelected) {
                  //             selectedProductIds.remove(_filteredProductGroupData[index]["item_code"]);
                  //           } else {
                  //             selectedProductIds.add(_filteredProductGroupData[index]["item_code"]);
                  //           }
                  //           print("products: $selectedProductIds");
                  //         });
                  //       },
                  //       child: Container(
                  //         child: Row(
                  //           children: <Widget>[
                  //             Expanded(
                  //               child: Container(
                  //                 padding: EdgeInsets.only(bottom: 12, top: 12),
                  //                 child: Text(
                  //                   displayText,
                  //                   maxLines: 3,
                  //                   style: TextStyle(
                  //                     fontSize: 16,
                  //                     color: Colors.black,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //             isSelected
                  //                 ? Icon(Icons.check_box, color: AppColors.main_color)
                  //                 : Container(),
                  //           ],
                  //         ),
                  //       ),
                  //     );
                  //   },
                  //   itemCount: _filteredProductGroupData.length,
                  // ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
  List<Map<String, dynamic>> allSelectedProducts = [];
  showFGOCardDialog() async {
    // selectedProductIds.clear();
    // List<String> selectedProductIds = [];
    await showModalBottomSheet(
        constraints: BoxConstraints.loose(Size(
            MediaQuery.of(context).size.width,
            //MediaQuery.of(context).size.height * 0.85)),
            MediaQuery.of(context).size.height * 0.85)),
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(builder: (context, state) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children : [
                        // Container(
                        //   padding: EdgeInsets.only(right:10),
                        //     child: IconButton(onPressed: () {
                        //     Navigator.pop(context);
                        //     },
                        //     icon: Icon(Icons.close),
                        //   )),
                        Container(
                          padding: EdgeInsets.all(10),
                          child:Text("FGO Request",style:TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                        ),
                        Divider(),
                        SizedBox(height:5),
                        Expanded(
                          // height: MediaQuery.of(context).size.height - 300,
                          child: ListView.builder(
                            // itemCount: productDetails.length,
                            // itemBuilder: (context, index) {
                            //   final discountValue = productDetails[index]['discount_value'] ?? 'N/A';
                            //   final inclusiveExclusive = productDetails[index]['inclusive_exclusive'] ?? 'N/A';
                            //   final discountOn = productDetails[index]['discount_on'] ?? 'N/A';
                            //   final fgoType = productDetails[index]['fgo_type'] ?? 'N/A';
                            //   final itemDesc = productDetails[index]['item_desc'] ?? 'N/A';
                            //   final quantityController = quantityControllers[index];
                            itemCount: allSelectedProducts.length,
                            itemBuilder: (context, index) {
                              final product = allSelectedProducts[index];
                              final discountValue = product['discount_value'] ?? 'N/A';
                              final inclusiveExclusive = product['inclusive_exclusive'] ?? 'N/A';
                              final discountOn = product['discount_on'] ?? 'N/A';
                              final fgoType = product['fgo_type'] ?? 'N/A';
                              final itemDesc = product['item_desc'] ?? 'N/A';
                              final netfixedrate = product['net_fixedrate'] ?? 'N/A';
                              // Ensure controllers are available before accessing
                              final quantityController = index < quantityControllers.length
                                  ? quantityControllers[index]
                                  : TextEditingController();
                              final fgoValueController = index < fgoValueControllers.length
                                  ? fgoValueControllers[index]
                                  : TextEditingController();
                              final invoiceValueController = index < invoiceValueControllers.length
                                  ? invoiceValueControllers[index]
                                  : TextEditingController();

                              // Calculate the display value for Discount On based on FGO type
                              String displayDiscountOn;
                              if (fgoType == 'Extra Scheme') {
                                if (inclusiveExclusive == 'exclusive') {
                                  displayDiscountOn = (double.parse(discountOn) + (discountValue)).toString();
                                } else {
                                  displayDiscountOn = discountOn;
                                }
                              } else {
                                displayDiscountOn = discountOn;
                              }

                              return Container(
                                // height: MediaQuery.of(context).size.height - 200,
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.all(10),
                                child: Stack(
                                  children: [
                                if (fgoType == 'Rate Difference' || fgoType == 'Trade Discount' || fgoType == 'Extra Scheme' || fgoType == 'Fixed Rate') ...[
                                 Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                        if (fgoType == 'Rate Difference' || fgoType == 'Trade Discount' || fgoType == 'Extra Scheme' || fgoType == 'Fixed Rate') ...[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    itemDesc,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.blueAccent,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    // Ensure index is valid
                                                    if (index >= 0 && index < allSelectedProducts.length) {
                                                      // Get the product ID
                                                      String productId = allSelectedProducts[index]["item_code"].toString();

                                                      // Remove the product ID from the selectedProductIds list
                                                      selectedProductIds.remove(productId);

                                                      // Remove the product from the list
                                                      allSelectedProducts.removeAt(index);

                                                      // Remove the entries from the maps
                                                      productQuantities.remove(productId);
                                                      productFgoValues.remove(productId);
                                                      productInvoiceValues.remove(productId);

                                                      // Dispose of the controllers associated with the removed product
                                                      quantityControllers[index].dispose();
                                                      fgoValueControllers[index].dispose();
                                                      invoiceValueControllers[index].dispose();

                                                      // Remove the disposed controllers from the list
                                                      quantityControllers.removeAt(index);
                                                      fgoValueControllers.removeAt(index);
                                                      invoiceValueControllers.removeAt(index);

                                                      // Recalculate total FGO and update state
                                                      calculateTotalFGO();
                                                      state(() {}); // Trigger a UI update
                                                      print("Removed product: $productId");
                                                    } else {
                                                      print("Invalid index for product removal");
                                                    }
                                                  },
                                                  child: Icon(Icons.close, color: Colors.red),
                                                ),
                                              ],
                                            ),],
                                            SizedBox(height: 5),
                                            // if (fgoType == 'Extra Scheme' ||
                                            //     fgoType == 'Rate Difference' ||
                                            //     fgoType == 'Free Goods') ...[
                                            //   Row(
                                            //     children: [
                                            //       Expanded(
                                            //         flex: 4, // Adjust flex as needed
                                            //         child: Text(
                                            //           'FGO Type',
                                            //           style: TextStyle(
                                            //             fontSize: 16,
                                            //             fontWeight: FontWeight.bold, // Bold label
                                            //           ),
                                            //         ),
                                            //       ),
                                            //       Expanded(
                                            //         // flex: 1, // Adjust flex to center the colon
                                            //         child: Text(
                                            //           ':',
                                            //           textAlign: TextAlign.center,
                                            //           style: TextStyle(
                                            //             fontSize: 16,
                                            //             color: Colors.black, // Normal colon
                                            //           ),
                                            //         ),
                                            //       ),
                                            //       Expanded(
                                            //         flex: 3, // Adjust flex as needed
                                            //         child: Text(
                                            //           '$fgoType',
                                            //           textAlign: TextAlign.start,
                                            //           style: TextStyle(
                                            //             fontSize: 16,
                                            //             fontWeight: FontWeight.normal,
                                            //             color: Colors.black, // Normal value
                                            //           ),
                                            //         ),
                                            //       ),
                                            //     ],
                                            //   ),
                                            //   if (fgoType != 'Free Goods')
                                            //     Row(
                                            //       children: [
                                            //         Expanded(
                                            //           flex: 4,
                                            //           child: Text(
                                            //             'Discount Value',
                                            //             style: TextStyle(
                                            //               fontSize: 16,
                                            //               fontWeight: FontWeight.bold, // Bold label
                                            //             ),
                                            //           ),
                                            //         ),
                                            //         Expanded(
                                            //           //  flex: 1,
                                            //           child: Text(
                                            //             ':',
                                            //             textAlign: TextAlign.center,
                                            //             style: TextStyle(
                                            //               fontSize: 16,
                                            //               color: Colors.black, // Normal colon
                                            //             ),
                                            //           ),
                                            //         ),
                                            //         Expanded(
                                            //           flex: 3,
                                            //           child: Text(
                                            //             '$discountValue',
                                            //             textAlign: TextAlign.start,
                                            //             style: TextStyle(
                                            //               fontSize: 16,
                                            //               fontWeight: FontWeight.normal,
                                            //               color: Colors.black, // Normal value
                                            //             ),
                                            //           ),
                                            //         ),
                                            //       ],
                                            //     ),
                                            //   if (fgoType == 'Free Goods') ...[
                                            //     Row(
                                            //       children: [
                                            //         Expanded(
                                            //           flex: 4,
                                            //           child: Text(
                                            //             'Inclusive/Exclusive',
                                            //             style: TextStyle(
                                            //               fontSize: 16,
                                            //               fontWeight: FontWeight.bold, // Bold label
                                            //             ),
                                            //           ),
                                            //         ),
                                            //         Expanded(
                                            //           // flex: 1,
                                            //           child: Text(
                                            //             ':',
                                            //             textAlign: TextAlign.center,
                                            //             style: TextStyle(
                                            //               fontSize: 16,
                                            //               color: Colors.black, // Normal colon
                                            //             ),
                                            //           ),
                                            //         ),
                                            //         Expanded(
                                            //           flex: 3,
                                            //           child: Text(
                                            //             '$inclusiveExclusive',
                                            //             textAlign: TextAlign.start,
                                            //             style: TextStyle(
                                            //               fontSize: 16,
                                            //               fontWeight: FontWeight.normal,
                                            //               color: Colors.black, // Normal value
                                            //             ),
                                            //           ),
                                            //         ),
                                            //       ],
                                            //     ),
                                            //     Row(
                                            //       children: [
                                            //         Expanded(
                                            //           flex: 4,
                                            //           child: Text(
                                            //             'Total Goods',
                                            //             style: TextStyle(
                                            //               fontSize: 16,
                                            //               fontWeight: FontWeight.bold, // Bold label
                                            //             ),
                                            //           ),
                                            //         ),
                                            //         Expanded(
                                            //           //flex: 1,
                                            //           child: Text(
                                            //             ':',
                                            //             textAlign: TextAlign.center,
                                            //             style: TextStyle(
                                            //               fontSize: 16,
                                            //               color: Colors.black, // Normal colon
                                            //             ),
                                            //           ),
                                            //         ),
                                            //         Expanded(
                                            //           flex: 3,
                                            //           child: Text(
                                            //             '$discountOn',
                                            //             textAlign: TextAlign.start,
                                            //             style: TextStyle(
                                            //               fontSize: 16,
                                            //               fontWeight: FontWeight.normal,
                                            //               color: Colors.black, // Normal value
                                            //             ),
                                            //           ),
                                            //         ),
                                            //       ],
                                            //     ),
                                            //   ],
                                            //   Row(
                                            //     children: [
                                            //       Expanded(
                                            //         flex: 4,
                                            //         child: Text(
                                            //           'Quantity',
                                            //           style: TextStyle(
                                            //             fontSize: 16,
                                            //             fontWeight: FontWeight.bold,
                                            //           ),
                                            //         ),
                                            //       ),
                                            //       Expanded(
                                            //         child: Text(
                                            //           ':',
                                            //           textAlign: TextAlign.center,
                                            //           style: TextStyle(
                                            //             fontSize: 16,
                                            //             color: Colors.black,
                                            //           ),
                                            //         ),
                                            //       ),
                                            //       Expanded(
                                            //         flex: 3,
                                            //         child:
                                            //         SizedBox(
                                            //           height: 23,
                                            //           width: 100,
                                            //           child: TextField(
                                            //             controller: quantityController,
                                            //             keyboardType: TextInputType.number,
                                            //             textAlign: TextAlign.start,
                                            //             decoration: InputDecoration(
                                            //               border: OutlineInputBorder(),
                                            //               contentPadding: EdgeInsets.symmetric(vertical: 8),
                                            //             ),
                                            //             onChanged: (value) {
                                            //               final newValue = int.tryParse(value);
                                            //               if (newValue != null && newValue >= 0) {
                                            //                 quantityController.text = newValue.toString();
                                            //                 quantityController.selection = TextSelection.fromPosition(
                                            //                   TextPosition(offset: quantityController.text.length),
                                            //                 );
                                            //                 if (_onQuantityChanged != null) {
                                            //                   _onQuantityChanged(index);
                                            //                   // _tabController.index = 3;
                                            //                   state((){});
                                            //                 }
                                            //               } else if (value.isEmpty) {
                                            //                 quantityController.text = '0';
                                            //                 if (_onQuantityChanged != null) {
                                            //                   _onQuantityChanged(index);
                                            //                   // _tabController.index = 3;
                                            //                   state((){});
                                            //                 }
                                            //               }
                                            //             },
                                            //           ),
                                            //         ),
                                            //       ),
                                            //     ],
                                            //   ),
                                            //   Row(
                                            //     children: [
                                            //       Expanded(
                                            //         flex: 4,
                                            //         child: Text(
                                            //           'Invoice Value',
                                            //           style: TextStyle(
                                            //             fontSize: 16,
                                            //             fontWeight: FontWeight.bold, // Bold label
                                            //           ),
                                            //         ),
                                            //       ),
                                            //       Expanded(
                                            //         //flex: 1,
                                            //         child: Text(
                                            //           ':',
                                            //           textAlign: TextAlign.center,
                                            //           style: TextStyle(
                                            //             fontSize: 16,
                                            //             color: Colors.black, // Normal colon
                                            //           ),
                                            //         ),
                                            //       ),
                                            //       Expanded(
                                            //         flex: 3,
                                            //         child:
                                            //
                                            //         SizedBox(
                                            //           height: 24,
                                            //           width: 100,
                                            //           child: TextField(
                                            //             controller: invoiceValueControllers[index],
                                            //             decoration: InputDecoration(
                                            //               border: OutlineInputBorder(),
                                            //             ),
                                            //             readOnly: true,
                                            //             // enabled: false,
                                            //           ),
                                            //         ),
                                            //       ),
                                            //     ],
                                            //   ),
                                            //   Row(
                                            //     children: [
                                            //       Expanded(
                                            //         flex: 4,
                                            //         child: Text(
                                            //           'FGO Value',
                                            //           style: TextStyle(
                                            //             fontSize: 16,
                                            //             fontWeight: FontWeight.bold, // Bold label
                                            //           ),
                                            //         ),
                                            //       ),
                                            //       Expanded(
                                            //         //  flex: 1,
                                            //         child: Text(
                                            //           ':',
                                            //           textAlign: TextAlign.center,
                                            //           style: TextStyle(
                                            //             fontSize: 16,
                                            //             color: Colors.black, // Normal colon
                                            //           ),
                                            //         ),
                                            //       ),
                                            //       Expanded(
                                            //         flex: 3,
                                            //         child:
                                            //         SizedBox(
                                            //           height: 24,
                                            //           width: 100,
                                            //           child: TextField(
                                            //             controller: fgoValueControllers[index],
                                            //             // enabled: false,
                                            //             readOnly: true,
                                            //             decoration: InputDecoration(
                                            //               border: OutlineInputBorder(),
                                            //             ),
                                            //           ),
                                            //         ),
                                            //
                                            //       ),
                                            //     ],
                                            //   ),
                                            // ],
                                            if (fgoType == 'Rate Difference' || fgoType == 'Trade Discount' || fgoType == 'Extra Scheme' || fgoType == 'Fixed Rate') ...[
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      'FGO Type',
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      ':',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(fontSize: 16, color: Colors.black),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      '$fgoType',
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // if (fgoType == 'Fixed Rate') ...[
                                              //   Row(
                                              //     children: [
                                              //       Expanded(
                                              //         flex: 4,
                                              //         child: Text(
                                              //           'Net/Fixed Rate',
                                              //           style: TextStyle(
                                              //             fontSize: 16,
                                              //             fontWeight: FontWeight
                                              //                 .bold, // Bold label
                                              //           ),
                                              //         ),
                                              //       ),
                                              //       Expanded(
                                              //         // flex: 1,
                                              //         child: Text(
                                              //           ':',
                                              //           textAlign: TextAlign
                                              //               .center,
                                              //           style: TextStyle(
                                              //             fontSize: 16,
                                              //             color: Colors
                                              //                 .black, // Normal colon
                                              //           ),
                                              //         ),
                                              //       ),
                                              //       Expanded(
                                              //         flex: 3,
                                              //         child: Text(
                                              //           '$netfixedrate',
                                              //           textAlign: TextAlign
                                              //               .start,
                                              //           style: TextStyle(
                                              //             fontSize: 16,
                                              //             fontWeight: FontWeight
                                              //                 .normal,
                                              //             color: Colors
                                              //                 .black, // Normal value
                                              //           ),
                                              //         ),
                                              //       ),
                                              //     ],
                                              //   ),
                                              // ],
                                              if (fgoType == 'Extra Scheme') ...[
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                        'Inclusive/Exclusive',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight
                                                              .bold, // Bold label
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      // flex: 1,
                                                      child: Text(
                                                        ':',
                                                        textAlign: TextAlign
                                                            .center,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors
                                                              .black, // Normal colon
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                        '$inclusiveExclusive',
                                                        textAlign: TextAlign
                                                            .start,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight
                                                              .normal,
                                                          color: Colors
                                                              .black, // Normal value
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                        'Total Goods',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold, // Bold label
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      // flex: 1,
                                                      child: Text(
                                                        ':',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black, // Normal colon
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                        '$displayDiscountOn',
                                                        textAlign: TextAlign.start,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.normal,
                                                          color: Colors.black, // Normal value
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),],
                                              if (fgoType == 'Rate Difference') ...[
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                        'Discount On',
                                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        ':',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(fontSize: 16, color: Colors.black),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                        '$discountOn',
                                                        textAlign: TextAlign.start,
                                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
                                                      ),
                                                    ),
                                                  ],
                                                )],
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      fgoType == 'Extra Scheme' ? 'Free Goods' : 'Discount Value',
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      ':',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(fontSize: 16, color: Colors.black),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      '$discountValue',
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      'Quantity',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      ':',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child:
                                                    SizedBox(
                                                      height: 23,
                                                      width: 100,
                                                      child: TextField(
                                                        controller: quantityController,
                                                        //keyboardType: TextInputType.number,
                                                        keyboardType: TextInputType.number,
                                                        inputFormatters: <TextInputFormatter>[
                                                          FilteringTextInputFormatter.digitsOnly
                                                        ],
                                                        textAlign: TextAlign.start,
                                                        decoration: InputDecoration(
                                                          border: OutlineInputBorder(),
                                                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                                                        ),
                                                        onChanged: (value) {
                                                          final newValue = int.tryParse(value);
                                                          if (newValue != null && newValue >= 0) {
                                                            quantityController.text = newValue.toString();
                                                            quantityController.selection = TextSelection.fromPosition(
                                                              TextPosition(offset: quantityController.text.length),
                                                            );
                                                            if (_onQuantityChanged != null) {
                                                              _onQuantityChanged(index);
                                                              // _tabController.index = 3;
                                                              state((){});
                                                            }
                                                          } else if (value.isEmpty) {
                                                            quantityController.text = '0';
                                                            if (_onQuantityChanged != null) {
                                                              _onQuantityChanged(index);
                                                              // _tabController.index = 3;
                                                              state((){});
                                                            }
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      'Invoice Value',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold, // Bold label
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    //flex: 1,
                                                    child: Text(
                                                      ':',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black, // Normal colon
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child:
                                                    SizedBox(
                                                      height: 24,
                                                      width: 100,
                                                      child: TextField(
                                                        controller: invoiceValueControllers[index],
                                                        decoration: InputDecoration(
                                                          border: OutlineInputBorder(),
                                                        ),
                                                        readOnly: true,
                                                        // enabled: false,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      'FGO Value',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold, // Bold label
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    //  flex: 1,
                                                    child: Text(
                                                      ':',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black, // Normal colon
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child:
                                                    SizedBox(
                                                      height: 24,
                                                      width: 100,
                                                      child: TextField(
                                                        controller: fgoValueControllers[index],
                                                        // enabled: false,
                                                        readOnly: true,
                                                        decoration: InputDecoration(
                                                          border: OutlineInputBorder(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left:10),
                          height: 40,
                          alignment: Alignment.bottomLeft,
                          child: isShowRate || isShowRateEntryEditText
                              ? RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Total FGO: ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: totalFGOValue.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          )
                              : Container(),
                        ),
                        Container(
                            padding: EdgeInsets.only(left:10),
                            //  padding: EdgeInsets.all(10),
                            //   child:Row(
                            //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                            //     children: [
                            //       Container(
                            //         child: ElevatedButton(
                            //           onPressed: () async {
                            //             await pickFileAndUploadData();
                            //             _buttonLabel = '${_selectedFile.path.split('/').last}';
                            //             state(() {});
                            //           },
                            //           style: ElevatedButton.styleFrom(
                            //               elevation: 12.0,
                            //               textStyle: const TextStyle(color: Colors.white)),
                            //           child: Text(
                            //             _buttonLabel,
                            //             overflow: TextOverflow.ellipsis, // Add this to handle long text
                            //             maxLines: 1,
                            //           ),
                            //         ),
                            //       ),
                            //       Container(
                            //         // height: Constants_data.getHeight(context, 35),
                            //         child: MaterialButton(
                            //           color: Colors.blue[800],
                            //           child: Text(
                            //             "Save",
                            //             style: TextStyle(color: Colors.white),
                            //           ),
                            //           onPressed: () async{
                            //             Navigator.pop(context);
                            //             await saveProductsData();
                            //             //state((){});
                            //           },
                            //         ),
                            //       ),
                            //     ],
                            //   )
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns children to the edges
                              children: [
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerLeft, // Aligns the button to the left
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await pickFileAndUploadData();
                                        _buttonLabel = '${_selectedFile.path.split('/').last}';
                                        state(() {});
                                      },
                                      style: ElevatedButton.styleFrom(
                                          elevation: 12.0,
                                          textStyle: const TextStyle(color: Colors.white)),
                                      child: Text(
                                        _buttonLabel,
                                        overflow: TextOverflow.ellipsis, // Truncate text with an ellipsis
                                        maxLines: 1, // Ensure the text is on a single line
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.0), // Add some space between the buttons
                                Container(
                                  alignment: Alignment.centerRight, // Aligns the button to the right
                                  child: MaterialButton(
                                    color: Colors.blue[800],
                                    child: Text(
                                      "Save",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await saveProductsData();
                                      //Navigator.pop(context);
                                      //state((){});
                                    },
                                  ),
                                ),
                              ],
                            )

                        )
                      ]
                  )
              ),
            );

          });
        });
  }
  Future<void> sendemail() async {
    bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
    if (isNetworkAvailable) {
      String message;
      String requestNo = Constants_data.customerid;
      String url = '/Mail/SendEmail?request_no=$requestNo';  // Use relative path
      try {
        // Use the API helper to call the get method
        var mailData = await _helper.get(url);

        if (mailData["Status"] == 1) {
          loadingForsendmail = false;
          print("Email sent successfully");
          // message = "Email sent successfully";
          // showAlertDialog(message);
          showAlertDialog(mailData["Message"]);
        }
        else if (mailData["Status"] == 0) {
          loadingForsendmail = false;
          print("Email sending failed");
          showAlertDialog(mailData["Message"]);
        }
        else if (mailData["Status"] == 2) {
          print("Email sending failed: Status 2");
          message = "Email sending failed";
          showAlertDialog(message);
          loadingForsendmail = false;
        }
        else if (mailData["status"] == 3) {
          print("Email sending failed: Status 3");
          message = "Email sending failed";
          showAlertDialog(message);
          loadingForsendmail = false;
        }
        else {
          print("Unknown status received: ${mailData["Status"]}");
        }
      } catch (e) {
        // Handle any exceptions
        print("Error occurred: $e");
        // Update loading flag based on email sending status
        loadingForsendmail = false;
      }
    } else {
      await Constants_data.openDialogNoInternetConection(context);
    }
  }
  Future<void> approveFGO(selectedData) async {
    List<String> dtlCode = [];
    for (int i = 0; i < selectedData.length; i++) {
      dtlCode.add(selectedData[i]["doc_no"]);
    }
    final String url = '/Dashboard/SetApprovedDoctorDetails'; // Relative path since base URL will be concatenated

    Map<String, dynamic> requestBody = {
      "yearCode": selectedData[0]["year_code"],
      "monthCode": selectedData[0]["month_code"],
      "doctorCode": selectedData[0]["doctor_code"],
      "repCode": dataUser["RepId"],
      "designationCode": dataUser["Designation"],
      "stateCode": selectedData[0]["state_code"],
      "divisionCode": Constants_data.selectedDivisionId,
      "request_flag": "",
      "total_fgo_value": selectedData[0]["total_fgo_value"],
      "level1_approved": selectedData[0]["level1_approved"],
      "level2_approved": selectedData[0]["level2_approved"],
      "isLevel2Required": selectedData[0]["Is_level2_approval_required"],
      "detail_doc_no": dtlCode,
      "header_doc_no": selectedData[0]["CustomerId"],
      "comments": _messageController.text,
    };

    try {
      final responseJson = await _helper.postMethod(
          url,
          requestBody,
          true
      );

      if (responseJson != null) {
        if (responseJson["Status"] == 0) {
          print("FGO not Approved.");
          showAlertDialog(responseJson["Message"]);
        } else if (responseJson["Status"] == 1) {
          loadingForApproval = false;
          print("FGO Approved successfully.");
          showAlertDialog(responseJson["Message"]);
        } else if (responseJson["status"] == 3) {
          loadingForApproval = false;
          showAlertDialog(responseJson["message"]);
        } else if (responseJson["status"].toString() == "8") {
          print("There Is No Products for This Division");
          //showAlertDialog(responseJson["message"]);
          await StateManager.logout();
          Constants_data.selectedDivisionName = null;
          Constants_data.selectedDivisionId = null;
          Constants_data.selectedHQCode = null;
          Constants_data.repId = null;
          Constants_data.SessionId = null;
          Constants_data.app_user= null;
          await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,  // This removes all previous routes
          );
          //Navigator.pushReplacementNamed(context, "/Login");
        }
        else if (responseJson["status"].toString() == "4") {
          print("There Is No Products for This Division");
          showAlertDialog(responseJson["message"]);
          await StateManager.logout(); // Wait for logout to complete
          //await SharedPrefs.instance.deleteUser(); // Wait for deletion to complete
          Constants_data.selectedDivisionName = null;
          Constants_data.selectedDivisionId = null;
          Constants_data.selectedHQCode = null;
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
        else if (responseJson["status"].toString() == "5") {
          //showAlertDialog(responseJson["message"]);
          await StateManager.logout(); // Wait for logout to complete
          //await SharedPrefs.instance.deleteUser(); // Wait for deletion to complete
          Constants_data.selectedDivisionName = null;
          Constants_data.selectedDivisionId = null;
          Constants_data.selectedHQCode = null;
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
        else {
          showAlertDialog(responseJson["Message"]);
        }
      } else {
        print('Failed to load details');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  Future<void> rejectFGOapproval(listData) async {
    final String url = '/Dashboard/RejectApprovalDetails'; // Relative path since base URL will be concatenated

    Map<String, dynamic> rejectiondetails = {
      "repId": dataUser["RepId"],
      "docNo":listData[0]["CustomerId"],
    };

    try {
      final responseJson = await _helper.postMethod(
          url,
          rejectiondetails,
          true // Indicating that requestBody should be converted to JSON
      );

      if (responseJson != null) {
        if (responseJson["Status"] == 0) {
          print("FGO not Rejected.");
          showAlertDialog(responseJson["Message"]);
        } else if (responseJson["Status"] == 1) {
          loadingForReject = false;
          print("FGO Rejected successfully.");
          showAlertDialog(responseJson["Message"]);
        } else if (responseJson["status"] == 3) {
          showAlertDialog(responseJson["Message"]);
        } else {
          showAlertDialog(responseJson["Message"]);
        }
      } else {
        print('Failed to load details');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  void _showDropdown(BuildContext context) async{
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200, // Set your desired height here
          child: ListView.builder(
            itemCount: divisions.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(divisions[index]["division_desc"]),
                onTap: () {
                  //  selectedDivision = divisions[index]["division_id"];
                  setState(() {
                    selectedDivision = divisions[index]["division_id"];
                    print("Selected Division ID: $selectedDivision");
                  });
                  // getMenu();
                  // selectedDivision = divisions[index]["division_id"];
                  Navigator.pop(context); // Close the dropdown
                },
              );
            },
          ),
        );
      },
    );
  }
  // Future<void> getDivisionData() async {
  //   final String url = 'http://122.170.7.252/MicroDishaWebApiPublish/api/Dashboard/GetDivisionListRepWise?repId=${dataUser["RepId"]}';
  //   Map<String, String> headers = {
  //     "Content-type": "application/json",
  //     "Authorization": Constants_data.SessionId,
  //     "CountryCode": Constants_data.Country,
  //     "IPAddress": Constants_data.deviceId,
  //     "UserId": Constants_data.repId,
  //
  //   };
  //   try {
  //     final response = await http.get(Uri.parse(url), headers: headers);
  //     if (response.statusCode == 200) {
  //       var divisiondata = jsonDecode(response.body);
  //       List<dynamic> divisionList = divisiondata["dt_ReturnedTables"][0];
  //       setState(() {
  //         divisions = divisionList.map((division) {
  //           return {
  //             "division_id": division["division_id"],
  //             "division_desc": division["division_desc"]
  //           };
  //         }).toList();
  //       });
  //       print('Division Data: $divisions');
  //     } else {
  //       print('Failed to load division data');
  //     }
  //   } catch (error) {
  //     print('Error: $error');
  //   }
  // }
  Future<void> getProductNames() async {
    bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
    if (isNetworkAvailable) {
      String message;
      String url = '/Dashboard/GetProductNames?repId=${dataUser["RepId"]}&divisionCode=${Constants_data.selectedDivisionId}'; // Relative URL

      try {
        // Use the helper to call the API
        var productsData = await _helper.get(url);

        if (productsData["Status"] == 0) {
          print("There Is No Data for This Product");
          showAlertDialog(productsData["Message"]);
        }
        else if (productsData["Status"] == 1) {
          print("Data fetched successfully");
        }
        else if (productsData["Status"] == 2) {
          showAlertDialog(productsData["Message"]);
        }
        else if (productsData["status"].toString() == "8") {
          print("There Is No Products for This Division");
          //showAlertDialog(productsData["message"]);
          await StateManager.logout();
          Constants_data.selectedDivisionName = null;
          Constants_data.selectedDivisionId = null;
          Constants_data.selectedHQCode = null;
          Constants_data.repId = null;
          Constants_data.SessionId = null;
          Constants_data.app_user= null;
          await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,  // This removes all previous routes
          );
          //Navigator.pushReplacementNamed(context, "/Login");
        }
        else if (productsData["status"].toString() == "4") {
          print("There Is No Products for This Division");
          showAlertDialog(productsData["message"]);
          await StateManager.logout(); // Wait for logout to complete
         // await SharedPrefs.instance.deleteUser(); // Wait for deletion to complete
          Constants_data.selectedDivisionName = null;
          Constants_data.selectedDivisionId = null;
          Constants_data.selectedHQCode = null;
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
        else if (productsData["status"].toString() == "5") {
          //showAlertDialog(productsData["message"]);
          await StateManager.logout(); // Wait for logout to complete
          //await SharedPrefs.instance.deleteUser(); // Wait for deletion to complete
          Constants_data.selectedDivisionName = null;
          Constants_data.selectedDivisionId = null;
          Constants_data.selectedHQCode = null;
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

        productGroupData = productsData["dt_ReturnedTables"][0];
        _filteredProductGroupData = productGroupData;
        print('Product Names: $productGroupData');

        // Initialize controllers for each product
        listController = [];
        for (int i = 0; i < productGroupData.length; i++) {
          productGroupData[i]["selected"] = "false";
          productGroupData[i]["txtValue"] = "";
          productGroupData[i]["qty"] = 0;
          productGroupData[i]["total"] = 0;
          TextEditingController cnt = TextEditingController();
          listController.add(cnt);
        }
        await showSampleProductList();  // Show product list
      } catch (error) {
        print('Error: $error');
      }
    } else {
      await Constants_data.openDialogNoInternetConection(context);
    }
  }
// Declare a global variable to store all selected product details
  List<Map<String, dynamic>> allProductDetails = [];
  Map<String, String> productQuantities = {};
  Map<String, String> productFgoValues = {};
  Map<String, String> productInvoiceValues = {};
  bool alertShown = false;
  Future<void> DisplayProductDetails(String customerId, List<String> productIds) async {
    String message;
    final String url = '/Dashboard/GetFGORequestProposalDetails'; // Relative URL
    Map<String, dynamic> requestBody = {
      "doctorCode": customerId,
      "productId": productIds,
      "divisionCode": Constants_data.selectedDivisionId,
    };

    try {
      // Use the helper to make the POST request
      var responsedata = await _helper.postMethod(
        url,
        requestBody,
        true, // isRequiredJsonString = true
      );
      if (responsedata["Status"] == 0) {
        // Clear selected product IDs and checkbox selections
        print("Selected products do not contain data.");
        //showAlertDialog1(responsedata["Message"]);
        // if (!alertShown) {
        //   print("Selected products do not contain data.");
        //   showAlertDialog1(responsedata["Message"]);
        //   // Set the flag to true so the alert is not shown again
        //   alertShown = true;
        // }
        // setState(() {
        //   selectedProductIds.clear();
        // });
        // Clear selection state inside setState to reflect UI changes
        setState(() {
          // selectedProductIds.clear(); // Clear the selected product IDs
          allSelectedProducts.clear(); // Clear any selected products
          productQuantities.clear();   // Clear product quantities if needed
          productFgoValues.clear();    // Clear FGO values
          productInvoiceValues.clear(); // Clear invoice values
        });
      }
      else if (responsedata["Status"] == 1) {
       // print('Response: $response');
        List<dynamic> rawProductData = responsedata["dt_ReturnedTables"][0];
        List<Map<String, dynamic>> newProductDetails = List<Map<String, dynamic>>.from(rawProductData);
        productDetails = List<Map<String, dynamic>>.from(rawProductData);

        // Remove products that were deselected
        allSelectedProducts.removeWhere((product) =>
        !productIds.contains(product["item_code"].toString()));

        // Add new products from the API response
        for (var product in productDetails) {
          String productId = product["item_code"].toString();
          bool alreadyExists = allSelectedProducts.any((existingProduct) =>
          existingProduct["item_code"].toString() == productId);
          if (!alreadyExists) {
            allSelectedProducts.add(product);

            // Initialize quantity if not already present
            if (!productQuantities.containsKey(productId)) {
              productQuantities[productId] = '';
              productFgoValues[productId] = '';
              productInvoiceValues[productId] = '';
            }
          }
        }

        // Remove values for deselected products
        productQuantities.removeWhere((productId, _) => !productIds.contains(productId));
        productFgoValues.removeWhere((productId, _) => !productIds.contains(productId));
        productInvoiceValues.removeWhere((productId, _) => !productIds.contains(productId));

        // Update productDetails with new data from API
        productDetails = productDetails;

        // Call any method to initialize or refresh your UI
        _initializeControllers();

        print('All Selected Products: $allSelectedProducts');
      }
      else if(responsedata["status"] == 3){
        print("Selected products does not contains data.");
        message = "Selected products does not contains data.";
        //showAlertDialog(message);
      }
      else if(responsedata["status"].toString == "8"){
        showAlertDialog(responsedata["message"]);
        await StateManager.logout();
        await SharedPrefs.instance.deleteUser();
        Constants_data.selectedDivisionName= null;
        Constants_data.selectedDivisionId = null;
        Constants_data.selectedHQCode = null;
        Constants_data.repId = null;
        Constants_data.SessionId = null;
        Constants_data.app_user= null;
        //await Navigator.pushReplacementNamed(context, "/Login");
        await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
              (Route<dynamic> route) => false,  // This removes all previous routes
        );
      }
      else if(responsedata["status"].toString == "4"){
        showAlertDialog(responsedata["message"]);
        await StateManager.logout();
        await SharedPrefs.instance.deleteUser();
        Constants_data.selectedDivisionName= null;
        Constants_data.selectedDivisionId = null;
        Constants_data.selectedHQCode = null;
        Constants_data.repId = null;
        Constants_data.SessionId = null;
        Constants_data.app_user= null;
        //await Navigator.pushReplacementNamed(context, "/Login");
        await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
              (Route<dynamic> route) => false,  // This removes all previous routes
        );
      }
      else if(responsedata["status"].toString == "5"){
        showAlertDialog(responsedata["message"]);
        await StateManager.logout(); // Wait for logout to complete
        //await SharedPrefs.instance.deleteUser(); // Wait for deletion to complete
        Constants_data.selectedDivisionName = null;
        Constants_data.selectedDivisionId = null;
        Constants_data.selectedHQCode = null;
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
      else {
        print('Failed to load product details');
      }
    } catch (error) {
      print('Error: $error');
    }

    print("Customer ID: $customerId");
    print("Selected Product IDs: $productIds");
  }

  double MRP = 0.0;
  double PTS = 0.0;
 // double discountValue = 0.0;
  double totalGoods = 0.0;
  String fgoType = '';
  String inclusiveExclusive = '';
  //String discontOn = '';
  double calC1 = 0.0;
  double calC2 = 0.0;

  void restorePreviousSelectio() {
    // Ensure all controllers are set up correctly and restore previous values
    for (int i = 0; i < allSelectedProducts.length; i++) {
      final productId = allSelectedProducts[i]["item_code"].toString();
        if (productQuantities.containsKey(productId)) {
          quantityControllers[i].text = productQuantities[productId] ?? '';
        }
        if (productFgoValues.containsKey(productId)) {
          String fgoValue = productFgoValues[productId] ?? '';

          // Check if the value is valid
          if (fgoValue.isNotEmpty) {
            double parsedFgoValue = double.parse(fgoValue);
            String formattedFgoValue = parsedFgoValue.toStringAsFixed(2);

            // Ensure the value is within the allowed length (9 digits + 2 decimals)
            if (formattedFgoValue.length <= 12) { // 9 digits + 1 decimal point + 2 decimal digits
              fgoValueControllers[i].text = formattedFgoValue;
            } else {
              // Handle cases where the number is too large by trimming the integer part
              String truncatedFgoValue = parsedFgoValue.toStringAsFixed(2)
                  .substring(0, 12);
              fgoValueControllers[i].text = truncatedFgoValue;
            }
          }
        }
        if (productInvoiceValues.containsKey(productId)) {
          String invoiceValue = productInvoiceValues[productId] ?? '';
          // Check if the value is valid
          if (invoiceValue.isNotEmpty) {
            double parsedInvoiceValue = double.parse(invoiceValue);
            String formattedInvoiceValue = parsedInvoiceValue.toStringAsFixed(
                2);
            // Ensure the value is within the allowed length (9 digits + 2 decimals)
            if (formattedInvoiceValue.length <=
                12) { // 9 digits + 1 decimal point + 2 decimal digits
              invoiceValueControllers[i].text = formattedInvoiceValue;
            } else {
              // Handle cases where the number is too large by trimming the integer part
              String truncatedInvoiceValue = parsedInvoiceValue.toStringAsFixed(
                  2).substring(0, 12);
              invoiceValueControllers[i].text = truncatedInvoiceValue;
            }
          }
        }
      }
    }
  void restorePreviousSelections() {
    // Ensure all controllers are set up correctly and restore previous values
    for (int i = 0; i < allSelectedProducts.length; i++) {
      final productId = allSelectedProducts[i]["item_code"].toString();

      // Check if the product's quantity is stored
      if (productQuantities.containsKey(productId)) {
        String quantity = productQuantities[productId] ?? '';
        quantityControllers[i].text = quantity; // Set quantity controller

        // If quantity is 0 or empty, set FGO and Invoice values to "0"
        if (quantity == "0" || quantity.isEmpty) {
          fgoValueControllers[i].text = " ";
          invoiceValueControllers[i].text = " ";
          quantityControllers[i].text = " ";
        } else {
          // If quantity is valid, restore FGO values
          if (productFgoValues.containsKey(productId)) {
            String fgoValue = productFgoValues[productId] ?? '';
            if (fgoValue.isNotEmpty) {
              double parsedFgoValue = double.parse(fgoValue);
              String formattedFgoValue = parsedFgoValue.toStringAsFixed(2);
              fgoValueControllers[i].text = formattedFgoValue.length <= 12
                  ? formattedFgoValue
                  : formattedFgoValue.substring(0, 12);
            }
          }
          // Restore invoice values similarly
          if (productInvoiceValues.containsKey(productId)) {
            String invoiceValue = productInvoiceValues[productId] ?? '';
            if (invoiceValue.isNotEmpty) {
              double parsedInvoiceValue = double.parse(invoiceValue);
              String formattedInvoiceValue = parsedInvoiceValue.toStringAsFixed(2);
              invoiceValueControllers[i].text = formattedInvoiceValue.length <= 12
                  ? formattedInvoiceValue
                  : formattedInvoiceValue.substring(0, 12);
            }
          }
        }
      }
    }
  }
  Future<void> _onQuantityChanged(int index) async {
    final productId = allSelectedProducts[index]["item_code"].toString();
    productQuantities[productId] = quantityControllers[index].text;
    // Retrieve product details for the calculation
    final product = allSelectedProducts[index];
    final discountValueString = product['discount_value']?.toString() ?? '0';
    final totalGoodsString = product['discount_on']?.toString() ?? '0';
    final tradeschemeString = product['free_goods']?.toString() ?? '0';
    final inclusiveExclusive = product['inclusive_exclusive'] ?? '';
    final fgoType = product['fgo_type'] ?? '';
    final discountValue = double.tryParse(discountValueString) ?? 0;
    final discountOn = double.tryParse(totalGoodsString) ?? 0;
    final tradescheme = double.tryParse(tradeschemeString) ?? 0;

    final PTS = double.tryParse(product['pts_rate']?.toString() ?? '0') ?? 0;
    final MRP = double.tryParse(product['mrp_rate']?.toString() ?? '0') ?? 0;
    final PTD= double.tryParse(product['ptd_rate']?.toString() ?? '0') ?? 0;
    final PTR = double.tryParse(product['ptr_rate']?.toString() ?? '0') ?? 0;

    Map<String, dynamic> valuemap = {
      "MRP": MRP,
      "PTS": PTS,
      "PTD": PTD,
      "PTR": PTR,
    };

    double discountOnValue = 0;
    if (fgoType == 'Rate Difference') {
       discountOnValue = valuemap[totalGoodsString] ?? 0;
    }

    final double quantity = double.tryParse(quantityControllers[index].text) ?? 0;
    // Ensure quantity is valid
    if (quantity <= 0 || quantity == "") {
      quantityControllers[index].clear(); // Clear the input field
      fgoValueControllers[index].clear();
      invoiceValueControllers[index].clear();
      calculateTotalFGO();
      return; // Exit the function early if quantity is invalid
    }

    // Calculate FGO value and Invoice value based on the FGO type
    double fgoValue = calculateFgoValue(
      quantity,
      PTS,
      discountValue, discountOn,
      fgoType,
      inclusiveExclusive,
      discountOnValue,
        tradescheme
    );

    double invoiceValue = calculateInvoiceValue(
      quantity,
      PTS,
      discountValue,
      discountOn,
      fgoType,
    );

    // Store calculated values
    productFgoValues[productId] = fgoValue.toString();
    productInvoiceValues[productId] = invoiceValue.toString();

    // Update controllers
    setState(() {
      fgoValueControllers[index].text = fgoValue.toStringAsFixed(2);
      invoiceValueControllers[index].text = invoiceValue.toStringAsFixed(2);
    });

    // Recalculate total FGO value
    calculateTotalFGO();
  }
  double calculateFgoValue(
      double quantity,
      double PTS,
      double discountValue,
      double discountOn,
      String fgoType,
      String inclusiveExclusive,
      double discountOnValue,
      double tradescheme,
      ) {
    double fgoValue = 0.0;

    if (fgoType == 'Rate Difference') { //es//
      fgoValue = (PTS - (discountValue / 100 * discountOnValue)) * quantity;
    }
    else if (fgoType == 'Trade Discount') { //rd//`
      //fgoValue = (PTS - discountValue) * quantity;
      fgoValue = (quantity * PTS) * (discountValue/100);
    }else if (fgoType == 'Fixed Rate') {
      fgoValue = (PTS - discountValue) * quantity;
    }
    else if (fgoType == 'Extra Scheme') {
      // var TOTAL = discountValue + totalGoods;
      var TOTAL = discountOn + discountValue;
      // if (inclusiveExclusive == 'inclusive') {
      //   fgoValue = (quantity * (discountValue / TOTAL) * PTS);
      // } else if (inclusiveExclusive == 'exclusive') {fgoValue = PTS * discountValue;}

      // var calC1;
      // var calC2;
      if (inclusiveExclusive == 'inclusive') {
         calC1 = (quantity * (discountValue / (TOTAL)));
        if (tradescheme == 0) {
           calC2 = 0;
        }
        else {
           calC2 = (quantity * (tradescheme / (discountOn + tradescheme)));
        }
        fgoValue = (calC1 - calC2) * PTS;
      }
    }
    return fgoValue;
  }

  double calculateInvoiceValue(double quantity, double PTS, double discountValue, double discountOn, String fgoType) {
    if (fgoType == 'Extra Scheme') {
      calC1 = (quantity * (discountValue / (discountOn + discountValue)));
      return calC1 * quantity;
    } else {
      return PTS * quantity;
    }
  }

  // Future<void> _onQuantityChanged(int index) async {
  // //  final product = productDetails[index];
  //   final productId = allSelectedProducts[index]["item_code"].toString();
  //   productQuantities[productId] = quantityControllers[index].text;
  //   // Recalculate FGO value and invoice value based on quantity
  //   double fgoValue = calculateFgoValue(quantityControllers[index].text);
  //   double invoiceValue = calculateInvoiceValue(quantityControllers[index].text);
  //   productFgoValues[productId] = fgoValue.toString();
  //   productInvoiceValues[productId] = invoiceValue.toString();
  //   // Update controllers
  //   fgoValueControllers[index].text = productFgoValues[productId] ?? '';
  //   invoiceValueControllers[index].text = productInvoiceValues[productId] ?? '';
  //
  //   final product = allSelectedProducts[index];
  //   final discountValueString = product['discount_value']?.toString() ?? '0';
  //   final totalGoodsString = product['discount_on']?.toString() ?? '0';
  //   final String inclusiveExclusive = product['inclusive_exclusive'] ?? '';
  //   final double quantity = double.tryParse(quantityControllers[index].text) ?? 0;
  //    fgoType = product['fgo_type'] ?? '';
  //    discountValue = double.tryParse(discountValueString) ?? 0;
  //    totalGoods = double.tryParse(totalGoodsString) ?? 0;
  //    PTS = double.tryParse(product['pts_rate']?.toString() ?? '0') ?? 0;
  //    MRP = double.tryParse(product['mrp_rate']?.toString() ?? '0') ?? 0;
  //   // double fgoValue = 0;
  //   // double invoiceValue = 0;
  //
  //   // Ensure quantity is valid
  //   if (quantity <= 0) {
  //     quantityControllers[index].clear(); // Clear the input field
  //     return; // Exit the function early if quantity is invalid
  //   }
  //   // Calculate FGO value and Invoice value based on the FGO type
  //   if (fgoType == 'Extra Scheme') {
  //     fgoValue = (PTS - (discountValue / 100 * totalGoods)) * quantity;
  //     invoiceValue = PTS * quantity;
  //   }
  //   else if (fgoType == 'Rate Difference') {
  //     fgoValue = (PTS - discountValue) * quantity;
  //     invoiceValue = PTS * quantity;
  //   }
  //   else if (fgoType == 'Free Goods') {
  //     var TOTAL = discountValue + totalGoods;
  //     if (inclusiveExclusive == 'inclusive') {
  //       fgoValue = (quantity * (discountValue / TOTAL) * PTS);
  //       invoiceValue = PTS * quantity;
  //     }
  //     else if (inclusiveExclusive == 'Exclusive') {
  //       fgoValue = PTS * discountValue;
  //       invoiceValue = PTS * quantity;
  //     }
  //   }
  //   fgoValueControllers[index].text = fgoValue.toStringAsFixed(2);
  //   invoiceValueControllers[index].text = invoiceValue.toStringAsFixed(2);
  //   calculateTotalFGO();
  //   // setState((){});
  // }
  //
  // double calculateFgoValue(String quantity) {
  //   return double.parse(quantity) * 10.0; // Example logic
  // }
  //
  // double calculateInvoiceValue(String quantity) {
  //   return double.parse(quantity) * 20.0; // Example logic
  // }
  double totalFGOValue = 0.0;
  void calculateTotalFGO() {
    double totalFGO = 0.0;

    for (var controller in fgoValueControllers) {
      final fgoValue = double.tryParse(controller.text) ?? 0.0;
      totalFGO += fgoValue;
    }
    totalFGOValue = totalFGO;
    print("Calculated Total FGO: $totalFGOValue");
    // });
  }
  void removeCard(int index) {
    productDetails.removeAt(index);
    quantityControllers[index].dispose();
    fgoValueControllers[index].dispose();
    invoiceValueControllers[index].dispose();
    quantityControllers.removeAt(index);
    fgoValueControllers.removeAt(index);
    invoiceValueControllers.removeAt(index);
  }
  void _initializeControllers() {
    // Clear existing controllers
    for (var controller in quantityControllers) {
      controller.dispose();
    }
    for (var controller in fgoValueControllers) {
      controller.dispose();
    }
    for (var controller in invoiceValueControllers) {
      controller.dispose();
    }
    quantityControllers.clear();
    fgoValueControllers.clear();
    invoiceValueControllers.clear();

    // Initialize controllers with existing data
    for (var product in allSelectedProducts) {
      final String productId = product["item_code"].toString();
      final quantityController = TextEditingController();
      final fgoValueController = TextEditingController();
      final invoiceValueController = TextEditingController();

      // Set initial value for quantity, FGO value, and invoice value if available
      quantityController.text = productQuantities[productId] ?? '';
      fgoValueController.text = productFgoValues[productId] ?? '';
      invoiceValueController.text = productInvoiceValues[productId] ?? '';

      quantityControllers.add(quantityController);
      fgoValueControllers.add(fgoValueController);
      invoiceValueControllers.add(invoiceValueController);
    }
    print('Controllers initialized and state updated');
  }
  Future<void> saveProductsData() async {
    String message;
    // Ensure product details are provided
    if (productDetails == null || productDetails.isEmpty) {
      showAlertDialog('Please Select Product.');
      return;
    }
    List<Map<String, dynamic>> productsDatanew = [];
    for (int i = 0; i < allSelectedProducts.length; i++) {
      final product = allSelectedProducts[i];
      final quantity = quantityControllers[i].text;

      if (quantity == null || quantity.isEmpty) {
        showAlertDialog('Please enter quantity for product ${product['item_desc']}');
        return;
      }

      final discountOn = product['discount_on'].toString();
      final discountValue = product['discount_value'].toString();
      final invoiceValue = invoiceValueControllers[i].text;
      final fgoValue = fgoValueControllers[i].text;
      final fgoType = product['fgo_type'].toString();
      final itemDesc = product['item_desc'].toString();
      final itemCode = selectedProductIds[i].toString();

      productsDatanew.add({
        'productCode': itemCode,
        'schemeType': fgoType,
        'quantity': quantity,
        'discountOn': discountOn,
        'discountValue': discountValue,
        'invoiceValue': invoiceValue,
        'fgoValue': fgoValue,
      });
    }
    DateTime now = DateTime.now();
    var proposalRequestDetails = {
      'docType_Header': 'FGOHeader',
      'docType_Detail': 'FGODetail',
      "docType_Approve": "FGOApprove",
      'yearCode': '24-25',
      'month': "${DateFormat('MM').format(now)}",
      'repCode': Constants_data.repId,
      'doctorCode': Constants_data.customerid,
      'supplyThrough': '',
      'distributorCode': '',
      'RequestDetails': productsDatanew,
      'divisionCode': Constants_data.selectedDivisionId,
      'stateCode': dataUser["employee_state"],
      'hqCode': Constants_data.selectedHQCode,
      'totalFgoValue': '0'
    };

    // if (_selectedFile == null) {
    //   showAlertDialog('Please select a file to upload.');
    //   return;
    // }
    File selectedFile;
    if (_selectedFile != null) {
      try {
        // Create a File object from the selected file path
        selectedFile = File(_selectedFile.path);
      } catch (e) {
        print('Error reading file: $e');
        Constants_data.toastError('Error reading file.');
        return;
      }
    }
    if (_selectedFile.size > 5 * 1024 * 1024) {  // Check if file size is larger than 5MB
      showAlertDialog("File size exceeds 5MB. Please select a smaller file.");
      return;
    }
    String jsonString = jsonEncode(proposalRequestDetails);
    // Define fields to send with the request
    Map<String, String> fields = {
      'proposalRequestDetails': jsonString,
    };
    try {
      // Use the postMultipart method to send the request
      var responsedata = await _helper.postMultipart(
        '/Dashboard/SaveFGOProposalDetails',
        fields,
        selectedFile,
        'file',
      );
      if (responsedata["Status"] == 0) {
        // message = responsedata["Message"];
        // showAlertDialog(message);
        showAlertDialog(responsedata["Message"]);
      } else if (responsedata["Status"] == 1) {
        showAlertDialog(responsedata["Message"]);
      } else if (responsedata["Status"] == 2) {
        showAlertDialog(responsedata["Message"]);
      }else {
        showAlertDialog("An unknown error occurred.");
      }
      print('Data and file uploaded successfully');
    } catch (e) {
      print('Error occurred while uploading data and file: $e');
    }
  }
  String message;

  void clearAllProducts() {
    setState(() {
      //productDetails.clear();
      selectedProductIds.clear();
      allSelectedProducts.clear();
      // Remove the entries from the maps
      // Clear the mappings for product quantities, FGO values, and invoice values
      productQuantities.clear();
      productFgoValues.clear();
      productInvoiceValues.clear();

      for (var controller in quantityControllers) {
        controller.dispose();
      }
      for (var controller in fgoValueControllers) {
        controller.dispose();
      }
      for (var controller in invoiceValueControllers) {
        controller.dispose();
      }
      quantityControllers.clear();
      fgoValueControllers.clear();
      invoiceValueControllers.clear();

      _selectedFile = null;
      _buttonLabel = 'Upload';

      FilePicker.platform.clearTemporaryFiles();
      totalFGOValue = 0;
    });
  }
  void addComment() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Comment"),
          content: TextField(
            controller: _messageController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(width: 2,color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.black),
              ),
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.black,
                    width: 2),
              ),
              focusedErrorBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.black,
                    width: 2),
              ),
              hintText: 'Enter comment',
            ),
            maxLines: 5,
          ),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                // this.setState((){});
              },
            ),
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
                _messageController.clear();
                // this.setState((){});
              },
            ),
          ],
        );
      },
    );
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
                // setState((){
                //   loadingForsendmail = false;
                // });
                 },
            ),
          ],
        );
      },
    );
  }
  void showAlertDialog1(String message) {
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
                  //this.setState((){});
                 },
            ),
          ],
        );
      },
    );
  }
  //original//
  // Future<void> pickFileAndUploadDatass() async {
  //   _selectedFile = null;
  //   // setState(() {
  //   // //  _selectedFile = null;
  //   //   _buttonLabel = 'Choose File';  // Reset button label or other indicators
  //   // });
  //
  //   FilePickerResult result = await FilePicker.platform.pickFiles();
  //   if (result != null) {
  //     _selectedFile = File(result.files.single.path);
  //     _buttonLabel = '${result.files.single.name}';
  //     setState(() {});
  //   } else {
  //     print('No file selected.');
  //   }
  // }

  Future<void> pickFileAndUploadData() async {
    _selectedFile = null;
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg','jpeg', 'png', 'pdf'],
    );
    if (result != null) {
      setState(() {
        _selectedFile = result.files.first; // Store the selected file
        _buttonLabel = '${result.files.single.name}';
        setState(() {});
      });
      print('File picked: ${_selectedFile.name}');
    } else {
      print('No file picked');
    }
  }
  Widget _buildRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            ":",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox   (width: 10),
          Expanded(
            flex: 4,
            child: Text(
              value != null ? value.toString() : '',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class ChartSampleData {
  ChartSampleData(
      {this.x,
        this.y,
        this.xValue,
        this.yValue,
        this.yValue2,
        this.yValue3,
        this.pointColor,
        this.size,
        this.text});

  final dynamic x;
  final double y;
  final dynamic xValue;
  final double yValue;
  final double yValue2;
  final double yValue3;
  final Color pointColor;
  final int size;
  final String text;
}
class SalesData {
  SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
class RedialChartSampleData {
  RedialChartSampleData({this.x, this.y, this.text, this.pointColor});

  final dynamic x;
  final double y;
  final Color pointColor;
  final String text;
}
class PieChartSampleData {
  PieChartSampleData({this.x, this.y, this.text});
  final dynamic x;
  final double y;
  final String text;
}
class CustomData {
  var _name;
  var _isShow;

  String get name => _name;

  bool get isShow => _isShow;

  set isShow(bool value) {
    _isShow = value;
  }

  set name(String value) {
    _name = value;
  }

  CustomData(this._name, this._isShow);
}
class PopupLabelView extends PopupMenuEntry<int> {
  @override
  double height = 100;

  @override
  bool represents(int n) => n == 1 || n == -1;

  @override
  PopupLabelViewState createState() => PopupLabelViewState();
}
class PopupLabelViewState extends State<PopupLabelView> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          child: Text(Constants_data.label_txt.trim()),
          padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
        ),
      ],
    );
  }
}

