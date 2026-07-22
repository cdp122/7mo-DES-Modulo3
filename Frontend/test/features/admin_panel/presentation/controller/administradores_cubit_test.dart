import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/admin_panel/domain/entities/administrador.dart';
import 'package:frontend/features/admin_panel/presentation/controller/administradores_cubit.dart';
import 'package:frontend/features/admin_panel/presentation/controller/administradores_state.dart';
import 'package:frontend/features/admin_panel/data/repositories/administradores_repository.dart';
import 'package:frontend/core/network/graphql_service.dart';
import 'package:dio/dio.dart';

// ── Fake GraphQLService ──────────────────────────────────────────────

class FakeGraphQLService extends GraphQLService {
  final Future<Map<String, dynamic>> Function(
    String query, {
    Map<String, dynamic>? variables,
  })? handler;

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

// ── Test data ────────────────────────────────────────────────────────

const _adminsJson = [
  {'id': '1', 'cedula': '1718056490', 'nombre': 'Admin Alpha'},
  {'id': '2', 'cedula': '1722250295', 'nombre': 'Admin Beta'},
  {'id': '3', 'cedula': '0501234567', 'nombre': 'Admin Gamma'},
];

void main() {
  // ─── CP-FE-AC01: Estado inicial ────────────────────────────────────
  test('CP-FE-AC01: Estado inicial es AdministradoresInitial', () {
    final graphQL = FakeGraphQLService();
    final repo = AdministradoresRepository(graphQL);
    final cubit = AdministradoresCubit(repo);

    expect(cubit.state, isA<AdministradoresInitial>());
    cubit.close();
  });

  // ─── CP-FE-AC02: cargar exitoso ───────────────────────────────────
  test('CP-FE-AC02: cargar emite Loading luego Loaded con lista ordenada', () async {
    final graphQL = FakeGraphQLService(
      handler: (query, {variables}) async {
        return {'obtenerAdministradores': _adminsJson};
      },
    );
    final repo = AdministradoresRepository(graphQL);
    final cubit = AdministradoresCubit(repo);

    final states = <AdministradoresState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.cargar();
    await Future.delayed(Duration.zero);

    expect(states.length, greaterThanOrEqualTo(2));
    expect(states[0], isA<AdministradoresLoading>());
    expect(states[1], isA<AdministradoresLoaded>());
    final loaded = states[1] as AdministradoresLoaded;
    expect(loaded.todos.length, 3);
    // Default ordering is nombre_asc
    expect(loaded.filtrados[0].nombre, 'Admin Alpha');
    expect(loaded.filtrados[1].nombre, 'Admin Beta');
    expect(loaded.filtrados[2].nombre, 'Admin Gamma');

    await sub.cancel();
    await cubit.close();
  });

  // ─── CP-FE-AC03: cargar con error ─────────────────────────────────
  test('CP-FE-AC03: cargar emite Loading luego Error al fallar', () async {
    final graphQL = FakeGraphQLService(
      handler: (query, {variables}) async {
        throw Exception('Error de red');
      },
    );
    final repo = AdministradoresRepository(graphQL);
    final cubit = AdministradoresCubit(repo);

    final states = <AdministradoresState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.cargar();
    await Future.delayed(Duration.zero);

    expect(states.length, greaterThanOrEqualTo(2));
    expect(states[0], isA<AdministradoresLoading>());
    expect(states[1], isA<AdministradoresError>());

    await sub.cancel();
    await cubit.close();
  });

  // ─── CP-FE-AC04: buscar filtra por nombre ─────────────────────────
  test('CP-FE-AC04: buscar filtra por nombre', () async {
    final graphQL = FakeGraphQLService(
      handler: (query, {variables}) async {
        return {'obtenerAdministradores': _adminsJson};
      },
    );
    final repo = AdministradoresRepository(graphQL);
    final cubit = AdministradoresCubit(repo);

    await cubit.cargar();
    await Future.delayed(Duration.zero);

    final states = <AdministradoresState>[];
    final sub = cubit.stream.listen(states.add);

    cubit.buscar('Alpha');
    await Future.delayed(Duration.zero);

    expect(states, isNotEmpty);
    final loaded = states.whereType<AdministradoresLoaded>().last;
    expect(loaded.filtrados.length, 1);
    expect(loaded.filtrados[0].nombre, 'Admin Alpha');

    await sub.cancel();
    await cubit.close();
  });

  // ─── CP-FE-AC05: buscar filtra por cédula ─────────────────────────
  test('CP-FE-AC05: buscar filtra por cédula', () async {
    final graphQL = FakeGraphQLService(
      handler: (query, {variables}) async {
        return {'obtenerAdministradores': _adminsJson};
      },
    );
    final repo = AdministradoresRepository(graphQL);
    final cubit = AdministradoresCubit(repo);

    await cubit.cargar();
    await Future.delayed(Duration.zero);

    final states = <AdministradoresState>[];
    final sub = cubit.stream.listen(states.add);

    cubit.buscar('1722250295');
    await Future.delayed(Duration.zero);

    expect(states, isNotEmpty);
    final loaded = states.whereType<AdministradoresLoaded>().last;
    expect(loaded.filtrados.length, 1);
    expect(loaded.filtrados[0].cedula, '1722250295');

    await sub.cancel();
    await cubit.close();
  });

  // ─── CP-FE-AC06: ordenar nombre_desc ──────────────────────────────
  test('CP-FE-AC06: ordenar por nombre_desc invierte el orden', () async {
    final graphQL = FakeGraphQLService(
      handler: (query, {variables}) async {
        return {'obtenerAdministradores': _adminsJson};
      },
    );
    final repo = AdministradoresRepository(graphQL);
    final cubit = AdministradoresCubit(repo);

    await cubit.cargar();
    await Future.delayed(Duration.zero);

    final states = <AdministradoresState>[];
    final sub = cubit.stream.listen(states.add);

    cubit.ordenar('nombre_desc');
    await Future.delayed(Duration.zero);

    expect(states, isNotEmpty);
    final loaded = states.whereType<AdministradoresLoaded>().last;
    expect(loaded.filtrados[0].nombre, 'Admin Gamma');
    expect(loaded.filtrados[2].nombre, 'Admin Alpha');

    await sub.cancel();
    await cubit.close();
  });

  // ─── CP-FE-AC07: ordenar cedula_asc ───────────────────────────────
  test('CP-FE-AC07: ordenar por cedula_asc ordena por cédula', () async {
    final graphQL = FakeGraphQLService(
      handler: (query, {variables}) async {
        return {'obtenerAdministradores': _adminsJson};
      },
    );
    final repo = AdministradoresRepository(graphQL);
    final cubit = AdministradoresCubit(repo);

    await cubit.cargar();
    await Future.delayed(Duration.zero);

    final states = <AdministradoresState>[];
    final sub = cubit.stream.listen(states.add);

    cubit.ordenar('cedula_asc');
    await Future.delayed(Duration.zero);

    expect(states, isNotEmpty);
    final loaded = states.whereType<AdministradoresLoaded>().last;
    expect(loaded.filtrados[0].cedula, '0501234567');
    expect(loaded.filtrados[1].cedula, '1718056490');
    expect(loaded.filtrados[2].cedula, '1722250295');

    await sub.cancel();
    await cubit.close();
  });

  // ─── CP-FE-AC08: crear exitoso ────────────────────────────────────
  test('CP-FE-AC08: crear emite ActionSuccess y recarga la lista', () async {
    final graphQL = FakeGraphQLService(
      handler: (query, {variables}) async {
        if (query.contains('CrearAdministrador')) {
          return {
            'crearAdministrador': {
              'id': '4',
              'cedula': '0102030405',
              'nombre': 'Nuevo Admin',
            }
          };
        }
        return {'obtenerAdministradores': _adminsJson};
      },
    );
    final repo = AdministradoresRepository(graphQL);
    final cubit = AdministradoresCubit(repo);

    await cubit.cargar();
    await Future.delayed(Duration.zero);

    final states = <AdministradoresState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.crear(
      cedula: '0102030405',
      nombre: 'Nuevo Admin',
      email: 'nuevo@test.com',
      password: 'Pass123!',
    );
    await Future.delayed(Duration.zero);

    // Should contain: Loading → ActionSuccess → Loading → Loaded
    expect(states.any((s) => s is AdministradoresActionSuccess), isTrue);
    expect(states.any((s) => s is AdministradoresLoaded), isTrue);

    await sub.cancel();
    await cubit.close();
  });

  // ─── CP-FE-AC09: crear con error ──────────────────────────────────
  test('CP-FE-AC09: crear emite Error y restaura estado previo al fallar', () async {
    int callCount = 0;
    final graphQL = FakeGraphQLService(
      handler: (query, {variables}) async {
        if (query.contains('CrearAdministrador')) {
          throw Exception('Ya existe un administrador con esa cédula');
        }
        return {'obtenerAdministradores': _adminsJson};
      },
    );
    final repo = AdministradoresRepository(graphQL);
    final cubit = AdministradoresCubit(repo);

    await cubit.cargar();
    await Future.delayed(Duration.zero);

    final states = <AdministradoresState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.crear(
      cedula: '1718056490',
      nombre: 'Duplicado',
      email: 'dup@test.com',
      password: 'Pass123!',
    );
    await Future.delayed(Duration.zero);

    // Should contain an Error state
    expect(states.any((s) => s is AdministradoresError), isTrue);
    // Should restore to Loaded state
    expect(states.any((s) => s is AdministradoresLoaded), isTrue);

    await sub.cancel();
    await cubit.close();
  });

  // ─── CP-FE-AC10: actualizar exitoso ───────────────────────────────
  test('CP-FE-AC10: actualizar emite ActionSuccess y recarga', () async {
    final graphQL = FakeGraphQLService(
      handler: (query, {variables}) async {
        if (query.contains('ActualizarAdministrador')) {
          return {
            'actualizarAdministrador': {
              'id': '1',
              'cedula': '1718056490',
              'nombre': 'Admin Actualizado',
            }
          };
        }
        return {'obtenerAdministradores': _adminsJson};
      },
    );
    final repo = AdministradoresRepository(graphQL);
    final cubit = AdministradoresCubit(repo);

    await cubit.cargar();
    await Future.delayed(Duration.zero);

    final states = <AdministradoresState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.actualizar(id: '1', nombre: 'Admin Actualizado');
    await Future.delayed(Duration.zero);

    expect(states.any((s) => s is AdministradoresActionSuccess), isTrue);
    final successState = states.whereType<AdministradoresActionSuccess>().first;
    expect(successState.mensaje, contains('actualizado'));

    await sub.cancel();
    await cubit.close();
  });

  // ─── CP-FE-AC11: actualizar con error ─────────────────────────────
  test('CP-FE-AC11: actualizar emite Error al fallar', () async {
    final graphQL = FakeGraphQLService(
      handler: (query, {variables}) async {
        if (query.contains('ActualizarAdministrador')) {
          throw Exception('Administrador no encontrado');
        }
        return {'obtenerAdministradores': _adminsJson};
      },
    );
    final repo = AdministradoresRepository(graphQL);
    final cubit = AdministradoresCubit(repo);

    await cubit.cargar();
    await Future.delayed(Duration.zero);

    final states = <AdministradoresState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.actualizar(id: '999', nombre: 'No existe');
    await Future.delayed(Duration.zero);

    expect(states.any((s) => s is AdministradoresError), isTrue);

    await sub.cancel();
    await cubit.close();
  });
}
