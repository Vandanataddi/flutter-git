

import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Constants/Constants_data.dart';
import '../Theme/DarkThemeProvider.dart';

class FGOInvoiceScreen extends StatefulWidget {
  @override
  _FGOInvoiceScreenState createState() => _FGOInvoiceScreenState();
}

class _FGOInvoiceScreenState extends State<FGOInvoiceScreen> {
  DarkThemeProvider themeChange;
  ThemeData themeData;
  String accountType;
  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> cardData = [];


  @override
  Widget build(BuildContext context) {
    Constants_data.currentScreenContext = context;
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    Map<String, dynamic> arg = ModalRoute.of(context).settings.arguments;
    accountType = arg["account_type"];
    String title = arg["menu_title"];

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
                'FGO Request',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              FutureBuilder<Map<String, dynamic>>(
                future: fetchTableData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                    return Text('No data found');
                  } else {
                    final tableData = snapshot.data['tableData'];
                    final cardData = snapshot.data['cardData'];
                    return Column(
                      children: [
                        Container(
                            padding: const EdgeInsets.all(16.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child:buildTable(tableData) ,
                            ) ),
                        //buildTable(tableData),
                        SizedBox(height: 10),
                        // Text(
                        //   'Cards:',
                        //   style: TextStyle(
                        //       fontSize: 20, fontWeight: FontWeight.bold),
                        // ),
                        // SizedBox(height: 10),
                        //  ...buildCards(cardData),
                      ],
                    );
                  }
                },
              ),
              SizedBox(height: 20),
              Text(
                'Please Upload invoice so that we can further proceed for credit note generation.',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // pickFileAndUploadData();
                },
                style: ElevatedButton.styleFrom(
                    elevation: 12.0,
                    textStyle: const TextStyle(color: Colors.white)),
                child: const Text('Upload'),
                // child: Text(_buttonLabel),
              ),
              // ElevatedButton(
              //  // onPressed: _pickFile,
              //   child: Text('Upload Invoice'),
              // ),
              SizedBox(height: 10),
              // _selectedFile != null
              //     ? Text('Selected file: ${_selectedFile.path}')
              //     : Container(),
              SizedBox(height: 10),
              buildInvoiceTextField('Invoice No'),
              SizedBox(height: 10),
              buildInvoiceTextField('Invoice Date'),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> fetchTableData() async {
    String url =
        'http://122.170.7.252/MicroDishaWebApiPublish/api/Mail/GetInsightDetails?docNo=148';
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
        List<dynamic> returnedTables = jsonResponse['dt_ReturnedTables'][0];

        for (var row in returnedTables) {
          tableData.add({
            "DoctorName": row["DoctorName"],
            "employee_name": row["employee_name"],
            "customerName": row["customerName"]
          });

          cardData.add({
            "item_desc": row["item_desc"],
            "product_code": row["product_code"],
            "doctor_code": row["doctor_code"],
            "rep_code": row["rep_code"],
            "supply_through": row["supply_through"],
            "scheme_type": row["scheme_type"],
            "discount_on": row["discount_on"],
            "discount_value": row["discount_value"],
            "quantity": row["quantity"],
            "fgo_value": row["fgo_value"]
          });
        }

        return {
          "tableData": tableData,
          "cardData": cardData,
        };
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  Widget buildTable2(List<Map<String, dynamic>> tableData) {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 600,
      columns: [
        DataColumn2(label: Text('Doctor'), size: ColumnSize.L),
        DataColumn2(label: Text('RepName'), size: ColumnSize.M),
        DataColumn2(label: Text('Distributor'), size: ColumnSize.M),
      ],
      rows: tableData.map((row) {
        return DataRow(cells: [
          DataCell(Text(row["DoctorName"] ?? '')),
          DataCell(Text(row["employee_name"] ?? '')),
          DataCell(Text(row["customerName"] ?? '')),
        ]);
      }).toList(),
    );
  }
  Widget buildTable(List<Map<String, dynamic>> tableData) {
    return DataTable(
      //decoration: Decoration(B),
      columns: [
        DataColumn(label: Text('Doctor')),
        DataColumn(label: Text('RepName')),
        DataColumn(label: Text('Distributor')),
      ],
      rows: tableData.map((row) {
        return DataRow(cells: [
          DataCell(Text(row["DoctorName"] ?? '')),
          DataCell(Text(row["employee_name"] ?? '')),
          DataCell(Text(row["customerName"] ?? '')),
        ]);
      }).toList(),
    );
  }
  List<Widget> buildCards(List<Map<String, dynamic>> cardData) {
    return cardData.map((card) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Item Description: ${card['item_desc']}"),
              Text("Product Code: ${card['product_code']}"),
              Text("Doctor Code: ${card['doctor_code']}"),
              Text("Rep Code: ${card['rep_code']}"),
              Text("Supply Through: ${card['supply_through']}"),
              Text("Scheme Type: ${card['scheme_type']}"),
              Text("Discount On: ${card['discount_on']}"),
              Text("Discount Value: ${card['discount_value']}"),
              Text("Quantity: ${card['quantity']}"),
              Text("FGO Value: ${card['fgo_value']}"),
            ],
          ),
        ),
      );
    }).toList();
  }
  Widget buildInvoiceTextField(String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(
          height: 10,
          width: 150,
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

}