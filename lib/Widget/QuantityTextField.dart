import 'package:flutter/material.dart';

// class QuantityTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final Function onQuantityChanged;
//
//   QuantityTextField({@required this.controller, @required this.onQuantityChanged});
//
//   @override
  // Widget build(BuildContext context) {
  //   return SizedBox(
  //     height: 24,
  //     width: 100,
  //     child: TextField(
  //       controller: controller,
  //       keyboardType: TextInputType.number,
  //       textAlign: TextAlign.start,
  //       decoration: InputDecoration(
  //         border: OutlineInputBorder(),
  //         contentPadding: EdgeInsets.symmetric(vertical: 8),
  //       ),
  //       onChanged: (value) {
  //         final newValue = double.tryParse(value) ?? 0;
  //         if (newValue >= 0) {
  //           controller.text = newValue.toString();
  //           controller.selection = TextSelection.fromPosition(
  //             TextPosition(offset: controller.text.length),
  //           );
  //           onQuantityChanged(); // Notify the parent widget of changes
  //         } else {
  //           controller.text = '0';
  //           onQuantityChanged(); // Notify the parent widget of changes
  //         }
  //       },
  //     ),
  //   );
  // }
  class QuantityTextField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onEditingComplete;

  QuantityTextField({
  @required this.controller,
  this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
  return TextField(
  controller: controller,
  decoration: InputDecoration(
  border: OutlineInputBorder(),
  labelText: 'Quantity',
  ),
  keyboardType: TextInputType.number,
  onEditingComplete: () {
  if (onEditingComplete != null) {
  onEditingComplete();
  }
  },
  );
  }
  }



