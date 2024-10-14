// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// // class TableWidget2 extends StatelessWidget {
// //   final Map<String, dynamic> templateJson;
// //   final List<Map<String, dynamic>> listData;
// //
// //   TableWidget2({@required this.templateJson, @required this.listData});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     List<String> columns = templateJson['ColumnList'].split(',').map((e) => e.trim()).toList();
// //
// //     return DataTable(
// //       columns: columns.map((col) => DataColumn(label: Text(col))).toList(),
// //       rows: listData.map((row) {
// //         return DataRow(
// //           cells: columns.map((col) {
// //             return DataCell(Text(row[col]?.toString() ?? ''));
// //           }).toList(),
// //         );
// //       }).toList(),
// //     );
// //   }
// // }
// // class TableWidget2 extends StatelessWidget {
// //   final Map<String, dynamic> templateJson;
// //   //final List<Map<String, dynamic>> listData;
// //   List<dynamic> listData;
// //   // Use named parameters and required keyword for non-nullable types
// //   TableWidget2({
// //     @required this.templateJson,
// //     @required this.listData,
// //   });
//
//
// // class TableWidget2 extends StatelessWidget {
// //   final Map<String, dynamic> templateJson;
// //   final List<Map<String, dynamic>> listData;
// //
// //   // Constructor
// //   TableWidget2({
// //     @required this.templateJson, // Ensure you use `required` with named parameters
// //     @required this.listData, // Ensure you use `required` with named parameters
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     print("Template JSON: $templateJson");
// //     print("List Data: $listData");
// //
// //     // Extract columns from templateJson
// //     List<String> columns = (templateJson['ColumnList'] as String)
// //         .split(',')
// //         .map((e) => e.trim())
// //         .toList();
// //
// //     // Build the DataTable
// //     return DataTable(
// //       columns: columns.map((col) => DataColumn(label: Text(col))).toList(),
// //       rows: listData.map((row) {
// //         return DataRow(
// //           cells: columns.map((col) {
// //             return DataCell(Text(row[col]?.toString() ?? ''));
// //           }).toList(),
// //         );
// //       }).toList(),
// //     );
// //   }
// // }

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class DataTableScreen1 extends StatelessWidget {
  final Map<String, dynamic> templateJson;
  final List<Map<String, dynamic>> listData;

  DataTableScreen1({
    @required this.templateJson,
    @required this.listData,
  });

  // @override
  // Widget build(BuildContext context) {
  //   // Extract columns from templateJson
  //   List<String> columns = (templateJson['ColumnList'] as String)
  //       .split(',')
  //       .map((e) => e.trim())
  //       .toList();
  //
  //   // Build the DataTable
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Data Table'),
  //     ),
  //     body: SingleChildScrollView(
  //       scrollDirection: Axis.horizontal,
  //       child: Container(
  //         padding: EdgeInsets.all(16.0),
  //         child: Card(
  //           elevation: 5,
  //           child: DataTable(
  //             columnSpacing: 16.0,  // Adjust spacing between columns if needed
  //             headingRowHeight: 56.0,  // Adjust height for header row if needed
  //             dataRowHeight: 56.0,  // Adjust height for data rows if needed
  //             columns: columns.map((col) => DataColumn(label: Text(col))).toList(),
  //             rows: listData.map((row) {
  //               return DataRow(
  //                 cells: columns.map((col) {
  //                   return DataCell(Text(row[col]?.toString() ?? ''));
  //                 }).toList(),
  //               );
  //             }).toList(),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  // @override
  // Widget build(BuildContext context) {
  //   // Extract columns from templateJson
  //   List<String> columns = (templateJson['ColumnList'] as String)
  //       .split(',')
  //       .map((e) => e.trim())
  //       .toList();
  //
  //   // Define header color
  //   final Color headerColor = Colors.grey.shade200;
  //
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Data Table'),
  //     ),
  //     body: SingleChildScrollView(
  //       scrollDirection: Axis.horizontal,
  //       child: Stack(
  //         children: [
  //           // Freeze the first column
  //           Positioned(
  //             left: 0,
  //             top: 0,
  //             bottom: 0,
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 border: Border.all(color: Colors.grey), // Add border here
  //               ),
  //               child: DataTable(
  //                 columnSpacing: 16.0,
  //                 headingRowHeight: 56.0,
  //                 dataRowHeight: 56.0,
  //                 headingRowColor: MaterialStateProperty.all(headerColor),
  //                 columns: [
  //                   DataColumn(
  //                     label: Container(
  //                       width: 50.0, // Set width for the first column
  //                       child: Text(columns[0]),
  //                     ),
  //                   ),
  //                 ],
  //                 rows: listData.map((row) {
  //                   return DataRow(
  //                     cells: [
  //                       DataCell(
  //                         Container(
  //                           width: 50.0, // Set width for the first column
  //                           child: Text(row[columns[0]]?.toString() ?? ''),
  //                         ),
  //                       ),
  //                     ],
  //                   );
  //                 }).toList(),
  //               ),
  //             ),
  //           ),
  //           // Scrollable data for the remaining columns
  //           SingleChildScrollView(
  //             scrollDirection: Axis.horizontal,
  //             child: Container(
  //               padding: EdgeInsets.only(left: 50.0),
  //               // Adjust for frozen column width
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   border: Border.all(color: Colors.grey), // Add border here
  //                 ),
  //                 child: DataTable(
  //                   columnSpacing: 16.0,
  //                   headingRowHeight: 56.0,
  //                   dataRowHeight: 56.0,
  //                   headingRowColor: MaterialStateProperty.all(headerColor),
  //                   columns: columns
  //                       .skip(1)
  //                       .map((col) =>
  //                       DataColumn(
  //                         label: Container(
  //                           width: 50.0, // Set a fixed width for other columns
  //                           child: Text(col),
  //                         ),
  //                       ))
  //                       .toList(),
  //                   rows: listData.map((row) {
  //                     return DataRow(
  //                       cells: columns.skip(1).map((col) {
  //                         return DataCell(
  //                           Container(
  //                             width: 50.0, // Set a fixed width for other columns
  //                             child: Text(row[col]?.toString() ?? ''),
  //                           ),
  //                         );
  //                       }).toList(),
  //                     );
  //                   }).toList(),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    // Extract columns from templateJson
    List<String> columns = (templateJson['ColumnList'] as String)
        .split(',')
        .map((e) => e.trim())
        .toList();

    // Define header color
    final Color headerColor = Colors.blue[300];

    return Scaffold(
      appBar: AppBar(
        title: Text('Data Table'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(

          columnSpacing: 10.0,
          headingRowHeight: 56.0,
          dataRowHeight: 56.0,
          headingRowColor: MaterialStateProperty.all(headerColor),
          columns: columns
              .map((col) => DataColumn(
            label: Container(
              width: 45.0, // Set a fixed width for columns
              child: Text(col,
                // overflow: TextOverflow.ellipsis,
                // maxLines: 1,
              ),
            ),
          ))
              .toList(),
          rows: listData.map((row) {
            return DataRow(
              cells: columns.map((col) {
                return DataCell(
                  Container(
                    width: 45.0, // Set a fixed width for cells
                    child: Text(row[col]?.toString() ?? ''),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
  // Widget build(BuildContext context) {
  //   // Extract columns from templateJson
  //   List<String> columns = (templateJson['ColumnList'] as String)
  //       .split(',')
  //       .map((e) => e.trim())
  //       .toList();
  //
  //   // Define header color
  //   final Color headerColor = Colors.blue[300];
  //
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Data Table'),
  //     ),
  //     body: SingleChildScrollView(
  //       scrollDirection: Axis.horizontal,
  //       child: DataTable2(
  //         columnSpacing: 12.0,
  //         horizontalMargin: 12.0,
  //         minWidth: 600.0, // Adjust this based on your content
  //         headingRowColor: MaterialStateProperty.all(headerColor),
  //         headingRowHeight: 56.0,
  //         dataRowHeight: 56.0,
  //         columns: columns
  //             .map((col) => DataColumn2(
  //           label: Container(
  //             width: 100.0, // Adjust the width as needed
  //             child: Text(
  //               col,
  //               overflow: TextOverflow.ellipsis,
  //               maxLines: 1,
  //             ),
  //           ),
  //           size: ColumnSize.L, // Adjust column size as needed
  //         ))
  //             .toList(),
  //         rows: listData.map((row) {
  //           return DataRow(
  //             cells: columns.map((col) {
  //               return DataCell(
  //                 Container(
  //                   width: 100.0, // Adjust the width as needed
  //                   child: Text(row[col]?.toString() ?? ''),
  //                 ),
  //               );
  //             }).toList(),
  //           );
  //         }).toList(),
  //       ),
  //     ),
  //   );
  // }
}


