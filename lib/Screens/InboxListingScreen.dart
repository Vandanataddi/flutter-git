import 'dart:collection';
import 'dart:convert';
import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Constants/StateManager.dart';
import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
import 'package:flexi_profiler/DBClasses/CreateAllTables.dart';
import 'package:flexi_profiler/DBClasses/DBProfessionalList.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class InboxListingScreen extends StatefulWidget {
  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<InboxListingScreen> {
  List<dynamic> mainData = [];
  bool isLoaded = false;
  List<bool> selectedList = [];
  bool isSelectable = false;
  ApiBaseHelper _helper = ApiBaseHelper();
  DarkThemeProvider themeChange;
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    Constants_data.currentScreenContext = context;
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Constants_data.getFlexibleAppBar(themeChange.darkTheme),
        title: Text('Inbox'),
      ),
      body: new Container(
        child: !isLoaded
            ? FutureBuilder<dynamic>(
          future: getDataFromLocal(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return getView();
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        )
            : getView(),
      ),
    );
  }

  Future<dynamic> getDataFromLocal() async {
    selectedList = [];
    var dataUser;
    if (Constants_data.app_user == null) {
      dataUser = await StateManager.getLoginUser();
    } else {
      dataUser = Constants_data.app_user;
    }

    try {
      String routeUrl = '/GetMessages?RepId=${dataUser["RepId"]}&AppName=degrtool';
      var inboxData = await _helper.get(routeUrl);
      List<dynamic> tempList = inboxData["dt_ReturnedTables"][0];
     // await CreateAllTables.createTableFromAPIResponse(tempList, "MessageData");
    } on Exception catch (err) {
      print("Error in GetMessages : $err");
    }

    List<dynamic> res = await DBProfessionalList.getInboxData();
    print('listSize = ${res.length}');
    if (res != null) {
      mainData = res;
    }
    for (int i = 0; i < mainData.length; i++) {
      selectedList.add(false);
    }
    isLoaded = true;
    return null;
  }

  getView() {
    if (mainData.length > 0) {
      Widget vi = ListView.builder(
          itemCount: mainData.length,
          itemBuilder: (BuildContext ctxt, int index) {
            String d = "";
            try {
              DateTime date = Constants_data.stringToDate(
                  mainData[index]["Date"], "yyyy-MM-dd'T'HH:mm:ss");
              d = Constants_data.dateToString(date, "dd/MM/yyyy HH:mm a");
            } catch (e) {
              print(e.toString());
            }
            return Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              child: new GestureDetector(
                onTap: () async {
                  if (!isSelectable) {
                    Map<String, dynamic> args = new HashMap();
                    args["data"] = mainData;
                    args["index"] = index;

                    print("Sending data : ${jsonEncode(mainData[index])}");
                    await Navigator.pushNamed(
                        context, "/InboxDetailsScreen", arguments: args);
                    this.setState(() {
                      isLoaded = false;
                    });
                  } else {
                    this.setState(() {
                      selectedList[index] = !selectedList[index];
                    });
                  }
                },
                child: new Container(
                  // height: 80,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: mainData[index]["Status"] == "U"
                            ? Colors.lightBlueAccent.withOpacity(0.3)
                            : themeData.cardColor,
                        border: Border(bottom: BorderSide(
                            width: 0.5, color: Colors.black45))),
                    child: Stack(
                      children: <Widget>[
                        new Align(
                          alignment: Alignment.topRight,
                          child: new Container(
                            child: new Text(
                              d,
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.main_color),
                            ),
                          ),
                        ),
                        new Row(
                          children: <Widget>[
                            isSelectable
                                ? new Container(
                              margin: EdgeInsets.only(right: 10),
                              width: 20,
                              child: Icon(
                                Icons.check_circle,
                                color: selectedList[index]
                                    ? AppColors.main_color
                                    : AppColors.grey_color.withOpacity(0.3),
                              ),
                            )
                                : new Container(),
                            new Expanded(
                                child: new Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    new Container(
                                      margin: EdgeInsets.only(top: 2,
                                          bottom: 2,
                                          left: 2,
                                          right: 80),
                                      child: new Text(
                                        mainData[index]["SenderName"] != null
                                            ? mainData[index]["SenderName"]
                                            : "-",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                        maxLines: 1,
                                      ),
                                    ),
                                    new Container(
                                        margin: EdgeInsets.all(1),
                                        child: new Text(
                                          mainData[index]["Subject"] != null
                                              ? mainData[index]["Subject"]
                                              : "-",
                                          style: TextStyle(fontSize: 13,
                                              color: themeData.textTheme.caption.color),
                                        )),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: new Container(
                                              margin: EdgeInsets.only(top: 3,
                                                  bottom: 3,
                                                  left: 3,
                                                  right: 25),
                                              child: new Text(
                                                mainData[index]["ShortMessage"] !=
                                                    null
                                                    ? mainData[index]["ShortMessage"]
                                                    : "-",
                                                style: TextStyle(fontSize: 12,
                                                    color: themeData.textTheme.caption.color),
                                                maxLines: 1,
                                              )),
                                        ),
                                        mainData[index]["IsAnyAttachment"] == "Y"
                                            ? new Align(
                                            alignment: Alignment.bottomRight,
                                            child: new Container(
                                              height: 20,
                                              width: 20,
                                              child: Image.asset(
                                                "assets/images/attachment_inbox.png",
                                              ),
                                            ))
                                            : new Container(),
                                      ],
                                    ),
                                  ],
                                ))
                          ],
                        )
                      ],
                    )),
              ),
              secondaryActions: <Widget>[
                IconSlideAction(
                  caption: 'Delete',
                  color: AppColors.red_color,
                  icon: Icons.delete,
                  onTap: () async {
                    bool delete = await openDialog();
                    if (delete) {
                      await updateReadStatus(
                          mainData[index]["MessageId"].toString());
                      await deleteMessage(
                          mainData[index]["MessageId"].toString());
                      isLoaded = false;
                      this.setState(() {});
                    }
                  },
                ),
              ],
            );
          });
      return new Column(
        children: <Widget>[
          new Expanded(
              child: new Container(
                child: vi,
              )),
          new Container(
            width: MediaQuery.of(context).size.width,
            height: 40,
            color: AppColors.grey_color.withOpacity(0.3),
            child: new Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: new GestureDetector(
                    onTap: () {
                      if (isSelectable) {
                        for (int i = 0; i < selectedList.length; i++) {
                          selectedList[i] = false;
                        }
                        this.setState(() {
                          isSelectable = false;
                        });
                      } else {
                        this.setState(() {
                          isSelectable = true;
                        });
                      }
                    },
                    child: new Container(
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.only(left: 10),
                      child: new Text(
                        isSelectable ? "Clear" : "Select",
                        style: TextStyle(
                            color: AppColors.main_color, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: new GestureDetector(
                    onTap: () async {
                      if (isSelectable) {
                        bool delete = await openDialog();
                        if (delete) {
                          for (int i = 0; i < selectedList.length; i++) {
                            if (selectedList[i]) {
                              await updateReadStatus(
                                  mainData[i]["MessageId"].toString());
                              await deleteMessage(
                                  mainData[i]["MessageId"].toString());
                            }
                          }
                          isLoaded = false;
                          this.setState(() {
                            isSelectable = false;
                          });
                        }
                      }
                    },
                    child: new Container(
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.only(right: 10),
                      child: new Text(
                        "Delete",
                        style:
                        TextStyle(color: isSelectable
                            ? AppColors.main_color
                            : AppColors.grey_color, fontSize: 16),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      );
    } else {
      return Center(
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
            "We couldn't find any result",
            style: TextStyle(color: AppColors.grey_color,
                fontSize: Constants_data.getFontSize(context, 14)),
            textAlign: TextAlign.center,
          )
        ]),
      );
    }
  }

  Future<bool> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.only(
                left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: AppColors.main_color,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 98.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.delete_forever,
                        size: 30.0,
                        color: AppColors.white_color,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Delete',
                      style: TextStyle(color: AppColors.white_color,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(15),
                child: Center(child: Text("Are you sure want to Delete?")),
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
                          "CANCEL",
                          style: TextStyle(color: AppColors.main_color,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context, 0);
                        },
                        child:
                        Text("DELETE", style: TextStyle(
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

  updateReadStatus(String id) async {
    String query = "UPDATE MessageData SET Status='D' WHERE MessageId='$id'";
    var res = await DBProfessionalList.prformQueryOperation(query, []);
    print("Response = $res");
  }

  deleteMessage(String msgId) async {
    var dataUser;
    if (Constants_data.app_user == null) {
      dataUser = await StateManager.getLoginUser();
    } else {
      dataUser = Constants_data.app_user;
    }

    try {
      String routeUrl = '/DeleteMessages?RepId=${dataUser["RepId"]}&AppName=degrtool&MessageId=$msgId';
      var inboxData = await _helper.get(routeUrl);
      if (inboxData["Status"] == 1) {
        print("Message Deleted Successfully");
      } else {
        print("Error in delete message");
      }
    } on Exception catch (e) {
      print('Error in DeleteMessages : ${e.toString()}');
    }
  }
}
