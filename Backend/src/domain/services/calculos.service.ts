import {
  Respuesta,
  ResultadosEvaluacion,
  Evaluacion,
  InterpretacionDimension,
  ResultadosInterpretados,
  ResumenGeneral,
} from '../models/evaluacion.model';

// ── Nombres de las 3 dimensiones del instrumento ────────────────
const NOMBRES_DIMENSIONES: Record<string, string> = {
  D1: 'Participación infantil',
  D2: 'Voz del niño',
  D3: 'Relación simétrica',
};

export class CalculosService {
  static readonly REACTIVOS_POR_DIMENSION = 5;
  static readonly VALOR_MAXIMO = 4;
  static readonly MAXIMO_POR_DIMENSION = CalculosService.REACTIVOS_POR_DIMENSION * CalculosService.VALOR_MAXIMO;
  static readonly MAXIMO_TOTAL = CalculosService.MAXIMO_POR_DIMENSION * 3;

  static calcularSubtotales(respuestas: Respuesta[]): { D1: number; D2: number; D3: number } {
    const subtotales = { D1: 0, D2: 0, D3: 0 };

    respuestas.forEach((respuesta) => {
      const dimension = this.extraerDimension(respuesta.reactivo_codigo);
      if (dimension === 'D1') subtotales.D1 += respuesta.valor;
      else if (dimension === 'D2') subtotales.D2 += respuesta.valor;
      else if (dimension === 'D3') subtotales.D3 += respuesta.valor;
    });

    return subtotales;
  }

  static calcularIndicesDimensionales(subtotales: {
    D1: number;
    D2: number;
    D3: number;
  }): { ID1: number; ID2: number; ID3: number } {
    return {
      ID1: (subtotales.D1 / this.MAXIMO_POR_DIMENSION) * 100,
      ID2: (subtotales.D2 / this.MAXIMO_POR_DIMENSION) * 100,
      ID3: (subtotales.D3 / this.MAXIMO_POR_DIMENSION) * 100,
    };
  }

  static calcularIGPP(subtotales: { D1: number; D2: number; D3: number }): number {
    const total = subtotales.D1 + subtotales.D2 + subtotales.D3;
    return (total / this.MAXIMO_TOTAL) * 100;
  }

  static determinarDimensionPrioritaria(indices: {
    ID1: number;
    ID2: number;
    ID3: number;
  }): string {
    const menorId = Math.min(indices.ID1, indices.ID2, indices.ID3);
    if (menorId === indices.ID1) return 'D1';
    if (menorId === indices.ID2) return 'D2';
    return 'D3';
  }

  /**
   * Rúbrica de interpretación cualitativa.
   * Aplica tanto al IGPP como a cada ID individual.
   */
  static mapearNivelCualitativo(porcentaje: number): string {
    if (porcentaje >= 76) return 'Participación auténtica';
    if (porcentaje >= 51) return 'Participación en desarrollo';
    if (porcentaje >= 26) return 'Participación incipiente';
    return 'Planificación adultocéntrica';
  }

  static calcularResultados(respuestas: Respuesta[]): ResultadosEvaluacion {
    const subtotales = this.calcularSubtotales(respuestas);
    const indices = this.calcularIndicesDimensionales(subtotales);
    const igpp = this.calcularIGPP(subtotales);
    const dimensionPrioritaria = this.determinarDimensionPrioritaria(indices);

    return {
      subtotales,
      indices_dimensionales: indices,
      IGPP: Math.round(igpp * 100) / 100,
      dimension_prioritaria: dimensionPrioritaria,
    };
  }

  // ── Nuevos métodos para métricas interpretadas ──────────────────

  /**
   * Interpreta los resultados de una evaluación individual.
   * Devuelve puntajes, porcentajes y lectura cualitativa por dimensión + global.
   */
  static interpretarResultados(evaluacion: Evaluacion): ResultadosInterpretados {
    const { subtotales, indices_dimensionales, IGPP, dimension_prioritaria } = evaluacion.resultados;

    const dimensiones: InterpretacionDimension[] = [
      {
        nombre: NOMBRES_DIMENSIONES.D1,
        clave: 'D1',
        puntaje: subtotales.D1,
        maximo: this.MAXIMO_POR_DIMENSION,
        porcentaje: Math.round(indices_dimensionales.ID1 * 100) / 100,
        nivel: this.mapearNivelCualitativo(indices_dimensionales.ID1),
      },
      {
        nombre: NOMBRES_DIMENSIONES.D2,
        clave: 'D2',
        puntaje: subtotales.D2,
        maximo: this.MAXIMO_POR_DIMENSION,
        porcentaje: Math.round(indices_dimensionales.ID2 * 100) / 100,
        nivel: this.mapearNivelCualitativo(indices_dimensionales.ID2),
      },
      {
        nombre: NOMBRES_DIMENSIONES.D3,
        clave: 'D3',
        puntaje: subtotales.D3,
        maximo: this.MAXIMO_POR_DIMENSION,
        porcentaje: Math.round(indices_dimensionales.ID3 * 100) / 100,
        nivel: this.mapearNivelCualitativo(indices_dimensionales.ID3),
      },
    ];

    const puntajeTotal = subtotales.D1 + subtotales.D2 + subtotales.D3;

    return {
      evaluacion_id: evaluacion.id,
      docente_cedula: evaluacion.cedula_docente,
      dimensiones,
      puntaje_total: puntajeTotal,
      maximo_total: this.MAXIMO_TOTAL,
      IGPP: Math.round(IGPP * 100) / 100,
      nivel_general: this.mapearNivelCualitativo(IGPP),
      dimension_prioritaria: NOMBRES_DIMENSIONES[dimension_prioritaria] || dimension_prioritaria,
    };
  }

  /**
   * Calcula un resumen general a partir de todas las evaluaciones.
   * Promedia subtotales y porcentajes de manera global.
   */
  static calcularResumenGeneral(evaluaciones: Evaluacion[]): ResumenGeneral {
    const total = evaluaciones.length;

    if (total === 0) {
      return {
        total_evaluaciones: 0,
        promedio_D1: 0,
        promedio_D2: 0,
        promedio_D3: 0,
        promedio_IGPP: 0,
        nivel_general: this.mapearNivelCualitativo(0),
        dimensiones: [
          { nombre: NOMBRES_DIMENSIONES.D1, clave: 'D1', puntaje: 0, maximo: this.MAXIMO_POR_DIMENSION, porcentaje: 0, nivel: this.mapearNivelCualitativo(0) },
          { nombre: NOMBRES_DIMENSIONES.D2, clave: 'D2', puntaje: 0, maximo: this.MAXIMO_POR_DIMENSION, porcentaje: 0, nivel: this.mapearNivelCualitativo(0) },
          { nombre: NOMBRES_DIMENSIONES.D3, clave: 'D3', puntaje: 0, maximo: this.MAXIMO_POR_DIMENSION, porcentaje: 0, nivel: this.mapearNivelCualitativo(0) },
        ],
      };
    }

    let sumaD1 = 0, sumaD2 = 0, sumaD3 = 0, sumaIGPP = 0;

    evaluaciones.forEach((ev) => {
      sumaD1 += ev.resultados.subtotales.D1;
      sumaD2 += ev.resultados.subtotales.D2;
      sumaD3 += ev.resultados.subtotales.D3;
      sumaIGPP += ev.resultados.IGPP;
    });

    const promD1 = sumaD1 / total;
    const promD2 = sumaD2 / total;
    const promD3 = sumaD3 / total;
    const promIGPP = sumaIGPP / total;

    const porcD1 = (promD1 / this.MAXIMO_POR_DIMENSION) * 100;
    const porcD2 = (promD2 / this.MAXIMO_POR_DIMENSION) * 100;
    const porcD3 = (promD3 / this.MAXIMO_POR_DIMENSION) * 100;

    return {
      total_evaluaciones: total,
      promedio_D1: Math.round(promD1 * 100) / 100,
      promedio_D2: Math.round(promD2 * 100) / 100,
      promedio_D3: Math.round(promD3 * 100) / 100,
      promedio_IGPP: Math.round(promIGPP * 100) / 100,
      nivel_general: this.mapearNivelCualitativo(promIGPP),
      dimensiones: [
        {
          nombre: NOMBRES_DIMENSIONES.D1,
          clave: 'D1',
          puntaje: Math.round(promD1 * 100) / 100,
          maximo: this.MAXIMO_POR_DIMENSION,
          porcentaje: Math.round(porcD1 * 100) / 100,
          nivel: this.mapearNivelCualitativo(porcD1),
        },
        {
          nombre: NOMBRES_DIMENSIONES.D2,
          clave: 'D2',
          puntaje: Math.round(promD2 * 100) / 100,
          maximo: this.MAXIMO_POR_DIMENSION,
          porcentaje: Math.round(porcD2 * 100) / 100,
          nivel: this.mapearNivelCualitativo(porcD2),
        },
        {
          nombre: NOMBRES_DIMENSIONES.D3,
          clave: 'D3',
          puntaje: Math.round(promD3 * 100) / 100,
          maximo: this.MAXIMO_POR_DIMENSION,
          porcentaje: Math.round(porcD3 * 100) / 100,
          nivel: this.mapearNivelCualitativo(porcD3),
        },
      ],
    };
  }

  private static extraerDimension(codigoReactivo: string): 'D1' | 'D2' | 'D3' | null {
    // Extrae el número antes del punto (ej. "2.1" -> 2)
    const numero = parseInt(codigoReactivo.split('.')[0], 10);
    
    // Asigna la dimensión según el número extraído
    if (numero === 1) return 'D1';
    if (numero === 2) return 'D2';
    if (numero === 3) return 'D3';
    
    return null;
  }
}