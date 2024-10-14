import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

import '../Constants/Constants_data.dart';
//1st profiler code//
// class CreateAllTables {
//   CreateAllTables._();
//
//   static List<dynamic> data = [];
//
//   static final CreateAllTables db = CreateAllTables._();
//   static Database _database;
//
//   Future<Database> get database async {
//     if (_database != null) return _database;
//     _database = await initDB();
//     return _database;
//   }
//
//   static initDB() async {
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentsDirectory.path, "Profiler.db");
//     return await openDatabase(path, version: 1, onOpen: (db) {});
//   }
//
//   // static Future<Database> initDB() async {
//   //   try {
//   //     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//   //     String path = join(documentsDirectory.path, "Profiler.db");
//   //
//   //     return await openDatabase(
//   //       path,
//   //       version: 1,
//   //       onCreate: (Database db, int version) async {
//   //         await createTables(db);
//   //         await createCategeoryTables(db);
//   //         await testDatabaseOperations(db);
//   //       },
//   //     );
//   //   } catch (e) {
//   //     print('Error initializing database: $e');
//   //     rethrow;
//   //   }
//   // }
//
//   static void createObject(jsonData, {isDeleteCurrent = true}) async {
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentsDirectory.path, "Profiler.db");
//     Database db = await openDatabase(path, version: 1, onOpen: (db) {});
//
//     List<dynamic> dt_ReturnedTables = jsonData["dt_ReturnedTables"];
//     int totalTables = 0,
//         emptyTables = 0,
//         errorInTables = 0,
//         creationError = 0;
//
//     List<dynamic> listTables = dt_ReturnedTables[0];
//     totalTables = listTables.length;
//
//     for (int i = 0; i < listTables.length; i++) {
//       //print("listTables length ${i}");
//       if (i == 0) continue;
//       String tableName;
//       if (i == 1) {
//         tableName = "ProfessionalList";
//       } else {
//         tableName = listTables[i]["TableName"];
//       }
//       if (tableName.trim() == "AccountListAttribute") {
//         tableName = "ProfessionalListAttribute";
//       }
//       int index = listTables[i]["Index"];
//       List<dynamic> listTableRows = dt_ReturnedTables[index];
//       if (isDeleteCurrent) {
//         await db.execute("DROP TABLE IF EXISTS ${tableName}");
//       }
//
//       if (listTableRows != null && listTableRows.length > 0) {
//         String query = makeCreateQuery(tableName, listTableRows[0]);
//         print("Query: ${query}");
//         try {
//           await db.execute(query);
//         } on Exception catch (exception) {
//           creationError++;
//         } catch (error) {
//           creationError++;
//         }
//         Batch batch = db.batch();
//         try {
//           for (int j = 0; j < listTableRows.length; j++) {
//             batch.insert(tableName, listTableRows[j]);
// //            insetIntoTable(tableName, listTableRows[j], db);
//             print("Inserting Row (${i},${j}) in Table ${tableName}");
//           }
//           await batch.commit();
//           print("Batch Commited");
//         } on Exception catch (exception) {
//           errorInTables++;
//         } catch (error) {
//           errorInTables++;
//         }
//       } else {
//         emptyTables++;
//         //print("Empty table on index ${index}, Table name ${tableName}");
//       }
//     }
//     print("Total Tables: ${totalTables - 1}");
//     print("Created Tables Tables: ${totalTables - 1 - creationError -
//         emptyTables}");
//     print("Error in Create Tables: ${creationError}");
//     print("Error in Tables: ${errorInTables}");
//     print("Empty Tables: ${emptyTables}");
// //    db.close();
//   }
//   static makeCreateQuery(String tableName, var sampleJson) {
//     print("********----- tableName: ${tableName}, sampleJson: ${sampleJson}");
//     String listColumns = "";
//     Map<String, dynamic> obj = sampleJson;
//     for (var colName in obj.keys) {
//       listColumns += "'${colName}'" + " Text,";
//     }
//     if (listColumns.length > 0) {
//       listColumns = listColumns.substring(0, listColumns.length - 1);
//       String query = "CREATE TABLE IF NOT EXISTS ${tableName} (" + listColumns +
//           ")";
//       print("********----- query: ${query}");
//       return query;
//     } else {
//       return "";
//     }
//   }
//   static createProfessionalListAttributeTable(listTableRows) async {
//     print("ListRows ProfessionalListAttribute :${listTableRows}");
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentsDirectory.path, "Profiler.db");
//     Database db = await openDatabase(path, version: 1, onOpen: (db) {});
//
//     String tableName = "ProfessionalListAttribute";
//     await db.execute("DROP TABLE IF EXISTS ${tableName}");
//
//     if (listTableRows != null && listTableRows.length > 0) {
//       String query = await makeCreateQuery(tableName, listTableRows[0]);
//       print("Query: ${query}");
//       try {
//         await db.execute(query);
//         print("Query Executed");
//       } on Exception catch (exception) {
//         print("Error: ${exception}");
//         //errorInTables++;
//       } catch (error) {
//         print("Error: ${error}");
//         //errorInTables++;
//       }
//       Batch batch = db.batch();
//       try {
//         for (int j = 0; j < listTableRows.length; j++) {
//           batch.insert(tableName, listTableRows[j]);
//           //insetIntoTable(tableName, listTableRows[j], db);
//           print("Inserting Row (${j}) in Table ${tableName}");
//         }
//         await batch.commit();
//         print("Batch Commited");
//       } on Exception catch (exception) {
//         print("Error: ${exception}");
//         //errorInTables++;
//       } catch (error) {
//         print("Error: ${error}");
//         //errorInTables++;
//       }
//     }
// //    db.close();
//   }
//   static insetIntoTable(String tableName, dynamic data, Database db) async {
//     if (db != null) {
//       var res = await db.insert(tableName, data);
//       return res;
//     } else {
//       print("Database null found");
//       return "";
//     }
//   }
//   Future<List<dynamic>> insertAll(String table, List<dynamic> objects, Database db) async {
//     List<dynamic> listRes = new List();
//     var res;
//     try {
//       await db.transaction((db) async {
//         objects.forEach((obj) async {
//           try {
//             var iRes = await db.insert(table, obj.toMap());
//             listRes.add(iRes);
//           } catch (ex) {
// //            DbHelper().databaseLog(CON_INSERT_MULTIPLE, "Error!", ex);
//           }
//         });
//       });
//       print("Data inserted for table: ${table}");
// //      DbHelper().databaseLog(CON_INSERT_MULTIPLE, table, listRes);
//       res = listRes;
//     } catch (er) {
// //      res = OutComeCallClient.ERROR;
// //      DbHelper().databaseLog(CON_INSERT_MULTIPLE, "Error!", er);
//     }
//     return res;
//   }
//   static createTableFromAPIResponse(listTableRows, table) async {
//     print(" ************** Creating table Message ************* ");
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentsDirectory.path, "Profiler.db");
//     Database db = await openDatabase(path, version: 1, onOpen: (db) {});
//
//     String tableName = table;
//     try {
//       await db.execute("DROP TABLE IF EXISTS ${tableName}");
//     } catch (err) {
//       Database db = await openDatabase(path, version: 1, onOpen: (db) {});
//       await db.execute("DROP TABLE IF EXISTS ${tableName}");
//     }
//
//     if (listTableRows != null && listTableRows.length > 0) {
//       String query = await makeCreateQuery(tableName, listTableRows[0]);
//       print("Query: ${query}");
//       try {
//         await db.execute(query);
//         print("Query Executed");
//       } on Exception catch (exception) {
//         print("Error: ${exception}");
//       } catch (error) {
//         print("Error: ${error}");
//       }
//       Batch batch = db.batch();
//       try {
//         for (int j = 0; j < listTableRows.length; j++) {
//           batch.insert(tableName, listTableRows[j]);
//           print("Inserting Row (${j}) in Table ${tableName}");
//         }
//         await batch.commit();
//         print("Batch Commited");
//       } on Exception catch (exception) {
//         print("Error: ${exception}");
//       } catch (error) {
//         print("Error: ${error}");
//       }
//     }
//     //db.close();
//   }
//
//   // static Future<void> createTables(Database db) async {
//   //   try {
//   //     await db.execute('''
//   //       CREATE TABLE TemplateDefinitionMst (
//   //         id INTEGER PRIMARY KEY AUTOINCREMENT,
//   //         AccountType TEXT,
//   //         TemplateJson TEXT,
//   //         HeaderTemplateJson TEXT,
//   //         ViewId TEXT
//   //       )
//   //     ''');
//   //     print('Table TemplateDefinitionMst created successfully.');
//   //   } catch (e) {
//   //     print('Error creating tables: $e');
//   //     rethrow;
//   //   }
//   // }
//   // static Future<void> createCategeoryTables(Database db) async {
//   //   try {
//   //     await db.execute('''
//   //       CREATE TABLE AccountCategoryMst (
//   //         id INTEGER PRIMARY KEY AUTOINCREMENT,
//   //         AccountType TEXT,
//   //         CategoryDescription TEXT,
//   //         CategoryCode TEXT,
//   //         ImageURL TEXT,
//   //         CategorySeqNo TEXT
//   //       )
//   //     ''');
//   //     print('Table AccountCategoryMst created successfully.');
//   //   } catch (e) {
//   //     print('Error creating tables: $e');
//   //     rethrow;
//   //   }
//   // }
//   // static Future<void> testDatabaseOperations(Database db) async {
//   //   await checkTableExists(db);
//   //   await checkRowsInserted(db);
//   // }
//   // static Future<void> checkTableExists(Database db) async {
//   //   try {
//   //     List<Map<String, dynamic>> tables = await db.rawQuery(
//   //         "SELECT name FROM sqlite_master WHERE type='table' AND name='TemplateDefinitionMst';"
//   //     );
//   //
//   //     if (tables.isNotEmpty) {
//   //       print('Table TemplateDefinitionMst exists.');
//   //     } else {
//   //       print('Table TemplateDefinitionMst does not exist.');
//   //     }
//   //   } catch (e) {
//   //     print('Error checking table existence: $e');
//   //     rethrow;
//   //   }
//   // }
//   // static Future<void> checkRowsInserted(Database db) async {
//   //   try {
//   //     List<Map<String, dynamic>> result = await db.query(
//   //         'TemplateDefinitionMst');
//   //
//   //     if (result.isNotEmpty) {
//   //       print('Rows inserted: ${result.length}');
//   //       for (var row in result) {
//   //         print('Row: $row');
//   //       }
//   //     } else {
//   //       print('No rows found in TemplateDefinitionMst.');
//   //     }
//   //   } catch (e) {
//   //     print('Error checking rows: $e');
//   //     rethrow;
//   //   }
//   // }
// // static Future<void> createTables(Database db) async {
// //   await db.execute('''
// //   CREATE TABLE TemplateDetails (
// //     id INTEGER PRIMARY KEY AUTOINCREMENT,
// //     AccountType TEXT,
// //     TemplateJson TEXT,
// //     HeaderTemplateJson TEXT,
// //     ViewId TEXT
// //   )
// // ''');
// // }
//
// }


class CreateAllTables {
  CreateAllTables._();

  static final CreateAllTables db = CreateAllTables._();
  static Database _database;

  // Future<Database> get database async {
  //   if (_database != null && _database.isOpen) {
  //     return _database;
  //   }
  //   _database = await initDB();
  //   return _database;
  // }
  Future<Database> get database async {
    if (_database != null) {
      if (_database.isOpen) {
        return _database;
      } else {
        _database = await initDB();
        return _database;
      }
    }
    _database = await initDB();
    return _database;
  }

  static Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "Profiler.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await createTables(db);
        await createCategeoryTables(db);
        print('Database created and tables initialized.');
      },
      onOpen: (db) async {
        await createTables(db);
        await createCategeoryTables(db);
        print('Database opened, ensuring tables exist.');
      },
    );
  }
  static void createObject(jsonData, {isDeleteCurrent = true}) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "Profiler.db");
    Database db = await openDatabase(path, version: 1, onOpen: (db) {});

    List<dynamic> dt_ReturnedTables = jsonData["dt_ReturnedTables"];
    int totalTables = 0, emptyTables = 0, errorInTables = 0, creationError = 0;

    List<dynamic> listTables = dt_ReturnedTables[0];
    totalTables = listTables.length;

    for (int i = 0; i < listTables.length; i++) {
      if (i == 0) continue;
      String tableName;
      if (i == 1) {
        tableName = "ProfessionalList";
      } else {
        tableName = listTables[i]["TableName"];
      }
      if (tableName.trim() == "AccountListAttribute") {
        tableName = "ProfessionalListAttribute";
      }
      int index = listTables[i]["Index"];
      List<dynamic> listTableRows = dt_ReturnedTables[index];
      if (isDeleteCurrent) {
        await db.execute("DROP TABLE IF EXISTS $tableName");
      }

      if (listTableRows != null && listTableRows.length > 0) {
        String query = makeCreateQuery(tableName, listTableRows[0]);
        print("Query: $query");
        try {
          await db.execute(query);
        } catch (error) {
          creationError++;
        }
        Batch batch = db.batch();
        try {
          for (int j = 0; j < listTableRows.length; j++) {
            batch.insert(tableName, listTableRows[j]);
            print("Inserting Row ($i, $j) in Table $tableName");
          }
          await batch.commit();
          print("Batch Commited");
        } catch (error) {
          errorInTables++;
        }
      } else {
        emptyTables++;
      }
    }
    print("Total Tables: ${totalTables - 1}");
    print("Created Tables: ${totalTables - 1 - creationError - emptyTables}");
    print("Error in Create Tables: $creationError");
    print("Error in Tables: $errorInTables");
    print("Empty Tables: $emptyTables");
  }
  static makeCreateQuery(String tableName, var sampleJson) {
    print("********----- tableName: $tableName, sampleJson: $sampleJson");
    String listColumns = "";
    Map<String, dynamic> obj = sampleJson;
    for (var colName in obj.keys) {
      listColumns += "'$colName' Text,";
    }
    if (listColumns.isNotEmpty) {
      listColumns = listColumns.substring(0, listColumns.length - 1);
      String query = "CREATE TABLE IF NOT EXISTS $tableName ($listColumns)";
      print("********----- query: $query");
      return query;
    } else {
      return "";
    }
  }
  static Future<void> createTables(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS TemplateDefinitionMst (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          AccountType TEXT,
          TemplateJson TEXT,
          HeaderTemplateJson TEXT,
          ViewId TEXT
        )
      ''');
      print('Table TemplateDefinitionMst created successfully.');
    } catch (e) {
      print('Error creating TemplateDefinitionMst: $e');
    }
  }

  static Future<void> createCategeoryTables(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS AccountCategoryMst (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          AccountType TEXT,
          CategoryDescription TEXT,
          CategoryCode TEXT,
          ImageURL TEXT,
          CategorySeqNo TEXT
        )
      ''');
      print('Table AccountCategoryMst created successfully.');
    } catch (e) {
      print('Error creating AccountCategoryMst: $e');
    }
  }

  static Future<bool> checkIfTableExists(String tableName, Database db) async {
    List<Map<String, dynamic>> result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName';");
    return result.isNotEmpty;
  }

  Future<void> fetchAndStoreTemplateData() async {
    final url =
        'http://122.170.7.252/MicroDishaWebApiPublish/api/Profiler/GetTemplateJSONDetails';

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
        final data = json.decode(response.body);
        final db = await database;

        // Check and create table if not exists
        bool tableExists = await checkIfTableExists('TemplateDefinitionMst', db);
        if (!tableExists) {
          print('Table TemplateDefinitionMst does not exist. Creating table...');
          await createTables(db);
        }

        await storeTemplateDataLocally(data);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching and storing template data: $e');
    }
  }

  Future<void> storeTemplateDataLocally(Map<String, dynamic> apiData) async {
    final db = await database;

    try {
      final List<dynamic> templateDetails =
      apiData["dt_ReturnedTables"]['dt_TemplateJSONDetails'];

      for (var item in templateDetails) {
        await db.insert('TemplateDefinitionMst', {
          'AccountType': item['AccountType'],
          'TemplateJson': item['TemplateJson'],
          'HeaderTemplateJson': item['HeaderTemplateJson'],
          'ViewId': item['ViewId'],
        });
      }

      print('Template data inserted successfully.');
    } catch (e) {
      print('Error inserting template data: $e');
    }
  }

  Future<void> fetchAndStoreCategoryData() async {
    final url =
        'http://122.170.7.252/MicroDishaWebApiPublish/api/Profiler/GetCategoryMstDetails';
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
        final data = json.decode(response.body);
        final db = await database;

        // Check and create table if not exists
        bool tableExists = await checkIfTableExists('AccountCategoryMst', db);
        if (!tableExists) {
          print('Table AccountCategoryMst does not exist. Creating table...');
          await createCategeoryTables(db);
        }
        await storeCategoryDataLocally(data);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching and storing category data: $e');
    }
  }

  Future<void> storeCategoryDataLocally(Map<String, dynamic> apiData) async {
    final db = await database;

    try {
      final List<dynamic> categoryDetails =
      apiData["dt_ReturnedTables"]['dt_CategoryMstDetails'];

      for (var item in categoryDetails) {
        await db.insert('AccountCategoryMst', {
          'AccountType': item['AccountType'],
          'CategoryDescription': item['CategoryDescription'],
          'CategoryCode': item['CategoryCode'],
          'ImageURL': item['ImageURL'],
          'CategorySeqNo': item['CategorySeqNo'],
        });
      }
      print('Category data inserted successfully.');
    } catch (e) {
      print('Error inserting category data: $e');
    }
  }
}

//2nd one working//
// class CreateAllTables {
//   CreateAllTables._();
//
//   static final CreateAllTables db = CreateAllTables._();
//   static Database _database;
//
//   // Future<Database> get database async {
//   //   if (_database != null && _database.isOpen) return _database;
//   //   _database = await initDB();
//   //   return _database;
//   // }
//
//   Future<Database> get database async {
//     if (_database != null) {
//       // Check if the database is open before returning it
//       if (_database.isOpen) {
//         return _database;
//       } else {
//         // Reinitialize the database if it is closed
//         _database = await initDB();
//         return _database;
//       }
//     }
//     // Initialize the database if it's null
//     _database = await initDB();
//     return _database;
//   }
//   static initDB() async {
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentsDirectory.path, "Profiler.db");
//
//     // Open database and ensure tables are created
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         // This block is only called when the database is first created
//         await createTables(db);
//         await createCategeoryTables(db);
//         print('Database created and tables initialized.');
//       },
//       onOpen: (db) async {
//         // This block is called every time the database is opened (including after deletion)
//         await createTables(db);
//         await createCategeoryTables(db);
//         print('Database opened, ensuring tables exist.');
//         await testDatabaseOperations(db);  // Verify the database structure
//       },
//     );
//   }
//
//   static void createObject(jsonData, {isDeleteCurrent = true}) async {
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentsDirectory.path, "Profiler.db");
//     Database db = await openDatabase(path, version: 1, onOpen: (db) {});
//
//     List<dynamic> dt_ReturnedTables = jsonData["dt_ReturnedTables"];
//     int totalTables = 0,
//         emptyTables = 0,
//         errorInTables = 0,
//         creationError = 0;
//
//     List<dynamic> listTables = dt_ReturnedTables[0];
//     totalTables = listTables.length;
//
//     for (int i = 0; i < listTables.length; i++) {
//       //print("listTables length ${i}");
//       if (i == 0) continue;
//       String tableName;
//       if (i == 1) {
//         tableName = "ProfessionalList";
//       } else {
//         tableName = listTables[i]["TableName"];
//       }
//       if (tableName.trim() == "AccountListAttribute") {
//         tableName = "ProfessionalListAttribute";
//       }
//       int index = listTables[i]["Index"];
//       List<dynamic> listTableRows = dt_ReturnedTables[index];
//       if (isDeleteCurrent) {
//         await db.execute("DROP TABLE IF EXISTS ${tableName}");
//       }
//
//       if (listTableRows != null && listTableRows.length > 0) {
//         String query = makeCreateQuery(tableName, listTableRows[0]);
//         print("Query: ${query}");
//         try {
//           await db.execute(query);
//         } on Exception catch (exception) {
//           creationError++;
//         } catch (error) {
//           creationError++;
//         }
//         Batch batch = db.batch();
//         try {
//           for (int j = 0; j < listTableRows.length; j++) {
//             batch.insert(tableName, listTableRows[j]);
// //            insetIntoTable(tableName, listTableRows[j], db);
//             print("Inserting Row (${i},${j}) in Table ${tableName}");
//           }
//           await batch.commit();
//           print("Batch Commited");
//         } on Exception catch (exception) {
//           errorInTables++;
//         } catch (error) {
//           errorInTables++;
//         }
//       } else {
//         emptyTables++;
//         //print("Empty table on index ${index}, Table name ${tableName}");
//       }
//     }
//     print("Total Tables: ${totalTables - 1}");
//     print("Created Tables Tables: ${totalTables - 1 - creationError -
//         emptyTables}");
//     print("Error in Create Tables: ${creationError}");
//     print("Error in Tables: ${errorInTables}");
//     print("Empty Tables: ${emptyTables}");
// //    db.close();
//   }
//   static makeCreateQuery(String tableName, var sampleJson) {
//     print("********----- tableName: ${tableName}, sampleJson: ${sampleJson}");
//     String listColumns = "";
//     Map<String, dynamic> obj = sampleJson;
//     for (var colName in obj.keys) {
//       listColumns += "'${colName}'" + " Text,";
//     }
//     if (listColumns.length > 0) {
//       listColumns = listColumns.substring(0, listColumns.length - 1);
//       String query = "CREATE TABLE IF NOT EXISTS ${tableName} (" + listColumns +
//           ")";
//       print("********----- query: ${query}");
//       return query;
//     } else {
//       return "";
//     }
//   }
//
//   static Future<void> createTables(Database db) async {
//     try {
//       await db.execute('''
//        CREATE TABLE IF NOT EXISTS TemplateDefinitionMst (
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           AccountType TEXT,
//           TemplateJson TEXT,
//           HeaderTemplateJson TEXT,
//           ViewId TEXT
//         )
//       ''');
//       print('Table TemplateDefinitionMst created successfully.');
//     } catch (e) {
//       print('Error creating tables: $e');
//       rethrow;
//     }
//   }
//   static Future<void> createCategeoryTables(Database db) async {
//     try {
//       await db.execute('''
//        CREATE TABLE IF NOT EXISTS AccountCategoryMst (
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           AccountType TEXT,
//           CategoryDescription TEXT,
//           CategoryCode TEXT,
//           ImageURL TEXT,
//           CategorySeqNo TEXT
//         )
//       ''');
//       print('Table AccountCategoryMst created successfully.');
//     } catch (e) {
//       print('Error creating tables: $e');
//       rethrow;
//     }
//   }
//   static Future<void> testDatabaseOperations(Database db) async {
//     await checkTableExists(db);
//     await checkRowsInserted(db);
//   }
//   static Future<void> checkTableExists(Database db) async {
//     try {
//       List<Map<String, dynamic>> tables = await db.rawQuery(
//           "SELECT name FROM sqlite_master WHERE type='table' AND name='TemplateDefinitionMst';"
//       );
//
//       if (tables.isNotEmpty) {
//         print('Table TemplateDefinitionMst exists.');
//       } else {
//         print('Table TemplateDefinitionMst does not exist.');
//       }
//     } catch (e) {
//       print('Error checking table existence: $e');
//       rethrow;
//     }
//   }
//   static Future<void> checkRowsInserted(Database db) async {
//     try {
//       List<Map<String, dynamic>> result = await db.query(
//           'TemplateDefinitionMst');
//
//       if (result.isNotEmpty) {
//         print('Rows inserted: ${result.length}');
//         for (var row in result) {
//           print('Row: $row');
//         }
//       } else {
//         print('No rows found in TemplateDefinitionMst.');
//       }
//     } catch (e) {
//       print('Error checking rows: $e');
//       rethrow;
//     }
//   }
//   Future<void> fetchAndStoreData() async {
//     final url = 'http://122.170.7.252/MicroDishaWebApiPublish/api/Profiler/GetTemplateJSONDetails';
//
//     Map<String, String> headers = {
//       "Content-type": "application/json",
//       "Authorization": Constants_data.SessionId,
//       "CountryCode": Constants_data.Country,
//       "IPAddress": Constants_data.deviceId,
//       "UserId": Constants_data.repId,
//     };
//
//     try {
//       final response = await http.get(Uri.parse(url),headers: headers);
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         await storeDataLocally(data);
//       } else {
//         throw Exception('Failed to load data');
//       }
//     } catch (e) {
//       print('Error fetching and storing data: $e');
//     }
//   }
//   Future<void> storeDataLocally(Map<String, dynamic> apiData) async {
//     final db = await database;
//     try {
//       final List<dynamic> templateDetails = apiData["dt_ReturnedTables"]['dt_TemplateJSONDetails'];
//
//       for (var item in templateDetails) {
//         await db.insert('TemplateDefinitionMst', {
//           'AccountType': item['AccountType'],
//           'TemplateJson': item['TemplateJson'],
//           'HeaderTemplateJson': item['HeaderTemplateJson'],
//           'ViewId': item['ViewId'],
//         });
//       }
//
//       print('Data inserted successfully.');
//     } catch (e) {
//       print('Error inserting data: $e');
//     }
//   }
//   Future<void> categeorydata() async {
//     final url = 'http://122.170.7.252/MicroDishaWebApiPublish/api/Profiler/GetCategoryMstDetails';
//     Map<String, String> headers = {
//       "Content-type": "application/json",
//       "Authorization": Constants_data.SessionId,
//       "CountryCode": Constants_data.Country,
//       "IPAddress": Constants_data.deviceId,
//       "UserId": Constants_data.repId,
//     };
//
//     try {
//       final response = await http.get(Uri.parse(url),headers: headers);
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         await storeCategeorydataLocally(data);
//       } else {
//         throw Exception('Failed to load data');
//       }
//     } catch (e) {
//       print('Error fetching and storing data: $e');
//     }
//   }
//   Future<void> storeCategeorydataLocally(Map<String, dynamic> apiData) async {
//     final db = await database;
//
//     try {
//       final List<dynamic> templateDetails = apiData["dt_ReturnedTables"]['dt_CategoryMstDetails'];
//
//       for (var item in templateDetails) {
//         await db.insert('AccountCategoryMst', {
//           'AccountType': item['AccountType'],
//           'CategoryDescription': item['CategoryDescription'],
//           'CategoryCode': item['CategoryCode'],
//           'ImageURL': item['ImageURL'],
//           'CategorySeqNo': item['CategorySeqNo'],
//         });
//       }
//       print('Data inserted successfully.');
//     } catch (e) {
//       print('Error inserting data: $e');
//     }
//   }
// }