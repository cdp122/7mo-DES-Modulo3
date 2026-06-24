import { IDimensionRepository } from '../../../../../domain/repositories/dimension.repository.port';
import { Dimension, CrearDimensionDTO, ActualizarDimensionDTO } from '../../../../../domain/models/dimension.model';
import { DimensionModel, IDimensionDocument } from '../models/dimension.schema';

export class DimensionRepository implements IDimensionRepository {
  async crear(dimension: CrearDimensionDTO): Promise<Dimension> {
    const doc = new DimensionModel(dimension);
    const guardado = await doc.save();
    const resultado = this.mapearADominio(guardado);
    if (!resultado) throw new Error('Error al crear dimensión');
    return resultado;
  }

  async obtenerTodas(): Promise<Dimension[]> {
    const docs = await DimensionModel.find().sort({ orden: 1 });
    return docs.map(doc => this.mapearADominio(doc)).filter((d): d is Dimension => d !== null);
  }

  async obtenerPorId(id: string): Promise<Dimension | null> {
    const doc = await DimensionModel.findById(id);
    return this.mapearADominio(doc);
  }

  async obtenerPorOrden(orden: number): Promise<Dimension | null> {
    const doc = await DimensionModel.findOne({ orden });
    return this.mapearADominio(doc);
  }

  async actualizar(id: string, datos: ActualizarDimensionDTO): Promise<Dimension | null> {
    const doc = await DimensionModel.findByIdAndUpdate(id, datos, { new: true });
    return this.mapearADominio(doc);
  }

  async eliminar(id: string): Promise<boolean> {
    const resultado = await DimensionModel.findByIdAndDelete(id);
    return !!resultado;
  }

  async tieneReactivosRespondidos(id: string): Promise<boolean> {
    const { EvaluacionModel } = await import('../models/evaluacion.schema');
    const dimension = await DimensionModel.findById(id);
    if (!dimension) return false;

    const codigosReactivos = dimension.reactivos.map(r => r.reactivo_codigo);
    const existeRespuesta = await EvaluacionModel.findOne({
      'respuestas.reactivo_codigo': { $in: codigosReactivos }
    });
    return !!existeRespuesta;
  }

  private mapearADominio(doc: IDimensionDocument | null): Dimension | null {
    if (!doc) return null;
    return {
      id: doc._id.toString(),
      orden: doc.orden,
      nombre: doc.nombre,
      descripcion: doc.descripcion,
      fundamento: doc.fundamento,
      reactivos: doc.reactivos.map(r => ({
        reactivo_codigo: r.reactivo_codigo,
        enunciado: r.enunciado,
        pista: r.pista
      })),
      version: doc.version
    };
  }
}