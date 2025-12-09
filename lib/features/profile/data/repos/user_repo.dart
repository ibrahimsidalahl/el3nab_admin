import 'package:dio/dio.dart';
import 'package:el3nab_admin/core/errors/app_exceptions.dart';
import 'package:el3nab_admin/core/errors/error_handler.dart';
import 'package:el3nab_admin/core/storage/app_secure_storage.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/app_secure_storage.dart';
import '../../../../core/utils/constants/app_constants.dart';
import '../../../auth/data/models/user_model.dart';

class UserRepo {
  UserRepo._();

  static final UserRepo instance = UserRepo._();

  // ------------------ Get Current User Profile ------------------
  Future<UserModel> getCurrentUser() async {
    try {
      final dio = await DioClient.getInstance(); // ✅ استخدم Dio مع الكاش
      final token = await AppPreferences.getAccessToken();

      final response = await dio.get(
        '/api/v1/users/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'x-api-key': AppConstants.apiKey,
          },
        ),
      );

      final data = response.data['data'];
      return UserModel.fromJson(data['user']);

    } on DioException catch (e) {
      // ✅ مرّر الخطأ لـ ErrorHandler الخاص بك
      throw ErrorHandler.handleDioError(e);

    } catch (e) {
      // ✅ أي خطأ غير معروف
      throw AppException('حدث خطأ غير متوقع: $e');
    }
  }

  // ------------------ Delete my Account ------------------
  Future<bool> deleteAccount() async {
    try {
      final token = await AppPreferences.getAccessToken();

      final dio = await DioClient.getInstance();
      await dio.delete(
        '/api/v1/users/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'x-api-key': AppConstants.apiKey,
          },
        ),
      );

      await AppPreferences.clearAccessToken();
      await AppPreferences.clearRefreshToken();
      return true;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      throw AppException('حدث خطأ غير متوقع: $e');
    }
  }
}
