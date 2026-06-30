export interface Respuesta {
  reactivo_codigo: string;
  valor: number;
}

export interface Comentarios {
  compromiso_personal: string | null;
  opiniones_programa: string | null;
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

export interface Evaluacion {
  id: string;
  cedula_docente: string;
  respuestas: Respuesta[];
  comentarios: Comentarios;
  resultados: ResultadosEvaluacion;
  version: string;
}

export interface CrearEvaluacionDTO {
  cedula_docente: string;
  respuestas: Respuesta[];
}

export interface ComentarEvaluacionDTO {
  compromiso_personal?: string | null;
  opiniones_programa?: string | null;
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