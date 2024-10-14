
import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/const.dart';
import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
        ),
      ),
      color: AppColors.white_color.withOpacity(0.8),
    );
  }
}
