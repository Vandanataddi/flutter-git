// import 'dart:collection';
// import 'dart:convert';
//
// import 'package:device_calendar/device_calendar.dart';
// import 'package:expandable/expandable.dart';
// import 'package:flexi_profiler/Constants/AppColors.dart';
// import 'package:flexi_profiler/Constants/Constants_data.dart';
// import 'package:flexi_profiler/Constants/StateManager.dart';
// import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
// import 'package:flexi_profiler/DBClasses/DBProfessionalList.dart';
// import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
// import 'package:flexi_profiler/Theme/StyleClass.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:table_calendar/table_calendar.dart';
//
// final Map<DateTime, List> _holidays = {};
//
// class CalendarScreen extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<CalendarScreen> with TickerProviderStateMixin {
//   Map<DateTime, List> _events;
//   Map<DateTime, List> _reminders;
//   Map<DateTime, dynamic> _deviation = new HashMap();
//   List _selectedEvents;
//   List _selectedReminder;
//   DateTime _selectedDateTime = DateTime(2020, 05, 01);
//   AnimationController _animationController;
//   CalendarController _calendarController;
//
//   ApiBaseHelper _helper = ApiBaseHelper();
//
// //  final currentDate = DateTime.now();
//   final currentDate = DateTime(DateTime.now().year, DateTime.now().month, 01);
//
//   // final currentDate = DateTime(2021, 5, 01);
//
//   int deviationStatus = 0; // 0: not deviate, 1: approved, 2: not approved
//
//   var selectedRoute;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _calendarController = CalendarController();
//
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//
//     _animationController.forward();
//
//     getSampleDetails();
//   }
//
//   getCalendarEvents() async {
//     DeviceCalendarPlugin _deviceCalendarPlugin;
//
//     _deviceCalendarPlugin = new DeviceCalendarPlugin();
//     _retrieveCalendars(_deviceCalendarPlugin);
//   }
//
//   void _retrieveCalendars(
//     _deviceCalendarPlugin,
//   ) async {
//     List<Calendar> _calendars;
//     Calendar _selectedCalendar;
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
//       _calendars = calendarsResult?.data;
//       print("calender result :  ${_calendars.length}");
//       for (int i = 0; i < _calendars.length; i++) {
//         _selectedCalendar = _calendars[i];
//         print("calender $i :${_selectedCalendar.toJson()}");
//       }
//     } catch (e) {
//       print("calender Error $e");
//     }
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     _calendarController.dispose();
//     super.dispose();
//   }
//
//   void _onDaySelected(DateTime day, List events) {
//     print('CALLBACK: _onDaySelected');
//     setState(() {
//       _selectedEvents = events;
//       _selectedReminder =
//           _reminders[Constants_data.stringToDate(Constants_data.dateToString(day, "dd-MM-yyyy"), "dd-MM-yyyy")];
//       _selectedDateTime = day;
//       // DateFormat("dd-MM-yyyy").parse(listData[i]["date"]
//       // print("Date: ${ Constants_data.dateToString(day, "dd-MM-yyyy")}");
//
//       DateTime dt = Constants_data.stringToDate(Constants_data.dateToString(day, "dd-MM-yyyy"), "dd-MM-yyyy");
//       if (_deviation != null && _deviation.containsKey(dt)) {
//         print("Found deviation : ${_deviation[dt]}");
//         var deviationData = _deviation[dt];
//         if (deviationData["is_deviation_approved"] == "Y") {
//           deviationStatus = 1;
//         } else {
//           deviationStatus = 2;
//         }
//       } else {
//         deviationStatus = 0;
//       }
//
//       if (routeMap != null && routeMap.containsKey(Constants_data.dateToString(_selectedDateTime, "dd-MM-yyyy"))) {
//         selectedRoute = routeMap[Constants_data.dateToString(_selectedDateTime, "dd-MM-yyyy")];
//       }
//     });
//   }
//
//   void _onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) {
//     print('CALLBACK: _onVisibleDaysChanged');
//   }
//
//   bool isCalled = false;
//
//   bool check_calendar_call = false;
//
//   DarkThemeProvider themeChange;
//   ThemeData themeData;
//
//   @override
//   Widget build(BuildContext context) {
//     Constants_data.currentScreenContext = context;
//     themeChange = Provider.of<DarkThemeProvider>(context);
//     themeData = Theme.of(context);
//     getCalendarEvents();
//     return check_calendar_call
//         ? Column(
//             mainAxisSize: MainAxisSize.max,
//             children: <Widget>[
//               new Container(
//                 color: themeChange.darkTheme ? themeData.cardColor : AppColors.main_color,
//                 child: _buildTableCalendarWithBuilders(_selectedDateTime.day),
//               ),
//               new Container(
//                 child: getExpandableView(),
//               ),
//               const SizedBox(height: 8.0),
//               const SizedBox(height: 8.0),
//               Expanded(child: _buildEventList()),
//               Container(child: getExpandableReminderList(_selectedReminder)),
//               deviationStatus != null && deviationStatus != 0
//                   ? Container(
//                       padding: EdgeInsets.all(5),
//                       margin: EdgeInsets.all(5),
//                       alignment: Alignment.center,
//                       width: MediaQuery.of(context).size.width,
//                       color: themeData.primaryColorLight,
//                       child: Text(
//                         deviationStatus == 1
//                             ? "Note: Deviation approved for this date."
//                             : "Note: Deviation submitted but not approved yet",
//                         style: TextStyle(color: themeData.primaryColor),
//                       ),
//                     )
//                   : SizedBox()
//             ],
//           )
//         : FutureBuilder<dynamic>(
//             future: getData(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.done) {
//                 if (snapshot.data == null) {
//                   return Center(
//                     child: Text("Data loading Error"),
//                   );
//                 } else {
//                   return Column(
//                     mainAxisSize: MainAxisSize.max,
//                     children: <Widget>[
//                       new Container(
//                         color: AppColors.main_color,
//                         child: _buildTableCalendarWithBuilders(1),
//                       ),
//                       new Container(
//                         child: getExpandableView(),
//                       ),
//                       const SizedBox(height: 8.0),
//                       const SizedBox(height: 8.0),
//                       Expanded(child: _buildEventList()),
//                       Container(child: getExpandableReminderList(_selectedReminder)),
//                       deviationStatus != null && deviationStatus != 0
//                           ? Container(
//                               padding: EdgeInsets.all(5),
//                               margin: EdgeInsets.all(5),
//                               alignment: Alignment.center,
//                               width: MediaQuery.of(context).size.width,
//                               color: AppColors.black_color,
//                               child: Text(
//                                 deviationStatus == 1
//                                     ? "Note: Deviation approved for this date."
//                                     : "Note: Deviation submitted but not approved yet",
//                                 style: TextStyle(color: AppColors.white_color),
//                               ),
//                             )
//                           : SizedBox()
//                     ],
//                   );
//                 }
//               } else {
//                 return Center(child: CircularProgressIndicator());
//               }
//             },
//           );
//   }
//
//   Future<dynamic> getData() async {
//     String month = currentDate.month < 10 ? "0${currentDate.month}" : "${currentDate.month}";
//     String date = "${month}-${currentDate.year}";
//     print("Months : ${date}");
//     _deviation = new HashMap();
//     var dataUser;
//     if (Constants_data.app_user == null) {
//       dataUser = await StateManager.getLoginUser();
//     } else {
//       dataUser = Constants_data.app_user;
//     }
//
//     try {
//       String eventUrl = '/GetSavedEventData_ForCalendar?RepId=${dataUser["RepId"]}&monthYear=${date}';
//       dynamic reminderData = await _helper.get(eventUrl);
//       // dynamic reminderData = Constants_data.ReminderData;
//       print("GetSavedEventData_ForCalendar : ${jsonEncode(reminderData)}");
//
//       if (reminderData["Status"].toString() == "1") {
//         List<dynamic> dt_ReturnedTables = reminderData["dt_ReturnedTables"];
//         List<dynamic> listData = dt_ReturnedTables[0];
//
//         Map<DateTime, List> mData = new HashMap();
//         for (int i = 0; i < listData.length; i++) {
//           DateTime dt = new DateFormat("dd-MM-yyyy").parse(listData[i]["date"]);
//           List<dynamic> data = listData[i]["data"];
//           for (int j = 0; j < data.length; j++) {
//             String query = "SELECT * from ProfessionalList WHERE CustomerId=? AND accountType=?";
//             List<dynamic> listSearch = await DBProfessionalList.prformQueryOperation(
//                 query, [data[j]["AccountId"].toString().trim(), data[j]["AccountType"].toString().trim()]);
//             print("IsFound any result from localDB : ${listSearch.length}");
//             String name;
//             if (listSearch.length > 0) {
//               name = listSearch[0]["CustomerName"];
//             } else {
//               name = "N/A";
//             }
//             data[j]["name"] = name;
//           }
//           mData[dt] = data;
//           print("Date $i : $dt");
//         }
//         _reminders = mData;
//       } else {
//         print("Status 2 got in the Calling response GetSavedEventData_ForCalendar");
//         isCalled = true;
//         check_calendar_call = true;
//       }
//     } catch (e) {
//       print("Error in GetSavedEventData_ForCalendar : ${e}");
//       return null;
//     }
//
//     try {
//       String url = '/GetSavedMTPData_ForCalendar?RepId=${dataUser["Rep_Id"]}&monthYear=${date}';
//       var mainData = await _helper.get(url);
//       var data = jsonEncode(mainData);
//       print("GetSavedMTPData_ForCalendar : ${data}");
//       await getRouteData(date);
//       if (mainData["Status"].toString() == "1") {
//         final _selectedDay = DateTime.now();
//         List<dynamic> dt_ReturnedTables = mainData["dt_ReturnedTables"];
//         List<dynamic> listData = dt_ReturnedTables[0];
//
//         Map<DateTime, List> mData = new HashMap();
//         for (int i = 0; i < listData.length; i++) {
//           if (listData[i]["showInCalendar"] == "Y") {
//             var dt = new DateFormat("dd-MM-yyyy").parse(listData[i]["date"]);
//             mData[dt] = listData[i]["data"];
//             if (listData[i]["is_deviated"] == "Y") {
//               _deviation[dt] = listData[i];
//             }
//           }
//         }
//         _events = mData;
//         _selectedEvents = _events[_selectedDay] ?? [];
//         isCalled = true;
//         // Constants_data.mainData_calendar = mainData;
//         check_calendar_call = true;
//         _onDaySelected(currentDate, _events[currentDate]);
//       } else {
//         print("Status 2 got in the Calling response GetSavedMTPData_ForCalendar");
//         isCalled = true;
//         check_calendar_call = true;
//         _onDaySelected(currentDate, []);
//       }
//
//       return mainData;
//     } on Exception catch (err) {
//       print("Error in GetSavedMTPData_ForCalendar : ${err}");
//       return null;
//     }
//   }
//
//   Map<String, dynamic> routeMap;
//
//   getRouteData(date) async {
//     var dataUser;
//     if (Constants_data.app_user == null) {
//       dataUser = await StateManager.getLoginUser();
//     } else {
//       dataUser = Constants_data.app_user;
//     }
//     try {
//       String routeUrl = '/GetDataForMTP?RepId=${dataUser["Rep_Id"]}&monthYear=${date}&UserId=${dataUser["Rep_Id"]}';
//       dynamic routeData = await _helper.get(routeUrl);
//
//       List<dynamic> dt_ReturnedTablesRoute = routeData["dt_ReturnedTables"];
//       List<dynamic> listRouteData = dt_ReturnedTablesRoute[0];
//
//       routeMap = new HashMap();
//       for (int i = 0; i < listRouteData.length; i++) {
//         routeMap[listRouteData[i]["date"]] = listRouteData[i];
//       }
//       print("Response Route : ${routeMap}");
//     } on Exception catch (err) {
//       print("Error in load data GetDataForMTP : $err");
//     }
//   }
//
//   Widget _buildTableCalendarWithBuilders(int day) {
//     return TableCalendar(
//       locale: 'en_US',
//       startDay: DateTime(currentDate.year, currentDate.month, 1),
//       endDay: DateTime(currentDate.year, currentDate.month + 1, 0),
//       calendarController: _calendarController,
//       events: _events,
//       initialSelectedDay: DateTime(currentDate.year, currentDate.month, day),
//       holidays: _holidays,
//       weekendDays: [DateTime.sunday],
//       initialCalendarFormat: CalendarFormat.week,
//       formatAnimation: FormatAnimation.slide,
//       startingDayOfWeek: StartingDayOfWeek.sunday,
//       availableGestures: AvailableGestures.all,
//       calendarStyle: CalendarStyle(
//         outsideDaysVisible: false,
//         weekendStyle: TextStyle().copyWith(color: AppColors.light_main_color1),
//         holidayStyle: TextStyle().copyWith(color: AppColors.light_main_color1),
//       ),
//       daysOfWeekStyle: DaysOfWeekStyle(
//         //weekendStyle: TextStyle().copyWith(color: AppColors.red_color),
//         weekdayStyle: TextStyle().copyWith(color: AppColors.white_color),
//       ),
//       headerStyle: HeaderStyle(
//           centerHeaderTitle: true,
//           formatButtonVisible: false,
//           titleTextStyle: TextStyle().copyWith(color: AppColors.white_color),
//           leftChevronIcon: Icon(
//             Icons.chevron_left,
//             color: AppColors.white_color,
//           ),
//           rightChevronIcon: Icon(
//             Icons.chevron_right,
//             color: AppColors.white_color,
//           )),
//       builders: CalendarBuilders(
//         holidayDayBuilder: (context, date, _) {
//           return FadeTransition(
//             opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
//             child: Container(
//               margin: const EdgeInsets.all(4.0),
//               padding: const EdgeInsets.only(top: 5.0, left: 6.0),
//               width: 75,
//               height: 75,
//               child: new Column(
//                 children: <Widget>[
//                   Text(
//                     '${date.day}',
//                     style: TextStyle().copyWith(fontSize: 16.0),
//                   ),
//                   Text(
//                     _holidays[new DateTime(date.year, date.month, date.day)][0].toString() == "Leave"
//                         ? "Leave"
//                         : "Holiday",
//                     style: TextStyle().copyWith(fontSize: 8.0),
//                   )
//                 ],
//               ),
//             ),
//           );
//         },
//         dayBuilder: (context, date, _) {
//           return FadeTransition(
//             opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
//             child: Container(
//               margin: const EdgeInsets.all(4.0),
//               width: 75,
//               height: 80,
//               child: new Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   Text(
//                     '${date.day}',
//                     style: TextStyle().copyWith(fontSize: 16.0, color: AppColors.white_color),
//                   ),
//                   date.weekday == 7
//                       ? Text(
//                           'Sunday',
//                           style: TextStyle().copyWith(fontSize: 8.0, color: AppColors.red_color),
//                         )
//                       : Container(),
//                 ],
//               ),
//             ),
//           );
//         },
//         selectedDayBuilder: (context, date, _) {
//           return FadeTransition(
//             opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
//             child: Container(
//               decoration: BoxDecoration(
//                   color: AppColors.white_color,
//                   borderRadius: new BorderRadius.all(
//                     const Radius.circular(20.0),
//                   )),
//               margin: const EdgeInsets.all(10.0),
//               width: 30,
//               height: 30,
//               child: new Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   Text(
//                     '${date.day}',
//                     style: TextStyle().copyWith(fontSize: 16.0, color: AppColors.red_color),
//                   ),
//                   getDayName(date),
//                 ],
//               ),
//             ),
//           );
//         },
//         todayDayBuilder: (context, date, _) {
//           return FadeTransition(
//             opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
//             child: Container(
//               margin: const EdgeInsets.all(4.0),
//               width: 75,
//               height: 80,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   Text(
//                     '${date.day}',
//                     style:
//                         TextStyle().copyWith(fontSize: 16.0, color: AppColors.white_color, fontWeight: FontWeight.bold),
//                   ),
//                   Text(
//                     'Today',
//                     style: TextStyle().copyWith(fontSize: 10.0, color: AppColors.white_color),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//         unavailableDayBuilder: (context, date, _) {
//           return FadeTransition(
//             opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
//             child: Container(
//               margin: const EdgeInsets.all(10.0),
//               width: 30,
//               height: 30,
//               child: new Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   Text(
//                     '${date.day}',
//                     style: TextStyle().copyWith(fontSize: 16.0, color: AppColors.light_main_color2),
//                   ),
//                   getDayName(date),
//                 ],
//               ),
//             ),
//           );
//         },
//         markersBuilder: (context, date, events, holidays) {
//           final children = <Widget>[];
//           return children;
//         },
//       ),
//       onDaySelected: (date, events, dynamic t) {
//         _onDaySelected(date, events);
//         _animationController.forward(from: 0.0);
//       },
//       onVisibleDaysChanged: _onVisibleDaysChanged,
//     );
//   }
//
//   getDayName(DateTime date) {
//     if (_holidays.containsKey(new DateTime(date.year, date.month, date.day))) {
//       return Text(
//         _holidays[new DateTime(date.year, date.month, date.day)][0].toString() == "Leave" ? "Leave" : "Holiday",
//         style: TextStyle().copyWith(fontSize: 8.0),
//       );
//     } else if (date.weekday == 7) {
//       return Text(
//         "Sunday",
//         style: TextStyle().copyWith(fontSize: 8.0),
//       );
//     } else {
//       return new Container();
//     }
//   }
//
//   Widget _buildEventList() {
//     if (selectedRoute == null || selectedRoute["day"] == "Sunday") {
//       return new Center(
//         child: new Text("Data not available !"),
//       );
//     } else {
//       print("Selected Date Data length : ${_selectedEvents.length}");
//       if (_selectedEvents.length > 0) {
//         return ListView(
//           children: getChildrens(),
//         );
//       } else {
//         return Container(
//           alignment: Alignment.center,
//           child: Text("MTP details not found for selected date"),
//         );
//       }
//     }
//   }
//
//   getChildrens() {
//     List<Widget> listWid = [];
//     for (int i = 0; i < _selectedEvents.length; i++) {
//       listWid.add(Container(
//           margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//           child: new GestureDetector(
//               onTap: () {
//                 print("Selected Event : ${_selectedEvents}");
//                 showDetailsDialog(_selectedEvents[i]);
//               },
//               child: new Container(
//                 height: 35,
//                 child: new Row(
//                   children: <Widget>[
//                     new Expanded(
//                       child: new Container(
//                         decoration: BoxDecoration(
//                           border: Border.all(
//                             width: 0.8,
//                             color: themeData.primaryColorLight,
//                           ),
//                           borderRadius: BorderRadius.only(
//                             topRight: const Radius.circular(10.0),
//                             bottomRight: const Radius.circular(10.0),
//                           ),
//                         ),
//                         child: new Align(alignment: Alignment.center, child: Text((i + 1).toString())),
//                         margin: EdgeInsets.only(top: 5, bottom: 5),
//                       ),
//                       flex: 1,
//                     ),
//                     new Expanded(
//                       child: new Container(
//                         margin: EdgeInsets.only(left: 10),
//                         child: Text(
//                           _selectedEvents[i]["prof_name"].toString(),
//                           style: TextStyle(color: AppColors.main_color, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       flex: 9,
//                     ),
//                   ],
//                 ),
//               ))));
//     }
//     return listWid;
//   }
//
//   static double popup_spacing = 15.0;
//
//   showDetailsDialog(var selectedEvent) {
//     print("Selected Event: ${selectedEvent} ");
//     showGeneralDialog(
//       context: context,
//       barrierColor: Colors.black12.withOpacity(0.01),
//       // background color
//       barrierDismissible: false,
//       // should dialog be dismissed when tapped outside
//       barrierLabel: "Dialog",
//       // label for barrier
//       transitionDuration: Duration(milliseconds: 400),
//       // how long it takes to popup dialog after button click
//       pageBuilder: (_, __, ___) {
//         // your widget implementation
//         return Material(
//             color: Colors.black12.withOpacity(0.5),
//             child: SizedBox.expand(
//                 // makes widget fullscreen
//                 child: FutureBuilder<dynamic>(
//               future: getCalData(selectedEvent),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done) {
//                   if (snapshot.data != null) {
//                     return Align(
//                         alignment: Alignment.center,
//                         child: new Container(
//                             decoration: new BoxDecoration(
//                                 color: themeData.cardColor,
//                                 borderRadius: new BorderRadius.only(
//                                   topLeft: const Radius.circular(10.0),
//                                   topRight: const Radius.circular(10.0),
//                                   bottomLeft: const Radius.circular(10.0),
//                                   bottomRight: const Radius.circular(10.0),
//                                 )),
//                             height: MediaQuery.of(context).size.height - 150,
//                             width: MediaQuery.of(context).size.width - popup_spacing,
//                             child: new Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: <Widget>[
//                                 new Container(
//                                   decoration: new BoxDecoration(
//                                       color: themeChange.darkTheme ? AppColors.dark_grey_color : AppColors.main_color,
//                                       borderRadius: new BorderRadius.only(
//                                         topLeft: const Radius.circular(10.0),
//                                         topRight: const Radius.circular(10.0),
//                                       )),
//                                   height: 45,
//                                   child: new Stack(
//                                     children: <Widget>[
//                                       Align(
//                                         alignment: Alignment.centerLeft,
//                                         child: new Container(
//                                           padding: EdgeInsets.only(left: 10),
//                                           child: new Text(
//                                             "Professional DCR",
//                                             style: TextStyle(
//                                                 color: AppColors.white_color,
//                                                 fontSize: 15,
//                                                 fontWeight: FontWeight.bold),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 new Container(
//                                   margin: EdgeInsets.all(5),
//                                   child: Align(
//                                     alignment: Alignment.centerRight,
//                                     child: new Text(
//                                       "${data["work_date"]}",
//                                       style: TextStyle(color: AppColors.grey_color),
//                                     ),
//                                   ),
//                                 ),
//                                 new Container(
//                                     margin: EdgeInsets.only(left: 10, top: 5, bottom: 5),
//                                     child: new Text(
//                                       "${selectedEvent["prof_name"]}",
//                                       style: TextStyle(
//                                           color: AppColors.main_color, fontWeight: FontWeight.bold, fontSize: 15),
//                                     )),
//                                 new Container(
//                                     margin: EdgeInsets.only(left: 10, bottom: 5, top: 5),
//                                     child: new Text(
//                                       doctorPhone,
//                                       style: TextStyle(color: themeData.primaryColorLight, fontSize: 15),
//                                     )),
//                                 new Container(
//                                     margin: EdgeInsets.only(left: 10, bottom: 5, top: 5),
//                                     child: new Text(
//                                       doctorAddress,
//                                       style: TextStyle(fontSize: 15),
//                                     )),
//                                 new Container(
//                                     margin: EdgeInsets.only(left: 10, bottom: 5, top: 5),
//                                     child: new Text(
//                                       "Last Visit: ${data["last_visit"]}",
//                                       style: TextStyle(fontSize: 15),
//                                     )),
//                                 new Container(
//                                     margin: EdgeInsets.all(10),
//                                     height: 50,
//                                     child: new Row(
//                                       children: <Widget>[
//                                         new Expanded(
//                                             flex: 1,
//                                             child: new Container(
//                                               margin: EdgeInsets.all(5),
//                                               child: new Column(
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: <Widget>[
//                                                   new Text(
//                                                     "Work With",
//                                                     style: TextStyle(color: AppColors.main_color, fontSize: 15),
//                                                   ),
//                                                   new Text(
//                                                     data["work_with"] == "" ? "N/A" : data["work_with"],
//                                                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//                                                   ),
//                                                 ],
//                                               ),
//                                             )),
//                                         new Expanded(
//                                             flex: 1,
//                                             child: new Container(
//                                                 margin: EdgeInsets.all(5),
//                                                 child: new Column(
//                                                   mainAxisAlignment: MainAxisAlignment.center,
//                                                   children: <Widget>[
//                                                     new Text(
//                                                       "Work Type",
//                                                       style: TextStyle(color: AppColors.main_color, fontSize: 15),
//                                                     ),
//                                                     new Text(
// //                                                      data["work_type"],
//                                                       "Field Work",
//                                                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//                                                     ),
//                                                   ],
//                                                 ))),
//                                       ],
//                                     )),
//                                 new Expanded(
//                                   child: new SingleChildScrollView(
//                                     child: new Column(
//                                       children: <Widget>[
//                                         brand.length > 0
//                                             ? new Container(
//                                                 margin: EdgeInsets.only(top: 15, right: 10, left: 10, bottom: 10),
//                                                 child: new Row(
//                                                   children: <Widget>[
//                                                     new Container(
//                                                       child: new Row(
//                                                         children: <Widget>[
//                                                           new Text(
//                                                             "Product Group Details: ",
//                                                             style: TextStyle(
//                                                                 color: AppColors.main_color,
//                                                                 fontSize: 15,
//                                                                 fontStyle: FontStyle.normal,
//                                                                 fontWeight: FontWeight.bold),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ))
//                                             : new Container(),
//                                         brand.length > 0
//                                             ? new Container(
//                                                 margin: EdgeInsets.only(top: 0, right: 10, left: 10, bottom: 10),
//                                                 child: Table(
//                                                     border: new TableBorder(
//                                                         right:
//                                                             BorderSide(color: AppColors.light_grey_color, width: 0.5),
//                                                         left: BorderSide(color: AppColors.light_grey_color, width: 0.5),
//                                                         bottom:
//                                                             BorderSide(color: AppColors.light_grey_color, width: 0.5),
//                                                         horizontalInside:
//                                                             BorderSide(color: AppColors.light_grey_color, width: 0.5),
//                                                         verticalInside:
//                                                             BorderSide(color: AppColors.light_grey_color, width: 0.5)),
//                                                     columnWidths: {
//                                                       0: FixedColumnWidth(150),
//                                                     },
//                                                     children: getProductDetails()))
//                                             : new Container(),
//                                         sampleDetails.length > 0
//                                             ? new Container(
//                                                 margin: EdgeInsets.only(top: 15, right: 10, left: 10, bottom: 10),
//                                                 child: new Row(
//                                                   children: <Widget>[
//                                                     new Container(
//                                                       child: new Row(
//                                                         children: <Widget>[
//                                                           new Text(
//                                                             "Sample Details: ",
//                                                             style: TextStyle(
//                                                                 color: AppColors.main_color,
//                                                                 fontSize: 15,
//                                                                 fontStyle: FontStyle.normal,
//                                                                 fontWeight: FontWeight.bold),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ))
//                                             : new Container(),
//                                         sampleDetails.length > 0
//                                             ? new Container(
//                                                 margin: EdgeInsets.only(top: 0, right: 10, left: 10, bottom: 10),
//                                                 child: Table(
//                                                     border: new TableBorder(
//                                                         right:
//                                                             BorderSide(color: AppColors.light_grey_color, width: 0.5),
//                                                         left: BorderSide(color: AppColors.light_grey_color, width: 0.5),
//                                                         bottom:
//                                                             BorderSide(color: AppColors.light_grey_color, width: 0.5),
//                                                         horizontalInside:
//                                                             BorderSide(color: AppColors.light_grey_color, width: 0.5),
//                                                         verticalInside:
//                                                             BorderSide(color: AppColors.light_grey_color, width: 0.5)),
//                                                     columnWidths: {
//                                                       1: FixedColumnWidth(80),
//                                                     },
//                                                     children: getItemDetails(sampleDetails)))
//                                             : new Container(),
//                                         promotionalItem.length > 0
//                                             ? new Container(
//                                                 margin: EdgeInsets.only(top: 15, right: 10, left: 10, bottom: 10),
//                                                 child: new Row(
//                                                   children: <Widget>[
//                                                     new Container(
//                                                       child: new Row(
//                                                         children: <Widget>[
//                                                           new Text(
//                                                             "Promotional Items: ",
//                                                             style: TextStyle(
//                                                                 color: AppColors.main_color,
//                                                                 fontSize: 15,
//                                                                 fontStyle: FontStyle.normal,
//                                                                 fontWeight: FontWeight.bold),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ))
//                                             : new Container(),
//                                         promotionalItem.length > 0
//                                             ? new Container(
//                                                 margin: EdgeInsets.only(top: 0, right: 10, left: 10, bottom: 10),
//                                                 child: Table(
//                                                     border: new TableBorder(
//                                                         right:
//                                                             BorderSide(color: AppColors.light_grey_color, width: 0.5),
//                                                         left: BorderSide(color: AppColors.light_grey_color, width: 0.5),
//                                                         bottom:
//                                                             BorderSide(color: AppColors.light_grey_color, width: 0.5),
//                                                         horizontalInside:
//                                                             BorderSide(color: AppColors.light_grey_color, width: 0.5),
//                                                         verticalInside:
//                                                             BorderSide(color: AppColors.light_grey_color, width: 0.5)),
//                                                     columnWidths: {
//                                                       1: FixedColumnWidth(80),
//                                                     },
//                                                     children: getItemDetails(promotionalItem)))
//                                             : new Container(),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 new Container(
//                                   margin: EdgeInsets.only(right: 20),
//                                   height: 50,
//                                   child: new Row(
//                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     children: <Widget>[
//                                       new GestureDetector(
//                                         onTap: () {
//                                           Navigator.pop(context);
//                                         },
//                                         child: new Container(
//                                           margin: EdgeInsets.only(right: 10),
//                                           height: 30,
//                                           child: new Text(
//                                             "CLOSE",
//                                             style: TextStyle(color: AppColors.red_color, fontWeight: FontWeight.bold),
//                                           ),
//                                         ),
//                                       ),
//                                       new GestureDetector(
//                                         onTap: () {
//                                           Map<String, dynamic> args = new HashMap();
//                                           args["date"] = Constants_data.dateToString(_selectedDateTime, "yyyy-MM-dd");
//                                           args["doctor"] = selectedEvent;
//
//                                           Navigator.pushNamed(context, "/DCR_Entry", arguments: args);
//                                         },
//                                         child: new Container(
//                                           height: 30,
//                                           child: new Text(
//                                             "DCR ENTRY",
//                                             style: TextStyle(fontWeight: FontWeight.bold),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               ],
//                             )));
//                   } else {
//                     return Align(
//                         alignment: Alignment.center,
//                         child: new Container(
//                             decoration: new BoxDecoration(
//                                 color: AppColors.white_color,
//                                 borderRadius: new BorderRadius.only(
//                                   topLeft: const Radius.circular(10.0),
//                                   topRight: const Radius.circular(10.0),
//                                   bottomLeft: const Radius.circular(10.0),
//                                   bottomRight: const Radius.circular(10.0),
//                                 )),
//                             width: MediaQuery.of(context).size.width - popup_spacing,
//                             height: 250,
//                             child: new Stack(
//                               children: <Widget>[
//                                 new Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
//                                   new Container(
//                                     decoration: new BoxDecoration(
//                                         color: AppColors.main_color,
//                                         borderRadius: new BorderRadius.only(
//                                           topLeft: const Radius.circular(10.0),
//                                           topRight: const Radius.circular(10.0),
//                                         )),
//                                     height: 45,
//                                     child: new Stack(
//                                       children: <Widget>[
//                                         Align(
//                                           alignment: Alignment.centerLeft,
//                                           child: new Container(
//                                             padding: EdgeInsets.only(left: 10),
//                                             child: new Text(
//                                               "Professional DCR",
//                                               style: TextStyle(
//                                                   color: AppColors.white_color,
//                                                   fontSize: 15,
//                                                   fontWeight: FontWeight.bold),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   new Container(
//                                     margin: EdgeInsets.all(5),
//                                     child: Align(
//                                       alignment: Alignment.centerRight,
//                                       child: new Text(
//                                         Constants_data.dateToString(_selectedDateTime, "MM/dd/yyyy HH:mm:ss aa"),
//                                         style: TextStyle(color: AppColors.grey_color),
//                                       ),
//                                     ),
//                                   ),
//                                   new Container(
//                                       margin: EdgeInsets.only(left: 10, top: 5, bottom: 5),
//                                       child: new Text(
//                                         "${selectedEvent["prof_name"]}",
//                                         style: TextStyle(
//                                             color: AppColors.main_color, fontWeight: FontWeight.bold, fontSize: 15),
//                                       )),
//                                   new Container(
//                                       margin: EdgeInsets.only(left: 10, bottom: 5, top: 5),
//                                       child: new Text(
//                                         doctorPhone,
//                                         style: TextStyle(color: Colors.green, fontSize: 15),
//                                       )),
//                                   new Container(
//                                       margin: EdgeInsets.only(left: 10, bottom: 5, top: 5),
//                                       child: new Text(
//                                         doctorAddress,
//                                         style: TextStyle(color: AppColors.black_color, fontSize: 15),
//                                       )),
//                                   new Container(
//                                       margin: EdgeInsets.only(left: 10, bottom: 5, top: 5),
//                                       child: new Text(
//                                         "Last Visit : N/A",
//                                         style: TextStyle(color: AppColors.black_color, fontSize: 15),
//                                       )),
//                                 ]),
//                                 new Align(
//                                   alignment: Alignment.bottomCenter,
//                                   child: new Container(
//                                     margin: EdgeInsets.only(right: 20),
//                                     height: 50,
//                                     child: new Row(
//                                       crossAxisAlignment: CrossAxisAlignment.end,
//                                       mainAxisAlignment: MainAxisAlignment.end,
//                                       children: <Widget>[
//                                         new GestureDetector(
//                                           onTap: () {
//                                             Navigator.pop(context);
//                                           },
//                                           child: new Container(
//                                             margin: EdgeInsets.only(right: 10),
//                                             height: 30,
//                                             child: new Text(
//                                               "CLOSE",
//                                               style: TextStyle(color: AppColors.red_color, fontWeight: FontWeight.bold),
//                                             ),
//                                           ),
//                                         ),
//                                         new GestureDetector(
//                                           onTap: () {
//                                             Map<String, dynamic> args = new HashMap();
//                                             args["date"] = Constants_data.dateToString(_selectedDateTime, "yyyy-MM-dd");
//                                             args["doctor"] = selectedEvent;
//                                             Navigator.pushNamed(context, "/DCR_Entry", arguments: args);
//                                           },
//                                           child: new Container(
//                                             height: 30,
//                                             child: new Text(
//                                               "DCR ENTRY",
//                                               style:
//                                                   TextStyle(color: AppColors.black_color, fontWeight: FontWeight.bold),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 )
//                               ],
//                             )));
//                   }
//                 } else {
//                   return Center(child: CircularProgressIndicator());
//                 }
//               },
//             )));
//       },
//     );
//   }
//
//   List<dynamic> brand = [];
//   List<dynamic> sampleDetails = [];
//   List<dynamic> promotionalItem = [];
//   var data;
//   String doctorPhone = "";
//   String doctorAddress = "";
//
//   Future<dynamic> getCalData(var selectedEvent) async {
//     doctorAddress = "";
//     String city = "", state = "";
//     List<dynamic> listAttributes =
//         await DBProfessionalList.getProfessionalFromID(selectedEvent["prof_code"], selectedEvent["account_type"]);
//     for (int i = 0; i < listAttributes.length; i++) {
//       if (listAttributes[i]["AttributeCode"] == "mobile") {
//         doctorPhone = listAttributes[i]["AttributeValue"] != null ? listAttributes[i]["AttributeValue"] : "N/A";
//       } else if (listAttributes[i]["AttributeCode"] == "CITY") {
//         city = (listAttributes[i]["AttributeValue"] != null ? listAttributes[i]["AttributeValue"] : "");
//       } else if (listAttributes[i]["AttributeCode"] == "STATE") {
//         state = (listAttributes[i]["AttributeValue"] != null ? listAttributes[i]["AttributeValue"] : "");
//       }
//     }
//     doctorAddress = city + ", " + state;
//     print("Doctor Data : ${listAttributes}");
//     var dataUser;
//     if (Constants_data.app_user == null) {
//       dataUser = await StateManager.getLoginUser();
//     } else {
//       dataUser = Constants_data.app_user;
//     }
// //      ${dataUser["Rep_Id"]};
//     try {
//       String url = '/GetLastVisitOfProfessionals?RepId=${dataUser["Rep_Id"]}&AccountId=${selectedEvent["prof_code"]}';
//       dynamic mainData = await _helper.get(url);
//       List dt_ReturnedTables = mainData["dt_ReturnedTables"];
//       data = dt_ReturnedTables[0];
//       brand = data["brands"];
//       sampleDetails = [];
//       promotionalItem = [];
//       List<dynamic> items = data["items"];
//       for (int i = 0; i < items.length; i++) {
//         if (items[i]["item_type"] == "S") {
//           sampleDetails.add(items[i]);
//         } else {
//           promotionalItem.add(items[i]);
//         }
//       }
//       return data;
//     } on Exception catch (err) {
//       print("Error in GetLastVisitOfProfessionals : ${err}");
//     }
//     return null;
//   }
//
//   TextStyle normalText = TextStyle(fontSize: 14, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold);
//
//   getProductDetails() {
//     List<TableRow> rows = [];
//     rows.add(new TableRow(children: [
//       new Container(
//           padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),
//           color: themeChange.darkTheme ? AppColors.dark_grey_color : AppColors.grey_color,
//           child: new Text(
//             "Product Name",
//             style: normalText,
//           )),
//       new Container(
//           padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),
//           color: themeChange.darkTheme ? AppColors.dark_grey_color : AppColors.grey_color,
//           child: new Text(
//             "Remarks",
//             style: normalText,
//           )),
//     ]));
//
//     for (int i = 0; i < brand.length; i++) {
//       rows.add(TableRow(children: [
//         Container(
//           padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),
//           child: Text(
//             getSampleName(brand[i]["product_brand"]),
//             style: normalText,
//           ),
//         ),
//         Container(
//             padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),
//             child: Text(
//               brand[i]["Remark"] == "" ? "N/A" : brand[i]["Remark"],
//               style: normalText,
//             ))
//       ]));
//     }
//     return rows;
//   }
//
//   getItemDetails(List<dynamic> sampleDetails) {
//     List<TableRow> rows = [];
//     rows.add(new TableRow(children: [
//       new Container(
//           padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),
//           color: themeChange.darkTheme ? AppColors.dark_grey_color : AppColors.grey_color,
//           child: new Text(
//             "Product Name",
//             style: normalText,
//           )),
//       new Container(
//           padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),
//           color: themeChange.darkTheme ? AppColors.dark_grey_color : AppColors.grey_color,
//           child: new Text(
//             "Qty",
//             style: normalText,
//           )),
//     ]));
//
//     for (int i = 0; i < sampleDetails.length; i++) {
//       rows.add(new TableRow(children: [
//         new Container(
//           padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),
//           child: new Text(
//             getSampleName(sampleDetails[i]["item_code"]),
//             style: normalText,
//           ),
//         ),
//         new Container(
//             padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),
//             child: new Text(
//               sampleDetails[i]["qty"] == "" ? "N/A" : sampleDetails[i]["qty"],
//               style: normalText,
//             ))
//       ]));
//     }
//     return rows;
//   }
//
//   Map<int, dynamic> mapSample;
//
//   void getSampleDetails() {
//     var mainData = Constants_data.jsonSampleProductDetails;
//     List dt_ReturnedTables = mainData["dt_ReturnedTables"];
//     List<dynamic> listSample = dt_ReturnedTables[0];
//     mapSample = listSample.asMap();
//   }
//
//   getSampleName(String code) {
//     var key = mapSample.keys.firstWhere(
//         (k) => mapSample[k]["product_code"] == code || mapSample[k]["product_brand_code"] == code,
//         orElse: null);
//     if (key != null) {
//       print("Searched Key : ${key}");
//       var data = mapSample[key];
//       String result;
//       if (data["product_category"] == "G") {
//         result = mapSample[key]["product_description"];
//       } else {
//         result = mapSample[key]["product_brand_name"];
//       }
//       return result;
//     } else {
//       return code;
//     }
//   }
//
//   getExpandableRow(String title, String desc) {
//     return new Row(
//       children: <Widget>[
//         new Expanded(
//             flex: 7,
//             child: new Container(
//               padding: EdgeInsets.only(top: 5, bottom: 5, left: 10),
//               child: new Text(title,
//                   style: TextStyle(color: AppColors.main_color, fontSize: 15, fontStyle: FontStyle.normal)),
//             )),
//         new Expanded(
//             flex: 1,
//             child: new Container(
//               child: new Text(" : "),
//             )),
//         new Expanded(
//             flex: 14,
//             child: new Container(
//               child: new Text(desc),
//             ))
//       ],
//     );
//   }
//
//   getExpandableView() {
//     if (selectedRoute == null || selectedRoute["day"] == "Sunday") {
//       return new Container();
//     } else {
//       List<dynamic> patches = selectedRoute["patches"];
//       String patchesStr = "";
//       for (int i = 0; i < patches.length; i++) {
//         patchesStr += patches[i]["patch_desc"] + (i == patches.length - 1 ? "" : ", ");
//       }
//
//       return selectedRoute != null
//           ? ExpandablePanel(
//               // iconColor: Colors.grey,
//               header: new Container(
//                   child: new Row(
//                 children: <Widget>[
//                   new Expanded(
//                       flex: 17,
//                       child: new Container(
//                         padding: EdgeInsets.only(top: 10, bottom: 5, left: 10),
//                         child: new Text("Route Name",
//                             style: TextStyle(
//                                 color: AppColors.main_color,
//                                 fontSize: 15,
//                                 fontStyle: FontStyle.normal,
//                                 fontWeight: FontWeight.bold)),
//                       )),
//                   new Expanded(
//                       flex: 1,
//                       child: Container(
//                         child: Text(" : "),
//                       )),
//                   new Expanded(
//                       flex: 35,
//                       child: new Container(
//                         padding: EdgeInsets.only(top: 10, bottom: 5, left: 10),
//                         child: new Text(selectedRoute["route_desc"]),
//                       ))
//                 ],
//               )),
// //                collapsed: Text("Body", softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
//               expanded: new Container(
//                   margin: EdgeInsets.only(right: 40),
//                   child: new Column(
//                     children: <Widget>[
//                       getExpandableRow("Patch", patchesStr),
//                       getExpandableRow(
//                           "Distance", selectedRoute["distance"] == "" ? " - " : "${selectedRoute["distance"]} km"),
//                       getExpandableRow("Visit", "${selectedRoute["visit_per_month"]} (per month)"),
//                       getExpandableRow("Route way", "${selectedRoute["route_way"]}"),
//                       getExpandableRow("Work Type", "Field Work"),
//                     ],
//                   )), collapsed: Container(),
//             )
//           : new Container();
//     }
//   }
//
//   getExpandableReminderList(events) {
//     if (events != null && events.length > 0) {
//       List<Widget> list = [];
//       for (int i = 0; i < events.length; i++) {
//         list.add(InkWell(
//             onTap: () {
//               openDetailDialogOfReminder(events[i]);
//             },
//             child: Card(
//               color: themeData.primaryColor,
//               elevation: 3,
//               child: ListTile(
//                 title: Text(
//                   "${events[i]["EventTitle"] == "" ? "N/A" : events[i]["EventTitle"]}",
//                   style: Styles.h3.copyWith(color: themeData.accentColor),
//                 ),
//                 subtitle: Text("${events[i]["EventType"]} (${events[i]["name"]})"),
//               ),
//             )));
//       }
//       return ExpansionTile(
//         backgroundColor: themeChange.darkTheme ? themeData.cardColor : Color(0xfff9f4f4),
//         title: Container(
//             alignment: Alignment.centerLeft,
//             child: Text(
//               "Today's Reminders List",
//               style: Styles.h3.copyWith(color: themeData.primaryColorLight),
//             )),
//         children: [
//           Container(
//               height: 200,
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: list,
//                 ),
//               ))
//         ],
//       );
//     } else {
//       return Container();
//     }
//   }
//
//   Future<bool> openDetailDialogOfReminder(data) async {
//     switch (await showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return SimpleDialog(
//             contentPadding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
//             children: <Widget>[
//               Container(
//                 color: AppColors.main_color,
//                 margin: EdgeInsets.all(0.0),
//                 padding: EdgeInsets.only(bottom: 15.0, top: 15.0),
//                 child: Column(
//                   children: <Widget>[
//                     Text(
//                       '${data["EventTitle"] == "" ? "N/A" : data["EventTitle"]}',
//                       style: TextStyle(color: AppColors.white_color, fontSize: 18.0, fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                   width: MediaQuery.of(context).size.width * 0.8,
//                   margin: EdgeInsets.all(10),
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         height: 10,
//                       ),
//                       Container(
//                           alignment: Alignment.centerRight,
//                           child: Text(
//                               "${Constants_data.dateToString(_selectedDateTime, "dd-MM-yyyy")} ${data["EventTime"]}",
//                               style: Styles.h4)),
//                       SizedBox(
//                         height: 15,
//                       ),
//                       Container(
//                         child: Row(
//                           children: [
//                             Text(
//                               "Type : ",
//                               style: Styles.subtitle1,
//                             ),
//                             Text(
//                               "${data["EventType"] == "" ? "N/A" : data["EventType"]}",
//                               style: Styles.h4,
//                             )
//                           ],
//                         ),
//                       ),
//                       SizedBox(
//                         height: 15,
//                       ),
//                       Container(
//                         child: Row(
//                           children: [
//                             Text(
//                               "Name : ",
//                               style: Styles.subtitle1,
//                             ),
//                             Text(
//                               "${data["name"] == "" ? "N/A" : data["name"]}",
//                               style: Styles.h4,
//                             )
//                           ],
//                         ),
//                       ),
//                       SizedBox(
//                         height: 15,
//                       ),
//                       Container(
//                         child: Row(
//                           children: [
//                             Text(
//                               "Description : ",
//                               style: Styles.subtitle1,
//                             ),
//                             Text(
//                               "${data["EventDesc"] == "" ? "N/A" : data["EventDesc"]}",
//                               style: Styles.h4,
//                             )
//                           ],
//                         ),
//                       ),
//                     ],
//                   )),
//               Container(
//                   margin: EdgeInsets.all(10),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       SimpleDialogOption(
//                         onPressed: () {
//                           Navigator.pop(context, 0);
//                         },
//                         child: Text("OK", style: TextStyle(color: AppColors.main_color, fontWeight: FontWeight.bold)),
//                       ),
//                     ],
//                   ))
//             ],
//           );
//         })) {
//       case 0:
//         return true;
//         break;
//       case 1:
//         return false;
//         break;
//     }
//     return false;
//   }
// }
