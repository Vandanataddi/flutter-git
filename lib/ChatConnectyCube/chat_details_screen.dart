import 'dart:async';
import 'dart:io';

import 'package:flexi_profiler/ChatConnectyCube/widgets/common.dart';

import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Constants/const.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'add_occupant_screen.dart';
import 'api_utils.dart';

class ChatDetailsScreen extends StatelessWidget {
  final CubeUser _cubeUser;
  final CubeDialog _cubeDialog;

  ChatDetailsScreen(this._cubeUser, this._cubeDialog);

  DarkThemeProvider themeChange;
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    return WillPopScope(
      onWillPop: () => _onBackPressed(context),
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Constants_data.getFlexibleAppBar(themeChange.darkTheme),
          title: Text(
            _cubeDialog.type == CubeDialogType.PRIVATE ? "Contact details" : "Group details",
          ),
          centerTitle: false,
          actions: <Widget>[],
        ),
        body: DetailScreen(_cubeUser, _cubeDialog),
      ),
    );
  }

  Future<bool> _onBackPressed(BuildContext context) {
    Navigator.pop(context);
    return Future.value(false);
  }
}

class DetailScreen extends StatefulWidget {
  static const String TAG = "DetailScreen";
  final CubeUser _cubeUser;
  final CubeDialog _cubeDialog;

  DetailScreen(this._cubeUser, this._cubeDialog);

  @override
  State createState() => _cubeDialog.type == CubeDialogType.PRIVATE
      ? ContactScreenState(_cubeUser, _cubeDialog)
      : GroupScreenState(_cubeUser, _cubeDialog);
}

abstract class ScreenState extends State<DetailScreen> {
  final CubeUser _cubeUser;
  CubeDialog _cubeDialog;
  final Map<int, CubeUser> _occupants = Map();
  var _isProgressContinues = false;

  ScreenState(this._cubeUser, this._cubeDialog);

  @override
  void initState() {
    super.initState();
    if (_occupants.isEmpty) {
      initUsers();
    }
  }

  initUsers() async {
    _isProgressContinues = true;
    var result = await getUsersByIds(_cubeDialog.occupantsIds.toSet());
    _occupants.clear();
    _occupants.addAll(result);
    _occupants.remove(_cubeUser.id);
    setState(() {
      _isProgressContinues = false;
    });
  }
}

class ContactScreenState extends ScreenState {
  CubeUser contactUser;

  initUser() {
    contactUser = _occupants.values.isNotEmpty ? _occupants.values.first : CubeUser(fullName: "Absent");
  }

  ContactScreenState(_cubeUser, _cubeDialog) : super(_cubeUser, _cubeDialog);

  @override
  Widget build(BuildContext context) {
    initUser();
    return Scaffold(
      body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(60),
          child: Column(
            children: [
              _buildAvatarFields(),
              _buildTextFields(),
              _buildButtons(),
              Container(
                margin: EdgeInsets.only(left: 8),
                child: Visibility(
                  maintainSize: false,
                  maintainAnimation: false,
                  maintainState: false,
                  visible: _isProgressContinues,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildAvatarFields() {
    if (_isProgressContinues) {
      return SizedBox.shrink();
    }
    return Stack(
      children: <Widget>[
        CircleAvatar(
          backgroundImage:
              contactUser.avatar != null && contactUser.avatar.isNotEmpty ? NetworkImage(contactUser.avatar) : null,
          backgroundColor: greyColor2,
          radius: 50,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(55),
            child: Text(
              contactUser.fullName.substring(0, 2).toUpperCase(),
              style: TextStyle(fontSize: 40),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFields() {
    if (_isProgressContinues) {
      return SizedBox.shrink();
    }
    return Container(
      margin: EdgeInsets.all(50),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              right: 10, left: 10,
              bottom: 3, // space between underline and text
            ),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
              color: primaryColor, // Text colour here
              width: 1.0, // Underline width
            ))),
            child: Text(
              contactUser.fullName,
              style: TextStyle(
                color: primaryColor,
                fontSize: 20, // Text colour here
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildButtons() {
    if (_isProgressContinues) {
      return SizedBox.shrink();
    }
    return new Container(
      child: new Column(
        children: <Widget>[
          new MaterialButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0), side: BorderSide(color: blueColor)),
            child: Text(
              'Start dialog',
              style: TextStyle(
                color: AppColors.white_color,
                fontSize: 20, // Text colour here
              ),
            ),
            onPressed: () => Navigator.pop(context),
            color: blueColor,
          ),
        ],
      ),
    );
  }
}

class GroupScreenState extends ScreenState {
  final picker = ImagePicker();
  final TextEditingController _nameFilter = new TextEditingController();
  String _photoUrl = "";
  String _name = "";
  Set<int> _usersToRemove = {};
  List<int> _usersToAdd;

  GroupScreenState(_cubeUser, _cubeDialog) : super(_cubeUser, _cubeDialog) {
    _nameFilter.addListener(_nameListen);
    _nameFilter.text = _cubeDialog.name;
    clearFields();
  }

  void _nameListen() {
    if (_nameFilter.text.isEmpty) {
      _name = "";
    } else {
      _name = _nameFilter.text.trim();
    }
  }

  DarkThemeProvider themeChange;
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    return Scaffold(
      body: Container(
          margin: EdgeInsets.all(15),
          child: Column(
            children: [
              _buildPhotoFields(),
              SizedBox(
                height: 10,
              ),
              _buildTextFields(),
              Expanded(child: _buildGroupFields()),
              Container(
                margin: EdgeInsets.only(left: 8),
                child: Visibility(
                  maintainSize: false,
                  maintainAnimation: false,
                  maintainState: false,
                  visible: _isProgressContinues,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        heroTag: "Update dialog",
        child: Icon(
          Icons.check,
          color: AppColors.white_color,
        ),
        backgroundColor: AppColors.main_color,
        onPressed: () => _updateDialog(),
      ),
    );
  }

  Widget _buildPhotoFields() {
    if (_isProgressContinues) {
      return SizedBox.shrink();
    }
    Widget avatarCircle = CircleAvatar(
      backgroundImage:
          _cubeDialog.photo != null && _cubeDialog.photo.isNotEmpty ? NetworkImage(_cubeDialog.photo) : null,
      backgroundColor: greyColor2,
      radius: 50,
      child: getAvatarTextWidget(
          _cubeDialog.photo != null && _cubeDialog.photo.isNotEmpty, _cubeDialog.name.substring(0, 2).toUpperCase()),
    );

    return new Stack(
      children: <Widget>[
        InkWell(
          borderRadius: BorderRadius.circular(45),
          onTap: () => _chooseUserImage(),
          child: avatarCircle,
        ),
        new Positioned(
          child: RawMaterialButton(
            onPressed: () {
              _chooseUserImage();
            },
            elevation: 2.0,
            fillColor: themeData.accentColor,
            child: Icon(
              Icons.mode_edit,
              size: 20.0,
              color: Colors.white,
            ),
            padding: EdgeInsets.all(5.0),
            shape: CircleBorder(),
          ),
          top: 55.0,
          right: 35.0,
        ),
      ],
    );
  }

  _chooseUserImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    var image = File(pickedFile.path);
    uploadFile(image, isPublic: true).then((cubeFile) {
      _photoUrl = cubeFile.getPublicUrl();
      setState(() {
        _cubeDialog.photo = _photoUrl;
      });
    }).catchError(_processUpdateError);
  }

  Widget _buildTextFields() {
    if (_isProgressContinues) {
      return SizedBox.shrink();
    }
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Container(
            child: TextField(
              style: TextStyle(fontSize: 15.0),
              controller: _nameFilter,
              decoration: InputDecoration(labelText: 'Change group name'),
            ),
          ),
        ],
      ),
    );
  }

  _buildGroupFields() {
    if (_isProgressContinues) {
      return SizedBox.shrink();
    }
    return Column(
      children: <Widget>[
        _addMemberBtn(),
        //_removeMemberBtn(),
        Expanded(child: _getUsersList()),
        _exitGroupBtn(),
      ],
    );
  }

  Widget _addMemberBtn() {
    return Row(
      children: [
        Expanded(
            child: Container(
          margin: EdgeInsets.all(5),
          child: InkWell(
            borderRadius: BorderRadius.circular(45),
            onTap: () => _addOpponent(),
            child: Container(
                decoration: BoxDecoration(
                  color: themeData.accentColor,
                  borderRadius: BorderRadius.circular(45),
                ),
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      child: Text(
                        'Add member',
                        style: TextStyle(
                          color: AppColors.white_color,
                          fontSize: 15, // Text colour here
                        ),
                      ),
                      padding: EdgeInsets.only(left: 5),
                    ),
                  ],
                )),
          ),
        )),
        Expanded(
            child: Container(
          margin: EdgeInsets.all(5),
          child: InkWell(
            splashColor: greyColor2,
            borderRadius: BorderRadius.circular(45),
            onTap: () => _removeOpponent(),
            child: Container(
                decoration: BoxDecoration(
                  color: _usersToRemove.isEmpty ? AppColors.grey_color : themeData.accentColor,
                  borderRadius: BorderRadius.circular(45),
                ),
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Icon(
                    //   Icons.person_remove,
                    //   color: AppColors.white_color,
                    // ),
                    Padding(
                      child: Text(
                        'Remove member',
                        style: TextStyle(
                          color: AppColors.white_color,
                          fontSize: 15, // Text colour here
                        ),
                      ),
                      padding: EdgeInsets.only(left: 5),
                    ),
                  ],
                )),
          ),
        ))
      ],
    );
  }

  Widget _removeMemberBtn() {
    if (_usersToRemove.isEmpty) {
      return SizedBox.shrink();
    }
    return Container(
      padding: EdgeInsets.only(
        bottom: 3, // space between underline and text
      ),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
        color: greyColor, // Text colour here
        width: 1.0, // Underline width
      ))),
      child: InkWell(
        splashColor: greyColor2,
        borderRadius: BorderRadius.circular(45),
        onTap: () => _removeOpponent(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(
                Icons.person_outline,
                size: 35.0,
                color: blueColor,
              ),
            ),
            Padding(
              child: Text(
                'Remove member',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 20, // Text colour here
                ),
              ),
              padding: EdgeInsets.only(left: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getUsersList() {
    if (_isProgressContinues) {
      return SizedBox.shrink();
    }
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: ListView.separated(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          primary: false,
          itemCount: _occupants.length,
          itemBuilder: _getListItemTile,
          separatorBuilder: (context, index) {
            return Divider(thickness: 1, indent: 10, endIndent: 10,color: themeData.hintColor,);
          },
        ));
  }

  Widget _getListItemTile(BuildContext context, int index) {
    final user = _occupants.values.elementAt(index);
    Widget getUserAvatar() {
      if (user.avatar != null && user.avatar.isNotEmpty) {
        return CircleAvatar(
          backgroundImage: NetworkImage(user.avatar),
          backgroundColor: greyColor2,
          radius: 25.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(55),
          ),
        );
      } else {
        return Material(
          child: Icon(
            Icons.account_circle,
            size: 50.0,
            color: greyColor,
          ),
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
          clipBehavior: Clip.hardEdge,
        );
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        child: Row(
          children: <Widget>[
            getUserAvatar(),
            Flexible(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        '${user.fullName}',
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    ),
                  ],
                ),
                margin: EdgeInsets.only(left: 5.0),
              ),
            ),
            Container(
              child: Checkbox(
                value: _usersToRemove.contains(_occupants.values.elementAt(index).id),
                onChanged: ((checked) {
                  setState(() {
                    if (checked) {
                      _usersToRemove.add(_occupants.values.elementAt(index).id);
                    } else {
                      _usersToRemove.remove(_occupants.values.elementAt(index).id);
                    }
                  });
                }),
              ),
            ),
          ],
        ),
        onTap: () {
          log("user onPressed");
        },
      ),
    );
  }

  Widget _exitGroupBtn() {
    return Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          child: InkWell(
            splashColor: greyColor2,
            borderRadius: BorderRadius.circular(45),
            onTap: () => _exitDialog(),
            child: Container(
                decoration: BoxDecoration(
                  color: AppColors.red_color,
                  borderRadius: BorderRadius.circular(45),
                ),
                padding: EdgeInsets.all(7),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.exit_to_app,
                      color: AppColors.white_color,
                    ),
                    Padding(
                      child: Text(
                        'Leave Group',
                        style: TextStyle(
                          color: AppColors.white_color,
                          fontSize: 15, // Text colour here
                        ),
                      ),
                      padding: EdgeInsets.only(left: 16),
                    ),
                  ],
                )),
          ),
        ));
  }

  void _processUpdateError(exception) {
    log("_processUpdateUserError error $exception");
    setState(() {
      clearFields();
      _isProgressContinues = false;
    });
    showDialogError(exception, context);
  }

  _addOpponent() async {
    print('_addOpponent');
    _usersToAdd = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddOccupantScreen(_cubeUser, _cubeDialog),
      ),
    );
    if (_usersToAdd != null && _usersToAdd.isNotEmpty) _updateDialog();
  }

  _removeOpponent() async {
    print('_removeOpponent');
    if (_usersToRemove != null && _usersToRemove.isNotEmpty) _updateDialog();
  }

  _exitDialog() {
    print('_exitDialog');
    deleteDialog(_cubeDialog.dialogId).then((onValue) {
      Fluttertoast.showToast(msg: 'Success');
      Navigator.of(context).popUntil(ModalRoute.withName("/SelectDialogScreen"));
    }).catchError(_processUpdateError);
  }

  void _updateDialog() {
    print('_updateDialog $_name');
    if (_name.isEmpty && _photoUrl.isEmpty && (_usersToAdd?.isEmpty ?? true) && (_usersToRemove?.isEmpty ?? true)) {
      Fluttertoast.showToast(msg: 'Nothing to save');
      return;
    }
    Map<String, dynamic> params = {};
    if (_name.isNotEmpty) params['name'] = _name;
    if (_photoUrl.isNotEmpty) params['photo'] = _photoUrl;
    if (_usersToAdd?.isNotEmpty ?? false) params['push_all'] = {'occupants_ids': List.of(_usersToAdd)};
    if (_usersToRemove?.isNotEmpty ?? false) params['pull_all'] = {'occupants_ids': List.of(_usersToRemove)};

    setState(() {
      _isProgressContinues = true;
    });
    updateDialog(_cubeDialog.dialogId, params).then((dialog) {
      _cubeDialog = dialog;
      Fluttertoast.showToast(msg: 'Success');
      setState(() {
        if ((_usersToAdd?.isNotEmpty ?? false) || (_usersToRemove?.isNotEmpty ?? false)) initUsers();
        _isProgressContinues = false;
        clearFields();
      });
    }).catchError(_processUpdateError);
  }

  clearFields() {
    _name = '';
    _photoUrl = '';
    _usersToAdd = null;
    _usersToRemove.clear();
  }
}
