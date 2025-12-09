import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dio/dio.dart';
import 'package:el3nab_admin/features/home/presentation/views/home_screen.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/storage/app_secure_storage.dart';
import '../../../../core/utils/app_colors/app_colors.dart';
import '../../../../core/utils/constants/app_constants.dart';
import '../../../auth/presentation/views/sign_in_view.dart';
import '../../../profile/data/repos/user_repo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _showSlogan = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceOut),
    );


    /// Delay navigation
    _delayNavigation();
    // Future.delayed(const Duration(seconds: 5), () {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (_) => SignInView()),
    //   );
    // });
    /// Show slogan after title finishes typing (≈3s)
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showSlogan = true;
      });
    });
  }
  Future<void> _delayNavigation() async {
    _controller.forward();

    // Add timeout and error handling for iOS secure storage
    String? token;
    try {
      token = await AppPreferences.getAccessToken().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          print('⚠️ Secure storage timeout - proceeding without token');
          return null;
        },
      );
    } catch (e) {
      print('❌ Error getting token: $e');
      token = null;
    }

    // Wait for animations to complete
    await Future.delayed(const Duration(seconds: 5));

    // Navigate safely with mounted check
    if (mounted) {


      if (token == null) {
        // No token - go to sign in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SignInView()),
        );
      } else {
        // Token exists - check if phone is verified

          Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(),));
        }
      }

  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            /// background watermark
            Opacity(
              opacity: 0.2,
              child: Image.asset(
                AppConstants.splashBackground,
                fit: BoxFit.cover,
              ),
            ),

            /// center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Logo with slide animation
                  SlideTransition(
                    position: _slideAnimation,
                    child: Image.asset(
                      AppConstants.appLogo,
                      height: 250,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Title with typing effect
                  SizedBox(
                    height: 50,
                    child: AnimatedTextKit(
                      totalRepeatCount: 1,
                      animatedTexts: [
                        TyperAnimatedText(
                          "الرجل العناب",
                          textStyle: GoogleFonts.cairo(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mainColor,
                          ),
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                    ),
                  ),


                  /// Slogan appears with fade AFTER title
                  AnimatedOpacity(
                    opacity: _showSlogan ? 1.0 : 0.0,
                    duration: const Duration(seconds: 1),
                    child: Text(
                      "هيوصلك لحد الباب",
                      style: GoogleFonts.cairo(
                        fontSize: 30,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
