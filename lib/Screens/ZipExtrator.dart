// import 'dart:collection';
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:archive/archive.dart';
// import 'package:flexi_profiler/Constants/AppColors.dart';
// import 'package:flexi_profiler/Constants/Constants_data.dart';
// import 'package:flexi_profiler/Constants/StateManager.dart';
// import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
// import 'package:flexi_profiler/DBClasses/CreateAllTables.dart';
// import 'package:flexi_profiler/DBClasses/DBProfessionalList.dart';
// import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:percent_indicator/percent_indicator.dart';
// import 'package:provider/provider.dart';
//
// class DownloadAssetsDemo extends StatefulWidget {
//   DownloadAssetsDemo() : super();
//   final String title = "Data Synchronization";
//
//   @override
//   DownloadAssetsDemoState createState() => DownloadAssetsDemoState();
// }
//
// class DownloadAssetsDemoState extends State<DownloadAssetsDemo> {
//   String _dir;
//   List<String> _images, _tempImages;
//   String _zipPath = '';
//   var dataUser;
//
//   String _localZipFileName = 'images.zip';
//   ApiBaseHelper _helper = ApiBaseHelper();
//
//   @override
//   void initState() {
//     super.initState();
//     _images = List();
//     _tempImages = List();
//     _initDir();
//     getDemoResponse();
//     //imageUpload();
//   }
//
//   _initDir() async {
//     if (Constants_data.app_user == null) {
//       dataUser = await StateManager.getLoginUser();
//     } else {
//       dataUser = Constants_data.app_user;
//     }
//     this.setState(() {
//       msg = "Creating directory";
//     });
//     if (null == _dir) {
//       _dir = (await getApplicationDocumentsDirectory()).path;
//     }
//     this.setState(() {
//       perComplate = perComplate + 5;
//     });
//   }
//
//   bool isError = false;
//
//   Future<String> getDemoResponse() async {
//     if (Constants_data.isBackgroundServiceCallingAPI) {
//       while (Constants_data.isBackgroundServiceCallingAPI) {
//         await new Future.delayed(const Duration(seconds: 2));
//       }
//     }
//     await makeAPICallAccountListAttributesChanges();
//     //await imageUpload();
//     if (Constants_data.app_user == null) {
//       dataUser = await StateManager.getLoginUser();
//     } else {
//       dataUser = Constants_data.app_user;
//     }
//
//     this.setState(() {
//       msg = "Calling server";
//     });
//
//     try {
//       String url = '/GetSyncData?RepId=${dataUser["Rep_Id"]}&AccountType=';
//
//       var mainData = await _helper.get(url);
//       this.setState(() {
//         perComplate = perComplate + 10;
//       });
//       _zipPath = mainData["URL"];
//
//       _downloadZip();
//       // if (mainData["Status"] == 1) {
//       //   _zipPath = mainData["URL"];
//       //
//       //   _downloadZip();
//       // } else {
//       //   this.setState(() {
//       //     isError = true;
//       //     StateManager.logout();
//       //   });
//       //   return null;
//       // }
//
//       return _zipPath;
//     }
//     on Exception catch (err) {
//       this.setState(() {
//         isError = true;
//         StateManager.logout();
//       });
//       return null;
//     }
//   }
//
//   makeAPICallAccountListAttributesChanges() async {
//     await DBProfessionalList.prformQueryOperation(
//         "CREATE TABLE IF NOT EXISTS tblAccountListAttributesChanges (CustomerId TEXT,AccountType TEXT,CategoryCode TEXT,AttributeCode TEXT,AttributeValue TEXT)",
//         []);
//
//     List<dynamic> currentData = await DBProfessionalList.prformQueryOperation("SELECT * from tblAccountListAttributesChanges", []);
//
//     bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
//     if (currentData != null && currentData.length > 0 && isNetworkAvailable) {
//       Map<String, dynamic> mainData = new HashMap();
//       mainData["saveAttributeJson"] = currentData;
//
//       try {
//         String url = "/saveAttributeValue?RepId=${dataUser["Rep_Id"]}";
//         var data = await _helper.post(url, mainData, true);
//         if (data["Status"] == 1) {
//           print("Data saved successfully");
//           List<dynamic> savedData = data["dt_ReturnedTables"];
//           for (int i = 0; i < savedData.length; i++) {
//             await DBProfessionalList.prformQueryOperation(
//                 "DELETE from tblAccountListAttributesChanges WHERE CustomerId=? AND AccountType=? AND CategoryCode=? AND AttributeCode=?",
//                 [savedData[i]["CustomerId"], savedData[i]["AccountType"], savedData[i]["CategoryCode"], savedData[i]["AttributeCode"]]);
//           }
//           print("Data Deleted");
//         } else {
//           print("Error in saving data");
//         }
//       } on Exception catch (err) {
//         print("Error in saveAttributeValue : $err");
//       }
//     }
//   }
//
//   Future<String> _downloadZip() async {
//     _images.clear();
//     _tempImages.clear();
//
//     await makeAPICall();
//
//     this.setState(() {
//       msg = "Downloading data";
//     });
//     var zippedFile = await _downloadFile(_zipPath, _localZipFileName);
//     this.setState(() {
//       perComplate = perComplate + 10;
//     });
//     List<dynamic> tableRows = [];
//
//     this.setState(() {
//       msg = "Initializing data";
//     });
//     await unarchiveAndSave(zippedFile);
//     this.setState(() {
//       perComplate = perComplate + 5;
//     });
//
//     for (int i = 0; i < _tempImages.length; i++) {
//       if (_tempImages[i].contains("_0.txt")) {
//         this.setState(() {
//           msg = "Getting user data";
//         });
//         await readCounter(_tempImages[i], false);
//         this.setState(() {
//           perComplate = perComplate + 25;
//         });
//       } else {
//         tableRows.addAll(await readCounter(_tempImages[i], true));
//         print("Received: ${tableRows.length}");
//       }
//     }
//     this.setState(() {
//       msg = "Getting accounts list";
//     });
//     await CreateAllTables.createProfessionalListAttributeTable(tableRows);
//     this.setState(() {
//       perComplate = perComplate + 35;
//     });
//
//     this.setState(() {
//       msg = "Getting inbox data";
//     });
//     await getItemsForPOBSummary();
//     await getInboxMsg();
//     await getSampleSampleProductDetails();
//     await getWorkType();
//     await getRouteDetails();
//     await getRouteMaster();
//     await createTabletblDCREntryTemp();
//     this.setState(() {
//       perComplate = perComplate + 10;
//       msg = "Completing";
//     });
//     DBProfessionalList.closeDatabase();
//     print("Fully Executed");
//
//     String dateTime = Constants_data.dateToString(DateTime.now(), "dd-MM-yyyy hh:mm a");
//     await StateManager.setLastSyncDateTime(dateTime);
//     Constants_data.lastSyncTime = dateTime;
//
//     Navigator.of(context).pushReplacementNamed('${Constants_data.homeScreenName}');
//
//     return "Success";
//   }
//
//   makeAPICall() async {
//     await DBProfessionalList.prformQueryOperation(
//         "CREATE TABLE IF NOT EXISTS tblAccountListAttributesChanges (CustomerId TEXT,AccountType TEXT,CategoryCode TEXT,AttributeCode TEXT,AttributeValue TEXT)",
//         []);
//
//     List<dynamic> currentData = await DBProfessionalList.prformQueryOperation("SELECT * from tblAccountListAttributesChanges", []);
//
//     if (currentData != null && currentData.length > 0) {
//       Map<String, dynamic> mainData = new HashMap();
//       mainData["saveAttributeJson"] = currentData;
//
//       try {
//         String url = "/saveAttributeValue?RepId=${dataUser["Rep_Id"]}";
//         var data = await _helper.post(url, mainData, true);
//         if (data["Status"] == 1) {
//           print("Data saved successfully");
//           List<dynamic> savedData = data["dt_ReturnedTables"];
//           for (int i = 0; i < savedData.length; i++) {
//             await DBProfessionalList.prformQueryOperation(
//                 "DELETE from tblAccountListAttributesChanges WHERE CustomerId=? AND AccountType=? AND CategoryCode=? AND AttributeCode=?",
//                 [savedData[i]["CustomerId"], savedData[i]["AccountType"], savedData[i]["CategoryCode"], savedData[i]["AttributeCode"]]);
//           }
//           print("Data Deleted");
//         } else {
//           print("Error in saving data");
//         }
//       } on Exception catch (err) {
//         print("Error in saveAttributeValue : $err");
//       }
//     }
//   }
//
//   imageUpload() async {
//     await DBProfessionalList.prformQueryOperation("CREATE TABLE IF NOT EXISTS tbl_AccountImage (id TEXT PRIMARY KEY,IsSaved TEXT)", []);
//     await DBProfessionalList.prformQueryOperation("CREATE TABLE IF NOT EXISTS tblImageStore (id TEXT PRIMARY KEY,IsSaved TEXT,ImageURL BLOB)", []);
//     if (Constants_data.app_user == null) {
//       dataUser = await StateManager.getLoginUser();
//     } else {
//       dataUser = Constants_data.app_user;
//     }
//     List<dynamic> currentData = await DBProfessionalList.prformQueryOperation("SELECT * from tbl_AccountImage WHERE IsSaved=?", ["N"]);
//
//     print("print imageUploadData Count: ${currentData}");
//
//     bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
//     if (isNetworkAvailable) {
//       for (int i = 0; i < currentData.length; i++) {
//         Map<String, dynamic> map = new HashMap();
//         map["AccountId"] = currentData[i]["AccountId"].toString();
//         map["AccountType"] = currentData[i]["AccountType"].toString();
//         map["ImageId"] = currentData[i]["ImageId"].toString();
//         map["ImageName"] = DateTime.now().millisecondsSinceEpoch.toString();
// //      map["Base64"] = "sdngjsnjkvjksfjvbifvnkfhvkfbhivb";
//         map["Base64"] = currentData[i]["ImageURL"].toString();
//
//         try {
//           String url = "/UploadAccountImage?RepId=${dataUser["Rep_Id"]}";
//           var data = await _helper.post(url, map, true);
//           if (data["Status"] == 1) {
//             var resData = data["dt_ReturnedTables"][0][0];
//             String query = "DELETE from tbl_AccountImage WHERE ImageId=?";
//             await DBProfessionalList.prformQueryOperation(query, [map["ImageId"]]);
//             await DBProfessionalList.prformQueryOperation(
//                 "INSERT INTO tbl_AccountImage (AccountId,AccountType,ImageId,ImageURL,ThumbImageURL,IsSaved) VALUES (?,?,?,?,?,?)", [
//               resData["AccountId"],
//               resData["AccountType"],
//               resData["ImageId"],
//               resData["ImageURL"],
//               resData["ThumbImageURL"],
//               resData["IsSaved"]
//             ]);
//           } else {
//             print("Error in upload image: ${data}");
//           }
//         } on Exception catch (err) {
//           print("Error in ");
//         }
//       }
//     }
//   }
//
//   createTabletblDCREntryTemp() async {
//     await DBProfessionalList.prformQueryOperation("CREATE TABLE IF NOT EXISTS tblDCREntryTemp (id TEXT PRIMARY KEY,data TEXT,doc_name TEXT)", []);
//
//     List<dynamic> currentData = await DBProfessionalList.prformQueryOperation("SELECT * from tblDCREntryTemp", []);
//     print("tblDCREntryTemp List : ${currentData}");
//     bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
//     if (currentData != null && currentData.length > 0 && isNetworkAvailable) {
//       for (int i = 0; i < currentData.length; i++) {
//         try {
//           String json_temp = currentData[i]["data"];
//           json_temp = json_temp.replaceAll("\"", "\\\"");
//           json_temp = "\"${json_temp}\"";
//
//           String url = "/SaveDCRDetail?RepId=${dataUser["Rep_Id"]}";
//           var data = await _helper.post(url, json_temp, false);
//
//           if (data["Status"] == 1) {
//             String query = "DELETE from tblDCREntryTemp WHERE id=?";
//             await DBProfessionalList.prformQueryOperation(query, [currentData[i]["id"].toString()]);
//             print("Data Deleted tblDCREntryTemp Successfully removed: ${currentData[i]["id"].toString()}");
//           } else if (data["Status"] == 0) {
//             print("Entry Error : ${data["Message"]}");
//           } else {
//             print("Error in saving DCR details : ${data["Message"]}");
//           }
//
//           print("Response Success : ${data}");
//         } on Exception catch (err) {
//           print("Error in SaveDCRDetail : $err");
//         }
//       }
//       List<dynamic> currentDataAfterDelete = await DBProfessionalList.prformQueryOperation("SELECT * from tblDCREntryTemp", []);
//       print("After Delete tblDCREntryTemp List : ${currentDataAfterDelete}");
//     }
//   }
//   getItemsForPOBSummary() async {
//     var inboxData;
//     String url = '/GetItemForPOBFilter?RepId=${dataUser["Rep_Id"]}&division=${dataUser["division"]}';
//     try {
//       inboxData = await _helper.get(url);
//       if (inboxData != null && inboxData["Status"] == 1 && inboxData["dt_ReturnedTables"] != null) {
//         List<dynamic> listData = inboxData["dt_ReturnedTables"][0];
//         CreateAllTables.createTableFromAPIResponse(listData, "tblItemsForPOBFilter");
//       }
//     } on Exception catch (_) {
//       print('Error');
//       inboxData = null;
//     }
//   }
//   getInboxMsg() async {
//     var inboxData;
//     String url = '/GetMessages?RepId=${dataUser["Rep_Id"]}&AppName=degrtool';
//     try {
//       inboxData = await _helper.get(url);
//       if (inboxData != null && inboxData["Status"] == 1 && inboxData["dt_ReturnedTables"] != null) {
//         List<dynamic> listData = inboxData["dt_ReturnedTables"][0];
//         CreateAllTables.createTableFromAPIResponse(listData, "MessageData");
//       }
//     } on Exception catch (_) {
//       print('Error');
//       inboxData = null;
//     }
//   }
//   getWorkType() async {
//     var inboxData;
//     String url = '/GetWorkTypeMst?RepId=${dataUser["Rep_Id"]}';
//     try {
//       inboxData = await _helper.get(url);
//       if (inboxData != null && inboxData["Status"] == 1 && inboxData["dt_ReturnedTables"] != null) {
//         List<dynamic> listData = inboxData["dt_ReturnedTables"][0];
//         CreateAllTables.createTableFromAPIResponse(listData, "tblWorkTypeMst");
//       }
//     } on Exception catch (_) {
//       print('Error');
//       inboxData = null;
//     }
//   }
//   getRouteDetails() async {
//     var inboxData;
//     String url = '/GetDataForMTP?RepId=${dataUser["Rep_Id"]}&monthYear=05-2020&UserId=${dataUser["Rep_Id"]}';
//     try {
//       inboxData = await _helper.get(url);
//       if (inboxData != null && inboxData["Status"] == 1 && inboxData["dt_ReturnedTables"] != null) {
//         List<dynamic> listData = inboxData["dt_ReturnedTables"][0];
//         for (int i = 0; i < listData.length; i++) {
//           Map<String, dynamic> data = listData[i];
//           data.forEach((k, v) {
//             if (k == "patches") {
//               data[k] = jsonEncode(v);
//             } else {
//               data[k] = v.toString();
//             }
//           });
//           listData[i] = data;
//         }
//         CreateAllTables.createTableFromAPIResponse(listData, "RouteDetailsMst");
//       }
//     } on Exception catch (_) {
//       print('Error');
//       inboxData = null;
//     }
//   }
//   getRouteMaster() async {
//     var inboxData;
//     String url =
//         '/GetSavedRouteDetailForMobile?RepId=${dataUser["Rep_Id"]}&hq_code=${dataUser["hq_code"]}&division_code=${dataUser["division"]}&coverage_group=${dataUser["coverage_group"]}';
//     try {
//       inboxData = await _helper.get(url);
//       if (inboxData != null && inboxData["Status"] == 1 && inboxData["dt_ReturnedTables"] != null) {
//         List<dynamic> listData = inboxData["dt_ReturnedTables"][0];
//         for (int i = 0; i < listData.length; i++) {
//           Map<String, dynamic> data = listData[i];
//           data.forEach((k, v) {
//             if (k == "patches") {
//               data[k] = jsonEncode(v);
//             } else {
//               data[k] = v.toString();
//             }
//           });
//           listData[i] = data;
//         }
//         CreateAllTables.createTableFromAPIResponse(listData, "RouteMst");
//       }
//     } on Exception catch (_) {
//       print('Error');
//       inboxData = null;
//     }
//   }
//   getSampleSampleProductDetails() async {
//     var sampleData;
//     String url = '/GetSampleProductDetail?RepId=${dataUser["Rep_Id"]}';
//     try {
//       sampleData = await _helper.get(url);
//       if (sampleData != null && sampleData["Status"] == 1 && sampleData["dt_ReturnedTables"] != null) {
//         List<dynamic> listData = sampleData["dt_ReturnedTables"][0];
//         CreateAllTables.createTableFromAPIResponse(listData, "SampleProductDetails");
//       }
//     } on Exception catch (_) {
//       print('Error');
//       sampleData = null;
//     }
//   }
//
//   Future<File> _downloadFile(String url, String fileName) async {
//     var req = await http.Client().get(Uri.parse(url));
//     var file = File('$_dir/$fileName');
//     return file.writeAsBytes(req.bodyBytes);
//   }
//
//   unarchiveAndSave(var zippedFile) async {
//     var bytes = zippedFile.readAsBytesSync();
//     var archive = ZipDecoder().decodeBytes(bytes);
//     for (var file in archive) {
//       var fileName = '$_dir/zipdata/${file.name}';
//       if (file.isFile) {
//         var outFile = File(fileName);
//         _tempImages.add(outFile.path);
//         outFile = await outFile.create(recursive: true);
//         await outFile.writeAsBytes(file.content);
//       }
//     }
//   }
//
//   Future<List<dynamic>> readCounter(String path, bool isProfessionalListAttribute) async {
//     try {
//       final file = await File(path);
//       String contents = await file.readAsString();
//       var jsonData = jsonDecode(contents);
//       if (!isProfessionalListAttribute) {
//         await CreateAllTables.createObject(jsonData);
//         return jsonData["dt_ReturnedTables"];
//       } else {
//         //await CreateAllTables.createProfessionalListAttributeTable(jsonData);
//         List<dynamic> dt_ReturnedTables = jsonData["dt_ReturnedTables"];
//         List<dynamic> listTableRows = dt_ReturnedTables[0];
//         print("tableRows: ${listTableRows.length}");
//         return listTableRows;
//       }
//     } catch (e) {
//       // If encountering an error, return 0.
//       return [];
//     }
//   }
//
//   double perComplate = 0;
//   String msg = "Initializing";
//
//   DarkThemeProvider themeChange;
//   ThemeData themeData;
//
//   @override
//   Widget build(BuildContext context) {
//     themeChange = Provider.of<DarkThemeProvider>(context);
//     themeData = Theme.of(context);
//     Constants_data.currentScreenContext = context;
//     return Scaffold(
//         appBar: AppBar(
//           flexibleSpace: Constants_data.getFlexibleAppBar(themeChange.darkTheme),
//           title: Text(widget.title),
//           automaticallyImplyLeading: false,
//         ),
//         body: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
//           Expanded(
//               child: Center(
//             child: Image.asset(
//               '${Constants_data.appIcon}',
//               width: 225,
//             ),
//           )),
//           !isError
//               ? Expanded(
//                   child: Center(
//                       child: CircularPercentIndicator(
//                   radius: 120.0,
//                   lineWidth: 13.0,
//                   percent: perComplate / 100,
//                   center: new Text(
//                     "${perComplate.floor()} %",
//                     style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
//                   ),
//                   footer: Container(
//                       margin: EdgeInsets.only(top: 10),
//                       child: Text(
//                         "${msg}",
//                         style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
//                       )),
//                   circularStrokeCap: CircularStrokeCap.round,
//                   backgroundColor: themeData.hintColor,
//                   progressColor: AppColors.main_color,
//                 )))
//               : Expanded(
//                   child: Column(
//                     children: [
//                       Text("Error in Sync Data, Please login again."),
//                       MaterialButton(
//                         color: AppColors.main_color,
//                         child: Text("Login again"),
//                         onPressed: () {
//                           Navigator.pushReplacementNamed(context, "/Login");
//                         },
//                       )
//                     ],
//                   ),
//                 )
//         ]));
//   }
// }
