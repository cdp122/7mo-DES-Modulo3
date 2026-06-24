import '../repositories/auth_repository.dart';

class LoginAdministrador {
  final AuthRepository repository;

  LoginAdministrador(this.repository);

  Future<bool> call(String cedula, String password) async {
    if (cedula.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('La cédula y la contraseña son requeridas');
    }
    return await repository.loginAdministrador(cedula, password);
  }
}
