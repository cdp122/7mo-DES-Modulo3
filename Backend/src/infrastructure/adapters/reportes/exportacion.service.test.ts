import { describe, it, expect } from 'vitest';
import { ExportacionService } from './exportacion.service';
import { Evaluacion } from '../../../domain/models/evaluacion.model';
import { Dimension } from '../../../domain/models/dimension.model';

// ── Helpers ─────────────────────────────────────────────────────────

const dimensionesTest: Dimension[] = [
  {
    id: 'd1',
    orden: 1,
    nombre: 'Dimensión 1',
    descripcion: 'Desc D1',
    fundamento: 'Fund D1',
    reactivos: [
      { reactivo_codigo: '1.1', enunciado: 'Enunciado 1.1' },
      { reactivo_codigo: '1.2', enunciado: 'Enunciado 1.2' },
      { reactivo_codigo: '1.3', enunciado: 'Enunciado 1.3' },
      { reactivo_codigo: '1.4', enunciado: 'Enunciado 1.4' },
      { reactivo_codigo: '1.5', enunciado: 'Enunciado 1.5' },
    ],
    version: 'V6.7.01',
  },
  {
    id: 'd2',
    orden: 2,
    nombre: 'Dimensión 2',
    descripcion: 'Desc D2',
    fundamento: 'Fund D2',
    reactivos: [
      { reactivo_codigo: '2.1', enunciado: 'Enunciado 2.1' },
      { reactivo_codigo: '2.2', enunciado: 'Enunciado 2.2' },
      { reactivo_codigo: '2.3', enunciado: 'Enunciado 2.3' },
      { reactivo_codigo: '2.4', enunciado: 'Enunciado 2.4' },
      { reactivo_codigo: '2.5', enunciado: 'Enunciado 2.5' },
    ],
    version: 'V6.7.01',
  },
  {
    id: 'd3',
    orden: 3,
    nombre: 'Dimensión 3',
    descripcion: 'Desc D3',
    fundamento: 'Fund D3',
    reactivos: [
      { reactivo_codigo: '3.1', enunciado: 'Enunciado 3.1' },
      { reactivo_codigo: '3.2', enunciado: 'Enunciado 3.2' },
      { reactivo_codigo: '3.3', enunciado: 'Enunciado 3.3' },
      { reactivo_codigo: '3.4', enunciado: 'Enunciado 3.4' },
      { reactivo_codigo: '3.5', enunciado: 'Enunciado 3.5' },
    ],
    version: 'V6.7.01',
  },
];

const crearEvaluacionTest = (cedula: string, valD1: number, valD2: number, valD3: number): Evaluacion => {
  const respuestas = [];
  for (let i = 1; i <= 5; i++) respuestas.push({ reactivo_codigo: `1.${i}`, valor: valD1 });
  for (let i = 1; i <= 5; i++) respuestas.push({ reactivo_codigo: `2.${i}`, valor: valD2 });
  for (let i = 1; i <= 5; i++) respuestas.push({ reactivo_codigo: `3.${i}`, valor: valD3 });

  const subtotalD1 = valD1 * 5;
  const subtotalD2 = valD2 * 5;
  const subtotalD3 = valD3 * 5;
  const total = subtotalD1 + subtotalD2 + subtotalD3;

  return {
    id: `eval-${Math.random().toString(36).slice(2)}`,
    cedula_docente: cedula,
    respuestas,
    comentarios: { compromiso_personal: null, opiniones_programa: null },
    resultados: {
      subtotales: { D1: subtotalD1, D2: subtotalD2, D3: subtotalD3 },
      indices_dimensionales: {
        ID1: (subtotalD1 / 20) * 100,
        ID2: (subtotalD2 / 20) * 100,
        ID3: (subtotalD3 / 20) * 100,
      },
      IGPP: (total / 60) * 100,
      dimension_prioritaria: 'D1',
    },
    version: 'V6.7.01',
    fecha_registro: new Date('2026-07-21T12:00:00Z'),
  };
};

// ─── CP-EX01 a CP-EX05: ExportacionService ──────────────────────────────────

describe('ExportacionService.generarWorkbookEvaluaciones (CP-EX01 a CP-EX05)', () => {
  it('CP-EX01: Genera workbook con exactamente 3 hojas', () => {
    const evaluaciones = [crearEvaluacionTest('1718056490', 3, 3, 3)];
    const workbook = ExportacionService.generarWorkbookEvaluaciones(evaluaciones, dimensionesTest);

    expect(workbook.worksheets).toHaveLength(3);
    expect(workbook.worksheets[0].name).toBe('Resumen por Docente');
    expect(workbook.worksheets[1].name).toBe('Resumen General (Grupal)');
    expect(workbook.worksheets[2].name).toBe('Respuestas Detalladas');
  });

  it('CP-EX02: Hoja "Resumen por Docente" contiene filas de evaluación con subtotales e IGPP', () => {
    const evaluaciones = [crearEvaluacionTest('1718056490', 4, 3, 2)];
    const workbook = ExportacionService.generarWorkbookEvaluaciones(evaluaciones, dimensionesTest);

    const hojaResumen = workbook.getWorksheet('Resumen por Docente')!;
    // Row 1 is header, row 2 is first data row
    expect(hojaResumen.rowCount).toBe(2);
    const fila = hojaResumen.getRow(2);
    expect(fila.getCell('cedula').value).toBe('1718056490');
    expect(fila.getCell('subtotalD1').value).toBe(20); // 4 * 5
    expect(fila.getCell('subtotalD2').value).toBe(15); // 3 * 5
    expect(fila.getCell('subtotalD3').value).toBe(10); // 2 * 5
  });

  it('CP-EX03: Hoja "Resumen General" contiene los promedios grupales', () => {
    const evaluaciones = [
      crearEvaluacionTest('1718056490', 4, 4, 4),
      crearEvaluacionTest('1722250295', 2, 2, 2),
    ];
    const workbook = ExportacionService.generarWorkbookEvaluaciones(evaluaciones, dimensionesTest);

    const hojaGrupal = workbook.getWorksheet('Resumen General (Grupal)')!;
    // Row 1: header, Row 2: total evaluaciones, Row 3: promedio IGPP, Row 4: nivel general
    const totalRow = hojaGrupal.getRow(2);
    expect(totalRow.getCell('indicador').value).toBe('Total de evaluaciones');
    expect(totalRow.getCell('valor').value).toBe(2);
  });

  it('CP-EX04: Con 0 evaluaciones genera workbook vacío sin error', () => {
    const workbook = ExportacionService.generarWorkbookEvaluaciones([], dimensionesTest);

    expect(workbook.worksheets).toHaveLength(3);
    const hojaResumen = workbook.getWorksheet('Resumen por Docente')!;
    expect(hojaResumen.rowCount).toBe(1); // Solo el header
  });

  it('CP-EX05: Hoja "Respuestas Detalladas" lista cada respuesta individual con enunciado', () => {
    const evaluaciones = [crearEvaluacionTest('1718056490', 3, 3, 3)];
    const workbook = ExportacionService.generarWorkbookEvaluaciones(evaluaciones, dimensionesTest);

    const hojaDetalle = workbook.getWorksheet('Respuestas Detalladas')!;
    // 15 respuestas + 1 header row = 16
    expect(hojaDetalle.rowCount).toBe(16);
    const primeraRespuesta = hojaDetalle.getRow(2);
    expect(primeraRespuesta.getCell('cedula').value).toBe('1718056490');
    expect(primeraRespuesta.getCell('codigo').value).toBe('1.1');
    expect(primeraRespuesta.getCell('enunciado').value).toBe('Enunciado 1.1');
    expect(primeraRespuesta.getCell('valor').value).toBe(3);
  });
});
