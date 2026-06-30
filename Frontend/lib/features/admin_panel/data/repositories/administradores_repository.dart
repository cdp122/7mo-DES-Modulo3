import '../../../../core/network/graphql_service.dart';
import '../../domain/entities/administrador.dart';

class AdministradoresRepository {
  final GraphQLService _graphQLService;

  AdministradoresRepository(this._graphQLService);

  static const _fields = '''
    id
    cedula
    nombre
    email
    rol
  ''';

  Future<List<AdministradorEntity>> obtenerTodos() async {
    const query = '''
      query {
        obtenerAdministradores {
          $_fields
        }
      }
    ''';
    final data = await _graphQLService.execute(query);
    if (data.containsKey('obtenerAdministradores')) {
      final list = data['obtenerAdministradores'] as List;
      return list
          .map((e) => AdministradorEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al obtener administradores');
  }

  Future<AdministradorEntity> crear({
    required String cedula,
    required String nombre,
    required String email,
    required String password,
  }) async {
    const mutation = '''
      mutation CrearAdministrador(\$input: CrearAdministradorInput!) {
        crearAdministrador(input: \$input) {
          $_fields
        }
      }
    ''';
    final data = await _graphQLService.execute(mutation, variables: {
      'input': {
        'cedula': cedula,
        'nombre': nombre,
        'email': email,
        'password': password,
      }
    });
    if (data.containsKey('crearAdministrador')) {
      return AdministradorEntity.fromJson(
          data['crearAdministrador'] as Map<String, dynamic>);
    }
    throw Exception('Error al crear administrador');
  }

  Future<AdministradorEntity> actualizar({
    required String id,
    String? nombre,
    String? email,
    String? password,
  }) async {
    final input = <String, dynamic>{};
    if (nombre != null) input['nombre'] = nombre;
    if (email != null) input['email'] = email;
    if (password != null && password.isNotEmpty) input['password'] = password;

    const mutation = '''
      mutation ActualizarAdministrador(\$id: ID!, \$input: ActualizarAdministradorInput!) {
        actualizarAdministrador(id: \$id, input: \$input) {
          $_fields
        }
      }
    ''';
    final data = await _graphQLService
        .execute(mutation, variables: {'id': id, 'input': input});
    if (data.containsKey('actualizarAdministrador')) {
      return AdministradorEntity.fromJson(
          data['actualizarAdministrador'] as Map<String, dynamic>);
    }
    throw Exception('Error al actualizar administrador');
  }

  Future<AdministradorEntity> cambiarRol({
    required String id,
    required String nuevoRol,
  }) async {
    const mutation = '''
      mutation CambiarRolAdministrador(\$id: ID!, \$nuevoRol: String!) {
        cambiarRolAdministrador(id: \$id, nuevoRol: \$nuevoRol) {
          $_fields
        }
      }
    ''';
    final data = await _graphQLService
        .execute(mutation, variables: {'id': id, 'nuevoRol': nuevoRol});
    if (data.containsKey('cambiarRolAdministrador')) {
      return AdministradorEntity.fromJson(
          data['cambiarRolAdministrador'] as Map<String, dynamic>);
    }
    throw Exception('Error al cambiar rol');
  }
}
