import { EvaluacionRepository } from '../../database/mongodb/repositories/evaluacion.repository';
import { CrearEvaluacionDTO } from '../../../../domain/models/evaluacion.model';
import { CalculosService } from '../../../../domain/services/calculos.service';

const evaluacionRepo = new EvaluacionRepository();

export const evaluacionResolvers = {
  Query: {
    obtenerEvaluaciones: async () => {
      return evaluacionRepo.obtenerTodas();
    },
    obtenerEvaluacion: async (_: any, { id }: { id: string }) => {
      return evaluacionRepo.obtenerPorId(id);
    },
    obtenerEvaluacionesPorDocente: async (_: any, { cedula }: { cedula: string }) => {
      return evaluacionRepo.obtenerPorDocenteCedula(cedula);
    },
    obtenerPromediosGlobales: async () => {
      return evaluacionRepo.obtenerPromediosDimensionales();
    }
  },
  Mutation: {
    crearEvaluacion: async (_: any, { input }: { input: CrearEvaluacionDTO }) => {
      if (input.respuestas.length !== 15) {
        throw new Error('Se deben responder exactamente 15 reactivos');
      }

      const valoresValidos = input.respuestas.every(r => r.valor >= 0 && r.valor <= 4);
      if (!valoresValidos) {
        throw new Error('Los valores deben estar entre 0 y 4');
      }

      const resultados = CalculosService.calcularResultados(input.respuestas);
      return evaluacionRepo.crear(input, resultados);
    }
  }
};