import { IEvaluacionRepository } from '../../../../../domain/repositories/evaluacion.repository.port';
import { Evaluacion, CrearEvaluacionDTO, ResultadosEvaluacion } from '../../../../../domain/models/evaluacion.model';
import { EvaluacionModel, IEvaluacionDocument } from '../models/evaluacion.schema';

export class EvaluacionRepository implements IEvaluacionRepository {
  async crear(evaluacion: CrearEvaluacionDTO, resultados: ResultadosEvaluacion): Promise<Evaluacion> {
    const doc = new EvaluacionModel({
      datos_docente: evaluacion.datos_docente,
      respuestas: evaluacion.respuestas,
      resultados
    });
    const guardado = await doc.save();
    const resultado = this.mapearADominio(guardado);
    if (!resultado) throw new Error('Error al crear evaluación');
    return resultado;
  }

  async obtenerPorId(id: string): Promise<Evaluacion | null> {
    const doc = await EvaluacionModel.findById(id);
    return this.mapearADominio(doc);
  }

  async obtenerPorDocenteCedula(cedula: string): Promise<Evaluacion[]> {
    const docs = await EvaluacionModel.find({ 'datos_docente.cedula': cedula });
    return docs.map(doc => this.mapearADominio(doc)).filter((e): e is Evaluacion => e !== null);
  }

  async obtenerTodas(): Promise<Evaluacion[]> {
    const docs = await EvaluacionModel.find();
    return docs.map(doc => this.mapearADominio(doc)).filter((e): e is Evaluacion => e !== null);
  }

  async obtenerPromediosDimensionales(): Promise<{
    D1: number;
    D2: number;
    D3: number;
    IGPP: number;
  }> {
    const resultado = await EvaluacionModel.aggregate([
      {
        $group: {
          _id: null,
          promedioD1: { $avg: '$resultados.subtotales.D1' },
          promedioD2: { $avg: '$resultados.subtotales.D2' },
          promedioD3: { $avg: '$resultados.subtotales.D3' },
          promedioIGPP: { $avg: '$resultados.IGPP' }
        }
      }
    ]);

    if (resultado.length === 0) {
      return { D1: 0, D2: 0, D3: 0, IGPP: 0 };
    }

    return {
      D1: Math.round((resultado[0].promedioD1 || 0) * 100) / 100,
      D2: Math.round((resultado[0].promedioD2 || 0) * 100) / 100,
      D3: Math.round((resultado[0].promedioD3 || 0) * 100) / 100,
      IGPP: Math.round((resultado[0].promedioIGPP || 0) * 100) / 100
    };
  }

  private mapearADominio(doc: IEvaluacionDocument | null): Evaluacion | null {
    if (!doc) return null;
    return {
      id: doc._id.toString(),
      datos_docente: {
        cedula: doc.datos_docente.cedula,
        nombre: doc.datos_docente.nombre
      },
      respuestas: doc.respuestas.map(r => ({
        reactivo_codigo: r.reactivo_codigo,
        valor: r.valor
      })),
      resultados: {
        subtotales: {
          D1: doc.resultados.subtotales.D1,
          D2: doc.resultados.subtotales.D2,
          D3: doc.resultados.subtotales.D3
        },
        indices_dimensionales: {
          ID1: doc.resultados.indices_dimensionales.ID1,
          ID2: doc.resultados.indices_dimensionales.ID2,
          ID3: doc.resultados.indices_dimensionales.ID3
        },
        IGPP: doc.resultados.IGPP,
        dimension_prioritaria: doc.resultados.dimension_prioritaria
      },
      version: doc.version
    };
  }
}