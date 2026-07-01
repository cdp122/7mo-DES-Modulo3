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

  static calcularIndicesDimensionales(
    subtotales: { D1: number; D2: number; D3: number },
    maximoD1 = CalculosService.MAXIMO_POR_DIMENSION,
    maximoD2 = CalculosService.MAXIMO_POR_DIMENSION,
    maximoD3 = CalculosService.MAXIMO_POR_DIMENSION
  ): { ID1: number; ID2: number; ID3: number } {
    return {
      ID1: maximoD1 > 0 ? (subtotales.D1 / maximoD1) * 100 : 0,
      ID2: maximoD2 > 0 ? (subtotales.D2 / maximoD2) * 100 : 0,
      ID3: maximoD3 > 0 ? (subtotales.D3 / maximoD3) * 100 : 0,
    };
  }

  static calcularIGPP(
    subtotales: { D1: number; D2: number; D3: number },
    maximoTotal = CalculosService.MAXIMO_TOTAL
  ): number {
    const total = subtotales.D1 + subtotales.D2 + subtotales.D3;
    return maximoTotal > 0 ? (total / maximoTotal) * 100 : 0;
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

  static mapearNivelCualitativo(porcentaje: number): string {
    if (porcentaje >= 76) return 'Participación auténtica';
    if (porcentaje >= 51) return 'Participación en desarrollo';
    if (porcentaje >= 26) return 'Participación incipiente';
    return 'Planificación adultocéntrica';
  }

  static calcularResultados(respuestas: Respuesta[], dimensiones?: any[]): ResultadosEvaluacion {
    let countD1 = 5;
    let countD2 = 5;
    let countD3 = 5;

    if (dimensiones && dimensiones.length > 0) {
      const d1Obj = dimensiones.find(d => d.orden === 1 || d.clave === 'D1');
      const d2Obj = dimensiones.find(d => d.orden === 2 || d.clave === 'D2');
      const d3Obj = dimensiones.find(d => d.orden === 3 || d.clave === 'D3');

      if (d1Obj) countD1 = d1Obj.reactivos.length;
      if (d2Obj) countD2 = d2Obj.reactivos.length;
      if (d3Obj) countD3 = d3Obj.reactivos.length;
    }

    const maxD1 = countD1 * this.VALOR_MAXIMO;
    const maxD2 = countD2 * this.VALOR_MAXIMO;
    const maxD3 = countD3 * this.VALOR_MAXIMO;
    const maxTotal = maxD1 + maxD2 + maxD3;

    const subtotales = this.calcularSubtotales(respuestas);
    const indices = this.calcularIndicesDimensionales(subtotales, maxD1, maxD2, maxD3);
    const igpp = this.calcularIGPP(subtotales, maxTotal);
    const dimensionPrioritaria = this.determinarDimensionPrioritaria(indices);

    return {
      subtotales,
      indices_dimensionales: indices,
      IGPP: Math.round(igpp * 100) / 100,
      dimension_prioritaria: dimensionPrioritaria,
    };
  }

  static interpretarResultados(evaluacion: Evaluacion, dimensiones?: any[]): ResultadosInterpretados {
    const { subtotales, indices_dimensionales, IGPP, dimension_prioritaria } = evaluacion.resultados;

    let countD1 = 5;
    let countD2 = 5;
    let countD3 = 5;
    let nameD1 = NOMBRES_DIMENSIONES.D1;
    let nameD2 = NOMBRES_DIMENSIONES.D2;
    let nameD3 = NOMBRES_DIMENSIONES.D3;

    if (dimensiones && dimensiones.length > 0) {
      const d1Obj = dimensiones.find(d => d.orden === 1 || d.clave === 'D1');
      const d2Obj = dimensiones.find(d => d.orden === 2 || d.clave === 'D2');
      const d3Obj = dimensiones.find(d => d.orden === 3 || d.clave === 'D3');

      if (d1Obj) {
        countD1 = d1Obj.reactivos.length;
        nameD1 = d1Obj.nombre;
      }
      if (d2Obj) {
        countD2 = d2Obj.reactivos.length;
        nameD2 = d2Obj.nombre;
      }
      if (d3Obj) {
        countD3 = d3Obj.reactivos.length;
        nameD3 = d3Obj.nombre;
      }
    }

    const maxD1 = countD1 * this.VALOR_MAXIMO;
    const maxD2 = countD2 * this.VALOR_MAXIMO;
    const maxD3 = countD3 * this.VALOR_MAXIMO;
    const maxTotal = maxD1 + maxD2 + maxD3;

    const dimensionesInterpretadas: InterpretacionDimension[] = [
      {
        nombre: nameD1,
        clave: 'D1',
        puntaje: subtotales.D1,
        maximo: maxD1,
        porcentaje: Math.round(indices_dimensionales.ID1 * 100) / 100,
        nivel: this.mapearNivelCualitativo(indices_dimensionales.ID1),
      },
      {
        nombre: nameD2,
        clave: 'D2',
        puntaje: subtotales.D2,
        maximo: maxD2,
        porcentaje: Math.round(indices_dimensionales.ID2 * 100) / 100,
        nivel: this.mapearNivelCualitativo(indices_dimensionales.ID2),
      },
      {
        nombre: nameD3,
        clave: 'D3',
        puntaje: subtotales.D3,
        maximo: maxD3,
        porcentaje: Math.round(indices_dimensionales.ID3 * 100) / 100,
        nivel: this.mapearNivelCualitativo(indices_dimensionales.ID3),
      },
    ];

    const puntajeTotal = subtotales.D1 + subtotales.D2 + subtotales.D3;

    const nombrePrioritaria = 
      dimension_prioritaria === 'D1' ? nameD1 :
      dimension_prioritaria === 'D2' ? nameD2 :
      dimension_prioritaria === 'D3' ? nameD3 :
      (NOMBRES_DIMENSIONES[dimension_prioritaria] || dimension_prioritaria);

    return {
      evaluacion_id: evaluacion.id,
      docente_cedula: evaluacion.cedula_docente,
      dimensiones: dimensionesInterpretadas,
      puntaje_total: puntajeTotal,
      maximo_total: maxTotal,
      IGPP: Math.round(IGPP * 100) / 100,
      nivel_general: this.mapearNivelCualitativo(IGPP),
      dimension_prioritaria: nombrePrioritaria,
    };
  }

  static calcularResumenGeneral(evaluaciones: Evaluacion[], dimensiones?: any[]): ResumenGeneral {
    const total = evaluaciones.length;

    let countD1 = 5;
    let countD2 = 5;
    let countD3 = 5;
    let nameD1 = NOMBRES_DIMENSIONES.D1;
    let nameD2 = NOMBRES_DIMENSIONES.D2;
    let nameD3 = NOMBRES_DIMENSIONES.D3;

    if (dimensiones && dimensiones.length > 0) {
      const d1Obj = dimensiones.find(d => d.orden === 1 || d.clave === 'D1');
      const d2Obj = dimensiones.find(d => d.orden === 2 || d.clave === 'D2');
      const d3Obj = dimensiones.find(d => d.orden === 3 || d.clave === 'D3');

      if (d1Obj) {
        countD1 = d1Obj.reactivos.length;
        nameD1 = d1Obj.nombre;
      }
      if (d2Obj) {
        countD2 = d2Obj.reactivos.length;
        nameD2 = d2Obj.nombre;
      }
      if (d3Obj) {
        countD3 = d3Obj.reactivos.length;
        nameD3 = d3Obj.nombre;
      }
    }

    const maxD1 = countD1 * this.VALOR_MAXIMO;
    const maxD2 = countD2 * this.VALOR_MAXIMO;
    const maxD3 = countD3 * this.VALOR_MAXIMO;
    const maxTotal = maxD1 + maxD2 + maxD3;

    if (total === 0) {
      return {
        total_evaluaciones: 0,
        promedio_D1: 0,
        promedio_D2: 0,
        promedio_D3: 0,
        promedio_IGPP: 0,
        nivel_general: this.mapearNivelCualitativo(0),
        dimensiones: [
          { nombre: nameD1, clave: 'D1', puntaje: 0, maximo: maxD1, porcentaje: 0, nivel: this.mapearNivelCualitativo(0) },
          { nombre: nameD2, clave: 'D2', puntaje: 0, maximo: maxD2, porcentaje: 0, nivel: this.mapearNivelCualitativo(0) },
          { nombre: nameD3, clave: 'D3', puntaje: 0, maximo: maxD3, porcentaje: 0, nivel: this.mapearNivelCualitativo(0) },
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

    const porcD1 = maxD1 > 0 ? (promD1 / maxD1) * 100 : 0;
    const porcD2 = maxD2 > 0 ? (promD2 / maxD2) * 100 : 0;
    const porcD3 = maxD3 > 0 ? (promD3 / maxD3) * 100 : 0;

    return {
      total_evaluaciones: total,
      promedio_D1: Math.round(promD1 * 100) / 100,
      promedio_D2: Math.round(promD2 * 100) / 100,
      promedio_D3: Math.round(promD3 * 100) / 100,
      promedio_IGPP: Math.round(promIGPP * 100) / 100,
      nivel_general: this.mapearNivelCualitativo(promIGPP),
      dimensiones: [
        {
          nombre: nameD1,
          clave: 'D1',
          puntaje: Math.round(promD1 * 100) / 100,
          maximo: maxD1,
          porcentaje: Math.round(porcD1 * 100) / 100,
          nivel: this.mapearNivelCualitativo(porcD1),
        },
        {
          nombre: nameD2,
          clave: 'D2',
          puntaje: Math.round(promD2 * 100) / 100,
          maximo: maxD2,
          porcentaje: Math.round(porcD2 * 100) / 100,
          nivel: this.mapearNivelCualitativo(porcD2),
        },
        {
          nombre: nameD3,
          clave: 'D3',
          puntaje: Math.round(promD3 * 100) / 100,
          maximo: maxD3,
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