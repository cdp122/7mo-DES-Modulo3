import '../../domain/entities/dimension.dart';

abstract class PreguntasState {
  const PreguntasState();
}

class PreguntasInitial extends PreguntasState {
  const PreguntasInitial();
}

class PreguntasLoading extends PreguntasState {
  const PreguntasLoading();
}

class PreguntasLoaded extends PreguntasState {
  final List<DimensionEntity> dimensiones;

  const PreguntasLoaded({
    required this.dimensiones,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreguntasLoaded &&
          runtimeType == other.runtimeType &&
          dimensiones == other.dimensiones;

  @override
  int get hashCode => dimensiones.hashCode;
}

class PreguntasError extends PreguntasState {
  final String mensaje;
  const PreguntasError(this.mensaje);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreguntasError &&
          runtimeType == other.runtimeType &&
          mensaje == other.mensaje;

  @override
  int get hashCode => mensaje.hashCode;
}

class PreguntasActionSuccess extends PreguntasState {
  final String mensaje;
  const PreguntasActionSuccess(this.mensaje);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreguntasActionSuccess &&
          runtimeType == other.runtimeType &&
          mensaje == other.mensaje;

  @override
  int get hashCode => mensaje.hashCode;
}
