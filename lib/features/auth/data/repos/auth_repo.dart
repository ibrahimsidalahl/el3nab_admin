import 'package:dio/dio.dart';
import 'package:el3nab_admin/core/errors/app_exceptions.dart';
import 'package:el3nab_admin/core/errors/error_handler.dart';
import 'package:el3nab_admin/core/storage/app_secure_storage.dart';
import '../../../../core/errors/token_interceptor.dart';
import '../../../../core/utils/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthRepo {
  AuthRepo._();

  static final AuthRepo instance = AuthRepo._();

  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl))
    ..interceptors.add(TokenInterceptor());

  Future<Response> _postRequest(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final headers = <String, String>{
        'x-api-key': AppConstants.apiKey,
      };

      // ✅ Always add auth token if available
      final token = await AppPreferences.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.post(
        endpoint,
        data: data,
        options: Options(headers: headers),
      );

      return response;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }


  // ------------------ Sign In ------------------
  Future<UserModel> signIn({
    required int phone,
    required String password,
  }) async {
    try {
      final response = await _postRequest(
        '/api/v1/admin/auth/login',
        data: {"phone": phone, "password": password},
      );

      final data = response.data['data'];
      await AppPreferences.saveTokens(
        data['accessToken'],
        data['refreshToken'],
      );

      return UserModel.fromJson(data['user']);
    } catch (e) {
      throw AppException(' $e');
    }
  }


  // ------------------ Logout ------------------
  Future<bool> logout() async {
    try {
      await _postRequest(
        '/api/v1/auth/logout',
      );
      await AppPreferences.clearAccessToken();
      await AppPreferences.clearRefreshToken();
      return true;
    }
    // on DioException catch (e) {
    //   throw ErrorHandler.handleDioError(e);
    // }
    catch (e) {
      throw AppException('$e');
    }
  }
}