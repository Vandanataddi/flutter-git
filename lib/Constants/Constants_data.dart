import 'dart:convert';
import 'dart:io';
import 'dart:math' show cos, sqrt, asin;
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:device_info/device_info.dart';
import 'package:flexi_profiler/DBClasses/DBProfessionalList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:uuid/uuid.dart';

import 'AppColors.dart';

class Constants_data {
  // 0 : Microlabs
  // 1 : RezMyTrip
  // 3 : Olcare
  static int appFlavour = 0;
  static BuildContext currentScreenContext;

  static bool isSynchronizing = false;
  static bool isBackgroundServiceCallingAPI = false;

  static bool isCallUpdated = false;
  static bool isThemeBlack;

  static String appVersionCode = "0";
  static String package_name = "0";

  static String homeScreenName = "/HomeScreenNew";

  static String profileUrl = "http://122.170.7.252/MicroDishaWebApiPublish";


  // isMicroLab != null && isMicroLab ? "/HomeScreenNew" : "/HomeScreenRMT";

  // static String baseUrl =
  //     "http://122.170.7.215/FlexiProfilerWebAPITest/api/Profiler";

  static String baseUrl =
      //"http://122.170.7.215/FlexiProfilerWebAPI/api/Profiler";
       "http://122.170.7.252/MicroDishaWebApiPublish/api";

  // = isMicroLab != null && isMicroLab
  //     ? "http://122.170.7.215/FlexiProfilerWebAPI/api/Profiler"
  //     : "http://122.170.7.215/FlexiProfilerWebAPI_RMT/api/profiler";

  static String appIcon = "assets/images/profiler_logo_new.png";
  static String appName = "Microlabs";

  // = isMicroLab != null && isMicroLab
  //     ? "assets/images/profiler_logo_new.png"
  //     : "assets/images/rmt_icon.png";

  static String label_txt = "";

  static var app_user = null;
  static String username = "";
  static String SessionId = "";
  static String Country = "";
  static String division = "";
  static String deviceId = "";
  static String email = "";
  static String ProfilePicURL = "";
  static String repId = "";
  static String designation = "";
  static String designationGroupCode = "";
  static String groupId = "";
  static String divisionname = "";
  static String hqname = "";
  static String hqcode = "";
  static String statecode = "";


  static String customerid = "";
  static String selectedDivisionId = "";
  static String selectedHQCode="";
  static String selectedDivisionName = "";
  static String selectedHQName = "";

  //accountlist screen//
  static String selectedHQidName = "";
  static String selectedHQidCode = "";
  static String selectedDivisionidName = "";
  static String selectedDivisionIdcode = "";

  static List<dynamic> sizeMenuItem = [];
  static List<Map<String,dynamic>> divisiondata =[];
  static List<Map<String,dynamic>> hqdata =[];

  static String lastSyncTime = "";
  static String versionName = "1.0.0";
  static const tvLabel_bg = const Color(0xff2E4E8F);

  static CubeUser cubeUser;
  static String demoUserCC = Platform.isIOS ? "call_user_3" : "call_user_1";
  static String demoPassCC = "Admin@123";

  static const White = const Color(0xffFFFFFF);

  static var jsonMenuUpdated;

  static setupThemeColors() {
    AppColors.main_color =
        Constants_data.isThemeBlack ? Color(0xFF2196F3) : Color(0xff215aa9);
    AppColors.visit_type_chemist =
        Constants_data.isThemeBlack ? Color(0xff1f0e47) : Color(0xffd0c4ec);
    AppColors.visit_type_stockiest =
        Constants_data.isThemeBlack ? Color(0xff363d12) : Color(0xffecf0d9);
    AppColors.visit_type_doctor_mcr =
        Constants_data.isThemeBlack ? Color(0xff174239) : Color(0xffceebe5);
    AppColors.visit_type_doctor_non_mcr =
        Constants_data.isThemeBlack ? Color(0xff471b1b) : Color(0xffeccece);
    AppColors.work_type_sunday =
        Constants_data.isThemeBlack ? Color(0xff2b1818) : Color(0xffffcdd2);
    AppColors.work_type_leave =
        Constants_data.isThemeBlack ? Color(0xff421c49) : Color(0xffe1bee7);
    AppColors.work_type_holiday =
        Constants_data.isThemeBlack ? Color(0xff1c3936) : Color(0xffb2dfdb);
    AppColors.light_blue_card_background =
        Constants_data.isThemeBlack ? Color(0xff1d1d1d) : Color(0xffe8eef6);
    AppColors.light_blue_card_background =
        Constants_data.isThemeBlack ? Color(0xff1d1d1d) : Color(0xffe8eef6);
  }

  static Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  static getFlexibleAppBar(isDark) {
    if (isDark) {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/menu_bg_dark.png"),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/menu_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }

  static timeDatePickerTheme(child, isDark, context) {
    return Theme(
      data: isDark
          ? ThemeData.dark().copyWith(
              buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            )
          : ThemeData.light().copyWith(
              buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
      child: child,
    );
  }

  // static Widget appBarFlexibleSpace = Container(
  //   decoration: BoxDecoration(
  //     image: DecorationImage(
  //       image: AssetImage("assets/images/menu_bg.png"),
  //       fit: BoxFit.cover,
  //     ),
  //   ),
  // );

  static List<dynamic> categoryList = [
    {"CategoryCode": "Core", "CategoryDescription": "Demographics"},
    {"CategoryCode": "MailingAddress", "CategoryDescription": "Mailing Address"},
    {"CategoryCode": "Education", "CategoryDescription": "Education"},
    {"CategoryCode": "Speciality", "CategoryDescription": "Speciality"},
    {"CategoryCode": "Education", "CategoryDescription": "Reach and Frequency"}
  ];

  // static List<Map<String, dynamic>> hqdata =[];

  static int temp_sel_exp_type;
  static var exp_type_Sel = "";
  static var exp_id_Sel = "";

  //present working//
  static DateTime stringToDate(String date, String formate) {
    return new DateFormat(formate).parse(date);
  }


  static String dateToString(DateTime date, String formate) {
    final format = DateFormat(formate); //"6:00 AM"

    String strDt = format.format(date);
    return strDt;
  }

  static String date_selected;
  static bool check_save = false;

  //static var mainData_calendar;
  static bool check_calendar_call = false;

  static var jsonSampleProductDetails = {
    "dt_ReturnedTables": [
      [
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSA0015",
          "product_category": "S",
          "product_brand_code": "A0910000009",
          "product_description": "AMLOZAAR-25 TABLETS",
          "product_brand_name": "AMLOZAAR"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSA0020",
          "product_category": "S",
          "product_brand_code": "A0910000006",
          "product_description": "AMLONG A-25 TABLETS",
          "product_brand_name": "AMLONG A"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSA0023",
          "product_category": "S",
          "product_brand_code": "A0910000005",
          "product_description": "AMLONG 2.5 TABLETS 10s",
          "product_brand_name": "AMLONG"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSA0025",
          "product_category": "S",
          "product_brand_code": "A0910000005",
          "product_description": "AMLONG 7.5 TABLETS",
          "product_brand_name": "AMLONG"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSA0027",
          "product_category": "S",
          "product_brand_code": "A0910000021",
          "product_description": "AVAS-AM TABLETS",
          "product_brand_name": "AVAS AM"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSA0028",
          "product_category": "S",
          "product_brand_code": "A0910000020",
          "product_description": "AVAS-EZ TABLETS",
          "product_brand_name": "AVAS"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSA0029",
          "product_category": "S",
          "product_brand_code": "A0910000023",
          "product_description": "AVAS PLUS TABLETS",
          "product_brand_name": "AVAS PLUS"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSA0030",
          "product_category": "S",
          "product_brand_code": "A0910000020",
          "product_description": "AVAS-5 TABLETS",
          "product_brand_name": "AVAS"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSA0033",
          "product_category": "S",
          "product_brand_code": "A0910000020",
          "product_description": "AVAS-40 TABLETS",
          "product_brand_name": "AVAS"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSA0035",
          "product_category": "S",
          "product_brand_code": "A0910000020",
          "product_description": "AVAS-10 TABLETS",
          "product_brand_name": "AVAS"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSA0040",
          "product_category": "S",
          "product_brand_code": "A0910000007",
          "product_description": "AMLONG-H TABLETS",
          "product_brand_name": "AMLONG H"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSA0044",
          "product_category": "S",
          "product_brand_code": "A0910000020",
          "product_description": "AVAS-20 TABLETS",
          "product_brand_name": "AVAS"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSA0046",
          "product_category": "S",
          "product_brand_code": "A0910000006",
          "product_description": "AMLONG-A TABLETS 10s",
          "product_brand_name": "AMLONG A"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSA0049",
          "product_category": "S",
          "product_brand_code": "A0910000005",
          "product_description": "AMLONG TABLETS 10s",
          "product_brand_name": "AMLONG"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSA0050",
          "product_category": "S",
          "product_brand_code": "A0910000005",
          "product_description": "AMLONG 10 TABLETS 10s",
          "product_brand_name": "AMLONG"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSA102",
          "product_category": "S",
          "product_brand_code": "A0910000008",
          "product_description": "AMLONG MT 25",
          "product_brand_name": "AMLONG MT"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSA103",
          "product_category": "S",
          "product_brand_code": "A0910000008",
          "product_description": "AMLONG MT 50",
          "product_brand_name": "AMLONG MT"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSA104",
          "product_category": "S",
          "product_brand_code": "A0910000020",
          "product_description": "AVAS-20 EZ TABLETS",
          "product_brand_name": "AVAS"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSD0024",
          "product_category": "S",
          "product_brand_code": "A0910000051",
          "product_description": "DIANORM-M TABLETS 10s",
          "product_brand_name": "DIANORM"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSD0026",
          "product_category": "S",
          "product_brand_code": "A0910000051",
          "product_description": "DIANORM TABLETS 20s",
          "product_brand_name": "DIANORM"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSD007",
          "product_category": "S",
          "product_brand_code": "A0910000051",
          "product_description": "DIANORM - 40 TABLETS",
          "product_brand_name": "DIANORM"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSD010",
          "product_category": "S",
          "product_brand_code": "A0910000051",
          "product_description": "DIANORM FORTE TABLETS",
          "product_brand_name": "DIANORM"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSL0013",
          "product_category": "S",
          "product_brand_code": "A0910000123",
          "product_description": "LOCHOL TABLETS",
          "product_brand_name": "LOCHOL"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSM005",
          "product_category": "S",
          "product_brand_code": "A0910000131",
          "product_description": "METADURE - 2.5 TABLETS",
          "product_brand_name": "METADURE"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSM006",
          "product_category": "S",
          "product_brand_code": "A0910000131",
          "product_description": "METADURE - 5 TABLETS",
          "product_brand_name": "METADURE"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSM007",
          "product_category": "S",
          "product_brand_code": "A0910000143",
          "product_description": "MINIMET 500 MG TABLETS",
          "product_brand_name": "MINIMET"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSM008",
          "product_category": "S",
          "product_brand_code": "A0910000143",
          "product_description": "MINIMET 500 MG SR TABLETS",
          "product_brand_name": "MINIMET"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSM009",
          "product_category": "S",
          "product_brand_code": "A0910000143",
          "product_description": "MINIMET 1000 MG SR TABLETS",
          "product_brand_name": "MINIMET"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSP0018",
          "product_category": "S",
          "product_brand_code": "A0910000198",
          "product_description": "PLAGERINE A 75 CAPS",
          "product_brand_name": "PLAGERINE"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSP0031",
          "product_category": "S",
          "product_brand_code": "A0910000198",
          "product_description": "PLAGERINE TABLETS",
          "product_brand_name": "PLAGERINE"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSP0032",
          "product_category": "S",
          "product_brand_code": "A0910000198",
          "product_description": "PLAGERINE A 150 CAPS",
          "product_brand_name": "PLAGERINE"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSR0012",
          "product_category": "S",
          "product_brand_code": "A0910000212",
          "product_description": "RGM TABLETS",
          "product_brand_name": "RGM"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "CARSS002",
          "product_category": "S",
          "product_brand_code": "A0910000220",
          "product_description": "S-AMLONG 5 TABLETS",
          "product_brand_name": "S-AMLONG"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "FTINA0106",
          "product_category": "S",
          "product_brand_code": "A0910000020",
          "product_description": "AVAS-80",
          "product_brand_name": "AVAS"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "FTINA0549",
          "product_category": "S",
          "product_brand_code": "A0910000005",
          "product_description": "AMLONG TABLETS 15s",
          "product_brand_name": "AMLONG"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "FTINA0555",
          "product_category": "S",
          "product_brand_code": "A0910000005",
          "product_description": "AMLONG 2.5 TABLETS 15s",
          "product_brand_name": "AMLONG"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "FTINA0556",
          "product_category": "S",
          "product_brand_code": "A0910000005",
          "product_description": "AMLONG 10 TABLETS 15s",
          "product_brand_name": "AMLONG"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "FTINA0558",
          "product_category": "S",
          "product_brand_code": "A0910000006",
          "product_description": "AMLONG-A TABLETS 15s",
          "product_brand_name": "AMLONG A"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "FTINA0582",
          "product_category": "S",
          "product_brand_code": "A0910000020",
          "product_description": "AVAS-CP TABLETS",
          "product_brand_name": "AVAS"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "FTINA0707",
          "product_category": "S",
          "product_brand_code": "A0910000007",
          "product_description": "AMLONG-H TABLETS 15s",
          "product_brand_name": "AMLONG H"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "FTINA0763",
          "product_category": "S",
          "product_brand_code": "A0910000005",
          "product_description": "AMLONG CT TABLETS",
          "product_brand_name": "AMLONG"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "FTINS0055",
          "product_category": "S",
          "product_brand_code": "A0910000220",
          "product_description": "S-AMLONG 2.5 TABLETS",
          "product_brand_name": "S-AMLONG"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "GIFTC0001",
          "product_category": "G",
          "product_brand_code": null,
          "product_description": "CFL LAMP",
          "product_brand_name": null
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "GIFTD0001",
          "product_category": "G",
          "product_brand_code": null,
          "product_description": "DOLO BAG",
          "product_brand_name": null
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "GIFTD0002",
          "product_category": "G",
          "product_brand_code": null,
          "product_description": "DOLOWIN HAMPER BAG",
          "product_brand_name": null
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "GIFTD0003",
          "product_category": "G",
          "product_brand_code": null,
          "product_description": "DOLOWIN HAMPER KNIFE",
          "product_brand_name": null
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "GIFTF0001",
          "product_category": "G",
          "product_brand_code": null,
          "product_description": "FOOD SAVER",
          "product_brand_name": null
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "TCINA0001",
          "product_category": "S",
          "product_brand_code": "A0910000020",
          "product_description": "ASPIVAS 75 CAPS",
          "product_brand_name": "AVAS"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "TCINA0002",
          "product_category": "S",
          "product_brand_code": "A0910000020",
          "product_description": "AVAS CV  10",
          "product_brand_name": "AVAS"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "TCINA0003",
          "product_category": "S",
          "product_brand_code": "B1213000110",
          "product_description": "ANGIPLAT 2.5 CAPSULES",
          "product_brand_name": "ANGIPLAT"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "TCINA0004",
          "product_category": "S",
          "product_brand_code": "B1213000110",
          "product_description": "ANGIPLAT 6.5 CAPSULES",
          "product_brand_name": "ANGIPLAT"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "TCINA0008",
          "product_category": "S",
          "product_brand_code": "A0910000020",
          "product_description": "AVAS CV  20",
          "product_brand_name": "AVAS"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "TTINA0063",
          "product_category": "S",
          "product_brand_code": "A0910000020",
          "product_description": "AVAS 10 D",
          "product_brand_name": "AVAS"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "TTINA0064",
          "product_category": "S",
          "product_brand_code": "A0910000020",
          "product_description": "AVAS 20 D",
          "product_brand_name": "AVAS"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "TTINM0067",
          "product_category": "S",
          "product_brand_code": "B1112000098",
          "product_description": "MOXILONG - 0.2",
          "product_brand_name": "MOXILONG"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "TTINM0068",
          "product_category": "S",
          "product_brand_code": "B1112000098",
          "product_description": "MOXILONG - 0.3",
          "product_brand_name": "MOXILONG"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "TTINN0057",
          "product_category": "S",
          "product_brand_code": "B1112000037",
          "product_description": "NICOVAS",
          "product_brand_name": "NICOVAS"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "TTINN0060",
          "product_category": "S",
          "product_brand_code": "B1112000037",
          "product_description": "NICOVAS 1000",
          "product_brand_name": "NICOVAS"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "TTINP0009",
          "product_category": "S",
          "product_brand_code": "B1112000038",
          "product_description": "PRASULET 5 TABLETS",
          "product_brand_name": "PRASULET"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "TTINP0010",
          "product_category": "S",
          "product_brand_code": "B1112000038",
          "product_description": "PRASULET 10 TABLETS",
          "product_brand_name": "PRASULET"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "TTINT0042",
          "product_category": "S",
          "product_brand_code": "B1516000181",
          "product_description": "TELPLUS",
          "product_brand_name": "TELPLUS"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "TTINT0043",
          "product_category": "S",
          "product_brand_code": "B1516000181",
          "product_description": "TELPLUS TRIO",
          "product_brand_name": "TELPLUS"
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "GIFTF0002",
          "product_category": "G",
          "product_brand_code": null,
          "product_description": "FRY PAN (BIG)",
          "product_brand_name": null
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "GIFTM0001",
          "product_category": "G",
          "product_brand_code": null,
          "product_description": "MOSQUITO REPELLENT",
          "product_brand_name": null
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "GIFTP0001",
          "product_category": "G",
          "product_brand_code": null,
          "product_description": "PLASTIC JUG",
          "product_brand_name": null
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "GIFTP0002",
          "product_category": "G",
          "product_brand_code": null,
          "product_description": "PLASTIC BOTTLE",
          "product_brand_name": null
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "GIFTR0001",
          "product_category": "G",
          "product_brand_code": null,
          "product_description": "RAIN COAT",
          "product_brand_name": null
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "GIFTS0001",
          "product_category": "G",
          "product_brand_code": null,
          "product_description": "STEEL PLAT",
          "product_brand_name": null
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "GIFTT0001",
          "product_category": "G",
          "product_brand_code": null,
          "product_description": "TADKA PAN",
          "product_brand_name": null
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "GIFTT0002",
          "product_category": "G",
          "product_brand_code": null,
          "product_description": "TOWEL",
          "product_brand_name": null
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "GIFTT0003",
          "product_category": "G",
          "product_brand_code": null,
          "product_description": "TORCHES",
          "product_brand_name": null
        },
        {
          "company_code": "C001",
          "division_code": "CC01",
          "product_code": "GIFTU0001",
          "product_category": "G",
          "product_brand_code": null,
          "product_description": "UMBRELLA",
          "product_brand_name": null
        }
      ]
    ],
    "ObjRetArgs": null,
    "Status": 1,
    "Message": "Product List Retrive Successfully.",
    "CSRF_TOKEN": ""
  };

  static toastError(String msg) {
    Fluttertoast.showToast(
        msg: msg,
       // toastLength: Toast.LENGTH_LONG,
         toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.red_color,
        textColor: AppColors.white_color,
        fontSize: 16.0);
  }

  static toastNormal(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        //toastLength: Toast.LENGTH_LONG,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: AppColors.white_color,
        fontSize: 16.0);
  }

  static removeLastCharFromString(String str) {
    String result = str.substring(0, str.length - 1);
    return result;
  }

  static Future<String> getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  static Future<bool> checkNetworkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }

  static getUUID() {
    var uuid = Uuid();
    return uuid.v4();
  }

  static double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat1 - lat2) * p) / 2 +
        c(lat2 * p) * c(lat1 * p) * (1 - c((lon1 - lon2) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // static rotationChange(image) async {
  //   final imageBytes = await image.readAsBytes();
  //   // await image.delete();
  //   final compressedImageBytes =
  //       await FlutterImageCompress.compressWithList(imageBytes);
  //   await image.writeAsBytes(compressedImageBytes);
  //   return image;
  // }
  static rotationChange(image) async {
    File file = File(image.path);
    final imageBytes = await file.readAsBytes();
    // await image.delete();
    final compressedImageBytes =
        await FlutterImageCompress.compressWithList(imageBytes);
    await file.writeAsBytes(compressedImageBytes);
    return file;
  }

  // static rotationChange(image) async {
  //   // final imageBytes = await image.readAsBytes();
  //   // await image.delete();
  //   // final compressedImageBytes =
  //   // await FlutterImageCompress.compressWithList(imageBytes);
  //   // await image.writeAsBytes(compressedImageBytes);
  //
  //   final imageBytes = await image.readAsBytes();
  //   var base64Image =  base64Encode(imageBytes);
  //   // print(base64Image);},), SizedBox(height: 30,),
  //   image.memory(base64Decode(base64Image));
  //
  //   return image;
  // }

  static getFontSize(context, dynamic size) {
    return ((MediaQuery.of(context).size.height +
                MediaQuery.of(context).size.width) *
            double.parse("${size}")) /
        1024;
  }

  static getHeight(context, dynamic size) {
    return (MediaQuery.of(context).size.height * double.parse("${size}")) / 667;
  }

  static getWidth(context, dynamic size) {
    return (MediaQuery.of(context).size.width * double.parse("${size}")) / 375;
  }

  static String formatter(String currentBalance) {
    try {
      // suffix = {' ', 'k', 'M', 'B', 'T', 'P', 'E'};
      int value = double.parse(currentBalance).round();

      if (value < 1000) {
        // less than a million
        return value.toStringAsFixed(2);
      } else if (value >= 1000 && value < (100000)) {
        // less than 100 million
        double result = value / 1000;
        if (result.toString().endsWith(".00"))
          return result.toStringAsFixed(0) + "K";
        else
          return result.toStringAsFixed(2) + "K";
      } else if (value >= 100000 && value < (100000 * 100)) {
        // less than 100 million
        double result = value / 100000;
        if (result.toString().endsWith(".00"))
          return result.toStringAsFixed(0) + "K";
        else
          return result.toStringAsFixed(2) + "L";
      } else if (value >= (100000 * 100)) {
        // less than 100 billion
        double result = value / (100000 * 100);
        if (result.toString().endsWith(".00"))
          return result.toStringAsFixed(0) + "K";
        else
          return result.toStringAsFixed(2) + "Cr";
      }
    } catch (e) {
      print(e);
    }
  }

  static LinearGradient getGradientColor() {
    final List<Color> color = <Color>[];
    color.add(AppColors.main_color);
    color.add(AppColors.light_main_color1);
    color.add(AppColors.light_main_color2);

    final List<double> stops = <double>[];
    stops.add(0.0);
    stops.add(0.5);
    stops.add(1.0);

    final LinearGradient gradientColors =
        LinearGradient(colors: color, stops: stops);
    return gradientColors;
  }

  static Future<bool> openDialogNoInternetConection(context) async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: AppColors.main_color,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Lottie.asset('assets/Lotti/no_connection.json',
                          width: 100, height: 150),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'No Data Connection',
                      style: TextStyle(
                          color: AppColors.white_color,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(15),
                child: Center(
                    child: Text(
                  "Without a data connection the App unable to refresh data",
                  textAlign: TextAlign.center,
                )),
              ),
              Container(
                  margin: EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context, 0);
                        },
                        child: Text("OK",
                            style: TextStyle(
                                color: AppColors.main_color,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ))
            ],
          );
        })) {
      case 0:
        return true;
        break;
      case 1:
        return false;
        break;
    }
    return false;
  }

  static var templateData = {
    "LeadingIconFrom": "Growth",
    "TrailIconFrom": "Growth",
    "currency_symbol": "₹",
    "currency_formate": "##,##,##,###.##",
    "isShowLeadingIcon": "N",
    "isShowTailIcon": "N",
    "isClickable": "Y",
    "ScreenName": "ReportScreen",
    "Params": "CustomerId",
    "ParentWidgetId": "TopCustomer",
    "Row": [
      [
        {
          "is_expandble": "Y",
          "bg_color": "",
          "label": "",
          "flex": 10,
          "txt_color": "#3b75c4",
          "txt_size": "13",
          "txt_style": "Bold",
          "value": "",
          "widget_id": "AccountName",
          "widget_type": "Text",
          "orientation": "",
          "is_currency": "N",
          "align": "left"
        }
      ],
      [
        {
          "is_expandble": "Y",
          "bg_color": "",
          "label": "Sales",
          "flex": 40,
          "txt_color": "#000000",
          "txt_size": "13",
          "txt_style": "normal",
          "value": "",
          "widget_id": "Sales",
          "widget_type": "Text",
          "orientation": "V",
          "is_currency": "Y",
          "align": "left"
        },
        {"widget_type": "Divider"},
        {
          "is_expandble": "Y",
          "bg_color": "",
          "label": "Sales %",
          "flex": 25,
          "txt_color": "#000000",
          "txt_size": "13",
          "txt_style": "normal",
          "value": "",
          "widget_id": "percentage",
          "widget_type": "Text",
          "orientation": "V",
          "is_currency": "N",
          "align": "left"
        },
        {"widget_type": "Divider"},
        {
          "is_expandble": "Y",
          "bg_color": "",
          "label": "Cumulative %",
          "flex": 35,
          "txt_color": "#000000",
          "txt_size": "13",
          "txt_style": "normal",
          "value": "",
          "widget_id": "cum_per",
          "widget_type": "Text",
          "orientation": "V",
          "is_currency": "N",
          "align": "left"
        }
      ]
    ]
  };

  static checkConfigAvailability(value) async {
    List<dynamic> configDetails = await DBProfessionalList.getConfigDetails();
    print("Check : ${configDetails}");
    bool isAvailable = false;
    for (int i = 0; i < configDetails.length; i++) {
      if (configDetails[i]["Parameter_Code"] == value.toString() &&
          configDetails[i]["Parameter_Value"] == "Y" &&
          configDetails[i]["is_active"] == "Y") {
        print("ConfigCheck : ${configDetails[i]}");
        isAvailable = true;
        break;
      }
    }
    return isAvailable;
  }
}
