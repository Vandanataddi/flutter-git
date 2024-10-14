import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Constants/const.dart';
import 'package:flutter/material.dart';

class GridViewWidget extends StatefulWidget {
  GridViewWidget({
    @required this.listData,
    @required this.numOfCols,
    this.templateJson,
  });

  int numOfCols;
  List<dynamic> listData;
  Map<String, dynamic> templateJson;

  @override
  _ScreenState createState() => _ScreenState(listData: listData, numOfCols: numOfCols, templateJson: templateJson);
}

class _ScreenState extends State<GridViewWidget> {
  _ScreenState({@required this.listData, @required this.numOfCols, this.templateJson});

  int numOfCols;
  String subTitle;
  String image;
  List<dynamic> listData;
  Map<String, dynamic> templateJson;
  String title;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    image = templateJson["icon"].toString();
    title = templateJson["title"].toString();
    subTitle = templateJson["isShowSubTitle"] == "Y" ? templateJson["sub_title"] : null;
  }

  @override
  Widget build(BuildContext context) {
    return _createDynamicTable(listData, numOfCols);
  }

  _createDynamicTable(List<dynamic> listData, int numCols) {
    int numItems = listData.length;
    int remaining = 0;
    int normal = 0;
    if (numItems >= numCols) {
      remaining = numItems % numCols;
      normal = numItems - remaining;
    } else {
      remaining = numItems;
      normal = 0;
    }

    List<TableRow> rows = [];

    for (int i = 0; i < normal;) {
      List<Widget> tild = [];
      for (int j = 0; j < numCols; j++) {
        tild.add(getSingleItem(i));
        i++;
      }
      rows.add(TableRow(children: tild));
    }

    if (remaining > 0) {
      List<TableRow> rows1 = [];
      List<Widget> tild = [];
      for (int i = 0; i < numCols; i++) {
        if (i < remaining) {
          tild.add(getSingleItem(i + normal));
        }
      }
      rows1.add(TableRow(children: tild));

      return ListView.builder(
        itemBuilder: (context, index) {
          return index == 0
              ? Table(children: rows)
              : Table(
                  children: rows1,
                );
        },
        itemCount: 2,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(0.0),
      itemBuilder: (context, index) {
        return Table(children: rows);
      },
      itemCount: 1,
    );
  }

  getSingleItem(int index) {
    print("Color ${listData[index]["color"].toString()}");
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      child: Card(
        color: listData[index]["color"] != null && listData[index]["color"].toString() != ""
            ? Constants_data.hexToColor(listData[index]["color"])
            : templateJson["bg_color"] == null && templateJson["bg_color"].toString() == ""
                ? AppColors.white_color
                : Constants_data.hexToColor(templateJson["bg_color"].toString()),
        child: GestureDetector(
          //padding: EdgeInsets.all(0),
          onTap: () async {},
          child: Container(
              margin: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      child: Text(
                        listData[index][title],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: templateJson["title_color"] == null || templateJson["title_color"] == ""
                              ? AppColors.black_color
                              : Constants_data.hexToColor("${templateJson["title_color"]}"),
                          fontSize: templateJson["title_size"] == null || templateJson["title_size"] == ""
                              ? 15
                              : double.parse("${templateJson["title_size"]}"),
                        ),
                      )),
                  templateJson["icon"] != null && templateJson["icon"] != ""
                      ? Expanded(
                          child: Container(
                              padding: EdgeInsets.all(5),
                              child: LayoutBuilder(builder: (context, constraint) {
                                return CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                                    ),
                                    padding: EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  imageUrl: listData[index][image],
                                  fit: BoxFit.contain,
                                );
                              })))
                      : SizedBox.shrink(),
                  Container(
                      margin: EdgeInsets.only(top: 3),
                      child: Text(
                        "${subTitle == null || listData[index][subTitle] == "" ? "" : "" + listData[index][subTitle] + ""}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: templateJson["sub_title_color"] == null || templateJson["sub_title_color"] == ""
                              ? AppColors.black_color
                              : Constants_data.hexToColor("${templateJson["sub_title_color"]}"),
                          fontSize: templateJson["sub_title_size"] == null || templateJson["sub_title_size"] == ""
                              ? 15.0
                              : double.parse("${templateJson["sub_title_size"]}"),
                        ),
                      )),
                ],
              )),
        ),
      ),
    );
  }

  getRandomColor() {
    return Color((Random().nextDouble() * 0xffffff).toInt()).withOpacity(1.0);
  }
}
