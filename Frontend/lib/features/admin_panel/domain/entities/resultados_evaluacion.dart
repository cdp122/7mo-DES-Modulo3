class InterpretacionDimensionEntity {
  final String nombre;
  final String clave;
  final double puntaje;
  final double maximo;
  final double porcentaje;
  final String nivel;

  const InterpretacionDimensionEntity({
    required this.nombre,
    required this.clave,
    required this.puntaje,
    required this.maximo,
    required this.porcentaje,
    required this.nivel,
  });

  factory InterpretacionDimensionEntity.fromJson(Map<String, dynamic> json) {
    return InterpretacionDimensionEntity(
      nombre: json['nombre'] as String,
      clave: json['clave'] as String,
      puntaje: (json['puntaje'] as num).toDouble(),
      maximo: (json['maximo'] as num).toDouble(),
      porcentaje: (json['porcentaje'] as num).toDouble(),
      nivel: json['nivel'] as String,
    );
  }
}

class ResultadosInterpretadosEntity {
  final String evaluacionId;
  final String docenteCedula;
  final String docenteNombre;
  final List<InterpretacionDimensionEntity> dimensiones;
  final double puntajeTotal;
  final double maximoTotal;
  final double igpp;
  final String nivelGeneral;
  final String dimensionPrioritaria;

  const ResultadosInterpretadosEntity({
    required this.evaluacionId,
    required this.docenteCedula,
    required this.docenteNombre,
    required this.dimensiones,
    required this.puntajeTotal,
    required this.maximoTotal,
    required this.igpp,
    required this.nivelGeneral,
    required this.dimensionPrioritaria,
  });

  factory ResultadosInterpretadosEntity.fromJson(Map<String, dynamic> json) {
    return ResultadosInterpretadosEntity(
      evaluacionId: json['evaluacion_id'] as String,
      docenteCedula: json['docente_cedula'] as String,
      docenteNombre: json['docente_nombre'] as String,
      dimensiones: (json['dimensiones'] as List<dynamic>)
          .map((d) => InterpretacionDimensionEntity.fromJson(d as Map<String, dynamic>))
          .toList(),
      puntajeTotal: (json['puntaje_total'] as num).toDouble(),
      maximoTotal: (json['maximo_total'] as num).toDouble(),
      igpp: (json['IGPP'] as num).toDouble(),
      nivelGeneral: json['nivel_general'] as String,
      dimensionPrioritaria: json['dimension_prioritaria'] as String,
    );
  }
}

class ResumenGeneralEntity {
  final int totalEvaluaciones;
  final double promedioD1;
  final double promedioD2;
  final double promedioD3;
  final double promedioIGPP;
  final String nivelGeneral;
  final List<InterpretacionDimensionEntity> dimensiones;

  const ResumenGeneralEntity({
    required this.totalEvaluaciones,
    required this.promedioD1,
    required this.promedioD2,
    required this.promedioD3,
    required this.promedioIGPP,
    required this.nivelGeneral,
    required this.dimensiones,
  });

  factory ResumenGeneralEntity.fromJson(Map<String, dynamic> json) {
    return ResumenGeneralEntity(
      totalEvaluaciones: json['total_evaluaciones'] as int,
      promedioD1: (json['promedio_D1'] as num).toDouble(),
      promedioD2: (json['promedio_D2'] as num).toDouble(),
      promedioD3: (json['promedio_D3'] as num).toDouble(),
      promedioIGPP: (json['promedio_IGPP'] as num).toDouble(),
      nivelGeneral: json['nivel_general'] as String,
      dimensiones: (json['dimensiones'] as List<dynamic>)
          .map((d) => InterpretacionDimensionEntity.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}
