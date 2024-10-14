import 'dart:collection';

import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Constants/StateManager.dart';
import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
import 'package:flexi_profiler/DBClasses/DBProfessionalList.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RMTCallScreen extends StatefulWidget {
  @override
  _StateScreen createState() => _StateScreen();
}

class _StateScreen extends State<RMTCallScreen> {
  double device_height, device_width;

  TextEditingController cnt_pName = new TextEditingController();
  TextEditingController cnt_remarks = new TextEditingController();
  var userData;
  bool isLoading = false;
  bool isLoaded = false;
  bool isCheckedIn = false;
  bool checkIn = false;
  bool checkOut = false;
  ApiBaseHelper _helper = ApiBaseHelper();
  bool isCheckOutDesable = false;

  DarkThemeProvider themeChange;
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    device_height = MediaQuery.of(context).size.height;
    device_width = MediaQuery.of(context).size.width;
    userData = ModalRoute.of(context).settings.arguments;
    print("Argument Receive : $userData");

    if (!isLoaded) callForTest();

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Constants_data.getFlexibleAppBar(themeChange.darkTheme),
        title: Text("RMT Call"),
      ),
      body: !isLoading
          ? Container(
              margin: EdgeInsets.only(top: 25),
              height: device_height,
              width: device_width,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Check In"),
                            Checkbox(
                              value: checkIn,
                              onChanged: !isCheckedIn
                                  ? (bool value) {
                                      setState(() {
                                        checkIn = value;
                                        if (value) checkOut = false;
                                      });
                                    }
                                  : null,
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Check Out",
                              style: isCheckOutDesable ? TextStyle(color: Colors.grey) : TextStyle(),
                            ),
                            Checkbox(
                              value: checkOut,
                              onChanged: isCheckOutDesable
                                  ? null
                                  : (bool value) {
                                      setState(() {
                                        checkOut = value;
                                        if (value) checkIn = false;
                                      });
                                    },
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: TextFormField(
                      controller: cnt_pName,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: new InputDecoration(
                        alignLabelWithHint: true,
                        hintText: 'Person Name',
                        hintStyle: TextStyle(fontSize: 16),
                        labelText: "Person Name",
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
                      ),
                      maxLines: 1,
                    ),
                  )
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
      bottomNavigationBar: !isLoading
          ? InkWell(
              onTap: () async {
                bool isInternetConnected = await Constants_data.checkNetworkConnectivity();
                if (isInternetConnected) {
                  callSubmit();
                } else {
                  Constants_data.toastError("Internet is not available");
                }
              },
              child: Container(
                alignment: Alignment.center,
                width: device_width,
                height: 45,
                color: AppColors.main_color,
                child: Text(
                  "Submit",
                  style: TextStyle(color: AppColors.white_color, fontWeight: FontWeight.bold),
                ),
              ),
            )
          : null,
    );
  }

  callForTest() async {
    isLoaded = true;
    String date = Constants_data.dateToString(DateTime.now(), "dd-MM-yyyy");
    String q =
        "select CustomerId, AttributeCode, AttributeValue from ProfessionalListAttribute where CustomerId in(select CustomerId from ProfessionalListAttribute where AttributeValue = 'Call In Progress' and AttributeCode = 'Status' and CustomerId in(select CustomerId from ProfessionalListAttribute where AttributeValue = '$date' and AttributeCode = 'Calldate'))";
    List<dynamic> res;
    try {
      res = await DBProfessionalList.prformQueryOperation(q, []);
      print("Testing Response : ${res}");
    } catch (err) {
      print("Error in getting checked in Account : ${err}");
    }

    if (res != null && res.length > 0) {
      String strAccounts = "You have to check out for ";
      strAccounts += '${res[0]["AttributeValue"]}, before check-in another Travel Agent.';
      Map<String, String> mapData = new HashMap();
      for (int i = 0; i < res.length; i++) {
        mapData["${res[i]["AttributeCode"].toString()}"] = res[i]["AttributeValue"].toString();
      }
      print("Map Data : ${mapData}");
      if (userData["CustomerName"].toString() == mapData["AgencyName"].toString()) {
        cnt_remarks.text = mapData["Remark"].toString();
        cnt_pName.text = mapData["PersonMet"].toString();
        this.setState(() {
          checkOut = true;
          isCheckedIn = true;
        });
      } else {
        print("Testing demo : $strAccounts");
        await openDialogCheckOut(strAccounts);
        Navigator.pop(context);
      }
    } else {
      this.setState(() {
        isCheckOutDesable = true;
      });
    }
  }

  Future<bool> openDialogCheckOut(String msg) async {
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
                height: 90.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.person,
                        size: 30.0,
                        color: AppColors.white_color,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Check-out Required',
                      style: TextStyle(color: AppColors.white_color, fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(15),
                child: Center(child: Text("$msg")),
              ),
              Container(
                  margin: EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context, 0);
                        },
                        child: Text("OK", style: TextStyle(color: AppColors.main_color, fontWeight: FontWeight.bold)),
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

  callSubmit() async {
    if (checkIn || checkOut) {
      this.setState(() {
        isLoading = true;
      });
      var dataUser;
      if (Constants_data.app_user == null) {
        dataUser = await StateManager.getLoginUser();
      } else {
        dataUser = Constants_data.app_user;
      }

      DateTime date = DateTime.now();

      String uuid = Constants_data.getUUID();
      Map<String, String> callTransactionsMap = new HashMap();
      callTransactionsMap["CallType"] = checkIn ? "chk_in" : "chk_out";
      callTransactionsMap["UniqueID"] = "$uuid";
      callTransactionsMap["PersonMet"] = "${cnt_pName.text.trim()}";
      callTransactionsMap["AccountType"] = "${userData["AccountType"].toString().trim()}";
      callTransactionsMap["AccountId"] = "${userData["CustomerId"].toString()}";
      callTransactionsMap["CallDate"] = "${Constants_data.dateToString(date, "yyyy-MM-dd HH:mm:ss")}";
      callTransactionsMap["EntryTime"] = "${Constants_data.dateToString(date, "HH:mm:ss")}";
      callTransactionsMap["Remark"] = "${cnt_remarks.text.trim()}";

      List<dynamic> list = [];
      list.add(callTransactionsMap);

      Map<String, dynamic> mainData = new HashMap();
      mainData["CallTransactions"] = list;

      try {
        String url = "/SaveCallTransaction?RepId=${dataUser["Rep_Id"]}";
        var data = await _helper.post(url, mainData, true);
        if (data["Status"] == 1) {
          Constants_data.toastNormal(data["Message"].toString());
          Constants_data.isCallUpdated = true;
          var ObjRetArgs = data["ObjRetArgs"][0];
          List<dynamic> AccountList = ObjRetArgs["AccountList"];
          List<dynamic> AccountListAttribute = ObjRetArgs["AccountListAttribute"];

          for (int i = 0; i < AccountList.length; i++) {
            var obj = AccountList[i];
            if (i == 0) {
              var res = await DBProfessionalList.prformQueryOperation(
                  "DELETE FROM ProfessionalList WHERE CustomerId=? AND AccountType=?",
                  [obj["CustomerId"].toString(), obj["AccountType"].toString()]);
              print("ProfessionalList Delete response[$i] : ${res}");
            }

            var resInsert = await DBProfessionalList.prformQueryOperation(
                "INSERT INTO ProfessionalList (CustomerId,AccountType,CustomerName,Latitude,Longitude,ProfilePic) VALUES (?,?,?,?,?,?)",
                [
                  obj["CustomerId"].toString(),
                  obj["AccountType"].toString(),
                  obj["CustomerName"].toString(),
                  obj["Latitude"].toString(),
                  obj["Longitude"].toString(),
                  obj["ProfilePicURL"].toString()
                ]);
            print("ProfessionaList Insert response[$i] : ${resInsert}");
          }

          for (int i = 0; i < AccountListAttribute.length; i++) {
            var obj = AccountListAttribute[i];
            if (i == 0) {
              var res = await DBProfessionalList.prformQueryOperation(
                  "DELETE FROM ProfessionalListAttribute WHERE CustomerId=? AND AccountType=?",
                  [obj["CustomerId"].toString(), obj["AccountType"].toString()]);
              print("ProfessionaListAttribute Delete response[$i] : ${res}");
            }

            var resInsert = await DBProfessionalList.prformQueryOperation(
                "INSERT INTO ProfessionalListAttribute (CustomerId,SeqNo,AccountType,CategoryCode,CategorySeqNo,AttributeCode,AttributeSeqNo,AttributeValue) VALUES (?,?,?,?,?,?,?,?)",
                [
                  obj["CustomerId"].toString(),
                  obj["SeqNo"].toString(),
                  obj["AccountType"].toString(),
                  obj["CategoryCode"].toString(),
                  obj["CategorySeqNo"].toString(),
                  obj["AttributeCode"].toString(),
                  obj["AttributeSeqNo"].toString(),
                  obj["AttributeValue"].toString(),
                ]);
            print("ProfessionaListAttribute Insert response[$i] : ${resInsert}");
          }

          Navigator.pop(context);
        } else {
          Constants_data.toastError(data["Message"].toString());
        }
        this.setState(() {
          isLoading = false;
        });
      } on Exception catch (err) {
        print("Error in ");
      }
    } else {
      Constants_data.toastError("Please provide check-in or check-out details");
    }
  }
}
