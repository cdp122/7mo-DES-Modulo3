import { DimensionRepository } from '../../database/mongodb/repositories/dimension.repository';
import { CrearDimensionDTO, ActualizarDimensionDTO, CrearReactivoDTO } from '../../../../domain/models/dimension.model';

const dimensionRepo = new DimensionRepository();

export const dimensionResolvers = {
  Query: {
    obtenerDimensiones: async () => {
      return dimensionRepo.obtenerTodas();
    },
    obtenerDimension: async (_: any, { id }: { id: string }) => {
      return dimensionRepo.obtenerPorId(id);
    },
    obtenerDimensionPorOrden: async (_: any, { orden }: { orden: number }) => {
      return dimensionRepo.obtenerPorOrden(orden);
    }
  },
  Mutation: {
    crearDimension: async (_: any, { input }: { input: CrearDimensionDTO }) => {
      const existe = await dimensionRepo.obtenerPorOrden(input.orden);
      if (existe) {
        throw new Error(`Ya existe una dimensión con el orden ${input.orden}`);
      }
      return dimensionRepo.crear(input);
    },
    actualizarDimension: async (_: any, { id, input }: { id: string; input: ActualizarDimensionDTO }) => {
      const dimension = await dimensionRepo.obtenerPorId(id);
      if (!dimension) {
        throw new Error('Dimensión no encontrada');
      }
      return dimensionRepo.actualizar(id, input);
    },
    eliminarDimension: async (_: any, { id }: { id: string }) => {
      const tieneReactivos = await dimensionRepo.tieneReactivosRespondidos(id);
      if (tieneReactivos) {
        throw new Error('No se puede eliminar: la dimensión tiene reactivos con historial de respuestas');
      }
      return dimensionRepo.eliminar(id);
    },
    agregarReactivo: async (_: any, { dimensionId, input }: { dimensionId: string; input: CrearReactivoDTO }) => {
      const dimension = await dimensionRepo.obtenerPorId(dimensionId);
      if (!dimension) {
        throw new Error('Dimensión no encontrada');
      }

      const existeReactivo = dimension.reactivos.some(r => r.reactivo_codigo === input.reactivo_codigo);
      if (existeReactivo) {
        throw new Error(`Ya existe un reactivo con el código ${input.reactivo_codigo}`);
      }

      const reactivosActualizados = [...dimension.reactivos, input];
      return dimensionRepo.actualizar(dimensionId, { reactivos: reactivosActualizados });
    }
  }
};