import '../../domain/entities/dimension.dart';

abstract class DimensionesState {
  const DimensionesState();
}

class DimensionesInitial extends DimensionesState {
  const DimensionesInitial();
}

class DimensionesLoading extends DimensionesState {
  const DimensionesLoading();
}

class DimensionesLoaded extends DimensionesState {
  final List<DimensionEntity> dimensiones;

  const DimensionesLoaded({
    required this.dimensiones,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DimensionesLoaded &&
          runtimeType == other.runtimeType &&
          dimensiones == other.dimensiones;

  @override
  int get hashCode => dimensiones.hashCode;
}

class DimensionesError extends DimensionesState {
  final String mensaje;

  const DimensionesError(this.mensaje);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DimensionesError &&
          runtimeType == other.runtimeType &&
          mensaje == other.mensaje;

  @override
  int get hashCode => mensaje.hashCode;
}

class DimensionActionSuccess extends DimensionesState {
  final String mensaje;

  const DimensionActionSuccess(this.mensaje);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DimensionActionSuccess &&
          runtimeType == other.runtimeType &&
          mensaje == other.mensaje;

  @override
  int get hashCode => mensaje.hashCode;
}
