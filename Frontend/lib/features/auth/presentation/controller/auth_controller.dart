import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/usecases/verificar_cedula.dart';
import '../../domain/usecases/login_administrador.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthError extends AuthState {
  final String mensaje;
  const AuthError(this.mensaje);
}

class AuthAdminPrompt extends AuthState {
  final Usuario usuario;
  const AuthAdminPrompt(this.usuario);
}

class AuthAdminPasswordPrompt extends AuthState {
  final Usuario usuario;
  const AuthAdminPasswordPrompt(this.usuario);
}

class AuthAuthenticatedAdmin extends AuthState {
  final Usuario usuario;
  const AuthAuthenticatedAdmin(this.usuario);
}

class AuthAuthenticatedUser extends AuthState {
  final Usuario usuario;
  const AuthAuthenticatedUser(this.usuario);
}

class AuthCubit extends Cubit<AuthState> {
  final VerificarCedula verificarCedulaUseCase;
  final LoginAdministrador loginAdministradorUseCase;

  AuthCubit({
    required this.verificarCedulaUseCase,
    required this.loginAdministradorUseCase,
  }) : super(const AuthInitial());

  Future<void> verificarCedula(String cedula) async {
    if (cedula.trim().isEmpty) {
      emit(const AuthError('Por favor ingrese su cédula.'));
      emit(const AuthInitial());
      return;
    }
    
    emit(const AuthLoading());
    try {
      final usuario = await verificarCedulaUseCase(cedula);
      if (usuario.isAdmin) {
        emit(AuthAdminPrompt(usuario));
      } else {
        emit(AuthAuthenticatedUser(usuario));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      emit(const AuthInitial());
    }
  }

  void elegirResponderEncuesta(Usuario usuario) {
    emit(AuthAuthenticatedUser(usuario));
  }

  void elegirAccederPanelAdmin(Usuario usuario) {
    emit(AuthAdminPasswordPrompt(usuario));
  }

  Future<void> verificarContrasena(String cedula, String password) async {
    if (password.trim().isEmpty) {
      emit(const AuthError('La contraseña no puede estar vacía.'));
      return;
    }

    final currentState = state;
    Usuario? currentUser;
    if (currentState is AuthAdminPasswordPrompt) {
      currentUser = currentState.usuario;
    } else if (currentState is AuthError) {
      // If we got an error, we might still have a cached user, but to be safe:
      // Let's assume we can pass it or retrieve it.
    }

    emit(const AuthLoading());
    try {
      final success = await loginAdministradorUseCase(cedula, password);
      if (success) {
        emit(AuthAuthenticatedAdmin(currentUser ?? Usuario(id: '0', cedula: cedula, rol: 'admin')));
      } else {
        emit(const AuthError('Contraseña incorrecta. Inténtelo de nuevo.'));
        if (currentUser != null) {
          emit(AuthAdminPasswordPrompt(currentUser));
        } else {
          emit(const AuthInitial());
        }
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      if (currentUser != null) {
        emit(AuthAdminPasswordPrompt(currentUser));
      } else {
        emit(const AuthInitial());
      }
    }
  }

  void reiniciar() {
    emit(const AuthInitial());
  }
}
