import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:path_provider/path_provider.dart';

import '../errors/token_interceptor.dart';
import '../utils/constants/app_constants.dart';

class DioClient {
  static Dio? _dio;

  static Future<Dio> getInstance() async {
    if (_dio != null) return _dio!;

    final dir = await getApplicationDocumentsDirectory();
    final cacheStore = HiveCacheStore('${dir.path}/dio_cache');

    final cacheOptions = CacheOptions(
      store: cacheStore,
      policy: CachePolicy.request,
      hitCacheOnErrorExcept: [401, 403],
      maxStale: const Duration(minutes: 30),
      priority: CachePriority.normal,
    );

    final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl))
      ..interceptors.add(TokenInterceptor())
      ..interceptors.add(DioCacheInterceptor(options: cacheOptions));

    _dio = dio;
    return _dio!;
  }
}
