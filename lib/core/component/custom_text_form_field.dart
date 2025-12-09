import 'package:flutter/material.dart';
import '../utils/app_colors/app_colors.dart';

class CustomTextFormField extends StatefulWidget {
  final String? title;
  final TextInputType? keyboardType;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isPasswordField;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const CustomTextFormField({
    super.key,
    required this.title,
    required this.validator,
    required this.controller,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.isPasswordField = false,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isTablet = width > 600;
    final fontSize = isTablet ? 18.0 : 16.0;

    final appliedFontSize = fontSize ?? (isTablet ? 16.0 : 14.0); // إذا محددش fontSize استخدم الافتراضي

    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,        style: TextStyle(fontSize: appliedFontSize), // ← هنا الخط داخل الـ field

      keyboardType: widget.keyboardType,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      obscureText: widget.isPasswordField ? obscure : false,
      cursorColor: AppColors.mainColor,
      decoration: InputDecoration(
        hintText: widget.title,
        hintStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: isTablet ? 18 : 14,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: EdgeInsets.symmetric(
          vertical: height * 0.02,
          horizontal: width * 0.04,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          borderSide: const BorderSide(color: Color(0xffE6E9EA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          borderSide: const BorderSide(
            width: 1.5,
            color: AppColors.mainColor,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          borderSide: const BorderSide(
            width: 1.5,
            color: Colors.red,
          ),
        ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.isPasswordField
            ? IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.remove_red_eye_outlined,
          ),
          onPressed: () {
            setState(() {
              obscure = !obscure;
            });
          },
        )
            : widget.suffixIcon,
      ),
    );
  }
}
