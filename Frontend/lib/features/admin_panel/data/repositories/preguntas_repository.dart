import '../../../../core/network/graphql_service.dart';
import '../../domain/entities/dimension.dart';
import '../../domain/entities/reactivo.dart';

class PreguntasRepository {
  final GraphQLService _graphQLService;

  // In-memory mock database for fallback
  final List<DimensionEntity> _mockDimensiones = [
    const DimensionEntity(
      id: 'mock_d1',
      orden: 1,
      nombre: 'Dimensión D1: Planificación Didáctica',
      descripcion: 'Aspectos de la planificación y diseño curricular.',
      fundamento: 'Establece las bases didácticas.',
      reactivos: [
        ReactivoEntity(codigo: '1.1', enunciado: '¿Involucra a los estudiantes en la selección de temas de interés?', pista: 'Considera buzones de sugerencias o asambleas.'),
        ReactivoEntity(codigo: '1.2', enunciado: '¿Define objetivos de aprendizaje consensuados con el grupo?', pista: 'Comprueba si se negocian o explican previamente.'),
        ReactivoEntity(codigo: '1.3', enunciado: '¿Adapta los tiempos curriculares al ritmo de aprendizaje del aula?', pista: 'Flexibilidad de cronogramas.'),
        ReactivoEntity(codigo: '1.4', enunciado: '¿Propone actividades extracurriculares elegidas de forma participativa?', pista: 'Visitas, talleres autogestionados.'),
        ReactivoEntity(codigo: '1.5', enunciado: '¿Integra recursos sugeridos o traídos por los alumnos?', pista: 'Materiales reciclados, lecturas del hogar.'),
      ],
    ),
    const DimensionEntity(
      id: 'mock_d2',
      orden: 2,
      nombre: 'Dimensión D2: Gestión de Aula y Clima',
      descripcion: 'Metodología, dinámicas y relaciones afectivas en clase.',
      fundamento: 'Define el clima afectivo y metodológico de aprendizaje.',
      reactivos: [
        ReactivoEntity(codigo: '2.1', enunciado: '¿El docente fomenta el debate crítico y la expresión libre de ideas?', pista: 'Ausencia de censura o burlas.'),
        ReactivoEntity(codigo: '2.2', enunciado: '¿Se organizan mesas de trabajo cooperativo de manera cotidiana?', pista: 'Trabajo en equipo frente a individual.'),
        ReactivoEntity(codigo: '2.3', enunciado: '¿Existe mediación democrática ante la resolución de conflictos?', pista: 'Elaboración conjunta de normas.'),
        ReactivoEntity(codigo: '2.4', enunciado: '¿Se redistribuye físicamente el aula según la actividad?', pista: 'Uso de mesas circulares, rincones.'),
        ReactivoEntity(codigo: '2.5', enunciado: '¿Se fomenta el rol de liderazgo rotativo en las exposiciones?', pista: 'Todos tienen la oportunidad de coordinar.'),
      ],
    ),
    const DimensionEntity(
      id: 'mock_d3',
      orden: 3,
      nombre: 'Dimensión D3: Evaluación de Procesos',
      descripcion: 'Instrumentos, retroalimentación y autoevaluación.',
      fundamento: 'Cierra el ciclo de aprendizaje reflexivo.',
      reactivos: [
        ReactivoEntity(codigo: '3.1', enunciado: '¿Se aplican pautas de autoevaluación y coevaluación entre pares?', pista: 'Uso de rúbricas de control de grupo.'),
        ReactivoEntity(codigo: '3.2', enunciado: '¿El estudiante puede elegir el formato para demostrar su aprendizaje?', pista: 'Exposición, ensayo, video, maqueta.'),
        ReactivoEntity(codigo: '3.3', enunciado: '¿Se realiza retroalimentación formativa cualitativa e individual?', pista: 'Comentarios de mejora más allá de la nota.'),
        ReactivoEntity(codigo: '3.4', enunciado: '¿Se debaten los criterios de evaluación antes de cada examen?', pista: 'Rúbricas publicadas y explicadas.'),
        ReactivoEntity(codigo: '3.5', enunciado: '¿El docente evalúa el impacto emocional del proceso evaluativo?', pista: 'Encuestas rápidas de satisfacción.'),
      ],
    ),
  ];

  bool _isUsingMock = false;

  bool get isUsingMock => _isUsingMock;

  PreguntasRepository(this._graphQLService);

  Future<List<DimensionEntity>> obtenerDimensiones() async {
    try {
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
        _isUsingMock = false;
        return list.map((item) => DimensionEntity.fromJson(item as Map<String, dynamic>)).toList();
      }
      throw Exception('Falta propiedad obtenerDimensiones');
    } catch (e) {
      print('Fallback a Mock debido a: $e');
      _isUsingMock = true;
      return List.from(_mockDimensiones);
    }
  }

  Future<DimensionEntity> agregarReactivo(String dimensionId, ReactivoEntity reactivo) async {
    if (_isUsingMock || dimensionId.startsWith('mock_')) {
      // Manage mock locally
      final index = _mockDimensiones.indexWhere((d) => d.id == dimensionId);
      if (index >= 0) {
        final dim = _mockDimensiones[index];
        if (dim.reactivos.any((r) => r.codigo == reactivo.codigo)) {
          throw Exception('Ya existe un reactivo con el código ${reactivo.codigo}');
        }
        final nuevosReactivos = List<ReactivoEntity>.from(dim.reactivos)..add(reactivo);
        _mockDimensiones[index] = dim.copyWith(reactivos: nuevosReactivos);
        return _mockDimensiones[index];
      }
      throw Exception('Dimensión no encontrada');
    }

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
    if (_isUsingMock || dimensionId.startsWith('mock_')) {
      final index = _mockDimensiones.indexWhere((d) => d.id == dimensionId);
      if (index >= 0) {
        final dim = _mockDimensiones[index];
        final nuevosReactivos = dim.reactivos.map((r) {
          if (r.codigo == codigoOriginal) {
            return reactivoEditado;
          }
          return r;
        }).toList();
        _mockDimensiones[index] = dim.copyWith(reactivos: nuevosReactivos);
        return _mockDimensiones[index];
      }
      throw Exception('Dimensión no encontrada');
    }

    // Since there's no direct editarReactivo mutation, fetch all reactivos of this dimension,
    // modify the matching one, and update the dimension with the new list of reactivos.
    final dimension = await _obtenerDimensionPorIdDirecto(dimensionId);
    if (dimension == null) throw Exception('Dimensión no encontrada');

    final nuevosReactivos = dimension.reactivos.map((r) {
      if (r.codigo == codigoOriginal) {
        return reactivoEditado;
      }
      return r;
    }).toList();

    return _actualizarReactivosEnServidor(dimensionId, nuevosReactivos);
  }

  Future<DimensionEntity> eliminarReactivo(String dimensionId, String codigo) async {
    if (_isUsingMock || dimensionId.startsWith('mock_')) {
      final index = _mockDimensiones.indexWhere((d) => d.id == dimensionId);
      if (index >= 0) {
        final dim = _mockDimensiones[index];
        final nuevosReactivos = dim.reactivos.where((r) => r.codigo != codigo).toList();
        _mockDimensiones[index] = dim.copyWith(reactivos: nuevosReactivos);
        return _mockDimensiones[index];
      }
      throw Exception('Dimensión no encontrada');
    }

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
