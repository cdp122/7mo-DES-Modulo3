import { EvaluacionRepository } from '../../database/mongodb/repositories/evaluacion.repository';
import { CrearEvaluacionDTO, ComentarEvaluacionDTO } from '../../../../domain/models/evaluacion.model';
import { CalculosService } from '../../../../domain/services/calculos.service';
import { CedulaEcuatorianaScalar } from '../scalars/cedulaEcuatoriana';

const evaluacionRepo = new EvaluacionRepository();

export const evaluacionResolvers = {
  CedulaEcuatoriana: CedulaEcuatorianaScalar,
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
    },

    // ── Nuevos queries de métricas interpretadas ──────────────────

    obtenerResultadosEvaluacion: async (_: any, { id }: { id: string }) => {
      const evaluacion = await evaluacionRepo.obtenerPorId(id);
      if (!evaluacion) return null;
      return CalculosService.interpretarResultados(evaluacion);
    },

    obtenerResultadosPorDocente: async (_: any, { cedula }: { cedula: string }) => {
      const evaluaciones = await evaluacionRepo.obtenerPorDocenteCedula(cedula);
      return evaluaciones.map((ev) => CalculosService.interpretarResultados(ev));
    },

    obtenerResumenGeneral: async () => {
      const evaluaciones = await evaluacionRepo.obtenerTodas();
      return CalculosService.calcularResumenGeneral(evaluaciones);
    },
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
    },

    agregarComentarios: async (
      _: any,
      { evaluacionId, input }: { evaluacionId: string; input: ComentarEvaluacionDTO }
    ) => {
      const evaluacion = await evaluacionRepo.obtenerPorId(evaluacionId);
      if (!evaluacion) {
        throw new Error('Evaluación no encontrada');
      }

      const compromiso = input.compromiso_personal?.trim() || null;
      const opiniones = input.opiniones_programa?.trim() || null;

      if (compromiso && compromiso.length > 500) {
        throw new Error('El campo compromiso_personal no puede exceder 500 caracteres');
      }
      if (opiniones && opiniones.length > 500) {
        throw new Error('El campo opiniones_programa no puede exceder 500 caracteres');
      }

      const comentarios = {
        compromiso_personal: compromiso,
        opiniones_programa: opiniones,
      };

      const resultado = await evaluacionRepo.agregarComentarios(evaluacionId, comentarios);
      if (!resultado) throw new Error('Error al guardar comentarios');
      return resultado;
    },
  }
};