

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Constants/Constants_data.dart';
import '../Constants/StateManager.dart';
import '../DBClasses/ApiBaseHelper.dart';
import '../Theme/DarkThemeProvider.dart';




class FgoList extends StatefulWidget {
  @override
  _FgoListState createState() => _FgoListState();
}

class _FgoListState extends State<FgoList> {
  Future<dynamic> futureProducts;
  ApiBaseHelper _helper = ApiBaseHelper();
  DarkThemeProvider themeChange;
  ThemeData themeData;
  var currentUser;

  @override
  void initState() {
    super.initState();
    initUser();
    futureProducts = fetchDoctorDetails();
  }

  initUser() async {
    if (Constants_data.app_user == null) {
      dataUser = await StateManager.getLoginUser();
    } else {
      dataUser = Constants_data.app_user;
    }
  }

  var dataUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: FutureBuilder<dynamic>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data[index].name),
                  subtitle: Text(snapshot.data[index].description),
                );
              },
            );
          }
        },
      ),
    );
  }
  // Future<dynamic> fetchProducts() async {
  //   //currentUser = await StateManager.getLoginUser();
  //   //String routeUrl = 'Dashboard/GetDoctorDetailsForApproval?repId=${currentUser["RepId"]}&divisionCode=${currentUser["division"]}&status=" "';
  //   String url = 'http://122.170.7.252/MicroDishaWebApiPublish/api/Dashboard/GetDoctorDetailsForApproval?repId=${Constants_data.repId}&divisionCode=${Constants_data.division}&status="ALL"';
  //   Map<String, String> headers = {
  //     "Content-type": "application/json",
  //     "Authorization": Constants_data.SessionId,
  //     "CountryCode": Constants_data.Country,
  //     "IPAddress": Constants_data.deviceId,
  //     "UserId": Constants_data.repId,
  //   };
  //   try {
  //     final response = await http.get(Uri.parse(url), headers: headers);
  //     if (response.statusCode == 200) {
  //       // final List<dynamic> jsonResponse = json.decode(response.body);
  //       // return jsonResponse.map((data) => Product.fromJson(data)).toList();
  //       final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //       List<dynamic> productsJson = jsonResponse['products'];
  //     // return productsJson.map((data) => Product.fromJson(data)).toList();
  //     } else {
  //       throw Exception('Failed to load products');
  //     }
  //   }
  //   catch (error) {
  //     print('Error: $error');
  //   }
  // }


  Future<dynamic> fetchDoctorDetails() async {
   // String url = 'http://122.170.7.252/MicroDishaWebApiPublish/api/Dashboard/GetDoctorDetailsForApproval?repId=${Constants_data.repId}&divisionCode=${Constants_data.division}&status="ALL"';
    String url = 'http://122.170.7.252/MicroDishaWebApiPublish/api/Dashboard/GetDoctorDetailsForApproval?repId=${dataUser["RepId"]}&divisionCode=${dataUser["division"]}&status=ALL';
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Authorization": Constants_data.SessionId,
      "CountryCode": Constants_data.Country,
      "IPAddress": Constants_data.deviceId,
      "UserId": Constants_data.repId,
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('dt_ReturnedTables') && jsonResponse['dt_ReturnedTables'] != null) {
          List<dynamic> returnedTables = jsonResponse['dt_ReturnedTables'];

          for (var table in returnedTables) {
            print(table);
          }
        } else {
          print('No data found in dt_ReturnedTables');
        }

        int status = jsonResponse['Status'];
        String message = jsonResponse['Message'];
        print('Status: $status, Message: $message');

      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


}