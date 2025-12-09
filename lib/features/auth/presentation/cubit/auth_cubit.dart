import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:el3nab_admin/features/auth/data/repos/auth_repo.dart';
import 'package:el3nab_admin/features/auth/presentation/cubit/auth_states.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/storage/app_secure_storage.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final AuthRepo _repo = AuthRepo.instance;

  // ---------------------- Sign In ----------------------
  Future<void> signIn({required int phone, required String password}) async {
    emit(AuthLoading());
    log("🔵 [SignIn] Started → phone: $phone");

    try {
      final user = await _repo.signIn(phone: phone, password: password);
      log("🟢 [SignIn] Success → userId: ${user.id}");



      emit(AuthSignInSuccess(user));
    } on AppException catch (e) {
      log("❌ [SignIn] AppException → ${e.message}");
      emit(AuthError(e.message));
    } catch (e) {
      log("❌ [SignIn] Unexpected Error → $e");
      emit(AuthError("حدث خطأ غير متوقع أثناء تسجيل الدخول."));
    }
  }


  // ---------------------- Logout ----------------------
  Future<void> logout() async {
    log("🔴 [Logout] Started");

    try {
      emit(LoggedOutLoading());
      await _repo.logout();

      await AppPreferences.clearAccessToken();
      await AppPreferences.clearUserId();
      log("🗑 Tokens Cleared");

      emit(AuthLoggedOut());
    } on AppException catch (e) {
      log("❌ [Logout] AppException → ${e.message}");
      emit(AuthError(e.message));
    } catch (e) {
      log("❌ [Logout] Unexpected → $e");
      emit(AuthError("حدث خطأ أثناء تسجيل الخروج."));
    }
  }
}
