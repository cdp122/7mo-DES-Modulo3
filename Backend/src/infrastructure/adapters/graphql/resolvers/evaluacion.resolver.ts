import { EvaluacionRepository } from '../../database/mongodb/repositories/evaluacion.repository';
import { DimensionRepository } from '../../database/mongodb/repositories/dimension.repository';
import { CrearEvaluacionDTO, ComentarEvaluacionDTO } from '../../../../domain/models/evaluacion.model';
import { CalculosService } from '../../../../domain/services/calculos.service';
import { CedulaEcuatorianaScalar } from '../scalars/cedulaEcuatoriana';

const evaluacionRepo = new EvaluacionRepository();
const dimensionRepo = new DimensionRepository();

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
      const dimensiones = await dimensionRepo.obtenerTodas();
      return CalculosService.interpretarResultados(evaluacion, dimensiones);
    },

    obtenerResultadosPorDocente: async (_: any, { cedula }: { cedula: string }) => {
      const evaluaciones = await evaluacionRepo.obtenerPorDocenteCedula(cedula);
      const dimensiones = await dimensionRepo.obtenerTodas();
      return evaluaciones.map((ev) => CalculosService.interpretarResultados(ev, dimensiones));
    },

    obtenerResumenGeneral: async () => {
      const evaluaciones = await evaluacionRepo.obtenerTodas();
      const dimensiones = await dimensionRepo.obtenerTodas();
      return CalculosService.calcularResumenGeneral(evaluaciones, dimensiones);
    },
  },
  Mutation: {
    crearEvaluacion: async (_: any, { input }: { input: CrearEvaluacionDTO }) => {
      const dimensiones = await dimensionRepo.obtenerTodas();
      let totalReactivos = dimensiones.reduce((acc, d) => acc + d.reactivos.length, 0);
      if (totalReactivos === 0) {
        totalReactivos = 15;
      }

      if (input.respuestas.length !== totalReactivos) {
        throw new Error(`Se deben responder exactamente ${totalReactivos} reactivos`);
      }

      const valoresValidos = input.respuestas.every(r => r.valor >= 0 && r.valor <= 4);
      if (!valoresValidos) {
        throw new Error('Los valores deben estar entre 0 y 4');
      }

      const resultados = CalculosService.calcularResultados(input.respuestas, dimensiones);
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