import 'package:dio/dio.dart';

class GraphQLService {
  final Dio _dio;
  final String _endpoint;

  GraphQLService({
    required Dio dio,
    String endpoint = 'http://localhost:4000/graphql',
  })  : _dio = dio,
        _endpoint = endpoint {
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 5);
  }

  Future<Map<String, dynamic>> execute(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    try {
      final response = await _dio.post(
        _endpoint,
        data: {
          'query': query,
          if (variables != null) 'variables': variables,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final body = response.data;
        if (body is Map<String, dynamic>) {
          if (body.containsKey('errors') && body['errors'] != null && (body['errors'] as List).isNotEmpty) {
            final errorMsg = (body['errors'] as List).first['message'] ?? 'Error desconocido de GraphQL';
            throw Exception(errorMsg);
          }
          return body['data'] ?? {};
        }
        throw Exception('Formato de respuesta inválido');
      } else {
        throw Exception('Error del servidor: Código ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.connectionError) {
        throw Exception('No se pudo conectar con el servidor Backend (¿está encendido?).');
      }
      throw Exception('Error de red: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
