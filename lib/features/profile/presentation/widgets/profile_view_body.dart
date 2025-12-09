// import 'dart:io';
//
// import 'package:elragol_el3nab/features/adresses/presentation/views/address_view.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:url_launcher/url_launcher_string.dart';
//
// import '../../../../core/utils/app_colors/app_colors.dart';
// import '../../../../core/utils/constants/app_constants.dart';
// import '../../../../core/widgets/shimmer_widget.dart';
// import '../../../../core/component/no_internet_widget.dart';
// import '../../../../core/component/error_message_widget.dart';
// import '../../../auth/presentation/cubit/auth_cubit.dart';
// import '../../../auth/presentation/cubit/auth_states.dart';
// import '../../../auth/presentation/views/sign_in_view.dart';
// import '../cubit/get_current_user_cubit.dart';
// import '../cubit/get_current_user_states.dart';
//
// class ProfileViewBody extends StatefulWidget {
//   const ProfileViewBody({super.key});
//
//   @override
//   State<ProfileViewBody> createState() => _ProfileViewBodyState();
// }
//
// class _ProfileViewBodyState extends State<ProfileViewBody> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<GetCurrentUserCubit>().getCurrentUser();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final width = size.width;
//     final height = size.height;
//     final isTablet = width > 600;
//
//     double textScale(double s) => s * (width / 400);
//
//     return Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: width * 0.05,
//         vertical: height * 0.02,
//       ),
//       child: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: Column(
//           children: [
//             // ======================= Header =======================
//             BlocBuilder<GetCurrentUserCubit, GetCurrentUserState>(
//               builder: (context, state) {
//                 if (state is UserLoading) {
//                   return _buildLoadingHeader(width, height);
//                 }
//                 if (state is UserLoaded) {
//                   final u = state.user;
//                   return Column(
//                     children: [
//                       CircleAvatar(
//                         radius: width * 0.13,
//                         backgroundColor: Colors.white,
//                         child: Container(
//                           width: width * 0.25,
//                           height: height * 0.12,
//                           decoration: const BoxDecoration(
//                             image: DecorationImage(
//                               fit: BoxFit.scaleDown,
//                               image: AssetImage('assets/images/playstore.png'),
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: height * 0.02),
//                       Text(
//                         u.name,
//                         style: TextStyle(
//                           fontSize: textScale(20),
//                           fontWeight: FontWeight.w700,
//                           color: AppColors.darkText,
//                         ),
//                       ),
//                       SizedBox(height: height * 0.01),
//                       Text(
//                         "20${u.phone}+",
//                         style: TextStyle(
//                           fontSize: textScale(14),
//                           color: Colors.grey[700],
//                         ),
//                       ),
//                       SizedBox(height: height * 0.005),
//                       Text(
//                         u.email ?? "",
//                         style: TextStyle(
//                           fontSize: textScale(13),
//                           color: Colors.grey[700],
//                         ),
//                       ),
//                       SizedBox(height: height * 0.03),
//                     ],
//                   );
//                 }
//                 if (state is UserError) {
//                   if (state.message.contains("لا يوجد اتصال")) {
//                     return NoInternetWidget();
//                   }
//                   return ErrorMessageWidget(message: state.message);
//                 }
//                 return const SizedBox.shrink();
//               },
//             ),
//
//             // ======================= Menu =======================
//             _buildMenuItem(
//               width: width,
//               height: height,
//               textScale: textScale,
//               icon: Icons.location_on_outlined,
//               title: "عناوين التوصيل",
//               onTap: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const AddressView()),
//               ),
//             ),
//
//             _buildMenuItem(
//               width: width,
//               height: height,
//               textScale: textScale,
//               icon: Icons.group_add_outlined,
//               title: "دعوة الأصدقاء",
//               onTap: () {
//                 String message =
//                     'جميع مطاعمك وكافيهاتك المفضلة وسوبر ماركت سمنود في تطبيق واحد! حمّل ${AppConstants.appTitle} الآن واستمتع بالتوصيل السريع داخل سمنود🚀: ';
//
//                 if (Platform.isAndroid) {
//                   message += AppConstants.appPlayStoreLink;
//                 } else if (Platform.isIOS) {
//                   message += AppConstants.appStoreLink;
//                 }
//
//                 SharePlus.instance.share(ShareParams(text: message));
//               },
//             ),
//
//             _buildMenuItem(
//               width: width,
//               height: height,
//               textScale: textScale,
//               icon: Icons.support_agent_outlined,
//               title: "الدعم الفني",
//               onTap: () {
//                 _openWhatsApp(
//                   phone: '201220222754',
//                   message:
//                       'مرحباً، لدي استفسار بخصوص خدمة التوصيل في تطبيق الرجل العناب. هل يمكنكم مساعدتي؟',
//                 );
//               },
//             ),
//
//             // Logout
//             _buildMenuItem(
//               width: width,
//               height: height,
//               textScale: textScale,
//               icon: Icons.logout,
//               title: "تسجيل الخروج",
//               isLogout: true,
//               onTap: () {
//                 _showConfirmationDialog<AuthCubit, AuthState>(
//                   context: context,
//                   title: "تأكيد تسجيل الخروج",
//                   content: "هل تريد تسجيل الخروج الآن؟",
//                   confirmText: "تسجيل الخروج",
//                   confirmColor: Colors.red,
//                   width: width,
//                   height: height,
//                   cubit: context.read<AuthCubit>(),
//                   isLoadingChecker: (state) => state is LoggedOutLoading,
//                   onConfirm: () async {
//                     await context.read<AuthCubit>().logout();
//                     Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(builder: (_) => const SignInView()),
//                       (route) => false,
//                     );
//                   },
//                 );
//               },
//             ),
//
//             // Delete Account
//             _buildMenuItem(
//               width: width,
//               height: height,
//               textScale: textScale,
//               icon: Icons.delete_forever,
//               title: "حذف الحساب نهائياً",
//               isLogout: true,
//               onTap: () {
//                 _showConfirmationDialog<
//                   GetCurrentUserCubit,
//                   GetCurrentUserState
//                 >(
//                   context: context,
//                   title: "تأكيد حذف الحساب",
//                   content:
//                       "هل تريد حذف الحساب نهائيًا؟ جميع البيانات سيتم فقدانها.",
//                   confirmText: "حذف الحساب",
//                   confirmColor: Colors.red,
//                   width: width,
//                   height: height,
//
//                   cubit: context.read<GetCurrentUserCubit>(),
//                   isLoadingChecker: (state) => state is DeleteLoading,
//                   onConfirm: () async {
//                     await context.read<GetCurrentUserCubit>().deleteAccount();
//                     context.read<AuthCubit>().logout();
//                     Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(builder: (_) => const SignInView()),
//                       (route) => false,
//                     );
//                   },
//                 );
//               },
//             ),
//
//             SizedBox(height: height * 0.06),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ========================== عنصر القائمة ==========================
//   Widget _buildMenuItem({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//     required double width,
//     required double height,
//     required double Function(double) textScale,
//     bool isLogout = false,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: EdgeInsets.symmetric(vertical: height * 0.018),
//         child: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(width * 0.025),
//               decoration: BoxDecoration(
//                 color: AppColors.mainColor.withOpacity(0.12),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 icon,
//                 color: AppColors.mainColor,
//                 size: textScale(22),
//               ),
//             ),
//             SizedBox(width: width * 0.04),
//             Expanded(
//               child: Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: textScale(15),
//                   fontWeight: FontWeight.w600,
//                   color: isLogout ? Colors.red : AppColors.darkText,
//                 ),
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios,
//               size: textScale(16),
//               color: Colors.grey,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ========================== Loader ==========================
//   Widget _buildLoadingHeader(double width, double height) {
//     return Column(
//       children: [
//         BuildShimmer(
//           child: CircleAvatar(
//             radius: width * 0.14,
//             backgroundColor: Colors.white,
//           ),
//         ),
//         SizedBox(height: height * 0.01),
//         BuildShimmer(
//           child: Container(
//             height: height * 0.02,
//             width: width * 0.30,
//             color: Colors.white,
//           ),
//         ),
//         SizedBox(height: height * 0.01),
//         BuildShimmer(
//           child: Container(
//             height: height * 0.018,
//             width: width * 0.40,
//             color: Colors.white,
//           ),
//         ),
//         SizedBox(height: height * 0.005),
//         BuildShimmer(
//           child: Container(
//             height: height * 0.018,
//             width: width * 0.50,
//             color: Colors.white,
//           ),
//         ),
//         SizedBox(height: height * 0.02),
//       ],
//     );
//   }
// }
//
// // ========================== Dialog ==========================
// void _showConfirmationDialog<T extends Cubit<S>, S>({
//   required BuildContext context,
//   required String title,
//   required String content,
//   required String confirmText,
//   required Color confirmColor,
//   required T cubit,
//   required height,
//   required width,
//   required bool Function(S state) isLoadingChecker,
//   required Future<void> Function() onConfirm,
// }) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) {
//       return AlertDialog(
//         backgroundColor: AppColors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//         content: Text(content),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('إلغاء', style: TextStyle(color: Colors.black)),
//           ),
//           BlocBuilder<T, S>(
//             bloc: cubit,
//             builder: (context, state) {
//               bool isLoading = isLoadingChecker(state);
//               return SizedBox(
//                 height: height * 0.05,
//                 width: width * 0.35,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: confirmColor,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   onPressed: isLoading ? null : () async => await onConfirm(),
//                   child: isLoading
//                       ? SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 4,
//                             color: Colors.white,
//                           ),
//                         )
//                       : Text(
//                           confirmText,
//                           style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w600),
//                         ),
//                 ),
//               );
//             },
//           ),
//         ],
//       );
//     },
//   );
// }
//
// Future<void> _openWhatsApp({
//   required String phone,
//   required String message,
// }) async {
//   final normalizedPhone = phone.replaceAll('+', '').trim();
//
//   final url =
//       "whatsapp://send?phone=$normalizedPhone&text=${Uri.encodeComponent(message)}";
//
//   if (await canLaunchUrlString(url)) {
//     await launchUrlString(url, mode: LaunchMode.externalApplication);
//   } else {
//     final webUrl =
//         "https://wa.me/$normalizedPhone?text=${Uri.encodeComponent(message)}";
//     await launchUrlString(webUrl, mode: LaunchMode.externalApplication);
//   }
// }
