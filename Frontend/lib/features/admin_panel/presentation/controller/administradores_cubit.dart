import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/administradores_repository.dart';
import '../../domain/entities/administrador.dart';
import 'administradores_state.dart';

class AdministradoresCubit extends Cubit<AdministradoresState> {
  final AdministradoresRepository _repository;

  AdministradoresCubit(this._repository) : super(const AdministradoresInitial());

  // ── Carga inicial ──────────────────────────────────────────────
  Future<void> cargar() async {
    emit(const AdministradoresLoading());
    try {
      final lista = await _repository.obtenerTodos();
      final filtrados = _aplicarOrden(lista, 'nombre_asc');
      emit(AdministradoresLoaded(todos: lista, filtrados: filtrados));
    } catch (e) {
      emit(AdministradoresError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // ── Búsqueda en memoria ────────────────────────────────────────
  void buscar(String termino) {
    final current = state;
    if (current is! AdministradoresLoaded) return;
    final query = termino.toLowerCase().trim();
    final filtrados = current.todos.where((a) {
      return a.nombre.toLowerCase().contains(query) ||
          a.cedula.toLowerCase().contains(query) ||
          a.email.toLowerCase().contains(query);
    }).toList();
    final ordenados = _aplicarOrden(filtrados, current.ordenamiento);
    emit(current.copyWith(
      filtrados: ordenados,
      busqueda: termino,
    ));
  }

  // ── Ordenamiento en memoria ───────────────────────────────────
  void ordenar(String criterio) {
    final current = state;
    if (current is! AdministradoresLoaded) return;
    final ordenados = _aplicarOrden(current.filtrados, criterio);
    emit(current.copyWith(filtrados: ordenados, ordenamiento: criterio));
  }

  // ── CRUD ───────────────────────────────────────────────────────
  Future<void> crear({
    required String cedula,
    required String nombre,
    required String email,
    required String password,
  }) async {
    final current = state;
    emit(const AdministradoresLoading());
    try {
      await _repository.crear(
        cedula: cedula,
        nombre: nombre,
        email: email,
        password: password,
      );
      emit(const AdministradoresActionSuccess('Administrador creado correctamente.'));
      await cargar();
    } catch (e) {
      emit(AdministradoresError(e.toString().replaceAll('Exception: ', '')));
      if (current is AdministradoresLoaded) emit(current);
    }
  }

  Future<void> actualizar({
    required String id,
    String? nombre,
    String? email,
    String? password,
  }) async {
    final current = state;
    emit(const AdministradoresLoading());
    try {
      await _repository.actualizar(
        id: id,
        nombre: nombre,
        email: email,
        password: password,
      );
      emit(const AdministradoresActionSuccess('Administrador actualizado correctamente.'));
      await cargar();
    } catch (e) {
      emit(AdministradoresError(e.toString().replaceAll('Exception: ', '')));
      if (current is AdministradoresLoaded) emit(current);
    }
  }

  Future<void> cambiarRol({
    required String id,
    required String nuevoRol,
  }) async {
    final current = state;
    emit(const AdministradoresLoading());
    try {
      await _repository.cambiarRol(id: id, nuevoRol: nuevoRol);
      final rolLabel = nuevoRol == 'admin' ? 'Administrador' : 'Docente';
      emit(AdministradoresActionSuccess('Rol cambiado a $rolLabel correctamente.'));
      await cargar();
    } catch (e) {
      emit(AdministradoresError(e.toString().replaceAll('Exception: ', '')));
      if (current is AdministradoresLoaded) emit(current);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────
  List<AdministradorEntity> _aplicarOrden(
      List<AdministradorEntity> lista, String criterio) {
    final copia = List<AdministradorEntity>.from(lista);
    switch (criterio) {
      case 'nombre_asc':
        copia.sort((a, b) => a.nombre.compareTo(b.nombre));
        break;
      case 'nombre_desc':
        copia.sort((a, b) => b.nombre.compareTo(a.nombre));
        break;
      case 'cedula_asc':
        copia.sort((a, b) => a.cedula.compareTo(b.cedula));
        break;
    }
    return copia;
  }
}
