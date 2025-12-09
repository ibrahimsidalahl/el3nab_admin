class AppException implements Exception {
  final String message;
  final int? statusCode;
  final bool isPhoneNotVerified;

  AppException(this.message, {this.statusCode, this.isPhoneNotVerified = false});

  @override
  String toString() => message;
}
