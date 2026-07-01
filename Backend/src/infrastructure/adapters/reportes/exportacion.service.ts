import ExcelJS from 'exceljs';
import { Evaluacion } from '../../../domain/models/evaluacion.model';
import { Dimension } from '../../../domain/models/dimension.model';
import { CalculosService } from '../../../domain/services/calculos.service';

export class ExportacionService {
  static generarWorkbookEvaluaciones(evaluaciones: Evaluacion[], dimensiones: Dimension[]): ExcelJS.Workbook {
    const enunciadosPorCodigo = new Map<string, string>();
    dimensiones.forEach(d => d.reactivos.forEach(r => enunciadosPorCodigo.set(r.reactivo_codigo, r.enunciado)));

    const workbook = new ExcelJS.Workbook();
    workbook.creator = 'Módulo 3 - Evaluación de Instrumento';
    workbook.created = new Date();

    // ── Hoja 1: Resumen por Docente (datos guardados + niveles cualitativos calculados) ──
    const hojaResumen = workbook.addWorksheet('Resumen por Docente');
    hojaResumen.columns = [
      { header: 'Cédula Docente', key: 'cedula', width: 16 },
      { header: 'Fecha Evaluación', key: 'fecha', width: 20 },
      { header: 'Subtotal D1', key: 'subtotalD1', width: 13 },
      { header: 'Subtotal D2', key: 'subtotalD2', width: 13 },
      { header: 'Subtotal D3', key: 'subtotalD3', width: 13 },
      { header: 'Índice D1 (%)', key: 'indiceD1', width: 14 },
      { header: 'Índice D2 (%)', key: 'indiceD2', width: 14 },
      { header: 'Índice D3 (%)', key: 'indiceD3', width: 14 },
      { header: 'IGPP (%)', key: 'igpp', width: 12 },
      { header: 'Nivel General', key: 'nivelGeneral', width: 26 },
      { header: 'Dimensión Prioritaria', key: 'dimensionPrioritaria', width: 24 },
    ];
    hojaResumen.getRow(1).font = { bold: true };

    evaluaciones.forEach(ev => {
      const interpretado = CalculosService.interpretarResultados(ev, dimensiones);
      hojaResumen.addRow({
        cedula: ev.cedula_docente,
        fecha: ev.fecha_registro,
        subtotalD1: ev.resultados.subtotales.D1,
        subtotalD2: ev.resultados.subtotales.D2,
        subtotalD3: ev.resultados.subtotales.D3,
        indiceD1: Math.round(ev.resultados.indices_dimensionales.ID1 * 100) / 100,
        indiceD2: Math.round(ev.resultados.indices_dimensionales.ID2 * 100) / 100,
        indiceD3: Math.round(ev.resultados.indices_dimensionales.ID3 * 100) / 100,
        igpp: Math.round(ev.resultados.IGPP * 100) / 100,
        nivelGeneral: interpretado.nivel_general,
        dimensionPrioritaria: interpretado.dimension_prioritaria,
      });
    });
    hojaResumen.getColumn('fecha').numFmt = 'dd/mm/yyyy hh:mm';

    // ── Hoja 2: Resumen General / Grupal (promedios calculados en memoria) ──
    const resumenGeneral = CalculosService.calcularResumenGeneral(evaluaciones, dimensiones);
    const hojaGrupal = workbook.addWorksheet('Resumen General (Grupal)');
    hojaGrupal.columns = [
      { header: 'Indicador', key: 'indicador', width: 34 },
      { header: 'Valor', key: 'valor', width: 20 },
    ];
    hojaGrupal.getRow(1).font = { bold: true };
    hojaGrupal.addRows([
      { indicador: 'Total de evaluaciones', valor: resumenGeneral.total_evaluaciones },
      { indicador: 'Promedio IGPP grupal (%)', valor: resumenGeneral.promedio_IGPP },
      { indicador: 'Nivel general grupal', valor: resumenGeneral.nivel_general },
    ]);
    hojaGrupal.addRow({});

    const hojaGrupalDimHeader = hojaGrupal.addRow({
      indicador: 'Dimensión',
      valor: 'Puntaje prom. / Máximo / % / Nivel',
    });
    hojaGrupalDimHeader.font = { bold: true };
    resumenGeneral.dimensiones.forEach(d => {
      hojaGrupal.addRow({
        indicador: d.nombre,
        valor: `${d.puntaje} / ${d.maximo} / ${d.porcentaje}% / ${d.nivel}`,
      });
    });

    const hojaDetalle = workbook.addWorksheet('Respuestas Detalladas');
    hojaDetalle.columns = [
      { header: 'Cédula Docente', key: 'cedula', width: 16 },
      { header: 'Fecha Evaluación', key: 'fecha', width: 20 },
      { header: 'Código Reactivo', key: 'codigo', width: 16 },
      { header: 'Enunciado', key: 'enunciado', width: 70 },
      { header: 'Puntaje (0-4)', key: 'valor', width: 14 },
    ];
    hojaDetalle.getRow(1).font = { bold: true };

    evaluaciones.forEach(ev => {
      ev.respuestas.forEach(r => {
        hojaDetalle.addRow({
          cedula: ev.cedula_docente,
          fecha: ev.fecha_registro,
          codigo: r.reactivo_codigo,
          enunciado: enunciadosPorCodigo.get(r.reactivo_codigo) || '',
          valor: r.valor,
        });
      });
    });
    hojaDetalle.getColumn('fecha').numFmt = 'dd/mm/yyyy hh:mm';

    return workbook;
  }
}
