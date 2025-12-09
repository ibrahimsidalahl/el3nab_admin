import 'dart:developer';
import 'package:dio/dio.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/utils/constants/app_constants.dart';
import '../../../../core/storage/app_secure_storage.dart';
import '../models/order_model.dart';

class OrdersRepository {
  final Dio _dio;
  static const String _baseUrl = '${AppConstants.baseUrl}/api/v1/admin';

  OrdersRepository({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.headers = {
      'x-api-key': AppConstants.apiKey,
      'Content-Type': 'application/json',
    };
  }

  /// Get auth headers with token
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await AppPreferences.getAccessToken();
    if (token == null || token.isEmpty) {
      throw AppException('يرجى تسجيل الدخول مرة أخرى');
    }
    return {
      'x-api-key': AppConstants.apiKey,
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Refresh access token using refresh token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await AppPreferences.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        log('❌ OrdersRepository: No refresh token available');
        return false;
      }

      log('🔄 OrdersRepository: Refreshing token...');
      
      final response = await _dio.post(
        '${AppConstants.baseUrl}/api/v1/admin/auth/refresh-token',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {
            'x-api-key': AppConstants.apiKey,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final newAccessToken = response.data['data']['accessToken'] as String;
        final newRefreshToken = response.data['data']['refreshToken'] as String;
        
        await AppPreferences.saveTokens(newAccessToken, newRefreshToken);
        log('✅ OrdersRepository: Token refreshed successfully');
        return true;
      }
      
      return false;
    } catch (e) {
      log('❌ OrdersRepository: Token refresh failed: $e');
      return false;
    }
  }

  /// Execute request with automatic token refresh on 401
  Future<Response> _executeWithTokenRefresh(
    Future<Response> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        log('🔄 OrdersRepository: Got 401, attempting token refresh...');
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry the request with new token
          return await request();
        }
      }
      rethrow;
    }
  }

  /// Get all orders with optional status filter
  Future<List<OrderModel>> getAllOrders({List<String>? statusFilter}) async {
    try {
      log('📦 OrdersRepository: Fetching all orders...');
      
      String url = '$_baseUrl/orders';
      if (statusFilter != null && statusFilter.isNotEmpty) {
        final statusParams = statusFilter.map((s) => 'status=$s').join('&');
        url = '$url?$statusParams';
      }
      
      log('📦 OrdersRepository: GET $url');

      final response = await _executeWithTokenRefresh(() async {
        final freshHeaders = await _getAuthHeaders();
        return await _dio.get(
          url,
          options: Options(headers: freshHeaders),
        );
      });

      log('📦 OrdersRepository: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['status'] == 'success' && data['data'] != null) {
          final ordersData = data['data']['orders'] as List;
          log('📦 OrdersRepository: Found ${ordersData.length} orders');
          
          final orders = ordersData
              .map((orderJson) => OrderModel.fromJson(orderJson as Map<String, dynamic>))
              .toList();

          log('📦 OrdersRepository: Successfully parsed ${orders.length} orders');
          return orders;
        } else {
          throw AppException(data['message'] ?? 'فشل في جلب الطلبات');
        }
      } else {
        throw AppException('خطأ في الخادم: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ OrdersRepository: DioException: ${e.message}');
      log('❌ OrdersRepository: Response: ${e.response?.data}');
      throw AppException(_handleDioError(e));
    } catch (e) {
      log('❌ OrdersRepository: Error: $e');
      if (e is AppException) rethrow;
      throw AppException('حدث خطأ غير متوقع في جلب الطلبات');
    }
  }

  /// Get order by ID
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      log('📦 OrdersRepository: Fetching order: $orderId');

      final url = '$_baseUrl/orders/$orderId';
      log('📦 OrdersRepository: GET $url');

      final response = await _executeWithTokenRefresh(() async {
        final authHeaders = await _getAuthHeaders();
        return await _dio.get(
          url,
          options: Options(headers: authHeaders),
        );
      });

      log('📦 OrdersRepository: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success' && data['data'] != null) {
          final orderData = data['data']['order'];
          final order = OrderModel.fromJson(orderData as Map<String, dynamic>);

          log('📦 OrdersRepository: Successfully loaded order #${order.orderNumber}');
          return order;
        } else {
          throw AppException(data['message'] ?? 'فشل في جلب تفاصيل الطلب');
        }
      } else {
        throw AppException('خطأ في الخادم: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ OrdersRepository: DioException: ${e.message}');
      throw AppException(_handleDioError(e));
    } catch (e) {
      log('❌ OrdersRepository: Error: $e');
      if (e is AppException) rethrow;
      throw AppException('حدث خطأ غير متوقع في جلب تفاصيل الطلب');
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'انتهت مهلة الاتصال بالخادم';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'];
        if (statusCode == 401) {
          return 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً';
        } else if (statusCode == 403) {
          return 'ليس لديك صلاحية للوصول';
        } else if (statusCode == 404) {
          return 'البيانات غير موجودة';
        }
        return message ?? 'خطأ في الخادم: $statusCode';
      case DioExceptionType.connectionError:
        return 'لا يوجد اتصال بالإنترنت';
      default:
        return 'حدث خطأ في الاتصال';
    }
  }
}
