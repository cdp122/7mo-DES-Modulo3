import { Evaluacion, CrearEvaluacionDTO, Comentarios } from '../models/evaluacion.model';

export interface IEvaluacionRepository {
  crear(evaluacion: CrearEvaluacionDTO, resultados: any): Promise<Evaluacion>;
  agregarComentarios(id: string, comentarios: Comentarios): Promise<Evaluacion | null>;
  obtenerPorId(id: string): Promise<Evaluacion | null>;
  obtenerPorDocenteCedula(cedula: string): Promise<Evaluacion[]>;
  obtenerTodas(): Promise<Evaluacion[]>;
  obtenerPromediosDimensionales(): Promise<{
    D1: number;
    D2: number;
    D3: number;
    IGPP: number;
  }>;
}