import '../../data/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}
class ResetPasswordLoading extends AuthState {}

class AuthSignInSuccess extends AuthState {
  final UserModel user;
  AuthSignInSuccess(this.user);
}

class AuthSignUpSuccess extends AuthState {
  final UserModel user;
  AuthSignUpSuccess(this.user);
}

class SendOtpSuccess extends AuthState {}

class ResetPasswordSuccess extends AuthState {
  final String message;

  ResetPasswordSuccess(this.message);
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

// When user's phone is not verified - navigate to OTP screen
class AuthPhoneNotVerified extends AuthState {
  final int phoneNumber;
  AuthPhoneNotVerified(this.phoneNumber);
}

class LoggedOutLoading extends AuthState {}
class AuthLoggedOut extends AuthState {}
