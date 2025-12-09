import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors/app_colors.dart';
import '../../../../core/utils/constants/app_constants.dart';

class RegistrationHeader extends StatelessWidget {
  const RegistrationHeader({
    super.key, required this.title,
    this.logo = AppConstants.appLogo,
  });

  final String title ;
  final String logo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          maxRadius: 60.r,
          backgroundColor: Colors.white,
          child: Image.asset(logo),
        ),

        SizedBox(height: 20.h),

        Text(
          title,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.mainColor,
          ),
        ),
      ],
    );
  }
}