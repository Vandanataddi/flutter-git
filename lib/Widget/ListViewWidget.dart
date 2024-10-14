import 'package:flexi_profiler/Widget/CreateViewFromTemplateJson.dart';
import 'package:flutter/material.dart';

class ListViewWidget extends StatefulWidget {
  ListViewWidget({@required this.templateJson, @required this.listData, this.onItemClick});

  Map<String, dynamic> templateJson;
  List<dynamic> listData;
  Function onItemClick;

  @override
  _ScreenState createState() => _ScreenState(templateJson: templateJson, listData: listData, onItemClick: onItemClick);
}

class _ScreenState extends State<ListViewWidget> {
  _ScreenState({@required this.templateJson, @required this.listData, this.onItemClick});

  Map<String, dynamic> templateJson;
  List<dynamic> listData;
  Function onItemClick;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: EdgeInsets.all(0.0),
        itemCount: listData.length,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return CreateViewFromTemplateJson(
              templateJson: templateJson, data: listData[index], param: index, onClick: onItemClick);
        });
  }
}
