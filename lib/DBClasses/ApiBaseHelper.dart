import 'dart:convert';
import 'dart:io';

import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:http/http.dart' as http;

class ApiBaseHelper {
  final String _baseUrl = Constants_data.baseUrl;

  Future<dynamic> get(String url,{bool isNeedToConcatBaseUrl=true}) async {
    var responseJson;
    try {
      print("Calling URL : ${(isNeedToConcatBaseUrl ? _baseUrl : "") + url}");
      // Map<String, String> headers = {
      //   "Content-type": "application/json",
      //   "CSRF_TOKEN": Constants_data.SessionId,
      //   "CountryCode": Constants_data.Country,
      //   "DEVICEID": Constants_data.deviceId,
      //   "RepId": Constants_data.repId,
      // };

      Map<String, String> headers = {
        "Content-type": "application/json",
        "Authorization": Constants_data.SessionId,
        "CountryCode": Constants_data.Country,
        "IPAddress": Constants_data.deviceId,
        "UserId": Constants_data.repId,
        // Check if repId is null or empty, if so use app_user["RepId"]
        // "UserId": (Constants_data.repId != "null" && Constants_data.repId.isNotEmpty)
        //     ? Constants_data.repId
        //     : (Constants_data.repId == "" ? "" : Constants_data.app_user["RepId"].toString()),
      };
      final response = await http.get(Uri.parse((isNeedToConcatBaseUrl ? _baseUrl : "") + url), headers: headers);
      responseJson = _returnResponse(response);
    }
    on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }
  Future<dynamic> post(String url, param, isRequiredJsonString,{bool isNeedToConcatBaseUrl=true}) async {
    var responseJson;
    try {
      print("Calling URL : ${(isNeedToConcatBaseUrl ? _baseUrl : "") + url}");
      print("Params $url : $param");

      // Map<String, String> headers = {
      //   "Content-type": "application/json",
      //   "CSRF_TOKEN": Constants_data.SessionId,
      //   "CountryCode": Constants_data.Country,
      //   "DEVICEID": Constants_data.deviceId,
      //   "RepId": Constants_data.repId,
      // };
      Map<String, String> headers = {
        "Content-type": "application/json",
        "Authorization": Constants_data.SessionId,
        "CountryCode": Constants_data.Country,
        "IPAddress": Constants_data.deviceId,
       "UserId": Constants_data.repId,
        // "UserId": (Constants_data.repId != "null" && Constants_data.repId.isNotEmpty)
        //     ? Constants_data.repId
        //     : (Constants_data.repId == "" ? "" : Constants_data.app_user["RepId"].toString()),
      };
      final response = await http.post(Uri.parse((isNeedToConcatBaseUrl ? _baseUrl : "") + url),
          headers: isRequiredJsonString ? headers : null,
          body: isRequiredJsonString ? convertToJsonString(param) : param);
      print("response : ${response.body}");
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }
  Future<dynamic> postMethod(String url, param, isRequiredJsonString, {bool isNeedToConcatBaseUrl = true}) async {
    var responseJson;
    try {
      print("Calling URL : ${(isNeedToConcatBaseUrl ? _baseUrl : "") + url}");
      print("Params $url : $param");

      // Map<String, String> headers = {
      //   "Content-type": "application/json",
      //   "CSRF_TOKEN": Constants_data.SessionId,
      //   "CountryCode": Constants_data.Country,
      //   "DEVICEID": Constants_data.deviceId,
      //   "RepId": Constants_data.repId,
      // };

      Map<String, String> headers = {
        "Content-type": "application/json",
        "Authorization": Constants_data.SessionId,
        "CountryCode": Constants_data.Country,
        "IPAddress": Constants_data.deviceId,
        "UserId": Constants_data.repId,
        // "UserId": (Constants_data.repId != "null" && Constants_data.repId.isNotEmpty)
        //     ? Constants_data.repId
        //     : (Constants_data.repId == "" ? "" : Constants_data.app_user["RepId"].toString()),
      };

      // Convert param to JSON string if required
      final body = isRequiredJsonString ? jsonEncode(param) : param;

      // Make the HTTP POST request
      final response = await http.post(
        Uri.parse((isNeedToConcatBaseUrl ? _baseUrl : "") + url),
        headers: headers,
        body: body, // Ensure param is sent as a proper JSON string
      );

      print("response : ${response.body}");

      // Handle response and errors
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }

    return responseJson;
  }
  Future<dynamic> postMultipart(String url, Map<String, String> fields, File file, String fieldName, {bool isNeedToConcatBaseUrl = true}) async {
    var responseJson;
    try {
      // Prepare the full URL
      String fullUrl = (isNeedToConcatBaseUrl ? _baseUrl : "") + url;

      // Create MultipartRequest
      var request = http.MultipartRequest('POST', Uri.parse(fullUrl));

      // Add headers
      Map<String, String> headers = {
        "Authorization": Constants_data.SessionId,
        "CountryCode": Constants_data.Country,
        "IPAddress": Constants_data.deviceId,
        "UserId": Constants_data.repId,
        // "UserId": (Constants_data.repId != "null" && Constants_data.repId.isNotEmpty)
        //     ? Constants_data.repId
        //     : (Constants_data.repId == "" ? "" : Constants_data.app_user["RepId"].toString()),
        "Content-Type": "application/json"
      };
      request.headers.addAll(headers);
      // Add fields
      request.fields.addAll(fields);
      // Add file
      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
      }
      // Send the request and wait for the response
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      // Parse the response
      responseJson = _returnResponse(response);
    } catch (e) {
      throw Exception("Error sending multipart request: $e");
    }
    return responseJson;
  }
  Future<dynamic> postWithoutParams(String url) async {
    var responseJson;
    try {
      print("Calling URL : ${_baseUrl + url}");
      Map<String, String> headers = {
        "CSRF_TOKEN": Constants_data.SessionId,
        "CountryCode": Constants_data.Country,
        "DEVICEID": Constants_data.deviceId,
         "UserId": Constants_data.repId,
      };
      final response = await http.post(Uri.parse(_baseUrl + url), headers: headers);
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }
  convertToJsonString(map) {
    String json_temp = "${jsonEncode(map).toString()}";
    json_temp = json_temp.replaceAll("\"", "\\\"");
    json_temp = "\"${json_temp}\"";
    return json_temp;
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        print(responseJson);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occurred while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}

class AppException implements Exception {
  final _message;
  final _prefix;

  AppException([this._message, this._prefix]);

  String toString() {
    return "$_prefix:$_message";
  }
}

class FetchDataException extends AppException {
  FetchDataException([String message]) : super(message, "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends AppException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends AppException {
  InvalidInputException([String message]) : super(message, "Invalid Input: ");
}
