import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Constants/StateManager.dart';
import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:uuid/uuid.dart';

class AllowanceScreen extends StatefulWidget {
  @override
  _AllowanceScreenState createState() => _AllowanceScreenState();
}

class _AllowanceScreenState extends State<AllowanceScreen> {
  bool isSubmited = false;
  ApiBaseHelper _helper = ApiBaseHelper();

  @override
  void initState() {
    super.initState();
    Constants_data.date_selected = "11-2019";
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  BoxDecoration decoration = BoxDecoration(
    border: Border.all(width: 0.2, color: Color(0xFFFFAAAAAA)),
  );

  BoxDecoration decorationHeader = BoxDecoration(
    color: AppColors.main_color,
    border: Border.all(width: 0.3, color: Color(0xFFFFBBBBBB)),
  );

  BoxDecoration decorationFooter = BoxDecoration(
    color: Colors.blueAccent,
    border: Border.all(width: 0.3, color: Color(0xFFFFBBBBBB)),
  );

  int selected = 0;

  final Map<int, Widget> dt = <int, Widget>{
    0: new Container(padding: EdgeInsets.all(5), child: Text("Daily")),
    1: new Container(padding: EdgeInsets.all(5), child: Text("Monthly")),
  };
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    Constants_data.currentScreenContext = context;
    return Scaffold(
      backgroundColor: AppColors.white_color,
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 40),
        child: Container(
          decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 5, blurRadius: 2)]),
          width: MediaQuery.of(context).size.width,
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white_color,
            ),
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // InkWell(
                      //     onTap: () {
                      //       Navigator.pop(context);
                      //     },
                      //     child: Container(
                      //         padding: EdgeInsets.all(10),
                      //         child: Icon(
                      //           PlatformIcons(context).back,
                      //           color: AppColors.main_color,
                      //         ))
                      // ),
                      new GestureDetector(
                          onTap: () {
                            print("Tap Calander");
                            // showMonthPicker(
                            //         context: context,
                            //         firstDate: DateTime(DateTime.now().year),
                            //         lastDate: DateTime(DateTime.now().year, 12),
                            //         initialDate: DateTime.now())
                            //     .then((date) {
                            //   if (date != null) {
                            //     print(date);
                            //     DateFormat dateFormat = DateFormat("MM-yyyy");
                            //     selected = 0;
                            //     this.setState(() {
                            //       Constants_data.date_selected = dateFormat.format(date);
                            //     });
                            //     print("SELECTED DATE: ${Constants_data.date_selected}");
                            //   }
                            // });
                          },
                          child: new Container(
                              padding: EdgeInsets.only(top: 5, bottom: 5, left: 15),
                              child: new Row(
                                children: <Widget>[
                                  new Text("Allowance of "),
                                  new Text(
                                    getMonthString(),
                                    style: TextStyle(color: AppColors.main_color, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )))
                    ],
                  ),
                  new Row(
                    children: <Widget>[
                      CupertinoSegmentedControl<int>(
                        unselectedColor: themeData.primaryColor,
                        selectedColor: themeData.accentColor,
                        borderColor: Colors.grey,
                        children: dt,
                        onValueChanged: (int val) {
                          print("Selected: ${val}");
                          selected = val;
                          this.setState(() {});
                        },
                        groupValue: selected,
                      ),
                      new Container(
                          margin: EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(),
//                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            color: AppColors.black_color87,
                          ),
                          height: 30,
                          width: 90,
                          child: new GestureDetector(
                              onTap: () {
                                if (!isSubmited) {
                                  submitData("Y");
                                } else {
                                  isSubmited = true;
                                  Fluttertoast.showToast(
                                      msg: "Data already Submitted",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      backgroundColor: AppColors.red_color,
                                      textColor: AppColors.white_color,
                                      fontSize: 16.0);
                                }
                                ;
                              },
                              child: new Align(
                                alignment: Alignment.center,
                                child: new Text(
                                  "SUBMIT",
                                  style: TextStyle(color: AppColors.white_color),
                                ),
                              )))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: selected == 1
          ? getMonthlyViewScreen()
          : FutureBuilder<dynamic>(
              future: getData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data != null && snapshot.data.length > 0) {
                    return new Column(
                      children: <Widget>[
                        getHeaderRow(),
                        new Expanded(
                            child: new SingleChildScrollView(
                          child: new Column(
                            children: getTableView(),
                          ),
                        )),
                        getFooter(),
                      ],
                    );
                  } else if (snapshot.data == null) {
                    return Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Container(
                          margin: EdgeInsets.only(top: 10),
                          child: new Text("DATA LOADING ERROR"),
                        )
                      ],
                    ));
                  } else {
                    return Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Container(
                          margin: EdgeInsets.only(top: 10),
                          child: new Text("Empty list"),
                        )
                      ],
                    ));
                  }
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(),
                          new Container(
                            margin: EdgeInsets.only(top: 10),
                            child: new Text("Loading..."),
                          )
                        ],
                      ));
                } else {
                  return Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Container(
                        margin: EdgeInsets.only(top: 10),
                        child: new Text("Data loading error"),
                      )
                    ],
                  ));
                }
              }),
    );
  }

  getMonthlyViewScreen() {
    getExpenseRows();
    return new Column(
      children: <Widget>[
        new Expanded(
            child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Expanded(
                flex: 1,
                child: new Container(
                    padding: EdgeInsets.all(10),
                    child: new Column(
                      children: <Widget>[
                        new Container(
                          padding: EdgeInsets.all(5),
                          child: new Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 7,
                                  child: new Text(
                                    "Expense Name",
                                    style: TextStyle(
                                        color: AppColors.main_color, fontWeight: FontWeight.bold, fontSize: 15),
                                  )),
                              new Expanded(
                                  flex: 3,
                                  child: new Text("Fare (Rs)",
                                      style: TextStyle(
                                          color: AppColors.main_color, fontWeight: FontWeight.bold, fontSize: 15))),
                            ],
                          ),
                        ),
                        new Expanded(
                            child: new SingleChildScrollView(
                          child: new Column(
                            children: getListRow(),
                          ),
                        )),
                      ],
                    ))),
            Expanded(
                flex: 1,
                child: new Container(
                    padding: EdgeInsets.all(10),
                    child: new Column(
                      children: <Widget>[
                        new Container(
                          child: new Row(
                            children: <Widget>[
                              ElevatedButton.icon(
                                onPressed: () {
//                                  getImage();
                                  if (data_parent["is_submitted"] == 'Y') {
                                  } else {
                                    int temp_pos;
                                    Constants_data.temp_sel_exp_type = temp_pos;
                                    openDropdwnDialog();
                                  }
                                },
                                icon: Icon(
                                  Icons.add,
                                  color: AppColors.white_color,
                                ),
                                label: new Text(
                                  "ADD RECEIPT",
                                  style: TextStyle(
                                    color: AppColors.white_color,
                                  ),
                                ),
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(data_parent["is_submitted"] == 'Y' ? Color(0xFFE0E0E0) : Colors.blueAccent,),),
                              ),
                            ],
                          ),
                        ),
                        getGridView(),
                      ],
                    ))),
          ],
        )),
        getFooter(),
      ],
    );
  }

  getListRow() {
    List<Widget> rows = [];
//    String dt = jsonEncode(listRow);
    rows = listRow;
    rows.add(new Container(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ElevatedButton.icon(
            onPressed: () {
              if (data_parent["is_submitted"] == 'Y') {
              } else {
                addExp();
              }
            },
            icon: Icon(
              Icons.add,
              color: AppColors.white_color,
            ),
            label: new Text(
              "ADD NEW",
              style: TextStyle(
                color: AppColors.white_color,
              ),
            ),
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(data_parent["is_submitted"] == 'Y' ? Color(0xFFE0E0E0) : Colors.blueAccent,),),
            // color: data_parent["is_submitted"] == 'Y' ? Color(0xFFE0E0E0) : Colors.blueAccent,
          ),
          MaterialButton(
            onPressed: () {
              if (Constants_data.check_save) {
                submitData("N");
              }
            },
            child: new Text(
              "SAVE CHANGES",
              style: TextStyle(
                color: AppColors.white_color,
              ),
            ),
            color: Constants_data.check_save ? Colors.blueAccent : Color(0xFFE0E0E0),
          ),
        ],
      ),
    ));

    return rows;
  }

  List<dynamic> listImage;

  getGridView() {
    return new Expanded(
        child: new GridView.count(
      crossAxisCount: 3,
      children: List.generate(listImage.length, (index) {
        return new Stack(
          clipBehavior: Clip.none, children: <Widget>[
            new Container(
                margin: EdgeInsets.all(5),
                child: new Stack(children: <Widget>[
                  new Container(
                    child: Image.network("${ImgUrlThumb + listImage[index]["image"]}.jpeg"),
                    padding: EdgeInsets.all(5),
                  ),
                  new Align(
                      alignment: Alignment.bottomCenter,
                      child: new Container(
                          color: AppColors.black_color26,
                          height: 20,
                          width: double.infinity,
                          child: new Align(
                              alignment: Alignment.center,
                              child: new Text(
                                listImage[index]["allowance_name"],
                                style:
                                    TextStyle(fontSize: 12, color: AppColors.white_color, fontStyle: FontStyle.normal),
                              )))),
                  new Container(
                      color: AppColors.black_color26,
                      width: double.infinity,
                      child: new Align(
                        alignment: Alignment.topRight,
                        child: new Container(),
                      ))
                ])),
            !isSubmited
                ? Positioned(
                    top: -5,
                    bottom: 1,
                    left: 1,
                    right: -5,
                    child: new Container(
                        margin: EdgeInsets.all(5),
                        width: double.infinity,
                        child: new Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                            child: Image.asset(
                              'assets/images/ic_delete.png',
                              width: 20,
                              height: 20,
                            ),
                            onTap: () {
                              showAlertDialog(context, listImage[index]["image_id"], index);
                            },
                          ),
                        )))
                : new Container()
          ],
        );
      }),
    ));
  }

  InputDecoration getDecoration(String hint) {
    return InputDecoration(
      filled: true,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(width: 2, color: Colors.green),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(width: 2, color: Colors.blueGrey),
      ),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(
            width: 2,
          )),
      hintText: hint,
      hintStyle: TextStyle(fontSize: 16, color: Color(0xFFB3B1B1)),
    );
  }

  void addExp() {
    TextEditingController expenseName = TextEditingController();
    TextEditingController expPrice = TextEditingController();

    showGeneralDialog(
        context: context,
        barrierColor: Colors.black12.withOpacity(0.01),
        barrierDismissible: false,
        barrierLabel: "Dialog",
        transitionDuration: Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) {
          return Material(
              color: Colors.black12.withOpacity(0.5),
              child: SizedBox.expand(
                  child: Align(
                      alignment: Alignment.center,
                      child: new Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: AppColors.white_color,
                        ),
                        padding: EdgeInsets.all(10),
                        height: 190,
                        width: MediaQuery.of(context).size.width - 100,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Text(
                              "Please add new expense.",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            new Container(
                              margin: EdgeInsets.all(10),
                              child: new Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 7,
                                    child: new Container(
                                      padding: EdgeInsets.all(5),
                                      child: new TextField(
                                        keyboardType: TextInputType.text,
                                        controller: expenseName,
                                        enabled: true,
                                        decoration: getDecoration("Expense name"),
                                        obscureText: false,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: new Container(
                                      padding: EdgeInsets.all(5),
                                      child: new TextField(
                                        keyboardType: TextInputType.number,
                                        controller: expPrice,
                                        enabled: true,
                                        decoration: getDecoration("000.00"),
                                        obscureText: false,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            new Container(
                              margin: EdgeInsets.all(10),
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: new Container(
                                      padding: EdgeInsets.all(5),
                                      child: new Text(
                                        "CANCEL",
                                        style: TextStyle(
                                            color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (expenseName.text.trim() != "") {
                                        //TODO: ADD NEW FARE
                                        Map<String, String> newDt = {
                                          "allowance_id": "A00" + data_monthly.length.toString(),
                                          "allowance_type": expenseName.text,
                                          "fare": expPrice.text.trim() == "" ? "0" : expPrice.text.trim()
                                        };
                                        data_monthly.add(newDt);

                                        this.setState(() {
                                          Constants_data.check_save = true;
                                        });
                                        Navigator.pop(context);
                                      } else {
                                        Constants_data.toastError("Expense name can't be blank");
                                      }
                                    },
                                    child: new Container(
                                      padding: EdgeInsets.all(5),
                                      child: new Text(
                                        "ADD",
                                        style: TextStyle(
                                            color: Colors.lightBlue, fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ))));
        });
  }

  File _image;

  Future getImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);

    final bytes = await image.readAsBytes();
    String img64 = base64Encode(bytes);

    print("-------------- Base64Stirng: ${img64}");

    await uploadPhoto(img64);

    setState(() {
      _image = image as File;
    });
  }

  uploadPhoto(String img64) async {
    Map<String, String> headers = {"Content-type": "application/json"};
    var uuid = Uuid();
    var date = new DateTime.now();
    Map<String, String> arg = new HashMap();
    arg["monthYear"] = Constants_data.date_selected;
    arg["expense_doc_no"] = expense_doc_no == null ? "" : expense_doc_no;
    arg["allowance_id"] = Constants_data.exp_id_Sel;
    arg["allowance_name"] = Constants_data.exp_type_Sel;
    arg["base64_image"] = img64;
    arg["filename"] = "${Constants_data.dateToString(date, "yyyyMMddHHmmss")}";

    var dataUser;

    if (Constants_data.app_user == null) {
      dataUser = await StateManager.getLoginUser();
    } else {
      dataUser = Constants_data.app_user;
    }

    Map<String, dynamic> arg_final = new HashMap();
    arg_final["RepId"] = dataUser["Rep_Id"].toString();
    arg_final["obj"] = arg;

    try {
      var data = await _helper.post("/UploadExpenseDocument", arg_final, true);
      setState(() {
        listImage.add(data["dt_ReturnedTables"][0][0]);
      });
    } on Exception catch (err) {
      print("Error in ");
    }
  }

  deletePhoto(String image_id, int index) async {
    Map<String, String> headers = {"Content-type": "application/json"};
    var dataUser;
    if (Constants_data.app_user == null) {
      dataUser = await StateManager.getLoginUser();
    } else {
      dataUser = Constants_data.app_user;
    }
    var response = await http.delete(
        Uri.parse("${Constants_data.baseUrl}/DeleteExpenseDocument?RepId=${dataUser["Rep_Id"]}&image_id=${image_id}"),
        headers: headers);

    var data = jsonDecode(response.body);
    print("Passed Param = ${data}");
    listImage.remove(listImage[index]);
    setState(() {
      //expense_document.remove(index);
      print("Passed Param = ${listImage}");
    });
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await ImagePicker().retrieveLostData();
    if (response == null) {
      return;
    }
    if (response.file != null) {
      setState(() {
        if (response.type == RetrieveType.video) {
          print("------------------- Its a Video: ${response.file}");
        } else if (response.type == RetrieveType.image) {
          print("------------------- Its a Image: ${response.file}");
        } else {
          print("------------------- Its a Other File: ${response.file}");
        }
      });
    } else {
      print("------------------- Its a Null");
    }
  }

  List<TextEditingController> listController = [];
  List<Widget> listRow = [];

  getExpenseRows() {
    listRow = [];
    listController = [];
    for (int i = 0; i < data_monthly.length; i++) {
      TextEditingController cnt = new TextEditingController();
      cnt.text = data_monthly[i]["fare"];
      listController.add(cnt);
      print("--------------- Data Monthly: ${listController[listController.length - 1].text}");
      listRow.add(new Container(
          padding: EdgeInsets.all(5),
          child: new Row(
            children: <Widget>[
              new Expanded(
                  flex: 7,
                  child: new Text(
                    data_monthly[i]["allowance_type"],
                    style: TextStyle(color: Colors.black45, fontWeight: FontWeight.bold, fontSize: 15),
                  )),
              new Expanded(
                  flex: 3,
                  child: new Container(
                      height: 30,
                      child: new TextFormField(
                        enabled: !isSubmited,
                        controller: listController[i],
                        onChanged: (val) {
                          //setState(() {
                          data_monthly[i]["fare"] = val;
                          print("------------- Value: ${val}");
                          Constants_data.check_save = true;
//                          });
                        },
                        onEditingComplete: () {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            data_monthly[i]["fare"] = listController[i].text;
                            //print("------------- Value: ${val}");
                            Constants_data.check_save = true;
                          });
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(5),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                              borderSide: BorderSide(
                                width: 1,
                              )),
                          hintText: "000.00",
                          hintStyle: TextStyle(fontSize: 16, color: Color(0xFFB3B1B1)),
                        ),
                        keyboardType: TextInputType.number,
                      ))),
            ],
          )));
    }

    return listRow;
  }

  List<dynamic> listMain;
  List<dynamic> data_monthly;
  var data_parent;
  List<dynamic> expense_document;
  var ImgUrl = "";
  var ImgUrlThumb = "";
  var newDt;
  var expense_doc_no, month_year, total_exp, total_daily_exp, total_monthly_exp, total_km, total_fare, total_wa;

  //TODO: GetMainData
  Future<dynamic> getData() async {
    var dataUser;
    if (Constants_data.app_user == null) {
      dataUser = await StateManager.getLoginUser();
    } else {
      dataUser = Constants_data.app_user;
    }

    try {
      String url = "/GetAllowanceClaimDetail?RepId=${dataUser["Rep_Id"]}&monthYear=${Constants_data.date_selected}";
      dynamic data = await _helper.get(url);

      ImgUrlThumb = data["dt_ReturnedTables"][0][0]["img_url_thumb"];
      ImgUrl = data["dt_ReturnedTables"][0][0]["img_url"];
      listMain = data["dt_ReturnedTables"][0][0]["data_daily"];

      expense_doc_no = data["dt_ReturnedTables"][0][0]["expense_doc_no"];
      //month_year = "12-2019";
      total_exp = data["dt_ReturnedTables"][0][0]["total_exp"];
      total_daily_exp = data["dt_ReturnedTables"][0][0]["total_daily_exp"];
      total_monthly_exp = data["dt_ReturnedTables"][0][0]["total_monthly_exp"];
      total_km = data["dt_ReturnedTables"][0][0]["total_km"];
      total_fare = data["dt_ReturnedTables"][0][0]["total_fare"];
      total_wa = data["dt_ReturnedTables"][0][0]["total_wa"];

      data_monthly = data["dt_ReturnedTables"][0][0]["data_monthly"];
      data_parent = data["dt_ReturnedTables"][0][0];
      isSubmited = data_parent["is_submitted"] == 'Y';
      expense_document = data["dt_ReturnedTables"][0][0]["expense_document"];
      newDt = data["dt_ReturnedTables"][0][0];
      listImage = expense_document;
      if (isSubmited) {
        Constants_data.check_save = false;
      }
      print("Print list: ${listMain}");

      print("isSubmit: ${data_parent["is_submitted"]}");

      return data["dt_ReturnedTables"][0][0];
    } on Exception catch (err) {
      return null;
    }
  }

  static double header_text_size = 12.0;
  static double data_text_size = 12.0;

  TextStyle header = TextStyle(
    fontWeight: FontWeight.bold,
    color: AppColors.white_color,
    fontSize: header_text_size,
  );

  getHeaderRow() {
    return new Row(
      children: <Widget>[
        new Expanded(
            flex: 2,
            child: new Container(
              decoration: decorationHeader,
              height: 35,
              child: new Center(
                child: new Text(
                  "Date",
                  style: header,
                ),
              ),
            )),
        new Expanded(
            flex: 1,
            child: new Container(
              decoration: decorationHeader,
              height: 35,
              child: new Center(
                child: new Text(
                  "Day",
                  style: header,
                ),
              ),
            )),
        new Expanded(
            flex: 3,
            child: new Container(
              decoration: decorationHeader,
              height: 35,
              child: new Center(
                child: new Text(
                  "Route",
                  style: header,
                ),
              ),
            )),
        new Expanded(
            flex: 2,
            child: new Container(
              decoration: decorationHeader,
              height: 35,
              child: new Center(
                child: new Text(
                  "Allowance Type",
                  style: header,
                ),
              ),
            )),
        new Expanded(
            flex: 1,
            child: new Container(
              decoration: decorationHeader,
              height: 35,
              child: new Center(
                child: new Text(
                  "Distance",
                  style: header,
                ),
              ),
            )),
        new Expanded(
            flex: 1,
            child: new Container(
              decoration: decorationHeader,
              height: 35,
              child: new Center(
                child: new Text(
                  "Fare",
                  style: header,
                ),
              ),
            )),
        new Expanded(
            flex: 1,
            child: new Container(
              decoration: decorationHeader,
              height: 35,
              child: new Center(
                child: new Text(
                  "WA",
                  style: header,
                ),
              ),
            )),
        new Expanded(
            flex: 1,
            child: new Container(
              decoration: decorationHeader,
              height: 35,
              child: new Center(
                child: new Text(
                  "Total",
                  style: header,
                ),
              ),
            ))
      ],
    );
  }

  getTableView() {
    List<Widget> listColumns = [];
    for (int i = 0; i < listMain.length; i++) {
      listColumns.add(new Row(
        children: <Widget>[
          new Expanded(
              flex: 2,
              child: new Container(
                decoration: decoration,
                height: 35,
                child: new Center(
                  child: new Text(
                    listMain[i]["date"],
                    style: TextStyle(color: AppColors.dark_grey_color, fontSize: data_text_size),
                  ),
                ),
              )),
          new Expanded(
              flex: 1,
              child: new Container(
                decoration: decoration,
                height: 35,
                child: new Center(
                  child: new Text(
                    listMain[i]["day"].toString().substring(0, 3),
                    style: TextStyle(color: AppColors.dark_grey_color, fontSize: data_text_size),
                  ),
                ),
              )),
          new Expanded(
              flex: 3,
              child: new Container(
                decoration: decoration,
                height: 35,
                child: new Center(
                  child: new Text(
                    listMain[i]["route_desc"],
                    style: TextStyle(color: AppColors.dark_grey_color, fontSize: data_text_size),
                  ),
                ),
              )),
          new Expanded(
              flex: 2,
              child: new Container(
                decoration: decoration,
                height: 35,
                child: new Center(
                  child: new Text(
                    listMain[i]["allowance_type"],
                    style: TextStyle(color: AppColors.dark_grey_color, fontSize: data_text_size),
                  ),
                ),
              )),
          new Expanded(
              flex: 1,
              child: new Container(
                decoration: decoration,
                height: 35,
                child: new Center(
                  child: new Text(
                    listMain[i]["distance"],
                    style: TextStyle(color: AppColors.dark_grey_color, fontSize: data_text_size),
                  ),
                ),
              )),
          new Expanded(
              flex: 1,
              child: new Container(
                decoration: decoration,
                height: 35,
                child: new Center(
                  child: new Text(
                    listMain[i]["fare"],
                    style: TextStyle(color: AppColors.dark_grey_color, fontSize: data_text_size),
                  ),
                ),
              )),
          new Expanded(
              flex: 1,
              child: new Container(
                decoration: decoration,
                height: 35,
                child: new Center(
                  child: new Text(
                    listMain[i]["wa"],
                    style: TextStyle(color: AppColors.dark_grey_color, fontSize: data_text_size),
                  ),
                ),
              )),
          new Expanded(
              flex: 1,
              child: new Container(
                decoration: decoration,
                height: 35,
                child: new Center(
                  child: new Text(
                    listMain[i]["total"],
                    style: TextStyle(color: AppColors.dark_grey_color, fontSize: data_text_size),
                  ),
                ),
              ))
        ],
      ));
    }
    listColumns.add(getFooterRow(newDt));
    return listColumns;
  }

  getFooterRow(var data) {
    print("DATA to: ${data}");
    return new Row(
      children: <Widget>[
        new Expanded(
            flex: 2,
            child: new Container(
              decoration: decorationFooter,
              height: 35,
              child: new Center(
                child: new Text(
                  "",
                  style: TextStyle(color: AppColors.white_color, fontSize: data_text_size),
                ),
              ),
            )),
        new Expanded(
            flex: 1,
            child: new Container(
              decoration: decorationFooter,
              height: 35,
              child: new Center(
                child: new Text(
                  "",
                  style: TextStyle(color: AppColors.white_color, fontSize: data_text_size),
                ),
              ),
            )),
        new Expanded(
            flex: 3,
            child: new Container(
              decoration: decorationFooter,
              height: 35,
              child: new Center(
                child: new Text(
                  "",
                  style: TextStyle(color: AppColors.white_color, fontSize: data_text_size),
                ),
              ),
            )),
        new Expanded(
            flex: 2,
            child: new Container(
              decoration: decorationFooter,
              height: 35,
              child: new Center(
                child: new Text(
                  "Grand Total",
                  style: TextStyle(color: AppColors.white_color, fontSize: data_text_size),
                ),
              ),
            )),
        new Expanded(
            flex: 1,
            child: new Container(
              decoration: decorationFooter,
              height: 35,
              child: new Center(
                child: new Text(
                  data["total_km"] == null ? "" : data["total_km"],
                  style: TextStyle(color: AppColors.white_color, fontSize: data_text_size),
                ),
              ),
            )),
        new Expanded(
            flex: 1,
            child: new Container(
              decoration: decorationFooter,
              height: 35,
              child: new Center(
                child: new Text(
                  data["total_fare"] == null ? "" : data["total_fare"],
                  style: TextStyle(color: AppColors.white_color, fontSize: data_text_size),
                ),
              ),
            )),
        new Expanded(
            flex: 1,
            child: new Container(
              decoration: decorationFooter,
              height: 35,
              child: new Center(
                child: new Text(
                  data["total_wa"],
                  style: TextStyle(color: AppColors.white_color, fontSize: data_text_size),
                ),
              ),
            )),
        new Expanded(
            flex: 1,
            child: new Container(
              decoration: decorationFooter,
              height: 35,
              child: new Center(
                child: new Text(
                  data["total_daily_exp"],
                  style: TextStyle(color: AppColors.white_color, fontSize: data_text_size),
                ),
              ),
            ))
      ],
    );
  }

  getFooter() {
    return new Container(
        color: AppColors.light_main_color1,
        padding: EdgeInsets.only(top: 5, bottom: 5, right: 15, left: 5),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            new Text(
              "Daily Allowances : ",
              style: TextStyle(color: AppColors.white_color, fontSize: 15),
            ),
            new Text(
              data_parent["total_daily_exp"],
              style: TextStyle(color: AppColors.white_color, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            new Container(
              height: 10,
              width: 1,
              color: AppColors.white_color,
              margin: EdgeInsets.only(left: 7, right: 7),
            ),
            new Text(
              "Monthly Expenses : ",
              style: TextStyle(color: AppColors.white_color, fontSize: 15),
            ),
            new Text(
              data_parent["total_monthly_exp"],
              style: TextStyle(color: AppColors.white_color, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            new Container(
              height: 10,
              width: 1,
              color: AppColors.white_color,
              margin: EdgeInsets.only(left: 7, right: 7),
            ),
            new Text(
              "Total : ",
              style: TextStyle(color: AppColors.white_color, fontSize: 15),
            ),
            new Text(
              data_parent["total_exp"],
              style: TextStyle(color: AppColors.white_color, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ));
  }

  void openDropdwnDialog() {
    List<DropdownMenuItem> items = [];
    for (int k = 0; k < data_monthly.length; k++) {
      items.add(DropdownMenuItem(value: k, child: Text(data_monthly[k]["allowance_type"])));
      //print(listItems[k]);
    }
    int selected;

    showGeneralDialog(
        context: context,
        barrierColor: Colors.black12.withOpacity(0.01),
        barrierDismissible: false,
        barrierLabel: "Dialog",
        transitionDuration: Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) {
          return Material(
              color: Colors.black12.withOpacity(0.5),
              child: SizedBox.expand(
                  child: Align(
                      alignment: Alignment.center,
                      child: new Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: AppColors.white_color,
                        ),
                        padding: EdgeInsets.all(10),
                        height: 180,
                        width: MediaQuery.of(context).size.width - 100,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Text(
                              "Select expense type of document.",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            new Container(
                              margin: EdgeInsets.all(10),
                              child: new Row(
                                children: <Widget>[
                                  Expanded(
                                    child: new Container(
                                      padding: EdgeInsets.all(5),
                                      child: new DropdownButton(
                                        isExpanded: true,
                                        hint: Text('Please select expense type'),
                                        // Not necessary for Option 1
                                        value: Constants_data.temp_sel_exp_type,
                                        onChanged: (newValue) {
                                          print("Selected: ${newValue}");
                                          //setState(() {
                                          Constants_data.temp_sel_exp_type = newValue;
                                          Constants_data.exp_type_Sel =
                                              data_monthly[Constants_data.temp_sel_exp_type]["allowance_type"];
                                          Constants_data.exp_id_Sel =
                                              data_monthly[Constants_data.temp_sel_exp_type]["allowance_id"];
                                          Navigator.pop(context);
                                          getImage();
                                          //});
                                        },
                                        items: items,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            /*new Container(
                              margin: EdgeInsets.all(10),
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: new Container(
                                      padding: EdgeInsets.all(5),
                                      child: new Text(
                                        "CANCEL",
                                        style: TextStyle(
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);

                                    },
                                    child: new Container(
                                      padding: EdgeInsets.all(5),
                                      child: new Text(
                                        "ADD",
                                        style: TextStyle(
                                            color: Colors.lightBlue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )*/
                          ],
                        ),
                      ))));
        });
  }

  showAlertDialog(BuildContext context, String image_id, int index) {
    // Create button
    Widget okButton = MaterialButton(
      child: Text("Delete"),
      onPressed: () {
        Navigator.of(context).pop();
        deletePhoto(image_id, index);
      },
    );

    Widget cancelButton = MaterialButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete!"),
      content: Text("Are you sure want to delete?"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void submitData(String s) async {
    Map<String, dynamic> JsonSaveAllowance = new HashMap();
    JsonSaveAllowance["expense_doc_no"] = expense_doc_no == null ? "" : expense_doc_no;
    JsonSaveAllowance["month_year"] = Constants_data.date_selected;
    JsonSaveAllowance["total_exp"] = total_exp;
    JsonSaveAllowance["total_daily_exp"] = total_daily_exp;
    JsonSaveAllowance["total_monthly_exp"] = total_monthly_exp;
    JsonSaveAllowance["total_km"] = total_km;
    JsonSaveAllowance["total_fare"] = total_fare;
    JsonSaveAllowance["total_wa"] = total_wa;
    JsonSaveAllowance["data_monthly"] = data_monthly;
    JsonSaveAllowance["data_daily"] = listMain;
    JsonSaveAllowance["is_submitted"] = s;

    var dataUser;
    if (Constants_data.app_user == null) {
      dataUser = await StateManager.getLoginUser();
    } else {
      dataUser = Constants_data.app_user;
    }
    try {
      String url = "/SaveExpenseClaimDetail?RepId=${dataUser["Rep_Id"]}";
      var data = await _helper.post(url, JsonSaveAllowance, true);
      if (data["Status"] == 1) {
        await getData();
        this.setState(() {});
        Constants_data.check_save = false;

        Fluttertoast.showToast(
            msg: data["Message"],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: AppColors.white_color,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: data["Message"],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: AppColors.red_color,
            textColor: AppColors.white_color,
            fontSize: 16.0);
      }
      print("------------------*** Response from SaveExpenseClaimDetail: ${data}");
    } on Exception catch (err) {
      print("Error in SaveExpenseClaimDetail : $err");
    }
  }

  String getMonthString() {
    String dt = Constants_data.date_selected;
    List<dynamic> lt = dt.split("-");
    if (lt[0] == "01") {
      return "January ${lt[1]}";
    } else if (lt[0] == "02") {
      return "February ${lt[1]}";
    } else if (lt[0] == "03") {
      return "March ${lt[1]}";
    } else if (lt[0] == "04") {
      return "April ${lt[1]}";
    } else if (lt[0] == "05") {
      return "May ${lt[1]}";
    } else if (lt[0] == "06") {
      return "June ${lt[1]}";
    } else if (lt[0] == "07") {
      return "July ${lt[1]}";
    } else if (lt[0] == "08") {
      return "August ${lt[1]}";
    } else if (lt[0] == "09") {
      return "September ${lt[1]}";
    } else if (lt[0] == "10") {
      return "October ${lt[1]}";
    } else if (lt[0] == "11") {
      return "November ${lt[1]}";
    } else if (lt[0] == "12") {
      return "December ${lt[1]}";
    }
  }
}
