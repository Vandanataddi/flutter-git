import 'package:flutter/material.dart';

class DataTableScreen1 extends StatelessWidget {
  final Map<String, dynamic> templateJson;
  final List<Map<String, dynamic>> listData;

  DataTableScreen1({
    @required this.templateJson,
    @required this.listData,
  });

  @override
  Widget build(BuildContext context) {
    // Extract columns from templateJson
    List<String> columns = (templateJson['ColumnList'] as String)
        .split(',')
        .map((e) => e.trim())
        .toList();

    // Build the DataTable
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Table'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Card(
            elevation: 5,
            child: DataTable(
              columns: columns.map((col) => DataColumn(label: Text(col))).toList(),
              rows: listData.map((row) {
                return DataRow(
                  cells: columns.map((col) {
                    return DataCell(Text(row[col]?.toString() ?? ''));
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}