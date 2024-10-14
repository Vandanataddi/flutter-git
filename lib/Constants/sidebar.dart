import 'dart:async' as tem;
import 'dart:core';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flexi_profiler/ChatConnectyCube/pref_util.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Constants/sizeConfigue.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import '../DBClasses/ApiBaseHelper.dart';
import 'AppColors.dart';
import 'StateManager.dart';
import 'menu_item.dart';
// import 'package:flutter_menu/flutter_menu.dart';

class SideBar extends StatefulWidget {
  final Function onTap;

  SideBar(this.onTap);

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> with SingleTickerProviderStateMixin<SideBar> {

  AnimationController _animationController;
  tem.StreamController<bool> isSidebarOpenedStreamController;
  tem.Stream<bool> isSidebarOpenedStream;
  tem.StreamSink<bool> isSidebarOpenedSink;
  final _animationDuration = const Duration(milliseconds: 500);
  bool isLogin = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: _animationDuration);
    isSidebarOpenedStreamController = PublishSubject<bool>();
    isSidebarOpenedStream = isSidebarOpenedStreamController.stream;
    isSidebarOpenedSink = isSidebarOpenedStreamController.sink;
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        this.setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    isSidebarOpenedStreamController.close();
    isSidebarOpenedSink.close();
    super.dispose();
  }

  void onIconPressed() {
    final animationStatus = _animationController.status;
    final isAnimationCompleted = animationStatus == AnimationStatus.completed;

    if (isAnimationCompleted) {
      isSidebarOpenedSink.add(false);
      _animationController.reverse();
    } else {
      isSidebarOpenedSink.add(true);
      _animationController.forward();
    }
  }

  DarkThemeProvider themeChange;
  ThemeData themeData;

  var currentUser;
  ApiBaseHelper _helper = ApiBaseHelper();
  final String _baseprofileUrl = Constants_data.profileUrl;

  @override
  Widget build(BuildContext context) {
    Constants_data.currentScreenContext = context;
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    SizeConfig().init(context);


    return StreamBuilder<bool>(
      initialData: false,
      stream: isSidebarOpenedStream,
      builder: (context, isSideBarOpenedAsync) {
        return AnimatedPositioned(
          duration: _animationDuration,
          top: 0,
          bottom: 0,
          left: isSideBarOpenedAsync.data ? 0 : -screenWidth,
          right: isSideBarOpenedAsync.data ? 0 : screenWidth - 40,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  color: themeChange.darkTheme ? themeData.cardColor : Constants_data.hexToColor("#467fc9"),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 80,
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: new BorderRadius.all(
                                  Radius.circular(Constants_data.getFontSize(context, 30)),
                                ),
                                border: Border.all(
                                  width: 2,
                                  color: themeData.primaryColor,
                                )),
                            height: Constants_data.getFontSize(context, 45),
                            width: Constants_data.getFontSize(context, 45),
                            child: (Constants_data.ProfilePicURL == "$_baseprofileUrl/content/ProfilePic/null" ||
                                Constants_data.ProfilePicURL == "null" ||
                                Constants_data.ProfilePicURL.isEmpty)
                            // child: Constants_data.ProfilePicURL == null || Constants_data.ProfilePicURL == ""
                                ? CircleAvatar(
                                    backgroundColor: AppColors.light_grey_color,
                                    radius: Constants_data.getFontSize(context, 50),
                                    child: new Container(
                                      margin: EdgeInsets.all(
                                        Constants_data.getFontSize(context, 2),
                                      ),
                                      child: Image.asset(
                                        "assets/images/default_user.png",
                                      ),
                                    ),
                                  )
                                : ClipOval(
                                    child: Image.network(
                                    "${Constants_data.ProfilePicURL}",
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes
                                              : null,
                                        ),
                                      );
                                    },
                                  )),
                            margin: EdgeInsets.only(
                              right: Constants_data.getFontSize(context, 5),
                              left: Constants_data.getFontSize(context, 15),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.symmetric(horizontal: Constants_data.getFontSize(context, 10)),
                              // child: Column(
                              //   crossAxisAlignment: CrossAxisAlignment.start,
                              //   children: [
                              //     Text(
                              //       "${Constants_data.username}",
                              //       style: TextStyle(
                              //           color: AppColors.white_color,
                              //           fontSize: SizeConfig.safeBlockHorizontal * 4,
                              //           fontWeight: FontWeight.w800),
                              //     ),
                              //     SizedBox(
                              //       height: 3,
                              //     ),
                              //     Container(
                              //       width:
                              //           MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width * 0.45),
                              //       child: Text(
                              //         "${Constants_data.email}",
                              //         overflow: TextOverflow.ellipsis,
                              //         style: TextStyle(
                              //           color: AppColors.white_color,
                              //           fontSize: SizeConfig.safeBlockHorizontal * 3,
                              //         ),
                              //       ),
                              //     )
                              //   ],
                              // )
                              child :Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (Constants_data.username != null &&
                                      Constants_data.username.isNotEmpty &&
                                      Constants_data.username != "null null")
                                    Text(
                                      "${Constants_data.username}",
                                      style: TextStyle(
                                        color: AppColors.white_color,
                                        fontSize: SizeConfig.safeBlockHorizontal * 4,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  if (Constants_data.username != null &&
                                      Constants_data.username.isNotEmpty &&
                                      Constants_data.username != "null null")
                                    SizedBox(
                                      height: 3,
                                    ),
                                  if (Constants_data.email != null &&
                                      Constants_data.email.isNotEmpty &&
                                      Constants_data.email != "null")
                                    Container(
                                      width: MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width * 0.45),
                                      child: Text(
                                        "${Constants_data.email}",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppColors.white_color,
                                          fontSize: SizeConfig.safeBlockHorizontal * 3,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                          )
                        ],
                      ),
                      // Divider(
                      //   height: Constants_data.getFontSize(context, 40),
                      //   thickness: Constants_data.getFontSize(context, 0.5),
                      //   color: AppColors.white_color.withOpacity(0.3),
                      //   indent: Constants_data.getFontSize(context, 24),
                      //   endIndent: Constants_data.getFontSize(context, 24),
                      // ),
                      getMenuItemss(),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text("Version : ${Constants_data.appVersionCode}",
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: Constants_data.getFontSize(context, 12),
                                      fontWeight: FontWeight.w500)),
                              // Text("Last refresh data on ${Constants_data.lastSyncTime}",
                              //     style: TextStyle(
                              //         color: Colors.white70,
                              //         fontSize: Constants_data.getFontSize(context, 12),
                              //         fontWeight: FontWeight.w500)),
                            ]),
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                  onTap: () {
                    final animationStatus = _animationController.status;
                    final isAnimationCompleted = animationStatus == AnimationStatus.completed;

                    if (isAnimationCompleted) {
                      isSidebarOpenedSink.add(false);
                      _animationController.reverse();
                    }
                  },
                  child: Container(
                      color: !isSideBarOpenedAsync.data || _animationController.isAnimating
                          ? Colors.transparent
                          : AppColors.black_color.withOpacity(0.4),
                      child: Align(
                        alignment: Alignment(0, -0.98),
                        child: GestureDetector(
                          onTap: () {
                            onIconPressed();
                          },
                          child: Container(
                            width: 40,
                            height: 110,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                colorFilter: ColorFilter.mode(
                                    themeChange.darkTheme ? themeData.cardColor : Constants_data.hexToColor("#467fc9"),
                                    BlendMode.srcIn),
                                image: AssetImage(
                                  "assets/images/side_menu_bg.png",
                                ),
                                // fit: BoxFit.cover,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: AnimatedIcon(
                              progress: _animationController.view,
                              icon: AnimatedIcons.menu_close,
                              color: AppColors.white_color,
                              size: 25,
                            ),
                          ),
                        ),
                      ))),
            ],
          ),
        );
      },
    );
  }

  Future<bool> openDialog() async {
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
                        Icons.exit_to_app,
                        size: 30.0,
                        color: AppColors.white_color,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Logout',
                      style: TextStyle(color: AppColors.white_color, fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(15),
                child: Center(child: Text("Are you sure want to Logout?")),
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
                          style: TextStyle(color: AppColors.main_color, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context, 0);
                        },
                        child:
                            Text("LOGOUT", style: TextStyle(color: AppColors.main_color, fontWeight: FontWeight.bold)),
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

  Widget getMenuItemss() {
    List<Widget> menu = [];
    bool isDeviderAdded = false;
    if (Constants_data.sizeMenuItem != null && Constants_data.sizeMenuItem.length > 0) {
      Constants_data.sizeMenuItem.sort((a, b) {
        if (int.parse(a['SeqNo'].toString()) == null || int.parse(b['SeqNo'].toString()) == null) {
          return null;
        }

        if (int.parse(a['SeqNo'].toString()) > int.parse(b['SeqNo'].toString())) {
          return 1;
        }

        if (int.parse(a['SeqNo'].toString()) < int.parse(b['SeqNo'].toString())) {
          return -1;
        }

        if (int.parse(a['SeqNo'].toString()) == int.parse(b['SeqNo'].toString())) {
          return 0;
        }

        return null;
      });
      var data;
      for (int i = 0; i < Constants_data.sizeMenuItem.length; i++) {
        Map<String, dynamic> singleMenu = Constants_data.sizeMenuItem[i];
        if (singleMenu["MenuId"].toString().trim() == "31" && singleMenu["IsActive"].toString().trim() == "Y") {
          menu.add(MenuItems(
            icon: Icons.sync,
            title: singleMenu["MenuName"].toString().trim(),
            onTap: () async {
              onIconPressed();
              widget.onTap(0);
            },
          ));
        }
        else if (singleMenu["MenuId"].toString().trim() == "32" && singleMenu["IsActive"].toString().trim() == "Y") {
          menu.add(MenuItems(
            icon: Icons.refresh,
            title: singleMenu["MenuName"].toString().trim(),
            onTap: () async {
              Constants_data.selectedDivisionId = null;
              Constants_data.selectedDivisionName = null;
              Constants_data.selectedHQCode = null;
              Constants_data.selectedHQName = null;
              bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
              if (isNetworkAvailable) {
                var connectivityResult = await (Connectivity()
                    .checkConnectivity());
                if (connectivityResult == ConnectivityResult.mobile ||
                    connectivityResult == ConnectivityResult.wifi) {
                  if (Constants_data.app_user == null) {
                    currentUser = await StateManager.getLoginUser();
                  }
                  else {
                    currentUser = Constants_data.app_user;
                  }
                  StateManager.loginUser(currentUser);
                  print("Current User : ${currentUser}");

                  //currentUser = dataUser;
                  //getFirebaseMessagesBadge();

                  try {
                    String routeUrl = '/Profiler/GetDashboardGridData?RepId=${currentUser["RepId"]}&divisionCode=${Constants_data.selectedDivisionId}';
                    data = await _helper.get(routeUrl);
                    StateManager.setHomeScreenGrid(data);
                  }
                  on Exception catch (err) {
                    print('Error in GetDashboardGridData : $err');
                    data = null;
                  }
                }
                else {
                  var dt = await StateManager.getHomeScreenGrid();
                  if (dt != null) {
                    data = dt;
                  }
                }
                if (data == null && data["Status"] != 1) {
                  data = Constants_data.jsonMenuUpdated;
                  Constants_data.sizeMenuItem = data["dt_ReturnedTables"][1];
                  Constants_data.toastNormal("Data Updated Successfully");
                }
              } else {
                await Constants_data.openDialogNoInternetConection(context);
              }

              onIconPressed();
              widget.onTap(1);
             //var dataUser = await StateManager.getLoginUser();
             // isLogin = await StateManager.isLogin();
              currentUser = await StateManager.getLoginUser();
              Navigator.of(context).pushReplacementNamed('/HomeScreenRMT');
            },
          ));
        }
        else if (singleMenu["MenuId"].toString().trim() == "33" && singleMenu["IsActive"].toString().trim() == "Y") {
          menu.add(MenuItems(
            icon: Icons.mail,
            title: singleMenu["MenuName"].toString().trim(),
            onTap: () async {
              onIconPressed();
              widget.onTap(2);

            },
          ));
        }
        else if (singleMenu["MenuId"].toString().trim() == "34" && singleMenu["IsActive"].toString().trim() == "Y") {
          menu.add(MenuItems(
            icon: Icons.find_in_page,
            title: singleMenu["MenuName"].toString().trim(),
            onTap: () async {
              onIconPressed();
              widget.onTap(3);
            },
          ));
        }
        else if (singleMenu["MenuId"].toString().trim() == "35" && singleMenu["IsActive"].toString().trim() == "Y") {
          menu.add(MenuItems(
            icon: Icons.import_export,
            title: singleMenu["MenuName"].toString().trim(),
            onTap: () async {
              onIconPressed();
              widget.onTap(5);
            },
          ));
        }
        else if (singleMenu["MenuId"].toString().trim() == "36" && singleMenu["IsActive"].toString().trim() == "Y") {
          if (!isDeviderAdded) {
            menu.add(
              Divider(
                height: Constants_data.getFontSize(context, 40),
                thickness: Constants_data.getFontSize(context, 0.5),
                color: AppColors.white_color.withOpacity(0.3),
                indent: Constants_data.getFontSize(context, 24),
                endIndent: Constants_data.getFontSize(context, 24),
              ),
            );
            isDeviderAdded = true;
          }
          menu.add(MenuItems(
            icon: Icons.settings,
            title: singleMenu["MenuName"].toString().trim(),
            onTap: () async {
              onIconPressed();
              widget.onTap(5);
              await Navigator.of(context).pushNamed("/Settings");
            },
          ));
        }
        else if (singleMenu["MenuId"].toString().trim() == "37" && singleMenu["IsActive"].toString().trim() == "Y") {
          if (!isDeviderAdded) {
            menu.add(
              Divider(
                height: Constants_data.getFontSize(context, 40),
                thickness: Constants_data.getFontSize(context, 0.5),
                color: AppColors.white_color.withOpacity(0.3),
                indent: Constants_data.getFontSize(context, 24),
                endIndent: Constants_data.getFontSize(context, 24),
              ),
            );
            isDeviderAdded = true;
          }
          menu.add(MenuItems(
            icon: Icons.exit_to_app,
            title: singleMenu["MenuName"].toString().trim(),
            onTap: () async {
              onIconPressed();
              widget.onTap(6);
              // CubeChatConnection.instance.logout();
              await SharedPrefs.instance.init();
               //SharedPrefs.instance.deleteUser();
               //Constants_data.selectedDivisionId = null;
               // Constants_data.selectedHQCode = null;
              bool result = await openDialog();
              if (result) {
                await StateManager.logout();
                SharedPrefs.instance.deleteUser();
                Constants_data.selectedDivisionName= " ";
                Constants_data.selectedDivisionId = "";
                Constants_data.selectedHQCode = "";
                Constants_data.selectedDivisionIdcode = "";
                Constants_data.selectedHQidCode = "";
                Navigator.pushReplacementNamed(context, "/Login");
              }
         //BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.MyOrdersClickedEvent);
            },
          ));
        }
      }
      return Expanded(
        child: Column(
          children: menu,
        ),
      );
    }
    else {
      return Expanded(
        child: Column(
          children: [
            MenuItems(
              icon: Icons.sync,
              title: "Territory Sync",
              onTap: () async {
                onIconPressed();
                widget.onTap(0);
              },
            ),
            MenuItems(
              icon: Icons.refresh,
              title: "Refresh Data",
              onTap: () async {
                onIconPressed();
                widget.onTap(1);
              },
            ),
            MenuItems(
              icon: Icons.mail,
              title: "Inbox",
              onTap: () async {
                onIconPressed();
                widget.onTap(2);
              },
            ),
            MenuItems(
              icon: Icons.find_in_page,
              title: "Rep Finder",
              onTap: () async {
                onIconPressed();
                widget.onTap(3);
              },
            ),
            Divider(
              height: Constants_data.getFontSize(context, 40),
              thickness: Constants_data.getFontSize(context, 0.5),
              color: AppColors.white_color.withOpacity(0.3),
              indent: Constants_data.getFontSize(context, 24),
              endIndent: Constants_data.getFontSize(context, 24),
            ),
            MenuItems(
              icon: Icons.settings,
              title: "Settings",
              onTap: () async {
                onIconPressed();
                widget.onTap(5);
                await Navigator.of(context).pushNamed("/Settings");
              },
            ),
            MenuItems(
              icon: Icons.exit_to_app,
              title: "Logout",
              onTap: () async {
                onIconPressed();
                widget.onTap(6);
                if (CubeChatConnection.instance != null) {
                  CubeChatConnection.instance.logout();
                } else {
                  print('CubeChatConnection instance is null');
                }
                //CubeChatConnection.instance.logout();
                await SharedPrefs.instance.init();
                //SharedPrefs.instance.deleteUser();
                bool result = await openDialog();
                if (result) {
                  await StateManager.logout();
                  SharedPrefs.instance.deleteUser();
                  Constants_data.selectedDivisionName=null;
                  Constants_data.selectedDivisionId = null;
                  Constants_data.selectedHQCode = null;
                  Constants_data.selectedDivisionIdcode = null;
                  Constants_data.selectedHQidCode = null;
                  Navigator.pushReplacementNamed(context, "/Login");
                }
//                          BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.MyOrdersClickedEvent);
              },
            ),
            Divider(
              height: Constants_data.getFontSize(context, 40),
              thickness: Constants_data.getFontSize(context, 0.5),
              color: AppColors.white_color.withOpacity(0.3),
              indent: Constants_data.getFontSize(context, 24),
              endIndent: Constants_data.getFontSize(context, 24),
            ),
            MenuItems(
              icon: Icons.refresh,
              title: "Refresh Data",
              onTap: () async {
                onIconPressed();
                widget.onTap(1);
              },
            ),
          ],
        ),
      );
    }
  }
}

class CustomMenuClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Paint paint = Paint();
    paint.color = AppColors.white_color;

    final width = size.width;
    final height = size.height;

    Path path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(0, 8, 10, 16);
    path.quadraticBezierTo(width - 1, height / 2 - 20, width, height / 2);
    path.quadraticBezierTo(width + 1, height / 2 + 20, 10, height - 16);
    path.quadraticBezierTo(0, height - 8, 0, height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
