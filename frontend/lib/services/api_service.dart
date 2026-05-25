import 'package:dio/dio.dart';
import 'package:campus_events_ai/core/constants.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, String? userEmail}) async {
    final options = Options();
    if (userEmail != null) {
      options.headers = {'user-email': userEmail};
    }
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(String path, {dynamic data, String? userEmail}) async {
    final options = Options();
    if (userEmail != null) {
      options.headers = {'user-email': userEmail};
    }
    return _dio.post(path, data: data, options: options);
  }

  Future<Response> put(String path, {dynamic data, String? userEmail}) async {
    final options = Options();
    if (userEmail != null) {
      options.headers = {'user-email': userEmail};
    }
    return _dio.put(path, data: data, options: options);
  }

  Future<Response> delete(String path, {String? userEmail}) async {
    final options = Options();
    if (userEmail != null) {
      options.headers = {'user-email': userEmail};
    }
    return _dio.delete(path, options: options);
  }
}
