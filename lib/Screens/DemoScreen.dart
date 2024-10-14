import 'package:flexi_profiler/Widget/GridViewWidget.dart';
import 'package:flutter/material.dart';

class DemoScreen extends StatefulWidget {
  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<DemoScreen> {
  @override
  Widget build(BuildContext context) {
    var json = {
      "id": 3,
      "widget_type": "grid",
      "title": "title",
      "sub_title": "count",
      "icon": "img",
      "isShowSubTitle": "Y",
      "title_color": "#0000FF",
      "title_size": "15",
      "sub_title_color": "#000000",
      "sub_title_size": "13",
      "data": [
        {
          "id": 1,
          "title": "Title 1",
          "img": "https://image.freepik.com/free-vector/pack-colorful-square-emoticons_23-2147589525.jpg",
          "count": "20"
        },
        {
          "id": 2,
          "title": "Title 2",
          "img": "https://i.pinimg.com/originals/39/44/6c/39446caa52f53369b92bc97253d2b2f1.png",
          "count": ""
        },
        {
          "id": 3,
          "title": "Title 3",
          "img": "https://i.pinimg.com/originals/39/44/6c/39446caa52f53369b92bc97253d2b2f1.png",
          "count": ""
        },
        {
          "id": 4,
          "title": "Title 4",
          "img": "https://i.pinimg.com/originals/39/44/6c/39446caa52f53369b92bc97253d2b2f1.png",
          "count": ""
        },
        {
          "id": 5,
          "title": "Title 5",
          "img": "https://image.freepik.com/free-vector/pack-colorful-square-emoticons_23-2147589525.jpg",
          "count": ""
        },
        {
          "id": 6,
          "title": "Title 6",
          "img": "https://i.pinimg.com/originals/39/44/6c/39446caa52f53369b92bc97253d2b2f1.png",
          "count": ""
        },
        {
          "id": 7,
          "title": "Title 7",
          "img": "https://i.pinimg.com/originals/39/44/6c/39446caa52f53369b92bc97253d2b2f1.png",
          "count": ""
        },
        {
          "id": 8,
          "title": "Title 8",
          "img": "https://i.pinimg.com/originals/39/44/6c/39446caa52f53369b92bc97253d2b2f1.png",
          "count": ""
        },
        {
          "id": 9,
          "title": "Title 9",
          "img": "https://i.pinimg.com/originals/39/44/6c/39446caa52f53369b92bc97253d2b2f1.png",
          "count": ""
        },
        {
          "id": 10,
          "title": "Title 10",
          "img": "https://image.freepik.com/free-vector/pack-colorful-square-emoticons_23-2147589525.jpg",
          "count": ""
        }
      ]
    };

    return Scaffold(
        appBar: AppBar(
          title: Text('Demo Screen'),
        ),
        body: Container(
            color: Colors.white30,
            child: GridViewWidget(
              listData: json["data"],
              numOfCols: 4,
              templateJson: json,
            )));
  }
}
