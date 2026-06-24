import { Dimension, CrearDimensionDTO, ActualizarDimensionDTO } from '../models/dimension.model';

export interface IDimensionRepository {
  crear(dimension: CrearDimensionDTO): Promise<Dimension>;
  obtenerTodas(): Promise<Dimension[]>;
  obtenerPorId(id: string): Promise<Dimension | null>;
  obtenerPorOrden(orden: number): Promise<Dimension | null>;
  actualizar(id: string, datos: ActualizarDimensionDTO): Promise<Dimension | null>;
  eliminar(id: string): Promise<boolean>;
  tieneReactivosRespondidos(id: string): Promise<boolean>;
}