import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Constants/MonthPicker/month_picker_dialog.dart';
import 'package:flexi_profiler/Constants/StateManager.dart';
import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
import 'package:flexi_profiler/DBClasses/DBProfessionalList.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flexi_profiler/Theme/StyleClass.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class POBSummaryScreen extends StatefulWidget {
  @override
  ScreenState createState() => new ScreenState();
}

class ScreenState extends State<POBSummaryScreen> {
  ApiBaseHelper _helper = ApiBaseHelper();

  double height, width;
  List<dynamic> listPOB = [];
  DarkThemeProvider themeChange;
  ThemeData themeData;
  bool isShowRate;
  bool isShowDescription;

  @override
  Widget build(BuildContext context) {
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("POB Report"),
        flexibleSpace: Constants_data.getFlexibleAppBar(themeChange.darkTheme),
        actions: [
          IconButton(
              icon: Icon(Icons.filter_alt_outlined),
              onPressed: () async {
                bool result = await filterBottomSheet(context);
                print("Result : $result");
              })
        ],
      ),
      body: Container(
        height: height,
        width: width,
        child: FutureBuilder<dynamic>(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (listPOB != null && listPOB.length > 0) {
                return ListView.separated(
                  itemBuilder: _itemBuilder,
                  itemCount: listPOB.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      height: 1,
                    );
                  },
                );
              } else {
                return Center(
                  child: Text("Data not available"),
                );
              }
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  bool isLoadedItemAndCustomer = false;

  Future<dynamic> getData() async {
    print("${Constants_data.app_user}");

    listPOB = [];
    var dataUser;
    if (Constants_data.app_user == null) {
      dataUser = await StateManager.getLoginUser();
    } else {
      dataUser = Constants_data.app_user;
    }

    if (!isLoadedItemAndCustomer) {
      listCustomers = await DBProfessionalList.prformQueryOperation(
          "select distinct CustomerId, CustomerName from ProfessionalList where AccountType = 'Customer'", []);
      listCustomers = listCustomers.toSet().toList();

      listItems = await DBProfessionalList.prformQueryOperation("select * from tblItemsForPOBFilter", []);
      listItems = listItems.toSet().toList();
      isLoadedItemAndCustomer = true;
    }

    try {
      String url =
          "/GetDataForPOBReport?RepId=${dataUser["RepId"]}&monthYear=$monthYear&UserId=${dataUser["RepId"]}&CustomerId=${selectedCustomer == null ? "ALL" : selectedCustomer["CustomerId"].toString()}&item_code=${selectedItem == null ? "ALL" : selectedItem["item_code"].toString()}";
      dynamic data = await _helper.get(url);

      if (data["Status"].toString() == "1") {
        listPOB = data["dt_ReturnedTables"][0];
        isShowRate = data["ObjRetArgs"][0]["IsRateAvl"] == "Y" || data["ObjRetArgs"][0]["ManualRateInPOB"] == "Y";
        isShowDescription = data["ObjRetArgs"][0]["POBDescription"] == "Y";
      } else {
        listPOB = [];
      }
    } on Exception catch (err) {
      print("Error in getting POB : ${err.toString()}");
      listPOB = [];
      return null;
    }
  }

  Widget _itemBuilder(BuildContext context, int index) {
    Map<String, dynamic> data = listPOB[index];
    return ExpansionTile(
      onExpansionChanged: (val) {
        print("$index : $val");
      },
      title: Container(
          child: Column(children: [
        Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "${data["CustomerName"]}",
              style: Styles.h4.copyWith(color: themeData.accentColor),
            )),
        Container(
            margin: EdgeInsets.only(top: 5),
            child: Row(children: [
              Container(child: Text("${data["order_date"]}", style: Styles.caption2)),
              Expanded(child: Container()),
              isShowRate
                  ? Row(children: [
                      Container(alignment: Alignment.centerRight, child: Text("Total : ", style: Styles.subtitle2)),
                      Container(
                          alignment: Alignment.centerRight,
                          child: Text("${data["TotalAmount"]}", style: Styles.h4.copyWith(color: themeData.primaryColorLight)))
                    ])
                  : Container()
            ])),
      ])),
      children: [
        data["PaymentOption"] == null || data["PaymentOption"] == ""
            ? Container()
            : Container(
                margin: EdgeInsets.only(top: 7, bottom: 7, left: 15, right: 20),
                child: Row(children: [
                  Container(
                    child: Text(
                      "Payment Option : ",
                      style: Styles.caption1,
                    ),
                  ),
                  Container(alignment: Alignment.centerLeft, child: Text("${data["PaymentOption"]}", style: Styles.h4)),
                ])),
        data["Description"] == null || data["Description"] == "" || !isShowDescription
            ? Container()
            : Container(
                margin: EdgeInsets.only(top: 7, bottom: 7, left: 15, right: 20),
                child: Row(children: [
                  Container(
                    child: Text(
                      "Description : ",
                      style: Styles.caption1,
                    ),
                  ),
                  Container(alignment: Alignment.centerLeft, child: Text("${data["Description"]}", style: Styles.h4)),
                ])),
        for (var i in data["POBData"]) _childItemBuilder(i)
      ],
    );
  }

  _childItemBuilder(Map<String, dynamic> data) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0), border: Border.all(color: themeData.hintColor, width: 0.5), color: themeData.buttonColor),
        child: ListTile(
          title: Row(
            children: [
              Expanded(
                child: Container(
                  child: Text(
                    "${data["item_desc"]}",
                    style: Styles.h4.copyWith(color: themeData.primaryColorLight),
                  ),
                ),
              ),
              !isShowRate
                  ? Row(children: [
                      Container(
                        child: Text(
                          "Qty : ",
                          style: Styles.caption2,
                        ),
                      ),
                      Container(
                        child: Text(
                          "${data["qty"]}",
                          style: Styles.h5,
                        ),
                      ),
                      SizedBox(
                        width: 7,
                      )
                    ])
                  : Container(),
              Icon(
                data["ApprovalStatus"].toString().toLowerCase() == "approved"
                    ? Icons.check_circle_outline_outlined
                    : data["ApprovalStatus"].toString().toLowerCase() == "pending"
                        ? Icons.access_time_rounded
                        : Icons.highlight_remove_outlined,
                color: data["ApprovalStatus"].toString().toLowerCase() == "approved"
                    ? Colors.green
                    : data["ApprovalStatus"].toString().toLowerCase() == "pending"
                        ? Colors.orange
                        : Colors.red,
                size: 20,
              )
            ],
          ),
          subtitle: isShowRate
              ? Row(
                  children: [
                    Expanded(
                        child: Row(children: [
                      Container(
                        child: Text(
                          "Qty : ",
                          style: Styles.caption2,
                        ),
                      ),
                      Container(
                        child: Text(
                          "${data["qty"]}",
                          style: Styles.h5,
                        ),
                      )
                    ])),
                    Expanded(
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        child: Text(
                          "Rate : ",
                          style: Styles.caption2,
                        ),
                      ),
                      Container(
                        child: Text(
                          "${data["Rate"]}",
                          style: Styles.h5,
                        ),
                      )
                    ])),
                    Expanded(
                        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Container(
                        child: Text(
                          "Total : ",
                          style: Styles.caption2,
                        ),
                      ),
                      Container(
                        child: Text(
                          "${data["TotalPrice"]}",
                          style: Styles.h5,
                        ),
                      )
                    ])),
                  ],
                )
              : null,
        ));
  }

  dynamic selectedCustomer;
  dynamic selectedItem;
  String monthYear = Constants_data.dateToString(DateTime.now(), "MM-yyyy");

  List<dynamic> listCustomers;
  List<dynamic> listItems;

  filterBottomSheet(context) async {
    print("ListCustomers : $listCustomers");
    var selectedCustomer = this.selectedCustomer;
    var selectedItem = this.selectedItem;
    switch (await showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter state) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                        flex: 20,
                        child: Container(
                          child: Text(
                            "Date",
                            style: Styles.subtitle1,
                          ),
                        )),
                    Text(
                      " :  ",
                      style: Styles.subtitle1,
                    ),
                    Expanded(
                        flex: 80,
                        child: Container(
                            child: InkWell(
                                onTap: () async {
                                  await monthPicker(state);
                                },
                                child: Container(
                                  height: 40,
                                  margin: EdgeInsets.all(2),
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5), border: Border.all(width: 1, color: AppColors.grey_color)),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                          child: Text("${monthYear == null ? "Select Month-Year" : monthYear}",
                                              style: monthYear == null ? Styles.subtitle1 : Styles.h4)),
                                      Icon(
                                        Icons.date_range_outlined,
                                        color: AppColors.grey_color,
                                      )
                                    ],
                                  ),
                                ))))
                  ]),
                  SizedBox(
                    height: 10,
                  ),
                  Row(children: [
                    Expanded(
                        flex: 20,
                        child: Container(
                          child: Text(
                            "Customer",
                            style: Styles.subtitle1,
                          ),
                        )),
                    Text(
                      " :  ",
                      style: Styles.subtitle1,
                    ),
                    Expanded(
                        flex: 80,
                        child: DropdownButton<dynamic>(
                          hint: Text("Select Customer"),
                          isExpanded: true,
                          value: selectedCustomer,
                          onChanged: (newValue) {
                            print("Selected Customer : $newValue");
                            state(() {
                              selectedCustomer = newValue;
                            });
                          },
                          items: listCustomers.map((dynamic val) {
                            return DropdownMenuItem<dynamic>(
                              value: val,
                              child: Text(
                                val["CustomerName"],
                                style: Styles.h3.copyWith(color: themeData.primaryColorLight),
                              ),
                            );
                          }).toList(),
                        ))
                  ]),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 20,
                          child: Container(
                            child: Text(
                              "Item",
                              style: Styles.subtitle1,
                            ),
                          )),
                      Text(
                        " :  ",
                        style: Styles.subtitle1,
                      ),
                      Expanded(
                        flex: 80,
                        child: DropdownButton<dynamic>(
                          hint: Text("Select Item"),
                          value: selectedItem,
                          isExpanded: true,
                          onChanged: (newValue) {
                            print("Selected Item : $newValue");
                            state(() {
                              selectedItem = newValue;
                            });
                          },
                          items: listItems.map((dynamic val) {
                            return DropdownMenuItem<dynamic>(
                              value: val,
                              child: Text(
                                val["item_desc"],
                                style: Styles.h3.copyWith(color: themeData.primaryColorLight),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: MaterialButton(
                          color: themeData.accentColor,
                          onPressed: () {
                            this.setState(() {
                              this.selectedItem = null;
                              this.selectedCustomer = null;
                              monthYear = Constants_data.dateToString(DateTime.now(), "MM-yyyy");
                              selectedDate = DateTime.now();
                            });

                            Navigator.pop(context, 1);
                          },
                          child: Text(
                            "Clear",
                            style: TextStyle(color: themeData.primaryColor),
                          ),
                        ),
                      ),
                      Expanded(child: Container()),
                      Container(
                        alignment: Alignment.centerRight,
                        child: MaterialButton(
                          color: themeData.accentColor,
                          onPressed: () {
                            setState(() {
                              this.selectedItem = selectedItem;
                              this.selectedCustomer = selectedCustomer;
                            });
                            Navigator.pop(context, 0);
                          },
                          child: Text(
                            "Filter",
                            style: TextStyle(color: themeData.primaryColor),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            );
          });
        })) {
      case 0:
        return true;
        break;
      case 1:
        return false;
        break;
    }
  }

  DateTime selectedDate = DateTime.now();

  monthPicker(state) async {
    await showMonthPicker(
            context: context,
            firstDate: DateTime(DateTime.now().year - 5),
            lastDate: DateTime(DateTime.now().year, DateTime.now().month),
            initialDate: selectedDate)
        .then((date) {
      if (date != null) {
        state(() {
          selectedDate = date;
          monthYear = Constants_data.dateToString(date, "MM-yyyy");
        });
      }
    });
  }
}
