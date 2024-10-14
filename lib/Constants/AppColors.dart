import 'dart:ui';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flutter/material.dart';

class AppColors {
  static int _bluePrimaryValue = 0xff215aa9;

  static List<Color> waveColors = [
    Color(0xff3b75c4),
    Color(0xff457fce),
    Color(0xff5089d8),
    Color(0xff3b75c4),
    Color(0xff2d66b5),
    main_color,
  ];

  static List<Color> waveColorsBlack = [
    Color(0xff111111),
    Color(0xff262626),
    Color(0xff2f2f2f),
    Color(0xff1c1c1c),
    Color(0xff0d0d0e),
    Color(0xff060607),
  ];

  static Color getCircularChartColor(index) {
    Color color = Colors.redAccent;
    if (index == 0) {
      color = Color(0xffdf6967);
    } else if (index == 4) {
      color = Color(0xff32cfee);
    } else if (index == 1) {
      color = Color(0xff2ba7ff);
    } else if (index == 2) {
      color = Color(0xfff9ac3a);
    } else if (index == 5) {
      color = Color(0xffffd527);
    } else if (index == 6) {
      color = Color(0xffe9e9e9);
    } else if (index == 3) {
      color = Color(0xff34df91);
    }
    return color;
  }

  static Color main_color = Color(0xff215aa9);
  static Color light_main_color1 = Color(0xff3c76c7);
  static Color light_main_color2 = Color(0xff5b95e4);
  static Color ligh_accents = Color(0xff9dbae0);
  static Color light_grey_color = Color(0xffDDDDDD);
  static Color grey_color = Color(0xff999999);
  static Color dark_grey_color = Color(0xff444444);
  static Color white_color = Color(0xffffffff);
  static Color black_color = Color(0xFF000000);
  static Color black_color87 = Color(0xDD000000);
  static Color black_color26 = Color(0x42000000);
  static Color red_color = Color(0xffff4c4c);
  static Color trend_line_color = Color(0xffff6060);

  static Color visit_type_chemist = Color(0xffd0c4ec);
  static Color visit_type_stockiest = Color(0xffecf0d9);
  static Color visit_type_doctor_mcr = Color(0xffceebe5);
  static Color visit_type_doctor_non_mcr = Color(0xffeccece);

  static Color work_type_sunday = Color(0xffffcdd2);
  static Color work_type_leave = Color(0xffe1bee7);
  static Color work_type_holiday = Color(0xffb2dfdb);

  static Color light_blue_card_background = Color(0xffe8eef6);

  static Color multicolumn_chart_color = Color(0xffF87073);
}
