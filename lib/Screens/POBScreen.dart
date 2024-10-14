import 'dart:collection';
import 'dart:convert';
import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Constants/StateManager.dart';
import 'package:flexi_profiler/Constants/bottom_sheet.dart';
import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
import 'package:flexi_profiler/DBClasses/DBProfessionalList.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class POB_Screen extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<POB_Screen> {
  final currancy_format = new NumberFormat("#,##,##,##,###.##", "en_IN");
  final currancy_symbol = "TSh ";

  List<dynamic> productGroupData = [];
  bool isLoaded = false;
  ApiBaseHelper _helper = ApiBaseHelper();
  Map<String, dynamic> customerData;
  bool isLoading = false;
  List<TextEditingController> listController;
  dynamic selectedCustomer;
  List<dynamic> listCustomers;
  TextEditingController cntRemarks = new TextEditingController();
  DarkThemeProvider themeChange;
  ThemeData themeData;

  List<dynamic> configDetails = [];

  @override
  Widget build(BuildContext context) {
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    customerData = args.containsKey("CustomerId") ? args : null;
    print("Argument received : ${args}");
    return Scaffold(
        appBar: AppBar(
          flexibleSpace:
              Constants_data.getFlexibleAppBar(themeChange.darkTheme),
          title: new Text("POB Entry"),
          actions: [
            PopupMenuButton(
              onSelected: _select,
              padding: EdgeInsets.zero,
              // initialValue: choices[_selection],
              child: Row(
                children: [
                  Container(
                      alignment: Alignment.center,
                      child: Text(
                        selectedAccountName,
                        style: TextStyle(
                            color: AppColors.white_color,
                            fontWeight: FontWeight.bold),
                      )),
                  Icon(
                    Icons.more_vert,
                    color: AppColors.white_color,
                  ),
                ],
              ),
              itemBuilder: (BuildContext context) {
                return choices.map((dynamic choice) {
                  return PopupMenuItem<dynamic>(
                    value: choice,
                    child: Text(choice["name"]),
                  );
                }).toList();
              },
            )
          ],
        ),
        body: !isLoaded
            ? FutureBuilder<dynamic>(
                future: getData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Container(
                      padding: EdgeInsets.all(10),
                      child: getView(),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              )
            : Container(
                padding: EdgeInsets.all(10),
                child: getView(),
              ));
  }

  bool isShowRate = true;
  bool isShowDescription = true;
  bool isShowRateEntryEditText = false;
  bool isShowPaymentOption = true;

  List<dynamic> choices = <dynamic>[
    {"name": "Customer", "accout_id": "Customer"},
    {"name": "Hospital", "accout_id": "HCO"},
  ];
  String _selectedAccount = "Customer";
  String selectedAccountName = "Customer";

  void _select(dynamic choice) {
    setState(() {
      customerData = null;
      selectedCustomer = null;
      isLoaded = false;
      _selectedAccount = choice["accout_id"];
      selectedAccountName = "${choice["name"]}";
    });
    print("Selected Choice : $choice");
  }

  Future<Null> getData() async {
    productGroupData = [];
    var dataUser;
    if (Constants_data.app_user == null) {
      dataUser = await StateManager.getLoginUser();
    } else {
      dataUser = Constants_data.app_user;
    }

    configDetails = await DBProfessionalList.getConfigDetails();

    for (int i = 0; i < configDetails.length; i++) {
      print("ConfigDetails : ${jsonEncode(configDetails[i])}");
      if (configDetails[i]["Parameter_Code"] == "IsRateAvl" &&
          configDetails[i]["Parameter_Value"] == "N" &&
          configDetails[i]["is_active"] == "Y") {
        isShowRate = false;
      }

      if (configDetails[i]["Parameter_Code"] == "POBDescription" &&
          configDetails[i]["Parameter_Value"] == "N" &&
          configDetails[i]["is_active"] == "Y") {
        isShowDescription = false;
      }

      if (configDetails[i]["Parameter_Code"] == "ManualRateInPOB" &&
          configDetails[i]["Parameter_Value"] == "Y" &&
          configDetails[i]["is_active"] == "Y") {
        isShowRateEntryEditText = true;
      }

      if (configDetails[i]["Parameter_Code"] == "is_payment_option_pob" &&
          configDetails[i]["Parameter_Value"] == "N" &&
          configDetails[i]["is_active"] == "Y") {
        isShowPaymentOption = false;
      }
    }

    Map<String, List<dynamic>> response =
        await DBProfessionalList.getAttributes(
            "$_selectedAccount", false, null);
    listCustomers = response["data"].toSet().toList();

    try {
      String routeUrl = '/GetDataForCustomerPOB?RepId=${dataUser["Rep_Id"]}';
      var response = await _helper.get(routeUrl);
      productGroupData = response["dt_ReturnedTables"][0];
    } on Exception catch (err) {
      print("Error in GetDataForCustomerPOB : $err");
      //dataMain = [];
    }

    listController = [];

    for (int i = 0; i < productGroupData.length; i++) {
      productGroupData[i]["selected"] = "false";
      productGroupData[i]["fromDD"] = "true";
      productGroupData[i]["DDValue"] = null;
      productGroupData[i]["txtValue"] = "";
      productGroupData[i]["qty"] = 0;
      productGroupData[i]["total"] = 0;
      TextEditingController cnt = new TextEditingController();
      listController.add(cnt);
    }

    isLoaded = true;
  }

  List<dynamic> listPaymentOptions = [
    {"name": "Credit", "id": "1"},
    {"name": "Cash", "id": "2"}
  ];
  dynamic selectedPaymentOption;

  Widget getView() {
    double grandTotal = 0;
    bool isSingleSelected = false;
    for (int i = 0; i < productGroupData.length; i++) {
      grandTotal += productGroupData[i]["total"];
      if (!isSingleSelected && productGroupData[i]["selected"] == "true") {
        isSingleSelected = true;
      }
    }
    print("Length: ${productGroupData.length}");
    return Column(
      children: <Widget>[
        customerData == null
            ? DropdownButton<dynamic>(
                hint: Text("Select Customer"),
                value: selectedCustomer,
                isExpanded: true,
                onChanged: (newValue) {
                  setState(() {
                    selectedCustomer = newValue;
                  });
                },
                items: listCustomers.map((dynamic lang) {
                  return DropdownMenuItem<dynamic>(
                    value: lang,
                    child: Text(lang["CustomerName"]),
                  );
                }).toList(),
              )
            : Column(
                children: [
                  Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Customer Name",
                        style: TextStyle(
                            fontSize: 13, color: AppColors.main_color),
                      )),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "${customerData["CustomerName"]}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                "Product Group",
                style: TextStyle(
                    color: Theme.of(context).textTheme.caption.color,
                    fontWeight: FontWeight.bold),
              ),
            ),
            MaterialButton(
              onPressed: () async {
                await showSampleProductList();
                this.setState(() {});
              },
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: AppColors.main_color,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(50)),
              child: Text(
                "Select Product",
                style: TextStyle(color: AppColors.main_color),
              ),
            )
          ],
        ),
        Expanded(
          child: !isSingleSelected
              ? Center(
                  child: Text(
                  "You don't have any selected product",
                  style: TextStyle(color: AppColors.grey_color),
                ))
              : ListView(
                  children: <Widget>[
                    getProductGroupDetails(),
                  ],
                ),
        ),
        isShowPaymentOption
            ? Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: DropdownButton<dynamic>(
                  hint: Text("Select Payment Option"),
                  value: selectedPaymentOption,
                  isExpanded: true,
                  onChanged: (newValue) {
                    print("selectedPaymentOption : ${newValue}");
                    setState(() {
                      selectedPaymentOption = newValue;
                    });
                  },
                  items: listPaymentOptions.map((dynamic lang) {
                    return DropdownMenuItem<dynamic>(
                      value: lang,
                      child: Text(
                        lang["name"],
                      ),
                    );
                  }).toList(),
                ))
            : Container(),
        isShowDescription
            ? Container(
                margin: EdgeInsets.only(bottom: 5, top: 5),
                child: TextFormField(
                  controller: cntRemarks,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: new InputDecoration(
                    alignLabelWithHint: true,
                    hintText: 'Remarks',
                    labelText: "Remarks",
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: themeData.accentColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.all(10),
                    //fillColor: Color(0xFFEEEEEE),
                  ),
                  maxLines: 2,
                ),
              )
            : Container(),
        Row(
          children: [
            Expanded(
                child: isShowRate || isShowRateEntryEditText
                    ? Text.rich(
                        TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Grand Total : ',
                                style: TextStyle(
                                    fontSize: Constants_data.getFontSize(
                                        context, 14))),
                            TextSpan(
                                text: ' $currancy_symbol' +
                                    '${currancy_format.format(grandTotal)}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.main_color,
                                    fontSize: Constants_data.getFontSize(
                                        context, 18))),
                          ],
                        ),
                      )
                    : Container()),
            Container(
              height: Constants_data.getHeight(context, 35),
              child: MaterialButton(
                onPressed: () async {
                  bool isSingleSelected = false;

                  if (customerData == null && selectedCustomer == null) {
                    Constants_data.toastError("Please select Customer");
                    return;
                  }

                  for (int i = 0; i < productGroupData.length; i++) {
                    if (productGroupData[i]["selected"] == "true" &&
                        (productGroupData[i]["qty"] == "" ||
                            productGroupData[i]["qty"] == 0)) {
                      Constants_data.toastError("Quantity can't be zero");
                      return;
                    }
                    if (productGroupData[i]["selected"] == "true") {
                      isSingleSelected = true;
                    }
                  }

                  if (!isSingleSelected) {
                    Constants_data.toastError(
                        "Please add at least one product");
                    return;
                  }
                  if (isShowPaymentOption && selectedPaymentOption == null) {
                    Constants_data.toastError("Please select payment method");
                    return;
                  }

                  List<dynamic> listSelected = [];
                  String date = Constants_data.dateToString(
                      new DateTime.now(), "yyyy-MM-dd");
                  for (int i = 0; i < productGroupData.length; i++) {
                    if (productGroupData[i]["selected"] == "true") {
                      Map<String, dynamic> map = new HashMap();
                      map["ItemCode"] = productGroupData[i]["item_code"];
                      map["Qty"] = productGroupData[i]["qty"];
                      map["nsp_rate"] = productGroupData[i]["item_price"];
                      map["total_price"] =
                          double.parse(productGroupData[i]["total"].toString())
                              .toStringAsFixed(2);
                      listSelected.add(map);
                    }
                  }
                  this.setState(() {
                    isLoading = true;
                  });
                  Map<String, dynamic> mainRequestJson = new HashMap();
                  mainRequestJson["POBData"] = listSelected;
                  mainRequestJson["CustomerId"] =
                      "${customerData == null ? selectedCustomer["CustomerId"] : customerData["CustomerId"]}";
                  mainRequestJson["AccountType"] = _selectedAccount;
                  mainRequestJson["OrderDate"] = date;
                  mainRequestJson["POBDesc"] =
                      isShowDescription ? cntRemarks.text : "";
                  if (isShowPaymentOption) {
                    mainRequestJson["PaymentOption"] =
                        selectedPaymentOption["name"];
                  }

                  print("Main Request Json : ${jsonEncode(mainRequestJson)}");
                  try {
                    String url =
                        "/SaveCustomerPOB?RepId=${Constants_data.repId}";
                    var data = await _helper.post(url, mainRequestJson, true);
                    if (data["Status"] == 1) {
                      Constants_data.toastNormal(data["Message"].toString());
                      for (int i = 0; i < productGroupData.length; i++) {
                        productGroupData[i]["selected"] = "false";
                        productGroupData[i]["qty"] = 0;
                        productGroupData[i]["total"] = 0;
                        cntRemarks.text = "";
                      }
                    } else {
                      Constants_data.toastError("Error in saving data");
                    }
                    this.setState(() {
                      isLoading = false;
                    });
                  } on Exception catch (err) {
                    print("Error in ");
                  }
                },
                color: AppColors.main_color,
                child: isLoading
                    ? Center(
                        child: Container(
                          width: Constants_data.getWidth(context, 25),
                          height: Constants_data.getHeight(context, 25),
                          child: CircularProgressIndicator(
                              backgroundColor: AppColors.white_color,
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  AppColors.black_color87)),
                        ),
                      )
                    : Text(
                        "Save",
                        style: TextStyle(color: AppColors.white_color),
                      ),
              ),
            )
          ],
        ),
      ],
    );
//    return;
  }

  Widget getProductGroupDetails() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 7),
        child: Column(
          children: getProductGroupColumns(),
        ));
  }

  List<Widget> getProductGroupColumns() {
    List<Widget> listCols = [];

    for (int i = 0; i < productGroupData.length; i++) {
      listController[i].text = productGroupData[i]["qty"].toString();
      TextEditingController cntPrice = new TextEditingController();
      cntPrice.text = productGroupData[i]["item_price"].toString();
      if (productGroupData[i]["selected"] == "true") {
        TextEditingController cnt = listController[i];
        listController[i].selection =
            TextSelection.fromPosition(TextPosition(offset: cnt.text.length));
        cntPrice.selection = TextSelection.fromPosition(
            TextPosition(offset: cntPrice.text.length));

        listCols.add(Stack(
          clipBehavior: Clip.none, children: <Widget>[
            Card(
              elevation: 5.0,
              margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                              flex: 15,
                              child: Container(
                                margin: EdgeInsets.all(5),
                                child: Text(
                                  "${productGroupData[i]["item_name"]}",
                                  style: TextStyle(
                                      fontSize: Constants_data.getFontSize(
                                          context, 15)),
                                ),
                              ))
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                              flex: isShowRate ? 5 : 16,
                              child: Container(
                                margin: EdgeInsets.all(5),
                                child: Text(
                                  "${productGroupData[i]["item_desc"] == null ? "N/A" : productGroupData[i]["item_desc"]}",
                                  style: TextStyle(
                                      color: AppColors.grey_color,
                                      fontSize: Constants_data.getFontSize(
                                          context, 13)),
                                ),
                              )),
                          !isShowRate && !isShowRateEntryEditText
                              ? Expanded(
                                  flex: 4,
                                  child: Container(
                                      height:
                                          Constants_data.getHeight(context, 25),
                                      margin:
                                          EdgeInsets.only(left: 10, right: 5),
                                      child: TextField(
                                        controller: cnt,
                                        maxLength: 5,
                                        onChanged: (val) {
                                          this.setState(() {
                                            int value =
                                                val == "" ? 0 : int.parse(val);
                                            productGroupData[i]["qty"] = value;
                                            productGroupData[i]["total"] =
                                                value *
                                                    productGroupData[i]
                                                        ["item_price"];
                                          });
                                        },
                                        style: new TextStyle(fontSize: 15.0),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9]')),
                                        ],
                                        decoration: new InputDecoration(
                                            counterText: "",
                                            contentPadding:
                                                EdgeInsets.only(bottom: 12),
                                            hintText: "Qty",
                                            hintStyle: new TextStyle(
                                                color: AppColors.grey_color)),
                                      )))
                              : Container(),
                        ],
                      ),
                      isShowRate || isShowRateEntryEditText
                          ? Row(
                              children: <Widget>[
                                isShowRateEntryEditText
                                    ? Expanded(
                                        flex: 16,
                                        child: Row(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(left: 5),
                                              child: Text(
                                                "Price : ",
                                                style: TextStyle(
                                                    color: AppColors.grey_color,
                                                    fontSize: Constants_data
                                                        .getFontSize(
                                                            context, 13)),
                                              ),
                                            ),
                                            Container(
                                              width: 50,
                                              height: Constants_data.getHeight(
                                                  context, 25),
                                              margin: EdgeInsets.only(
                                                  left: 5, right: 5),
                                              child: TextField(
                                                controller: cntPrice,
                                                onChanged: (val) {
                                                  this.setState(() {
                                                    int value = val == ""
                                                        ? 0
                                                        : int.parse(val);
                                                    productGroupData[i]
                                                        ["item_price"] = value;
                                                    productGroupData[i]
                                                            ["total"] =
                                                        value *
                                                            productGroupData[i]
                                                                ["qty"];
                                                    print(
                                                        "Total : ${productGroupData[i]["total"]}");
                                                  });
                                                },
                                                style: new TextStyle(
                                                    fontSize: 15.0),
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: <
                                                    TextInputFormatter>[
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(r'[0-9]')),
                                                ],
                                                decoration: new InputDecoration(
                                                    counterText: "",
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            bottom: 12),
                                                    hintText: "Qty",
                                                    hintStyle: new TextStyle(
                                                        color: AppColors
                                                            .grey_color)),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                child: Text(
                                                  "  x  ${productGroupData[i]["qty"]}  =  " +
                                                      "${currancy_format.format(productGroupData[i]["total"])}",
                                                  style: TextStyle(
                                                      color:
                                                          AppColors.grey_color,
                                                      fontSize: Constants_data
                                                          .getFontSize(
                                                              context, 13)),
                                                ),
                                              ),
                                            )
                                          ],
                                        ))
                                    : Expanded(
                                        flex: 16,
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              left: 5, right: 5),
                                          child: Text(
                                            "$currancy_symbol" +
                                                "${currancy_format.format(productGroupData[i]["item_price"])}  x  ${productGroupData[i]["qty"]}  =  " +
                                                "$currancy_symbol" +
                                                "${currancy_format.format(productGroupData[i]["total"])}",
                                            style: TextStyle(
                                                color: AppColors.grey_color,
                                                fontSize:
                                                    Constants_data.getFontSize(
                                                        context, 13)),
                                          ),
                                        )),
                                Expanded(
                                    flex: 4,
                                    child: Container(
                                        height: Constants_data.getHeight(
                                            context, 25),
                                        margin:
                                            EdgeInsets.only(left: 10, right: 5),
                                        child: TextField(
                                          controller: cnt,
                                          maxLength: 5,
                                          onChanged: (val) {
                                            this.setState(() {
                                              int value = val == ""
                                                  ? 0
                                                  : int.parse(val);
                                              productGroupData[i]["qty"] =
                                                  value;
                                              productGroupData[i]["total"] =
                                                  value *
                                                      productGroupData[i]
                                                          ["item_price"];
                                            });
                                          },
                                          style: new TextStyle(fontSize: 15.0),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9]')),
                                          ],
                                          decoration: new InputDecoration(
                                              counterText: "",
                                              contentPadding:
                                                  EdgeInsets.only(bottom: 12),
                                              hintText: "Qty",
                                              hintStyle: new TextStyle(
                                                  color: AppColors.grey_color)),
                                        ))),
                              ],
                            )
                          : Container()
                    ],
                  )),
            ),
            Positioned(
              top: -3,
              right: -3,
              child: InkWell(
                  onTap: () {
                    if (isLoading) {
                      Constants_data.toastError("Please wait...");
                    } else {
                      this.setState(() {
                        productGroupData[i]["selected"] = "false";
                        productGroupData[i]["qty"] = 0;
                        productGroupData[i]["total"] = 0;
                      });
                    }
                  },
                  child: Icon(
                    Icons.remove_circle,
                    color: AppColors.red_color,
                  )),
            )
          ],
        ));
      }
    }

    return listCols;
  }

  showSampleProductList() async {
    await showModalBottomSheet1(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter state) {
            return Container(
              height: 300,
              color: Theme.of(context).cardColor,
              child: Column(
                children: <Widget>[
                  new Stack(
                    children: <Widget>[
                      new Positioned(
                        child: new Align(
                          child: Container(
                              margin: EdgeInsets.only(top: 15),
                              child: new Text("Select Product",
                                  style: TextStyle(
                                      fontSize: Constants_data.getFontSize(
                                          context, 14)))),
                          alignment: Alignment.center,
                        ),
                      ),
                      new Positioned(
                          child: new Align(
                        child: MaterialButton(
                          onPressed: () {
                            //resetRequestData(jsonTemplate);
                            Navigator.pop(context);
                          },
                          child: new Text(
                            "Done",
                            style: TextStyle(
                                color: AppColors.main_color,
                                fontSize:
                                    Constants_data.getFontSize(context, 14)),
                          ),
                        ),
                        alignment: Alignment.centerRight,
                      )),
                    ],
                  ),
                  Expanded(
                      child: ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () {
                            state(() {
                              productGroupData[index]["selected"] =
                                  productGroupData[index]["selected"] == "true"
                                      ? "false"
                                      : "true";
                            });
                          },
                          child: Container(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    child: Container(
                                        height: 40,
                                        child: Text(
                                          "${productGroupData[index]["item_name"]}",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .color,
                                              fontSize:
                                                  Constants_data.getFontSize(
                                                      context, 14)),
                                        ))),
                                productGroupData[index]["selected"] == "true"
                                    ? Icon(Icons.check_box,
                                        color: AppColors.main_color)
                                    : Container()
                              ],
                            ),
                          ));
                    },
                    itemCount: productGroupData.length,
                  ))
                ],
              ),
            );
          });
        });
  }
}
