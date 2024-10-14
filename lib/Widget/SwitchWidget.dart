import 'dart:io';

import 'package:flexi_profiler/Constants/const.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SwitchWidget extends StatelessWidget {
  final Function onChanged;

  final Map<String, dynamic> templateJson;

  SwitchWidget({Key key, @required this.onChanged, @required this.templateJson}) : super(key: key);

  ThemeData themeData;
  DarkThemeProvider themeChange;

  @override
  Widget build(BuildContext context) {
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Platform.isIOS
            ? CupertinoSwitch(
                value: templateJson["defaultSelection"],
                onChanged: onChanged,
              )
            : Switch(
                value: templateJson["defaultSelection"],
                onChanged: onChanged,
              ),
        templateJson["label"] != null && templateJson["label"] != ""
            ? Container(
                child: Text(
                  templateJson["label"].toString(),
                  style: themeData.textTheme.caption,
                ),
              )
            : Container(),
      ],
    );
  }
}
