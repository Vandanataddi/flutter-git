import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:file_utils/file_utils.dart';
import 'package:flexi_profiler/ChatConnectyCube/select_dialog_screen.dart';
import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Constants/StateManager.dart';
import 'package:flexi_profiler/Constants/sidebar.dart';
import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
import 'package:flexi_profiler/DBClasses/DBProfessionalList.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// import 'package:install_plugin/install_plugin.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'package:flexi_profiler/Screens/Login.dart';
import '../ChatConnectyCube/pref_util.dart';
import 'ReportsScreen.dart';

class HomeScreenRMT extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeScreenRMT>
    with TickerProviderStateMixin {
  @override
  List<dynamic> accountTypelist = [];
  List<dynamic> accountTypelistRemoved = [];
  bool isBadgeUpdated = false;
  double tildHeight, imageContainerHeight, textContainerHeight;
  int numberOfRows;
  bool isLoaded = false;
  double deviceHeight;
  double deviceWidth;

  // bool isShowChatIcon = true;
  bool isShowChatIcon = false; //todo to hide make it false
  bool isShowChatAssistant = false;

  ZoomPanBehavior zoomPan;
  bool isSideMenuLoaded = false;

  // final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<dynamic> accountTypelistMain = [];
  double img_padding = 15;
  int selectedIndex = 0;
  AnimationController _controller;
  List<dynamic> HeaderData = [];
  var currentUser;
  bool isShowAsList = false;
  bool isAppUpdateAvailable = false;
  int connectyCubeUnreadCount = 0;

  //final ChatMessagesManager chatMessagesManager = CubeChatConnection.instance.chatMessagesManager;
  ApiBaseHelper _helper = ApiBaseHelper();
  ThemeData themeData;

  String selectedDivisionId;
  String selectedDivisionName;
  String selectedDivision = "";
  String selectedHQName = "";
  String selectedHQCode = "";
  dynamic divisions;
  dynamic filteredHQs;
  dynamic hqs;

  //bool shouldCallApi = " "; // Flag to control API call

  Future<List<dynamic>> _futureDashboardData;
  AnimationController _hideFabAnimController;
  bool isScrolled = false;
  ScrollController _hideButtonController;

  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    initUser();
    zoomPan = ZoomPanBehavior(
      enableDoubleTapZooming: true,
      enablePanning: true,
      enablePinching: true,
      enableSelectionZooming: true,
    );
    super.initState();
    _controller = AnimationController(
      lowerBound: 0.5,
      duration: Duration(seconds: 3),
      vsync: this,
    )
      ..repeat();

    // chatMessagesManager.chatMessagesStream.listen((newMessage) {
    //   print("New messageReceived : ${newMessage.toJson()}");
    //   updateUnReadMsg();
    // }).onError((error) {
    //   print("New messageReceived Error : $error");
    // });
    // registerNotification();
    // configLocalNotification();
    // showAlertDialog();

    // if (isLoggedIn()) {
    //   getChildsofdashboard();
    // }

    // Call the API once when the screen is initialized.

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

    _futureDashboardData = _getConstantsData();

    if (["", null].contains(selectedDivision)) {
      getDivisionData();
    }

  }

  void dispose() {
    _controller.dispose();  // Dispose of the AnimationController
    super.dispose();  // Call the super dispose method
  }
  var dataUser;

  initUser() async {
    if (Constants_data.app_user == null) {
      dataUser = await StateManager.getLoginUser();
    } else {
      dataUser = Constants_data.app_user;
    }
  }

  updateUnReadMsg() {
    // getUnreadMessagesCount().then((unreadCount) {
    //   print("UnreadMsg Total: $unreadCount");
    //   int unread = unreadCount["total"] != null ? unreadCount["total"] : 0;
    //   this.setState(() {
    //     connectyCubeUnreadCount = unread;
    //   });
    // }).catchError((error) {
    //   print("UnreadMsg Error: ${error}");
    // });
  }

  DarkThemeProvider themeChange;

  @override
  Widget build(BuildContext context) {
    Constants_data.currentScreenContext = context;
    deviceWidth = MediaQuery
        .of(context)
        .size
        .width;
    deviceHeight = MediaQuery
        .of(context)
        .size
        .height;
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    // final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    // final String userId = args['userId'];
    // final String password = args['password'];

    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          key: _scaffoldKey,
          body: Stack(children: <Widget>[

            getChildsofdashboard(),
            isSideMenuLoaded
                ? SideBar((int index) async {
              if (index == 1) {
                var connectivityResult = await (Connectivity()
                    .checkConnectivity());
                if (connectivityResult == ConnectivityResult.mobile ||
                    connectivityResult == ConnectivityResult.wifi) {
                  //await Navigator.of(context).pushReplacementNamed("/ZipExtrator");
                  this.setState(() {
                    isBadgeUpdated = false;
                  });
                } else {
                  await Constants_data.openDialogNoInternetConection(context);
                }
              }
              else if (index == 2) {
                await Navigator.of(context).pushNamed("/InboxListingScreen");
                this.setState(() {
                  isBadgeUpdated = false;
                });
              }
            })
                : SizedBox.shrink(),
          ]),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: Colors.blue,
            onPressed: () {
              getDivisionData();
              setState(() {});
            },
            mini: true, // This makes the button smaller
          ),
        ));
  }

  // Create a set to track unique HQ codes
  Set<String> uniqueHQCodes = Set<String>();
  List<Map<String, dynamic>> uniqueHQs = [];

  Future<void> getDivisionDatass() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      StateManager.loginUser(currentUser);
      divisions = await StateManager.getDivisionManager();
      hqs = await StateManager.gethqManager();
      if (!["", null, {}].contains(divisions)) {
        Set<String> uniqueHQCodes = Set<String>();
        List<Map<String, dynamic>> uniqueHQs = [];
        for (var hq in hqs) {
          if (uniqueHQCodes.add(hq['hq_code'])) {
            uniqueHQs.add(hq);
          }
        }
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            String selectedDivisionLocal = Constants_data.selectedDivisionId;
            return AlertDialog(
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Stack(
                    children: [
                      Container(
                        height: 400,
                        width: double.maxFinite,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Division Section
                            Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border:
                                Border.all(color: Colors.grey, width: 1.0),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Select Division',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(height: 10),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxHeight: 120),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: divisions.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return RadioListTile<String>(
                                          title: Text(
                                              "${divisions[index]['division_name']}"),
                                          value: divisions[index]['division'],
                                          groupValue: selectedDivisionLocal,
                                          onChanged: (String value) {
                                            if (value != null) {
                                              setState(() {
                                                selectedDivisionLocal = value;
                                                Constants_data
                                                    .selectedDivisionId = value;
                                                Constants_data
                                                    .selectedDivisionName =
                                                divisions[index]['division_name'];
                                                //selectedDivision = divisions[index]['division_name'];
                                              });
                                              // Immediately update the parent state
                                              this.setState(() {
                                                Constants_data
                                                    .selectedDivisionName =
                                                divisions[index]
                                                ['division_name'];
                                              });
                                              print(
                                                  'Selected Division ID: ${Constants_data
                                                      .selectedDivisionId}');
                                            }
                                          },
                                          activeColor: Colors.blue,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            // HQ Section
                            Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border:
                                Border.all(color: Colors.grey, width: 1.0),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Select Headquarter',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(height: 10),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxHeight: 100),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: uniqueHQs.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return RadioListTile<String>(
                                          title: Text(
                                              "${uniqueHQs[index]['hq_name']}"),
                                          value: uniqueHQs[index]['hq_code'],
                                          groupValue:
                                          Constants_data.selectedHQCode,
                                          onChanged: (String value) {
                                            if (value != null) {
                                              setState(() {
                                                Constants_data.selectedHQCode =
                                                    value;
                                                Constants_data.selectedHQName =
                                                uniqueHQs[index]['hq_name'];
                                              });
                                              print(
                                                  'Selected Headquarters Code: ${Constants_data
                                                      .selectedHQCode}');
                                            }
                                          },
                                          activeColor: Colors.blue,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: ElevatedButton(
                          onPressed: () {
                            if (Constants_data.selectedDivisionId != null &&
                                Constants_data.selectedDivisionId.isNotEmpty &&
                                Constants_data.selectedHQCode != null &&
                                Constants_data.selectedHQCode.isNotEmpty) {
                              Navigator.of(context).pop();
                            } else {
                              Constants_data.toastError(
                                  "Please select both Division and HQ");
                            }
                          },
                          child: Text('OK'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
        // setState(() {});
      } else {
        Constants_data.toastNormal("Division or HQ data not found.");
      }
    });
  }
  Future<void> getDivisionData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      StateManager.loginUser(currentUser);
      divisions = await StateManager.getDivisionManager();
      hqs = await StateManager.gethqManager();

      if (!["", null, {}].contains(divisions)) {
        Set<String> uniqueHQCodes = Set<String>();
        List<Map<String, dynamic>> uniqueHQs = [];
        for (var hq in hqs) {
          if (uniqueHQCodes.add(hq['hq_code'])) {
            uniqueHQs.add(hq);
          }
        }

        // ScrollControllers for Divisions and HQ sections
        ScrollController divisionScrollController = ScrollController();
        ScrollController hqScrollController = ScrollController();

        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            String selectedDivisionLocal = Constants_data.selectedDivisionId;
            return AlertDialog(
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Stack(
                    children: [
                      Container(
                        height: 400,
                        width: double.maxFinite,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Division Section
                            Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1.0),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Select Division',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(height: 10),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxHeight: 120),
                                    child: Scrollbar(
                                      controller: divisionScrollController,
                                      thumbVisibility: true, // Makes scrollbar visible
                                      child: ListView.builder(
                                        controller: divisionScrollController,
                                        shrinkWrap: true,
                                        itemCount: divisions.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          return RadioListTile<String>(
                                            title: Text("${divisions[index]['division_name']}"),
                                            value: divisions[index]['division'],
                                            groupValue: selectedDivisionLocal,
                                            onChanged: (String value) {
                                              if (value != null) {
                                                setState(() {
                                                  selectedDivisionLocal = value;
                                                  Constants_data.selectedDivisionId = value;
                                                  Constants_data.selectedDivisionName = divisions[index]['division_name'];
                                                });
                                                // Immediately update the parent state
                                                this.setState(() {
                                                  Constants_data.selectedDivisionName = divisions[index]['division_name'];
                                                });
                                                print('Selected Division ID: ${Constants_data.selectedDivisionId}');
                                              }
                                            },
                                            activeColor: Colors.blue,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            // HQ Section
                            Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1.0),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Select Headquarter',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(height: 10),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxHeight: 100),
                                    child: Scrollbar(
                                      controller: hqScrollController,
                                      thumbVisibility: true, // Makes scrollbar visible
                                      child: ListView.builder(
                                        controller: hqScrollController,
                                        shrinkWrap: true,
                                        itemCount: uniqueHQs.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          return RadioListTile<String>(
                                            title: Text("${uniqueHQs[index]['hq_name']}"),
                                            value: uniqueHQs[index]['hq_code'],
                                            groupValue: Constants_data.selectedHQCode,
                                            onChanged: (String value) {
                                              if (value != null) {
                                                setState(() {
                                                  Constants_data.selectedHQCode = value;
                                                  Constants_data.selectedHQName = uniqueHQs[index]['hq_name'];
                                                });
                                                print('Selected Headquarters Code: ${Constants_data.selectedHQCode}');
                                              }
                                            },
                                            activeColor: Colors.blue,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: ElevatedButton(
                          onPressed: () {
                            if (Constants_data.selectedDivisionId != null && Constants_data.selectedDivisionId != "" &&
                                Constants_data.selectedDivisionId.isNotEmpty &&
                                Constants_data.selectedHQCode != null && Constants_data.selectedHQCode != "" &&
                                Constants_data.selectedHQCode.isNotEmpty) {
                              Navigator.of(context).pop();
                            } else {
                              Constants_data.toastError("Please select both Division and HQ");
                            }
                          },
                          child: Text('OK'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      }
      else {
        Constants_data.toastNormal("Division or HQ data not found.");
      }
    });
  }
  getChildsofdashboard() {
    if (!isLoaded) {
      return FutureBuilder<List<dynamic>>(
        //future: _getConstantsData(),
        future: _futureDashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return getViews();
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );
    }
    else {
      if (!isBadgeUpdated) {
        badgeCount();
      }
      return getViews();
    }
  }

  Future<List<dynamic>> _getConstantsData() async {
    bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
    if (isNetworkAvailable) {
      accountTypelistMain = [];
      accountTypelist = [];
      accountTypelistRemoved = [];

      var data;
      updateUnReadMsg();
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        if (Constants_data.app_user == null) {
          currentUser = await StateManager.getLoginUser();
        } else {
          currentUser = Constants_data.app_user;
        }
        StateManager.loginUser(currentUser);
        print("Current User : ${currentUser}");

        if (currentUser["is_temp_pass"] == "Y") {
          openDialog();
        }
        //currentUser = dataUser;
        //getFirebaseMessagesBadge();

        try {
          String routeUrl = '/Profiler/GetDashboardGridData?RepId=${currentUser["RepId"]}';
          data = await _helper.get(routeUrl);
          StateManager.setHomeScreenGrid(data);
        }
        on Exception catch (err) {
          print('Error in DashboardGridData : $err');
          data = null;
        }
        // if (Platform.isAndroid) {
        //   try {
        //     String checkVersionURL =
        //         '/CheckAppVersion?AppName=${Platform.isAndroid ? "android" : "ios"}&Version=${Constants_data.appVersionCode}';
        //     var dataCheckVer = await _helper.get(checkVersionURL);
        //     if (dataCheckVer["Status"] == 1) {
        //       isAppUpdateAvailable = dataCheckVer["ObjRetArgs"][0] != null && dataCheckVer["ObjRetArgs"][0];
        //       // if (isAppUpdateAvailable) {
        //       //   updateDialog(dataCheckVer["ObjRetArgs"][2].toString());
        //       // }
        //     }
        //   }
        //   on Exception catch (err) {
        //     print('Error in CheckAppVersion : $err');
        //     data = null;
        //   }
        // }
      }
      else {
        var dt = await StateManager.getHomeScreenGrid();
        if (dt != null) {
          data = dt;
        }
      }
      if (data == null && data["Status"] != 1) {
        data = Constants_data.jsonMenuUpdated;
      }
      else if (data["status"].toString() == "8") {
        print("There Is No Products for This Division");
        Constants_data.toastError(data["message"]);
        await StateManager.logout();
        SharedPrefs.instance.deleteUser();
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
        // Navigator.pushReplacementNamed(context, "/Login");
      }
      else if (data["status"].toString() == "4") {
        print("There Is No Products for This Division");
        Constants_data.toastError(data["message"]);
        await StateManager.logout(); // Wait for logout to complete
        //await SharedPrefs.instance.deleteUser();
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
      else if (data["status"].toString() == "5") {
        Constants_data.toastError(data["message"]);
        await StateManager.logout(); // Wait for logout to complete
        //await SharedPrefs.instance.deleteUser();
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
      List<dynamic> list = data["dt_ReturnedTables"];
      print("HomeScreen sideMenu : ${data["dt_ReturnedTables"][1]}");
      Constants_data.sizeMenuItem = data["dt_ReturnedTables"][1];
      isSideMenuLoaded = true;
      print("Status Success Found, ${data["Message"]}");
      try {
        for (int i = 0; i < Constants_data.sizeMenuItem.length; i++) {
          if (Constants_data.sizeMenuItem[i]["MenuId"].toString() == "43" &&
              Constants_data.sizeMenuItem[i]["IsActive"].toString() == "Y") {
            isShowChatAssistant = true;
          }
          if (Constants_data.sizeMenuItem[i]["MenuId"].toString() == "44" &&
              Constants_data.sizeMenuItem[i]["IsActive"].toString() == "Y") {
            isShowChatIcon = true;
          }
        }
      }
      catch (ex) {}
      HeaderData = data["ObjRetArgs"] != null && data["ObjRetArgs"].length > 0
          ? data["ObjRetArgs"][0]
          : [];
      print("Header Data : ${jsonEncode(HeaderData)}");
      accountTypelistMain = list[0];
      accountTypelist = list[0];

      print("AccoutTypeList length : ${accountTypelist.length}");

      if (accountTypelist.length <= 4) {
        isShowAsList = true;
      } else {
        if (accountTypelist.length >= 3) {
          final int count = accountTypelist.length % 3;
          for (int i = 0; i < count; i++) {
            accountTypelistRemoved.add(
                accountTypelist[accountTypelist.length - 1]);
            accountTypelist.removeAt(accountTypelist.length - 1);
          }

          numberOfRows = (accountTypelist.length / _getTiledCount()).toInt();
          if (accountTypelistRemoved.length > 0) {
            numberOfRows++;
          }
        } else {
          final int count = accountTypelist.length;
          for (int i = 0; i < count; i++) {
            accountTypelistRemoved.add(
                accountTypelist[accountTypelist.length - 1]);
            accountTypelist.removeAt(accountTypelist.length - 1);
          }
          accountTypelistRemoved = accountTypelistRemoved.reversed.toList();
          numberOfRows = 1;
        }
        print("AccoutTypeList length : ${accountTypelist.length}");
        print(
            "AccoutTypeListRemoved length : ${accountTypelistRemoved.length}");

        print("Number Of Rows : ${numberOfRows}");
      }

      badgeCount();
      isLoaded = true;
      startTheCron();
      this.setState(() {});
      return accountTypelistMain;
    }
    else {
      await Constants_data.openDialogNoInternetConection(context);
    }
  }

  startTheCron() async {
    const oneSec = const Duration(seconds: 30);
    Timer.periodic(oneSec, (Timer timer) {
      print("Timer for badgeUpdate HomeScreen");
      badgeCount();
    });
  }

  final formKey = GlobalKey<FormState>();
  TextEditingController cnt_pass = new TextEditingController();
  TextEditingController cnt_cpass = new TextEditingController();

  Future<Null> openDialog() async {
    bool _isShowNewPassword = false;
    bool _isShowCPassword = false;
    bool isLoading = false;
    String oldPassword = currentUser["password"];
    cnt_pass.clear();
    cnt_cpass.clear();
    switch (await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SimpleDialog(
                  contentPadding: EdgeInsets.only(
                      left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
                  children: <Widget>[
                    Container(
                      color: themeChange.darkTheme
                          ? AppColors.dark_grey_color
                          : AppColors.main_color,
                      margin: EdgeInsets.all(0.0),
                      padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                      width: deviceWidth * 0.7,
                      height: 98.0,
                      child: isLoading
                          ? Center(
                        child: CircularProgressIndicator(
                          backgroundColor: AppColors.white_color,
                        ),
                      )
                          : Column(
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
                            'Change Password',
                            style: TextStyle(color: AppColors.white_color,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Form(
                        key: formKey,
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.all(10),
                              child: TextFormField(
                                  controller: cnt_pass,
                                  validator: (str) {
                                    if (str.isEmpty) {
                                      return "Password can't be blank";
                                    }
                                    else if (str.length < 5) {
                                      return 'Password length must be 5 Character long';
                                    }
                                    return null;
                                  },
                                  obscureText: !_isShowNewPassword,
                                  decoration: new InputDecoration(
                                      contentPadding: EdgeInsets.only(
                                          bottom: 0),
                                      labelText: "New Password",
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          // Based on passwordVisible state choose the icon
                                          _isShowNewPassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Theme
                                              .of(context)
                                              .primaryColorDark,
                                        ),
                                        onPressed: () {
                                          // Update the state i.e. toogle the state of passwordVisible variable
                                          setState(() {
                                            _isShowNewPassword =
                                            !_isShowNewPassword;
                                          });
                                        },
                                      ))),
                            ),
                            Container(
                              margin: EdgeInsets.all(10),
                              child: TextFormField(
                                  controller: cnt_cpass,
                                  validator: (str1) {
                                    if (str1.isEmpty) {
                                      return "Confirm Password can't be blank";
                                    } else if (str1.length < 5) {
                                      return 'CPassword length must be 5 Character long';
                                    } else if (cnt_pass.text != str1) {
                                      return 'Password and Confirm password not match';
                                    }
                                    return null;
                                  },
                                  obscureText: !_isShowCPassword,
                                  decoration: new InputDecoration(
                                      contentPadding: EdgeInsets.only(
                                          bottom: 0),
                                      labelText: "Confirm Password",
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          // Based on passwordVisible state choose the icon
                                          _isShowCPassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Theme
                                              .of(context)
                                              .primaryColorDark,
                                        ),
                                        onPressed: () {
                                          // Update the state i.e. toogle the state of passwordVisible variable
                                          setState(() {
                                            _isShowCPassword =
                                            !_isShowCPassword;
                                          });
                                        },
                                      ))),
                            )
                          ],
                        )),
                    Container(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            SimpleDialogOption(
                              onPressed: () async {
                                if (formKey.currentState.validate()) {
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    isLoading = true;
                                  });
                                  var dataUser;
                                  if (Constants_data.app_user == null) {
                                    dataUser =
                                    await StateManager.getLoginUser();
                                  } else {
                                    dataUser = Constants_data.app_user;
                                  }
                                  try {
                                    String url =
                                        '/ChangePassword?RepId=${dataUser["RepId"]}&OldPassword=${Uri
                                        .encodeComponent(
                                        oldPassword)}&NewPassword=${Uri
                                        .encodeComponent(cnt_pass.text)}';

                                    var mainData = await _helper.get(url);
                                    if (mainData["Status"] == 1) {
                                      Constants_data.toastNormal(
                                          "${mainData["Message"].toString()}");
                                      currentUser["password"] = cnt_pass.text;
                                      await StateManager.loginUser(currentUser);
                                      Constants_data.app_user = currentUser;
                                      Navigator.pop(context, 1);
                                    } else {
                                      Constants_data.toastError(
                                          "${mainData["Message"].toString()}");
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  } on Exception catch (err) {
                                    Constants_data.toastError("$err");
                                    print("Error in ChangePassword : $err");
                                  }
                                }
                              },
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    'CHANGE',
                                    style: TextStyle(
                                        color: AppColors.main_color,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ))
                  ],
                );
              });
        })) {
      case 0:
        break;
      case 1:
        print("password changed");
        break;
    }
  }

  badgeCount() async {
    for (int i = 0; i < accountTypelist.length; i++) {
      if (accountTypelist[i]["isShowBadge"] != null &&
          accountTypelist[i]["isShowBadge"].toString() == "true") {
        print("badgeCountQuery : ${accountTypelist[i]["badgeCountQuery"]}");
        var resQ = await DBProfessionalList.prformQueryOperation(
            accountTypelist[i]["badgeCountQuery"], []);
        print("Badge counter : ${resQ[0]["COUNT(*)"]}");
        if (resQ != null && resQ.isNotEmpty) {
          accountTypelist[i]["badgeCount"] = resQ[0]["COUNT(*)"].toString();
        }
      }
    }

    for (int i = 0; i < accountTypelistRemoved.length; i++) {
      if (accountTypelistRemoved[i]["isShowBadge"] != null &&
          accountTypelistRemoved[i]["isShowBadge"].toString() == "true") {
        var resQ = await DBProfessionalList.prformQueryOperation(
            accountTypelistRemoved[i]["badgeCountQuery"], []);
        print("Badge counter : ${resQ[0]["COUNT(*)"]}");
        if (resQ != null && resQ.isNotEmpty) {
          accountTypelistRemoved[i]["badgeCount"] =
              resQ[0]["COUNT(*)"].toString();
        }
      }
    }
    isBadgeUpdated = true;
    try {
      this.setState(() {});
    } catch (e) {}
  }

  _getTiledCount() {
    final int length = accountTypelist.length + accountTypelistRemoved.length;
    if (length <= 3) {
      img_padding = 20;
      return 1;
    } else if (length <= 6) {
      img_padding = 18;
      return 2;
    } else if (length <= 12) {
      img_padding = 16;
      return 3;
    } else if (length <= 15) {
      img_padding = 14;
      return 3;
    } else if (length <= 20) {
      img_padding = 12;
      return 4;
    } else {
      img_padding = 10;
      return 4;
    }
  }

  _createDynamicTable() {
    if (isShowAsList) {
      return Column(
        children: getListItems(),
      );
    }
    else {
      List<TableRow> rows = [];
      if (accountTypelist.length > 0) {
        for (int i = 0; i < accountTypelist.length;) {
          List<Widget> tild = [];
          for (int j = 0; j < 3; j++) {
            tild.add(getSingleItem(accountTypelist[i]));
            i++;
          }
          rows.add(TableRow(children: tild));
        }
      }

      if (accountTypelistRemoved.length > 0) {
        List<TableRow> rows1 = [];
        List<Widget> tild = [];
        for (int i = 0; i < 3; i++) {
          if (i < accountTypelistRemoved.length) {
            tild.add(getSingleItem(accountTypelistRemoved[i]));
          } else {
            tild.add(Container());
          }
        }
        rows1.add(TableRow(children: tild));

        return ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemBuilder: (context, index) {
            return index == 0
                ? Table(children: rows)
                : Table(
              children: rows1,
            );
          },
          itemCount: 2,
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemBuilder: (context, index) {
          return Table(children: rows);
        },
        itemCount: 1,
      );
    }
  }

  getListItems() {
    List<Widget> listRows = [];
    for (int i = 0; i < accountTypelist.length; i++) {
      var accountData = accountTypelist[i];
      listRows.add(Container(
          height: Constants_data.getHeight(context, 74),
          child: InkWell(
              onTap: () async {
                Map<String, dynamic> arg = new HashMap();
                arg["account_type"] = accountData["account_type"];
                arg["menu_title"] = accountData["menu_title"];
                arg["api_name"] = accountData["api_name"];
                arg["api_parameters"] = accountData["api_parameters"];
                // print(" ********* ${accountData["screen"]}");
                if (accountData["screen"] == "/ReportsScreen") {
                  Map<String, dynamic> dataToSend = new HashMap();
                  Map<String, dynamic> jsonParam = new HashMap();
                  dataToSend["ParentWidgetId"] = "";
                  dataToSend["jsonParam"] = jsonParam;
                  dataToSend["Rep_Id"] = dataUser["RepId"];
                  dataToSend["title_value"] = "Reports";
                  print(jsonEncode(dataToSend));
                  // dataToSend["selectedDate"] = selectedDate;
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportsScreen(dataToSend),
                    ),
                  );
                }
                else {
                  await Navigator.of(context)
                      .pushNamed(accountData["screen"],
                      arguments: accountData["account_type"] != '' ? arg : '');
                }
                this.setState(() {
                  isBadgeUpdated = false;
                  if (Constants_data.isCallUpdated) {
                    isLoaded = false;
                    Constants_data.isCallUpdated = false;
                  }
                });
              },
              child: Stack(
                clipBehavior: Clip.none, children: [
                Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5,
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                    child: Row(children: [
                      Expanded(
                        flex: 30,
                        child: Container(
                            padding: EdgeInsets.all(Constants_data.getFontSize(
                                context, 12)),
                            child: Image.asset(
                              "assets/images/" + accountData["menu_icon"],
                              //color: AppColors.black_color87,
                            )),
                      ),
                      Expanded(
                          flex: 90,
                          child: Text(
                            accountData["menu_title"],
                            maxLines: 1,
                            style:
                            TextStyle(fontSize: Constants_data.getFontSize(
                                context, 15), fontWeight: FontWeight.bold),
                          )),
                      // accountData["additional_data"] != ""
                      //     ? Expanded(
                      //         flex: 20,
                      //         child: Center(
                      //             child: Text(
                      //           accountData["additional_data"].toString(),
                      //           maxLines: 1,
                      //           style: TextStyle(
                      //               color: themeData.hoverColor, fontSize: Constants_data.getFontSize(context, 13)),
                      //         )),
                      //       )
                      //     : Expanded(
                      //         flex: 20,
                      //         child: Center(
                      //             child: Text(
                      //           "",
                      //           maxLines: 1,
                      //           style: TextStyle(
                      //               color: AppColors.black_color, fontSize: Constants_data.getFontSize(context, 10)),
                      //         )),
                      //       ),
                    ])),
                Positioned(
                  right: 5,
                  top: 0,
                  child: accountData["isShowBadge"] != null &&
                      accountData["isShowBadge"].toString() == "true" &&
                      accountData["badgeCount"] != null &&
                      int.parse(accountData["badgeCount"]) > 0
                      ? Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.red_color,
//                        color: Color(0xFFDDDDDD)
                    ),
                    child: Center(
                      child: Text(
                        "${accountData["badgeCount"]}",
                        style: TextStyle(
                            color: AppColors.white_color, fontSize: 12),
                      ),
                    ),
                  )
                      : Container(),
                )
              ],
              ))));
    }

    return listRows;
  }

  getSingleItem(var accountData) {
    return Container(
      margin: EdgeInsets.only(left: 3, right: 3, top: 3, bottom: 0),
      height: deviceHeight * 0.15,
      child: Container(
        child: GestureDetector(
          //padding: EdgeInsets.all(0),
          onTap: () async {
            Map<String, dynamic> arg = new HashMap();
            arg["account_type"] = accountData["account_type"];
            arg["menu_title"] = accountData["menu_title"];
            arg["api_name"] = accountData["api_name"];
            arg["api_parameters"] = accountData["api_parameters"];

            // print(" ********* ${accountData["screen"]}");
            if (accountData["screen"] == "/ReportsScreen") {
              Map<String, dynamic> dataToSend = new HashMap();
              Map<String, dynamic> jsonParam = new HashMap();
              dataToSend["ParentWidgetId"] = "";
              dataToSend["jsonParam"] = jsonParam;
              dataToSend["Rep_Id"] = dataUser["RepId"];
              //dataToSend["Rep_Id"] = Constants_data.repId;
              dataToSend["title_value"] = "Reports";
              print(jsonEncode(dataToSend));
              // dataToSend["selectedDate"] = selectedDate;
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportsScreen(dataToSend),
                ),
              );
            } else {
              await Navigator.of(context)
                  .pushNamed(accountData["screen"],
                  arguments: accountData["account_type"] != '' ? arg : '');
            }
            this.setState(() {
              isBadgeUpdated = false;
              if (Constants_data.isCallUpdated) {
                isLoaded = false;
                Constants_data.isCallUpdated = false;
              }
            });
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  height: deviceHeight * 0.07,
                  child: Stack(
                    clipBehavior: Clip.none, children: <Widget>[
                    Card(
                      elevation: 2,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      // color: AppColors.white_color,
                      child: Padding(
                        padding: EdgeInsets.all(deviceHeight * 0.015),
                        child: Image.asset(
                          "assets/images/" + accountData["menu_icon"],
                          //color: AppColors.black_color87,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -5,
                      top: -5,
                      child: accountData["isShowBadge"] != null &&
                          accountData["isShowBadge"].toString() == "true" &&
                          accountData["badgeCount"] != null &&
                          int.parse(accountData["badgeCount"]) > 0
                          ? Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.red_color,
//                        color: Color(0xFFDDDDDD)
                        ),
                        child: Center(
                          child: Text(
                            "${accountData["badgeCount"]}",
                            style: TextStyle(
                                color: AppColors.white_color, fontSize: 11),
                          ),
                        ),
                      )
                          : Container(),
                    )
                  ],
                  )),
              Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 5),
                  height: deviceHeight * 0.05,
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Align(
                            child: Text(
                              accountData["menu_title"],
                              maxLines: 1,
                              style: TextStyle(
                                //fontWeight: FontWeight.bold,
                                  fontSize: Constants_data.getFontSize(
                                      context, 12)),
                            ),
                          ),
                        ),
                        accountData["additional_data"] != ""
                            ? Expanded(
                          child: Text(
                            '(' + accountData["additional_data"] + ')',
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: Constants_data.getFontSize(
                                    context, 10), fontWeight: FontWeight.bold),
                          ),
                        )
                            : Expanded(
                          child: Text(
                            "",
                            maxLines: 1,
                            style: TextStyle(
                                color: AppColors.black_color,
                                fontSize: Constants_data.getFontSize(
                                    context, 10)),
                          ),
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  // Future<bool> updateDialog(url) async {
  //   bool isDownloading = false;
  //   var progress = "";
  //   double intProgress = 0;
  //   String dirloc = "/sdcard/download/";
  //
  //   String path = dirloc + Constants_data.appName + ".apk";
  //   bool isDownloadComplated = false;
  //
  //   Future<void> downloadFile(setState) async {
  //     var status = await Permission.storage.status;
  //     if (status.isGranted) {
  //     } else {
  //       Map<Permission, PermissionStatus> statuses = await [
  //         Permission.storage,
  //       ].request();
  //       print("Permission Status : ${statuses[Permission.location]}");
  //     }
  //
  //     Dio dio = Dio();
  //     print("Download path : ${path}");
  //     try {
  //       FileUtils.mkdir([dirloc]);
  //       await dio.download(url, path, onReceiveProgress: (receivedBytes, totalBytes) {
  //         setState(() {
  //           isDownloading = true;
  //           progress = ((receivedBytes / totalBytes) * 100).toStringAsFixed(0) + "%";
  //           intProgress = receivedBytes / totalBytes;
  //         });
  //       });
  //     } catch (e) {
  //       print(e);
  //     }
  //
  //     setState(() {
  //       isDownloading = false;
  //       progress = "Download Completed.";
  //       //path = dirloc + "_" + Constants_data.appName + ".apk";
  //       isDownloadComplated = true;
  //     });
  //   }
  //
  //   switch (await showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
  //           String text = "/n/n";
  //           String title = "";
  //           if (isDownloadComplated) {
  //             text = 'Successfully download the app,\nClick install to update app';
  //             title = 'Install Update';
  //           } else if (isDownloading) {
  //             text = 'Downloading File: $progress\n';
  //             title = 'Downloading App';
  //           } else {
  //             text = "New version of App available\nPlease update your app.";
  //             title = 'Update Available';
  //           }
  //           return SimpleDialog(
  //             contentPadding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
  //             children: <Widget>[
  //               Container(
  //                 color: AppColors.white_color,
  //                 margin: EdgeInsets.all(0.0),
  //                 padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
  //                 child: Column(
  //                   children: <Widget>[
  //                     Container(
  //                       child: isDownloading
  //                           ? Container(
  //                               child: Lottie.asset('assets/Lotti/updating_progress.json', width: 200, height: 250),
  //                               margin: EdgeInsets.only(bottom: 10.0),
  //                             )
  //                           : !isDownloadComplated
  //                               ? Container(
  //                                   child: Lottie.asset('assets/Lotti/update_available.json', width: 200, height: 250),
  //                                   margin: EdgeInsets.only(bottom: 10.0),
  //                                 )
  //                               : Container(
  //                                   child: Lottie.asset('assets/Lotti/update_success.json', width: 200, height: 250),
  //                                   margin: EdgeInsets.only(bottom: 10.0),
  //                                 ),
  //                       margin: EdgeInsets.only(bottom: 10.0),
  //                     ),
  //                     Text(
  //                       '$title',
  //                       style: TextStyle(color: AppColors.black_color, fontSize: 18.0, fontWeight: FontWeight.bold),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Container(
  //                 margin: EdgeInsets.all(15),
  //                 child: Center(
  //                     child: Text(
  //                   "$text",
  //                   style: TextStyle(color: AppColors.black_color, fontWeight: FontWeight.bold),
  //                   textAlign: TextAlign.center,
  //                 )),
  //               ),
  //               Container(
  //                   margin: EdgeInsets.all(10),
  //                   child: Row(
  //                     crossAxisAlignment: CrossAxisAlignment.center,
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: <Widget>[
  //                       SimpleDialogOption(
  //                         onPressed: () async {
  //                           if (isDownloadComplated) {
  //                             print("Path : ${path}");
  //                             InstallPlugin.installApk(path, '${Constants_data.package_name}').then((result) {
  //                               print('install apk $result');
  //                             }).catchError((error) {
  //                               print('install apk error: $error');
  //                             });
  //                           } else {
  //                             downloadFile(setState);
  //                           }
  //                           //Navigator.pop(context, 0);
  //                         },
  //                         child: Text(isDownloadComplated ? "Install" : "Update",
  //                             style: TextStyle(color: AppColors.main_color, fontWeight: FontWeight.bold)),
  //                       ),
  //                     ],
  //                   ))
  //             ],
  //           );
  //         });
  //       })) {
  //     case 0:
  //       return true;
  //       break;
  //     case 1:
  //       return false;
  //       break;
  //   }
  //   return false;
  // }

  getViews() {
    return Stack(
      children: <Widget>[
        Container(
          height: MediaQuery
              .of(context)
              .size
              .height,
          width: MediaQuery
              .of(context)
              .size
              .width,
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
          // color: themeChange.darkTheme ? themeData.indicatorColor : null,
          child: Column(
            children: <Widget>[
              new Container(
                margin: EdgeInsets.only(top: 30, bottom: 0, left: 5, right: 5),
                padding: EdgeInsets.all(6),
//                color: AppColors.white_color.withOpacity(0.2),l
                child: new Row(
                  children: <Widget>[
                    Expanded(
                        child: new Container(
                          height: 40,
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(left: 50, right: 5),
                          child: new Text(
                            '${Constants_data.appName}  ' '${Constants_data
                                .selectedDivisionName}',
                            // Constants_data.appName,selectedDivision
                            style: TextStyle(color: AppColors.white_color,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        )),
                    isShowChatAssistant
                        ? Container(
                      margin: EdgeInsets.only(left: 5, right: 5),
                      child: IconButton(
                          icon: Icon(
                            Icons.mic,
                            color: AppColors.white_color,
                          ),
                          onPressed: () async {
                            Navigator.pushNamed(context, "/AssistanceScreen");
                          }),
                    )
                    //     ? Container(
                    //      margin: EdgeInsets.only(left: 5, right: 5),
                    //      child: IconButton(
                    //       icon: Icon(
                    //         Icons.mic,
                    //         color: AppColors.white_color,
                    //       ),
                    //       onPressed: () async {
                    //         Navigator.pushNamed(context, "/FGOInvoiceScreen");
                    //       }),
                    // )

                        : Container(),
                    isShowChatIcon
                        ? Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                            icon: Icon(
                              Icons.message,
                              color: AppColors.white_color,
                            ),
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  settings: RouteSettings(
                                      name: "/SelectDialogScreen"),
                                  builder: (context) => SelectDialogScreen(
                                      Constants_data.cubeUser),
                                ),
                              );
                              updateUnReadMsg();
                            }),
                        connectyCubeUnreadCount != null &&
                            connectyCubeUnreadCount > 0
                            ? Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.red_color,
//
                            ),
                            child: Center(
                              child: Text(
                                "${connectyCubeUnreadCount}",
                                style: TextStyle(
                                    color: AppColors.white_color, fontSize: 11),
                              ),
                            ),
                          ),
                        )
                            : Container()
                      ],
                    )
                        : Container(),
                    // Container(
                    //   margin: EdgeInsets.only(left: 5, right: 5),
                    //   child: IconButton(
                    //       icon: Icon(
                    //         Icons.search,
                    //         color: AppColors.white_color,
                    //       ),
                    //       onPressed: () async {
                    //         Navigator.pushNamed(context, "/GlobalSearchScreen");
                    //       }),
                    // ),
                  ],
                ),
              ),
              HeaderData != null && HeaderData.length > 0
                  ? CarouselSlider(
                options: CarouselOptions(
                  height: Constants_data.getHeight(context, 130),
                  aspectRatio: 16 / 9,
                  viewportFraction: 1.0,
                  initialPage: 0,
                  enableInfiniteScroll: false,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 5),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: false,
                  scrollDirection: Axis.horizontal,
                ),
                items: getHeaderData(),
              )
                  : SizedBox.shrink(),
              Expanded(
                child: Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      color: themeData.primaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15.0),
                        topRight: const Radius.circular(15.0),
                      ),
                    ),
                    padding: EdgeInsets.only(
                        left: 5, right: 5, bottom: 5, top: 15),
                    child: _createDynamicTable()),
              ),
              Container(
                  color: themeData.primaryColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 1,
                        color: Colors.black12,
                      ),
                      Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.all(10),
                        child: Text(
                            "© 2024 All Rights Reserved. Flexiware Solutions.",
                            style: TextStyle(
                              color: AppColors.grey_color,
                              fontSize: Constants_data.getFontSize(context, 12),
                            )),
                      )
                    ],
                  )),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> getHeaderData() {
    List<Widget> sliders = [];
    // Loop through each header data to create a slider for it
    for (int i = 0; i < HeaderData.length; i++) {
      Map<String, dynamic> data = HeaderData[i];
      String title = data["title"];
      String currency = data["currency"];
      String currencyFormat = data["currency_format"];
      Map<String, String> properties = data["properties"];
      List<dynamic> goalListBlock = data["goal_data"];
      List<dynamic> salesListBlock = data["sales_data"];

      // Combine goal and sales data blocks
      List<dynamic> listBlocks = [];
      listBlocks.addAll(salesListBlock);
      listBlocks.addAll(goalListBlock);

      // List to hold rows and columns for the current slider
      List<Widget> cols = [];
      List<Widget> rows = [];

      // Add the title of the current slider
      cols.add(
        Container(
          margin: EdgeInsets.all(5),
          child: Text(
            "$title",
            maxLines: 1,
            style: TextStyle(
              color: themeChange.darkTheme ? themeData.focusColor : AppColors
                  .white_color,
              fontSize: Constants_data.getFontSize(context, 12),
            ),
          ),
        ),
      );
      // Loop through each block to create rows of data
      for (int j = 0; j < listBlocks.length; j++) {
        rows.add(
          getSingleHeaderBlock(
              listBlocks[j], currency, listBlocks.length, currencyFormat),
          // getSingleHeaderBlock(listBlocks[j], currency, listBlocks.length, currencyFormat,properties),
        );
        // Add rows into columns every 2 items or on the last block
        if (rows.length == 2 || j == listBlocks.length - 1) {
          cols.add(Expanded(child: Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: Row(children: rows))));
          rows = []; // Reset rows after adding them to cols
        }
      }
      // Add the column to the list of sliders
      sliders.add(
        Container(
          margin: EdgeInsets.only(bottom: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: cols,
          ),
        ),
      );
    }
    return sliders;
  }

  Widget getSingleHeaderBlock(Map<String, dynamic> block, String currency,
      int totalBlocks, String currencyFormat) {
    // Hardcoded static properties
    String backgroundColor = "#467fc9"; // Static background color
    String valueTextColor = "#FFFFFF"; // Static value text color
    String labelTextColor = "#FFFFFF"; // Static label text color
    String valueTextSize = "30"; // Static value text size
    String labelTextSize = "12"; // Static label text size

    // Fetching the grid label and grid value
    String gridLabel = block["grid_label"] ?? "";
    String gridValue = block["grid_value"] ?? "0"; // Default to "0" if empty
    String value = _formatCurrency(gridValue, currencyFormat);
    return Expanded(
      child: Container(
        child: Card(
          elevation: 0,
          margin: EdgeInsets.all(Constants_data.getHeight(context, 5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: themeChange.darkTheme
              ? themeData.cardColor
              : Constants_data.hexToColor(backgroundColor),
          // Using static background color
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Displaying the value (formatted currency)
                    Text(
                      value,
                      maxLines: 1,
                      style: TextStyle(
                        color: themeChange.darkTheme
                            ? themeData.focusColor
                            : Constants_data.hexToColor(valueTextColor),
                        // Using static value text color
                        fontSize: Constants_data.getFontSize(context, int.parse(
                            valueTextSize)), // Using static value text size
                      ),
                    ),
                    // Displaying the grid label
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: Text(
                        gridLabel.isEmpty ? "" : gridLabel,
                        maxLines: 1,
                        style: TextStyle(
                          color: themeChange.darkTheme
                              ? themeData.focusColor
                              : Constants_data.hexToColor(labelTextColor),
                          // Using static label text color
                          fontSize: Constants_data.getFontSize(context,
                              int.parse(
                                  labelTextSize)), // Using static label text size
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(String value, String format) {
    try {
      double amount = double.tryParse(value) ?? 0.0;
      final formatCurrency = NumberFormat(format);
      return formatCurrency.format(amount);
    } catch (e) {
      return value; // Return the original value if parsing fails
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
                this.setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

// List<Widget> getHeaderData() {
//   List<Widget> listSliders = [];
//   for (int i = 0; i < HeaderData.length; i++) {
//     Map<String, dynamic> data = HeaderData[i];
//     String title = data["title"];
//     String currency = data["currency"];
//     String currency_formate = data["currency_format"];
//     List<dynamic> listBlocks = data["data"];
//
//     List<Widget> cols = [];
//     List<Widget> rows = [];
//
//     cols.add(Container(
//         margin: EdgeInsets.all(5),
//         child: Text(
//           "$title",
//           maxLines: 1,
//           style: TextStyle(
//               color: themeChange.darkTheme ? themeData.focusColor : AppColors.white_color,
//               fontSize: Constants_data.getFontSize(context, 12)),
//         )));
//
//     for (int i = 0; i < listBlocks.length; i++) {
//       rows.add(
//         getSingleHeaderBlock(listBlocks[i], currency, listBlocks.length, currency_formate),
//       );
//       if (rows.length == 2 || i == listBlocks.length - 1) {
//         cols.add(Expanded(child: Container(margin: EdgeInsets.symmetric(horizontal: 15), child: Row(children: rows))));
//         rows = [];
//       }
//     }
//
//     listSliders.add(Container(
//         margin: EdgeInsets.only(bottom: 5),
//         child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: cols)));
//   }
//   return listSliders;
// }
// Widget getSingleHeaderBlock(block, currency, length, currency_formate) {
//   String value = block["grid_value"];
//   String value1 = block["grid_value"];
//   String grid_id = block["grid_id"];
//   Map<String, dynamic> properties = block["properties"];
//   final currancy_format = new NumberFormat("$currency_formate", "en_IN");
//   bool isClickable = properties["is_clickable"] == "Y";
//
//   if (properties["is_currency"] == "Y") {
//     value = "$currency" + Constants_data.formatter(value);
//   }
//
//   return Expanded(
//     child: InkWell(
//         onTap: () {
//           print("${properties["is_clickable"]}");
//           if (properties["is_clickable"] == "Y") {
//             Map<String, dynamic> mapArgs = new HashMap();
//             mapArgs["currency"] = currency;
//             mapArgs["is_currency"] = properties["is_currency"];
//             mapArgs["dashboard_value"] = "$currency" + currancy_format.format(int.parse(value1));
//             mapArgs["grid_id"] = grid_id.toString();
//
//             Navigator.pushNamed(context, "/${properties["screen_name"]}", arguments: mapArgs);
//           }
//         },
//         child: Container(
//             child: Card(
//                 elevation: 0,
//                 margin: EdgeInsets.all(Constants_data.getHeight(context, 5)),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 color: themeChange.darkTheme
//                     ? themeData.cardColor
//                     : Constants_data.hexToColor("${properties["background_color"]}"),
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.all(5),
//                       child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: <Widget>[
//                             Text(
//                               value,
//                               maxLines: 1,
//                               style: TextStyle(
//                                   color: themeChange.darkTheme
//                                       ? themeData.focusColor
//                                       : Constants_data.hexToColor("${properties["value_text_color"]}"),
//                                   fontSize: Constants_data.getFontSize(context, int.parse(properties["value_text_size"]))),
//                             ),
//                             Container(
//                                 margin: EdgeInsets.only(top: 5),
//                                 child: Text(
//                                   block["grid_label"] == null ? "" : block["grid_label"],
//                                   maxLines: 1,
//                                   style: TextStyle(
//                                       color: themeChange.darkTheme
//                                           ? themeData.focusColor
//                                           : Constants_data.hexToColor("${properties["leble_text_color"]}"),
//                                       fontSize:
//                                       Constants_data.getFontSize(context, int.parse(properties["lebel_text_size"]))),
//                                 )),
//                           ]),
//                     ),
//                     isClickable
//                         ? Positioned(
//                       top: 10,
//                       right: 10,
//                       child: Container(
//                         decoration: BoxDecoration(color: AppColors.white_color, shape: BoxShape.circle),
//                         height: 5,
//                         width: 5,
//                       ),
//                     )
//                         : Container()
//                   ],
//                 )))),
//   );
// }
}
