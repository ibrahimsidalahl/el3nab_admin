import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_colors/app_colors.dart';

class CustomTextButton extends StatelessWidget {

  final String title;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isLoading;


  const CustomTextButton({super.key, required this.title, required this.onPressed, this.color,    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      width:double.maxFinite,
      decoration: BoxDecoration(
        boxShadow: [
      BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
    ],
        color: color ?? AppColors.mainColor,
        borderRadius: BorderRadiusGeometry.all(

            Radius.circular(10)),
      ),
      child:  isLoading
          ? Center(child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 4,
          // year2023: true,
          color: Colors.white,
        ),
      ),)
          :TextButton(
        onPressed: onPressed,
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith( fontWeight: FontWeight.bold,
            color: Colors.white,)
        ),
      ),
    );
  }
}
