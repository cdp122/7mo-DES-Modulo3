import '../../../../core/network/graphql_service.dart';
import '../../domain/entities/resultados_evaluacion.dart';

class ResultadosRepository {
  final GraphQLService _graphQLService;

  ResultadosRepository(this._graphQLService);

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
      query ObtenerResultadosPorDocente($cedula: String!) {
        obtenerResultadosPorDocente(cedula: $cedula) {
          evaluacion_id
          docente_cedula
          docente_nombre
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
          docente_nombre
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
}
