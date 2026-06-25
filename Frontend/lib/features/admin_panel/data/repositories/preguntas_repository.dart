import '../../../../core/network/graphql_service.dart';
import '../../domain/entities/dimension.dart';
import '../../domain/entities/reactivo.dart';

class PreguntasRepository {
  final GraphQLService _graphQLService;

  PreguntasRepository(this._graphQLService);

  Future<List<DimensionEntity>> obtenerDimensiones() async {
    const query = r'''
      query {
        obtenerDimensiones {
          id
          orden
          nombre
          descripcion
          fundamento
          reactivos {
            reactivo_codigo
            enunciado
            pista
          }
        }
      }
    ''';

    final data = await _graphQLService.execute(query);
    if (data.containsKey('obtenerDimensiones')) {
      final list = data['obtenerDimensiones'] as List;
      return list.map((item) => DimensionEntity.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception('Falta propiedad obtenerDimensiones');
  }


  Future<DimensionEntity> crearDimension(DimensionEntity dimension) async {
    const mutation = r'''
      mutation CrearDimension($input: CrearDimensionInput!) {
        crearDimension(input: $input) {
          id
          orden
          nombre
          descripcion
          fundamento
          reactivos {
            reactivo_codigo
            enunciado
            pista
          }
        }
      }
    ''';

    final variables = {
      'input': {
        'orden': dimension.orden,
        'nombre': dimension.nombre,
        'descripcion': dimension.descripcion,
        'fundamento': dimension.fundamento,
        'reactivos': [],
      }
    };

    final data = await _graphQLService.execute(mutation, variables: variables);
    if (data.containsKey('crearDimension')) {
      return DimensionEntity.fromJson(data['crearDimension'] as Map<String, dynamic>);
    }
    throw Exception('Error al crear la dimensión en el servidor');
  }

  Future<DimensionEntity> actualizarDimension(
    String id, {
    String? nombre,
    String? descripcion,
    String? fundamento,
    List<ReactivoEntity>? reactivos,
  }) async {
    final input = <String, dynamic>{
      if (nombre != null) 'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (fundamento != null) 'fundamento': fundamento,
      if (reactivos != null) 'reactivos': reactivos.map((r) => r.toJson()).toList(),
    };

    const mutation = r'''
      mutation ActualizarDimension($id: ID!, $input: ActualizarDimensionInput!) {
        actualizarDimension(id: $id, input: $input) {
          id
          orden
          nombre
          descripcion
          fundamento
          reactivos {
            reactivo_codigo
            enunciado
            pista
          }
        }
      }
    ''';

    final data = await _graphQLService.execute(mutation, variables: {'id': id, 'input': input});
    if (data.containsKey('actualizarDimension') && data['actualizarDimension'] != null) {
      return DimensionEntity.fromJson(data['actualizarDimension'] as Map<String, dynamic>);
    }
    throw Exception('Error al actualizar la dimensión en el servidor');
  }

  Future<bool> eliminarDimension(String id) async {
    const mutation = r'''
      mutation EliminarDimension($id: ID!) {
        eliminarDimension(id: $id)
      }
    ''';

    final data = await _graphQLService.execute(mutation, variables: {'id': id});
    if (data.containsKey('eliminarDimension')) {
      return data['eliminarDimension'] as bool;
    }
    throw Exception('Error al eliminar la dimensión en el servidor');
  }

  Future<DimensionEntity> agregarReactivo(String dimensionId, ReactivoEntity reactivo) async {
    const mutation = r'''
      mutation AgregarReactivo($dimensionId: ID!, $input: CrearReactivoInput!) {
        agregarReactivo(dimensionId: $dimensionId, input: $input) {
          id
          orden
          nombre
          descripcion
          fundamento
          reactivos {
            reactivo_codigo
            enunciado
            pista
          }
        }
      }
    ''';

    final variables = {
      'dimensionId': dimensionId,
      'input': {
        'reactivo_codigo': reactivo.codigo,
        'enunciado': reactivo.enunciado,
        if (reactivo.pista != null && reactivo.pista!.isNotEmpty) 'pista': reactivo.pista,
      }
    };

    final data = await _graphQLService.execute(mutation, variables: variables);
    if (data.containsKey('agregarReactivo')) {
      return DimensionEntity.fromJson(data['agregarReactivo'] as Map<String, dynamic>);
    }
    throw Exception('Error al agregar el reactivo en el servidor');
  }

  Future<DimensionEntity> editarReactivo(String dimensionId, String codigoOriginal, ReactivoEntity reactivoEditado) async {
    // No existe mutación directa para editar reactivo: buscamos la dimensión,
    // reemplazamos el reactivo modificado y actualizamos la lista completa.
    final dimension = await _obtenerDimensionPorIdDirecto(dimensionId);
    if (dimension == null) throw Exception('Dimensión no encontrada');

    final nuevosReactivos = dimension.reactivos.map((r) {
      return r.codigo == codigoOriginal ? reactivoEditado : r;
    }).toList();

    return _actualizarReactivosEnServidor(dimensionId, nuevosReactivos);
  }

  Future<DimensionEntity> eliminarReactivo(String dimensionId, String codigo) async {
    final dimension = await _obtenerDimensionPorIdDirecto(dimensionId);
    if (dimension == null) throw Exception('Dimensión no encontrada');

    final nuevosReactivos = dimension.reactivos.where((r) => r.codigo != codigo).toList();
    return _actualizarReactivosEnServidor(dimensionId, nuevosReactivos);
  }

  Future<DimensionEntity?> _obtenerDimensionPorIdDirecto(String id) async {
    const query = r'''
      query ObtenerDimension($id: ID!) {
        obtenerDimension(id: $id) {
          id
          orden
          nombre
          descripcion
          fundamento
          reactivos {
            reactivo_codigo
            enunciado
            pista
          }
        }
      }
    ''';

    final data = await _graphQLService.execute(query, variables: {'id': id});
    if (data.containsKey('obtenerDimension') && data['obtenerDimension'] != null) {
      return DimensionEntity.fromJson(data['obtenerDimension'] as Map<String, dynamic>);
    }
    return null;
  }

  Future<DimensionEntity> _actualizarReactivosEnServidor(String id, List<ReactivoEntity> reactivos) async {
    const mutation = r'''
      mutation ActualizarDimension($id: ID!, $input: ActualizarDimensionInput!) {
        actualizarDimension(id: $id, input: $input) {
          id
          orden
          nombre
          descripcion
          fundamento
          reactivos {
            reactivo_codigo
            enunciado
            pista
          }
        }
      }
    ''';

    final variables = {
      'id': id,
      'input': {
        'reactivos': reactivos.map((r) => r.toJson()).toList(),
      }
    };

    final data = await _graphQLService.execute(mutation, variables: variables);
    if (data.containsKey('actualizarDimension') && data['actualizarDimension'] != null) {
      return DimensionEntity.fromJson(data['actualizarDimension'] as Map<String, dynamic>);
    }
    throw Exception('Error al actualizar reactivos en el servidor');
  }
}
