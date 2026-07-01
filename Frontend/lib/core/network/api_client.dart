import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio) {
    const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:4000');
    _dio.options.baseUrl = '$baseUrl/api';
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    
    // Add logging and custom headers or token interceptors here
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Dio get dio => _dio;
}
