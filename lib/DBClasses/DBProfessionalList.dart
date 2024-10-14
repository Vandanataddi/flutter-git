import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProfessionalList {
  static initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "Profiler.db");
    return await openDatabase(path, version: 1, onOpen: (db) {});
  }

  static getValueForAccount(String LevelId, String accountType) async {
    Database db = await initDB();
    var res = await db.rawQuery(
        'SELECT AttributeCode, AttributeValue, CategoryCode, AttributeSeqNo FROM  ProfessionalListAttribute WHERE CustomerId=? AND AccountType=? ORDER BY SeqNo,cast(CategorySeqNo as int),cast(AttributeSeqNo as int)',
        [LevelId, accountType]);
    List<dynamic> list = res.isNotEmpty ? res : [];
    return list;
  }

  static getAttributes(String accountType, bool isSorting, String ids) async {
    Database db = await initDB();
    var res = await db.rawQuery(
        'SELECT DISTINCT AttributeCode FROM  ProfessionalListAttribute WHERE CategoryCode=? AND AccountType=? ORDER BY CAST (AttributeSeqNo AS INTEGER)',
        ['Core', accountType]);
    List<dynamic> list = res.isNotEmpty ? res : [];
    List<String> attr = [];

    for (int i = 0; i < list.length; i++) {
//      if(i<3)
      attr.add(list[i]["AttributeCode"]);
    }
    print("getAttributes : ${attr}");

    Map<String, List<dynamic>> map = await getDoctorsList(accountType, attr, isSorting, ids);
    return map;
  }

  static getAttributesByCustomerID(String accountType, String CustomerId) async {
    Database db = await initDB();
    var res = await db.rawQuery(
        'SELECT DISTINCT AttributeCode FROM  ProfessionalListAttribute WHERE CategoryCode=? AND AccountType=? AND CustomerId=? ORDER BY CAST (AttributeSeqNo AS INTEGER)',
        ['Core', accountType, CustomerId]);
    List<dynamic> list = res.isNotEmpty ? res : [];
    List<String> attr = [];

    for (int i = 0; i < list.length; i++) {
//      if(i<3)
      attr.add(list[i]["AttributeCode"]);
    }
    print("getAttributes : ${attr}");
    Map<String, List<dynamic>> map = await getDoctorsList(accountType, attr, false, null);
    return map;
  }

  static getDoctorsList(String accountType, List<String> attribute_code, bool isSorting, String ids) async {
    Database db = await initDB();

    String query = 'SELECT p.CustomerId,p.CustomerName, p.AccountType,p.Latitude,p.Longitude,p.ProfilePic';
    List<String> params = [];
    for (int i = 0; i < attribute_code.length; i++) {
      params.add(attribute_code[i]);
      query = query + ', MAX(CASE WHEN c.AttributeCode = ? THEN c.AttributeValue END) AS ' + attribute_code[i];
    }
    if (isSorting) {
      query = query +
          ' FROM ProfessionalList p JOIN ProfessionalListAttribute c ON p.CustomerId = c.CustomerId WHERE c.CategoryCode=? AND p.AccountType=? AND p.CustomerId in($ids) GROUP BY p.CustomerID ORDER BY p.CustomerName';
    }
    else {
      if (accountType == "Calls") {
        query = query +
            ' FROM ProfessionalList p JOIN ProfessionalListAttribute c ON p.CustomerId = c.CustomerId WHERE c.CategoryCode=? AND p.AccountType=? GROUP BY p.CustomerID ORDER BY p.CustomerID DESC';
      }
      else {
        query = query +
            ' FROM ProfessionalList p JOIN ProfessionalListAttribute c ON p.CustomerId = c.CustomerId WHERE c.CategoryCode=? AND p.AccountType=?  GROUP BY p.CustomerID ORDER BY p.CustomerName';
      }
    }

    //SELECT * FROM ProfessionalListAttribute c where AttributeCode='Calldate' ORDER BY strftime("%s",(select substr(c.AttributeValue, 7,4) || "-" || substr(c.AttributeValue, 4, 2)|| "-" || substr(c.AttributeValue, 1, 2) as proper_date from (select c.AttributeValue as reversed_date))) DESC
    print("------- Final Query : ${query}");
    params.add("Core");
    params.add(accountType);

    List<dynamic> list = await db.rawQuery(query, params);
    print("Response Data : ${list}");

    Map<String, List<dynamic>> mapData = new HashMap();
    mapData["data"] = list;
    mapData["keys"] = attribute_code;
    return mapData;
  }

  static getCoreAttributes() async {
    Database db = await initDB();
    String TypeCode = "Professional";
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT * FROM ProfessionalListAttribute where CategoryCode=? AND AccountType=? ORDER BY CustomerId',
        ["Core", TypeCode]);

    Map<String, List<dynamic>> listData = new HashMap();

    for (int i = 0; i < maps.length; i++) {
      List<dynamic> list = [];
      if (listData != null && listData.containsKey(maps[i]["LevelId"])) {
        list = listData[maps[i]["LevelId"]];
      }
      list.add(maps[i]);
      listData[maps[i]["LevelId"]] = list;
    }
    listData.forEach((k, v) {
      print('${k}: ${v}');
    });
    print("Length of doc : ${listData.length}");
    return [];
  }

  static getTemplateFromViewId(String viewId, String accountType) async {
    Database db = await initDB();
    List<String> params = [];
    params.add(viewId);
    params.add(accountType);
    var res =
        await db.rawQuery('SELECT TemplateJson FROM  TemplateDefinitionMst WHERE ViewId=? AND AccountType=?', params);
    String json = res.isNotEmpty ? res.elementAt(0)['TemplateJson'] : "";
    return json;
  }

  static getCategoryFromAccountType(String accountType) async {
    Database db = await initDB();
    var res = await db.rawQuery(
        'SELECT CategoryCode,CategoryDescription,ImageURL FROM AccountCategoryMst WHERE AccountType=? ORDER BY CategorySeqNo ASC', [accountType]);
    List<dynamic> json = res.isNotEmpty ? res : [];
    return json;
  }
  //
  // static Future<List<dynamic>> getCategoryFromAccountType(String accountType) async {
  //   Database db = await initDB();
  //   print('Database initialized: $db');
  //   print('Running query with accountType: $accountType');
  //
  //   var res = await db.rawQuery(
  //       'SELECT CategoryCode,CategoryDescription,ImageURL FROM AccountCategoryMst WHERE AccountType=?',
  //       [accountType]);
  //
  //   print('Query result: $res');
  //
  //   List<dynamic> json = res.isNotEmpty ? res : [];
  //   return json;
  // }

  static getHeaderTemplateFromViewId(String viewId) async {
    Database db = await initDB();
    var res = await db.rawQuery('SELECT HeaderTemplateJson FROM  TemplateDefinitionMst WHERE ViewId=?', [viewId]);
//    print("================" + res.toString());
    String json = res.isNotEmpty ? res.elementAt(0)['HeaderTemplateJson'] : "";
    return json;
  }

//  static getTableDataForChart(String tableName, String CustomerId) async {
//    print("Called from retrive data of table $tableName");
//    Database db = await initDB();
//    var res = await db
//        .rawQuery('SELECT * FROM  $tableName WHERE CustomerId=?', [CustomerId]);
//    List<dynamic> json = res.isNotEmpty ? res : [];
//    print("Data from table $tableName : $json");
//    return json;
//  }

  static closeDatabase() async {
    Database db = await initDB();
    db.close();
  }

  static getTableDataForChart(String tableName, String CustomerId, String condition) async {
    print("Called from retrive data of table $tableName");
    Database db = await initDB();
    var res = await db.rawQuery('SELECT * FROM  $tableName WHERE $condition?', [CustomerId]);
    List<dynamic> json = res.isNotEmpty ? res : [];
    print("Data from table $tableName : $json");
    return json;
  }

  static updateValueForAccount(
      String attvalue, String custId, String attCode, String accoutType, String categoryCode) async {
    Database db = await initDB();
    var res = await db.rawQuery(
        'UPDATE ProfessionalListAttribute SET AttributeValue = ? WHERE CustomerId=? AND AttributeCode=?',
        [attvalue, custId, attCode]);
    await addDataIntoChnagesTable(custId, accoutType, categoryCode, attCode, attvalue, DateTime.now());
    print("Response from update ProfessionalListAttribute : ${res}");
    List<dynamic> list = res.isNotEmpty ? res : [];
    return list;
  }

  static createTableLocalChanges() async {
    Database db = await initDB();
    String query =
        "CREATE TABLE IF NOT EXISTS LocalChanges (Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, CustomerId TEXT, AccountType TEXT, CategoryCode TEXT, AttributeCode TEXT, AttributeValue TEXT, ChangeTime TEXT)";
    await db.execute(query);
    print("Response from createTableLocalChanges");
    return true;
  }

  static addDataIntoChnagesTable(String CustomerId, String AccountType, String CategoryCode, String AttributeCode,
      String AttributeValue, DateTime ChangeTime) async {
    await createTableLocalChanges();
    Database db = await initDB();
    Map<String, String> changes = new HashMap();
    changes["CustomerId"] = CustomerId;
    changes["AccountType"] = AccountType;
    changes["CategoryCode"] = CategoryCode;
    changes["AttributeCode"] = AttributeCode;
    changes["AttributeValue"] = AttributeValue;
    changes["ChangeTime"] = Constants_data.dateToString(ChangeTime, "dd-MM-yyyy HH:mm:ss");

    bool isAlreadyAvailable =
        await checkAvailabilityInLocalChange(CustomerId, AccountType, CategoryCode, AttributeCode);

    var res;
    if (isAlreadyAvailable) {
      res = await db.rawQuery(
          'UPDATE LocalChanges SET AttributeValue = ?, ChangeTime=? WHERE CustomerId=? AND AccountType=? AND CategoryCode=? AND AttributeCode=?',
          [
            AttributeValue,
            Constants_data.dateToString(ChangeTime, "dd-MM-yyyy HH:mm:ss"),
            CustomerId,
            AccountType,
            CategoryCode,
            AttributeCode
          ]);
      print("********** Updated ${res} record succeessfully");
    } else {
      res = await db.insert("LocalChanges", changes);
      print("********** Inserted ${res} record succeessfully");
    }

    var res2 = await db.rawQuery('SELECT * FROM  LocalChanges');
    if (res2.length > 0) {
      Map<String, dynamic> finalResponse = new HashMap();
      finalResponse["saveAttributeJson"] = res2;
      print("********** Response from LocalChanges : ${jsonEncode(finalResponse)}");
    }

    return res;
  }

  static checkAvailabilityInLocalChange(CustomerId, AccountType, CategoryCode, AttributeCode) async {
    Database db = await initDB();
    var res = await db.rawQuery(
        'SELECT * FROM  LocalChanges WHERE CustomerId=? AND AccountType=? AND CategoryCode=? AND AttributeCode=?',
        [CustomerId, AccountType, CategoryCode, AttributeCode]);
    List<dynamic> json = res.isNotEmpty ? res : [];
    return json.length > 0;
  }

  static getProfessionalFromID(String Id, String accoutType) async {
    Database db = await initDB();
    var res = await db.rawQuery(
        'SELECT AttributeCode, AttributeValue FROM ProfessionalListAttribute WHERE CustomerId=? AND AccountType=?',
        [Id, accoutType]);
    List<dynamic> json = res.isNotEmpty ? res : [];
    return json;
  }

  static insertDataIntoTable(String table, Map<String, String> columns) async {
    Database db = await initDB();
    var res = await db.insert(table, columns);

    print("Data inserted successfully ${res}, Table : ${table}, Colums : ${columns}");
    return res;
  }

  static prformQueryOperation(String query, List<dynamic> args) async {
    print("Calling performQueryOperation Query = ${query}, params = ${args}");
    Database db = await initDB();
    var res = await db.rawQuery(query, args);
    // db.close();
    return res;
  }

  static getInboxData() async {
    Database db = await initDB();
    var res = await db.rawQuery(
        "SELECT * from MessageData WHERE (ShowInInbox = 'Y' OR ShowInInbox IS NULL) AND (Status != 'D' or Status IS NULL) Order By Date desc",
        []);
    print("Table data of Inbox : ${res}");
    db.close();
    return res;
  }

  static getFavoriteList(String accountType) async {
    Database db = await initDB();
    var res = await db.rawQuery('SELECT * FROM  tblFavouriteList WHERE AccountType=?', [accountType]);
    List<dynamic> json = res.isNotEmpty ? res : [];
    return json;
  }

  static updateFavoriteList(String ListId, String LevelIds) async {
    Database db = await initDB();
    var res = await db.rawQuery('UPDATE  tblFavouriteList SET LevelIds=? WHERE ListId=?', [LevelIds, ListId]);
    var json = res;
    return json;
  }

  static addFavoriteList(Map<String, String> args) async {
    Database db = await initDB();
    var res = await db.insert("", args);
    return res;
  }

  static testSystemQuery(String query) async {
    query = query.replaceAll("*", "'");
    print("Debug : SELECT CustomerId FROM ProfessionalList WHERE ${query} order by CustomerName");
    Database db = await initDB();
    var res = await db.rawQuery("SELECT CustomerId FROM ProfessionalList WHERE ${query} order by CustomerName", []);
    List<dynamic> json = res.isNotEmpty ? res : [];

    String custIds = "";
    for (int j = 0; j < json.length; j++) {
      if (j == 0) {
        custIds = "'" + json[j]["CustomerId"] + "'";
      } else {
        custIds = custIds + ",'" + json[j]["CustomerId"] + "'";
      }
    }
    return custIds;
  }

  static getSampleProductDetails() async {
    Database db = await initDB();
    var res = await db.rawQuery('SELECT * FROM  SampleProductDetails', []);
    List<dynamic> json = res.isNotEmpty ? res : [];
    return json;
  }

  static getConfigDetails() async {
    Database db = await initDB();
    var res = await db.rawQuery('SELECT * FROM  Config_Parameter_Mst', []);
    List<dynamic> json = res.isNotEmpty ? res : [];
    return json;
  }

  static deleteDatabaseFromFile() async {
    print("Database Deleted Called");
    Database db = await initDB();
    await db.close();
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "Profiler.db");
    await deleteDatabase(path);
    print("Database Deleted Successfully");
  }
}
