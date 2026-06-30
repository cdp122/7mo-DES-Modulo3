export interface Respuesta {
  reactivo_codigo: string;
  valor: number;
}

export interface ResultadosEvaluacion {
  subtotales: {
    D1: number;
    D2: number;
    D3: number;
  };
  indices_dimensionales: {
    ID1: number;
    ID2: number;
    ID3: number;
  };
  IGPP: number;
  dimension_prioritaria: string;
}

export interface DatosDocente {
  cedula: string;
  nombre: string;
}

export interface Evaluacion {
  id: string;
  datos_docente: DatosDocente;
  respuestas: Respuesta[];
  resultados: ResultadosEvaluacion;
  version: string;
}

export interface CrearEvaluacionDTO {
  datos_docente: DatosDocente;
  respuestas: Respuesta[];
}

// ── Tipos para la interpretación de resultados ──────────────────

export interface InterpretacionDimension {
  nombre: string;
  clave: string;
  puntaje: number;
  maximo: number;
  porcentaje: number;
  nivel: string;
}

export interface ResultadosInterpretados {
  evaluacion_id: string;
  docente_cedula: string;
  docente_nombre: string;
  dimensiones: InterpretacionDimension[];
  puntaje_total: number;
  maximo_total: number;
  IGPP: number;
  nivel_general: string;
  dimension_prioritaria: string;
}

export interface ResumenGeneral {
  total_evaluaciones: number;
  promedio_D1: number;
  promedio_D2: number;
  promedio_D3: number;
  promedio_IGPP: number;
  nivel_general: string;
  dimensiones: InterpretacionDimension[];
}