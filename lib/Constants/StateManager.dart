// import 'dart:convert';
//
// import 'package:flexi_profiler/Constants/Constants_data.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// class StateManager {
//
//   static Future<bool> isLogin() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final bool isLogin = prefs.getBool('isLogin');
//
//     return isLogin==null ? false : isLogin;
//   }
//
//   static Future<dynamic> getLoginUser() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final String user = prefs.getString('user');
//     var userJson = jsonDecode(user);
//     return userJson;
//   }
//
//   static Future<bool> logout() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.clear();
//     return true;
//   }
//
//   static Future<bool> loginUser(var data) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     var userJson = jsonEncode(data);
//     prefs.setString('user', userJson);
//     prefs.setBool('isLogin', true);
//     return true;
//   }
//
//   static Future<bool> setHomeScreenGrid(var data) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     var userJson = jsonEncode(data);
//     prefs.setString('homescreen_grid', userJson);
//     return true;
//   }
//
//   static Future<dynamic> getHomeScreenGrid() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final String user = prefs.getString('homescreen_grid');
//     var userJson;
//     try {
//       userJson  = jsonDecode(user);
//     }on Exception catch(err){
//       userJson = null;
//     }
//     return userJson;
//   }
//
//   static Future<bool> setLastSyncDateTime(String data) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setString('sync_time', data);
//     return true;
//   }
//
//   static Future<dynamic> getLastSyncDateTime() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final String data = prefs.getString('sync_time');
//     return data == null ? "" : data;
//   }
// }


import 'dart:convert';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StateManager {

  static Future<bool> isLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLogin = prefs.getBool('isLogin');
    return isLogin==null ? false : isLogin;
  }

  static Future<dynamic> getLoginUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user = prefs.getString('user');
    var userJson = jsonDecode(user);
    return userJson;
  }

  static Future<bool> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    return true;
  }

  static Future<bool> loginUser(var data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var userJson = jsonEncode(data);
    prefs.setString('user', userJson);
    prefs.setBool('isLogin', true);
    return true;
  }

  static Future<bool> divisionManager(var data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var userJson = jsonEncode(data);
    prefs.setString('division', userJson);
    return true;
  }

  static Future<dynamic> getDivisionManager() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user = prefs.getString('division');
    var userJson = jsonDecode(user);
    return userJson;
  }

  // static Future<bool> loginUser(var data) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var userJson = jsonEncode(data);
  //   print("Saving user data: $userJson");  // Debug: Inspect the data being saved
  //   prefs.setString('user', userJson);
  //   prefs.setBool('isLogin', true);
  //   return true;
  // }
  // static Future<dynamic> getLoginUser() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final String user = prefs.getString('user');
  //   print("Retrieved user data: $user");  // Debug: Inspect the data retrieved
  //   if (user != null) {
  //     var userJson = jsonDecode(user);
  //     return userJson;
  //   } else {
  //     return null;
  //   }
  // }
  // static Future<bool> isLogin() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final bool isLogin = prefs.getBool('isLogin');
  //   print("Is user logged in: $isLogin");  // Debug: Check if the login state is stored
  //   return isLogin ?? false;
  // }
  // static Future<bool> logout() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.clear();  // Clear all stored preferences
  //   print("Logged out and cleared preferences");
  //   return true;
  // }
  // static Future<bool> divisionManager(var data) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   if (data != null) {
  //     var userJson = jsonEncode(data);
  //     await prefs.setString('division', userJson);
  //     print("Data saved to SharedPreferences: $userJson");
  //     return true;
  //   } else {
  //     print("No data to save in divisionManager.");
  //     return false;
  //   }
  // }
  // static Future<dynamic> getDivisionManager() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final String user = prefs.getString('division'); // Nullable String
  //   if (user != null) {
  //     var userJson = jsonDecode(user);
  //     print("Data retrieved from SharedPreferences: $userJson");
  //     return userJson;
  //   } else {
  //     print("No data found in SharedPreferences for key 'division'.");
  //     return null;
  //   }
  // }

  static Future<bool> hqManager(var data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var userJson = jsonEncode(data);
    prefs.setString('hq', userJson);
    return true;
  }
  static Future<dynamic> gethqManager() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user = prefs.getString('hq');
    var userJson = jsonDecode(user);
    return userJson;
  }
  static Future<bool> setHomeScreenGrid(var data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var userJson = jsonEncode(data);
    prefs.setString('homescreen_grid', userJson);
    return true;
  }
  static Future<dynamic> getHomeScreenGrid() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String user = prefs.getString('homescreen_grid');
    var userJson;
    try {
      userJson  = jsonDecode(user);
    }on Exception catch(err){
      userJson = null;
    }
    return userJson;
  }

  static Future<bool> setLastSyncDateTime(String data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('sync_time', data);
    return true;
  }

  static Future<dynamic> getLastSyncDateTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String data = prefs.getString('sync_time');
    return data == null ? "" : data;
  }
}
