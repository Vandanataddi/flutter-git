import 'package:flutter/material.dart';
import 'AppColors.dart';
import 'Constants_data.dart';

class MenuItems extends StatelessWidget {
  final IconData icon;
  final String title;
  final Function onTap;

  const MenuItems({Key key, this.icon, this.title, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 10,bottom: 10,left: 16,right: 16),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              color: AppColors.white_color,
              size: Constants_data.getFontSize(context, 20),
            ),
            SizedBox(
              width: Constants_data.getFontSize(context, 15),
            ),
            Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: Constants_data.getFontSize(context, 14),
                  color: AppColors.white_color),
            )
          ],
        ),
      ),
    );
  }
}
