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
    _token = null;
    _graphQLService.setToken(null);

    const query = r'''
      query BuscarAdminPorCedula($cedula: CedulaEcuatoriana!) {
        buscarAdminPorCedula(cedula: $cedula) {
          id
          cedula
          nombre
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
      print('DEBUG: verificarCedula error: $e');
      // Si la consulta falla, asumimos que es un docente regular para no bloquear el flujo de la encuesta.
      return UsuarioModel(
        id: cedula,
        cedula: cedula,
        rol: 'regular',
        nombre: null,
      );
    }
  }

  /// Llama a la mutación login del backend con la cédula del administrador y su contraseña.
  @override
  Future<bool> loginAdministrador(String cedula, String password) async {
    const mutation = r'''
      mutation Login($input: LoginInput!) {
        login(input: $input) {
          token
          administrador {
            id
            cedula
            nombre
          }
        }
      }
    ''';

    try {
      final data = await _graphQLService.execute(
        mutation,
        variables: {
          'input': {'cedula': cedula, 'password': password},
        },
      );

      if (data.containsKey('login') && data['login'] != null) {
        final loginPayload = data['login'] as Map<String, dynamic>;
        _token = loginPayload['token'] as String?;
        _graphQLService.setToken(_token);
        return _token != null && _token!.isNotEmpty;
      }
      return false;
    } catch (e) {
      throw Exception('Credenciales inválidas o error de conexión: $e');
    }
  }
}

