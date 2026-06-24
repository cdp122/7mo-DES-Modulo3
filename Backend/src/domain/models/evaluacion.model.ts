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