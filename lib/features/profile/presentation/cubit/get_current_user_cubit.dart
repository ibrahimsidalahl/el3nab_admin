import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/storage/app_secure_storage.dart';
import '../../data/repos/user_repo.dart';
import 'get_current_user_states.dart';

class GetCurrentUserCubit extends Cubit<GetCurrentUserState> {
  GetCurrentUserCubit() : super(UserInitial());

  final UserRepo _repo = UserRepo.instance;

  // ---------- Get Current User Profile ----------
  Future<void> getCurrentUser() async {
    emit(UserLoading());
    try {
      final user = await _repo.getCurrentUser();
      emit(UserLoaded(user));
    } on AppException catch (e) {
      emit(UserError(e.message));
    } catch (e) {
      emit(UserError('⚠️ حدث خطأ غير متوقع أثناء تحميل بيانات المستخدم.'));
    }
  }


  // ------------------ Delete my Account ------------------

  Future<void> deleteAccount() async {
    try {
      emit(DeleteLoading());

      await _repo.deleteAccount();
      await AppPreferences.clearAccessToken();
      await AppPreferences.clearRefreshToken();
      emit(UserDeleted());
    } on AppException catch (e) {
      emit(DeleteUserError(e.message));
    } catch (e) {
      emit(UserError('حدث خطأ أثناء تسجيل الخروج.'));
    }
  }
}
