import 'package:el3nab_admin/core/utils/constants/app_constants.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/storage/app_secure_storage.dart';
import 'core/utils/app_colors/app_colors.dart';
import 'core/utils/snackbar.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

import 'features/splash/presentation/views/splash_screen.dart';
import 'generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }



   


  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MultiBlocProvider(
          providers: [
            // Global cubits that need to be accessible throughout the entire app
            BlocProvider(create: (_) => AuthCubit()), // Used in multiple places (drawer, profile, auth screens)

          ],
          child: MaterialApp(
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar', 'AR')],
            title: AppConstants.appTitle,
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Cairo-Regular',
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.mainColor),
              textTheme: TextTheme(
                displaySmall: GoogleFonts.cairo(fontSize: 32),
                headlineSmall: GoogleFonts.cairo(fontSize: 20),
                titleLarge: GoogleFonts.cairo(fontSize: 18),
                titleMedium: GoogleFonts.cairo(fontSize: 16),
                titleSmall: GoogleFonts.cairo(fontSize: 14),
                bodyLarge: GoogleFonts.cairo(fontSize: 14),
                bodySmall: GoogleFonts.cairo(fontSize: 12),
              ),
            ),
            localizationsDelegates:  [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: rootScaffoldMessengerKey,

            home: SplashScreen(),
          ),
        );
      },
    );
  }
}