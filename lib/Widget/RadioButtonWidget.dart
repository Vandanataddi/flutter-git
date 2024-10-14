import 'package:flexi_profiler/Constants/const.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RadioButtonWidget extends StatelessWidget {
  final Function onChanged;
  final Map<String, dynamic> templateJson;
  final int groupValue;

  RadioButtonWidget({Key key, @required this.onChanged,  @required this.templateJson,@required this.groupValue})
      : super(key: key);

  ThemeData themeData;
  DarkThemeProvider themeChange;

  @override
  Widget build(BuildContext context) {
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio(
          value: templateJson["value"],
          groupValue: groupValue,
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
