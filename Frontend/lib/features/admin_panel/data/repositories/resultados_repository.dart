import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/graphql_service.dart';
import '../../domain/entities/resultados_evaluacion.dart';

class ResultadosRepository {
  final GraphQLService _graphQLService;
  final ApiClient _apiClient;

  ResultadosRepository(this._graphQLService, this._apiClient);

  Future<ResumenGeneralEntity> obtenerResumenGeneral() async {
    const query = r'''
      query {
        obtenerResumenGeneral {
          total_evaluaciones
          promedio_D1
          promedio_D2
          promedio_D3
          promedio_IGPP
          nivel_general
          dimensiones {
            nombre
            clave
            puntaje
            maximo
            porcentaje
            nivel
          }
        }
      }
    ''';

    final data = await _graphQLService.execute(query);
    if (data.containsKey('obtenerResumenGeneral')) {
      return ResumenGeneralEntity.fromJson(
        data['obtenerResumenGeneral'] as Map<String, dynamic>,
      );
    }
    throw Exception('Falta propiedad obtenerResumenGeneral');
  }

  Future<List<ResultadosInterpretadosEntity>> obtenerResultadosPorDocente(
    String cedula,
  ) async {
    const query = r'''
      query ObtenerResultadosPorDocente($cedula: CedulaEcuatoriana!) {
        obtenerResultadosPorDocente(cedula: $cedula) {
          evaluacion_id
          docente_cedula
          dimensiones {
            nombre
            clave
            puntaje
            maximo
            porcentaje
            nivel
          }
          puntaje_total
          maximo_total
          IGPP
          nivel_general
          dimension_prioritaria
        }
      }
    ''';

    final data = await _graphQLService.execute(
      query,
      variables: {'cedula': cedula},
    );
    if (data.containsKey('obtenerResultadosPorDocente')) {
      final list = data['obtenerResultadosPorDocente'] as List;
      return list
          .map(
            (item) => ResultadosInterpretadosEntity.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }
    throw Exception('Falta propiedad obtenerResultadosPorDocente');
  }

  Future<ResultadosInterpretadosEntity?> obtenerResultadosEvaluacion(
    String id,
  ) async {
    const query = r'''
      query ObtenerResultadosEvaluacion($id: ID!) {
        obtenerResultadosEvaluacion(id: $id) {
          evaluacion_id
          docente_cedula
          dimensiones {
            nombre
            clave
            puntaje
            maximo
            porcentaje
            nivel
          }
          puntaje_total
          maximo_total
          IGPP
          nivel_general
          dimension_prioritaria
        }
      }
    ''';

    final data = await _graphQLService.execute(
      query,
      variables: {'id': id},
    );
    if (data.containsKey('obtenerResultadosEvaluacion') &&
        data['obtenerResultadosEvaluacion'] != null) {
      return ResultadosInterpretadosEntity.fromJson(
        data['obtenerResultadosEvaluacion'] as Map<String, dynamic>,
      );
    }
    return null;
  }

  /// Descarga el reporte Excel de evaluaciones desde el backend.
  /// Si [cedula] se provee, filtra solo las evaluaciones de ese docente.
  Future<List<int>> exportarEvaluacionesExcel({String? cedula}) async {
    try {
      final response = await _apiClient.dio.get<List<int>>(
        '/reportes/evaluaciones/excel',
        queryParameters: cedula != null ? {'cedula': cedula} : null,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            if (_graphQLService.token != null)
              'Authorization': 'Bearer ${_graphQLService.token}',
          },
        ),
      );
      return response.data ?? [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception(
          'No autenticado. Vuelve a iniciar sesión como administrador.',
        );
      }
      throw Exception('No se pudo generar el archivo Excel: ${e.message}');
    }
  }
}
