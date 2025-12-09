import 'package:flutter/material.dart';
import '../utils/app_colors/app_colors.dart';

class CustomPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;

  const CustomPhoneField({
    super.key,
    required this.controller,
    this.focusNode,
    this.hintText = 'رقم الهاتف',
  });

  String? _validator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'من فضلك أدخل رقم الهاتف';
    }

    final phone = value.trim();

    if (phone.startsWith('0')) return 'الرقم لا يجب أن يبدأ بصفر';
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) return 'الرقم يجب أن يحتوي على أرقام فقط';
    if (phone.length != 10) return 'رقم الهاتف يجب أن يكون 10 أرقام';

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isTablet = width > 600;

    // حساب قياسات مرنة
    final borderRadius = isTablet ? 20.0 : 16.0;
    final fontSize = isTablet ? 18.0 : 16.0;
    final horizontalPadding = width * 0.04;
    final verticalPadding = height * 0.02;
    final appliedFontSize = fontSize ?? (isTablet ? 16.0 : 14.0); // إذا محددش fontSize استخدم الافتراضي

    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextFormField(
        focusNode: focusNode,
        controller: controller,
        keyboardType: TextInputType.phone,
        validator: _validator,        style: TextStyle(fontSize: appliedFontSize), // ← هنا الخط داخل الـ field

        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🇪🇬', style: TextStyle(fontSize: fontSize)),
                SizedBox(width: width * 0.015),
                Text(
                  '+20',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: width * 0.02),
                Container(height: 25, width: 1, color: Colors.grey[300]),
                SizedBox(width: width * 0.02),
              ],
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: fontSize),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: Color(0xffE6E9EA), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: AppColors.mainColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
      ),
    );
  }
}
