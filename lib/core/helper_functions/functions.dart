import 'package:flutter/material.dart';

import '../../features/auth/presentation/views/sign_in_view.dart';
import '../utils/app_colors/app_colors.dart';

class Functions {

  Future<void> showCustomSnackBar(BuildContext context,
      String message, {
        bool isError = false,
      }) async {const int snackBarDuration = 1000;

  // Show SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(milliseconds: snackBarDuration),
      ),
    );

    // ⏳ انتظر انتهاء الـ SnackBar لمدة 3 ثواني (مدته)
    await Future.delayed(const Duration(milliseconds: snackBarDuration));
  }


void showLoginPrompt(
    { required BuildContext context, required String content}) {
  showDialog(
    context: context,
    builder: (_) =>
        AlertDialog(
          backgroundColor: Colors.white,

          title: Text('تسجيل الدخول مطلوب'),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(AppColors.mainColor),),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => SignInView()),
                );
              },
              child: Text(
                'تسجيل الدخول', style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
  );
}


}
