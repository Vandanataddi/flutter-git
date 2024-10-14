import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flexi_profiler/ChatConnectyCube/chat_dialog_screen.dart';
import 'package:flexi_profiler/ChatConnectyCube/new_dialog_screen.dart';
import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Constants/const.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'api_utils.dart';

class SelectDialogScreen extends StatelessWidget {
  static const String TAG = "SelectDialogScreen";
  final CubeUser currentUser;

  SelectDialogScreen(this.currentUser);

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
          'Messages',
        ),
      ),
      body: BodyLayout(currentUser),
    );
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
  List<ListItem<CubeDialog>> dialogList = [];
  var _isDialogContinues = true;
  StreamSubscription<CubeMessage> msgSubscription;
  final ChatMessagesManager chatMessagesManager = CubeChatConnection.instance.chatMessagesManager;

  _BodyLayoutState(this.currentUser);

  DarkThemeProvider themeChange;
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(bottom: 16, top: 16),
        child: Column(
          children: [
            Visibility(
              visible: _isDialogContinues && dialogList.isEmpty,
              child: Container(
                margin: EdgeInsets.all(40),
                alignment: FractionalOffset.center,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
            Expanded(
              child: _getDialogsList(context),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "New dialog",
        child: Icon(
          Icons.add,
          color: AppColors.white_color,
        ),
        backgroundColor: AppColors.main_color,
        onPressed: () => _createNewDialog(context),
      ),
    );
  }

  void _createNewDialog(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateChatScreen(currentUser),
      ),
    ).then((value) => refresh());
  }

  void _processGetDialogError(exception) {
    log("GetDialog error $exception", TAG);
    setState(() {
      _isDialogContinues = false;
    });
    showDialogError(exception, context);
  }

  void _deleteDialog(BuildContext context, CubeDialog dialog) async {
    log("_deleteDialog= $dialog");
    Fluttertoast.showToast(msg: 'Coming soon');
  }

  void _openDialog(BuildContext context, CubeDialog dialog) async {
    log("_openDialog= $dialog");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDialogScreen(currentUser, dialog),
      ),
    ).then((value) => refresh());
  }

  void refresh() {
    setState(() {
      _isDialogContinues = true;
    });
  }

  getUnread(int index, String dialogId) {
    List<String> dialogsIds = ["$dialogId"];
    getUnreadMessagesCount(dialogsIds).then((unreadCount) {
      print("UnreadMsg : $unreadCount");
      int unread = unreadCount[dialogId] != null ? unreadCount[dialogId] : 0;
      this.setState(() {
        dialogList[index].unreadCount = unread;
      });
      print("UnreadMsg : $unread");
    }).catchError((error) {
      print("UnreadMsg Error: ${error}");
    });
  }

  Widget _getDialogsList(BuildContext context) {
    if (_isDialogContinues) {
      getDialogs().then((dialogs) {
        _isDialogContinues = false;
        log("getDialogs: $dialogs", TAG);
        setState(() {
          dialogList.clear();

          for (int i = 0; i < dialogs.items.length; i++) {
            getUnread(i, dialogs.items[i].dialogId);
            dialogList.add(ListItem(dialogs.items[i]));
          }

          //dialogList.addAll(dialogs.items.map((dialog) => ListItem(dialog)).toList());
        });
      }).catchError(_processGetDialogError);
    }
    if (_isDialogContinues && dialogList.isEmpty)
      return SizedBox.shrink();
    else if (dialogList.isEmpty)
      return Center(
        child: Text(
          "You don't have any conversation yet.\n\nPress '+' button to start conversation.",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      );
    else
      return ListView.separated(
        itemCount: dialogList.length,
        itemBuilder: _getListItemTile,
        separatorBuilder: (context, index) {
          return Divider(thickness: 0.5, indent: 10, endIndent: 10,color: themeData.hintColor,);
        },
      );
  }

  Widget _getListItemTile(BuildContext context, int index) {
    getDialogIcon() {
      var dialog = dialogList[index].data;
      if (dialog.type == CubeDialogType.PRIVATE)
        return Icon(
          Icons.person,
          size: 30.0,
          color: greyColor,
        );
      else {
        return Icon(
          Icons.group,
          size: 30.0,
          color: greyColor,
        );
      }
    }

    getDialogAvatarWidget() {
      var dialog = dialogList[index].data;
      if (dialog.photo == null || dialog.photo == "") {
        return CircleAvatar(radius: 17, backgroundColor: themeData.hintColor, child: getDialogIcon());
      } else {
        return CachedNetworkImage(
          placeholder: (context, url) => Container(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
            ),
            width: 35.0,
            height: 35.0,
            padding: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: themeData.hintColor,
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
          ),
          imageUrl: dialogList[index].data.photo,
          width: 35.0,
          height: 35.0,
          fit: BoxFit.cover,
        );
      }
    }

    return Container(
      child: MaterialButton(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5),
            child:Row(
          children: <Widget>[
            Material(
              child: getDialogAvatarWidget(),
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
              clipBehavior: Clip.hardEdge,
            ),
            Expanded(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        '${dialogList[index].data.name ?? 'Not available'}',
                        style: TextStyle(color: themeData.accentColor, fontWeight: FontWeight.bold, fontSize: 15.0),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 5.0),
                    ),
                    Container(
                      child: Text(
                        '${dialogList[index].data.lastMessage ?? 'Not available'}',
                        style: TextStyle(color: themeData.primaryColorLight),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                    ),
                  ],
                ),
                margin: EdgeInsets.only(left: 20.0),
              ),
            ),
            Visibility(
              child: IconButton(
                iconSize: 20.0,
                icon: Icon(
                  Icons.delete,
                  color: themeData.accentColor,
                ),
                onPressed: () {
                  _deleteDialog(context, dialogList[index].data);
                },
              ),
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              visible: dialogList[index].isSelected,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  child: Text(
                    '${dialogList[index].data.lastMessageDateSent != null ? timeago.format(DateTime.fromMillisecondsSinceEpoch(dialogList[index].data.lastMessageDateSent * 1000)) : 'Not available'}',
                    style: TextStyle(color: themeData.textTheme.caption.color, fontSize: 13),
                  ),
                ),
                dialogList[index].unreadCount == 0
                    ? Container(
                        height: 25,
                        width: 25,
                        margin: EdgeInsets.all(3),
                      )
                    : Container(
                        height: 25,
                        width: 25,
                        padding: EdgeInsets.all(2),
                        margin: EdgeInsets.all(3),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: themeData.accentColor),
                        child: Center(
                            child: Text(dialogList[index].unreadCount > 10 ? "10+" : "${dialogList[index].unreadCount}",
                                style: TextStyle(color: AppColors.white_color, fontSize: 11, fontWeight: FontWeight.bold))),
                      )
              ],
            )
          ],
        )),
        onLongPress: () {
          setState(() {
            dialogList[index].isSelected = !dialogList[index].isSelected;
          });
        },
        onPressed: () {
          _openDialog(context, dialogList[index].data);
        },
        color: dialogList[index].isSelected ? Colors.black12 : Colors.transparent,
        padding: EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 0.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      margin: EdgeInsets.only(left: 5.0, right: 5.0),
    );
  }

  @override
  void initState() {
    super.initState();
    chatMessagesManager.chatMessagesStream.listen((newMessage) {
      print("New messageReceived : ${newMessage.toJson()}");
      updateDialog(newMessage);
    }).onError((error) {
      print("New messageReceived Error : $error");
    });
  }

  @override
  void dispose() {
    super.dispose();
    msgSubscription.cancel();
  }

  void onReceiveMessage(CubeMessage message) {
    log("onReceiveMessage global message= $message");
    updateDialog(message);
  }

  updateDialog(CubeMessage msg) {
    ListItem<CubeDialog> dialogItem = dialogList.firstWhere((dlg) {
      return dlg.data.dialogId == msg.dialogId;
    }, orElse: () => null);
    if (dialogItem == null) return;
    {
      List<String> dialogsIds = ["${msg.dialogId}"];
      getUnreadMessagesCount(dialogsIds).then((unreadCount) {
        print("UnreadMsg : $unreadCount");
        int unread = unreadCount[msg.dialogId] != null ? unreadCount[msg.dialogId] : 0;
        this.setState(() {
          dialogItem.unreadCount = unread;
        });
      }).catchError((error) {
        print("UnreadMsg Error: ${error}");
      });
      dialogItem.data.lastMessage = msg.body;
      dialogItem.data.lastMessageDateSent = msg.dateSent;
      dialogList.sort((a, b) => b.data.lastMessageDateSent.compareTo(a.data.lastMessageDateSent));
    }
    setState(() {
      dialogItem.data.lastMessage = msg.body;
      dialogItem.data.lastMessageDateSent = msg.dateSent;
      dialogList.sort((a, b) => b.data.lastMessageDateSent.compareTo(a.data.lastMessageDateSent));
    });
  }
}
