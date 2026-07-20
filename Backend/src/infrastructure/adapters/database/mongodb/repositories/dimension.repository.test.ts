import { describe, it, expect, beforeEach } from 'vitest';
import { DimensionRepository } from './dimension.repository';
import { DimensionModel } from '../models/dimension.schema';
import { CrearDimensionDTO, ActualizarDimensionDTO } from '../../../../../domain/models/dimension.model';

const repository = new DimensionRepository();

const crearDimensionPrueba = (overrides: Partial<CrearDimensionDTO> = {}): CrearDimensionDTO => ({
  orden: 1,
  nombre: 'Dimensión de prueba',
  descripcion: 'Descripción de prueba',
  fundamento: 'Fundamento de prueba',
  reactivos: [
    {
      reactivo_codigo: '1.1',
      enunciado: 'Enunciado de prueba',
      pista: 'Pista de prueba'
    }
  ],
  ...overrides
});

describe('DimensionRepository - Gestión de dimensiones', () => {
  beforeEach(async () => {
    await DimensionModel.deleteMany({});
  });

  it('CP-01: Leer y retornar los registros existentes', async () => {
    await repository.crear(crearDimensionPrueba({ orden: 1, nombre: 'Dimensión 1' }));
    await repository.crear(crearDimensionPrueba({ orden: 2, nombre: 'Dimensión 2', reactivos: [{ reactivo_codigo: '2.1', enunciado: 'Enunciado 2.1' }] }));

    const dimensiones = await repository.obtenerTodas();

    expect(dimensiones).toHaveLength(2);
    expect(dimensiones[0].orden).toBe(1);
    expect(dimensiones[0].nombre).toBe('Dimensión 1');
    expect(dimensiones[1].orden).toBe(2);
    expect(dimensiones[1].nombre).toBe('Dimensión 2');
  });

  it('CP-02: Creación de la nueva dimensión dentro de la base de datos', async () => {
    const input = crearDimensionPrueba({ orden: 3, nombre: 'Dimensión nueva' });
    const dimensionCreada = await repository.crear(input);

    expect(dimensionCreada).toMatchObject({
      orden: 3,
      nombre: 'Dimensión nueva',
      descripcion: 'Descripción de prueba',
      fundamento: 'Fundamento de prueba'
    });
    expect(dimensionCreada.reactivos).toHaveLength(1);
    expect(dimensionCreada.reactivos[0].reactivo_codigo).toBe('1.1');

    const dimensionGuardada = await repository.obtenerPorId(dimensionCreada.id);
    expect(dimensionGuardada).not.toBeNull();
    expect(dimensionGuardada?.id).toBe(dimensionCreada.id);
  });

  it('CP-03: Edición dentro de la Base de datos', async () => {
    const dimension = await repository.crear(crearDimensionPrueba({ orden: 4, nombre: 'Dimensión editable' }));
    const datosActualizar: ActualizarDimensionDTO = {
      nombre: 'Dimensión editada',
      descripcion: 'Descripción actualizada',
      reactivos: [
        {
          reactivo_codigo: '4.1',
          enunciado: 'Enunciado actualizado',
          pista: 'Pista actualizada'
        }
      ]
    };

    const dimensionActualizada = await repository.actualizar(dimension.id, datosActualizar);

    expect(dimensionActualizada).not.toBeNull();
    expect(dimensionActualizada?.nombre).toBe('Dimensión editada');
    expect(dimensionActualizada?.descripcion).toBe('Descripción actualizada');
    expect(dimensionActualizada?.reactivos).toHaveLength(1);
    expect(dimensionActualizada?.reactivos[0].reactivo_codigo).toBe('4.1');
  });

  it('CP-04: Eliminar la dimensión de la Base de datos', async () => {
    const dimension = await repository.crear(crearDimensionPrueba({ orden: 5, nombre: 'Dimensión a eliminar' }));

    const eliminado = await repository.eliminar(dimension.id);
    expect(eliminado).toBe(true);

    const dimensionEliminada = await repository.obtenerPorId(dimension.id);
    expect(dimensionEliminada).toBeNull();
  });

  it('CP-05: Tratar de eliminar una dimensión pero cancelar la acción', async () => {
    const dimension = await repository.crear(crearDimensionPrueba({ orden: 6, nombre: 'Dimensión cancelada' }));

    // Simula que el usuario decide cancelar la acción de eliminación.
    const dimensionAntes = await repository.obtenerPorId(dimension.id);
    expect(dimensionAntes).not.toBeNull();

    // No se llama a repository.eliminar() porque la acción fue cancelada.
    const dimensionDespues = await repository.obtenerPorId(dimension.id);
    expect(dimensionDespues).not.toBeNull();
    expect(dimensionDespues?.nombre).toBe('Dimensión cancelada');
  });
});
