import { describe, it, expect } from 'vitest';
import { CalculosService } from './calculos.service';
import { Respuesta } from '../models/evaluacion.model';

// ─── Helpers de datos ───────────────────────────────────────────────

/** Genera las 15 respuestas (5 por dimensión) con un valor fijo por dimensión. */
const respuestas15 = (valorD1: number, valorD2: number, valorD3: number): Respuesta[] => {
  const respuestas: Respuesta[] = [];
  for (let i = 1; i <= 5; i++) respuestas.push({ reactivo_codigo: `1.${i}`, valor: valorD1 });
  for (let i = 1; i <= 5; i++) respuestas.push({ reactivo_codigo: `2.${i}`, valor: valorD2 });
  for (let i = 1; i <= 5; i++) respuestas.push({ reactivo_codigo: `3.${i}`, valor: valorD3 });
  return respuestas;
};

const dimensionesBD = (reactivosPorDimension: { d1: number; d2: number; d3: number }) => [
  { orden: 1, clave: 'D1', nombre: 'Participación infantil', reactivos: Array(reactivosPorDimension.d1).fill({}) },
  { orden: 2, clave: 'D2', nombre: 'Voz del niño', reactivos: Array(reactivosPorDimension.d2).fill({}) },
  { orden: 3, clave: 'D3', nombre: 'Relación simétrica', reactivos: Array(reactivosPorDimension.d3).fill({}) },
];

// ─── CP-01 y CP-02: calcularSubtotales (caja negra: clasificación por código de reactivo) ───

describe('CalculosService.calcularSubtotales - Clasificación por dimensión (CP-01 y CP-02)', () => {
  it('CP-01: Debe sumar únicamente los reactivos "2.x" en el subtotal D2 (Voz del niño)', () => {
    const respuestas: Respuesta[] = [
      { reactivo_codigo: '1.1', valor: 4 },
      { reactivo_codigo: '2.1', valor: 3 },
      { reactivo_codigo: '2.2', valor: 2 },
      { reactivo_codigo: '2.3', valor: 3 },
      { reactivo_codigo: '2.4', valor: 2 },
      { reactivo_codigo: '2.5', valor: 3 },
      { reactivo_codigo: '3.1', valor: 4 },
    ];

    const subtotales = CalculosService.calcularSubtotales(respuestas);

    expect(subtotales.D2).toBe(13); // 3+2+3+2+3
    expect(subtotales.D1).toBe(4);
    expect(subtotales.D3).toBe(4);
  });

  it('CP-02: Un reactivo con código de dimensión no reconocido (ej. "4.1") no se contabiliza en ningún subtotal', () => {
    const respuestas: Respuesta[] = [
      { reactivo_codigo: '2.1', valor: 3 },
      { reactivo_codigo: '4.1', valor: 4 }, // dimensión inexistente
    ];

    const subtotales = CalculosService.calcularSubtotales(respuestas);

    expect(subtotales).toEqual({ D1: 0, D2: 3, D3: 0 });
  });
});

// ─── CP-03 y CP-04: calcularIndicesDimensionales (caja blanca: rama de división por cero) ───

describe('CalculosService.calcularIndicesDimensionales - Índice ID2 (CP-03 y CP-04)', () => {
  it('CP-03: ID2 = (subtotal D2 / máximo por defecto 20) * 100', () => {
    const indices = CalculosService.calcularIndicesDimensionales({ D1: 16, D2: 12, D3: 17 });

    expect(indices.ID2).toBe(60);
  });

  it('CP-04: Dimensión 2 sin reactivos (máximo = 0) retorna ID2 = 0 sin dividir por cero', () => {
    const indices = CalculosService.calcularIndicesDimensionales({ D1: 16, D2: 0, D3: 17 }, 20, 0, 20);

    expect(indices.ID2).toBe(0);
    expect(Number.isFinite(indices.ID2)).toBe(true);
  });
});

// ─── CP-05: calcularIGPP ────────────────────────────────────────────

describe('CalculosService.calcularIGPP (CP-05)', () => {
  it('CP-05: IGPP = (suma de los 3 subtotales / máximo total) * 100, redondeado a 2 decimales', () => {
    const igpp = CalculosService.calcularIGPP({ D1: 16, D2: 12, D3: 19 }, 60);

    expect(igpp).toBeCloseTo(78.33, 2);
  });
});

// ─── CP-06 y CP-07: determinarDimensionPrioritaria (caja blanca: 2 nodos de decisión) ────

describe('CalculosService.determinarDimensionPrioritaria (CP-06 y CP-07)', () => {
  it('CP-06: Cuando D2 (Voz del niño) tiene el menor índice, la dimensión prioritaria es "D2"', () => {
    const prioritaria = CalculosService.determinarDimensionPrioritaria({ ID1: 80, ID2: 60, ID3: 95 });

    expect(prioritaria).toBe('D2');
  });

  it('CP-07: En caso de empate entre D1 y D2 como menor índice, se prioriza D1 (desempate por orden de evaluación)', () => {
    const prioritaria = CalculosService.determinarDimensionPrioritaria({ ID1: 50, ID2: 50, ID3: 90 });

    expect(prioritaria).toBe('D1');
  });
});

// ─── CP-08 y CP-09: mapearNivelCualitativo (caja negra: valores límite del baremo) ───

describe('CalculosService.mapearNivelCualitativo - Valores límite (CP-08 y CP-09)', () => {
  it('CP-08: 76% (límite inferior de la clase) mapea a "Participación auténtica"', () => {
    expect(CalculosService.mapearNivelCualitativo(76)).toBe('Participación auténtica');
  });

  it('CP-09: 75.99% (justo debajo del límite) mapea a "Participación en desarrollo"', () => {
    expect(CalculosService.mapearNivelCualitativo(75.99)).toBe('Participación en desarrollo');
  });
});

// ─── CP-10 a CP-12: calcularResultados (caja blanca: caminos base P1, P4 y camino integrador) ──

describe('CalculosService.calcularResultados - Caminos base (CP-10 a CP-12)', () => {
  it('CP-10 (camino P1): Sin parámetro "dimensiones", usa el conteo por defecto de 5 reactivos por dimensión', () => {
    const resultado = CalculosService.calcularResultados(respuestas15(4, 3, 4));

    // maximo por dimension = 5 reactivos x 4 = 20 (valor por defecto, sin consultar "dimensiones")
    expect(resultado.indices_dimensionales.ID2).toBe(75); // (15/20)*100
  });

  it('CP-11 (camino P4, "mi módulo"): Solo la Dimensión 2 existe en "dimensiones" con 4 reactivos en vez de 5', () => {
    const dimensiones = [
      { orden: 2, clave: 'D2', nombre: 'Voz del niño', reactivos: Array(4).fill({}) },
    ];
    // 4 respuestas de D2 (2.1 a 2.4) con valor 4, D1 y D3 con las 5 respuestas por defecto
    const respuestas: Respuesta[] = [
      ...['1.1', '1.2', '1.3', '1.4', '1.5'].map((c) => ({ reactivo_codigo: c, valor: 3 })),
      ...['2.1', '2.2', '2.3', '2.4'].map((c) => ({ reactivo_codigo: c, valor: 4 })),
      ...['3.1', '3.2', '3.3', '3.4', '3.5'].map((c) => ({ reactivo_codigo: c, valor: 3 })),
    ];

    const resultado = CalculosService.calcularResultados(respuestas, dimensiones);

    // maximo D2 = 4 reactivos x 4 = 16 (ajustado dinámicamente, NO el default de 20)
    expect(resultado.subtotales.D2).toBe(16);
    expect(resultado.indices_dimensionales.ID2).toBe(100);
    // D1 y D3 no estaban en "dimensiones" -> usan el conteo por defecto (5 reactivos, máximo 20)
    expect(resultado.indices_dimensionales.ID1).toBe(75); // (15/20)*100
  });

  it('CP-12 (camino integrador, reproduce la evidencia real de ejecución): D2 más bajo que D1 y D3 -> dimensión prioritaria "D2"', () => {
    const dimensiones = dimensionesBD({ d1: 5, d2: 5, d3: 5 });
    // Perfil equivalente al capturado en la evidencia de ejecución: D1=16/20 (80%), D2=12/20 (60%), D3=19/20 (95%)
    const respuestas: Respuesta[] = [
      { reactivo_codigo: '1.1', valor: 4 }, { reactivo_codigo: '1.2', valor: 3 }, { reactivo_codigo: '1.3', valor: 3 },
      { reactivo_codigo: '1.4', valor: 3 }, { reactivo_codigo: '1.5', valor: 3 },
      { reactivo_codigo: '2.1', valor: 3 }, { reactivo_codigo: '2.2', valor: 2 }, { reactivo_codigo: '2.3', valor: 2 },
      { reactivo_codigo: '2.4', valor: 2 }, { reactivo_codigo: '2.5', valor: 3 },
      { reactivo_codigo: '3.1', valor: 4 }, { reactivo_codigo: '3.2', valor: 4 }, { reactivo_codigo: '3.3', valor: 4 },
      { reactivo_codigo: '3.4', valor: 4 }, { reactivo_codigo: '3.5', valor: 3 },
    ];

    const resultado = CalculosService.calcularResultados(respuestas, dimensiones);

    expect(resultado.dimension_prioritaria).toBe('D2');
    expect(resultado.indices_dimensionales.ID2).toBeLessThan(resultado.indices_dimensionales.ID1);
    expect(resultado.indices_dimensionales.ID2).toBeLessThan(resultado.indices_dimensionales.ID3);
  });
});
