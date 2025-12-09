// import 'package:el3nab_admin/features/profile/presentation/widgets/profile_view_body.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../../core/utils/constants/app_constants.dart';
// import '../cubit/get_current_user_cubit.dart';
//
// class ProfileView extends StatelessWidget {
//   static const routeName = "profileView";
//
//   const ProfileView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size; // حجم الشاشة
//     final height = size.height;
//     final width = size.width;
//     return BlocProvider(
//       create: (_) => GetCurrentUserCubit(),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           title: Text(
//             "الملف الشخصي",
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: width * 0.055, // حجم الخط حسب العرض
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           centerTitle: false,
//           actions: [
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: width * 0.04),
//               child: CircleAvatar(
//                 radius: width * 0.06,
//                 backgroundColor: Colors.white,
//                 child: Image.asset(AppConstants.appLogo, width: width * 0.1),
//               ),
//             ),
//           ],
//         ),
//         body: SafeArea(child: ProfileViewBody()),
//       ),
//     );
//   }
// }
