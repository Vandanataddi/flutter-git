// import 'dart:collection';
// import 'dart:convert';
//
// import 'package:device_calendar/device_calendar.dart';
// import 'package:flexi_profiler/Constants/AppColors.dart';
// import 'package:flexi_profiler/Constants/Constants_data.dart';
// import 'package:flexi_profiler/Constants/StateManager.dart';
// import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
//
// class CalendarScreenAll extends StatefulWidget {
//   @override
//   _CalendarScreenState createState() => new _CalendarScreenState();
// }
//
// class _CalendarScreenState extends State<CalendarScreenAll> {
//   DeviceCalendarPlugin _deviceCalendarPlugin;
//   List<Calendar> _calendars;
//   List<Event> _calendarEvents;
//   Map<DateTime, dynamic> mainList;
//   ApiBaseHelper _helper = ApiBaseHelper();
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   _CalendarScreenState() {
//     _deviceCalendarPlugin = DeviceCalendarPlugin();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Constants_data.currentScreenContext = context;
//     return FutureBuilder(
//       future: getData(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           return SingleChildScrollView(
//               child: new Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.all(10),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: getColuns(),
//                   )));
//         } else {
//           return Center(child: CircularProgressIndicator());
//         }
//       },
//     );
//   }
//
//   List<dynamic> listData;
//   final currentDate = DateTime(2020, 5, 01);
//
//   Future<Null> getData() async {
//     mainList = new HashMap();
//     listData = [];
//
//     String month = currentDate.month < 10 ? "0${currentDate.month}" : "${currentDate.month}";
//     String date = "${month}-${currentDate.year}";
//     print("Months : ${date}");
//
//     var dataUser;
//     if (Constants_data.app_user == null) {
//       dataUser = await StateManager.getLoginUser();
//     } else {
//       dataUser = Constants_data.app_user;
//     }
// //      ${dataUser["RepId"]};
//
//     try {
//       String url = '/GetSavedMTPData_ForCalendar?RepId=${dataUser["RepId"]}&monthYear=${date}';
//
//       dynamic mainData = await _helper.get(url);
//       if (mainData["Status"] == 1) {
//         List<dynamic> dt_ReturnedTables = mainData["dt_ReturnedTables"];
//         listData = dt_ReturnedTables[0];
//
//         for (int i = 0; i < listData.length; i++) {
//           mainList[Constants_data.stringToDate("${listData[i]["date"]}", "dd-MM-yyyy")] = listData[i];
//         }
//         // List<dynamic> m = mainList.keys.toList()..sort();
//         print("Maindata : ${mainData}");
//
//         await _retrieveCalendars(currentDate);
//
//         for (int i = 0; i < _calendarEvents.length; i++) {
//           DateTime dt =
//               new DateTime(_calendarEvents[i].start.year, _calendarEvents[i].start.month, _calendarEvents[i].start.day);
//           if (!mainList.containsKey(dt)) {
//             var json = {
//               "date": "${Constants_data.dateToString(dt, "dd-MM-yyyy")}",
//               "route_code": "586bcfff-d1f3-43ad-aea2-9d3c62be68df",
//               "route_desc": "Banglore to Mysore",
//               "work_type_desc": "Field Work",
//               "work_type_code": "W102",
//               "wt_short_desc": "FW",
//               "is_deviated": "N",
//               "deviation_type": "",
//               "is_deviation_approved": "N",
//               "showInCalendar": "Y",
//               "showInDeviation": "Y",
//               "data": [
//                 {
//                   "prof_name": "${_calendarEvents[i].title}",
//                   "time": "00:00:00",
//                   "CallID": "",
//                   "Status": "",
//                   "Type": "",
//                   "RepName": "",
//                   "StatusColour": "",
//                   "Address": "${_calendarEvents[i].description == "" ? "N/A" : _calendarEvents[i].description}",
//                   "Latitude": "",
//                   "Longitude": "",
//                   "isHoliday": ""
//                 }
//               ]
//             };
//             mainList[dt] = json;
//           }
//
//           listData = [];
//           List<dynamic> keys = mainList.keys.toList()..sort();
//           for (int i = 0; i < keys.length; i++) {
//             listData.add(mainList[keys[i]]);
//           }
//
//           for (int i = 0; i < listData.length; i++) {
//             for (int j = 0; j < _calendarEvents.length; j++) {
//               if (Constants_data.dateToString(_calendarEvents[j].start, "dd-MM-yyyy") == listData[i]["date"]) {
//                 List<dynamic> data = listData[i]["data"];
//                 var json = {
//                   "prof_name": "",
//                   "time": "00:00:00",
//                   "CallID": "",
//                   "Status": "",
//                   "Type": "",
//                   "RepName": "",
//                   "StatusColour": "",
//                   "Address": "",
//                   "Latitude": "",
//                   "Longitude": "",
//                   "isHoliday": ""
//                 };
//                 json["prof_name"] = _calendarEvents[j].title;
//                 json["Address"] = _calendarEvents[j].description == "" ? "N/A" : _calendarEvents[j].description;
//                 bool isSingle = true;
//                 for (int i = 0; i < data.length; i++) {
//                   if (data[i]["prof_name"] == json["prof_name"]) {
//                     isSingle = false;
//                     break;
//                   }
//                 }
//                 if (isSingle) {
//                   data.add(json);
//                 }
//                 listData[i]["data"] = data;
//               }
//             }
//           }
//         }
//       } else {
//         listData = [];
//       }
//     } on Exception catch (err) {
//       listData = [];
//       print("Error in GetSavedMTPData_ForCalendar : $err");
//     }
//   }
//
//   _retrieveCalendars(DateTime date) async {
//     _calendarEvents = [];
//     try {
//       var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
//       if (permissionsGranted.isSuccess && !permissionsGranted.data) {
//         permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
//         if (!permissionsGranted.isSuccess || !permissionsGranted.data) {
//           return;
//         }
//       }
//
//       final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
//
//       _calendars = calendarsResult?.data;
//       if (_calendars.length > 0) {
//         for (int i = 0; i < _calendars.length; i++) {
//           await _retrieveCalendarEvents(_calendars[i], date);
//         }
//       }
//     } on PlatformException catch (e) {
//       print(e);
//     }
//   }
//
//   Future _retrieveCalendarEvents(Calendar _calendar, DateTime date) async {
//     // var currentLocation = timeZoneDatabase.locations[_timezone];
//     // if (currentLocation != null) {
//     //   _startDate = TZDateTime.now(currentLocation);
//     //   _endDate =
//     //       TZDateTime.now(currentLocation).add(const Duration(hours: 1));
//     // } else {
//     //   var fallbackLocation = timeZoneDatabase.locations['Etc/UTC'];
//     //   _startDate = TZDateTime.now(fallbackLocation!);
//     //   _endDate =
//     //       TZDateTime.now(fallbackLocation).add(const Duration(hours: 1));
//     // }
//     final startDate = new DateTime(date.year, 1, 1);
//     final endDate = new DateTime(startDate.year + 1, 12, 1);
//     var calendarEventsResult = await _deviceCalendarPlugin.retrieveEvents(
//         _calendar.id, RetrieveEventsParams(startDate: startDate, endDate: endDate));
//
//     if (calendarEventsResult.data.length > 0) {
//       _calendarEvents.addAll(calendarEventsResult.data);
//     }
//   }
//
//   getColuns() {
//     List<Widget> rows = [];
//     for (int i = 0; i < listData.length; i++) {
//       DateTime dt = new DateFormat("dd-MM-yyyy").parse(listData[i]["date"]);
//       if (dt.weekday != 7) {
//         rows.add(createDateFormate(Constants_data.dateToString(dt, "EEE dd MMM yyyy")));
//         rows.add(createChildList(listData[i]["data"]));
//       }
//     }
//     return rows;
//   }
//
//   createDateFormate(String date) {
//     return new Container(
//       padding: EdgeInsets.all(5),
//       child: new Text(
//         date == null ? "N/A" : date,
//         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//       ),
//     );
//   }
//
//   createChildList(List<dynamic> listItems) {
//     List<Widget> rows = [];
//     for (int i = 0; i < listItems.length; i++) {
//       var time = Constants_data.dateToString(
//           Constants_data.stringToDate("10-10-2020 ${listItems[i]["time"]}", "dd-MM-yyyy HH:mm:ss"), "hh:mm a");
//       rows.add(new Container(
//         margin: EdgeInsets.all(5),
//         child: new Row(
//           children: <Widget>[
//             new Expanded(
//               flex: 2,
//               child: new Container(
//                   height: Constants_data.getHeight(context, 50),
//                   child: new Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       new Container(
//                         child: new Text(
//                           "${listItems[i]["isHoliday"] != null ? "All day" : time ?? "N/A"}",
//                           style: TextStyle(fontSize: Constants_data.getFontSize(context, 13)),
//                         ),
//                       )
//                     ],
//                   )),
//             ),
//             new Container(
//               height: Constants_data.getHeight(context, 40),
//               width: 2,
//               color: AppColors.main_color,
//             ),
//             new Expanded(
//               flex: 7,
//               child: new Container(
//                   padding: EdgeInsets.only(left: 12),
//                   child: new Column(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       new Container(
//                         child: new Text(
//                             listItems[i]["prof_name"] == "" || listItems[i]["prof_name"] == null
//                                 ? "NO NAME"
//                                 : listItems[i]["prof_name"],
//                             style: TextStyle(
//                               color:
//                                   listItems[i]["isHoliday"] == null ? AppColors.main_color : Theme.of(context).primaryColorLight,
//                               fontSize: Constants_data.getFontSize(context, 15),
//                             ),
//                             maxLines: 1),
//                       ),
//                       new Container(
//                         margin: EdgeInsets.only(top: 3),
//                         child: new Text(
//                           listItems[i]["Address"] == null || listItems[i]["Address"] == "null"
//                               ? "N/A"
//                               : listItems[i]["Address"],
//                           style: TextStyle(color: AppColors.grey_color, fontSize: Constants_data.getFontSize(context, 13)),
//                           maxLines: 3,
//                         ),
//                       )
//                     ],
//                   )),
//             ),
//           ],
//         ),
//       ));
//     }
//     return new Container(
//       margin: EdgeInsets.all(5),
//       child: new Column(
//         children: rows,
//       ),
//     );
//   }
// }
