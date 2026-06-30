import { Respuesta, ResultadosEvaluacion } from '../models/evaluacion.model';

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

  static mapearNivelCualitativo(igpp: number): string {
    if (igpp >= 90) return 'Participación protagónica';
    if (igpp >= 70) return 'Participación en desarrollo';
    if (igpp >= 50) return 'Participación en consulta';
    if (igpp >= 30) return 'Participación marginal';
    return 'Sin participación';
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