import 'dart:collection';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Constants/Constants_data.dart';
import '../Theme/DarkThemeProvider.dart';
import '../Widget/DateTimePickerDialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Constants/Constants_data.dart';
import '../Theme/DarkThemeProvider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io'; // Use 'io.File'
import '../Widget/DateTimePickerDialog.dart';
import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
import 'package:intl/intl.dart';
import 'AccountListScreen.dart';

class InvoiceUploadScreen extends StatefulWidget {
  @override
  _InvoiceUploadScreenState createState() => _InvoiceUploadScreenState();
}

// String accountType;
// String doc_No;

class _InvoiceUploadScreenState extends State<InvoiceUploadScreen> {
  ApiBaseHelper _helper = ApiBaseHelper();
  DarkThemeProvider themeChange;
  ThemeData themeData;
  String accountType;
  String doc_No;
  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> cardData = [];

  String _buttonLabel = 'Upload Invoice';
  Future<void> fetchDataFuture;

  TextEditingController _invoiceDateController = TextEditingController();
  TextEditingController _invoiceNumberController = TextEditingController();
  //TextEditingController _invoiceDateController = TextEditingController();
  PlatformFile _selectedFile;

  int _currentSortColumn = 0;
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
   // fetchDataFuture = fetchTableData();
  }
  @override
  Widget build(BuildContext context) {
    Constants_data.currentScreenContext = context;
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    Map<String, dynamic> arg = ModalRoute.of(context).settings.arguments;
    accountType = arg["accountType"];
     doc_No = arg["doctor_docNo"];

    fetchDataFuture ??= fetchTableData();

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Constants_data.getFlexibleAppBar(themeChange.darkTheme),
        backgroundColor: Colors.transparent,
        title: Text("INSIGHTS"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invoice Upload For FGO',
                style: TextStyle(
                    fontSize: 19, color: Colors.blue[900], fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              FutureBuilder<Map<String, dynamic>>(
               // future: fetchTableData(),
              //  future: fetchDataFuture,
                future: fetchDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                    return Text('No data found');
                  } else {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child:
                     // children: [
                        Container(
                          // width: 800,
                          padding: const EdgeInsets.all(2.0),
                          // child: SingleChildScrollView(
                          //   scrollDirection: Axis.horizontal,
                          child:buildTable(tableData) ,
                        ) ,
                        //),
                        //buildTable(tableData),
                       // SizedBox(height: 10),
                        //  Text(
                        //    'Cards:',
                        //    style: TextStyle(
                        //        fontSize: 20, fontWeight: FontWeight.bold),
                        //  ),
                        //  SizedBox(height: 10),
                        // ...buildCards(cardData),
                     // ],
                    );
                  }
                },
              ),
              SizedBox(height: 20),
              Text("Items",  style: TextStyle(
                  fontSize: 16, color: Colors.blue[900], fontWeight: FontWeight.bold)),
              ...buildCards(cardData),
              Divider(thickness: 2,color: Colors.blueGrey[100]),
              SizedBox(height: 20),
              Text(
                'Please Upload invoice Number and Invoice Date for the above Products.',
                style: TextStyle(fontSize: 16,
                  //fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              buildInvoiceTextField('Invoice No' ,  _invoiceNumberController),
              buildInvoiceTextField('Invoice Date', _invoiceDateController),
              SizedBox(height: 20),
              Text(
                'Please Upload invoice so that we can further proceed for credit note generation.',
                style: TextStyle(fontSize: 16,
                  //fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  getFile(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(5),
                    elevation: 12.0,
                    textStyle: const TextStyle(color: Colors.white)),
                child: Text(_buttonLabel),
              ),
              SizedBox(height: 8),
              Text(
                'NOTE : Accepted formats are jpg,jpeg,png,pdf and the file size must be 5MB or less..',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal,
                ),
              ),
              // buildInvoiceTextField('Invoice No' ,  _invoiceNumberController),
              // buildInvoiceTextField('Invoice Date', _invoiceDateController),
              // SizedBox(height: 20),
              // ...buildCards(cardData),
              SizedBox(height: 25),
              Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 0, 0, 0)),
              ElevatedButton(
                onPressed: () {
                  saveData();
                },
                child: Text('Save'),
              ),

            ],
          ),
        ),
      ),
    );
  }
  List<dynamic> returnedTables = [];
  Future<Map<String, dynamic>> fetchTableData() async {
    bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
    if (isNetworkAvailable) {
      if (doc_No == null || doc_No.isEmpty) {
        print('doc_No is not set properly.');
        return null;
      }

      String url = '/Mail/GetInsightDetails?docNo=$doc_No';
      try {
        // Call the helper's get method
        dynamic response = await _helper.get(url);

        // Since the response is already a parsed JSON, directly access its fields
        if (response['Status'] == 0){
          showAlertDialog1(response["Message"]);
          //Constants_data.toastError(response["Message"]);
        }
        else if (response['Status'] == 1) {
           returnedTables = response['dt_ReturnedTables'][0];

          List<Map<String, dynamic>> fetchedTableData = [];
          List<Map<String, dynamic>> fetchedCardData = [];

          for (var row in returnedTables) {
            fetchedTableData.add({
              "DoctorName": row["DoctorName"],
              "employee_name": row["employee_name"],
              "customerName": row["customerName"],
              "level1_approved_by_name": row["level1_approved_by_name"],
              "level2_approved_by_name": row["level2_approved_by_name"],
            });

            fetchedCardData.add({
              "item_desc": row["item_desc"],
              "product_code": row["product_code"],
              "doctor_code": row["doctor_code"],
              "rep_code": row["rep_code"],
              "supply_through": row["supply_through"],
              "scheme_type": row["scheme_type"],
              "discount_on": row["discount_on"],
              "discount_value": row["discount_value"],
              "quantity": row["quantity"],
              "fgo_value": row["fgo_value"],
              "inclusive_exclusive": row["inclusive_exclusive"]
            });
          }

          setState(() {
            tableData = fetchedTableData;
            cardData = fetchedCardData;
          });

          return {
            "tableData": tableData,
            "cardData": cardData,
          };
        }
        else if (response['Status'] == 2){
          //Constants_data.toastError(response["Message"]);
          showAlertDialog1(response["Message"]);
        }
        else {
          print('Failed to load data. Status: ${response['Status']}, Message: ${response['Message']}');
        }
      } catch (e) {
        print('Error: $e');
      }
    } else {
      await Constants_data.openDialogNoInternetConection(context);
    }
  }
  Widget buildTables(List<Map<String, dynamic>> tableData) {
    return DataTable(
      headingRowHeight: 30,
      columnSpacing: 6,
      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue[800]),
      dividerThickness: 3,
      decoration: BoxDecoration(
        border:Border(
          right: Divider.createBorderSide(context, width: 2.0),
          left: Divider.createBorderSide(context, width: 2.0),
        ),
      ),
      showBottomBorder: true,
      sortColumnIndex: _currentSortColumn,
      sortAscending: _isAscending,
      columns: [
        DataColumn(label: Text('Doctor',style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold), )),
        DataColumn(label: Text('RepName',style: TextStyle(fontSize: 15, color: Colors.white,fontWeight: FontWeight.bold),)),
        DataColumn(label: Text('Distributor',style: TextStyle(fontSize: 15, color: Colors.white,fontWeight: FontWeight.bold),)),
        DataColumn(label: Text('ApprovedBy Level1',style: TextStyle(fontSize: 15, color: Colors.white,fontWeight: FontWeight.bold),)),
        DataColumn(label: Text('ApprovedBy Level2',style: TextStyle(fontSize: 15, color: Colors.white,fontWeight: FontWeight.bold),)),
      ],
      rows: tableData.isNotEmpty
      ? [
      DataRow(
        cells: [
          DataCell(
            Container(
              width: 73, // Set specific width for this cell
              child: Text(tableData[0]["DoctorName"] ?? ''),
            ),
          ),
          DataCell(
            Container(
              width: 73, // Set specific width for this cell
              child: Text(tableData[0]["employee_name"] ?? ''),
            ),
          ),
          DataCell(
            Container(
              width: 75, // Set specific width for this cell
              child: Text(tableData[0]["customerName"] ?? ''),
            ),
          ),
          DataCell(
            Container(
              width: 75, // Set specific width for this cell
              child: Text(tableData[0]["level1_approved_by_name"] ?? ''),
            ),
          ),
          DataCell(
            Container(
              width: 75, // Set specific width for this cell
              child: Text(tableData[0]["level2_approved_by_name"] ?? ''),
            ),
          ),
        ],
      )
      ] : [],
    );
  }
  Widget buildTable(List<Map<String, dynamic>> tableData) {
    bool displayLevel2Column =
         returnedTables[0]["Is_level2_approval_required"] == "Y";

    return DataTable(
      headingRowHeight: 30,
      columnSpacing: 5,
      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue[800]),
      dividerThickness: 3,
      decoration: BoxDecoration(
        border: Border(
          right: Divider.createBorderSide(context, width: 2.0),
          left: Divider.createBorderSide(context, width: 2.0),
        ),
      ),
      showBottomBorder: true,
      sortColumnIndex: _currentSortColumn,
      sortAscending: _isAscending,
      columns: [
        DataColumn(
          label: Text(
            'Doctor',
            style: TextStyle(
                fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'RepName',
            style: TextStyle(
                fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Distributor',
            style: TextStyle(
                fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Level1 Approved',
            style: TextStyle(
                fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        if (displayLevel2Column) // Conditionally include this column
          DataColumn(
            label: Text(
              'Level2 Approved',
              style: TextStyle(
                  fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
      ],
      rows: tableData.isNotEmpty
          ? [
        DataRow(
          cells: [
            DataCell(
              Container(
                width: 63, // Set specific width for this cell
                child: Text(tableData[0]["DoctorName"] ?? ''),
              ),
            ),
            DataCell(
              Container(
                width: 73, // Set specific width for this cell
                child: Text(tableData[0]["employee_name"] ?? ''),
              ),
            ),
            DataCell(
              Container(
                width: 73, // Set specific width for this cell
                child: Text(tableData[0]["customerName"] ?? ''),
              ),
            ),
            DataCell(
              Container(
                width: 75, // Set specific width for this cell
                child: Text(tableData[0]["level1_approved_by_name"] ?? ''),
              ),
            ),
            if (displayLevel2Column)
              DataCell(
                Container(
                  width: 75, // Set specific width for this cell
                  child: Text(
                      tableData[0]["level2_approved_by_name"] ?? ''),
                ),
              ),
          ],
        )
      ]
          : [],
    );
  }
  List<Widget> buildCards(List<Map<String, dynamic>> cardData) {
    return [
      Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        children: cardData.map((card) {
          return Container(
            width: 180, // Adjust the width as needed
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (card['scheme_type'] == "Trade Discount") ...[
                      Text("${card['item_desc']}", style: TextStyle(fontSize: 13, color: Colors.blue)),
                      Text("FGO Type: ${card['scheme_type']}"),
                      Text("Discount Value: ${card['discount_value']}"),
                      Text("Quantity: ${card['quantity']}"),
                      Text("FGO Value: ${card['fgo_value']}"),
                    ] else if (card['scheme_type'] == "Rate Difference") ...[
                      Text("${card['item_desc']}", style: TextStyle(fontSize: 13, color: Colors.blue)),
                      Text("FGO Type: ${card['scheme_type']}"),
                      Text("Discount On: ${card['discount_on']}"),
                      Text("Discount Value: ${card['discount_value']}"),
                      Text("Quantity: ${card['quantity']}"),
                      Text("FGO Value: ${card['fgo_value']}"),
                    ]else if (card['scheme_type'] == "Fixed Rate") ...[
                      Text("${card['item_desc']}", style: TextStyle(fontSize: 13, color: Colors.blue)),
                      Text("FGO Type: ${card['scheme_type']}"),
                      //Text("Discount On: ${card['discount_on']}"),
                      Text("Discount Value: ${card['discount_value']}"),
                      Text("Quantity: ${card['quantity']}"),
                      Text("FGO Value: ${card['fgo_value']}"),
                    ] else if (card['scheme_type'] == "Extra Scheme") ...[
                      Text("${card['item_desc']}", style: TextStyle(fontSize: 13, color: Colors.blue)),
                      Text("FGO Type: ${card['scheme_type']}"),
                      Text("Inclusive/\nExclusive  : ${card['inclusive_exclusive']}"),
                      Text("Total Goods: ${card['discount_on']}"),
                      Text("Free Goods: ${card['discount_value']}"),
                      Text("Quantity: ${card['quantity']}"),
                      Text("FGO Value: ${card['fgo_value']}"),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ];
  }
  Widget buildInvoiceTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(
            height: 40,
            width: 160, // Adjust width as needed
            child: GestureDetector(
              onTap: label == 'Invoice Date'
                  ? () async {
                String selectedDate = await DateTimePickerDialog.selectDate(
                  themeChange: themeChange,
                  context: context,
                  template: {
                    "format": "DD-MM-YYYY",
                    //"format": "yyyy-MM-dd",
                    "selected_date": controller.text.isNotEmpty
                        ? controller.text
                        : "today",
                  },
                );
                if (selectedDate != null) {
                  setState(() {
                    controller.text = selectedDate;
                  });
                }
              }
                  : null,
              child: AbsorbPointer(
                absorbing: label == 'Invoice Date',
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: label == 'Invoice Date' ? "DD-MM-YYYY" : "Invoice",
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void getFile(BuildContext context) async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
     type: FileType.custom,
     allowedExtensions: ['jpg','jpeg', 'png', 'pdf'],
    );
    if (result != null) {
      setState(() {
        _selectedFile = result.files.first; // Store the selected file
        _buttonLabel = '${result.files.single.name}';
      });
      print('File picked: ${_selectedFile.name}');
    } else {
      print('No file picked');
    }
  }

  Future<void> saveData() async {
    bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
    if (isNetworkAvailable) {
      if (!validateInputs()) {
        return;
      }
      String message;
      String url = "/Mail/SaveInsights";

      // Fields for the request
      Map<String, String> fields = {
       // 'invoice_date': _invoiceDateController.text,
        'invoice_date': formatInvoiceDate(_invoiceDateController.text), // Convert date
        'invoice_no': _invoiceNumberController.text,
        'docNo': doc_No, // Make sure `doc_No` is a valid variable
      };

      // Check if file is selected
      File selectedFile;
      if (_selectedFile != null) {
        try {
          selectedFile = File(_selectedFile.path);
        } catch (e) {
          print('Error reading file: $e');
          Constants_data.toastError('Error reading file.');
          return;
        }
      }
      try {
        // Call the postMultipart method
        final response = await _helper.postMultipart(url, fields, selectedFile, 'uploadedFile');
        // Handle the response
        if (response["Status"] == 0) {
          showAlertDialog1(response["Message"]);
        }
        else  if (response["Status"] == 1) {
          showAlertDialog(response["Message"]);
         // cleardata();
        }
        else  if (response["Status"] == 2) {
          //Constants_data.toastError(response["Message"]);
          showAlertDialog1(response["Message"]);
        }
        else {
          showAlertDialog1("Invoice details not updated");
          // Constants_data.toastError("Invoice details not updated.");
          // setState(() {
          //   isLoading = false; // Stop the loading indicator
          // });
        }
      } catch (e) {
        Constants_data.toastError("Error saving data: $e");
        print("Error in saving data: $e");
      }
    } else {
      // Handle no network condition
      await Constants_data.openDialogNoInternetConection(context);
    }
  }
  String formatInvoiceDate(String date) {
    try {
      DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(date);
      String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      return formattedDate;
    } catch (e) {
      print('Error formatting date: $e');
      return date; // Return the original date if there's an error
    }
  }
  void showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alert"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () async {
                // Create a valid map structure with correct key-value pairs
                Map<String, dynamic> arg = {
                  "account_type": "FGO",
                  "menu_title": "FGO List",
                  "api_name": "GetFGOListDetails",
                  "api_parameters": jsonEncode({"accountType": "FGO"})
                };
                await Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountListScreen(),
                    settings: RouteSettings(
                      arguments: arg,
                    ),
                  ),
                  ModalRoute.withName('/HomeScreenRMT'), // Replace '/home' with your home or dashboard route
                );
              },
            ),
          ],
        );
      },
    );
  }
  void showAlertDialog1(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alert"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  bool validateInputs() {
    if (_invoiceNumberController.text.isEmpty) {
      showAlertDialog1("Invoice number cannot be empty");
      return false;
    } else if (_invoiceDateController.text.isEmpty) {
      showAlertDialog1("Invoice date cannot be empty");
      return false;
    } else if (_selectedFile == null) {
      showAlertDialog1("Please upload a file");
      return false;
    }else if (_selectedFile.size > 5 * 1024 * 1024) {  // Check if file size is larger than 5MB
      showAlertDialog1("File size exceeds 5MB. Please select a smaller file.");
      return false;
    }
    return true;
  }
  void cleardata(){
    setState(() {
      _invoiceNumberController.clear();
      _invoiceDateController.clear();
      _selectedFile = null;
      _buttonLabel = 'Upload Invoice';
      FilePicker.platform.clearTemporaryFiles();
    });
  }
}

// List<Widget> buildCard(List<Map<String, dynamic>> cardData) {
//   final groupedData = <String, List<Map<String, dynamic>>>{};
//   for (var item in cardData) {
//     final fgoType = item['scheme_type'] as String;
//     if (!groupedData.containsKey(fgoType)) {
//       groupedData[fgoType] = [];
//     }
//     groupedData[fgoType].add(item);
//   }
//
//   // Build cards for each group
//   return groupedData.entries.map((entry) {
//     final fgoType = entry.key;
//     final items = entry.value;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text(
//             'FGO Type: $fgoType',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueAccent,
//             ),
//           ),
//         ),
//         ...items.asMap().entries.map((entry) {
//           final index = entry.key;
//           final item = entry.value;
//
//           return Container(
//             height: 230,
//             width: double.infinity,
//             margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//             child: Stack(
//               children: [
//                 Card(
//                   elevation: 5,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.all(10),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(height: 20),
//                         Text(
//                           item['item_desc'],
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blueAccent,
//                           ),
//                         ),
//                         SizedBox(height: 5),
//                         if (fgoType == 'Extra Scheme') ...[
//                           Text(
//                             'FGO Type: $fgoType',
//                             style: TextStyle(fontSize: 16),
//                           ),
//                           Text(
//                             'Discount on: ${item['discount_on']}',
//                             style: TextStyle(fontSize: 16),
//                           ),
//                           Text(
//                             'Discount Value: ${item['discount_value']}',
//                             style: TextStyle(fontSize: 16),
//                           ),
//
//                         ]
//                         else if (fgoType == 'Rate Difference') ...[
//                           Text(
//                             'FGO Type: $fgoType',
//                             style: TextStyle(fontSize: 16),
//                           ),
//                           Text(
//                             'Discount Value: ${item['discount_value']}',
//                             style: TextStyle(fontSize: 16),
//                           ),
//
//                         ]
//                         else if (fgoType == 'Free Goods') ...[
//                             Text(
//                               'FGO Type: $fgoType',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                             Text(
//                               'Inclusive/Exclusive: ${item['inclusive_exclusive']}',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                             Text(
//                               'Total Goods: ${item['discount_on']}',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                             Text(
//                               'Scheme Goods: ${item['discount_value']}',
//                               style: TextStyle(fontSize: 16),
//                             ),
//
//                           ],
//                       ],
//                     ),
//                   ),
//                 ),
//
//               ],
//             ),
//           );
//         }).toList(),
//       ],
//     );
//   }).toList();
// }
// Widget buildTable2(List<Map<String, dynamic>> tableData) {
//   return DataTable2(
//     columnSpacing: 12,
//     horizontalMargin: 12,
//     minWidth: 600,
//     columns: [
//       DataColumn2(label: Text('Doctor',), size: ColumnSize.L),
//       DataColumn2(label: Text('RepName'), size: ColumnSize.M),
//       DataColumn2(label: Text('Distributor'), size: ColumnSize.M),
//     ],
//     rows: tableData.map((row) {
//       return DataRow(cells: [
//         DataCell(Text(row["DoctorName"] ?? '')),
//         DataCell(Text(row["employee_name"] ?? '')),
//         DataCell(Text(row["customerName"] ?? '')),
//       ]);
//     }).toList(),
//   );
// }
//  Widget buildTable1(List<Map<String, dynamic>> tableData) {
//   return DataTable(
//     //decoration: Decoration(B),
//     columns: [
//       DataColumn(label: Text('Doctor')),
//       DataColumn(label: Text('RepName')),
//       DataColumn(label: Text('Distributor')),
//     ],
//     rows: tableData.map((row) {
//       return DataRow(cells: [
//         DataCell(Text(row["DoctorName"] ?? '')),
//         DataCell(Text(row["employee_name"] ?? '')),
//         DataCell(Text(row["customerName"] ?? '')),
//       ]);
//     }).toList(),
//   );
// }
//  Widget buildInvoiceTextFields(String label) {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Text(
//         label,
//         style: TextStyle(fontSize: 16,color: Colors.black),
//       ),
//       SizedBox(
//         height: 10,
//         width: 150,
//         child: TextField(
//           keyboardType: TextInputType.number,
//           decoration: InputDecoration(
//             border: OutlineInputBorder(),
//           ),
//         ),
//       ),
//     ],
//   );
// }