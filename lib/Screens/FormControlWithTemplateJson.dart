import 'dart:convert';

import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
import 'package:flexi_profiler/Widget/CheckBoxWidget.dart';
import 'package:flexi_profiler/Widget/DropDownWidget.dart';
import 'package:flexi_profiler/Widget/RadioButtonWidget.dart';
import 'package:flexi_profiler/Widget/DateTimePickerDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Constants/Constants_data.dart';
import '../Constants/StateManager.dart';
import '../Theme/DarkThemeProvider.dart';
import '../Theme/StyleClass.dart';

import 'package:flexi_profiler/DBClasses/DBProfessionalList.dart';

class FormControlWithTemplateJson extends StatefulWidget {
  @override
  _ScreenState createState() => new _ScreenState();
}

class _ScreenState extends State<FormControlWithTemplateJson> {
  double height, width;
  DarkThemeProvider themeChange;
  ThemeData themeData;
  ApiBaseHelper _helper = new ApiBaseHelper();

  Map<String, dynamic> templateJson;

  Map<String, dynamic> requestJson;
  String url;
  bool isSavingData = false;
  String accountType;
  bool isLoaded = false;
  final formKey = GlobalKey<FormState>();
  String title = "";

  @override
  Widget build(BuildContext context) {
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    accountType = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Constants_data.getFlexibleAppBar(themeChange.darkTheme),
        title: Text(
          "$title",
        ),
      ),
      body: Container(
          height: height,
          width: width,
          child: isLoaded
              ? getMainView()
              : FutureBuilder<dynamic>(
                  future: getTemplate(accountType),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.data != null && templateJson != null) {
                        delayForTitle();
                        return getMainView();
                      } else {
                        return Container(
                          child: Center(
                            child: Text("Problem in Loading templateJson"),
                          ),
                        );
                      }
                    } else {
                      return Container();
                    }
                  },
                )),
    );
  }

  delayForTitle() async {
    await Future.delayed(new Duration(milliseconds: 500));
    this.setState(() {});
  }

  Widget getMainView() {
    return Column(
      children: [
        Expanded(child: getView(templateJson["template_json"])),
        InkWell(
          child: isSavingData
              ? CircularProgressIndicator()
              : Container(
                  color: themeData.accentColor,
                  height: 45,
                  width: width,
                  child: Center(
                      child: Text(
                    "Save",
                    style: Styles.subtitle1
                        .copyWith(color: themeData.primaryColor),
                  )),
                ),
          onTap: () async {
            if (Constants_data.app_user == null) {
              currentUser = await StateManager.getLoginUser();
            } else {
              currentUser = Constants_data.app_user;
            }
            requestJson["division"] = currentUser["division"];
            requestJson["hq_code"] = currentUser["hq_code"];
            print("RequestJson : ${jsonEncode(requestJson)}");
             saveData(requestJson);
          },
        )
      ],
    );
  }

  Future<dynamic> getTemplate(accountType) async {
    var dt = await DBProfessionalList.prformQueryOperation(
        "SELECT * FROM dt_additional_templateJson WHERE id=? AND type=? ",
        [accountType, "Add"]);
    // dt = [
    //   {
    //     "Id": "Customer",
    //     "type": "Add",
    //     "template": {
    //       "template_json": {
    //         "ScreenName": "AddAccountScreen",
    //         "Row": [
    //           [
    //             {
    //               "hint": "Customer Code",
    //               "flex": 10,
    //               "txt_style": "caption1",
    //               "value": "",
    //               "widget_id": "customer_code",
    //               "widget_type": "Field",
    //               "isRequired": "Y",
    //               "input_type": "number",
    //               "max_length": "5"
    //             }
    //           ],
    //           [
    //             {
    //               "hint": "Customer Name",
    //               "flex": 10,
    //               "txt_style": "caption1",
    //               "value": "",
    //               "widget_id": "CustomerName",
    //               "widget_type": "Field",
    //               "isRequired": "Y"
    //             }
    //           ],
    //           [
    //             {
    //               "hint": "Email",
    //               "flex": 10,
    //               "txt_style": "caption1",
    //               "value": "",
    //               "widget_id": "email",
    //               "widget_type": "Field",
    //               "isRequired": "Y"
    //             }
    //           ],
    //           [
    //             {
    //               "hint": "Mobile No",
    //               "flex": 10,
    //               "txt_style": "caption1",
    //               "value": "",
    //               "widget_id": "mobile",
    //               "widget_type": "Field",
    //               "isRequired": "Y",
    //               "input_type": "phone",
    //               "max_length": "10"
    //             }
    //           ],
    //           [
    //             {
    //               "label": "CheckBox demo",
    //               "flex": 5,
    //               "txt_style": "caption1",
    //               "defaultSelection": "0",
    //               "widget_id": "chb",
    //               "widget_type": "CheckBox"
    //             },
    //             {
    //               "label": "CheckBox demo",
    //               "flex": 5,
    //               "txt_style": "caption1",
    //               "defaultSelection": "0",
    //               "widget_id": "chb",
    //               "widget_type": "CheckBox"
    //             }
    //           ],
    //           [
    //             {
    //               "label": "Radio 1",
    //               "flex": 5,
    //               "txt_style": "caption1",
    //               "widget_id": "rdb",
    //               "widget_type": "RadioButton",
    //               "value": 0
    //             },
    //             {
    //               "label": "Radio 2",
    //               "flex": 5,
    //               "txt_style": "caption1",
    //               "widget_id": "rdb",
    //               "widget_type": "RadioButton",
    //               "value": 1
    //             }
    //           ],
    //           [
    //             {
    //               "label": "DropDown",
    //               "flex": 10,
    //               "txt_style": "caption1",
    //               "defaultSelection": "0",
    //               "widget_id": "mobile",
    //               "widget_type": "DropDown",
    //               "options": [
    //                 {"id": "1", "name": "Item 1"},
    //                 {"id": "2", "name": "Item 2"},
    //                 {"id": "3", "name": "Item 3"},
    //                 {"id": "4", "name": "Item 4"},
    //                 {"id": "5", "name": "Item 5"}
    //               ]
    //             }
    //           ],
    //           [
    //             {
    //               "flex": 10,
    //               "txt_style": "caption1",
    //               "selected_date": "today",
    //               "first_date": "01-01-2010",
    //               "last_date": "today",
    //               "format": "dd-MM-yyyy",
    //               "widget_id": "date",
    //               "widget_type": "Date"
    //             },
    //             {
    //               "flex": 10,
    //               "txt_style": "caption1",
    //               "selected_date": "",
    //               "format": "hh:mm a",
    //               "widget_id": "time",
    //               "widget_type": "Time"
    //             }
    //           ],
    //         ]
    //       },
    //       "requestJson": {
    //         "CustomerId": "",
    //         "hq_code": "",
    //         "division": "",
    //         "customer_code": "",
    //         "CustomerName": "",
    //         "CustomerShortName": "",
    //         "depo_code": "",
    //         "mobile": "",
    //         "Address": "",
    //         "Address2": "",
    //         "Address3": "",
    //         "Country": "",
    //         "CountryCode": "",
    //         "State": "",
    //         "City": "",
    //         "PostalCode": "",
    //         "PhoneNo1": "",
    //         "PhoneNo2": "",
    //         "Fax": "",
    //         "ContactPerson": "",
    //         "GSTNo": "",
    //         "email": "",
    //         "CustomerType": "s",
    //         "FromApp": "Y",
    //         "rdb": -1,
    //         "date": "",
    //         "time": ""
    //       }
    //     }
    //   }
    // ];
    if (dt != null && dt.length > 0) {
      try {
        print("Template Json: $dt");
        templateJson = jsonDecode(dt[0]["template"].toString());
        // templateJson = dt[0]["template"];
        requestJson = templateJson["requestJson"];
        url = templateJson["method"].toString();
        title = templateJson["template_json"]["ScreenName"];
        isLoaded = true;
        return true;
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }

  var currentUser;

  saveData(requestJson) async {
    FocusScope.of(context).unfocus();
    if (formKey.currentState.validate()) {
      String Url = "/$url?RepId=${currentUser["Rep_Id"]}";
      this.setState(() {
        isSavingData = true;
      });
      try {
        dynamic data = await _helper.post(Url, requestJson, true);
        print("Response : ${data}");
        if (data["Status"] == 1) {
          Constants_data.toastNormal(data["Message"].toString());
          Navigator.pop(context);
        } else {
          Constants_data.toastError(data["Message"].toString());
        }
      } catch (e) {
        Constants_data.toastError("Error in saving data");
        this.setState(() {
          isSavingData = false;
        });
      }
      this.setState(() {
        isSavingData = false;
      });
    }
  }

  Widget getView(templateJson) {
    List<Widget> cols = [];
    for (int j = 0; j < templateJson["Row"].length; j++) {
      List<Widget> rows = [];
      for (int i = 0; i < templateJson["Row"][j].length; i++) {
        Map<String, dynamic> singleRow = templateJson["Row"][j][i];
        Widget vi = Expanded(
          flex: singleRow["flex"],
          child: Container(),    );

        if (singleRow["widget_type"].toString() == "Field") {
          TextInputType inputType;
          List<TextInputFormatter> inputFormatter = [];
          if (singleRow["input_type"] == null ||
              singleRow["input_type"] == "" ||
              singleRow["input_type"] == "text") {
            inputType = TextInputType.text;
          } else if (singleRow["input_type"] == "phone") {
            inputType = TextInputType.phone;
            inputFormatter = [
              FilteringTextInputFormatter.allow(RegExp('[0-9+]')),
            ];
          } else if (singleRow["input_type"] == "number") {
            inputType = TextInputType.number;
            inputFormatter = [
              FilteringTextInputFormatter.allow(RegExp('[0-9]')),
            ];
          } else if (singleRow["input_type"] == "email") {
            inputType = TextInputType.emailAddress;
          }

          int maxLength = 0;
          if (singleRow["max_length"] != null ||
              singleRow["max_length"] != "") {
            try {
              maxLength = int.parse(singleRow["max_length"].toString());
            } catch (e) {}
          }
          vi = Expanded(
              flex: singleRow["flex"],
              child: Container(
                alignment: singleRow["align"] == "left"
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: TextFormField(
                  onChanged: (val) {
                    requestJson[singleRow["widget_id"].toString()] = val;
                  },
                  validator: (str) {
                    if (str.trim() == "" && singleRow["isRequired"] == "Y") {
                      return "Field can't be blank";
                    }
                    return null;
                  },
                  maxLength: maxLength > 0 ? maxLength : null,
                  keyboardType: inputType,
                  inputFormatters: inputFormatter,
                  decoration: new InputDecoration(
                      counter: Offstage(),
                      labelText: "${singleRow["hint"]}",
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
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.red,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.red,
                        ),
                      )),
                  // keyboardType: TextInputType.emailAddress,
                  style: new TextStyle(
                    fontFamily: "Poppins",
                  ),
                ),
              ));
        }
        else if (singleRow["widget_type"].toString() == "CheckBox") {
          vi = Expanded(
              flex: singleRow["flex"],
              child: Container(
                margin: EdgeInsets.all(1),
                //color: Colors.grey,
                alignment: singleRow["align"] == "right"
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: CheckBoxWidget(
                  templateJson: singleRow,
                  onChanged: (val) {
                    this.setState(() {
                      singleRow["defaultSelection"] = val ? "1" : "0";
                      requestJson[singleRow["widget_id"]] = val ? "1" : "0";
                    });

                    print("Selection Status : $requestJson");
                  },
                ),
              ));
        }
        else if (singleRow["widget_type"].toString() == "RadioButton") {
          vi = Expanded(
              flex: singleRow["flex"],
              child: Container(
                margin: EdgeInsets.all(1),
                //color: Colors.grey,
                alignment: singleRow["align"] == "right"
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: RadioButtonWidget(
                  templateJson: singleRow,
                  onChanged: (val) {
                    this.setState(() {
                      requestJson[singleRow["widget_id"]] = val;
                    });

                    print("Selection Status RadioButton: $requestJson");
                  },
                  groupValue: requestJson[singleRow["widget_id"]],
                ),
              ));
        }
        else if (singleRow["widget_type"].toString() == "DropDown") {
          vi = Expanded(
              flex: singleRow["flex"],
              child: Container(
                margin: EdgeInsets.all(1),
                //color: Colors.grey,
                alignment: singleRow["align"] == "right"
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: CustomDropdown(
                  templateJson: singleRow,
                  onChanged: (val, item) {
                    this.setState(() {
                      singleRow["defaultSelection"] = val;
                      requestJson[singleRow["widget_id"]] = val.toString();
                    });

                    print("Selection Item : $requestJson ");
                  },
                ),
              ));
        }
        else if (singleRow["widget_type"].toString() == "Date") {
          DateTime selectedDate = new DateTime.now();
          if (singleRow["selected_date"] != null &&
              singleRow["selected_date"] != "" &&
              singleRow["selected_date"] != "today") {
            selectedDate = Constants_data.stringToDate(
                singleRow["selected_date"], singleRow["format"]);
            requestJson[singleRow["widget_id"]] =
                Constants_data.dateToString(selectedDate, singleRow["format"]);
          } else {
            requestJson[singleRow["widget_id"]] = Constants_data.dateToString(
                DateTime.now(), singleRow["format"]);
          }
          vi = Expanded(
              flex: singleRow["flex"],
              child: InkWell(
                  onTap: () async {
                    // String strDate = await DateTimePickerDialog.selectDate(
                    //     selectedDate, firstDate, lastDate, format,themeChange,context);
                    String strDate = await DateTimePickerDialog.selectDate(
                        context: context,
                        themeChange: themeChange,
                        template: singleRow);
                    if (strDate != null) {
                      this.setState(() {
                        singleRow["selected_date"] = strDate;
                        requestJson[singleRow["widget_id"]] = strDate;
                      });
                    }
                    print("Callback date : ${strDate}");
                  },
                  child: Container(
                    height: 45,
                    margin: EdgeInsets.all(2),
                    padding: EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border:
                            Border.all(width: 1, color: AppColors.grey_color)),
                    child: Row(
                      children: <Widget>[
                        Container(
                            child: Text(
                          "Date : ",
                          style: Styles.caption1,
                        )),
                        Expanded(
                            child: Text(
                                "${Constants_data.dateToString(selectedDate, singleRow["format"])}",
                                style: Styles.h4)),
                        Icon(
                          Icons.date_range_outlined,
                          color: AppColors.grey_color,
                        )
                      ],
                    ),
                  )));
        }
        else if (singleRow["widget_type"].toString() == "Time") {
          String selectedTime = singleRow["selected_time"];
          if (singleRow["selected_time"] == null ||
              singleRow["selected_time"] == "null") {
            selectedTime = Constants_data.dateToString(
                DateTime.now(), singleRow["format"]);
            requestJson[singleRow["widget_id"]] = selectedTime;
          } else {
            requestJson[singleRow["widget_id"]] = singleRow["selected_time"];
          }
          vi = Expanded(
              flex: singleRow["flex"],
              child: InkWell(
                  onTap: () async {
                    String strTime = await DateTimePickerDialog.selectTime(
                        themeChange: themeChange,
                        context: context,
                        timeFormat: singleRow["format"]);
                    if (strTime != null) {
                      this.setState(() {
                        singleRow["selected_time"] = strTime;
                        requestJson[singleRow["widget_id"]] = strTime;
                      });
                    }
                    print("Callback Time : ${strTime}");
                  },
                  child: Container(
                    height: 45,
                    margin: EdgeInsets.all(2),
                    padding: EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border:
                            Border.all(width: 1, color: AppColors.grey_color)),
                    child: Row(
                      children: <Widget>[
                        Container(
                            child: Text(
                          "Date : ",
                          style: Styles.caption1,
                        )),
                        Expanded(
                            child: Text("$selectedTime", style: Styles.h4)),
                        Icon(
                          Icons.date_range_outlined,
                          color: AppColors.grey_color,
                        )
                      ],
                    ),
                  )));
        }
        rows.add(vi);
      }
      cols.add(Row(
        children: rows,
      ));
    }

    return Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
        child: SingleChildScrollView(
          child: Form(
              key: formKey,
              child: Column(
                children: cols,
              )),
        ));
  }
}
