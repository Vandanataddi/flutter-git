import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:cron/cron.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flexi_profiler/ChatConnectyCube/api_utils.dart';
import 'package:flexi_profiler/ChatConnectyCube/configs.dart' as config;
import 'package:flexi_profiler/ChatConnectyCube/pref_util.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Constants/StateManager.dart';
import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
import 'package:flexi_profiler/DBClasses/CreateAllTables.dart';
import 'package:flexi_profiler/DBClasses/DBProfessionalList.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:package_info/package_info.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _SplashScreen(),
    );
  }
}

class _SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  bool isLogin = false;
  var dataUser;
  ApiBaseHelper _helper = ApiBaseHelper();

  startTime() async {
    try {
      await Firebase.initializeApp();
      String pushNoti = await FirebaseMessaging.instance.getToken();
      print("Token : $pushNoti");
    } catch (er) {
      print("Erorr in gettting device Token: ${er.toString()}");
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    print("--------- appName : ${appName}");
    print("--------- packageName : ${packageName}"); //deBZs8qXSVa3jrh3u3eN_T,dDs16f6TQgKPAuu3YxWHNy
    print("--------- version : ${version}");
    print("--------- buildNumber : ${buildNumber}");

    this.setState(() {
      Constants_data.appName = appName;
      Constants_data.appVersionCode = version;
      Constants_data.package_name = packageName;
      initFlavours(appName);
    });

    try {
      Constants_data.deviceId = await Constants_data.getDeviceId();
    } on Exception catch (e) {
      print("Error in getting deviceID:$e");
    }

    isLogin = await StateManager.isLogin();
    final String _baseprofileUrl = Constants_data.profileUrl;

    if (isLogin) {
      dataUser = await StateManager.getLoginUser();
      Constants_data.app_user = dataUser;
      Constants_data.username = "${dataUser["first_name"]} ${dataUser["last_name"]}";
      Constants_data.email = "${dataUser["Email"]}";
      //Constants_data.ProfilePicURL = "${dataUser["ProfilePic"]}";
      String profile= "${dataUser["ProfilePic"]}";
      Constants_data.ProfilePicURL = profile.startsWith('http')
          ? profile
          : "$_baseprofileUrl/content/ProfilePic/$profile";
      //Constants_data.ProfilePicURL = "http://122.170.7.252/MicroDishaWebApiPublish/content/ProfilePic/$profile";
      Constants_data.repId = "${dataUser["RepId"]}";
      Constants_data.SessionId = "${dataUser["SessionId"]}";
      Constants_data.Country = "${dataUser["Country"]}";
      Constants_data.lastSyncTime = await StateManager.getLastSyncDateTime();
     //Constants_data.divisiondata = await StateManager.getDivisionManager();
      //Constants_data.hqdata = await StateManager.gethqManager();
      bool isOnline = await Constants_data.checkNetworkConnectivity();
      // if (isOnline) {
      //   await getFilterChipsWidgets();
      // } else {
      //   var _duration = new Duration(seconds: 2);
      //   return new Timer(_duration, navigationPage);
      // }
      var _duration = new Duration(seconds: 2);
      return new Timer(_duration, navigationPage);
    } else {
      var _duration = new Duration(seconds: 2);
      return new Timer(_duration, navigationPage);
    }
  }

  initFlavours(appName) {
    if (appName == "Microlabs") {
      Constants_data.appFlavour = 0;
      Constants_data.appIcon = "assets/images/profiler_logo_new.png";
      Constants_data.homeScreenName = "/HomeScreenRMT";
       Constants_data.baseUrl = "http://122.170.7.252/MicroDishaWebApiPublish/api";
     // Constants_data.baseUrl = "http://122.170.7.215/FlexiProfilerWebAPI/api/Profiler";

    } else if (appName == "Rezmytrip") {
      Constants_data.appFlavour = 1;
      Constants_data.appIcon = "assets/images/rmt_icon.png";
      Constants_data.homeScreenName = "/HomeScreenRMT";
      //Testing
      Constants_data.baseUrl = "http://122.170.7.215/FlexiProfilerWebAPI_RMT/api/profiler";
      //Live
      // Constants_data.baseUrl = "http://43.242.212.118/FlexiProfilerWebAPI_RMT/api/profiler";
    } else if (appName == "Olcare") {
      Constants_data.appFlavour = 2;
      Constants_data.appIcon = "assets/images/profiler_logo_new.png";
      Constants_data.homeScreenName = "/HomeScreenRMT";
      Constants_data.baseUrl = "http://122.170.7.252:90/FlexiProfilerWebAPI_Olcare/api/profiler";
    } else if (appName == "Food Express") {
      Constants_data.appFlavour = 3;
      Constants_data.appIcon = "assets/images/profiler_logo_new.png";
      Constants_data.homeScreenName = "/HomeScreenRMT";
      Constants_data.baseUrl = "http://122.170.7.215/FlexiProfilerWebAPI_FO/api/profiler";
    } else if (appName == "White Goods") {
      Constants_data.appFlavour = 4;
      Constants_data.appIcon = "assets/images/profiler_logo_new.png";
      Constants_data.homeScreenName = "/HomeScreenRMT";
      Constants_data.baseUrl = "http://122.170.7.215/FlexiProfilerWebAPI_WG/api/profiler";
    } else if (appName == "FMCG") {
      Constants_data.appFlavour = 5;
      Constants_data.appIcon = "assets/images/profiler_logo_new.png";
      Constants_data.homeScreenName = "/HomeScreenRMT";
      Constants_data.baseUrl = "http://122.170.7.215/FlexiProfilerWebAPI_FMCG/api/profiler";
    } else if (appName == "Heko") {
      Constants_data.appFlavour = 6;
      Constants_data.appIcon = "assets/images/profiler_logo_new.png";
      Constants_data.homeScreenName = "/HomeScreenRMT";
      Constants_data.baseUrl = "http://122.170.7.215/FlexiProfilerWebAPI_Heko/api/profiler";
    }
    print("appFlavour : ${Constants_data.appFlavour}");
  }

  @override
  void initState() {
    super.initState();
    init(
      config.APP_ID,
      config.AUTH_KEY,
      config.AUTH_SECRET,
    );
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    startTime();
    main();
    //initPlatformState();
  }

  main() {
    var cron = new Cron();
    cron.schedule(new Schedule.parse('*/1 * * * *'), () async {
      print("Received custom task");
      bool isLogin_temp = await StateManager.isLogin();
      print("----------  isLogin=$isLogin_temp : isSynchronizing=${Constants_data.isSynchronizing}");
      if (!Constants_data.isSynchronizing && isLogin_temp) {
        Constants_data.isBackgroundServiceCallingAPI = true;
        //await makeAPICallAccountListAttributesChanges();
        //await checkUserAuthentication(Constants_data.baseUrl);
        //await checkInboxMessages(Constants_data.baseUrl);
        //await imageUpload();
        //await makeAPICallDCREntryDetailsSave();
        Constants_data.isBackgroundServiceCallingAPI = false;
      } else {
        print("condition wrong isLogin=$isLogin_temp : isSynchronizing=${Constants_data.isSynchronizing}");
      }
    });
  }

  DarkThemeProvider themeChange;
  ThemeData themeData;

  var template = {
    "widget_id": "rout_actual",
    "label": "Is MCR Doctor",
    "widget_type": "Checkbox",
    "defaultSelection": false,
  };

  @override
  Widget build(BuildContext context) {
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    Constants_data.isThemeBlack = themeChange.darkTheme;
    Constants_data.setupThemeColors();
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Center(
              child: Form(
                  child: Column(children: [
                  Image.asset(
                  '${Constants_data.appIcon}',
                  width: 225,
                ),
              ])),
            ),
          ),
        ),
      ),
    );
  }

  // checkUserAuthentication(baseURL) async {
  //   try {
  //     String url = "$baseURL/CheckUserAuthentication?RepId=${Constants_data.app_user["Rep_Id"]}&password=${Constants_data.app_user["password"]}";
  //     var data = await _helper.get(url, isNeedToConcatBaseUrl: false);
  //     if (data["Status"] != 1) {
  //       openDialogAutoLogout(data["Message"]);
  //     }
  //   } on Exception catch (err) {
  //     print("Error in ${err.toString()}");
  //   }
  // }
  //
  // checkInboxMessages(baseURL) async {
  //   try {
  //     String routeUrl = '$baseURL/GetMessages?RepId=${Constants_data.app_user["Rep_Id"]}&AppName=degrtool';
  //     var inboxData = await _helper.get(routeUrl, isNeedToConcatBaseUrl: false);
  //     if (inboxData["Status"] == 1) {
  //       List<dynamic> tempList = inboxData["dt_ReturnedTables"][0];
  //       await CreateAllTables.createTableFromAPIResponse(tempList, "MessageData");
  //     }
  //   } on Exception catch (err) {
  //     print("Error in GetMessages : $err");
  //   }
  // }

  // Future<Null> openDialogAutoLogout(String msg) async {
  //   switch (await showDialog(
  //       context: Constants_data.currentScreenContext,
  //       builder: (BuildContext context) {
  //         return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
  //           return SimpleDialog(
  //             contentPadding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
  //             children: <Widget>[
  //               Container(
  //                 margin: EdgeInsets.all(0.0),
  //                 padding: EdgeInsets.only(bottom: 25.0, top: 25.0, left: 25, right: 25),
  //                 child: Text(
  //                   "${msg}\nYou have to login again.",
  //                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
  //                 ),
  //               ),
  //               Row(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: <Widget>[
  //                   SimpleDialogOption(
  //                     onPressed: () async {
  //                       await StateManager.logout();
  //                       Navigator.pushReplacementNamed(context, "/Login");
  //                     },
  //                     child: MaterialButton(
  //                       onPressed: () async {
  //                         await StateManager.logout();
  //                         Navigator.pushReplacementNamed(context, "/Login");
  //                       },
  //                       child: Text("OK"),
  //                     ),
  //                   )
  //                 ],
  //               )
  //             ],
  //           );
  //         });
  //       })) {
  //     case 0:
  //       break;
  //     case 1:
  //       print("password changed");
  //       break;
  //   }
  // }

  // imageUpload() async {
  //   dataUser = await StateManager.getLoginUser();
  //   await DBProfessionalList.prformQueryOperation("CREATE TABLE IF NOT EXISTS tbl_AccountImage (id TEXT PRIMARY KEY,IsSaved TEXT)", []);
  //   List<dynamic> currentData = await DBProfessionalList.prformQueryOperation("SELECT * from tbl_AccountImage WHERE IsSaved=?", ["N"]);
  //
  //   print("print imageUploadData Count: ${currentData}");
  //
  //   bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
  //   if (isNetworkAvailable) {
  //     for (int i = 0; i < currentData.length; i++) {
  //       Map<String, dynamic> map = new HashMap();
  //       map["AccountId"] = currentData[i]["AccountId"].toString();
  //       map["AccountType"] = currentData[i]["AccountType"].toString();
  //       map["ImageId"] = currentData[i]["ImageId"].toString();
  //       map["ImageName"] = DateTime.now().millisecondsSinceEpoch.toString();
  //       map["Base64"] = currentData[i]["ImageURL"].toString();
  //
  //       try {
  //         String url = "/UploadAccountImage?RepId=${dataUser["Rep_Id"]}";
  //         var data = await _helper.post(url, map, true);
  //         if (data["Status"] == 1) {
  //           var resData = data["dt_ReturnedTables"][0][0];
  //           String query = "DELETE from tbl_AccountImage WHERE ImageId=?";
  //           await DBProfessionalList.prformQueryOperation(query, [map["ImageId"]]);
  //           await DBProfessionalList.prformQueryOperation(
  //               "INSERT INTO tbl_AccountImage (AccountId,AccountType,ImageId,ImageURL,ThumbImageURL,IsSaved) VALUES (?,?,?,?,?,?)", [
  //             resData["AccountId"],
  //             resData["AccountType"],
  //             resData["ImageId"],
  //             resData["ImageURL"],
  //             resData["ThumbImageURL"],
  //             resData["IsSaved"]
  //           ]);
  //         } else {
  //           print("Error in upload image: ${data}");
  //         }
  //       } on Exception catch (err) {
  //         print("Error in UploadAccountImage : $err");
  //       }
  //     }
  //   }
  // }
  //
  // makeAPICallAccountListAttributesChanges() async {
  //   await DBProfessionalList.prformQueryOperation(
  //       "CREATE TABLE IF NOT EXISTS tblAccountListAttributesChanges (CustomerId TEXT,AccountType TEXT,CategoryCode TEXT,AttributeCode TEXT,AttributeValue TEXT)",
  //       []);
  //
  //   List<dynamic> currentData = await DBProfessionalList.prformQueryOperation("SELECT * from tblAccountListAttributesChanges", []);
  //
  //   bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
  //   if (currentData != null && currentData.length > 0 && isNetworkAvailable) {
  //     Map<String, dynamic> mainData = new HashMap();
  //     mainData["saveAttributeJson"] = currentData;
  //     print("RequestData : ${mainData}");
  //
  //     try {
  //       String url = "/saveAttributeValue?RepId=${dataUser["Rep_Id"]}";
  //       var data = await _helper.post(url, mainData, true);
  //       if (data["Status"] == 1) {
  //         print("Data saved successfully");
  //         List<dynamic> savedData = data["dt_ReturnedTables"];
  //         for (int i = 0; i < savedData.length; i++) {
  //           await DBProfessionalList.prformQueryOperation(
  //               "DELETE from tblAccountListAttributesChanges WHERE CustomerId=? AND AccountType=? AND CategoryCode=? AND AttributeCode=?",
  //               [savedData[i]["CustomerId"], savedData[i]["AccountType"], savedData[i]["CategoryCode"], savedData[i]["AttributeCode"]]);
  //         }
  //         print("Data Deleted");
  //       } else {
  //         print("Error in saving data");
  //       }
  //     } on Exception catch (err) {
  //       print("Error in ");
  //     }
  //   }
  // }
  //
  // makeAPICallDCREntryDetailsSave() async {
  //   await DBProfessionalList.prformQueryOperation("CREATE TABLE IF NOT EXISTS tblDCREntryTemp (id TEXT PRIMARY KEY,data TEXT,doc_name TEXT)", []);
  //   List<dynamic> currentData = await DBProfessionalList.prformQueryOperation("SELECT * from tblDCREntryTemp", []);
  //   print("tblDCREntryTemp List : ${currentData}");
  //   bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
  //   List<dynamic> DateValidation = [];
  //   if (currentData != null && currentData.length > 0 && isNetworkAvailable) {
  //     for (int i = 0; i < currentData.length; i++) {
  //       try {
  //         String json_temp = currentData[i]["data"];
  //         json_temp = json_temp.replaceAll("\"", "\\\"");
  //         json_temp = "\"${json_temp}\"";
  //         String url = "/SaveDCRDetail?RepId=${dataUser["Rep_Id"]}";
  //         var data = await _helper.post(url, json_temp, false);
  //         if (data["Status"] == 1) {
  //           String query = "DELETE from tblDCREntryTemp WHERE id=?";
  //           await DBProfessionalList.prformQueryOperation(query, [currentData[i]["id"].toString()]);
  //           print("Data Deleted tblDCREntryTemp Successfully removed: ${currentData[i]["id"].toString()}");
  //         } else if (data["Status"] == 0) {
  //           print("Entry Error : ${data["Message"]}");
  //           Map<String, String> map = new HashMap();
  //           map["doc_name"] = currentData[i]["doc_name"];
  //           var obj = jsonDecode(currentData[i]["data"].toString());
  //           map["date"] = Constants_data.dateToString(
  //               Constants_data.stringToDate(obj["DCRDetail"][0]["work_date"].toString(), "yyyy-MM-dd hh:mm:ss"), "yyyy-MM-dd");
  //           map["id"] = currentData[i]["id"];
  //           DateValidation.add(map);
  //           //await openDialog();
  //         } else {
  //           print("Error in saving DCR details : ${data["Message"]}");
  //         }
  //       } on Exception catch (err) {
  //         print("Error in SaveDCRDetail : $err");
  //       }
  //     }
  //     print("Need to delete Data List : ${DateValidation}");
  //     String errorStr = "";
  //     for (int i = 0; i < DateValidation.length; i++) {
  //       errorStr += "${DateValidation[i]["doc_name"]}(${DateValidation[i]["date"]}),";
  //       String query = "DELETE from tblDCREntryTemp WHERE id=?";
  //       await DBProfessionalList.prformQueryOperation(query, [currentData[i]["id"].toString()]);
  //       print("Data Deleted tblDCREntryTemp Successfully removed: ${currentData[i]["id"].toString()}");
  //     }
  //     errorStr = Constants_data.removeLastCharFromString(errorStr);
  //
  //     print("Final Error message to show : $errorStr");
  //     await openDialog(errorStr);
  //   }
  // }

  // Future<Null> openDialog(String str) async {
  //   switch (await showDialog(
  //       context: Constants_data.currentScreenContext,
  //       builder: (BuildContext context) {
  //         return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
  //           return SimpleDialog(
  //             contentPadding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
  //             children: <Widget>[
  //               Container(
  //                 margin: EdgeInsets.all(0.0),
  //                 padding: EdgeInsets.only(bottom: 25.0, top: 25.0, left: 25, right: 25),
  //                 child: Text(
  //                   "Can not save DCR detail for below doctors. \n\n$str",
  //                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
  //                 ),
  //               ),
  //               Row(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: <Widget>[
  //                   SimpleDialogOption(
  //                     onPressed: () {
  //                       Navigator.pop(context, 0);
  //                     },
  //                     child: MaterialButton(
  //                       onPressed: () {
  //                         Navigator.pop(context, 1);
  //                       },
  //                       child: Text("OK"),
  //                     ),
  //                   )
  //                 ],
  //               )
  //             ],
  //           );
  //         });
  //       })) {
  //     case 0:
  //       break;
  //     case 1:
  //       print("password changed");
  //       break;
  //   }
  // }

  void navigationPage() {
    //Navigator.of(context).pushReplacementNamed('/LoginCC');
    if (isLogin != null && isLogin) {
      // Navigator.of(context).pushReplacementNamed('/POBSummaryScreen');
      Navigator.of(context).pushReplacementNamed('${Constants_data.homeScreenName}');
    } else {
      Navigator.of(context).pushReplacementNamed('/Login');
    }
  }

  // Future<int> getFilterChipsWidgets() async {
  //   await SharedPrefs.instance.init();
  //   CubeUser user = SharedPrefs.instance.getUser();
  //   if (user != null) {
  //     _loginToCC(context, user);
  //     return 0;
  //   } else {
  //     _loginPressed();
  //     return 1;
  //   }
  // }

  void _loginPressed() {
    print('login with ${Constants_data.demoUserCC} and ${Constants_data.demoPassCC}');
    CubeUser user = CubeUser(login: Constants_data.demoUserCC, password: Constants_data.demoPassCC);
    print("User: ${user.toJson()}");
    _loginToCC(context, user, saveUser: true);
  }

  _loginToCC(BuildContext context, CubeUser user, {bool saveUser = false}) {
    createSession(user).then((cubeSession) async {
      var tempUser = user;
      user = cubeSession.user..password = tempUser.password;
      if (saveUser) SharedPrefs.instance.saveNewUser(user);
      _loginToCubeChat(context, user);
    }).catchError((err) {
      print("Error in CreateSession : ${err.toString()}");
    });
  }

  _loginToCubeChat(BuildContext context, CubeUser user) {
    print("_loginToCubeChat user $user");
    CubeChatConnection.instance.login(user).then((cubeUser) {
      _goDialogScreen(context, cubeUser);
    }).catchError(_processLoginError);
  }

  void _processLoginError(exception) {
    log("Login error $exception", "Profiler");
    showDialogError(exception, context);
  }

  void _goDialogScreen(BuildContext context, CubeUser cubeUser) async {
    Constants_data.cubeUser = cubeUser;
    print("Cube User Custom Data : ${cubeUser.customData}");
    Navigator.of(context).pushReplacementNamed('${Constants_data.homeScreenName}');
  }
}

class DDPOJO {
  final String name;
  final String value;
  final int id;

  DDPOJO({this.name, this.value, this.id});
}
