import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/admin_panel/domain/entities/resultados_evaluacion.dart';
import 'package:frontend/features/admin_panel/presentation/controller/resultados_cubit.dart';
import 'package:frontend/features/admin_panel/presentation/controller/resultados_state.dart';
import 'package:frontend/features/admin_panel/data/repositories/resultados_repository.dart';
import 'package:frontend/core/network/graphql_service.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:dio/dio.dart';

// ── Fake GraphQLService for testing ──────────────────────────────────

class FakeGraphQLService extends GraphQLService {
  final Future<Map<String, dynamic>> Function(String query, {Map<String, dynamic>? variables})? handler;

  FakeGraphQLService({this.handler}) : super(dio: Dio());

  @override
  Future<Map<String, dynamic>> execute(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    if (handler != null) {
      return handler!(query, variables: variables);
    }
    return {};
  }
}

// ── Fake ApiClient for testing ───────────────────────────────────────

class FakeApiClient extends ApiClient {
  FakeApiClient() : super(Dio());
}

// ── Fake ResumenGeneral data ─────────────────────────────────────────

const _resumenJson = {
  'total_evaluaciones': 5,
  'promedio_D1': 15.0,
  'promedio_D2': 12.0,
  'promedio_D3': 18.0,
  'promedio_IGPP': 75.0,
  'nivel_general': 'Participación en desarrollo',
  'dimensiones': <Map<String, dynamic>>[],
};

const _resultadoDocenteJson = {
  'evaluacion_id': 'eval-001',
  'docente_cedula': '1718056490',
  'dimensiones': <Map<String, dynamic>>[],
  'puntaje_total': 45,
  'maximo_total': 60,
  'IGPP': 75.0,
  'nivel_general': 'Participación en desarrollo',
  'dimension_prioritaria': 'D2',
};

void main() {
  // ─── CP-FE-RC01: Estado inicial ────────────────────────────────────
  test('CP-FE-RC01: Estado inicial es ResultadosInitial', () {
    final graphQL = FakeGraphQLService();
    final repo = ResultadosRepository(graphQL, FakeApiClient());
    final cubit = ResultadosCubit(repo);

    expect(cubit.state, isA<ResultadosInitial>());
    cubit.close();
  });

  // ─── CP-FE-RC02: cargarResumenGeneral exitoso ─────────────────────
  test('CP-FE-RC02: cargarResumenGeneral emite Loading luego Loaded', () async {
    final graphQL = FakeGraphQLService(
      handler: (query, {variables}) async {
        return {'obtenerResumenGeneral': _resumenJson};
      },
    );
    final repo = ResultadosRepository(graphQL, FakeApiClient());
    final cubit = ResultadosCubit(repo);

    final states = <ResultadosState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.cargarResumenGeneral();
    await Future.delayed(Duration.zero);

    expect(states.length, greaterThanOrEqualTo(2));
    expect(states[0], isA<ResultadosLoading>());
    expect(states[1], isA<ResultadosLoaded>());
    final loaded = states[1] as ResultadosLoaded;
    expect(loaded.resumen.totalEvaluaciones, 5);
    expect(loaded.resumen.promedioIGPP, 75.0);

    await sub.cancel();
    await cubit.close();
  });

  // ─── CP-FE-RC03: cargarResumenGeneral con error ───────────────────
  test('CP-FE-RC03: cargarResumenGeneral emite Loading luego Error al fallar', () async {
    final graphQL = FakeGraphQLService(
      handler: (query, {variables}) async {
        throw Exception('Error de conexión');
      },
    );
    final repo = ResultadosRepository(graphQL, FakeApiClient());
    final cubit = ResultadosCubit(repo);

    final states = <ResultadosState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.cargarResumenGeneral();
    await Future.delayed(Duration.zero);

    expect(states.length, greaterThanOrEqualTo(2));
    expect(states[0], isA<ResultadosLoading>());
    expect(states[1], isA<ResultadosError>());

    await sub.cancel();
    await cubit.close();
  });

  // ─── CP-FE-RC04: buscarPorDocente exitoso ─────────────────────────
  test('CP-FE-RC04: buscarPorDocente emite ResultadosLoaded con resultados del docente', () async {
    int callCount = 0;
    final graphQL = FakeGraphQLService(
      handler: (query, {variables}) async {
        callCount++;
        if (query.contains('obtenerResumenGeneral')) {
          return {'obtenerResumenGeneral': _resumenJson};
        }
        if (query.contains('obtenerResultadosPorDocente')) {
          return {
            'obtenerResultadosPorDocente': [_resultadoDocenteJson]
          };
        }
        return {};
      },
    );
    final repo = ResultadosRepository(graphQL, FakeApiClient());
    final cubit = ResultadosCubit(repo);

    // First load the resumen
    await cubit.cargarResumenGeneral();
    await Future.delayed(Duration.zero);

    final states = <ResultadosState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.buscarPorDocente('1718056490');
    await Future.delayed(Duration.zero);

    // Should have the loaded state with results
    final loadedStates = states.whereType<ResultadosLoaded>().toList();
    expect(loadedStates, isNotEmpty);
    final lastLoaded = loadedStates.last;
    expect(lastLoaded.resultadosDocente.length, 1);
    expect(lastLoaded.resultadosDocente[0].evaluacionId, 'eval-001');

    await sub.cancel();
    await cubit.close();
  });

  // ─── CP-FE-RC05: buscarPorDocente sin resumen previo ──────────────
  test('CP-FE-RC05: buscarPorDocente cuando no hay resumen cargado, carga ambos', () async {
    final graphQL = FakeGraphQLService(
      handler: (query, {variables}) async {
        if (query.contains('obtenerResumenGeneral')) {
          return {'obtenerResumenGeneral': _resumenJson};
        }
        if (query.contains('obtenerResultadosPorDocente')) {
          return {
            'obtenerResultadosPorDocente': [_resultadoDocenteJson]
          };
        }
        return {};
      },
    );
    final repo = ResultadosRepository(graphQL, FakeApiClient());
    final cubit = ResultadosCubit(repo);

    final states = <ResultadosState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.buscarPorDocente('1718056490');
    await Future.delayed(Duration.zero);

    // Should end up with a ResultadosLoaded that has both resumen and resultados
    final loadedStates = states.whereType<ResultadosLoaded>().toList();
    expect(loadedStates, isNotEmpty);
    final lastLoaded = loadedStates.last;
    expect(lastLoaded.resumen.totalEvaluaciones, 5);
    expect(lastLoaded.resultadosDocente.length, 1);

    await sub.cancel();
    await cubit.close();
  });

  // ─── CP-FE-RC06: limpiarBusqueda ──────────────────────────────────
  test('CP-FE-RC06: limpiarBusqueda emite estado con resultadosDocente vacío', () async {
    final graphQL = FakeGraphQLService(
      handler: (query, {variables}) async {
        if (query.contains('obtenerResumenGeneral')) {
          return {'obtenerResumenGeneral': _resumenJson};
        }
        if (query.contains('obtenerResultadosPorDocente')) {
          return {
            'obtenerResultadosPorDocente': [_resultadoDocenteJson]
          };
        }
        return {};
      },
    );
    final repo = ResultadosRepository(graphQL, FakeApiClient());
    final cubit = ResultadosCubit(repo);

    // Load resumen + search
    await cubit.cargarResumenGeneral();
    await cubit.buscarPorDocente('1718056490');
    await Future.delayed(Duration.zero);

    final states = <ResultadosState>[];
    final sub = cubit.stream.listen(states.add);

    cubit.limpiarBusqueda();
    await Future.delayed(Duration.zero);

    expect(states, isNotEmpty);
    final lastLoaded = states.whereType<ResultadosLoaded>().last;
    expect(lastLoaded.resultadosDocente, isEmpty);

    await sub.cancel();
    await cubit.close();
  });
}
