import 'dart:collection';
import 'dart:convert';
import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Constants/StateManager.dart';
import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
import 'package:flexi_profiler/DBClasses/DBProfessionalList.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flexi_profiler/Theme/StyleClass.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';

class InboxDetailsScreen extends StatefulWidget {
  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<InboxDetailsScreen> {
  bool isLoaded = false;
  int totalSize = 0;
  bool check_once = true;
  ApiBaseHelper _helper = ApiBaseHelper();

  DarkThemeProvider themeChange;
  ThemeData themeData;

  Map<String, dynamic> element;

  @override
  Widget build(BuildContext context) {
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    Map<String, dynamic> args;
    if (check_once) {
      args = ModalRoute.of(context).settings.arguments;
      print("args = ${args}");
      index = args["index"];
      totalSize = args["data"].length;
      check_once = false;
    }

    // element = jsonDecode();
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Constants_data.getFlexibleAppBar(themeChange.darkTheme),
        title: Text("Message (${index + 1}/${totalSize})"),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(
                Icons.keyboard_arrow_up,
                size: 40,
              ),
              onPressed: () {
                if (index != 0) {
                  cnt_remarks.text = "";
                  this.setState(() {
                    index--;
                    try {
                      var data = jsonDecode(mainData[index]["Approval"]);
                      print("Data : ${data}");
                      if (data["IsFor"] == "POBApproval") {
                        print("Data for POBApproval : ${data}");
                        templateJson = data;
                        element = null;
                      } else if (data["IsFor"] == "NewAccountApproval" || data["IsFor"] == "UnlockDCREntry") {
                        print("Data for NewAccountApproval : ${data}");
                        element = data;
                        templateJson = null;
                      } else {
                        element = null;
                        templateJson = null;
                      }
                    } catch (e) {
                      print("Error in checking Approval : ${e.toString()}");
                    }
                  });
                }
              }),
          new IconButton(
              icon: new Icon(
                Icons.keyboard_arrow_down,
                size: 40,
              ),
              onPressed: () {
                if (index != totalSize - 1) {
                  cnt_remarks.text = "";
                  this.setState(() {
                    index++;
                    try {
                      var data = jsonDecode(mainData[index]["Approval"]);

                      if (data["IsFor"] == "POBApproval") {
                        print("Data for POBApproval : ${data}");
                        templateJson = data;
                        element = null;
                      } else if (data["IsFor"] == "NewAccountApproval" || data["IsFor"] == "UnlockDCREntry") {
                        print("Data for ${data["IsFor"]} : ${data}");
                        element = data;
                        templateJson = null;
                      }
                    } catch (e) {
                      print("Error in checking Approval : ${e.toString()}");
                    }
                  });
                }
              }),
        ],
      ),
      body: new Container(
        child: !isLoaded
            ? FutureBuilder<dynamic>(
                future: getDataFromLocal(args),
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

  var mainData;
  int index;

  Future<dynamic> getDataFromLocal(var args) async {
    mainData = args["data"];

    index = args["index"];
    totalSize = mainData.length;
    try {
      var data = jsonDecode(mainData[index]["Approval"]);
      if (data["IsFor"] == "POBApproval") {
        print("Data for POBApproval : ${data}");
        templateJson = data;
        for (int i = 0; i < templateJson["data"].length; i++) {
          if (templateJson["data"][i]["price"] == null ||
              templateJson["data"][i]["price"].toString() == "" ||
              templateJson["data"][i]["price"].toString() == "0" ||
              templateJson["data"][i]["qty"] == null ||
              templateJson["data"][i]["qty"].toString() == "" ||
              templateJson["data"][i]["qty"].toString() == "0") {
            templateJson["data"][i]["rate"] = "0.0";
          } else {
            templateJson["data"][i]["rate"] =
                "${(double.parse(templateJson["data"][i]["price"].toString()) / double.parse(templateJson["data"][i]["qty"].toString())).toStringAsFixed(2)}";
          }
        }
      } else if (data["IsFor"] == "NewAccountApproval" || data["IsFor"] == "UnlockDCREntry") {
        print("Data for NewAccountApproval : ${data}");
        element = data;
      }
    } catch (e) {
      print("Error in checking Approval : ${e.toString()}");
    }
    isLoaded = true;
    return null;
  }

  updateReadStatus(String id) async {
    String query = "UPDATE MessageData SET Status='R' WHERE MessageId='$id'";
    var res = await DBProfessionalList.prformQueryOperation(query, []);
    print("Response = $res");
  }

  TextEditingController cnt_remarks = new TextEditingController();

  getView() {
    DateTime date = Constants_data.stringToDate(mainData[index]["Date"], "yyyy-MM-dd'T'HH:mm:ss");
    String d = Constants_data.dateToString(date, "dd/MM/yyyy HH:mm a");

    if (mainData[index]["Status"] == "U") {
      updateReadStatus(mainData[index]["MessageId"].toString());
      markAsRead(mainData[index]["MessageId"].toString());
    }
    return Container(
      margin: EdgeInsets.all(10),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Expanded(
                  child: new Container(
                      child: new Text("${mainData[index]["SenderName"]}",
                          style: TextStyle(fontSize: 15, color: AppColors.black_color, fontWeight: FontWeight.bold)))),
              new Container(
                child: new Text(
                  d,
                  style: TextStyle(fontSize: 10, color: AppColors.main_color),
                ),
              )
            ],
          ),
          Container(
              margin: EdgeInsets.only(top: 10),
              child: new Text(mainData[index]["Subject"],
                  style: TextStyle(
                    fontSize: 14,
                  ))),
          new Container(
              margin: EdgeInsets.only(top: 10, bottom: 10),
              width: MediaQuery.of(context).size.width,
              height: 1,
              color: AppColors.grey_color),
          // new Text(mainData[index]["Message"],
          //     style: TextStyle(
          //       fontSize: 14,
          //     )),
          Expanded(
              flex: 5,
              child: new SingleChildScrollView(
                  child: Container(
                child: HtmlWidget(mainData[index]["Message"],
                    textStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 14), onTapUrl: (data) async {
                  print("onTapLink ${data}");
                  String test = data.substring(7);

                  List<String> list = test.split("-");
                  String CustomerId = list[0];
                  String accountType = list[1];

                  CustomerId = CustomerId.toUpperCase();
                  if (accountType.toUpperCase() == "DRUG") {
                    accountType = "Drug";
                  } else if (accountType.toUpperCase() == "HCP") {
                    accountType = "HCP";
                  } else if (accountType.toUpperCase() == "TERRIOTORY") {
                    accountType = "Territory";
                  } else if (accountType.toUpperCase() == "CUSTOMER") {
                    accountType = "Customer";
                  }

                  print("CustomerId : $CustomerId");
                  print("accoutType : $accountType");

                  try {
                    String str1 = await DBProfessionalList.getHeaderTemplateFromViewId(accountType);
                    var template_json_header = jsonDecode(str1);

                    Map<String, List<dynamic>> response =
                        await DBProfessionalList.getAttributesByCustomerID(accountType, CustomerId);

                    List<dynamic> categoryData = await DBProfessionalList.getCategoryFromAccountType(accountType);
                    Constants_data.categoryList = categoryData;

                    List<dynamic> data = response["data"];

                    Map<String, dynamic> arg = new HashMap();
                    for (int i = 0; i < data.length; i++) {
                      if (data[i]["CustomerId"] == CustomerId) {
                        arg["data"] = data[i];
                      }
                    }
                    arg["keys"] = response["keys"];
                    arg["accountType"] = accountType;
                    arg["jsonHeader"] = template_json_header;
                    Navigator.pushNamed(context, "/AccountDetailsScreen", arguments: arg);
                  } on Exception catch (ex) {
                    Constants_data.toastError("Data not found");
                    print(ex);
                  }
                })
                // new Text(mainData[index]["Message"],
                //     style: TextStyle(
                //       fontSize: 14,
                //     ))
                ,
              ))),
          element != null
              ? Container(
                  child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                    maxLines: 3,
                  ),
                ))
              : Container(),
          templateJson != null
              ? Expanded(
                  flex: 15,
                  child: getPOBApprovalView(),
                )
              : Container(),

          createViewFromElement(element),
          mainData[index]["IsAnyAttachment"] == "Y"
              ? new GestureDetector(
                  onTap: () {
                    if (mainData[index]["AttachmentType"] != null && mainData[index]["AttachmentType"] == ".pdf") {
                      Map<String, String> args = new HashMap();
                      args["url"] = mainData[index]["AttachmentPath"];
                      args["title"] = mainData[index]["AttachmentName"];

                      Navigator.pushNamed(context, "/PDFViewer", arguments: args);
                    } else {
                      Constants_data.toastError("Unable to load Attachment");
                    }
                  },
                  child: new Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: AppColors.grey_color),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(5),
                    child: new Row(
                      children: <Widget>[
                        new Container(
                          height: 20,
                          width: 20,
                          child: Image.asset(
                            "assets/images/attachment_inbox.png",
                          ),
                        ),
                        new Container(
                            margin: EdgeInsets.only(left: 10), child: new Text("${mainData[index]["AttachmentName"]}"))
                      ],
                    ),
                  ))
              : new Container()
        ],
      ),
    );
  }

  markAsRead(String msgId) async {
    var dataUser;
    if (Constants_data.app_user == null) {
      dataUser = await StateManager.getLoginUser();
    } else {
      dataUser = Constants_data.app_user;
    }

    String routeUrl = "/MarkReadMessages?RepId=${dataUser["Rep_Id"]}&AppName=degrtool&MessageId='$msgId'";
    try {
      var inboxData = await _helper.get(routeUrl);
      if (inboxData["Status"] == 1) {
        print("Message Deleted Successfully");
      } else {
        print("Error in delete message : ${inboxData}");
      }
    } on Exception catch (e) {
      print('Error in MarkReadMessages : ${e.toString()}');
    }
  }

  createViewFromElement(element) {
    if (element != null) {
      List<Widget> listButtons = [];
      for (int i = 0; i < element["elements"].length; i++) {
        listButtons.add(Expanded(
            child: Container(
          margin: EdgeInsets.all(3),
          child: MaterialButton(
            color: themeData.accentColor,
            child: Text(
              "${element["elements"][i]["button"]}",
              style: TextStyle(color: Colors.white),
            ),
            disabledColor: Colors.grey,
            onPressed: element["elements"][i]["is_enabled"] == "Y"
                ? () async {
                    String text = "Are you sure do you want to ${element["elements"][i]["button"]}?";
                    bool result = await openDialog(text, "Request Approval");
                    if (result) {
                      try {
                        var inboxData = await _helper.get(
                            element["elements"][i]["url"].toString() +
                                "&remark=${Uri.encodeComponent(cnt_remarks.text.trim())}",
                            isNeedToConcatBaseUrl: false);
                        if (inboxData["Status"] == 1) {
                          Constants_data.toastNormal(inboxData["Message"].toString());
                          Navigator.pop(context);
                        } else {
                          Constants_data.toastError(inboxData["Message"].toString());
                          // Navigator.pop(context);
                        }
                      } on Exception catch (e) {
                        Constants_data.toastError("Error in ${element["elements"][i]["button"]}.");
                      }
                    }
                  }
                : null,
          ),
        )));
      }
      return Container(
          margin: EdgeInsets.only(bottom: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: listButtons,
              ),
              Container(
                child: Text(
                  "${element["message"]}",
                  style: Styles.caption2.copyWith(color: themeData.primaryColorLight),
                ),
              )
            ],
          ));
    } else {
      return Container();
    }
  }

  Map<String, dynamic> templateJson;

  getPOBApprovalView() {
    print("template_json : ${templateJson["template_json"]}");
    print("Data : ${templateJson["data"]}");

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: templateJson["data"].length,
            itemBuilder: (context, index) {
              return Container(
                  child: createStaticView(templateJson["data"][index], param: index, onClick: (data, param) {
                templateJson["data"][index]["approve_status"] =
                    templateJson["data"][index]["approve_status"].toString() == "0" ? "1" : "0";
                this.setState(() {});
              }, onChange: (val) {
                this.setState(() {
                  int qty = val == "" ? 0 : int.parse(val);
                  double singleItemPrice = double.parse(templateJson["data"][index]["rate"]);
                  templateJson["data"][index]["qty"] = qty.toString();
                  templateJson["data"][index]["price"] = "${(singleItemPrice * qty).toStringAsFixed(2)}";
                });
              }));
            },
          ),
        ),
        Container(
            child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            maxLines: 3,
          ),
        )),
        Container(
          margin: EdgeInsets.all(3),
          child: MaterialButton(
              color: themeData.accentColor,
              child: Text(
                "Submit",
                style: TextStyle(color: Colors.white),
              ),
              disabledColor: Colors.grey,
              onPressed: () async {
                List<String> approvedItemsId = [];
                String names = "";
                for (int i = 0; i < templateJson["data"].length; i++) {
                  if (templateJson["data"][i]["approve_status"].toString().trim() == "1") {
                    approvedItemsId.add(templateJson["data"][i]["product_id"].toString());
                    names = names + "${templateJson["data"][i]["product_name"]}, ";
                  }
                }
                names = Constants_data.removeLastCharFromString(names);
                print("Approved Ids : ${approvedItemsId}");
                Map<String, dynamic> requestJson = templateJson["requestJson"];
                requestJson["approved_items"] = templateJson["data"];
                // requestJson["approved_items"] = approvedItemsId;
                try {
                  String text = names == ""
                      ? "Are you sure do you want to reject all the products?"
                      : "Are you sure do you want to Approve $names products?";
                  bool result = await openDialog(text, "POB Approval");
                  if (result) {
                    var response = await _helper.post(
                        templateJson["request_url"].toString() + "&remark=${Uri.encodeComponent(cnt_remarks.text.trim())}",
                        requestJson,
                        true,
                        isNeedToConcatBaseUrl: false);
                    if (response["Status"] == 1) {
                      Constants_data.toastNormal(response["Message"].toString());
                      Navigator.pop(context);
                    } else {
                      Constants_data.toastError(response["Message"].toString());
                      //Navigator.pop(context);
                    }
                  }
                } on Exception catch (e) {
                  print("Error in submitting data : ${e.toString()}");
                  Constants_data.toastError("Error in Submitting data.");
                }
              }),
        )
      ],
    );
  }

  bool isEditableQty = true;

  Widget createStaticView(data, {Function onClick, param, Function onChange}) {
    TextEditingController cnt = new TextEditingController();
    cnt.text = data["qty"];
    cnt.selection = TextSelection.fromPosition(TextPosition(offset: cnt.text.length));
    return Container(
        margin: EdgeInsets.symmetric(
          horizontal: 5,
        ),
        child: Card(
            elevation: themeChange.darkTheme ? null : 3,
            child: ListTile(
                onTap: onClick == null
                    ? null
                    : () {
                        onClick(data, param);
                      },
                title: Text(
                  "${data["product_name"]}",
                  style: Styles.h4,
                ),
                subtitle: Row(children: [
                  Container(child: Text("Qty : ")),
                  isEditableQty
                      ? Container(
                          height: 25,
                          width: 50,
                          child: TextField(
                            controller: cnt,
                            onChanged: onChange,
                            style: new TextStyle(fontSize: 15.0),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            ],
                            decoration: new InputDecoration(
                                counterText: "",
                                contentPadding: EdgeInsets.only(bottom: 12),
                                hintText: "Qty",
                                hintStyle: new TextStyle(color: AppColors.grey_color)),
                          ))
                      : Container(child: Text("${data["qty"]}")),
                  Expanded(child: Container()),
                  Container(child: Text("Total Price : ${data["price"]}"))
                ]),
                trailing: Container(
                  child: Icon(
                    data["approve_status"].toString() == "1" ? Icons.check_box : Icons.check_box_outline_blank,
                    color: themeData.accentColor,
                  ),
                ))));
  }

  Widget createViewFromTemplate(templateJson, data, {Function onClick, param}) {
    List<Widget> cols = [];
    for (int j = 0; j < templateJson["Row"].length; j++) {
      List<Widget> rows = [];
      for (int i = 0; i < templateJson["Row"][j].length; i++) {
        Map<String, dynamic> singleRow = templateJson["Row"][j][i];
        Widget vi = Expanded(
          flex: singleRow["flex"],
          child: Container(),
        );
        String text, label;
        text = data[singleRow["widget_id"]].toString();
        if (text == null || text == "") {
          text = "N/A";
        }

        if (singleRow["widget_type"].toString() == "Label" && singleRow["lable"].toString() != "") {
          label = "${singleRow["lable"].toString()}";
        } else if (singleRow["lable"].toString() != "") {
          label = "${singleRow["lable"].toString()} : ";
        }

        if (singleRow["widget_type"].toString() == "Text") {
          vi = Expanded(
              flex: singleRow["flex"],
              child: Container(
                // alignment: singleRow["align"] == "left"
                //     ? Alignment.centerLeft
                //     : Alignment.centerRight,
                padding: EdgeInsets.symmetric(vertical: 3),
                child: textWidget(singleRow, label, text),
              ));
        } else if (singleRow["widget_type"].toString() == "Divider") {
          vi = Container(height: 50, width: 1, color: AppColors.grey_color, margin: EdgeInsets.only(right: 5));
        }

        rows.add(vi);
      }
      cols.add(Row(
        children: rows,
      ));
    }

    return Container(
        margin: EdgeInsets.symmetric(
          horizontal: 5,
        ),
        child: Card(
            elevation: themeChange.darkTheme ? null : 3,
            child: InkWell(
                onTap: onClick == null
                    ? null
                    : () {
                        onClick(data, param);
                      },
                child: Container(
                    padding: EdgeInsets.fromLTRB(7.0, 10.0, 10.0, 7.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: Column(
                          children: cols,
                        )),
                        Container(
                          child: Icon(
                            data["approve_status"].toString() == "1" ? Icons.check_box : Icons.check_box_outline_blank,
                            color: themeData.accentColor,
                          ),
                        ),
                      ],
                    )))));
  }

  Widget textWidget(Map<String, dynamic> singleRow, String label, String text) {
    return singleRow["orientation"].toString() != null && singleRow["orientation"].toString() == "V"
        ? Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            singleRow["label"].toString() != ""
                ? Container(
                    constraints: BoxConstraints(maxWidth: 100),
                    margin: EdgeInsets.only(bottom: 5),
                    child: Text(
                      label.replaceAll(" : ", ""),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: Constants_data.getFontSize(context, int.parse(singleRow["txt_size"].toString()) - 2),
                          color: AppColors.grey_color),
                    ))
                : Container(),
            Flexible(
                child: Text(
              text,
              overflow: TextOverflow.visible,
              style: TextStyle(
                fontWeight: singleRow["txt_style"].toString() == "Bold" ? FontWeight.bold : FontWeight.normal,
                fontSize: Constants_data.getFontSize(context, int.parse(singleRow["txt_size"].toString())),
                // color: Constants_data.hexToColor(singleRow["txt_color"].toString()
              ),
            )),
          ])
        : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            singleRow["lable"].toString() != ""
                ? Container(
                    constraints: BoxConstraints(maxWidth: 100),
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          // fontSize: Constants_data.getFontSize(context,
                          //     int.parse(singleRow["txt_size"].toString())),
                          color: AppColors.grey_color),
                    ))
                : Container(),
            Flexible(
                child: Text(
              text,
              overflow: TextOverflow.visible,
              style: TextStyle(
                  // fontWeight: singleRow["txt_style"].toString() == "Bold"
                  //     ? FontWeight.bold
                  //     : FontWeight.normal,
                  // fontSize: Constants_data.getFontSize(
                  //     context, int.parse(singleRow["txt_size"].toString())),
                  // color: Constants_data.hexToColor(singleRow["txt_color"].toString()
                  ),
            )),
          ]);
  }

  Future<bool> openDialog(text, String dialogFor) async {
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
                height: 98.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        size: 30.0,
                        color: AppColors.white_color,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      '$dialogFor',
                      style: TextStyle(color: AppColors.white_color, fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(15),
                child: Center(child: Text("$text")),
              ),
              Container(
                  margin: EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          child: Center(
                              child: SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context, 1);
                        },
                        child: Text(
                          "CANCEL",
                          style: TextStyle(color: AppColors.main_color, fontWeight: FontWeight.bold),
                        ),
                      ))),
                      Expanded(
                          child: Center(
                              child: SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context, 0);
                        },
                        child: Text("Ok", style: TextStyle(color: AppColors.main_color, fontWeight: FontWeight.bold)),
                      ))),
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
}
