import '../../../../core/network/graphql_service.dart';
import '../models/usuario_model.dart';

abstract class AuthRemoteDataSource {
  Future<UsuarioModel> verificarCedula(String cedula);
  Future<bool> loginAdministrador(String cedula, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final GraphQLService _graphQLService;

  // JWT guardado en memoria para reutilizarlo si se necesita en llamadas futuras
  String? _token;
  String? get token => _token;

  AuthRemoteDataSourceImpl(this._graphQLService);

  /// Busca en MongoDB si la cédula corresponde a un Administrador o a un Docente.
  /// El backend devuelve el rol implícito: si existe en 'administradores' → admin,
  /// si solo existe en 'evaluaciones' → docente, si no existe → nuevo docente.
  @override
  Future<UsuarioModel> verificarCedula(String cedula) async {
    const query = r'''
      query BuscarAdminPorCedula($cedula: String!) {
        buscarAdminPorCedula(cedula: $cedula) {
          id
          cedula
          nombre
          email
        }
      }
    ''';

    try {
      final data = await _graphQLService.execute(query, variables: {'cedula': cedula});

      if (data.containsKey('buscarAdminPorCedula') && data['buscarAdminPorCedula'] != null) {
        final admin = data['buscarAdminPorCedula'] as Map<String, dynamic>;
        return UsuarioModel(
          id: admin['id'] as String,
          cedula: admin['cedula'] as String,
          nombre: admin['nombre'] as String?,
          rol: 'admin',
        );
      }

      // Si no es admin, se trata como docente (rol regular)
      return UsuarioModel(
        id: cedula,
        cedula: cedula,
        rol: 'regular',
        nombre: null,
      );
    } catch (e) {
      // Si el backend no está disponible o la query falla, relanzamos el error
      throw Exception('No se pudo verificar la cédula: $e');
    }
  }

  /// Llama a la mutación login del backend con el email del administrador y su contraseña.
  /// Nota: el backend usa email como identificador de login.
  /// Como el frontend recibe cédula, primero buscamos el email del admin en el servidor
  /// y luego hacemos login con ese email.
  @override
  Future<bool> loginAdministrador(String cedula, String password) async {
    // Paso 1: obtener el email del admin a partir de su cédula
    const queryEmail = r'''
      query BuscarAdminPorCedula($cedula: String!) {
        buscarAdminPorCedula(cedula: $cedula) {
          email
        }
      }
    ''';

    final dataAdmin = await _graphQLService.execute(queryEmail, variables: {'cedula': cedula});
    final adminData = dataAdmin['buscarAdminPorCedula'] as Map<String, dynamic>?;
    if (adminData == null) throw Exception('Administrador no encontrado');
    final email = adminData['email'] as String;

    // Paso 2: hacer login con email + password
    const mutation = r'''
      mutation Login($input: LoginInput!) {
        login(input: $input) {
          token
          administrador {
            id
            cedula
            nombre
            email
          }
        }
      }
    ''';

    final data = await _graphQLService.execute(
      mutation,
      variables: {
        'input': {'email': email, 'password': password},
      },
    );

    if (data.containsKey('login') && data['login'] != null) {
      final loginPayload = data['login'] as Map<String, dynamic>;
      _token = loginPayload['token'] as String?;
      return _token != null && _token!.isNotEmpty;
    }

    return false;
  }
}

