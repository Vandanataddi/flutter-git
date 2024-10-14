import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget getAvatarTextWidget(bool condition, String text) {
  if (condition)
    return SizedBox.shrink();
  else
    return ClipRRect(
      borderRadius: BorderRadius.circular(55),
      child: Container(
        child: Text(
          text,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
}
