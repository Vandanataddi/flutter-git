import 'package:connectycube_sdk/connectycube_chat.dart';
import 'package:flexi_profiler/ChatConnectyCube/api_utils.dart';
import 'package:flexi_profiler/ChatConnectyCube/chat_dialog_screen.dart';
import 'package:flexi_profiler/ChatConnectyCube/new_group_dialog_screen.dart';
import 'package:flexi_profiler/ChatConnectyCube/widgets/common.dart';
import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Constants/const.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateChatScreen extends StatefulWidget {
  final CubeUser _cubeUser;

  @override
  State<StatefulWidget> createState() {
    return _CreateChatScreenState(_cubeUser);
  }

  CreateChatScreen(this._cubeUser);
}

class _CreateChatScreenState extends State<CreateChatScreen> {
  final CubeUser currentUser;

  _CreateChatScreenState(this.currentUser);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BodyLayout(currentUser);
    return WillPopScope(
      onWillPop: () => _onBackPressed(context),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(
            'Logged in as ${currentUser.login}',
          ),
        ),
        body: BodyLayout(currentUser),
      ),
    );
  }

  Future<bool> _onBackPressed(BuildContext context) {
    Navigator.pop(context);
    return Future.value(false);
  }
}

class BodyLayout extends StatefulWidget {
  final CubeUser currentUser;

  BodyLayout(this.currentUser);

  @override
  State<StatefulWidget> createState() {
    return _BodyLayoutState(currentUser);
  }
}

class _BodyLayoutState extends State<BodyLayout> {
  static const String TAG = "_BodyLayoutState";

  final CubeUser currentUser;
  List<CubeUser> userList = [];
  Set<int> _selectedUsers = {};
  var _isUsersContinues = false;
  var _isPrivateDialog = true;
  String userToSearch;
  String userMsg = "";

  bool _isDialogContinues = false;

  _BodyLayoutState(this.currentUser);

  _searchUser(value) {
    log("searchUser _user= $value");
    if (value != null)
      setState(() {
        userToSearch = value;
        _isUsersContinues = true;
      });
  }

  bool isLoaded = false;
  DarkThemeProvider themeChange;
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Constants_data.getFlexibleAppBar(themeChange.darkTheme),
        title: Text(
          'All Users',
          style: TextStyle(color: AppColors.white_color, fontWeight: FontWeight.bold),
        ),
        actions: [
          ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isPrivateDialog = !_isPrivateDialog;
                });
              },
              icon: Icon(
                !_isPrivateDialog ? Icons.person : Icons.people,
                color: AppColors.white_color,
              ),
              label: Text(!_isPrivateDialog ? "Private Chat" : "Create Group",
                  style: TextStyle(color: AppColors.white_color)))
        ],
      ),
      body: Container(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Column(
            children: [
              //_buildDialogButton(),
              SizedBox(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.only(left: 8),
                child: Visibility(
                  maintainSize: false,
                  maintainAnimation: false,
                  maintainState: false,
                  visible: _isUsersContinues,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
              Expanded(
                child: !isLoaded
                    ? FutureBuilder<dynamic>(
                        future: _getUsersList(context),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            return ListView.builder(
                              itemCount: userList.length,
                              itemBuilder: _getListItemTile,
                            );
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      )
                    : ListView.builder(
                        itemCount: userList.length,
                        itemBuilder: _getListItemTile,
                      ),
              ),
            ],
          )),
      floatingActionButton: new Visibility(
        visible: !_isPrivateDialog,
        child: FloatingActionButton(
          heroTag: "New dialog",
          child: Icon(
            Icons.check,
            color: AppColors.white_color,
          ),
          backgroundColor: AppColors.main_color,
          onPressed: () => _createDialog(context, _selectedUsers, true),
        ),
      ),
    );
  }

  Widget _buildDialogButton() {
    getIcon() {
      if (_isPrivateDialog) {
        return Icons.person;
      } else {
        return Icons.people;
      }
    }

    getDescription() {
      if (_isPrivateDialog) {
        return "Create group chat";
      } else {
        return "Create private chat";
      }
    }

    return new Container(
      alignment: Alignment.centerLeft,
      child: ElevatedButton.icon(
        icon: Icon(
          getIcon(),
          size: 25.0,
          color: themeColor,
        ),
        onPressed: () {
          setState(() {
            _isPrivateDialog = !_isPrivateDialog;
          });
        },
        label: Text(getDescription()),
      ),
    );
  }

  Future<Null> _getUsersList(BuildContext context) async {
    // clearValues() {
    //   _isUsersContinues = false;
    //   userToSearch = null;
    //   userMsg = " ";
    //   userList.clear();
    // }

    if (userList.length == 0) {
      PagedResult<CubeUser> users = await getAllUsers();
      print("------------- All Users : ${users.items}");
      log("getusers: $users", TAG);
      // clearValues();
      for (int i = 0; i < users.items.length; i++) {
        if (currentUser.id != users.items[i].id) {
          userList.add(users.items[i]);
        }
      }
      //userList.addAll(users.items);
      isLoaded = true;
    }

    // getAllUsers().then((users) {
    //   print("------------- All Users : ${users.items}");
    //   log("getusers: $users", TAG);
    //   setState(() {
    //     clearValues();
    //     userList.addAll(users.items);
    //   });
    // }).catchError((onError) {
    //   print("------------- All Users Error: ${onError.toString()}");
    //   log("getusers catchError: $onError", TAG);
    //   setState(() {
    //     clearValues();
    //     userMsg = "Couldn't find user";
    //   });
    // });

    if (userToSearch != null && userToSearch.isNotEmpty) {
      // getUsersByFullName(userToSearch).then((users) {
      //   log("getusers: $users", TAG);
      //   setState(() {
      //     clearValues();
      //     userList.addAll(users.items);
      //   });
      // }).catchError((onError) {
      //   log("getusers catchError: $onError", TAG);
      //   setState(() {
      //     clearValues();
      //     userMsg = "Couldn't find user";
      //   });
      // });
    }

    // if (userList.isEmpty)
    //   return FittedBox(
    //     fit: BoxFit.contain,
    //     child: Text(userMsg),
    //   );
    // else
    //   return ;
  }

  Widget _getListItemTile(BuildContext context, int index) {
    getPrivateWidget() {
      return Container(
        child: MaterialButton(
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: themeData.hintColor,
                backgroundImage: userList[index].avatar != null && userList[index].avatar.isNotEmpty
                    ? NetworkImage(userList[index].avatar)
                    : null,
                radius: 20,
                child: getAvatarTextWidget(userList[index].avatar != null && userList[index].avatar.isNotEmpty,
                    userList[index].fullName.substring(0, 2).toUpperCase()),
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          '${userList[index].fullName}',
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
              _isPrivateDialog
                  ? Container(
                      child: Icon(
                        Icons.arrow_forward,
                        size: 25.0,
                        color: themeData.hintColor,
                      ),
                    )
                  : Container(
                      child: Checkbox(
                        value: _selectedUsers.contains(userList[index].id),
                        onChanged: ((checked) {
                          setState(() {
                            if (checked) {
                              _selectedUsers.add(userList[index].id);
                            } else {
                              _selectedUsers.remove(userList[index].id);
                            }
                          });
                        }),
                      ),
                    ),
            ],
          ),
          onPressed: () {
            if (_isPrivateDialog) {
              _createDialog(context, {userList[index].id}, false);
            }
          },
          color: themeData.cardColor,
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }

    getGroupWidget() {
      return Container(
        child: MaterialButton(
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: themeData.hintColor,
                backgroundImage: userList[index].avatar != null && userList[index].avatar.isNotEmpty
                    ? NetworkImage(userList[index].avatar)
                    : null,
                radius: 20,
                child: getAvatarTextWidget(userList[index].avatar != null && userList[index].avatar.isNotEmpty,
                    userList[index].fullName.substring(0, 2).toUpperCase()),
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          '${userList[index].fullName}',
                          style: TextStyle(color: primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
              Container(
                child: Checkbox(
                  value: _selectedUsers.contains(userList[index].id),
                  onChanged: ((checked) {
                    setState(() {
                      if (checked) {
                        _selectedUsers.add(userList[index].id);
                      } else {
                        _selectedUsers.remove(userList[index].id);
                      }
                    });
                  }),
                ),
              ),
            ],
          ),
          onPressed: () {
            setState(() {
              if (_selectedUsers.contains(userList[index].id)) {
                _selectedUsers.remove(userList[index].id);
              } else {
                _selectedUsers.add(userList[index].id);
              }
            });
          },
          color: greyColor2,
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }

    getItemWidget() {
      return getPrivateWidget();
      if (_isPrivateDialog) {
        return getPrivateWidget();
      } else {
        return getGroupWidget();
      }
    }

    return getItemWidget();
  }

  void _createDialog(BuildContext context, Set<int> users, bool isGroup) async {
    log("_createDialog with users= $users");
    if (isGroup) {
      CubeDialog newDialog = CubeDialog(CubeDialogType.GROUP, occupantsIds: users.toList());
      List<CubeUser> usersToAdd =
          users.map((id) => userList.firstWhere((user) => user.id == id, orElse: () => null)).toList();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewGroupDialogScreen(currentUser, newDialog, usersToAdd),
        ),
      );
    } else {
      _isDialogContinues = true;
      CubeDialog newDialog = CubeDialog(CubeDialogType.PRIVATE, occupantsIds: users.toList());
      createDialog(newDialog).then((createdDialog) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDialogScreen(currentUser, createdDialog),
          ),
        );
      }).catchError(_processCreateDialogError);
    }
  }

  void _processCreateDialogError(exception) {
    log("Login error $exception", TAG);
    setState(() {
      _isDialogContinues = false;
    });
    showDialogError(exception, context);
  }

  @override
  void initState() {
    super.initState();
    log("initState");
  }
}
