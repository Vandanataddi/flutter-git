import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// class TableWidget1 extends StatefulWidget {
//   TableWidget1( {@required this.templateJson, @required this.details});
//
//   Map<String, dynamic> templateJson;
//   List<dynamic> details;
//
//   @override
//   _ScreenState createState() => _ScreenState(templateJson: templateJson, listData: details);
// }
//
// class _ScreenState extends State<TableWidget1> {
//   _ScreenState({@required this.templateJson, @required this.listData});
//   Map<String, dynamic> templateJson;
//   List<dynamic> listData;
//
//
//   @override
//   Widget build(BuildContext context) {
//
//   }
//   }


// class TableWidget1 extends StatelessWidget {
//   final Map<String, dynamic> templateJson;
//   final List<Map<String, dynamic>> details;
//
//   TableWidget1({@required this.templateJson, @required this.details});
//
//   @override
//   Widget build(BuildContext context) {
//     return DataTable(
//       columns: [
//         DataColumn(label: Text('Request No')),
//         DataColumn(label: Text('Doctor Code')),
//         DataColumn(label: Text('Doctor Name')),
//         DataColumn(label: Text('Speciality')),
//       ],
//       rows: details.map((data) {
//         return DataRow(cells: [
//           DataCell(Text(data['RequestNo'] ?? '')),
//           DataCell(Text(data['doctor_code'] ?? '')),
//           DataCell(Text(data['DoctorName'] ?? '')),
//           DataCell(Text(data['SPECIALITY'] ?? '')),
//         ]);
//       }).toList(),
//     );
//   }
// }



class TableWidget1 extends StatelessWidget {
  final Map<String, dynamic> templateJson;
  final List<Map<String, dynamic>> details;

  TableWidget1({@required this.templateJson, @required this.details});

  @override
  Widget build(BuildContext context) {
    // Define your columns based on templateJson or hardcode them
    List<DataColumn> columns = <DataColumn>[
      DataColumn(label: Text('Column 1')),
      DataColumn(label: Text('Column 2')),
      DataColumn(label: Text('Column 3')),
      // Add more columns as needed
    ];

    // Ensure each row has the same number of cells as the number of columns
    List<DataRow> rows = details.map((data) {
      return DataRow(cells: <DataCell>[
        DataCell(Text(data['column1'] ?? '')), // Ensure the key exists in data
        DataCell(Text(data['column2'] ?? '')),
        DataCell(Text(data['column3'] ?? '')),
        // Add more cells as needed
      ]);
    }).toList();

    return DataTable(
      columns: columns,
      rows: rows,
    );
  }
}
