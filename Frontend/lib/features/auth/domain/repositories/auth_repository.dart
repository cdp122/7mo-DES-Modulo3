import '../entities/usuario.dart';

abstract class AuthRepository {
  Future<Usuario> verificarCedula(String cedula);
  Future<bool> loginAdministrador(String cedula, String password);
}
