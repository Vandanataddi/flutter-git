// import 'package:flexi_profiler/Constants/Constants_data.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class DateTimePickerDialog {
//   static Future<String> selectDate(
//       {@required themeChange, @required context, @required template}) async {
//     DateTime selectedDate = new DateTime.now();
//     DateTime firstDate = new DateTime.now();
//     DateTime lastDate = new DateTime.now();
//     String format = template["format"];
//
//     if (template["selected_date"] != null &&
//         template["selected_date"] != "" &&
//         template["selected_date"] != "today") {
//       selectedDate = Constants_data.stringToDate(
//           template["selected_date"], template["format"]);
//     }
//
//     if (template["first_date"] != null &&
//         template["first_date"] != "" &&
//         template["first_date"] != "today") {
//       firstDate = Constants_data.stringToDate(
//           template["first_date"], template["format"]);
//     }
//
//     if (template["last_date"] != null &&
//         template["last_date"] != "" &&
//         template["last_date"] != "today") {
//       firstDate = Constants_data.stringToDate(
//           template["last_date"], template["format"]);
//     }
//
//     final DateTime picked = await showDatePicker(
//       builder: (BuildContext context, Widget child) {
//         return Constants_data.timeDatePickerTheme(
//             child, themeChange.darkTheme, context);
//       },
//       context: context,
//       initialDate: selectedDate,
//       firstDate: firstDate,
//       lastDate: lastDate,
//     );
//
//     if (picked != null && picked != selectedDate) {
//       var date = new DateFormat("$format").format(picked);
//       return date;
//     } else {
//       return null;
//     }
//   }
//
//   static Future<String> selectTime({@required timeFormat, @required themeChange, @required context}) async {
//     TimeOfDay time = await showTimePicker(
//       builder: (BuildContext context, Widget child) {
//         return Constants_data.timeDatePickerTheme(
//             child, themeChange.darkTheme, context);
//       },
//       initialTime: TimeOfDay.now(),
//       context: context,
//     );
//     if (time != null) {
//       final now = new DateTime.now();
//       final dt = DateTime(now.day, now.month, now.year, time.hour, time.minute);
//       final format = DateFormat("$timeFormat"); //"6:00 AM"
//
//       String t = format.format(dt);
//       return t;
//     } else {
//       return null;
//     }
//   }
// }



import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePickerDialog {
  static Future<String> selectDate({
    @required themeChange,
    @required context,
    @required template,
  }) async {
    DateTime selectedDate = DateTime.now();
    DateTime firstDate = DateTime(1900);  // Earliest date selectable
    DateTime lastDate = DateTime(2100);   // Latest date selectable

    // Update format to dd/MM/yyyy
     String format = "dd-MM-yyyy";
    //String format= "yyyy-MM-dd";

    // Set selected date if provided
    if (template["selected_date"] != null &&
        template["selected_date"] != "" &&
        template["selected_date"] != "today") {
      selectedDate = Constants_data.stringToDate(
          template["selected_date"], format);
    }

    // Set first date if provided
    if (template["first_date"] != null &&
        template["first_date"] != "" &&
        template["first_date"] != "today") {
      firstDate = Constants_data.stringToDate(
          template["first_date"], format);
    }

    // Set last date if provided
    if (template["last_date"] != null &&
        template["last_date"] != "" &&
        template["last_date"] != "today") {
      lastDate = Constants_data.stringToDate(
          template["last_date"], format);
    }

    final DateTime picked = await showDatePicker(
      builder: (BuildContext context, Widget child) {
        return Constants_data.timeDatePickerTheme(
            child, themeChange.darkTheme, context);
      },
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != selectedDate) {
      var date = DateFormat(format).format(picked);
      return date;
    } else {
      return null;
    }
  }

  static Future<String> selectTime({
    @required timeFormat,
    @required themeChange,
    @required context,
  }) async {
    TimeOfDay time = await showTimePicker(
      builder: (BuildContext context, Widget child) {
        return Constants_data.timeDatePickerTheme(
            child, themeChange.darkTheme, context);
      },
      initialTime: TimeOfDay.now(),
      context: context,
    );
    if (time != null) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      final format = DateFormat(timeFormat); //"6:00 AM"

      String t = format.format(dt);
      return t;
    } else {
      return null;
    }
  }
}
