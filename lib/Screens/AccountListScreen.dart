import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Constants/StateManager.dart';
import 'package:flexi_profiler/Constants/bottom_sheet.dart';
import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
import 'package:flexi_profiler/DBClasses/CreateAllTables.dart';
import 'package:flexi_profiler/DBClasses/DBProfessionalList.dart';
import 'package:flexi_profiler/Screens/AccountDetailsScreen.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../ChatConnectyCube/pref_util.dart';
import 'Login.dart';

class AccountListScreen extends StatefulWidget {
  @override
  _AccountListScreen createState() => _AccountListScreen();
}

//List<Map<String, dynamic>> doctorDetails = [] ;
//List<dynamic> doctorDetails ;
Map<String, dynamic> templateJson;

String accountType;
String apiname;
Map<String, dynamic> apiParameters;
Map<String, dynamic> apiParameters1;
List<String> keyNames;

String selectedDivisionIdcode;
String selectedDivisionidName;
String selectedDivision = "";
String selectedHQidName = "";
String selectedHQidCode = "";
dynamic divisions;
dynamic filteredHQs;
dynamic hqs;



class _AccountListScreen extends State<AccountListScreen> {
  @override
  initState() {
    super.initState();
    getLoginUser();
    selectedDivisionIdcode = Constants_data.selectedDivisionId;
    selectedHQidCode = Constants_data.selectedHQCode;
  }

  var user;
  getLoginUser() async {
    if (Constants_data.app_user == null) {
      user = await StateManager.getLoginUser();
    } else {
      user = Constants_data.app_user;
    }
    print("Login User = ${user}");
  }

  bool isLoaded = false;
  List<dynamic> lItems;
  List<dynamic> listAllItemsCopy;
  bool isSearching = false;
  //List<Map<String, dynamic>> lItems;
  Map<String, dynamic> data;
  List<dynamic> templateDetails;

  //List<Map<String, dynamic>> listAllItemsCopy;
  List<dynamic> filterList = [];
  List<dynamic> keys = [];
  List<dynamic> listFavorite = [];
  List<bool> listSelected = [];
  bool isSelectable = false;
  String currentListId = "";
  List<dynamic> filterQueryList = [];
  List<dynamic> alertList = [];
  List<dynamic> attributeList = [];
  List<dynamic> attributeVariableList = [];
  ApiBaseHelper _helper = ApiBaseHelper();
  bool isFiltered = false;

  //selectedDivisionIdcode = Constants_data.selectedDivisionId;

  Icon actionIcon = new Icon(Icons.search);
  ThemeData themeData;

  TextEditingController cnt_searchAppbar = new TextEditingController();

  DarkThemeProvider themeChange;
  bool isAdvancedSearch = false;

  @override
  Widget build(BuildContext context) {
    Constants_data.currentScreenContext = context;
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    final arg = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    String title = arg["menu_title"];
    apiname = arg["api_name"];
    accountType = arg["account_type"];
    apiParameters = jsonDecode(arg["api_parameters"]);

// Always include accountType and hqCode in apiParameters
    apiParameters["accountType"] = accountType;
    apiParameters["hqCode"] = Constants_data.selectedHQCode;
    // apiParameters["hqCode"] = (selectedHQidCode == null || selectedHQidCode.trim().isEmpty || selectedHQidCode == "null" || selectedHQidCode == "")
    //     ? Constants_data.selectedHQCode
    //     : selectedHQidCode;

// Conditionally include divisionCode only if accountType is 'HCP'
    if (accountType == 'HCP') {
     // apiParameters["divisionCode"] = (selectedDivisionIdcode == null || selectedDivisionIdcode == "null" || selectedDivisionIdcode == "")?Constants_data.selectedDivisionId:selectedDivisionIdcode;
      apiParameters["divisionCode"] = Constants_data.selectedDivisionId;
      apiParameters["repCode"] = '${user["RepId"]}';
    }if (accountType == 'FGO') {
      apiParameters["divisionCode"] = Constants_data.selectedDivisionId;
    }

    String div= Constants_data.selectedDivisionId;
    String hqid = Constants_data.selectedHQCode;
    updateApiParametersinit(div,hqid);
    getProfessionalData(apiname, apiParameters);

    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Constants_data.getFlexibleAppBar(themeChange.darkTheme),
          backgroundColor: Colors.transparent,
          title: this.actionIcon.icon == Icons.search
          // ? new Text("$title")
              ? Text("$title ($doctorDetailsCount)")
              : new TextField(
            controller: cnt_searchAppbar,
            style: new TextStyle(
              color: AppColors.white_color,
            ),
            onChanged: (val) {
              searchOperationInAppBar(val);
            },
            decoration: new InputDecoration(
                prefixIcon: new Icon(
                    Icons.search, color: AppColors.white_color),
                hintText: "Search...",
                hintStyle: new TextStyle(color: AppColors.white_color)),
          ),
          actions: <Widget>[
            // this.actionIcon.icon == Icons.search
            //     ? FutureBuilder<bool>(
            //         future: getAddUserConfig(accountType),
            //         builder: (context, snapshot) {
            //           if (snapshot.connectionState == ConnectionState.done) {
            //             if (snapshot.data) {
            //               return IconButton(
            //                 icon: Icon(Icons.person_add),
            //                 onPressed: () async {
            //                   Navigator.pushNamed(context, "/FormControlWithTemplateJson", arguments: accountType);
            //                 },
            //               );
            //             } else {
            //               return Container();
            //             }
            //           } else {
            //             return Container();
            //           }
            //         },
            //       )
            //     : Container(),
            // this.actionIcon.icon == Icons.search
            //     ? IconButton(
            //         icon: Icon(Icons.post_add),
            //         onPressed: () async {
            //           if (isSelectable) {
            //             String selectedIds = "";
            //             String selectedNames = "";
            //             for (int i = 0; i < lItems.length; i++) {
            //               if (listSelected[i]) {
            //                 selectedIds += lItems[i]["CustomerId"].toString() + "~";
            //                 selectedNames += lItems[i]["CustomerName"].toString() + "~";
            //               }
            //             }
            //             selectedIds = Constants_data.removeLastCharFromString(selectedIds);
            //             selectedNames = Constants_data.removeLastCharFromString(selectedNames);
            //             print("Selected Ids $selectedIds");
            //             print("Selected names $selectedNames");
            //             print("CurrentListId $currentListId");
            //             if (currentListId != null) {
            //               var response = await DBProfessionalList.updateFavoriteList(currentListId, selectedIds);
            //               this.setState(() {
            //                 isLoaded = false;
            //                 isSelectable = false;
            //                 currentListId = "";
            //               });
            //             } else {
            //               print("Add new List");
            //               showAddNameDialog(accountType, selectedIds);
            //             }
            //             print("Response = $response");
            //           } else {
            //             showCategoryDialog();
            //           }
            //         },
            //       )
            //     : new Container(),
            // this.actionIcon.icon == Icons.search
            //     ? Stack(children: [
            //         IconButton(
            //           icon: Icon(Icons.sort),
            //           onPressed: () async {
            //             _settingModalBottomSheet(context);
            //           },
            //         ),
            //         isFiltered
            //             ? Positioned(
            //                 right: 15,
            //                 top: 15,
            //                 child: Container(
            //                   decoration: BoxDecoration(
            //                     shape: BoxShape.circle,
            //                     color: AppColors.red_color,
            //                   ),
            //                   height: 7,
            //                   width: 7,
            //                 ))
            //             : Container()
            //       ])
            //     : Container(),
            IconButton(
              icon: actionIcon,
              onPressed: () {
                setState(() {
                  if (this.actionIcon.icon == Icons.search) {
                    listSearchResult = [];
                    this.actionIcon = new Icon(Icons.close);
                  } else {
                    isAdvancedSearch = false;
                    if (isFiltered) {
                      lItems = filterList;
                    } else {
                      lItems = listAllItemsCopy;
                    }
                    cnt_searchAppbar.text = "";
                    this.actionIcon = new Icon(Icons.search);
                  }
                });
              },
            ),
            // this.actionIcon.icon != Icons.search
            //     ? FutureBuilder<bool>(
            //         future: getGlobalSearchStatus(accountType),
            //         builder: (context, snapshot) {
            //           if (snapshot.connectionState == ConnectionState.done) {
            //             if (snapshot.data) {
            //               return IconButton(
            //                 icon: Icon(
            //                   Icons.person_search,
            //                   color: isAdvancedSearch ? Colors.white : Colors.grey,
            //                 ),
            //                 onPressed: () async {
            //                   this.setState(() {
            //                     isAdvancedSearch = !isAdvancedSearch;
            //                   });
            //                   print("Advanced Search called:$isAdvancedSearch");
            //                 },
            //               );
            //             } else {
            //               return Container();
            //             }
            //           } else {
            //             return Container();
            //           }
            //         },
            //       )
            //     : Container(),
            // this.actionIcon.icon != Icons.search && isShowAdvanceSearchOption
            //     ? IconButton(
            //         icon: Icon(
            //           Icons.person_search,
            //           color: isAdvancedSearch ? Colors.white : Colors.grey,
            //         ),
            //         onPressed: () async {
            //           this.setState(() {
            //             isAdvancedSearch = !isAdvancedSearch;
            //           });
            //           print("Advanced Search called:$isAdvancedSearch");
            //         },
            //       )
            //     : Container(),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            isLoaded = false;
            await getProfessionalData(apiname, apiParameters);
          },
          child: Container(
            child: !isLoaded
                ? FutureBuilder<int>(
              future: getProfessionalData(apiname, apiParameters),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == 0) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return getView();
                  }
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            )
                : getView(),
          ),
        ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        onPressed: () {
          getDivisionData();
          setState(() {});
        },
        mini: true, // This makes the button smaller
      ),
    );
  }

  searchOperationInAppBar(val) {
    // setState(() {
    //   isSearching = true;
    // });
    if (isAdvancedSearch) {
      if (val != "") {
        _timer?.cancel();
        _schedule(val);
      }
    } else {
      if (val != "") {
        if (!isFiltered) {
          this.setState(() {
            // isSearching = false;
            lItems = listAllItemsCopy
                .where((e) =>e["CustomerName"].toString().trim().toLowerCase().contains(val.toString().toLowerCase().trim()))
                .toList();
          });
        } else {
          this.setState(() {
            lItems = filterList
                .where((e) =>
                e["CustomerName"].toString().trim().toLowerCase().contains(val.toString().toLowerCase().trim()))
                .toList();
          });
        }
      } else {
        if (!isFiltered) {
          this.setState(() {
            lItems = listAllItemsCopy;
          });
        } else {
          this.setState(() {
            lItems = filterList;
          });
        }
      }
    }
  }
  Future<bool> getGlobalSearchStatus(accountType) async {
    try {
      String query = "SELECT * FROM AccountTypeMst WHERE AccountType=?";
      List<dynamic> accountTypeMst = await DBProfessionalList.prformQueryOperation(query, [accountType]);
      return accountTypeMst[0]["AllowGlobalSearch"] == "Y";
    } catch (e) {
      print("Error in fetching Global Search status : ${e.toString()}");
      return false;
    }
  }

  Timer _timer;
  List<dynamic> listSearchResult = [];
  bool isLoading;

  void _schedule(val) {
    _timer = Timer(Duration(seconds: 1), () {
      if (val.toString().length >= 3) {
        // this.setState(() {
        //   listSearchResult = listSearchResultMain;
        // });
        print('After delay : ${val}');
        searchKeyword(val);
      } else if (val.toString().length == 0) {
        print("Blank");
        this.setState(() {
          listSearchResult = [];
        });
      } else {
        print("Cancel");
      }
    });
  }
  void searchKeyword(keyword) async {
    String url = "/GetCoreDataFromSearch?search=$keyword&AccountType=$accountType&RepId=${Constants_data.repId}";
    this.setState(() {
      isLoading = true;
    });
    try {
      dynamic data = await _helper.get(url);
      print("Response Data : ${data}");
      if (data["Status"].toString() == "1") {
        this.setState(() {
          listSearchResult = data["dt_ReturnedTables"][0];
          isLoading = false;
        });
      } else {
        print("Error in response : $data");
      }
    } on Exception catch (err) {
      print("Error: ${err.toString()}");
      this.setState(() {
        isLoading = false;
      });
    }
    print("List Search Result length : ${listSearchResult.length}");
  }

  getView() {
    Widget vi;
    if (lItems != null && lItems.isNotEmpty && !isAdvancedSearch) {
      vi = new ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: lItems.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return getViewFromListTemplate(lItems[index], keys, accountType, index, lItems);
          });
    }
    else if (listSearchResult != null && listSearchResult.length > 0 && isAdvancedSearch) {
      vi = new ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: listSearchResult.length,
          itemBuilder: (BuildContext ctxt, int index) {
            int status = 0;
            return StatefulBuilder(builder: (BuildContext context, StateSetter state) {
              Widget icon;
              if (status == 0) {
                icon = Icon(
                  Icons.add_circle_outline_outlined,
                  color: themeData.accentColor,
                );
              }
              else if (status == 1) {
                icon = CircularProgressIndicator();
              }
              else {icon = Icon(
                Icons.check_circle_outline,
                color: themeData.accentColor,
              );
              }
              return Card(
                  child: ListTile(
                    title: Text("${listSearchResult[index]["AccountName"]}"),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.add_circle_outline_outlined,
                        color: themeData.accentColor,
                      ),
                      onPressed: () async {
                        state(() {
                          status = 1;
                        });
                        String query = "SELECT * from ProfessionalList WHERE CustomerId=? AND accountType=?";
                        List<dynamic> listSearch = await DBProfessionalList.prformQueryOperation(
                            query, [listSearchResult[index]["AccountId"], accountType]);
                        print("IsFound any result from localDB : ${listSearch.length}");
                        if (listSearch.length > 0) {
                          Constants_data.toastError("Account detail is already there in you local database");
                          state(() {
                            status = 0;
                          });
                        } else {
                          String url =
                              "/GetCoreDataFromCustomerId?CustomerId=${listSearchResult[index]["AccountId"]}&AccountType=$accountType&RepId=${Constants_data.repId}";
                          try {
                            dynamic data = await _helper.get(url);
                            if (data["Status"].toString() == "1") {
                              await CreateAllTables.createObject(data, isDeleteCurrent: false);
                              Constants_data.toastNormal(data["Message"].toString());
                              state(() {
                                status = 2;
                              });
                            } else {
                              Constants_data.toastError(data["Message"].toString());
                              state(() {
                                status = 0;
                              });
                            }
                          } on Exception catch (err) {
                            print("Error: ${err.toString()}");
                            state(() {
                              status = 0;
                            });
                          }
                        }
                      },
                    ),
                  ));
            });
          });
    }
    else {
      vi = Center(
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
            style: TextStyle(color: AppColors.grey_color, fontSize: Constants_data.getFontSize(context, 14)),
            textAlign: TextAlign.center,
          )
        ]),
      );
    }
    return vi;
  }
  Future<bool> getAddUserConfig(accountType) async {
    bool status = await Constants_data.checkConfigAvailability("Add$accountType");
    return status;
  }
  resetSelectedList() {
    listSelected = [];
    for (int i = 0; i < lItems.length; i++) {
      listSelected.add(false);
    }
  }
  getFavoriteList(String accoutType) async {
    List<dynamic> response = await DBProfessionalList.getFavoriteList(accoutType);
    return response;
  }

//   List<dynamic> sortedItems = [];
//   void sortItems(List<dynamic> lItems) {
//     sortedItems = List.from(lItems);
//     lItems.sort((a, b) {
//       String statusA = getStatus(a);
//       String statusB = getStatus(b);
//
//       // Sorting logic as previously defined
//       if (statusA == "Level1 Pending") return -1;
//       if (statusB == "Level1 Pending") return 1;
//       if (statusA == "Level2 Pending") return -1;
//       if (statusB == "Level2 Pending") return 1;
//       if (statusA == "Supplied") return -1;
//       if (statusB == "Supplied") return 1;
//       return 0;
//     });
//   }
//   //3rd code//
//   getViewFromListTemplate3(var dt, List<dynamic> key, var accountType, int index, List<dynamic> lItems) {
//     var data = template_json;
//
//     sortItems(lItems);
//    // checkForDuplicates(lItems);
//     print("lItems after sorting: $sortedItems");
//     if (data["ViewType"] == "List") {
//       List<Widget> dtColumn = [];
//       List<dynamic> rowData = data["Row"];
//       for (int i = 0; i < rowData.length; i++) {
//         List<Widget> dtRow = [];
//         List<dynamic> rowDataChild = rowData[i];
//
//         for (int j = 0; j < rowDataChild.length; j++) {
//           Alignment align = Alignment.centerLeft;
//           if (rowDataChild[j]["align"] == "Center") {
//             align = Alignment.center;
//           } else if (rowDataChild[j]["align"] == "Right") {
//             align = Alignment.centerRight;
//           }
//
//           dtRow.add(Expanded(
//             flex: rowDataChild[j]["maxWidht"],
//             child: Container(
//               padding: EdgeInsets.all(3),
//               child: Align(
//                 alignment: align,
//                 child: Row(children: [
//                   if (data["api_name"] == "GetFGODetails") ...[
//                     Text(
//                       "${rowDataChild[j]["label"]}",
//                       maxLines: 2,
//                       softWrap: false,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: Constants_data.getFontSize(context, rowDataChild[j]["txt_size"]),
//                       ),
//                     )
//                   ],
//                   Flexible(
//                     child: Text(
//                       "${getFormattedStatus(dt, rowDataChild[j])}",
//                       maxLines: 2,
//                       softWrap: false,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontWeight: rowDataChild[j]["txt_style"] == "Bold"
//                             ? FontWeight.bold
//                             : FontWeight.normal,
//                         fontSize: Constants_data.getFontSize(context, rowDataChild[j]["txt_size"]),
//                       ),
//                     ),
//                   )
//                 ]),
//               ),
//             ),
//           ));
//         }
//
//         dtColumn.add(Container(
//           child: Row(children: dtRow),
//         ));
//       }
//       return InkWell(
//         onTap: () async {
//           if (!isSelectable) {
//             FocusScope.of(context).requestFocus(FocusNode());
//             await Future.delayed(const Duration(milliseconds: 200));
//
//             Map<String, dynamic> arg = HashMap();
//             arg["data"] = dt;
//             arg["keys"] = key;
//             arg["accountType"] = accountType;
//             arg["jsonHeader"] = template_json_header;
//             arg["categeorydata"] = categeorydata;
//             arg["apiname"] = template_json["api_name"];
//             arg["apiparameters"] = template_json["api_parameters"];
//
//             String strAgr = json.encode(arg);
//             print("Navigating to AccountDetailsScreen with arguments: $strAgr");
//
//             Navigator.of(context).push(PageRouteBuilder(
//               pageBuilder: (context, animation, secondaryAnimation) => AccountDetailsScreen(),
//               settings: RouteSettings(name: "/AccountDetailsScreen", arguments: arg),
//               transitionDuration: Duration(milliseconds: 1000),
//             ));
//           } else {
//             setState(() {
//               listSelected[index] = !listSelected[index];
//             });
//           }
//         },
//         child: Hero(
//           tag: "hero${dt["CustomerId"]}",
//           child: Material(
//             child: Card(
//               elevation: 8,
//               child: Container(
//                 decoration: const BoxDecoration(
//                   border: Border(
//                     bottom: BorderSide(width: 0.5, color: Color(0xFFbbbbbb)),
//                   ),
//                 ),
//                 padding: EdgeInsets.all(7),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: <Widget>[
//                     isSelectable
//                         ? Container(
//                       margin: EdgeInsets.only(right: 10),
//                       width: 20,
//                       child: Icon(
//                         Icons.check_circle,
//                         color: listSelected[index]
//                             ? AppColors.main_color
//                             : AppColors.grey_color.withOpacity(0.3),
//                       ),
//                     )
//                         : Container(),
//                     data["isShowLeadingIcon"] == "Y"
//                         ? Container(
//                       child: CircleAvatar(
//                         backgroundColor: AppColors.light_grey_color,
//                         radius: Constants_data.getFontSize(context, 25),
//                         child: Container(
//                           alignment: Alignment.center,
//                           margin: EdgeInsets.all(2),
//                           child: dt[data["LeadingIconFrom"]] == null ||
//                               dt[data["LeadingIconFrom"]] == ""
//                               ? Image.asset("assets/images/default_user.png")
//                               : Image.network(dt[data["LeadingIconFrom"]]),
//                         ),
//                       ),
//                       margin: EdgeInsets.only(right: 5, left: 5),
//                     )
//                         : Container(),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: dtColumn,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//   }
// //2nd code//
//   getViewFromListTemplateee(var dt, List<dynamic> key, var accountType, int index, List<dynamic> lItems) {
//     var data = template_json;
//
//     // Sort the lItems so that "Level1 Pending" and "Level2 Pending" are at the top.
//     lItems.sort((a, b) {
//       String statusA = getStatus(a);
//       String statusB = getStatus(b);
//
//       // Define priority for sorting: "Level1 Pending" and "Level2 Pending" first.
//       if (statusA == "Level1 Pending") return -1;
//       if (statusB == "Level1 Pending") return 1;
//       if (statusA == "Level2 Pending") return -1;
//       if (statusB == "Level2 Pending") return 1;
//       return 0; // Keep the original order for other statuses.
//     });
//
//     if (data["ViewType"] == "List") {
//       List<Widget> dtColumn = [];
//       List<dynamic> rowData = data["Row"];
//
//       for (int i = 0; i < rowData.length; i++) {
//         List<Widget> dtRow = [];
//         List<dynamic> rowDataChild = rowData[i];
//
//         for (int j = 0; j < rowDataChild.length; j++) {
//           Alignment align = Alignment.centerLeft;
//           if (rowDataChild[j]["align"] == "Center") {
//             align = Alignment.center;
//           } else if (rowDataChild[j]["align"] == "Right") {
//             align = Alignment.centerRight;
//           }
//
//           dtRow.add(Expanded(
//             flex: rowDataChild[j]["maxWidht"],
//             child: Container(
//               padding: EdgeInsets.all(3),
//               child: Align(
//                 alignment: align,
//                 child: Row(children: [
//                   if (data["api_name"] == "GetFGODetails") ...[
//                     Text(
//                       "${rowDataChild[j]["label"]}",
//                       maxLines: 2,
//                       softWrap: false,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: Constants_data.getFontSize(context, rowDataChild[j]["txt_size"]),
//                       ),
//                     )
//                   ],
//                   Flexible(
//                     child: Text(
//                       "${getFormattedStatus(dt, rowDataChild[j])}",
//                       maxLines: 2,
//                       softWrap: false,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontWeight: rowDataChild[j]["txt_style"] == "Bold"
//                             ? FontWeight.bold
//                             : FontWeight.normal,
//                         fontSize: Constants_data.getFontSize(context, rowDataChild[j]["txt_size"]),
//                       ),
//                     ),
//                   )
//                 ]),
//               ),
//             ),
//           ));
//         }
//
//         dtColumn.add(Container(
//           child: Row(children: dtRow),
//         ));
//       }
//
//       return InkWell(
//         onTap: () async {
//           if (!isSelectable) {
//             FocusScope.of(context).requestFocus(FocusNode());
//             await Future.delayed(const Duration(milliseconds: 200));
//
//             Map<String, dynamic> arg = HashMap();
//             arg["data"] = dt;
//             arg["keys"] = key;
//             arg["accountType"] = accountType;
//             arg["jsonHeader"] = template_json_header;
//             arg["categeorydata"] = categeorydata;
//             arg["apiname"] = template_json["api_name"];
//             arg["apiparameters"] = template_json["api_parameters"];
//
//             String strAgr = json.encode(arg);
//             print("Navigating to AccountDetailsScreen with arguments: $strAgr");
//
//             Navigator.of(context).push(PageRouteBuilder(
//               pageBuilder: (context, animation, secondaryAnimation) => AccountDetailsScreen(),
//               settings: RouteSettings(name: "/AccountDetailsScreen", arguments: arg),
//               transitionDuration: Duration(milliseconds: 1000),
//             ));
//           } else {
//             setState(() {
//               listSelected[index] = !listSelected[index];
//             });
//           }
//         },
//         child: Hero(
//           tag: "hero${dt["CustomerId"]}",
//           child: Material(
//             child: Card(
//               elevation: 8,
//               child: Container(
//                 decoration: const BoxDecoration(
//                   border: Border(
//                     bottom: BorderSide(width: 0.5, color: Color(0xFFbbbbbb)),
//                   ),
//                 ),
//                 padding: EdgeInsets.all(7),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: <Widget>[
//                     isSelectable
//                         ? Container(
//                       margin: EdgeInsets.only(right: 10),
//                       width: 20,
//                       child: Icon(
//                         Icons.check_circle,
//                         color: listSelected[index]
//                             ? AppColors.main_color
//                             : AppColors.grey_color.withOpacity(0.3),
//                       ),
//                     )
//                         : Container(),
//                     data["isShowLeadingIcon"] == "Y"
//                         ? Container(
//                       child: CircleAvatar(
//                         backgroundColor: AppColors.light_grey_color,
//                         radius: Constants_data.getFontSize(context, 25),
//                         child: Container(
//                           alignment: Alignment.center,
//                           margin: EdgeInsets.all(2),
//                           child: dt[data["LeadingIconFrom"]] == null ||
//                               dt[data["LeadingIconFrom"]] == ""
//                               ? Image.asset("assets/images/default_user.png")
//                               : Image.network(dt[data["LeadingIconFrom"]]),
//                         ),
//                       ),
//                       margin: EdgeInsets.only(right: 5, left: 5),
//                     )
//                         : Container(),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: dtColumn,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//   }
//   String getStatus(dynamic dt) {
//       if (dt["level1_approved"] == "N" && dt["level2_approved"] == "N") {
//       return "Level1 Pending";
//      } else if (dt["level1_approved"] == "Y" && dt["level2_approved"] == "N" && dt["Is_level2_approval_required"] == "Y") {
//       return "Level2 Pending";
//      } else if (dt["is_invoice_uploaded"] == "Y") {
//         return "Supplied";
//       }
//       else {
//       return "Approved";
//     }
//   }
//   String getFormattedStatus(dynamic dt, dynamic rowDataChild) {
//     // Check if the widget is 'fgo_request_status' and return status accordingly
//     if (rowDataChild["widget_id"] == "fgo_request_status") {
//       return getStatus(dt);
//     }
//     // Handle cases where the value is null, empty, or any other type
//     var value = dt[rowDataChild["widget_id"]];
//
//     if (value == null || value.toString().trim() == "") {
//       return "N/A";  // Return "N/A" for empty or null values
//     } else {
//       return value.toString();  // Safely convert any type to a string
//     }
//   }
//   void checkForDuplicates(List<dynamic> items) {
//     var uniqueItems = items.toSet().toList();
//     if (uniqueItems.length != items.length) {
//       print("Duplicate items found in lItems!");
//     }
//   }


//1st code//
  getViewFromListTemplate(var dt, List<dynamic> key, var accountType, int index,List<dynamic> lItems) {
    var data = template_json;
    if (data["ViewType"] == "List") {
      List<Widget> dtColumn = [];
      List<dynamic> rowData = data["Row"];

      for (int i = 0; i < rowData.length; i++) {
        List<Widget> dtRow = [];
        List<dynamic> rowDataChild = rowData[i];

        for (int j = 0; j < rowDataChild.length; j++) {
          Alignment align = Alignment.centerLeft;
          if (rowDataChild[j]["align"] == "Center") {
            align = Alignment.center;
          }
          else if (rowDataChild[j]["align"] == "Right") {
            align = Alignment.centerRight;
          }
          dtRow.add(new Expanded(
            flex: rowDataChild[j]["maxWidht"],
            child: Container(
                padding: EdgeInsets.all(3),
                child: Align(
                    alignment: align,
                    child: Row(
                        children:[
                          if(data["api_name"] == "GetFGODetails") ...[
                            Text(
                              // "${dt[rowDataChild[j]["widget_id"]] == null || dt[rowDataChild[j]["widget_id"]].toString().trim() == "" ? "N/A" : dt[rowDataChild[j]["widget_id"]]}",
                              "${rowDataChild[j]["label"]}",
                              maxLines: 2,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: Constants_data.getFontSize(context, rowDataChild[j]["txt_size"]),
                              ),
                            )
                          ],
                          Flexible(child: Text(
                            // "${dt[rowDataChild[j]["widget_id"]] == null || dt[rowDataChild[j]["widget_id"]].toString().trim() == "" ? "N/A" : dt[rowDataChild[j]["widget_id"]]}",
                            "${rowDataChild[j]["widget_id"] == "fgo_request_status"
                                ? (dt["is_invoice_uploaded"] == "Y"
                                ? "Supplied"
                                : (dt["level1_approved"] == "N" && dt["level2_approved"] == "N"
                                //? "Pending"
                                ? "Level1 Pending"
                                : dt["level1_approved"] == "Y" && dt["level2_approved"] == "N" && dt["Is_level2_approval_required"] == "Y"
                                ? "Level2 Pending"
                                //? "Level1 Approved"
                                : "Approved"))
                                : (dt[rowDataChild[j]["widget_id"]] == null || dt[rowDataChild[j]["widget_id"]].toString().trim() == ""
                                ? "N/A"
                                : dt[rowDataChild[j]["widget_id"]])}",

                            // "${rowDataChild[j]["widget_id"] == "fgo_request_status"
                            //     ? (dt["level1_approved"] == "N" && dt["level2_approved"] == "N" ? "Pending" : dt["level1_approved"] == "Y" && dt["level2_approved"] == "N" ? "Level1 Approved": "Approved")
                            //     : (dt[rowDataChild[j]["widget_id"]] == null || dt[rowDataChild[j]["widget_id"]].toString().trim() == "" ? "N/A" : dt[rowDataChild[j]["widget_id"]])}",

                            maxLines: 2,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: rowDataChild[j]["txt_style"] == "Bold" ? FontWeight.bold : FontWeight.normal,
                              fontSize: Constants_data.getFontSize(context, rowDataChild[j]["txt_size"]),
                            ),
                          ))
                        ]
                    )
                )),
          ));
        }
        dtColumn.add(new Container(
          child: new Row(children: dtRow),
        ));
      }
      return InkWell(
        // onTap: () async {
        //   if (!isSelectable) {
        //     FocusScope.of(context).requestFocus(FocusNode());
        //     await Future.delayed(const Duration(milliseconds: 200));
        //     Map<String, dynamic> arg = new HashMap();
        //     arg["data"] = dt;
        //     arg["keys"] = keys;
        //     arg["accountType"] = accountType;
        //     arg["jsonHeader"] = template_json_header;
        //     arg["categeorydata"] = categeorydata;
        //     arg["apiname"] = template_json["api_name"];
        //     arg["apiparameters"] = template_json["api_parameters" ];
        //
        //     // Navigator.pushNamed(context, "/AccountDetailsScreen",
        //     //     arguments: arg);
        //
        //     String strAgr = json.encode(arg);
        //     print("strArg : ${strAgr}");
        //
        //     Navigator.of(context).push(PageRouteBuilder(
        //         pageBuilder: (context, animation, secondaryAnimation) => AccountDetailsScreen(),
        //         settings: RouteSettings(name: "/AccountDetailsScreen", arguments: arg),
        //         transitionDuration: Duration(milliseconds: 1000)));
        //   } else {
        //     this.setState(() {
        //       listSelected[index] = !listSelected[index];
        //     });
        //   }
        // },
          onTap: () async {
            if (!isSelectable) {
              FocusScope.of(context).requestFocus(FocusNode());
              await Future.delayed(const Duration(milliseconds: 200));

              Map<String, dynamic> arg = new HashMap();
              arg["data"] = dt;
              arg["keys"] = keys;
              arg["accountType"] = accountType;
              arg["jsonHeader"] = template_json_header;
              arg["categeorydata"] = categeorydata;
              arg["apiname"] = template_json["api_name"];
              arg["apiparameters"] = template_json["api_parameters"];

              String strAgr = json.encode(arg);
              print("Navigating to AccountDetailsScreen with arguments: $strAgr");

              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => AccountDetailsScreen(),
                settings: RouteSettings(name: "/AccountDetailsScreen", arguments: arg),
                transitionDuration: Duration(milliseconds: 1000),
              ));
            } else {
              setState(() {
                listSelected[index] = !listSelected[index];
              });
            }
          },

          child: Hero(
              tag: "hero${dt["CustomerId"]}",
              child: Material(
                  child: Card(
                    // shape: data["api_name"] == "GetFGODetails" ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)):Border.all(),
                      elevation: 8,
                      child:
                      Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 0.5, color: Color(0xFFbbbbbb)),
                            ),
                          ),
                          padding: EdgeInsets.all(7),
                          child: Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  isSelectable
                                      ? Container(
                                    margin: EdgeInsets.only(right: 10),
                                    width: 20,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: listSelected[index]
                                          ? AppColors.main_color
                                          : AppColors.grey_color.withOpacity(0.3),
                                    ),
                                  )
                                      : Container(),
                                  data["isShowLeadingIcon"] == "Y"
                                      ? Container(
                                    child: CircleAvatar(
                                      backgroundColor: AppColors.light_grey_color,
                                      radius: Constants_data.getFontSize(context, 25),
                                      child: Container(
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.all(2),
                                        child: dt[data["LeadingIconFrom"]] == null || dt[data["LeadingIconFrom"]] == ""
                                            ? Image.asset(
                                          "assets/images/default_user.png",
                                        )
                                            : Image.network(dt[data["LeadingIconFrom"]]),
                                      ),
                                    ),
                                    margin: EdgeInsets.only(right: 5, left: 5),
                                  )
                                      : Container(),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: dtColumn,
                                    ),
                                  ),
                                  // data["isShowTailIcon"] == "Y"
                                  //     ? new Center(
                                  //         child: Icon(
                                  //           Icons.keyboard_arrow_right,
                                  //           color: AppColors.grey_color,
                                  //         ),
                                  //       )
                                  //     : new Container()
                                ],
                              )
                          ))
                  )
              )));
    }
  }
  getSubTitle(var lItems, List<dynamic> keys) {
    List<Widget> listWidget = [];
    for (int i = 1; i < keys.length; i++) {
      listWidget.add(Text(
        lItems[keys[i]] != null ? lItems[keys[i]] : "",
        maxLines: 1,
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listWidget,
    );
  }

  int doctorDetailsCount = 0;
  Future<int> getProfessionalData(String apiName, Map<String, dynamic> apiParameters) async {
    bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();

    if (isNetworkAvailable) {
      if (isLoaded) {
        return 1; // Data is already loaded, no need to fetch again
      }
      lItems = [];
      listAllItemsCopy = [];
      // Construct the relative URL
      String url = '/Profiler/$apiName?' + Uri(queryParameters: apiParameters).query;

      try {
        var responseJson = await _helper.get(url);
        if (responseJson["Status"] == 1) {
          Map<String, dynamic> data = responseJson["dt_ReturnedTables"];
          print("Data: $data");
          var doctorDetailsRaw = data["dt_ListDetails"];
          if (doctorDetailsRaw is List) {
            if (doctorDetailsRaw != null && doctorDetailsRaw is List && doctorDetailsRaw.isNotEmpty) {
              doctorDetailsCount = doctorDetailsRaw.length;
            } else {
              doctorDetailsCount = 0;
            }
            //doctorDetailsCount = doctorDetailsRaw.length;
            lItems = doctorDetailsRaw.cast<Map<String, dynamic>>();
            listAllItemsCopy = doctorDetailsRaw.cast<Map<String, dynamic>>();
            print("Doctor Details : $lItems");
          } else {
            print("Error: dt_ListDetails is not a List.");
          }
          keys = doctorDetailsRaw.isNotEmpty
              ? doctorDetailsRaw[0].keys.toList()
              : [];
          print(keys);
          print('Doctor Details Count: $doctorDetailsCount');
        }
        else if (responseJson['Status'] == 2){
          Constants_data.toastNormal("${responseJson["Message"]}");
        }
        else if (responseJson['Status'] == 0){
          Constants_data.toastNormal("${responseJson["Message"]}");
          doctorDetailsCount = 0;
        }
        else if (responseJson["status"].toString() == "8") {
          print("There Is No Products for This Division");
         // Constants_data.toastError(responseJson["message"]);
          await StateManager.logout();
          // SharedPrefs.instance.deleteUser();
          Constants_data.selectedDivisionName= " ";
          Constants_data.selectedDivisionId = null;
          Constants_data.selectedHQCode = null;
          Constants_data.repId = null;
          Constants_data.SessionId = null;
          Constants_data.app_user= null;
          await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,  // This removes all previous routes
          );
         // Navigator.pushReplacementNamed(context, "/Login");
        }
        else if (responseJson["status"].toString() == "4") {
          print("There Is No Products for This Division");
          Constants_data.toastError(responseJson["message"]);
          await StateManager.logout(); // Wait for logout to complete
          //await SharedPrefs.instance.deleteUser(); // Wait for deletion to complete
          Constants_data.selectedDivisionName = "";
          Constants_data.selectedDivisionId = null;
          Constants_data.selectedHQCode = null;
          Constants_data.repId = null;
          Constants_data.SessionId = null;
          Constants_data.app_user= null;
          await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,  // This removes all previous routes
          );
          //await Navigator.pushReplacementNamed(context, "/Login");
        }
        else if (responseJson["status"].toString() == "5") {
         // Constants_data.toastError(responseJson["message"]);
          await StateManager.logout(); // Wait for logout to complete
          //await SharedPrefs.instance.deleteUser(); // Wait for deletion to complete
          Constants_data.selectedDivisionName = "";
          Constants_data.selectedDivisionId = null;
          Constants_data.selectedHQCode = null;
          Constants_data.repId = null;
          Constants_data.repId = null;
          Constants_data.SessionId = null;
          Constants_data.app_user= null;
          await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,  // This removes all previous routes
          );
         // await Navigator.pushReplacementNamed(context, "/Login");
        }

        String str = await getTemplateJson(accountType);
        template_json = jsonDecode(str);

        List<dynamic> categoryData = await getCategoryJson(accountType);
        Constants_data.categoryList = categoryData;
        categeorydata = categoryData;

        String str1 = await getHeaderTemplateFromViewId(accountType);
        template_json_header = jsonDecode(str1);
      } catch (e) {
        print('Exception: $e');
        return 0;
      }
     // sortItems(lItems);
      setState(() {
        isLoaded = true; // Mark data as loaded
      });
      return 1;
    } else {
      await Constants_data.openDialogNoInternetConection(context);
    }
    return 0; // Default return in case network is unavailable
  }
  void showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alert Message"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                this.setState((){});
              },
            ),
          ],
        );
      },
    );
  }
  var template_json;
  var template_json_header;
  var categeorydata;
  Map<String, List<dynamic>> response;

  Future<List<dynamic>> getCategoryJson(String accountType) async {
    List<dynamic> response = await DBProfessionalList.getCategoryFromAccountType(accountType);
    return response;
  }

  Future<String> getTemplateJson(String accountType) async {
    String response = await DBProfessionalList.getTemplateFromViewId(accountType, accountType);
    return response;
  }
  Future<String> getHeaderTemplateFromViewId(String accountType) async {
    String response = await DBProfessionalList.getHeaderTemplateFromViewId(accountType);
    return response;
  }

  showCategoryDialog() {
    resetSelectedList();
    double singleViewHeight = 50;
    double availableHeight = MediaQuery.of(context).size.height - 100;
    int totalItems = listFavorite.length;
    double heightToAssign = (totalItems * singleViewHeight) + 50;
    if (heightToAssign > availableHeight) {
      heightToAssign = availableHeight;
    }
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(0.01),
      barrierDismissible: false,
      barrierLabel: "Dialog",
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        // your widget implementation
        return Material(
            color: Colors.black12.withOpacity(0.5),
            child: SizedBox.expand(
              // makes widget fullscreen
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        decoration: BoxDecoration(
                            color: themeData.cardColor,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(10.0),
                              topRight: const Radius.circular(10.0),
                              bottomLeft: const Radius.circular(10.0),
                              bottomRight: const Radius.circular(10.0),
                            )),
                        height: heightToAssign + 50,
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: SingleChildScrollView(
                            child: Column(
                              children: getViewItems(),
                            )),
                      )),
                )));
      },
    );
  }

  getViewItems() {
    List<Widget> cols = [];
    cols.add(GestureDetector(
        onTap: () {
          currentListId = null;
          this.setState(() {
            isSelectable = true;
          });
          Navigator.pop(context);
        },
        child: Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.3, color: Color(0xFFFFAAAAAA)))),
            margin: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
            width: MediaQuery.of(context).size.width * 0.5,
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Add new List",
                style: TextStyle(fontWeight: FontWeight.normal, color: AppColors.main_color),
              ),
            ))));

    for (int i = 0; i < listFavorite.length; i++) {
      cols.add(GestureDetector(
          onTap: () {
            print("Menu Index : ${i}");
            List<dynamic> tempList = [];
            tempList.addAll(lItems);
            List<dynamic> listProfessional = listFavorite[i]["LevelIds"].toString().split("~");
            currentListId = listFavorite[i]["ListId"].toString();
            int tempPosition = 0;
            for (int j = 0; j < tempList.length; j++) {
              for (int k = 0; k < listProfessional.length; k++) {

                if (listProfessional[k] == tempList[j]["CustomerId"]) {
                  listSelected[tempPosition] = true;
                  print("Selected Event $j");
                  var temp = tempList[j];
                  tempList.removeAt(j);
                  tempList.insert(0, temp);
                  tempPosition++;
                }
              }
            }
            lItems = tempList;
            this.setState(() {
              isSelectable = true;
            });
            Navigator.pop(context);
          },
          child: Container(
              decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.3, color: themeData.disabledColor))),
              margin: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
              width: MediaQuery.of(context).size.width * 0.5,
              height: 50,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${listFavorite[i]["Name"]}",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ))));
    }
    return cols;
  }

  showAddNameDialog(
      String accoutType,
      String LevelIds,
      ) {
    final myController = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(0.01),
      barrierDismissible: false,
      barrierLabel: "Dialog",
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        // your widget implementation
        return Material(
            color: Colors.black12.withOpacity(0.5),
            child: SizedBox.expand(
              // makes widget fullscreen
                child: new GestureDetector(
                  child: Align(
                      alignment: Alignment.center,
                      child: new Container(
                        decoration: new BoxDecoration(
                            color: AppColors.white_color,
                            borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(10.0),
                              topRight: const Radius.circular(10.0),
                              bottomLeft: const Radius.circular(10.0),
                              bottomRight: const Radius.circular(10.0),
                            )),
                        height: 120,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: SingleChildScrollView(
                            child: new Column(
                              children: <Widget>[
                                new Container(
                                  padding: EdgeInsets.all(10),
                                  child: new TextField(
                                    controller: myController,
                                    decoration: new InputDecoration(
                                      contentPadding: new EdgeInsets.symmetric(vertical: 7.0),
                                      hintText: "Add Name",
                                      fillColor: AppColors.black_color,
                                    ),
                                  ),
                                ),
                                new Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    new Container(
                                        margin: EdgeInsets.only(top: 5, bottom: 5),
                                        child: new MaterialButton(
                                            onPressed: () {
                                              this.setState(() {
                                                isLoaded = false;
                                                isSelectable = false;
                                                currentListId = "";
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: new Text(
                                              "Cancel",
                                              style: TextStyle(color: AppColors.red_color),
                                            ))),
                                    new Container(
                                        margin: EdgeInsets.only(
                                          top: 5,
                                          bottom: 5,
                                          right: 5,
                                        ),
                                        child: new MaterialButton(
                                            onPressed: () async {
                                              if (myController.text.trim() == "") {
                                                Constants_data.toastError("Name can't be blank");
                                              } else {
                                                var uuid = Uuid();
                                                var dataUser;
                                                if (Constants_data.app_user == null) {
                                                  dataUser = await StateManager.getLoginUser();
                                                } else {
                                                  dataUser = Constants_data.app_user;
                                                }

                                                Map<String, String> params = new HashMap();
                                                params["ListId"] = uuid.v1();
                                                params["RepId"] = dataUser["RepId"].toString();
                                                params["AccountType"] = accoutType;
                                                params["ListType"] = "F";
                                                params["LevelIds"] = LevelIds;
                                                params["Name"] = myController.text;
                                                params["MaxLimit"] = "0";
                                                params["isActive"] = "Y";
                                                params["CreatedDate"] =
                                                    Constants_data.dateToString(new DateTime.now(), "yyyy-MM-dd'T'HH:mm:ss");
                                                params["isSaved"] = "Y";
                                                params["isDelete"] = "N";

                                                String json_temp = "${jsonEncode(params).toString()}";
                                                json_temp = json_temp.replaceAll("\"", "\\\"");
                                                json_temp = "\"{\\\"jsonCallCustomFavouriteList\\\":[" + json_temp + "]}\"";

                                                await DBProfessionalList.addFavoriteList(params);

                                                var stateUser;
                                                if (Constants_data.app_user == null) {
                                                  stateUser = await StateManager.getLoginUser();
                                                } else {
                                                  stateUser = Constants_data.app_user;
                                                }
                                                try {
                                                  String url = "/SaveCustomFavouriteList?RepId=${stateUser["RepId"]}";
                                                  var data = await _helper.post(url, json_temp, false);
                                                  print('Success in response ${data}');
                                                } on Exception catch (err) {
                                                  print("Error in ");
                                                }
                                                this.setState(() {
                                                  isLoaded = false;
                                                  isSelectable = false;
                                                  currentListId = "";
                                                });
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: new Text("Save", style: TextStyle(color: AppColors.main_color))))
                                  ],
                                )
                              ],
                            )),
                      )),
                )));
      },
    );
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet1(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter state) {
            return SingleChildScrollView(
                child: new GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      print("Ontap called");
                    },
                    child: Container(
                        color: themeData.cardColor,
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: createDialogViewFromTemplate(state)))));
          });
        });
  }

  int selected = 0;
  int selectedQuery = -1;
  int selectedList = -1;
  int selectedAlert = -1;

  int selectedSubScreen = 0;
  List<bool> selectedFieldVariable = [];
  List<Map<String, dynamic>> selectedField = [];
  int currentSelectedField = -1;

  TextEditingController cnt = new TextEditingController();
  TextEditingController cnt_search = new TextEditingController();
  createDialogViewFromTemplate(StateSetter setState) {
    final Map<int, Widget> dt = <int, Widget>{
      0: Container(
          padding: EdgeInsets.all(5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.search,
                size: 14,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                "Queries",
                style: TextStyle(color: themeData.primaryColorLight),
              )
            ],
          )),
      1: Container(
          padding: EdgeInsets.all(5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.person_add,
                size: 14,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                "Lists",
                style: TextStyle(color: themeData.primaryColorLight),
              )
            ],
          )),
      2: Container(
          padding: EdgeInsets.all(5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.notifications_none,
                size: 14,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                "Alerts",
                style: TextStyle(color: themeData.primaryColorLight),
              )
            ],
          )),
    };
    TextStyle listItemTextStyle = TextStyle(fontWeight: FontWeight.bold, color: themeData.primaryColorLight);
    List<Widget> col = [];
    col.add(new Stack(
      children: <Widget>[
        Positioned(
            child: new Align(
              child: MaterialButton(
                onPressed: () {
                  this.setState(() {
                    selectedQuery = -1;
                    selectedList = -1;
                    selectedAlert = -1;
                    selectedSubScreen = 0;
                    selectedField = [];
                    isFiltered = false;
                    filterList = [];
                    isLoaded = false;
                  });
                  Navigator.pop(context);
                },
                child: new Text("Clear"),
              ),
              alignment: Alignment.centerLeft,
            )),
        Align(
          child: MaterialButton(
            onPressed: () {},
            child: new Text(
              "Filter",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          alignment: Alignment.center,
        ),
        new Positioned(
            child: new Align(
              child: MaterialButton(
                onPressed: () async {
                  if (selected == 0) {
                    if (selectedSubScreen == 0 && selectedQuery != -1) {
                      print("Performing Query : ${filterQueryList[selectedQuery]["QueryString"]}");
                      var ids = await DBProfessionalList.testSystemQuery(filterQueryList[selectedQuery]["QueryString"]);
                      print("Ids = ${ids}");

                      var response = await DBProfessionalList.getAttributes(accountType, true, ids);
                      print("Total records = ${lItems.length}");
                      print("sorted records = ${response["data"].length}");

                      this.setState(() {
                        lItems = response["data"];
                        isFiltered = true;
                        filterList = response["data"];
                      });
                      selectedList = -1;
                      selectedAlert = -1;
                      Navigator.pop(context);
                    } else if (selectedSubScreen == 1) {
                      String queryAfterWhere = "";
                      for (int i = 0; i < selectedField.length; i++) {
                        Map<String, dynamic> map = selectedField[i];
                        if (map["selected"]) {
                          String str =
                              "( AttributeCode = '${attributeList[i]["AttributeCode"].toString()}' and AttributeValue in (${map["selected_variables"].toString().replaceAll("~", ",")}) )";

                          if (queryAfterWhere == "") {
                            queryAfterWhere = str;
                          } else {
                            queryAfterWhere += " AND " +
                                "CustomerId in (select CustomerId from ProfessionalListAttribute where " +
                                str +
                                ")";
                          }
                        }
                      }
                      String finalQuery = "select CustomerId from ProfessionalListAttribute where $queryAfterWhere";
                      print("Final Query1 = ${finalQuery}");

                      String queryToSave = "CustomerId IN ($finalQuery) and AccountType = '$accountType'";

                      var ids = await DBProfessionalList.testSystemQuery(queryToSave);
                      print("Ids = ${ids}");

                      var response = await DBProfessionalList.getAttributes(accountType, true, ids);
                      print("Total records = ${lItems.length}");
                      print("sorted records = ${response["data"].length}");

                      this.setState(() {
                        lItems = response["data"];
                        isFiltered = true;
                        filterList = response["data"];
                      });
                      selectedList = -1;
                      selectedAlert = -1;
                      selectedQuery = -1;
                      Navigator.pop(context);
                    } else if (selectedSubScreen == 2) {
                      String selectedVariables = "";
                      for (int i = 0; i < attributeVariableList.length; i++) {
                        if (selectedFieldVariable[i]) {
                          if (selectedVariables == "") {
                            selectedVariables = "'" + attributeVariableList[i]["AttributeValue"] + "'";
                          } else {
                            selectedVariables += "~'" + attributeVariableList[i]["AttributeValue"] + "'";
                          }
                        }
                      }
                      if (selectedVariables != "") {
                        Map<String, dynamic> dt = new HashMap();
                        dt["selected"] = true;
                        dt["selected_variables"] = selectedVariables;
                        selectedField[currentSelectedField] = dt;
                      } else {
                        Map<String, dynamic> dt = new HashMap();
                        dt["selected"] = false;
                        dt["selected_variables"] = selectedVariables;
                        selectedField[currentSelectedField] = dt;
                      }
                      setState(() {
                        selectedSubScreen = 1;
                      });
                      print("selected Values = ${selectedField[currentSelectedField]}");
                    }
                  } else if (selected == 1 && selectedList != -1) {
                    List<dynamic> listSorted = [];
                    var favorite = listFavorite[selectedList];

                    List<String> LevelIds = favorite["LevelIds"].toString().split("~");
                    String ids = "";
                    for (int j = 0; j < LevelIds.length; j++) {
                      if (j == 0) {
                        ids = "'" + LevelIds[j] + "'";
                      } else {
                        ids = ids + ",'" + LevelIds[j] + "'";
                      }
                    }
                    print("Ids = ${ids}");

                    var response = await DBProfessionalList.getAttributes(accountType, true, ids);
                    print("Total records = ${lItems.length}");
                    print("sorted records = ${response["data"].length}");

                    this.setState(() {
                      lItems = response["data"];
                      isFiltered = true;
                      filterList = response["data"];
                    });
                    selectedQuery = -1;
                    selectedAlert = -1;
                    selectedField = [];
                    selectedSubScreen = 0;
                    selectedFieldVariable = [];
                    cnt.text = "";
                    cnt_search.text = "";
                    selected = 1;
                    Navigator.pop(context);
                  } else if (selected == 2 && selectedAlert != -1) {
                    List<dynamic> alertData = await DBProfessionalList.prformQueryOperation(
                        "SELECT AcctKeyId FROM MessageData WHERE Sender='${alertList[selectedAlert]["Sender"]}' AND AcctType = '" +
                            accountType +
                            "' AND ShowInInbox = 'N'",
                        []);
                    print("Alert Data = ${alertData}");

                    String ids = "";
                    for (int j = 0; j < alertData.length; j++) {
                      if (j == 0) {
                        ids = "'" + alertData[j]["AcctKeyId"] + "'";
                      } else {
                        ids = ids + ",'" + alertData[j]["AcctKeyId"] + "'";
                      }
                    }
                    print("Ids = ${ids}");

                    var response = await DBProfessionalList.getAttributes(accountType, true, ids);
                    print("Total records = ${lItems.length}");
                    print("sorted records = ${response["data"].length}");

                    this.setState(() {
                      lItems = response["data"];
                      isFiltered = true;
                      filterList = response["data"];
                    });

                    selectedQuery = -1;
                    selectedList = -1;
                    selectedSubScreen = 0;
                    selectedFieldVariable = [];
                    cnt.text = "";
                    cnt_search.text = "";
                    selected = 2;
                    Navigator.pop(context);
                  }
                },
                child: new Text("Done"),
              ),
              alignment: Alignment.centerRight,
            )),
      ],
    ));
    col.add(new Container(
      width: MediaQuery.of(context).size.width,
      child: CupertinoSegmentedControl<int>(
        unselectedColor: themeData.primaryColor,
        selectedColor: themeData.accentColor,
        borderColor: Colors.grey,
        children: dt,
        onValueChanged: (int val) {
          print("Selected: ${val}");
          setState(() {
            selected = val;
          });
        },
        groupValue: selected,
      ),
    ));
    if (selected == 0) {
      if (selectedSubScreen == 0) {
        col.add(new Container(
            margin: EdgeInsets.only(top: 10),
            height: 300,
            child: new Column(
              children: <Widget>[
                new GestureDetector(
                  onTap: () async {
                    var listAttributes = await DBProfessionalList.prformQueryOperation(
                        "SELECT DISTINCT AttributeCode FROM ProfessionalListAttribute where AccountType='$accountType'",
                        []);
                    print("ListAttributes = ${listAttributes}");
                    attributeList = listAttributes;

                    for (int i = 0; i < attributeList.length; i++) {
                      Map<String, dynamic> dt = new HashMap();
                      dt["selected"] = false;
                      dt["selected_variables"] = "";
                      selectedField.add(dt);
                    }
                    setState(() {
                      selectedSubScreen = 1;
                    });
                  },
                  child: new Container(
                    decoration:
                    BoxDecoration(border: Border(bottom: BorderSide(width: 0.3, color: Color(0xFFFFAAAAAA)))),
                    margin: EdgeInsets.all(5),
                    height: 25,
                    width: MediaQuery.of(context).size.width,
                    child: new Text(
                      "New Query",
                      style: TextStyle(color: AppColors.grey_color),
                    ),
                  ),
                ),
                new Expanded(
                  child: ListView.builder(
                      itemCount: filterQueryList.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return new Container(
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(width: 0.3, color: Color(0xFFFFAAAAAA)))),
                            margin: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: 40,
                            child: new Align(
                              alignment: Alignment.centerLeft,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                      child: new GestureDetector(
                                        onTap: () async {
//                                var response = await DBProfessionalList.testSystemQuery(filterQueryList[index]["QueryString"]);
//                                print("sorted records = ${response}");
//                                print("sorted records length = ${response.length}");
                                          setState(() {
                                            if (selectedQuery == index) {
                                              selectedQuery = -1;
                                            } else {
                                              selectedQuery = index;
                                            }
                                          });
                                        },
                                        child: new Container(
                                          child: new Text(
                                            filterQueryList[index]["QueryName"],
                                            style: listItemTextStyle,
                                          ),
                                        ),
                                      )),
                                  selectedQuery == index
                                      ? new Container(
                                    margin: EdgeInsets.only(right: 10),
                                    width: 20,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: AppColors.main_color,
                                    ),
                                  )
                                      : new Container()
                                ],
                              ),
                            ));
                      }),
                )
              ],
            )));
      }
      else if (selectedSubScreen == 1) {
        col.add(new Container(
            margin: EdgeInsets.only(top: 10),
            height: 300,
            child: new Column(
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new GestureDetector(
                      onTap: () {
//                        //currentSelectedField = -1;
                        setState(() {
                          selectedSubScreen = 0;
                        });
                      },
                      child: new Container(
                        height: 35,
                        width: 35,
                        child: Icon(
                          Icons.arrow_back,
                          color: AppColors.main_color,
                        ),
                      ),
                    ),
                    new Expanded(
                        child: new Container(
                          margin: EdgeInsets.only(left: 15, right: 15),
                          child: new TextField(
                            controller: cnt,
                            decoration: new InputDecoration(
                              hintText: 'Enter Query Name',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                            ),
                          ),
                        )),
                    new GestureDetector(
                      onTap: () async {
                        if (cnt.text.trim() != "") {
                          bool isSingleSelectedField = false;
                          for (int i = 0; i < selectedField.length; i++) {
                            if (selectedField[i]["selected"]) {
                              isSingleSelectedField = true;
                              break;
                            }
                          }
                          print("isSingle Selected : ${isSingleSelectedField}");
                          if (isSingleSelectedField) {
                            String queryAfterWhere = "";
                            for (int i = 0; i < selectedField.length; i++) {
                              Map<String, dynamic> map = selectedField[i];
                              if (map["selected"]) {
                                String str =
                                    "( AttributeCode = '${attributeList[i]["AttributeCode"].toString()}' and AttributeValue in (${map["selected_variables"].toString().replaceAll("~", ",")}) )";

                                if (queryAfterWhere == "") {
                                  queryAfterWhere = str;
                                } else {
                                  queryAfterWhere += " AND " + str;
                                }
                              }
                            }


                            String finalQuery =
                                "select CustomerId from ProfessionalListAttribute where $queryAfterWhere";
                            print("Final Query2 = ${finalQuery}");
                            String queryToSave = "CustomerId IN ($finalQuery) and AccountType = '$accountType'";

//                        var res = await DBProfessionalList.prformQueryOperation(finalQuery, []);
//                        print("Response from final query $res");

                            if (cnt.text == "") {
                              Constants_data.toastError("Please enter Query Name");
                            } else {
                              var uuid = Uuid();
                              Map<String, String> dataToSave = new HashMap();
                              dataToSave["AccountType"] = accountType;
                              dataToSave["QueryName"] = cnt.text;
                              dataToSave["QueryString"] = queryToSave;
                              dataToSave["isDelete"] = "NO";

                              try {
                                var dataUser;
                                if (Constants_data.app_user == null) {
                                  dataUser = await StateManager.getLoginUser();
                                } else {
                                  dataUser = Constants_data.app_user;
                                }
                                String url1 = "/SaveFilterQueries?RepId=${dataUser["RepId"]}";
                                var data = await _helper.post(url1, dataToSave, true);
                                print('Success in response ${data}');
                                String url = '/GetFilterQueries?RepId=${dataUser["RepId"]}';
                                final res = await _helper.get(url);
                                var mainData = res["dt_ReturnedTables"][0];
                                print("Response  GetFilterQueries: ${mainData}");
                                filterQueryList = [];

                                for (int i = 0; i < mainData.length; i++) {
                                  if (mainData[i]["AccountType"] == accountType) {
                                    filterQueryList.add(mainData[i]);
                                  }
                                }

                                cnt.text = "";

                                setState(() {
                                  selected = 0;
                                  selectedSubScreen = 0;
                                  selectedField = [];
                                  selectedFieldVariable = [];
                                });
                              } on Exception catch (err) {
                                print('Errorn in response ${err}');
                                Constants_data.toastError("$err");
                              }
                            }

                            // String query =
                            //     "select CustomerId from ProfessionalListAttribute where ( AttributeCode = 'City' and AttributeValue in ('DALY CITY','SALINAS'))";
                          } else {
                            Constants_data.toastError("Please select at least one Attribute");
                          }
                        } else {
                          Constants_data.toastError("Query name can't be blank");
                        }
                      },
                      child: new Container(
                        margin: EdgeInsets.only(right: 15),
                        height: 35,
                        child: Center(
                            child: new Text(
                              "Save",
                            )),
                      ),
                    ),
                  ],
                ),
                new Expanded(
                  child: ListView.builder(
                      itemCount: attributeList.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return new Container(
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(width: 0.3, color: Color(0xFFFFAAAAAA)))),
                            margin: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: 40,
                            child: new Align(
                              alignment: Alignment.centerLeft,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                      child: new GestureDetector(
                                        onTap: () async {
                                          Map<String, dynamic> dt = selectedField[index];
                                          List<String> selectedList = [];
                                          if (dt["selected"]) {
                                            selectedList = dt["selected_variables"].toString().split("~");
                                            print("Default selected Values = ${dt}");
                                          }
                                          selectedFieldVariable = [];
                                          var attributeValue = await DBProfessionalList.prformQueryOperation(
                                              "SELECT DISTINCT AttributeValue FROM ProfessionalListAttribute where AttributeCode='${attributeList[index]["AttributeCode"]}' AND AccountType='$accountType'",
                                              []);
                                          print("AttributeValue = ${attributeValue}");
                                          attributeVariableList = attributeValue;
                                          for (int i = 0; i < attributeVariableList.length; i++) {
                                            bool isFound = false;
                                            if (dt["selected"]) {
                                              for (int j = 0; j < selectedList.length; j++) {
                                                if (selectedList[j] ==
                                                    "'" + attributeVariableList[i]["AttributeValue"] + "'") {
                                                  isFound = true;
                                                }
                                              }
                                              if (isFound) {
                                                selectedFieldVariable.add(true);
                                              } else {
                                                selectedFieldVariable.add(false);
                                              }
                                            } else {
                                              selectedFieldVariable.add(false);
                                            }
                                          }
                                          currentSelectedField = index;

                                          setState(() {
                                            selectedSubScreen = 2;
                                          });
//
//                                      setState(() {
//                                        selectedField[index]["selected"] = !selectedField[index]["selected"];
//                                      });
                                        },
                                        child: new Container(
                                          child: new Text(
                                            attributeList[index]["AttributeCode"],
                                            style: listItemTextStyle,
                                          ),
                                        ),
                                      )),
                                  selectedField[index]["selected"]
                                      ? new Container(
                                    margin: EdgeInsets.only(right: 10),
                                    width: 20,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: AppColors.main_color,
                                    ),
                                  )
                                      : new Container()
                                ],
                              ),
                            ));
                      }),
                )
              ],
            )));
      }
      else if (selectedSubScreen == 2) {
        col.add(new Container(
            margin: EdgeInsets.only(top: 10),
            height: 300,
            child: new Column(
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new GestureDetector(
                      onTap: () {
//                        //currentSelectedField = -1;
                        setState(() {
                          selectedSubScreen = 1;
                        });
                      },
                      child: new Container(
                        height: 35,

                        width: 35,
                        child: Icon(
                          Icons.arrow_back,
                          color: AppColors.main_color,
                        ),
                      ),
                    ),
                    new Expanded(
                        child: new Container(
                          height: 35,
                          margin: EdgeInsets.only(left: 15, right: 15),
                          child: new TextField(
                            controller: cnt_search,
                            onChanged: (str) async {
                              if (str != "") {
                                Map<String, dynamic> dt = selectedField[currentSelectedField];
                                List<String> selectedList = [];
                                if (dt["selected"]) {
                                  selectedList = dt["selected_variables"].toString().split("~");
                                  print("Default selected Values = ${dt}");
                                }
                                selectedFieldVariable = [];
                                var attributeValue = await DBProfessionalList.prformQueryOperation(
                                    "SELECT DISTINCT AttributeValue FROM ProfessionalListAttribute where AttributeValue LIKE '%${str}%' AND AttributeCode='${attributeList[currentSelectedField]["AttributeCode"]}' AND AccountType='$accountType'",
                                    []);
                                print("AttributeValue = ${attributeValue}");
                                attributeVariableList = attributeValue;
                                for (int i = 0; i < attributeVariableList.length; i++) {
                                  bool isFound = false;
                                  if (dt["selected"]) {
                                    for (int j = 0; j < selectedList.length; j++) {
                                      if (selectedList[j] == "'" + attributeVariableList[i]["AttributeValue"] + "'") {
                                        isFound = true;
                                      }
                                    }
                                    if (isFound) {
                                      selectedFieldVariable.add(true);
                                    } else {
                                      selectedFieldVariable.add(false);
                                    }
                                  } else {
                                    selectedFieldVariable.add(false);
                                  }
                                }
                              } else {
                                Map<String, dynamic> dt = selectedField[currentSelectedField];
                                List<String> selectedList = [];
                                if (dt["selected"]) {
                                  selectedList = dt["selected_variables"].toString().split("~");
                                  print("Default selected Values = ${dt}");
                                }
                                selectedFieldVariable = [];
                                var attributeValue = await DBProfessionalList.prformQueryOperation(
                                    "SELECT DISTINCT AttributeValue FROM ProfessionalListAttribute where AttributeCode='${attributeList[currentSelectedField]["AttributeCode"]}' AND AccountType='$accountType'",
                                    []);
                                print("AttributeValue = ${attributeValue}");
                                attributeVariableList = attributeValue;
                                for (int i = 0; i < attributeVariableList.length; i++) {
                                  bool isFound = false;
                                  if (dt["selected"]) {
                                    for (int j = 0; j < selectedList.length; j++) {
                                      if (selectedList[j] == "'" + attributeVariableList[i]["AttributeValue"] + "'") {
                                        isFound = true;
                                      }
                                    }
                                    if (isFound) {
                                      selectedFieldVariable.add(true);
                                    } else {
                                      selectedFieldVariable.add(false);
                                    }
                                  } else {
                                    selectedFieldVariable.add(false);
                                  }
                                }
                                currentSelectedField = currentSelectedField;
                              }

                              setState(() {
                                selectedSubScreen = 2;
                              });
                            },
                            decoration: new InputDecoration(
                              hintText: 'Search',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                            ),
                          ),
                        )),
                  ],
                ),
                Expanded(
                    child: ListView.builder(
                        itemCount: attributeVariableList.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return new Container(
                              decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(width: 0.3, color: Color(0xFFFFAAAAAA)))),
                              margin: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: 40,
                              child: new Align(
                                alignment: Alignment.centerLeft,
                                child: new Row(
                                  children: <Widget>[
                                    new Expanded(
                                        child: new GestureDetector(
                                          onTap: () async {
                                            setState(() {
                                              selectedFieldVariable[index] = !selectedFieldVariable[index];
                                            });
                                          },
                                          child: new Container(
                                            child: new Text(
                                              "${attributeVariableList[index]["AttributeValue"]}",
                                              style: listItemTextStyle,
                                            ),
                                          ),
                                        )),
                                    selectedFieldVariable[index]
                                        ? new Container(
                                      margin: EdgeInsets.only(right: 10),
                                      width: 20,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: AppColors.main_color,
                                      ),
                                    )
                                        : new Container()
                                  ],
                                ),
                              ));
                        }))
              ],
            )));
      }
    }
    else if (selected == 1) {
      col.add(new Container(
        margin: EdgeInsets.only(top: 10),
        height: 300,
        child: listFavorite.length > 0
            ? ListView.builder(
            itemCount: listFavorite.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return new Container(
                  decoration:
                  BoxDecoration(border: Border(bottom: BorderSide(width: 0.3, color: Color(0xFFFFAAAAAA)))),
                  margin: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 40,
                  child: new Align(
                    alignment: Alignment.centerLeft,
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                            child: new GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (selectedList == index) {
                                    selectedList = -1;
                                  } else {
                                    selectedList = index;
                                  }
                                });
                              },
                              child: new Container(
                                child: new Text(
                                  listFavorite[index]["Name"],
                                  style: listItemTextStyle,
                                ),
                              ),
                            )),
                        selectedList == index
                            ? new Container(
                          margin: EdgeInsets.only(right: 10),
                          width: 20,
                          child: Icon(
                            Icons.check_circle,
                            color: AppColors.main_color,
                          ),
                        )
                            : new Container()
                      ],
                    ),
                  ));
            })
            : Center(child: Text("List is not available")),
      ));
    }
    else if (selected == 2) {
      col.add(new Container(
        margin: EdgeInsets.only(top: 10),
        height: 300,
        child: alertList.length > 0
            ? ListView.builder(
            itemCount: alertList.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return new Container(
                  decoration:
                  BoxDecoration(border: Border(bottom: BorderSide(width: 0.3, color: Color(0xFFFFAAAAAA)))),
                  margin: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 40,
                  child: new Align(
                    alignment: Alignment.centerLeft,
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                            child: new GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (selectedAlert == index) {
                                    selectedAlert = -1;
                                  } else {
                                    selectedAlert = index;
                                  }
                                });
                              },
                              child: new Container(
                                child: new Text(
                                  alertList[index]["Sender"],
                                  style: listItemTextStyle,
                                ),
                              ),
                            )),
                        selectedAlert == index
                            ? new Container(
                          margin: EdgeInsets.only(right: 10),
                          width: 20,
                          child: Icon(
                            Icons.check_circle,
                            color: AppColors.main_color,
                          ),
                        )
                            : new Container()
                      ],
                    ),
                  ));
            })
            : Center(child: Text("Alert is not available")),
      ));
    }
    return col;
  }

  void updateApiParameters(Map<String, dynamic> apiParameters) {
    apiParameters["accountType"] = accountType;
    apiParameters["hqCode"] = selectedHQidCode;

    if (accountType == 'HCP') {
      apiParameters["divisionCode"] = selectedDivisionIdcode;
      apiParameters["repCode"] = '${user["RepId"]}';
    }if (accountType == 'FGO') {
      apiParameters["divisionCode"] = selectedDivisionIdcode;
    }
  }
  void updateApiParametersinit(div,hqid) {
    apiParameters["accountType"] = accountType;
    apiParameters["hqCode"] = hqid;

    if (accountType == 'HCP') {
      apiParameters["divisionCode"] = div;
      apiParameters["repCode"] = '${user["RepId"]}';
    }
    if (accountType == 'FGO') {
      apiParameters["divisionCode"] = Constants_data.selectedDivisionId;
    }
  }

  Future<void> getDivisionData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      StateManager.loginUser(user);
      divisions = await StateManager.getDivisionManager();
      hqs = await StateManager.gethqManager();

      if (!["", null, {}].contains(divisions)) {
        Set<String> uniqueHQCodes = Set<String>();
        List<Map<String, dynamic>> uniqueHQs = [];
        for (var hq in hqs) {
          if (uniqueHQCodes.add(hq['hq_code'])) {
            uniqueHQs.add(hq);
          }
        }

        // ScrollControllers for Divisions and HQ sections
        ScrollController divisionScrollController = ScrollController();
        ScrollController hqScrollController = ScrollController();

        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            String selectedDivisionLocal = Constants_data.selectedDivisionId;
            String selectedHqLocal = Constants_data.selectedHQCode;
            return AlertDialog(
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Stack(
                    children: [
                      Container(
                        height: 400,
                        width: double.maxFinite,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Division Section
                            Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1.0),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Select Division',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(height: 10),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxHeight: 120),
                                    child: Scrollbar(
                                      controller: divisionScrollController,
                                      thumbVisibility: true, // Makes scrollbar visible
                                      child: ListView.builder(
                                        controller: divisionScrollController,
                                        shrinkWrap: true,
                                        itemCount: divisions.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          return RadioListTile<String>(
                                            title: Text("${divisions[index]['division_name']}"),
                                            value: divisions[index]['division'],
                                            groupValue: selectedDivisionIdcode,
                                            onChanged: (String value) {
                                              if (value != null) {
                                                setState(() {
                                                  selectedDivisionLocal = value;
                                                  // Constants_data.selectedDivisionId = value;
                                                  // Constants_data.selectedDivisionName = divisions[index]['division_name'];
                                                  selectedDivisionIdcode = value;
                                                  selectedDivisionidName = divisions[index]['division_name'];
                                                });
                                                // Immediately update the parent state
                                                // this.setState(() {
                                                //   selectedDivisionidName = divisions[index]['division_name'];
                                                // });
                                                print('Selected Division ID: $selectedDivisionIdcode');
                                              }
                                            },
                                            activeColor: Colors.blue,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            // HQ Section
                            Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1.0),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Select Headquarter',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(height: 10),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxHeight: 100),
                                    child: Scrollbar(
                                      controller: hqScrollController,
                                      thumbVisibility: true, // Makes scrollbar visible
                                      child: ListView.builder(
                                        controller: hqScrollController,
                                        shrinkWrap: true,
                                        itemCount: uniqueHQs.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          return RadioListTile<String>(
                                            title: Text("${uniqueHQs[index]['hq_name']}"),
                                            value: uniqueHQs[index]['hq_code'],
                                            groupValue: selectedHQidCode,
                                            onChanged: (String value) {
                                              if (value != null) {
                                                setState(() {
                                                  selectedHqLocal = value;
                                                  selectedHQidCode = value;
                                                  selectedHQidName = uniqueHQs[index]['hq_name'];
                                                });
                                                print('Selected Headquarters Code: ${selectedHQidCode}');
                                              }
                                            },
                                            activeColor: Colors.blue,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Positioned(
                      //   bottom: 10,
                      //   right: 10,
                      //   child: ElevatedButton(
                      //     onPressed: () async {
                      //       if (selectedDivisionIdcode != null &&
                      //           selectedDivisionidName.isNotEmpty &&
                      //           selectedHQidCode != null &&
                      //           selectedHQidCode.isNotEmpty) {
                      //         Navigator.of(context).pop();
                      //       } else {
                      //         Constants_data.toastError("Please select both Division and HQ");
                      //       }
                      //     },
                      //     child: Text('OK'),
                      //   ),
                      // ),

                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (selectedDivisionIdcode != null &&
                                //selectedDivisionidName.isNotEmpty &&
                                selectedHQidCode != null
                               // && selectedHQidCode.isNotEmpty
                            ) {
                              updateApiParameters(apiParameters); // Update parameters
                              isLoaded = false;
                              await getProfessionalData(apiname, apiParameters);
                              Navigator.of(context).pop();
                            } else {
                              Constants_data.toastError("Please select both Division and HQ");
                            }
                          },
                          child: Text('OK'),
                        ),
                      )
                    ],
                  );
                },
              ),
            );
          },
        );
      } else {
        Constants_data.toastNormal("Division or HQ data not found.");
      }
    });
  }

}