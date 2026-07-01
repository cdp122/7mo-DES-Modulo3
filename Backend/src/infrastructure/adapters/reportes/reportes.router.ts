import { Router } from 'express';
import { EvaluacionRepository } from '../database/mongodb/repositories/evaluacion.repository';
import { DimensionRepository } from '../database/mongodb/repositories/dimension.repository';
import { extraerToken } from '../graphql/server/jwt.middleware';
import { ExportacionService } from './exportacion.service';

const evaluacionRepo = new EvaluacionRepository();
const dimensionRepo = new DimensionRepository();

export const crearRouterReportes = (): Router => {
  const router = Router();

  router.get('/evaluaciones/excel', async (req, res) => {
    const { administrador } = extraerToken(req);
    if (!administrador) {
      res.status(401).json({ error: 'No autenticado. Se requiere token JWT de administrador.' });
      return;
    }

    const cedula = typeof req.query.cedula === 'string' ? req.query.cedula : undefined;
    const evaluaciones = cedula
      ? await evaluacionRepo.obtenerPorDocenteCedula(cedula)
      : await evaluacionRepo.obtenerTodas();
    const dimensiones = await dimensionRepo.obtenerTodas();

    const workbook = ExportacionService.generarWorkbookEvaluaciones(evaluaciones, dimensiones);

    res.setHeader(
      'Content-Type',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    );
    res.setHeader('Content-Disposition', 'attachment; filename="evaluaciones.xlsx"');
    await workbook.xlsx.write(res);
    res.end();
  });

  return router;
};
