// import 'package:dio/dio.dart';
// import 'package:elragol_el3nab/core/storage/app_secure_storage.dart';
// import 'package:elragol_el3nab/core/errors/app_exceptions.dart';
// import 'package:elragol_el3nab/core/utils/constants/app_constants.dart';
//
// class TokenInterceptor extends Interceptor {
//   final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
//
//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) async {
//     // لو كان الخطأ بسبب Invalid Token أو 401
//
//     if (err.response?.statusCode == 401 &&
//         (err.response?.data['message']?.toString().contains('Invalid token') ??
//             false)) {
//       final refreshToken = await AppPreferences.getRefreshToken();
//       if (refreshToken != null) {
//         try {
//           // 1. نبعث refresh token للسيرفر
//           final refreshResponse = await _dio.post(
//             '/api/v1/auth/refresh-token',
//             options: Options(headers: {'x-api-key': AppConstants.apiKey}),
//             data: {'refreshToken': refreshToken},
//           );
//
//           if (refreshResponse.statusCode == 200 &&
//               refreshResponse.data['status'] == 'success') {
//             final newAccessToken = refreshResponse.data['data']['accessToken'];
//             final newRefreshToken =
//                 refreshResponse.data['data']['refreshToken'];
//
//             // 2. نحفظ التوكنات الجديدة
//             await AppPreferences.saveAccessToken(newAccessToken);
//             await AppPreferences.saveRefreshToken(newRefreshToken);
//
//             // 3. نعيد الطلب الأصلي
//             final options = err.requestOptions;
//             options.headers['Authorization'] = 'Bearer $newAccessToken';
//
//             final cloneReq = await _dio.fetch(options);
//             return handler.resolve(cloneReq);
//           }
//         } catch (e) {
//           return handler.reject(
//             DioException(
//               requestOptions: err.requestOptions,
//               error: 'Refresh token failed: $e',
//             ),
//           );
//         }
//       }
//     }
//     return handler.next(err);
//   }
// }
import 'package:dio/dio.dart';
import 'package:el3nab_admin/core/storage/app_secure_storage.dart';
import 'package:el3nab_admin/core/utils/constants/app_constants.dart';

class TokenInterceptor extends Interceptor {
  final Dio authDio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    headers: {"x-api-key": AppConstants.apiKey},
  ));

  bool _isRefreshing = false;
  final List<Function(String)> _retryQueue = [];

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;

    /// هل الخطأ بسبب انتهاء الـ Access Token ؟
    final isTokenExpired = statusCode == 401 &&
        (err.response?.data['message']?.toString().contains("Invalid token") ??
            false);

    if (!isTokenExpired) {
      return handler.next(err);
    }

    final refreshToken = await AppPreferences.getRefreshToken();
    if (refreshToken == null) {
      return handler.reject(err);
    }

    final RequestOptions requestOptions = err.requestOptions;

    /// لو في Refresh شغال حالياً → ندخل الطلب في Queue
    if (_isRefreshing) {
      _retryQueue.add((String newToken) async {
        final newReq = await _retryRequest(requestOptions, newToken);
        handler.resolve(newReq);
      });
      return;
    }

    _isRefreshing = true;

    try {
      /// 1. Refresh token request
      final response = await authDio.post(
        "/api/v1/auth/refresh-token",
        data: {"refreshToken": refreshToken},
      );

      if (response.statusCode == 200 && response.data["status"] == "success") {
        final newAccessToken = response.data["data"]["accessToken"];
        final newRefreshToken = response.data["data"]["refreshToken"];

        /// 2. Save new tokens
        await AppPreferences.saveAccessToken(newAccessToken);
        await AppPreferences.saveRefreshToken(newRefreshToken);

        /// 3. نفذ الطلب اللي كان عامل Error
        final newReq =
        await _retryRequest(requestOptions, newAccessToken);

        /// 4. نفّذ كل الطلبات اللي كانت مستنية
        for (var callback in _retryQueue) {
          callback(newAccessToken);
        }

        _retryQueue.clear();
        _isRefreshing = false;

        return handler.resolve(newReq);
      }
    } catch (e) {
      _isRefreshing = false;
      _retryQueue.clear();

      return handler.reject(
        DioException(
          requestOptions: requestOptions,
          error: "Refresh token failed: $e",
        ),
      );
    }

    _isRefreshing = false;
    return handler.next(err);
  }

  Future<Response> _retryRequest(
      RequestOptions requestOptions, String newToken) {
    final dio = Dio();

    /// copy options صح
    final opts = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        "Authorization": "Bearer $newToken",
      },
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
    );

    return dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: opts,
    );
  }
}
