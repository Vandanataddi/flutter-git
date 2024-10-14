// import 'dart:convert';
//
// import 'package:connectycube_sdk/connectycube_sdk.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flexi_profiler/ChatConnectyCube/api_utils.dart';
// import 'package:flexi_profiler/ChatConnectyCube/pref_util.dart';
// import 'package:flexi_profiler/Constants/AppColors.dart';
// import 'package:flexi_profiler/Constants/Constants_data.dart';
// import 'package:flexi_profiler/Constants/StateManager.dart';
// import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
// import 'package:flexi_profiler/DBClasses/DBProfessionalList.dart';
// import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:provider/provider.dart';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../DBClasses/CreateAllTables.dart';
//
// class LoginScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     Constants_data.currentScreenContext = context;
//     return Scaffold(
//       body: _LoginScreen(),
//     );
//   }
// }
//
// class _LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => new _LoginScreenState();
// }
//
// class _LoginScreenState extends State<_LoginScreen> {
//   // ignore: non_constant_identifier_names
//   final username_controller = TextEditingController();
//
//   // ignore: non_constant_identifier_names
//   final pass_controller = TextEditingController();
//   bool isLoading = false;
//   ApiBaseHelper _helper = ApiBaseHelper();
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     username_controller.dispose();
//     pass_controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     //print("isMicroLab : ${Constants_data.isMicroLab}");
//     super.initState();
//     DBProfessionalList.deleteDatabaseFromFile();
//     getToken();
//   }
//
//   getToken() async {
//     try {
//       deviceTokenFirebase = await FirebaseMessaging.instance.getToken();
//       print("Token : $deviceTokenFirebase");
//       // FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
//       //  firebaseMessaging.subscribeToTopic('all');
//     } catch (er) {
//       print("Error in getting device Token: ${er.toString()}");
//     }
//   }
//
//   String deviceTokenFirebase = "";
//   final _formKey = GlobalKey<FormState>();
//   final _scaffoldKey = GlobalKey<ScaffoldState>();
//   bool isShowPassword = false;
//   Map<String, dynamic> selectedCountry;
//
//   DarkThemeProvider themeChange;
//   ThemeData themeData;
//
//   @override
//   Widget build(BuildContext context) {
//     themeChange = Provider.of<DarkThemeProvider>(context);
//     themeData = Theme.of(context);
//     return new Scaffold(
//       key: _scaffoldKey,
//       body: new Center(
//         child: new Container(
//           padding: const EdgeInsets.all(30.0),
//           child: SingleChildScrollView(
//             child: new Center(
//               child: Form(
//                   key: _formKey,
//                   child: new Column(children: [
//                     new Padding(padding: EdgeInsets.only(top: 50.0)),
//                     new Image.asset(
//                       '${Constants_data.appIcon}',
//                       width: 225,
//                     ),
//                     new Padding(padding: EdgeInsets.only(top: 50.0)),
//                     Container(
//                         padding: EdgeInsets.only(
//                             top: 5, bottom: 5, right: 5, left: 10),
//                         margin: EdgeInsets.only(bottom: 15),
//                         alignment: Alignment.centerLeft,
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10.0),
//                             border: new Border.all(width: 1.0, color: AppColors
//                                 .grey_color),
//                             color: Colors.transparent),
//                         child: isLoaded
//                             ? getCountryDropDown(context)
//                             : FutureBuilder<Widget>(
//                           future: getCountryList(context),
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState ==
//                                 ConnectionState.done) {
//                               return getCountryDropDown(context);
//                             } else {
//                               return Center(child: CircularProgressIndicator());
//                             }
//                           },
//                         )),
//                     new Container(
//                       margin: EdgeInsets.only(bottom: 20),
//                       child: new TextFormField(
//                         controller: username_controller,
//                         decoration: new InputDecoration(
//                           labelText: "Username",
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(
//                               color: Colors.blue,
//                             ),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide(
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ),
//                         keyboardType: TextInputType.emailAddress,
//                         style: new TextStyle(
//                           fontFamily: "Poppins",
//                         ),
//                       ),
//                     ),
//                     new Container(
//                       margin: EdgeInsets.only(bottom: 20),
//                       child: new TextFormField(
//                         controller: pass_controller,
//                         obscureText: !isShowPassword,
//                         decoration: new InputDecoration(
//                             labelText: "Password",
//                             fillColor: AppColors.white_color,
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10.0),
//                               borderSide: BorderSide(
//                                 color: Colors.blue,
//                               ),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10.0),
//                               borderSide: BorderSide(
//                                 color: Colors.grey,
//                               ),
//                             ),
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 isShowPassword ? Icons.visibility : Icons
//                                     .visibility_off,
//                                 color: Theme
//                                     .of(context)
//                                     .primaryColorDark,
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   isShowPassword = !isShowPassword;
//                                 });
//                               },
//                             )),
//                         style: new TextStyle(
//                           fontFamily: "Poppins",
//                         ),
//                       ),
//                     ),
//                     _getView(),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Container(
//                       alignment: Alignment.centerRight,
//                       child: MaterialButton(
//                         child: Text(
//                           "Forgot Password?",
//                           style: TextStyle(color: themeData.primaryColorLight),
//                         ),
//                         onPressed: () {
//                           openDialogForgetPassword();
//                         },
//                       ),
//                     )
//                   ])),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   bool isLoaded = false;
//   List<dynamic> countryList = [];
//
//   // Future<Null> getCountryList(context) async {
//   //   countryList = [];
//   //   countryList.add({"CountryCode": "", "CountryName": "Select Country (Optional)"});
//   //
//   //   try {
//   //     var mainData = await _helper.get('/GetCountryData');
//   //
//   //     if (mainData["Status"] == 1) {
//   //       countryList.addAll(mainData["dt_ReturnedTables"][0]);
//   //     } else {
//   //       // showSnackBar("${mainData["Message"].toString()}");
//   //     }
//   //   } catch (ex) {
//   //     // showSnackBar("Error in getting country");
//   //     print(ex);
//   //   }
//   //   isLoaded = true;
//   // }
//
//   Future<Null> getCountryList(context) async {
//     countryList = [];
//     countryList.add(
//         {"CountryCode": "", "CountryName": "Select Country (Optional)"});
//
//     try {
//       // const String url = 'http://122.170.7.252/MicroDishaWebApiPublish/api/Login/GetCountryData';
//       //final response = await http.get(Uri.parse('http://122.170.7.252/MicroDishaWebApiPublish/api/Login/GetCountryData'));
//       var mainData = await _helper.get('/Login/GetCountryData');
//      // var mainData = json.decode(response.body);
//       // var mainData = await _helper.get('/GetCountryData');
//
//       if (mainData["Status"] == 1) {
//         countryList.addAll(mainData["dt_ReturnedTables"][0]);
//       } else {
//         // showSnackBar("${mainData["Message"].toString()}");
//       }
//     } catch (ex) {
//       print(ex);
//     }
//     isLoaded = true;
//   }
//
//
//   _getView() {
//     if (isLoading) {
//       return new SpinKitThreeBounce(
//         color: AppColors.main_color,
//         size: 35.0,
//       );
//     } else {
//       return new SizedBox(
//         width: MediaQuery
//             .of(context)
//             .size
//             .width,
//         height: 45,
//         child: new MaterialButton(
//           color: Constants_data.tvLabel_bg,
//           child: new Text("SignIn", style: new TextStyle(
//               fontFamily: "Poppins", color: Constants_data.White)),
//           onPressed: () async {
//             loginNew();
//           },
//         ),
//       );
//     }
//   }
//
//   Future<Null> openDialogForgetPassword() async {
//     TextEditingController cnt_forgotpass_email = new TextEditingController();
//     final formKey = GlobalKey<FormState>();
//     bool isLoading = false;
//     switch (await showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return StatefulBuilder(
//               builder: (BuildContext context, StateSetter setState) {
//                 return SimpleDialog(
//                   contentPadding: EdgeInsets.only(
//                       left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
//                   children: <Widget>[
//                     Container(
//                       color: AppColors.main_color,
//                       margin: EdgeInsets.all(0.0),
//                       padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
//                       width: MediaQuery
//                           .of(context)
//                           .size
//                           .width * 0.7,
//                       height: 90.0,
//                       child: isLoading
//                           ? Center(
//                         child: CircularProgressIndicator(
//                           backgroundColor: AppColors.white_color,
//                         ),
//                       )
//                           : Column(
//                         children: <Widget>[
//                           Container(
//                             child: Icon(
//                               Icons.vpn_key,
//                               size: 30.0,
//                               color: AppColors.white_color,
//                             ),
//                             margin: EdgeInsets.only(bottom: 10.0),
//                           ),
//                           Text(
//                             'Forget Password',
//                             style:
//                             TextStyle(color: AppColors.white_color,
//                                 fontSize: 18.0,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                         margin: EdgeInsets.only(
//                             top: 25, bottom: 10, left: 10, right: 10),
//                         child: Text(
//                           'Profiler will send a temporary password to you register email address.',
//                           style: TextStyle(color: AppColors.black_color,
//                               fontSize: 15.0,
//                               fontWeight: FontWeight.bold),
//                         )),
//                     Form(
//                         key: formKey,
//                         child: Column(
//                           children: <Widget>[
//                             Container(
//                               margin: EdgeInsets.only(
//                                   top: 15, bottom: 10, left: 10, right: 10),
//                               child: TextFormField(
//                                   keyboardType: TextInputType.emailAddress,
//                                   controller: cnt_forgotpass_email,
//                                   validator: (str) {
//                                     if (str.isEmpty) {
//                                       return "User ID can't be blank";
//                                     }
//                                     return null;
//                                   },
//                                   obscureText: false,
//                                   decoration: new InputDecoration(
//                                     labelText: "Enter User ID",
//                                     contentPadding: EdgeInsets.only(bottom: 0),
//                                   )),
//                             )
//                           ],
//                         )),
//                     Container(
//                         margin: EdgeInsets.symmetric(vertical: 15),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: <Widget>[
//                             SimpleDialogOption(
//                               onPressed: () {
//                                 Navigator.pop(context, 0);
//                               },
//                               child: Row(
//                                 children: <Widget>[
//                                   Text(
//                                     'CANCEL',
//                                     style: TextStyle(
//                                         color: AppColors.main_color,
//                                         fontWeight: FontWeight.bold),
//                                   )
//                                 ],
//                               ),
//                             ),
//                             SimpleDialogOption(
//                               onPressed: () async {
//                                 if (formKey.currentState.validate()) {
//                                   FocusScope.of(context).unfocus();
//                                   setState(() {
//                                     isLoading = true;
//                                   });
//
//                                   String url = '/ForgotPassword?RepId=${Uri
//                                       .encodeComponent(
//                                       cnt_forgotpass_email.text)}';
//
//                                   try {
//                                     var mainData = await _helper.get('$url');
//                                     if (mainData["Status"] == 1) {
//                                       Constants_data.toastNormal(
//                                           "${mainData["Message"].toString()}");
//                                       Navigator.pop(context, 1);
//                                     } else {
//                                       Constants_data.toastError(
//                                           "${mainData["Message"].toString()}");
//                                     }
//                                   } on Exception catch (ex) {
//                                     Constants_data.toastError("$ex");
//                                     print("$ex");
//                                   }
//                                   setState(() {
//                                     isLoading = false;
//                                   });
//                                 }
//                               },
//                               child: Row(
//                                 children: <Widget>[
// //
//                                   Text(
//                                     'SEND',
//                                     style: TextStyle(
//                                         color: AppColors.main_color,
//                                         fontWeight: FontWeight.bold),
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ],
//                         )),
//                   ],
//                 );
//               });
//         })) {
//       case 0:
//         break;
//       case 1:
//         print("password changed");
//         break;
//     }
//   }
//
//   // void loginNew() async {
//   //   String Url =
//   //       "/LoginWithPerameter?RepId=${Uri.encodeComponent(username_controller.text)}&password=${Uri.encodeComponent(pass_controller.text)}&DeviceType=${Platform.isAndroid ? "Android" : "ios"}&DeviceId=${Constants_data.deviceId}&Country=${selectedCountry == null ? '' : selectedCountry["CountryCode"]}&RegId=${deviceTokenFirebase}";
//   //
//   //   print("Calling Login : $Url");
//   //   this.setState(() {
//   //     isLoading = true;
//   //   });
//   //   if (_formKey.currentState.validate()) {
//   //     print("Username: ${username_controller.text}");
//   //     print("Password: ${pass_controller.text}");
//   //
//   //     try {
//   //       dynamic data = await _helper.get(Url);
//   //       if (data["Status"] == 2) {
//   //         dialogErrorInLogin(
//   //             data['Message'] == null ? 'Error in login, Please try again.' : data['Message'].toString());
//   //       } else if (data["Status"] == 1) {
//   //         print("DataToSave : ${data["dt_ReturnedTables"][0][0]}");
//   //         data["dt_ReturnedTables"][0][0]["RepId"] = Uri.encodeComponent(data["dt_ReturnedTables"][0][0]["RepId"]);
//   //         Map<String, dynamic> test = data["dt_ReturnedTables"][0][0];
//   //         test["password"] = pass_controller.text;
//   //
//   //         await StateManager.loginUser(test);
//   //         Constants_data.app_user = test;
//   //         print("Test :${Constants_data.app_user}");
//   //         Constants_data.username =
//   //             "${data["dt_ReturnedTables"][0][0]["first_name"]} ${data["dt_ReturnedTables"][0][0]["last_name"]}";
//   //         Constants_data.email = "${data["dt_ReturnedTables"][0][0]["email"]}";
//   //         Constants_data.ProfilePicURL = "${data["dt_ReturnedTables"][0][0]["ProfilePicURL"]}";
//   //         Constants_data.repId = "${data["dt_ReturnedTables"][0][0]["RepId"]}";
//   //         Constants_data.SessionId = "${data["dt_ReturnedTables"][0][0]["SessionId"]}";
//   //         Constants_data.Country = "${data["dt_ReturnedTables"][0][0]["Country"]}";
//   //         Constants_data.division = "${data["dt_ReturnedTables"][0][0]["division"]}";
//   //
//   //         await getFilterChipsWidgets();
//   //         Navigator.of(context).pushReplacementNamed('/ZipExtrator');
//   //       }
//   //       this.setState(() {
//   //         isLoading = false;
//   //       });
//   //     } on Exception catch (err) {
//   //       dialogErrorInLogin(err.toString());
//   //       print("Error: ${err.toString()}");
//   //       this.setState(() {
//   //         isLoading = false;
//   //       });
//   //     }
//   //   }
//   // }
//   //List<Map<String, dynamic>> dtHqAssignment = [];
//   Set<String> uniqueHqCodes = {};
//   List<Map<String, dynamic>> uniqueHqData = [];
//
//
//
//   void loginNew() async {
//     bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
//     if (isNetworkAvailable)
//     {
//       String url = '/Login/LoginNew?userId=${Uri
//           .encodeComponent(username_controller.text)}&password=${Uri
//           .encodeComponent(pass_controller.text)}&deviceId=${Platform.isAndroid
//           ? "Android"
//           : "ios"}&Country=${selectedCountry == null
//           ? ''
//           : selectedCountry["CountryCode"]}&IPAddress=${Constants_data
//           .deviceId}&FCMToken=${deviceTokenFirebase}';
//       //final data = await http.get(Uri.parse(url));
//       print("Calling Login : $url");
//       this.setState(() {
//         isLoading = true;
//       });
//       if (_formKey.currentState.validate()) {
//         print("Username: ${username_controller.text}");
//         print("Password: ${pass_controller.text}");
//
//         try {
//           dynamic data = await _helper.get(url);
//          // final response = await http.get(Uri.parse(url));
//          // dynamic data = json.decode(response.body); // Decode the JSON response
//           //dynamic data = await http.get(Uri.parse(url));
//           if (data["Status"] == 2) {
//             dialogErrorInLogin(
//                 data['Message'] == null
//                     ? 'Error in login, Please try again.'
//                     : data['Message'].toString());
//           }
//           else if (data["Status"] == 1) {
//
//             //dtHqAssignment = data["dt_ReturnedTables"]["dtHqAssignment"];
//
//
//             print("DataToSave : ${data["dt_ReturnedTables"]['dtUserDetail'][0]}");
//             data["dt_ReturnedTables"]['dtUserDetail'][0]["RepId"] =
//                 Uri.encodeComponent(
//                     data["dt_ReturnedTables"]['dtUserDetail'][0]["RepId"]);
//             Map<String,
//                 dynamic> test = data["dt_ReturnedTables"]['dtUserDetail'][0];
//             test["password"] = pass_controller.text;
//
//             await StateManager.loginUser(test);
//             Constants_data.app_user = test;
//             print("Test :${Constants_data.app_user}");
//             Constants_data.username =
//             "${data["dt_ReturnedTables"]['dtUserDetail'][0]["first_name"]} ${data["dt_ReturnedTables"]['dtUserDetail'][0]["last_name"]}";
//             Constants_data.email =
//             "${data["dt_ReturnedTables"]['dtUserDetail'][0]["Email"]}";
//             // Constants_data.ProfilePicURL =
//             // "${data["dt_ReturnedTables"][0][0]["ProfilePicURL"]}";
//             Constants_data.repId =
//             "${data["dt_ReturnedTables"]['dtUserDetail'][0]["RepId"]}";
//             Constants_data.SessionId =
//             "${data["dt_ReturnedTables"]['dtUserDetail'][0]["SessionId"]}";
//             Constants_data.Country =
//             "${data["dt_ReturnedTables"]['dtUserDetail'][0]["Country"]}";
//             Constants_data.division =
//             "${data["dt_ReturnedTables"]['dtUserDetail'][0]["division"]}";
//             Constants_data.hqcode =
//             "${data["dt_ReturnedTables"]['dtUserDetail'][0]["hq_code"]}";
//             //Constants_data.hqname = "${data["dt_ReturnedTables"]['dtUserDetail'][0]["RepId"]}";
//             //Constants_data.divisionname = "${data["dt_ReturnedTables"]['dtUserDetail'][0]["RepId"]}";
//             //Constants_data.groupId = "${data["dt_ReturnedTables"]['dtUserDetail'][0]["RepId"]}";
//             Constants_data.designation =
//             "${data["dt_ReturnedTables"]['dtUserDetail'][0]["Designation"]}";
//             Constants_data.statecode =
//             "${data["dt_ReturnedTables"]['dtUserDetail'][0]["state_code"]}";
//             await CreateAllTables.db.fetchAndStoreData();
//             await CreateAllTables.db.categeorydata();
//             await getFilterChipsWidgets();
//             await  processHqAssignment(data);
//             Navigator.of(context).pushReplacementNamed('/HomeScreenRMT');
//             // await CreateAllTables.db.fetchAndStoreData();
//             // await CreateAllTables.db.categeorydata();
//             // await fetchAndStoreData();
//             // await categeorydata();
//           }
//           this.setState(() {
//             isLoading = false;
//           });
//         }
//         on Exception catch (err) {
//           dialogErrorInLogin(err.toString());
//           print("Error: ${err.toString()}");
//           this.setState(() {
//             isLoading = false;
//           });
//         }
//       }
//     }
//     else {
//       await Constants_data.openDialogNoInternetConection(context);
//     }
//   }
//
//
//   void processHqAssignment(Map<String, dynamic> data) {
//     // Retrieve the dtHqAssignment list from the API response
//     List<Map<String, dynamic>> dtHqAssignment = List<Map<String, dynamic>>.from(data["dt_ReturnedTables"]["dtHqAssignment"]);
//
//     // List<Map<String, dynamic>> uniqueHqData = [];
//     // Iterate over the dtHqAssignment list and filter duplicates
//     for (var hq in dtHqAssignment) {
//       String hqCode = hq['hq_code'];
//       // If the hq_code is not already in the set, add it to uniqueHqData
//       if (!uniqueHqCodes.contains(hqCode)) {
//         uniqueHqCodes.add(hqCode);
//         uniqueHqData.add(hq);
//       }
//     }
//     Constants_data.hqdata = uniqueHqData;
//     // Now, uniqueHqData contains only unique HQ entries based on hq_code
//     print(uniqueHqData);
//   }
//
//
//   Future<int> getFilterChipsWidgets() async {
//     await SharedPrefs.instance.init();
//     CubeUser user = SharedPrefs.instance.getUser();
//     if (user != null) {
//       _loginToCC(context, user);
//       return 0;
//     } else {
//       _loginPressed();
//       return 1;
//     }
//   }
//
//   void _loginPressed() {
//     print('login with ${Constants_data.demoUserCC} and ${Constants_data
//         .demoPassCC}');
//     CubeUser user = CubeUser(
//         login: Constants_data.demoUserCC, password: Constants_data.demoPassCC);
//     print("User: ${user.toJson()}");
//     _loginToCC(context, user, saveUser: true);
//   }
//
//   _loginToCC(BuildContext context, CubeUser user, {bool saveUser = false}) {
//     createSession(user).then((cubeSession) async {
//       var tempUser = user;
//       user = cubeSession.user..password = tempUser.password;
//       if (saveUser) SharedPrefs.instance.saveNewUser(user);
//       _loginToCubeChat(context, user);
//     }).catchError((err) {
//       print("Error in CreateSession : ${err.toString()}");
//     });
//   }
//
//   _loginToCubeChat(BuildContext context, CubeUser user) {
//     print("_loginToCubeChat user $user");
//     CubeChatConnection.instance.login(user).then((cubeUser) {
//       _goDialogScreen(context, cubeUser);
//     }).catchError(_processLoginError);
//   }
//
//   void _processLoginError(exception) {
//     log("Login error $exception", "Profiler");
//     showDialogError(exception, context);
//   }
//
//   void _goDialogScreen(BuildContext context, CubeUser cubeUser) async {
//     print("Task Executed");
//
//     Constants_data.cubeUser = cubeUser;
//     //Navigator.of(context).pushReplacementNamed('/HomeScreenNew');
//
//     // bool refresh = await Navigator.push(
//     //   context,
//     //   MaterialPageRoute(
//     //     settings: RouteSettings(name: "/SelectDialogScreen"),
//     //     builder: (context) => SelectDialogScreen(cubeUser),
//     //   ),
//     // );
//   }
//
//   SharedPreferences prefs;
//
// //   Future<Null> handleSignIn(String id) async {
// //     prefs = await SharedPreferences.getInstance();
// //     String uid = "${id.trim()}";
// //     String nickname = Constants_data.username;
// //     String photoUrl = Constants_data.ProfilePicURL == null ||
// //             Constants_data.ProfilePicURL == ""
// //         ? "https://www.computerhope.com/jargon/g/guest-user.jpg"
// //         : Constants_data.ProfilePicURL;
// //
// //     final QuerySnapshot result = await Firestore.instance
// //         .collection('users')
// //         .where('id', isEqualTo: uid)
// //         .getDocuments();
// //     final List<DocumentSnapshot> documents = result.documents;
// //     if (documents.length == 0) {
// //       Firestore.instance.collection('users').document(uid).setData({
// //         'nickname': nickname,
// //         'photoUrl': photoUrl,
// //         'id': uid,
// //         'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
// //         'chattingWith': null
// //       });
// //
// //       await prefs.setString('id', uid);
// //       await prefs.setString('nickname', nickname);
// //       await prefs.setString('photoUrl', photoUrl);
// //     } else {
// //       await prefs.setString('id', documents[0]['id']);
// //       await prefs.setString('nickname', nickname);
// //       await prefs.setString('photoUrl', photoUrl);
// //
// //       Firestore.instance
// //           .collection('users')
// //           .document(uid)
// //           .updateData({'nickname': nickname, "photoUrl": photoUrl});
// //     }
// //
// // //    Navigator.of(context).push(
// // //      MaterialPageRoute(
// // //        settings: RouteSettings(name: "/HomeScreenChat"),
// // //        builder: (context) => HomeScreen(currentUserId: uid),
// // //      ),
// // //    );
// //   }
//
//   // void showSnackBar(String msg) {
//   //   _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('${msg}')));
//   // }
//
//   getCountryDropDown(BuildContext context) {
//     return DropdownButton<dynamic>(
//       underline: SizedBox(),
//       hint: Text("Select Country (Optional)",
//           style: TextStyle(
//             fontFamily: "Poppins",
//           )),
//       value: selectedCountry,
//       isExpanded: true,
//       onChanged: (newValue) {
//         print("Selected Country : ${newValue}");
//         print("List Country : ${countryList}");
//         setState(() {
//           selectedCountry = newValue;
//         });
//       },
//       items: countryList.map((dynamic lang) {
//         return DropdownMenuItem<dynamic>(
//           value: lang,
//           child: Text(
//               lang["CountryName"], style: TextStyle(fontFamily: "Poppins")),
//         );
//       }).toList(),
//     );
//   }
//
//   Future<Null> dialogErrorInLogin(msg) async {
//     switch (await showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return StatefulBuilder(
//               builder: (BuildContext context, StateSetter setState) {
//                 return SimpleDialog(
//                   contentPadding: EdgeInsets.only(
//                       left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
//                   children: <Widget>[
//                     Container(
//                       color: AppColors.red_color,
//                       margin: EdgeInsets.all(0.0),
//                       padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
//                       width: MediaQuery
//                           .of(context)
//                           .size
//                           .width * 0.7,
//                       height: 90.0,
//                       child: Column(
//                         children: <Widget>[
//                           Container(
//                             child: Icon(
//                               Icons.error,
//                               size: 30.0,
//                               color: AppColors.white_color,
//                             ),
//                             margin: EdgeInsets.only(bottom: 10.0),
//                           ),
//                           Text(
//                             'Error in Login',
//                             style: TextStyle(color: AppColors.white_color,
//                                 fontSize: 18.0,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                         alignment: Alignment.center,
//                         margin: EdgeInsets.only(
//                             top: 25, bottom: 15, left: 15, right: 15),
//                         child: Text(
//                           '$msg',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(color: AppColors.black_color,
//                               fontSize: 15.0,
//                               fontWeight: FontWeight.bold),
//                         )),
//                     Container(
//                         margin: EdgeInsets.symmetric(vertical: 15),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: <Widget>[
//                             SimpleDialogOption(
//                               onPressed: () {
//                                 Navigator.pop(context, 0);
//                               },
//                               child: Row(
//                                 children: <Widget>[
//                                   Text(
//                                     'OK',
//                                     style: TextStyle(
//                                         color: AppColors.main_color,
//                                         fontWeight: FontWeight.bold),
//                                   )
//                                 ],
//                               ),
//                             )
//                           ],
//                         )),
//                   ],
//                 );
//               });
//         })) {
//       case 0:
//         break;
//       case 1:
//         print("password changed");
//         break;
//     }
//   }
//
//  //  Future<void> fetchAndStoreData() async {
//  //    final url = 'http://122.170.7.252/MicroDishaWebApiPublish/api/Profiler/GetTemplateJSONDetails';
//  //
//  //    try {
//  //      final response = await http.get(Uri.parse(url));
//  //
//  //      if (response.statusCode == 200) {
//  //        final data = json.decode(response.body);
//  //        await storeDataLocally(data);
//  //      } else {
//  //        throw Exception('Failed to load data');
//  //      }
//  //    } catch (e) {
//  //      print('Error fetching and storing data: $e');
//  //    }
//  //  }
//  //  Future<void> storeDataLocally(Map<String, dynamic> apiData) async {
//  //    final db = await CreateAllTables.db.database;
//  //
//  //    try {
//  //      // Extract TemplateDetails list
//  //      final List<dynamic> templateDetails = apiData["dt_ReturnedTables"]['dt_TemplateJSONDetails'];
//  //
//  //      for (var item in templateDetails) {
//  //        // Insert into TemplateDefinitionMst table
//  //        await db.insert('TemplateDefinitionMst', {
//  //          'AccountType': item['AccountType'],
//  //          'TemplateJson': item['TemplateJson'],
//  //          'HeaderTemplateJson': item['HeaderTemplateJson'],
//  //          'ViewId': item['ViewId'],
//  //        });
//  //      }
//  //
//  //      print('Data inserted successfully.');
//  //    } catch (e) {
//  //      print('Error inserting data: $e');
//  //    }
//  //  }
//  //  Future<void> categeorydata() async{
//  //    final url = 'http://122.170.7.252/MicroDishaWebApiPublish/api/Profiler/GetCategoryMstDetails';
//  //
//  //    try {
//  //      final response = await http.get(Uri.parse(url));
//  //
//  //      if (response.statusCode == 200) {
//  //        final data = json.decode(response.body);
//  //        await storeCategeorydataLocally(data);
//  //      } else {
//  //        throw Exception('Failed to load data');
//  //      }
//  //    } catch (e) {
//  //      print('Error fetching and storing data: $e');
//  //    }
//  // }
//  //  Future<void> storeCategeorydataLocally(Map<String, dynamic> apiData) async {
//  //    final db = await CreateAllTables.db.database;
//  //
//  //    try {
//  //      final List<dynamic> templateDetails = apiData["dt_ReturnedTables"]['dt_CategoryMstDetails'];
//  //
//  //      for (var item in templateDetails) {
//  //        // Insert into AccountCategoryMst table
//  //        await db.insert('AccountCategoryMst', {
//  //          'AccountType': item['AccountType'],
//  //          'CategoryDescription': item['CategoryDescription'],
//  //          'CategoryCode': item['CategoryCode'],
//  //          'ImageURL': item['ImageURL'],
//  //          'CategorySeqNo': item['CategorySeqNo'],
//  //        });
//  //      }
//  //
//  //      print('Data inserted successfully.');
//  //    } catch (e) {
//  //      print('Error inserting data: $e');
//  //    }
//  //  }
//
// }


import 'dart:convert';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flexi_profiler/ChatConnectyCube/api_utils.dart';
import 'package:flexi_profiler/ChatConnectyCube/pref_util.dart';
import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Constants/StateManager.dart';
import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
import 'package:flexi_profiler/DBClasses/DBProfessionalList.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../DBClasses/CreateAllTables.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Constants_data.currentScreenContext = context;
    return Scaffold(
      body: _LoginScreen(),
    );
  }
}

class _LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<_LoginScreen> {
  // ignore: non_constant_identifier_names
  final username_controller = TextEditingController();

  // ignore: non_constant_identifier_names
  final pass_controller = TextEditingController();
  bool isLoading = false;
  ApiBaseHelper _helper = ApiBaseHelper();
  bool shouldCallDashboardApi = false;


  @override
  void dispose() {
    // TODO: implement dispose
    username_controller.dispose();
    pass_controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    //print("isMicroLab : ${Constants_data.isMicroLab}");
    super.initState();
    DBProfessionalList.deleteDatabaseFromFile();
    getToken();
  }


  getToken() async {
    try {
      deviceTokenFirebase = await FirebaseMessaging.instance.getToken();
      print("Token : $deviceTokenFirebase");
      // FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
      //  firebaseMessaging.subscribeToTopic('all');
    } catch (er) {
      print("Error in getting device Token: ${er.toString()}");
    }
  }

  String deviceTokenFirebase = "";
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isShowPassword = false;
  Map<String, dynamic> selectedCountry;

  DarkThemeProvider themeChange;
  ThemeData themeData;


  @override
  Widget build(BuildContext context) {
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    return new Scaffold(
      key: _scaffoldKey,
      body: new Center(
        child: new Container(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: new Center(
              child: Form(
                  key: _formKey,
                  child: new Column(children: [
                    new Padding(padding: EdgeInsets.only(top: 50.0)),
                    new Image.asset(
                      '${Constants_data.appIcon}',
                      width: 225,
                    ),
                    new Padding(padding: EdgeInsets.only(top: 50.0)),
                    Container(
                        padding: EdgeInsets.only(
                            top: 5, bottom: 5, right: 5, left: 10),
                        margin: EdgeInsets.only(bottom: 15),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: new Border.all(width: 1.0, color: AppColors
                                .grey_color),
                            color: Colors.transparent),
                        child: isLoaded
                            ? getCountryDropDown(context)
                            : FutureBuilder<Widget>(
                          future: getCountryList(context),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return getCountryDropDown(context);
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                        )),
                     Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: new TextFormField(
                        controller: username_controller,
                        decoration: new InputDecoration(
                          labelText: "Username",
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        style: new TextStyle(
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                     Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: new TextFormField(
                        controller: pass_controller,
                        obscureText: !isShowPassword,
                        decoration: new InputDecoration(
                            labelText: "Password",
                            fillColor: AppColors.white_color,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.grey,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isShowPassword ? Icons.visibility : Icons
                                    .visibility_off,
                                color: Theme
                                    .of(context)
                                    .primaryColorDark,
                              ),
                              onPressed: () {
                                setState(() {
                                  isShowPassword = !isShowPassword;
                                });
                              },
                            )),
                        style: new TextStyle(
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    _getView(),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      child: MaterialButton(
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(color: themeData.primaryColorLight),
                        ),
                        onPressed: () {
                          openDialogForgetPassword();
                        },
                      ),
                    )
                  ])),
            ),
          ),
        ),
      ),
    );
  }

  bool isLoaded = false;
  List<dynamic> countryList = [];

  Future<Null> getCountryList(context) async {
    bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
    if (isNetworkAvailable) {
      countryList = [];
       countryList.add(
      //     //{"CountryCode": "", "CountryName": "Select Country (Optional)"});
          {"CountryCode": "C0001", "CountryName": "INDIA"});

      try {
        // const String url = 'http://122.170.7.252/MicroDishaWebApiPublish/api/Login/GetCountryData';
        //final response = await http.get(Uri.parse('http://122.170.7.252/MicroDishaWebApiPublish/api/Login/GetCountryData'));
        var mainData = await _helper.get('/Login/GetCountryData');

        if (mainData["Status"] == 1) {
          countryList.addAll(mainData["dt_ReturnedTables"][0]);
        } else {
          // showSnackBar("${mainData["Message"].toString()}");
        }
      } catch (ex) {
        print(ex);
      }
      isLoaded = true;
    }  else {
      await Constants_data.openDialogNoInternetConection(context);
    }
  }


  _getView() {
    if (isLoading) {
      return new SpinKitThreeBounce(
        color: AppColors.main_color,
        size: 35.0,
      );
    } else {
      return new SizedBox(
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: 45,
        child: new MaterialButton(
          color: Constants_data.tvLabel_bg,
          child: new Text("SignIn", style: new TextStyle(
              fontFamily: "Poppins", color: Constants_data.White)),
          onPressed: () async {
            loginNew();
          },
        ),
      );
    }
  }

  Future<Null> openDialogForgetPassword() async {
    TextEditingController cnt_forgotpass_email = new TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SimpleDialog(
                  contentPadding: EdgeInsets.only(
                      left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
                  children: <Widget>[
                    Container(
                      color: AppColors.main_color,
                      margin: EdgeInsets.all(0.0),
                      padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.7,
                      height: 90.0,
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
                              Icons.vpn_key,
                              size: 30.0,
                              color: AppColors.white_color,
                            ),
                            margin: EdgeInsets.only(bottom: 10.0),
                          ),
                          Text(
                            'Forget Password',
                            style:
                            TextStyle(color: AppColors.white_color,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(
                            top: 25, bottom: 10, left: 10, right: 10),
                        child: Text(
                          'Profiler will send a temporary password to you register email address.',
                          style: TextStyle(color: AppColors.black_color,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold),
                        )),
                    Form(
                        key: formKey,
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(
                                  top: 15, bottom: 10, left: 10, right: 10),
                              child: TextFormField(
                                  keyboardType: TextInputType.emailAddress,
                                  controller: cnt_forgotpass_email,
                                  validator: (str) {
                                    if (str.isEmpty) {
                                      return "User ID can't be blank";
                                    }
                                    return null;
                                  },
                                  obscureText: false,
                                  decoration: new InputDecoration(
                                    labelText: "Enter User ID",
                                    contentPadding: EdgeInsets.only(bottom: 0),
                                  )),
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
                              onPressed: () {
                                Navigator.pop(context, 0);
                              },
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    'CANCEL',
                                    style: TextStyle(
                                        color: AppColors.main_color,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                            SimpleDialogOption(
                              onPressed: () async {
                                if (formKey.currentState.validate()) {
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    isLoading = true;
                                  });
                                  String url = '/Profiler/ForgotPassword?RepId=${Uri
                                      .encodeComponent(
                                      cnt_forgotpass_email.text)}';

                                  try {
                                    var mainData = await _helper.get('$url');
                                    if (mainData["Status"] == 1) {
                                      Constants_data.toastNormal(
                                          "${mainData["Message"].toString()}");
                                      Navigator.pop(context, 1);
                                    } else {
                                      Constants_data.toastError(
                                          "${mainData["Message"].toString()}");
                                    }
                                  } on Exception catch (ex) {
                                    Constants_data.toastError("$ex");
                                    print("$ex");
                                  }
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    'SEND',
                                    style: TextStyle(
                                        color: AppColors.main_color,
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
        break;
      case 1:
        print("password changed");
        break;
    }
  }

  // void loginNew() async {
  //   String Url =
  //       "/LoginWithPerameter?RepId=${Uri.encodeComponent(username_controller.text)}&password=${Uri.encodeComponent(pass_controller.text)}&DeviceType=${Platform.isAndroid ? "Android" : "ios"}&DeviceId=${Constants_data.deviceId}&Country=${selectedCountry == null ? '' : selectedCountry["CountryCode"]}&RegId=${deviceTokenFirebase}";
  //
  //   print("Calling Login : $Url");
  //   this.setState(() {
  //     isLoading = true;
  //   });
  //   if (_formKey.currentState.validate()) {
  //     print("Username: ${username_controller.text}");
  //     print("Password: ${pass_controller.text}");
  //
  //     try {
  //       dynamic data = await _helper.get(Url);
  //       if (data["Status"] == 2) {
  //         dialogErrorInLogin(
  //             data['Message'] == null ? 'Error in login, Please try again.' : data['Message'].toString());
  //       } else if (data["Status"] == 1) {
  //         print("DataToSave : ${data["dt_ReturnedTables"][0][0]}");
  //         data["dt_ReturnedTables"][0][0]["RepId"] = Uri.encodeComponent(data["dt_ReturnedTables"][0][0]["RepId"]);
  //         Map<String, dynamic> test = data["dt_ReturnedTables"][0][0];
  //         test["password"] = pass_controller.text;
  //
  //         await StateManager.loginUser(test);
  //         Constants_data.app_user = test;
  //         print("Test :${Constants_data.app_user}");
  //         Constants_data.username =
  //             "${data["dt_ReturnedTables"][0][0]["first_name"]} ${data["dt_ReturnedTables"][0][0]["last_name"]}";
  //         Constants_data.email = "${data["dt_ReturnedTables"][0][0]["email"]}";
  //         Constants_data.ProfilePicURL = "${data["dt_ReturnedTables"][0][0]["ProfilePicURL"]}";
  //         Constants_data.repId = "${data["dt_ReturnedTables"][0][0]["RepId"]}";
  //         Constants_data.SessionId = "${data["dt_ReturnedTables"][0][0]["SessionId"]}";
  //         Constants_data.Country = "${data["dt_ReturnedTables"][0][0]["Country"]}";
  //         Constants_data.division = "${data["dt_ReturnedTables"][0][0]["division"]}";
  //
  //         await getFilterChipsWidgets();
  //         Navigator.of(context).pushReplacementNamed('/ZipExtrator');
  //       }
  //       this.setState(() {
  //         isLoading = false;
  //       });
  //     } on Exception catch (err) {
  //       dialogErrorInLogin(err.toString());
  //       print("Error: ${err.toString()}");
  //       this.setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   }
  // }

  final String _baseprofileUrl = Constants_data.profileUrl;
  void loginNew() async {
    bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
    if (isNetworkAvailable) {
      String url = '/Login/LoginNew?userId=${Uri
          .encodeComponent(username_controller.text)}&password=${Uri
          .encodeComponent(pass_controller.text)}&deviceId=${Platform.isAndroid
          ? "Android"
          : "ios"}&Country=${selectedCountry == null
          ? ''
          : selectedCountry["CountryCode"]}&IPAddress=${Constants_data
          .deviceId}&FCMToken=${deviceTokenFirebase}';
      //final data = await http.get(Uri.parse(url));
      print("Calling Login : $url");
      this.setState(() {
        isLoading = true;
      });
      if (_formKey.currentState.validate()) {
        print("Username: ${username_controller.text}");
        print("Password: ${pass_controller.text}");

        try {
          dynamic data = await _helper.get(url);
          //dynamic data = await http.get(Uri.parse(url));
          if (data["Status"] == 2) {
            dialogErrorInLogin(
                data['Message'] == null
                    ? 'Error in login, Please try again.'
                    : data['Message'].toString());
          }
          else if (data["Status"] == 1) {
            print("DataToSave : ${data["dt_ReturnedTables"]['dtUserDetail'][0]}");
            data["dt_ReturnedTables"]['dtUserDetail'][0]["RepId"] = Uri.encodeComponent(data["dt_ReturnedTables"]['dtUserDetail'][0]["RepId"]);
            Map<String, dynamic> test = data["dt_ReturnedTables"]['dtUserDetail'][0];
            test["password"] = pass_controller.text;

            await StateManager.loginUser(test);

            // SharedPreferences prefs = await SharedPreferences.getInstance();
            // prefs.setBool('isLogin', true);  // Set login status
            // prefs.setString('userData', jsonEncode(test));  // Save user data
            await StateManager.divisionManager(
                data["dt_ReturnedTables"]['dtDivisionAssignment']);
            await StateManager.hqManager(
                data["dt_ReturnedTables"]["dtHqAssignment"]);

            // Constants_data.divisiondata = data["dt_ReturnedTables"]['dtDivisionAssignment'];
            // Constants_data.hqdata = data["dt_ReturnedTables"]["dtHqAssignment"];
            Constants_data.divisiondata = List<Map<String, dynamic>>.from(data["dt_ReturnedTables"]['dtDivisionAssignment']);
            Constants_data.hqdata = List<Map<String, dynamic>>.from(data["dt_ReturnedTables"]["dtHqAssignment"]);
            Constants_data.app_user = test;
            Constants_data.app_user["designationGroupCode"] =
            "${data["dt_ReturnedTables"]['dtAllAssignment'][0]["designation_group_code"]}";
            print("Test :${Constants_data.app_user}");
            Constants_data.username =
            "${data["dt_ReturnedTables"]['dtUserDetail'][0]["first_name"]} ${data["dt_ReturnedTables"]['dtUserDetail'][0]["last_name"]}";
            Constants_data.email =
            "${data["dt_ReturnedTables"]['dtUserDetail'][0]["Email"]}";
             //Constants_data.ProfilePicURL =
             //"${data["dt_ReturnedTables"]['dtUserDetail'][0]["ProfilePic"]}";
            String profile = "${data["dt_ReturnedTables"]['dtUserDetail'][0]["ProfilePic"]}";
            Constants_data.ProfilePicURL = "$_baseprofileUrl/content/ProfilePic/$profile";
            // Constants_data.ProfilePicURL = "http://122.170.7.252/MicroDishaWebApiPublish/content/ProfilePic/$profile";
             Constants_data.repId =
            "${data["dt_ReturnedTables"]['dtUserDetail'][0]["RepId"]}";
            Constants_data.SessionId =
            "${data["dt_ReturnedTables"]['dtUserDetail'][0]["SessionId"]}";
            Constants_data.Country =
            "${data["dt_ReturnedTables"]['dtUserDetail'][0]["Country"]}";
            Constants_data.division =
            "${data["dt_ReturnedTables"]['dtUserDetail'][0]["division"]}";
            Constants_data.hqcode =
            "${data["dt_ReturnedTables"]['dtUserDetail'][0]["hq_code"]}";
            Constants_data.designation =
            "${data["dt_ReturnedTables"]['dtUserDetail'][0]["Designation"]}";
            Constants_data.designationGroupCode =
            "${data["dt_ReturnedTables"]['dtAllAssignment'][0]["designation_group_code"]}";
            Constants_data.statecode =
            "${data["dt_ReturnedTables"]['dtUserDetail'][0]["state_code"]}";
            await CreateAllTables.db.fetchAndStoreTemplateData();
            await CreateAllTables.db.fetchAndStoreCategoryData();
            //await getFilterChipsWidgets();
             Navigator.of(context).pushReplacementNamed('/HomeScreenRMT');
          }
          this.setState(() {
            isLoading = false;
          });
        }
        on Exception catch (err) {
          dialogErrorInLogin(err.toString());
          print("Error: ${err.toString()}");
          this.setState(() {
            isLoading = false;
          });
        }
      }
    }
    else {
      await Constants_data.openDialogNoInternetConection(context);
    }
  }

  Future<int> getFilterChipsWidgets() async {
    await SharedPrefs.instance.init();
    CubeUser user = SharedPrefs.instance.getUser();
    if (user != null) {
      // _loginToCC(context, user);
      return 0;
    } else {
      _loginPressed();
      return 1;
    }
  }

  void _loginPressed() {
    print('login with ${Constants_data.demoUserCC} and ${Constants_data
        .demoPassCC}');
    CubeUser user = CubeUser(
        login: Constants_data.demoUserCC, password: Constants_data.demoPassCC);
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
    print("Task Executed");
    Constants_data.cubeUser = cubeUser;
    //Navigator.of(context).pushReplacementNamed('/HomeScreenNew');

    // bool refresh = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     settings: RouteSettings(name: "/SelectDialogScreen"),
    //     builder: (context) => SelectDialogScreen(cubeUser),
    //   ),
    // );
  }

  SharedPreferences prefs;

//   Future<Null> handleSignIn(String id) async {
//     prefs = await SharedPreferences.getInstance();
//     String uid = "${id.trim()}";
//     String nickname = Constants_data.username;
//     String photoUrl = Constants_data.ProfilePicURL == null ||
//             Constants_data.ProfilePicURL == ""
//         ? "https://www.computerhope.com/jargon/g/guest-user.jpg"
//         : Constants_data.ProfilePicURL;
//
//     final QuerySnapshot result = await Firestore.instance
//         .collection('users')
//         .where('id', isEqualTo: uid)
//         .getDocuments();
//     final List<DocumentSnapshot> documents = result.documents;
//     if (documents.length == 0) {
//       Firestore.instance.collection('users').document(uid).setData({
//         'nickname': nickname,
//         'photoUrl': photoUrl,
//         'id': uid,
//         'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
//         'chattingWith': null
//       });
//
//       await prefs.setString('id', uid);
//       await prefs.setString('nickname', nickname);
//       await prefs.setString('photoUrl', photoUrl);
//     } else {
//       await prefs.setString('id', documents[0]['id']);
//       await prefs.setString('nickname', nickname);
//       await prefs.setString('photoUrl', photoUrl);
//
//       Firestore.instance
//           .collection('users')
//           .document(uid)
//           .updateData({'nickname': nickname, "photoUrl": photoUrl});
//     }
//
// //    Navigator.of(context).push(
// //      MaterialPageRoute(
// //        settings: RouteSettings(name: "/HomeScreenChat"),
// //        builder: (context) => HomeScreen(currentUserId: uid),
// //      ),
// //    );
//   }

  // void showSnackBar(String msg) {
  //   _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('${msg}')));
  // }

  getCountryDropDown(BuildContext context) {
    // Initialize selectedCountry to 'India' by default
    selectedCountry ??= countryList.firstWhere(
          (country) => country['CountryName'] == 'INDIA',
      orElse: () => null, // If 'India' is not found
    );

    return DropdownButton<dynamic>(
      underline: SizedBox(), // Removes the underline
      value: selectedCountry, // Display 'India' as the default selected value
      isExpanded: true,
      onChanged: (newValue) {
        print("Selected Country: $newValue");
        setState(() {
          selectedCountry = newValue;
        });
      },
      items: countryList.map((dynamic country) {
        return DropdownMenuItem<dynamic>(
          value: country,
          child: Text(
            country["CountryName"], // Bind country name
            style: TextStyle(fontFamily: "Poppins"),
          ),
        );
      }).toList(),
    );
  }


  getCountryDropDowns(BuildContext context) {
    return DropdownButton<dynamic>(
      underline: SizedBox(),
      hint: Text("Select Country (Optional)",
          style: TextStyle(
            fontFamily: "Poppins",
          )),
      value: selectedCountry,
      isExpanded: true,
      onChanged: (newValue) {
        print("Selected Country : ${newValue}");
        print("List Country : ${countryList}");
        setState(() {
          selectedCountry = newValue;
        });
      },
      items: countryList.map((dynamic lang) {
        return DropdownMenuItem<dynamic>(
          value: lang,
          child: Text(
              lang["CountryName"], style: TextStyle(fontFamily: "Poppins")),
        );
      }).toList(),
    );
  }

  Future<Null> dialogErrorInLogin(msg) async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SimpleDialog(
                  contentPadding: EdgeInsets.only(
                      left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
                  children: <Widget>[
                    Container(
                      color: AppColors.red_color,
                      margin: EdgeInsets.all(0.0),
                      padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.7,
                      height: 90.0,
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Icon(
                              Icons.error,
                              size: 30.0,
                              color: AppColors.white_color,
                            ),
                            margin: EdgeInsets.only(bottom: 10.0),
                          ),
                          Text(
                            'Error in Login',
                            style: TextStyle(color: AppColors.white_color,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                            top: 25, bottom: 15, left: 15, right: 15),
                        child: Text(
                          '$msg',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.black_color,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold),
                        )),
                    Container(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SimpleDialogOption(
                              onPressed: () {
                                Navigator.pop(context, 0);
                              },
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    'OK',
                                    style: TextStyle(
                                        color: AppColors.main_color,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            )
                          ],
                        )),
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

//  Future<void> fetchAndStoreData() async {
//    final url = 'http://122.170.7.252/MicroDishaWebApiPublish/api/Profiler/GetTemplateJSONDetails';
//
//    try {
//      final response = await http.get(Uri.parse(url));
//
//      if (response.statusCode == 200) {
//        final data = json.decode(response.body);
//        await storeDataLocally(data);
//      } else {
//        throw Exception('Failed to load data');
//      }
//    } catch (e) {
//      print('Error fetching and storing data: $e');
//    }
//  }
//  Future<void> storeDataLocally(Map<String, dynamic> apiData) async {
//    final db = await CreateAllTables.db.database;
//
//    try {
//      // Extract TemplateDetails list
//      final List<dynamic> templateDetails = apiData["dt_ReturnedTables"]['dt_TemplateJSONDetails'];
//
//      for (var item in templateDetails) {
//        // Insert into TemplateDefinitionMst table
//        await db.insert('TemplateDefinitionMst', {
//          'AccountType': item['AccountType'],
//          'TemplateJson': item['TemplateJson'],
//          'HeaderTemplateJson': item['HeaderTemplateJson'],
//          'ViewId': item['ViewId'],
//        });
//      }
//
//      print('Data inserted successfully.');
//    } catch (e) {
//      print('Error inserting data: $e');
//    }
//  }
//  Future<void> categeorydata() async{
//    final url = 'http://122.170.7.252/MicroDishaWebApiPublish/api/Profiler/GetCategoryMstDetails';
//
//    try {
//      final response = await http.get(Uri.parse(url));
//
//      if (response.statusCode == 200) {
//        final data = json.decode(response.body);
//        await storeCategeorydataLocally(data);
//      } else {
//        throw Exception('Failed to load data');
//      }
//    } catch (e) {
//      print('Error fetching and storing data: $e');
//    }
// }
//  Future<void> storeCategeorydataLocally(Map<String, dynamic> apiData) async {
//    final db = await CreateAllTables.db.database;
//
//    try {
//      final List<dynamic> templateDetails = apiData["dt_ReturnedTables"]['dt_CategoryMstDetails'];
//
//      for (var item in templateDetails) {
//        // Insert into AccountCategoryMst table
//        await db.insert('AccountCategoryMst', {
//          'AccountType': item['AccountType'],
//          'CategoryDescription': item['CategoryDescription'],
//          'CategoryCode': item['CategoryCode'],
//          'ImageURL': item['ImageURL'],
//          'CategorySeqNo': item['CategorySeqNo'],
//        });
//      }
//
//      print('Data inserted successfully.');
//    } catch (e) {
//      print('Error inserting data: $e');
//    }
//  }

}