import 'package:el3nab_admin/core/utils/app_colors/app_colors.dart';
import 'package:el3nab_admin/features/auth/presentation/widgets/registration_header_section.dart';
import 'package:el3nab_admin/features/home/presentation/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/helper_functions/functions.dart';
import '../../../../core/storage/app_secure_storage.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_states.dart';

import '../../../../core/component/custom_phone_field.dart';
import '../../../../core/component/custom_text_button.dart';
import '../../../../core/component/custom_text_form_field.dart';

class SignInViewBody extends StatefulWidget {
  const SignInViewBody({super.key});

  @override
  State<SignInViewBody> createState() => _SignInViewBodyState();
}

class _SignInViewBodyState extends State<SignInViewBody> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late TextEditingController phoneNumberController;
  late TextEditingController passwordController;

  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    phoneNumberController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    passwordController.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isTablet = width > 600;
    double verticalSpacing(double fraction) => height * fraction;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) async {
        if (state is AuthSignInSuccess) {
          await Functions().showCustomSnackBar(context, "تم تسجيل الدخول بنجاح ✅");

          phoneNumberController.clear();
          passwordController.clear();
Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(),));
        } else if (state is AuthError) {
          Functions().showCustomSnackBar(
            context,
            state.message,
            isError: true,
          );
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return Form(
            key: formKey,
            child: Padding(
              padding: EdgeInsets.all(width * 0.05),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: verticalSpacing(0.14)),
                    RegistrationHeader(title: 'الدخول إلى الإدارة'),
                    SizedBox(height: verticalSpacing(0.033)),

                    CustomPhoneField(
                      focusNode: _phoneFocus,
                      controller: phoneNumberController,
                    ),

                    SizedBox(height: verticalSpacing(0.02)),

                    CustomTextFormField(
                      prefixIcon: Icon(Icons.password, color: Colors.grey[500]),
                      focusNode: _passwordFocus,
                      title: 'كلمة المرور',
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      isPasswordField: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال كلمة المرور';
                        }
                        return null;
                      },
                    ),


                    SizedBox(height: verticalSpacing(0.033)),

                    CustomTextButton(
                      isLoading: state is AuthLoading,
                      title: 'الدخول',
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        final valid = formKey.currentState!.validate();
                        if (valid) {
                          context.read<AuthCubit>().signIn(
                            phone: int.parse(phoneNumberController.text.trim()),
                            password: passwordController.text.trim(),
                          );
                        }
                      },
                    ),

                    SizedBox(height: verticalSpacing(0.033)),




                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
