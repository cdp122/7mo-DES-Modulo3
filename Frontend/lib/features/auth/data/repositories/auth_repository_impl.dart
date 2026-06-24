import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Usuario> verificarCedula(String cedula) async {
    try {
      return await remoteDataSource.verificarCedula(cedula);
    } catch (e) {
      throw Exception('Error de conexión al verificar cédula: $e');
    }
  }

  @override
  Future<bool> loginAdministrador(String cedula, String password) async {
    try {
      return await remoteDataSource.loginAdministrador(cedula, password);
    } catch (e) {
      throw Exception('Error de conexión al verificar contraseña: $e');
    }
  }
}
