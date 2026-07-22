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

// ─── CP-13 a CP-16: interpretarResultados (sin tests previos) ───────────────

describe('CalculosService.interpretarResultados (CP-13 a CP-16)', () => {
  const crearEvaluacion = (
    subtotales: { D1: number; D2: number; D3: number },
    indices: { ID1: number; ID2: number; ID3: number },
    igpp: number,
    dimensionPrioritaria: string
  ) => ({
    id: 'eval-001',
    cedula_docente: '1718056490',
    respuestas: [],
    comentarios: { compromiso_personal: null, opiniones_programa: null },
    resultados: {
      subtotales,
      indices_dimensionales: indices,
      IGPP: igpp,
      dimension_prioritaria: dimensionPrioritaria,
    },
    version: 'V6.7.01',
    fecha_registro: new Date(),
  });

  it('CP-13: Con dimensiones estándar (5 reactivos), retorna las 3 dimensiones interpretadas con nombre, puntaje, máximo y nivel', () => {
    const dimensiones = dimensionesBD({ d1: 5, d2: 5, d3: 5 });
    const evaluacion = crearEvaluacion(
      { D1: 16, D2: 12, D3: 19 },
      { ID1: 80, ID2: 60, ID3: 95 },
      78.33,
      'D2'
    );

    const resultado = CalculosService.interpretarResultados(evaluacion, dimensiones);

    expect(resultado.evaluacion_id).toBe('eval-001');
    expect(resultado.docente_cedula).toBe('1718056490');
    expect(resultado.dimensiones).toHaveLength(3);
    expect(resultado.dimensiones[0].nombre).toBe('Participación infantil');
    expect(resultado.dimensiones[0].puntaje).toBe(16);
    expect(resultado.dimensiones[0].maximo).toBe(20);
    expect(resultado.dimensiones[1].nombre).toBe('Voz del niño');
    expect(resultado.dimensiones[1].puntaje).toBe(12);
    expect(resultado.puntaje_total).toBe(47);
    expect(resultado.maximo_total).toBe(60);
  });

  it('CP-14: Con dimensiones personalizadas (conteo dinámico de reactivos), los máximos se ajustan', () => {
    const dimensiones = [
      { orden: 1, clave: 'D1', nombre: 'Dim Custom 1', reactivos: Array(3).fill({}) },
      { orden: 2, clave: 'D2', nombre: 'Dim Custom 2', reactivos: Array(4).fill({}) },
      { orden: 3, clave: 'D3', nombre: 'Dim Custom 3', reactivos: Array(6).fill({}) },
    ];
    const evaluacion = crearEvaluacion(
      { D1: 10, D2: 14, D3: 20 },
      { ID1: 83.33, ID2: 87.5, ID3: 83.33 },
      84.62,
      'D1'
    );

    const resultado = CalculosService.interpretarResultados(evaluacion, dimensiones);

    expect(resultado.dimensiones[0].maximo).toBe(12); // 3 * 4
    expect(resultado.dimensiones[1].maximo).toBe(16); // 4 * 4
    expect(resultado.dimensiones[2].maximo).toBe(24); // 6 * 4
    expect(resultado.maximo_total).toBe(52);
    expect(resultado.dimensiones[0].nombre).toBe('Dim Custom 1');
  });

  it('CP-15: Los niveles cualitativos se asignan correctamente por dimensión', () => {
    const dimensiones = dimensionesBD({ d1: 5, d2: 5, d3: 5 });
    const evaluacion = crearEvaluacion(
      { D1: 20, D2: 10, D3: 4 },
      { ID1: 100, ID2: 50, ID3: 20 },
      56.67,
      'D3'
    );

    const resultado = CalculosService.interpretarResultados(evaluacion, dimensiones);

    expect(resultado.dimensiones[0].nivel).toBe('Participación auténtica');    // 100%
    expect(resultado.dimensiones[1].nivel).toBe('Participación incipiente');     // 50%
    expect(resultado.dimensiones[2].nivel).toBe('Planificación adultocéntrica'); // 20%
  });

  it('CP-16: Con dimensión prioritaria D3, el nombre de la dimensión prioritaria se resuelve correctamente', () => {
    const dimensiones = dimensionesBD({ d1: 5, d2: 5, d3: 5 });
    const evaluacion = crearEvaluacion(
      { D1: 18, D2: 16, D3: 8 },
      { ID1: 90, ID2: 80, ID3: 40 },
      70,
      'D3'
    );

    const resultado = CalculosService.interpretarResultados(evaluacion, dimensiones);

    expect(resultado.dimension_prioritaria).toBe('Relación simétrica');
  });
});

// ─── CP-17 a CP-20: calcularResumenGeneral (sin tests previos) ──────────────

describe('CalculosService.calcularResumenGeneral (CP-17 a CP-20)', () => {
  const crearEvaluacionSimple = (d1: number, d2: number, d3: number, igpp: number) => ({
    id: `eval-${Math.random()}`,
    cedula_docente: '1718056490',
    respuestas: [],
    comentarios: { compromiso_personal: null, opiniones_programa: null },
    resultados: {
      subtotales: { D1: d1, D2: d2, D3: d3 },
      indices_dimensionales: { ID1: 0, ID2: 0, ID3: 0 },
      IGPP: igpp,
      dimension_prioritaria: 'D1',
    },
    version: 'V6.7.01',
    fecha_registro: new Date(),
  });

  it('CP-17: Con 0 evaluaciones retorna promedios en 0 y nivel "Planificación adultocéntrica"', () => {
    const resultado = CalculosService.calcularResumenGeneral([]);

    expect(resultado.total_evaluaciones).toBe(0);
    expect(resultado.promedio_D1).toBe(0);
    expect(resultado.promedio_D2).toBe(0);
    expect(resultado.promedio_D3).toBe(0);
    expect(resultado.promedio_IGPP).toBe(0);
    expect(resultado.nivel_general).toBe('Planificación adultocéntrica');
    expect(resultado.dimensiones).toHaveLength(3);
  });

  it('CP-18: Con 1 evaluación, los promedios coinciden con los subtotales de esa evaluación', () => {
    const evaluaciones = [crearEvaluacionSimple(16, 12, 19, 78.33)];
    const dimensiones = dimensionesBD({ d1: 5, d2: 5, d3: 5 });

    const resultado = CalculosService.calcularResumenGeneral(evaluaciones, dimensiones);

    expect(resultado.total_evaluaciones).toBe(1);
    expect(resultado.promedio_D1).toBe(16);
    expect(resultado.promedio_D2).toBe(12);
    expect(resultado.promedio_D3).toBe(19);
    expect(resultado.promedio_IGPP).toBe(78.33);
  });

  it('CP-19: Con múltiples evaluaciones calcula promedios correctamente', () => {
    const evaluaciones = [
      crearEvaluacionSimple(20, 20, 20, 100),
      crearEvaluacionSimple(10, 10, 10, 50),
    ];
    const dimensiones = dimensionesBD({ d1: 5, d2: 5, d3: 5 });

    const resultado = CalculosService.calcularResumenGeneral(evaluaciones, dimensiones);

    expect(resultado.total_evaluaciones).toBe(2);
    expect(resultado.promedio_D1).toBe(15);
    expect(resultado.promedio_D2).toBe(15);
    expect(resultado.promedio_D3).toBe(15);
    expect(resultado.promedio_IGPP).toBe(75);
    expect(resultado.nivel_general).toBe('Participación en desarrollo');
  });

  it('CP-20: Con dimensiones personalizadas, los máximos de las dimensiones se ajustan', () => {
    const evaluaciones = [crearEvaluacionSimple(12, 8, 20, 76.92)];
    const dimensiones = [
      { orden: 1, clave: 'D1', nombre: 'Custom D1', reactivos: Array(4).fill({}) },
      { orden: 2, clave: 'D2', nombre: 'Custom D2', reactivos: Array(3).fill({}) },
      { orden: 3, clave: 'D3', nombre: 'Custom D3', reactivos: Array(6).fill({}) },
    ];

    const resultado = CalculosService.calcularResumenGeneral(evaluaciones, dimensiones);

    expect(resultado.dimensiones[0].maximo).toBe(16); // 4 * 4
    expect(resultado.dimensiones[1].maximo).toBe(12); // 3 * 4
    expect(resultado.dimensiones[2].maximo).toBe(24); // 6 * 4
    expect(resultado.dimensiones[0].nombre).toBe('Custom D1');
  });
});

// ─── CP-21 a CP-24: mapearNivelCualitativo — valores límite adicionales ─────

describe('CalculosService.mapearNivelCualitativo - Valores límite adicionales (CP-21 a CP-24)', () => {
  it('CP-21: 51% (límite inferior de "Participación en desarrollo")', () => {
    expect(CalculosService.mapearNivelCualitativo(51)).toBe('Participación en desarrollo');
  });

  it('CP-22: 26% (límite inferior de "Participación incipiente")', () => {
    expect(CalculosService.mapearNivelCualitativo(26)).toBe('Participación incipiente');
  });

  it('CP-23: 25.99% (justo debajo del límite → "Planificación adultocéntrica")', () => {
    expect(CalculosService.mapearNivelCualitativo(25.99)).toBe('Planificación adultocéntrica');
  });

  it('CP-24: Extremos (0% y 100%)', () => {
    expect(CalculosService.mapearNivelCualitativo(0)).toBe('Planificación adultocéntrica');
    expect(CalculosService.mapearNivelCualitativo(100)).toBe('Participación auténtica');
  });
});

// ─── CP-25 y CP-26: Casos borde (arreglo vacío y división por cero) ─────────

describe('CalculosService - Casos borde (CP-25 y CP-26)', () => {
  it('CP-25: calcularSubtotales con arreglo vacío retorna {D1: 0, D2: 0, D3: 0}', () => {
    const subtotales = CalculosService.calcularSubtotales([]);
    expect(subtotales).toEqual({ D1: 0, D2: 0, D3: 0 });
  });

  it('CP-26: calcularIGPP con máximo total 0 retorna 0 sin dividir por cero', () => {
    const igpp = CalculosService.calcularIGPP({ D1: 10, D2: 5, D3: 8 }, 0);
    expect(igpp).toBe(0);
    expect(Number.isFinite(igpp)).toBe(true);
  });
});
