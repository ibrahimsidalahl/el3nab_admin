
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget NoInternetWidget(){
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 70.h,
          width: 70.w,
          child: Image.asset(
            'assets/icons/no_internet.png',
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'لا يوجد اتصال بالإنترنت تأكد من الشبكة.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12.h),
      ],
    ),
  );
}