import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Constants/const.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreateViewFromTemplateJson extends StatefulWidget {
  CreateViewFromTemplateJson({@required this.templateJson, @required this.data, this.onClick, this.param});

  Map<String, dynamic> templateJson;
  Map<String, dynamic> data;
  final Function onClick;
  final dynamic param;

  @override
  _ScreenState createState() => _ScreenState(onClick, data, templateJson, param);
}

class _ScreenState extends State<CreateViewFromTemplateJson> {
  Map<String, dynamic> templateJson;
  Map<String, dynamic> data;
  final Function onClick;
  final dynamic param;

  _ScreenState(this.onClick, this.data, this.templateJson, this.param);

  DarkThemeProvider themeChange;
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    final currancy_format = new NumberFormat("${templateJson["currency_formate"]}", "en_IN");
    String currency_symbol = templateJson["currency_symbol"];
    List<Widget> cols = [];
    for (int j = 0; j < templateJson["Row"].length; j++) {
      List<Widget> rows = [];
      for (int i = 0; i < templateJson["Row"][j].length; i++) {
        Map<String, dynamic> singleRow = templateJson["Row"][j][i];
        Widget vi = Expanded(
          flex: singleRow["flex"],
          child: Container(),
        );
        String text, label;
        if (singleRow["widget_type"].toString() == "Text" && singleRow["is_currency"] == "Y") {
          text =
              "$currency_symbol" + currancy_format.format(double.parse("${data[singleRow["widget_id"]].toString()}"));
        } else {
          text = data[singleRow["widget_id"]].toString();
          if (text == null || text == "") {
            text = "N/A";
          }
        }
        if (singleRow["widget_type"].toString() == "Label" && singleRow["label"].toString() != "") {
          label = "${singleRow["label"].toString()}";
        } else if (singleRow["label"].toString() != "") {
          label = "${singleRow["label"].toString()} : ";
        }
        if (singleRow["widget_type"].toString() == "Text") {
          vi = Expanded(
              flex: singleRow["flex"],
              child: Container(
                alignment: singleRow["align"] == "left" ? Alignment.centerLeft : Alignment.centerRight,
                padding: EdgeInsets.symmetric(vertical: 3),
                child: textWidget(singleRow, label, text),
              ));
        } else if (singleRow["widget_type"].toString() == "Divider") {
          vi = Container(
            height: 50,
            width: 1,
            color: AppColors.grey_color,
            margin: EdgeInsets.only(right: 5),
          );
        } else if (singleRow["widget_type"].toString() == "icon") {
          vi = Center(
            child: new Icon(
              data[singleRow["widget_id"]].toString() == 'up' ? Icons.arrow_upward : Icons.arrow_downward,
              color: data[singleRow["widget_id"]].toString() == 'up' ? Colors.green : AppColors.red_color,
            ),
          );
        }
        rows.add(vi);
      }
      cols.add(Row(
        children: rows,
      ));
    }

    return Container(
        margin: EdgeInsets.symmetric(
          horizontal: 5,
        ),
        child: Card(
            elevation: themeChange.darkTheme ? null : 3,
            child: InkWell(
                onTap: onClick == null
                    ? null
                    : () {
                        onClick(data, param);
                      },
                child: Container(
                    padding: EdgeInsets.fromLTRB(7.0, 10.0, 10.0, 7.0),
                    child: Row(
                      children: [
                        templateJson["isShowLeadingIcon"].toString() == "Y"
                            ? Expanded(
                                flex: 1,
                                child: Center(
                                  child: Icon(
                                      data[templateJson["LeadingIconFrom"]].toString() == 'up'
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      color: data[templateJson["LeadingIconFrom"]].toString() == 'up'
                                          ? Colors.green
                                          : AppColors.red_color,
                                      size: 25),
                                ))
                            : Container(),
                        Expanded(
                            flex: templateJson["isShowLeadingIcon"].toString() == "Y" ? 8 : 9,
                            child: Column(
                              children: cols,
                            )),
                        templateJson["isShowTailIcon"].toString() == "Y"
                            ? Expanded(
                                flex: 1,
                                child: Center(
                                  child: Icon(
                                    data[templateJson["TrailIconFrom"]].toString() == 'up'
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: data[templateJson["TrailIconFrom"]].toString() == 'up'
                                        ? Colors.green
                                        : AppColors.red_color,
                                    size: 25,
                                  ),
                                ))
                            : Container(),
                        templateJson["isClickable"] == "Y"
                            ? Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: greyColor,
                                    size: 20,
                                  ),
                                ))
                            : Container(),
                      ],
                    )))));
  }

  Widget textWidget(Map<String, dynamic> singleRow, String label, String text) {
    return singleRow["orientation"].toString() != null && singleRow["orientation"].toString() == "V"
        ? Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            singleRow["label"].toString() != ""
                ? Container(
                    constraints: BoxConstraints(maxWidth: 100),
                    margin: EdgeInsets.only(bottom: 5),
                    child: Text(
                      label.replaceAll(" : ", ""),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize:
                              Constants_data.getFontSize(context, int.parse(singleRow["txt_size"].toString()) - 2),
                          color: AppColors.grey_color),
                    ))
                : Container(),
            Flexible(
                child: Text(
              text,
              overflow: TextOverflow.visible,
              style: TextStyle(
                fontWeight: singleRow["txt_style"].toString() == "Bold" ? FontWeight.bold : FontWeight.normal,
                fontSize: Constants_data.getFontSize(context, int.parse(singleRow["txt_size"].toString())),
                // color: Constants_data.hexToColor(singleRow["txt_color"].toString()
              ),
            )),
          ])
        : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            singleRow["label"].toString() != ""
                ? Container(
                    constraints: BoxConstraints(maxWidth: 100),
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: Constants_data.getFontSize(context, int.parse(singleRow["txt_size"].toString())),
                          color: AppColors.grey_color),
                    ))
                : Container(),
            Flexible(
                child: Text(
              text,
              overflow: TextOverflow.visible,
              style: TextStyle(
                fontWeight: singleRow["txt_style"].toString() == "Bold" ? FontWeight.bold : FontWeight.normal,
                fontSize: Constants_data.getFontSize(context, int.parse(singleRow["txt_size"].toString())),
                // color: Constants_data.hexToColor(singleRow["txt_color"].toString()
              ),
            )),
          ]);
  }
}
