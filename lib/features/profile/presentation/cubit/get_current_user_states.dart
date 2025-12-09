
import '../../../auth/data/models/user_model.dart';

abstract class GetCurrentUserState {}

// الحالة الابتدائية
class UserInitial extends GetCurrentUserState {}

// جاري تحميل بيانات المستخدم
class UserLoading extends GetCurrentUserState {}

// تم تحميل بيانات المستخدم بنجاح
class UserLoaded extends GetCurrentUserState {
  final UserModel user;

  UserLoaded(this.user);
}

// حدث خطأ أثناء تحميل البيانات
class UserError extends GetCurrentUserState {
  final String message;

  UserError(this.message);
}class DeleteUserError extends GetCurrentUserState {
  final String message;

  DeleteUserError(this.message);
}
class UserDeleted extends GetCurrentUserState{
}
class DeleteLoading extends GetCurrentUserState{

}