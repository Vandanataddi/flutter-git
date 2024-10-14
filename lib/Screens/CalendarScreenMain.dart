import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Screens/CalendarScreen.dart';
import 'package:flexi_profiler/Screens/CalendarScreenDefault.dart';
import 'package:flexi_profiler/Screens/CalendarScreenAll.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class CalendarScreenMain extends StatefulWidget {
  @override
  _CalendarScreenMainState createState() => _CalendarScreenMainState();
}

class _CalendarScreenMainState extends State<CalendarScreenMain> {
  int selected = 0;

  final Map<int, Widget> dt = <int, Widget>{
    0: new Container(padding: EdgeInsets.all(5), child: Text("Default")),
    1: new Container(padding: EdgeInsets.all(5), child: Text("All")),
  };

  bool isCalendarEnable = true;

  DarkThemeProvider themeChange;
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    Constants_data.currentScreenContext = context;
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    return Scaffold(
        body: new Container(
            child: new Column(
      children: <Widget>[
        Container(
          height: Constants_data.getFontSize(context, 35),
          width: MediaQuery.of(context).size.width,
          color: themeChange.darkTheme ? AppColors.dark_grey_color : AppColors.main_color,
        ),
        new Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          height: 50,
          decoration: BoxDecoration(color: themeChange.darkTheme ? AppColors.dark_grey_color  : AppColors.main_color, boxShadow: [
            BoxShadow(color: Colors.black45, blurRadius: 5.0, spreadRadius: 0.0, offset: Offset(2.0, 2.0))
          ]),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: new Icon(
                    PlatformIcons(context).back,
                    color: Colors.white,
                  )),
              !isCalendarEnable
                  ? CupertinoSegmentedControl<int>(
                      children: dt,
                unselectedColor: themeData.primaryColor,
                selectedColor: themeData.accentColor,
                borderColor: Colors.grey,
                      onValueChanged: (int val) {
                        print("Selected: ${val}");
                        selected = val;
                        this.setState(() {});
                      },
                      groupValue: selected,
                    )
                  : Container(
                      child: Text(
                        "Calendar",
                        style: TextStyle(
                          color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Constants_data.getFontSize(context, 15)),
                      ),
                    ),
              new Row(
                children: <Widget>[
                  InkWell(
                      onTap: () async {
                        await Navigator.pushNamed(context, "/DeviationScreen");
                        if (isCalendarEnable) {
                          this.setState(() {
                            isCalendarEnable = !isCalendarEnable;
                          });
                          await new Future.delayed(const Duration(milliseconds: 200));
                          this.setState(() {
                            isCalendarEnable = !isCalendarEnable;
                          });
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        child: Icon(Icons.directions,color: Colors.white,),
                        //     FaIcon(
                        //   FontAwesomeIcons.directions,
                        //   color: AppColors.main_color,
                        // )
                      )),
                  InkWell(
                      onTap: () {
                        this.setState(() {
                          isCalendarEnable = !isCalendarEnable;
                        });
                      },
                      child: new Icon(
                        Icons.menu,
                        // color: isCalendarEnable ? AppColors.black_color : AppColors.main_color,
                        color: isCalendarEnable ? Colors.white : Colors.grey,
                      )),
                ],
              )
            ],
          ),
        ),
//         new Expanded(
// //                height: MediaQuery.of(context).size.height-100,
// //                width: MediaQuery.of(context).size.width,
//           child: isCalendarEnable
//               ? CalendarScreen()
//               : selected == 0
//                   ? CalendarScreenDefault()
//                   : CalendarScreenAll(),
//         )
      ],
    )));
  }
}
