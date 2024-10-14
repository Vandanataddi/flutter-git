import 'dart:convert';

import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Constants/StateManager.dart';
import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CalendarScreenDefault extends StatefulWidget {
  @override
  _CalendarScreenState createState() => new _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreenDefault> {
  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Constants_data.currentScreenContext = context;
    return FutureBuilder<List<dynamic>>(
      future: getData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SingleChildScrollView(
              child: new Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: getColuns(),
                  )));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  List<dynamic> listData;
  final currentDate = DateTime(2020, 5, 01);
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<Null> getData() async {
    listData = [];

    String month = currentDate.month < 10 ? "0${currentDate.month}" : "${currentDate.month}";
    String date = "${month}-${currentDate.year}";
    print("Months : ${date}");

    var dataUser;
    if (Constants_data.app_user == null) {
      dataUser = await StateManager.getLoginUser();
    } else {
      dataUser = Constants_data.app_user;
    }

    try {
      String url = '/GetSavedMTPData_ForCalendar?RepId=${dataUser["RepId"]}&monthYear=${date}';
      dynamic mainData = await _helper.get(url);
      List<dynamic> dt_ReturnedTables = mainData["dt_ReturnedTables"];
      listData = dt_ReturnedTables[0];
      print("MainData: ${listData}");
      print("ListDataSize: ${listData.length}");
    } on Exception catch (err) {
      print("Error in GetSavedMTPData_ForCalendar : $err");
    }
  }

  getColuns() {
    List<Widget> rows = [];

    for (int i = 0; i < listData.length; i++) {
      DateTime dt = new DateFormat("dd-MM-yyyy").parse(listData[i]["date"]);
      if (dt.weekday != 7) {
        rows.add(createDateFormate(Constants_data.dateToString(dt, "EEE dd MMM yyyy")));
        rows.add(createChildList(listData[i]["data"]));
      }
    }
    return rows;
  }

  createDateFormate(String date) {
    return new Container(
      padding: EdgeInsets.all(5),
      child: new Text(
        date,
        style: TextStyle( fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  createChildList(List<dynamic> listItems) {
    List<Widget> rows = [];
    for (int i = 0; i < listItems.length; i++) {
      print("List Item: ${listItems[i]}");
      rows.add(new Container(
        margin: EdgeInsets.all(5),
        child: new Row(
          children: <Widget>[
            new Expanded(
              flex: 2,
              child: new Container(
                  height: Constants_data.getHeight(context, 50),
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Container(
                        child: new Text(
                          "12:00 am",
                          style: TextStyle( fontSize: Constants_data.getFontSize(context, 13)),
                        ),
                      ),
                    ],
                  )),
            ),
            new Container(
              height: Constants_data.getHeight(context, 40),
              width: 2,
              color: AppColors.main_color,
            ),
            new Expanded(
              flex: 7,
              child: new Container(
                  padding: EdgeInsets.only(left: 12),
                  height: 50,
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Container(
                        child: new Text(listItems[i]["prof_name"] == "" ? "NO NAME" : listItems[i]["prof_name"],
                            style: TextStyle(
                              color: AppColors.main_color,
                              fontSize: Constants_data.getFontSize(context, 15),
                            ),
                            maxLines: 1),
                      ),
                      new Container(
                        margin: EdgeInsets.only(top: 3),
                        child: new Text(listItems[i]["Address"],
                            style: TextStyle(color: AppColors.grey_color, fontSize: Constants_data.getFontSize(context, 13)),
                            maxLines: 1),
                      )
                    ],
                  )),
            ),
          ],
        ),
      ));
    }

    return new Container(
      margin: EdgeInsets.all(5),
      child: new Column(
        children: rows,
      ),
    );
  }
}
