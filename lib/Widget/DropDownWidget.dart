import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flexi_profiler/Theme/StyleClass.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDropdown extends StatelessWidget {
  final Function onChanged;
  final Map<String, dynamic> templateJson;
  final bool isHideUnderline;

  CustomDropdown(
      {Key key, @required this.onChanged, @required this.templateJson,this.isHideUnderline=false})
      : super(key: key);

  ThemeData themeData;
  DarkThemeProvider themeChange;

  @override
  Widget build(BuildContext context) {
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    List<DropdownMenuItem> items = [];
    List<dynamic> listItems = [];

    listItems = templateJson["options"];

    for (int k = 0; k < listItems.length; k++) {
      items.add(DropdownMenuItem(value: k, child: Text(listItems[k]["name"])));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        templateJson["label"] != null && templateJson["label"] != ""
            ? Container(
              margin: EdgeInsets.only(right: 5),
                child: Text(
                  templateJson["label"].toString() + " : ",
                  style: themeData.textTheme.caption,
                ),
              )
            : Container(),
        Expanded(
            child: DropdownButton(
                underline: isHideUnderline ? SizedBox() : null,
                isExpanded: true,
                items: items,
                hint: Text("Select"),
                style: Styles.h4.copyWith(color: themeData.primaryColorLight),
                onChanged: (val) {
                  this.onChanged(val, listItems[val]);
                },
                value: templateJson["defaultSelection"] == null
                    ? null
                    : int.parse(templateJson["defaultSelection"].toString())))
      ],
    );
  }
}
