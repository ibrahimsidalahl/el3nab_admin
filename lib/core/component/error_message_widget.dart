import 'package:el3nab_admin/core/utils/app_colors/app_colors.dart';
import 'package:flutter/material.dart';

Widget ErrorMessageWidget({required String message}
    ){
  return  Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: AppColors.accentColor, size: 60),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}