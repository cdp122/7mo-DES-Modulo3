import '../entities/usuario.dart';
import '../repositories/auth_repository.dart';

class VerificarCedula {
  final AuthRepository repository;

  VerificarCedula(this.repository);

  Future<Usuario> call(String cedula) async {
    if (cedula.trim().isEmpty) {
      throw Exception('La cédula no puede estar vacía');
    }
    return await repository.verificarCedula(cedula);
  }
}
