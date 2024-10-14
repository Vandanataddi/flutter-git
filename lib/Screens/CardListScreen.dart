import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// class CardListScreen extends StatelessWidget {
//   final List<Map<String, dynamic>> listData;
//
//   CardListScreen({@required this.listData});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Data Details'),
//       ),
//       body: ListView.builder(
//         itemCount: listData.length,
//         itemBuilder: (context, index) {
//           final data = listData[index];
//           return Container(
//             width: 400,
//             //height: 400,
//             child: Card(
//               elevation: 3,
//               margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//               color: Colors.white,
//               child: Padding(
//                 padding: EdgeInsets.all(10.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       data['item_desc'] ?? 'No Description',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blue,
//                       ),
//                     ),
//                     Divider(thickness: 2),
//                     SizedBox(height: 5), // Space after title
//                     _buildRow("Doc No", data['doc_no']),
//                     _buildRow("Scheme Type", data['scheme_type']),
//                     _buildRow("Quantity", data['quantity']),
//                     _buildRow("Discount On", data['discount_on']),
//                     _buildRow("Discount Value", data['discount_value']),
//                     _buildRow("Approved", data['is_approved']),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildRow(String label, dynamic value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 1.0),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//           Text(
//             ":",
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//             ),
//           ),
//           SizedBox(width: 10,),
//           Expanded(
//             flex: 4,
//             child: Text(
//               value != null ? value.toString() : '',
//              textAlign: TextAlign.left,
//               style: TextStyle(
//                 fontWeight: FontWeight.normal,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class CardListScreen extends StatefulWidget {
  final List<Map<String, dynamic>> listData;

  CardListScreen({@required this.listData});

  @override
  _CardListScreenState createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Details'),
      ),
      body: ListView.builder(
        itemCount: widget.listData.length,
        itemBuilder: (context, index) {
          final data = widget.listData[index];
          return Container(
            width: MediaQuery.of(context).size.width, // Use full width of the screen
          //  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            padding: EdgeInsets.all(0),
            child: Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                // child: Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     Text(
                //       data['item_desc'] ?? 'No Description',
                //       style: TextStyle(
                //         fontSize: 16,
                //         fontWeight: FontWeight.bold,
                //         color: Colors.blue,
                //       ),
                //     ),
                //     Divider(thickness: 2),
                //     SizedBox(height: 5), // Space after title
                //     _buildRow("Doc No", data['doc_no']),
                //     _buildRow("Scheme Type", data['scheme_type']),
                //     _buildRow("Quantity", data['quantity']),
                //     _buildRow("Discount On", data['discount_on']),
                //     _buildRow("Discount Value", data['discount_value']),
                //     _buildRow("Approved", data['is_approved']),
                //     _buildRow("FGO Value", data['fgo_value']),
                //   ],
                // ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['item_desc'] ?? 'No Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Divider(thickness: 2),
                    SizedBox(height: 5), // Space after title
                    _buildRow("Request No", data['doc_no']),
                    _buildRow("Scheme Type", data['scheme_type']),

                    // Display common fields
                    _buildRow("Quantity", data['quantity']),
                    // Conditionally render based on scheme type
                    if (data['scheme_type'] == 'Extra Scheme' ||
                        data['scheme_type'] == 'Free Goods') ...[
                      _buildRow("Discount On", data['discount_on']),
                      _buildRow("Discount Value", data['discount_value']),
                    ],
                    if (data['scheme_type'] == 'Rate Difference') ...[
                      _buildRow("Discount Value", data['discount_value']),
                      // If you want to skip "Discount On" for Rate Difference, you don't include it here
                    ],
                    if (data['scheme_type'] == 'Free Goods') ...[
                     // _buildRow("Inclusive/Exclusive", data['inclusive_exclusive']),
                      //_buildRow("Total Goods", data['total_goods']),
                    ],
                    _buildRow("FGO Value", data['fgo_value']),
                    _buildRow("Status", data['is_approved']== 'Y' ? 'Approved' : 'Not Approved'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            ":",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: Text(
              value != null ? value.toString() : '',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


