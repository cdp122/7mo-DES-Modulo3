import '../models/usuario_model.dart';

abstract class AuthRemoteDataSource {
  Future<UsuarioModel> verificarCedula(String cedula);
  Future<bool> loginAdministrador(String cedula, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // Mock users
  final Map<String, UsuarioModel> _mockUsuarios = {
    '123456': const UsuarioModel(id: '1', cedula: '123456', rol: 'admin', nombre: 'Admin Mateo'),
    '654321': const UsuarioModel(id: '2', cedula: '654321', rol: 'regular', nombre: 'Juan Pérez'),
  };

  @override
  Future<UsuarioModel> verificarCedula(String cedula) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 800));

    if (_mockUsuarios.containsKey(cedula)) {
      return _mockUsuarios[cedula]!;
    } else {
      // By default, if it starts with '99', make it admin. Otherwise, treat as regular user.
      if (cedula.startsWith('99')) {
        return UsuarioModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          cedula: cedula,
          rol: 'admin',
          nombre: 'Admin Mock ($cedula)',
        );
      } else {
        return UsuarioModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          cedula: cedula,
          rol: 'regular',
          nombre: 'Usuario ($cedula)',
        );
      }
    }
  }

  @override
  Future<bool> loginAdministrador(String cedula, String password) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 800));

    if (cedula == '123456') {
      return password == 'admin123';
    }
    // For other admins (like those starting with 99)
    return password == 'admin';
  }
}
