import '../../domain/entities/resultados_evaluacion.dart';

abstract class ResultadosState {
  const ResultadosState();
}

class ResultadosInitial extends ResultadosState {
  const ResultadosInitial();
}

class ResultadosLoading extends ResultadosState {
  const ResultadosLoading();
}

class ResultadosLoaded extends ResultadosState {
  final ResumenGeneralEntity resumen;
  final List<ResultadosInterpretadosEntity> resultadosDocente;

  const ResultadosLoaded({
    required this.resumen,
    this.resultadosDocente = const [],
  });

  ResultadosLoaded copyWith({
    ResumenGeneralEntity? resumen,
    List<ResultadosInterpretadosEntity>? resultadosDocente,
  }) {
    return ResultadosLoaded(
      resumen: resumen ?? this.resumen,
      resultadosDocente: resultadosDocente ?? this.resultadosDocente,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultadosLoaded &&
          runtimeType == other.runtimeType &&
          resumen == other.resumen &&
          resultadosDocente == other.resultadosDocente;

  @override
  int get hashCode => resumen.hashCode ^ resultadosDocente.hashCode;
}

class ResultadosError extends ResultadosState {
  final String mensaje;

  const ResultadosError(this.mensaje);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultadosError &&
          runtimeType == other.runtimeType &&
          mensaje == other.mensaje;

  @override
  int get hashCode => mensaje.hashCode;
}
