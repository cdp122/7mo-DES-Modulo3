import '../../domain/entities/administrador.dart';

abstract class AdministradoresState {
  const AdministradoresState();
}

class AdministradoresInitial extends AdministradoresState {
  const AdministradoresInitial();
}

class AdministradoresLoading extends AdministradoresState {
  const AdministradoresLoading();
}

class AdministradoresLoaded extends AdministradoresState {
  final List<AdministradorEntity> todos;
  final List<AdministradorEntity> filtrados;
  final String busqueda;
  final String ordenamiento; // 'nombre_asc' | 'nombre_desc' | 'cedula_asc'

  const AdministradoresLoaded({
    required this.todos,
    required this.filtrados,
    this.busqueda = '',
    this.ordenamiento = 'nombre_asc',
  });

  AdministradoresLoaded copyWith({
    List<AdministradorEntity>? todos,
    List<AdministradorEntity>? filtrados,
    String? busqueda,
    String? ordenamiento,
  }) {
    return AdministradoresLoaded(
      todos: todos ?? this.todos,
      filtrados: filtrados ?? this.filtrados,
      busqueda: busqueda ?? this.busqueda,
      ordenamiento: ordenamiento ?? this.ordenamiento,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdministradoresLoaded &&
          runtimeType == other.runtimeType &&
          todos == other.todos &&
          busqueda == other.busqueda &&
          ordenamiento == other.ordenamiento;

  @override
  int get hashCode => todos.hashCode ^ busqueda.hashCode ^ ordenamiento.hashCode;
}

class AdministradoresActionSuccess extends AdministradoresState {
  final String mensaje;
  const AdministradoresActionSuccess(this.mensaje);
}

class AdministradoresError extends AdministradoresState {
  final String mensaje;
  const AdministradoresError(this.mensaje);
}
