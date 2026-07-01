import { describe, it, expect, beforeAll, beforeEach } from 'vitest';
import { ApolloServer } from '@apollo/server';
import { makeExecutableSchema } from '@graphql-tools/schema';
import { readFileSync } from 'fs';
import { join } from 'path';
import { administradorResolvers } from './administrador.resolver';
import { dimensionResolvers } from './dimension.resolver';
import { evaluacionResolvers } from './evaluacion.resolver';
import { DimensionModel } from '../../database/mongodb/models/dimension.schema';

const crearSchema = () => {
  const administradorSchema = readFileSync(
    join(__dirname, '../schemas/administrador.graphql'),
    'utf-8'
  );
  const dimensionSchema = readFileSync(
    join(__dirname, '../schemas/dimension.graphql'),
    'utf-8'
  );
  const evaluacionSchema = readFileSync(
    join(__dirname, '../schemas/evaluacion.graphql'),
    'utf-8'
  );

  const typeDefs = `
    ${administradorSchema}
    ${dimensionSchema}
    ${evaluacionSchema}
  `;

  return makeExecutableSchema({
    typeDefs,
    resolvers: {
      CedulaEcuatoriana: evaluacionResolvers.CedulaEcuatoriana,
      Query: {
        ...administradorResolvers.Query,
        ...dimensionResolvers.Query,
        ...evaluacionResolvers.Query
      },
      Mutation: {
        ...administradorResolvers.Mutation,
        ...dimensionResolvers.Mutation,
        ...evaluacionResolvers.Mutation
      }
    }
  });
};

const seedDimensiones = async () => {
  const dimensiones = [
    {
      orden: 1,
      nombre: 'Dimensión 1',
      descripcion: 'Descripción D1',
      fundamento: 'Fundamento D1',
      reactivos: [
        { reactivo_codigo: '1.1', enunciado: 'Reactivo 1.1', pista: 'Pista 1.1' },
        { reactivo_codigo: '1.2', enunciado: 'Reactivo 1.2', pista: 'Pista 1.2' },
        { reactivo_codigo: '1.3', enunciado: 'Reactivo 1.3', pista: 'Pista 1.3' },
        { reactivo_codigo: '1.4', enunciado: 'Reactivo 1.4', pista: 'Pista 1.4' },
        { reactivo_codigo: '1.5', enunciado: 'Reactivo 1.5', pista: 'Pista 1.5' }
      ],
      version: 'V6.7.01'
    },
    {
      orden: 2,
      nombre: 'Dimensión 2',
      descripcion: 'Descripción D2',
      fundamento: 'Fundamento D2',
      reactivos: [
        { reactivo_codigo: '2.1', enunciado: 'Reactivo 2.1', pista: 'Pista 2.1' },
        { reactivo_codigo: '2.2', enunciado: 'Reactivo 2.2', pista: 'Pista 2.2' },
        { reactivo_codigo: '2.3', enunciado: 'Reactivo 2.3', pista: 'Pista 2.3' },
        { reactivo_codigo: '2.4', enunciado: 'Reactivo 2.4', pista: 'Pista 2.4' },
        { reactivo_codigo: '2.5', enunciado: 'Reactivo 2.5', pista: 'Pista 2.5' }
      ],
      version: 'V6.7.01'
    },
    {
      orden: 3,
      nombre: 'Dimensión 3',
      descripcion: 'Descripción D3',
      fundamento: 'Fundamento D3',
      reactivos: [
        { reactivo_codigo: '3.1', enunciado: 'Reactivo 3.1', pista: 'Pista 3.1' },
        { reactivo_codigo: '3.2', enunciado: 'Reactivo 3.2', pista: 'Pista 3.2' },
        { reactivo_codigo: '3.3', enunciado: 'Reactivo 3.3', pista: 'Pista 3.3' },
        { reactivo_codigo: '3.4', enunciado: 'Reactivo 3.4', pista: 'Pista 3.4' },
        { reactivo_codigo: '3.5', enunciado: 'Reactivo 3.5', pista: 'Pista 3.5' }
      ],
      version: 'V6.7.01'
    }
  ];

  await DimensionModel.insertMany(dimensiones);
};

const reseedDimensiones = async () => {
  await DimensionModel.deleteMany({});
  await seedDimensiones();
};

// ─── CP-01 a CP-06: Campos obligatorios ────────────────────────────

describe('Dimension Resolver - Campos obligatorios (CP-01 a CP-06)', () => {
  let servidorApollo: ApolloServer;

  beforeAll(async () => {
    const schema = crearSchema();
    servidorApollo = new ApolloServer({ schema });
    await seedDimensiones();
  });

  beforeEach(async () => {
    await reseedDimensiones();
  });

  it('CP-01: Debe crear dimensión con todos los campos obligatorios', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation CrearDimension($input: CrearDimensionInput!) {
            crearDimension(input: $input) {
              id
              orden
              nombre
              descripcion
              fundamento
              reactivos {
                reactivo_codigo
                enunciado
                pista
              }
            }
          }
        `,
        variables: {
          input: {
            orden: 4,
            nombre: 'Dimensión Test',
            descripcion: 'Descripción Test',
            fundamento: 'Fundamento Test',
            reactivos: [
              { reactivo_codigo: '4.1', enunciado: 'Enunciado 4.1', pista: 'Pista 4.1' }
            ]
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const dimension = resultado.body.singleResult.data?.crearDimension as any;
      expect(dimension).toBeDefined();
      expect(dimension.orden).toBe(4);
      expect(dimension.nombre).toBe('Dimensión Test');
      expect(dimension.descripcion).toBe('Descripción Test');
      expect(dimension.fundamento).toBe('Fundamento Test');
      expect(dimension.reactivos).toHaveLength(1);
      expect(dimension.reactivos[0].reactivo_codigo).toBe('4.1');
      expect(dimension.reactivos[0].enunciado).toBe('Enunciado 4.1');
      expect(dimension.reactivos[0].pista).toBe('Pista 4.1');
    }
  });

  it('CP-02: Debe rechazar dimensión sin campo "nombre"', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation CrearDimension($input: CrearDimensionInput!) {
            crearDimension(input: $input) { id }
          }
        `,
        variables: {
          input: {
            orden: 4,
            descripcion: 'Descripción Test',
            fundamento: 'Fundamento Test',
            reactivos: [{ reactivo_codigo: '4.1', enunciado: 'Enunciado 4.1' }]
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
    }
  });

  it('CP-03: Debe rechazar dimensión sin campo "descripcion"', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation CrearDimension($input: CrearDimensionInput!) {
            crearDimension(input: $input) { id }
          }
        `,
        variables: {
          input: {
            orden: 4,
            nombre: 'Dimensión Test',
            fundamento: 'Fundamento Test',
            reactivos: [{ reactivo_codigo: '4.1', enunciado: 'Enunciado 4.1' }]
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
    }
  });

  it('CP-04: Debe rechazar dimensión sin campo "fundamento"', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation CrearDimension($input: CrearDimensionInput!) {
            crearDimension(input: $input) { id }
          }
        `,
        variables: {
          input: {
            orden: 4,
            nombre: 'Dimensión Test',
            descripcion: 'Descripción Test',
            reactivos: [{ reactivo_codigo: '4.1', enunciado: 'Enunciado 4.1' }]
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
    }
  });

  it('CP-05: Debe rechazar dimensión sin campo "orden"', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation CrearDimension($input: CrearDimensionInput!) {
            crearDimension(input: $input) { id }
          }
        `,
        variables: {
          input: {
            nombre: 'Dimensión Test',
            descripcion: 'Descripción Test',
            fundamento: 'Fundamento Test',
            reactivos: [{ reactivo_codigo: '4.1', enunciado: 'Enunciado 4.1' }]
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
    }
  });

  it('CP-06: Debe rechazar reactivo sin campo "enunciado"', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation CrearDimension($input: CrearDimensionInput!) {
            crearDimension(input: $input) { id }
          }
        `,
        variables: {
          input: {
            orden: 4,
            nombre: 'Dimensión Test',
            descripcion: 'Descripción Test',
            fundamento: 'Fundamento Test',
            reactivos: [{ reactivo_codigo: '4.1' }]
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
    }
  });
});

// ─── CP-07 a CP-09: Orden secuencial ───────────────────────────────

describe('Dimension Resolver - Orden secuencial (CP-07 a CP-09)', () => {
  let servidorApollo: ApolloServer;

  beforeAll(async () => {
    const schema = crearSchema();
    servidorApollo = new ApolloServer({ schema });
    await seedDimensiones();
  });

  beforeEach(async () => {
    await reseedDimensiones();
  });

  it('CP-07: Debe crear dimensión con orden secuencial (siguiente al último existente)', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation CrearDimension($input: CrearDimensionInput!) {
            crearDimension(input: $input) {
              id
              orden
            }
          }
        `,
        variables: {
          input: {
            orden: 4,
            nombre: 'Dimensión 4',
            descripcion: 'Desc 4',
            fundamento: 'Fund 4',
            reactivos: [{ reactivo_codigo: '4.1', enunciado: 'R4.1' }]
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const dimension = resultado.body.singleResult.data?.crearDimension as any;
      expect(dimension.orden).toBe(4);
    }
  });

  it('CP-08: Debe rechazar dimensión con orden duplicado (orden 1)', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation CrearDimension($input: CrearDimensionInput!) {
            crearDimension(input: $input) { id }
          }
        `,
        variables: {
          input: {
            orden: 1,
            nombre: 'Duplicada',
            descripcion: 'Dup',
            fundamento: 'Dup',
            reactivos: [{ reactivo_codigo: '1.1', enunciado: 'R1.1' }]
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain(
        'Ya existe una dimensión con el orden 1'
      );
    }
  });

  it('CP-09: Debe rechazar dimensión con orden duplicado (orden 2)', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation CrearDimension($input: CrearDimensionInput!) {
            crearDimension(input: $input) { id }
          }
        `,
        variables: {
          input: {
            orden: 2,
            nombre: 'Duplicada',
            descripcion: 'Dup',
            fundamento: 'Dup',
            reactivos: [{ reactivo_codigo: '2.1', enunciado: 'R2.1' }]
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain(
        'Ya existe una dimensión con el orden 2'
      );
    }
  });
});

// ─── CP-10 a CP-13: Reactivos secuenciales con enunciado y pista ────

describe('Dimension Resolver - Reactivos (CP-10 a CP-13)', () => {
  let servidorApollo: ApolloServer;

  beforeAll(async () => {
    const schema = crearSchema();
    servidorApollo = new ApolloServer({ schema });
    await seedDimensiones();
  });

  beforeEach(async () => {
    await reseedDimensiones();
  });

  it('CP-10: Debe crear dimensión con reactivos secuenciales (orden.id)', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation CrearDimension($input: CrearDimensionInput!) {
            crearDimension(input: $input) {
              id
              orden
              reactivos {
                reactivo_codigo
                enunciado
                pista
              }
            }
          }
        `,
        variables: {
          input: {
            orden: 4,
            nombre: 'Dimensión Reactivos',
            descripcion: 'Desc',
            fundamento: 'Fund',
            reactivos: [
              { reactivo_codigo: '4.1', enunciado: 'Enunciado 4.1', pista: 'Pista 4.1' },
              { reactivo_codigo: '4.2', enunciado: 'Enunciado 4.2', pista: 'Pista 4.2' },
              { reactivo_codigo: '4.3', enunciado: 'Enunciado 4.3', pista: 'Pista 4.3' }
            ]
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const dimension = resultado.body.singleResult.data?.crearDimension as any;
      expect(dimension.reactivos).toHaveLength(3);
      expect(dimension.reactivos[0].reactivo_codigo).toBe('4.1');
      expect(dimension.reactivos[1].reactivo_codigo).toBe('4.2');
      expect(dimension.reactivos[2].reactivo_codigo).toBe('4.3');
      for (const r of dimension.reactivos) {
        expect(r.enunciado).toBeDefined();
        expect(r.enunciado.length).toBeGreaterThan(0);
      }
    }
  });

  it('CP-11: Debe agregar reactivo con campos enunciado y pista', async () => {
    const dimensionId = await obtenerPrimeraDimensionId(servidorApollo);

    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation AgregarReactivo($dimensionId: ID!, $input: CrearReactivoInput!) {
            agregarReactivo(dimensionId: $dimensionId, input: $input) {
              id
              reactivos {
                reactivo_codigo
                enunciado
                pista
              }
            }
          }
        `,
        variables: {
          dimensionId,
          input: {
            reactivo_codigo: '1.99',
            enunciado: 'Enunciado nuevo 1.99',
            pista: 'Pista nueva 1.99'
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const dimension = resultado.body.singleResult.data?.agregarReactivo as any;
      const reactivo = dimension.reactivos.find((r: any) => r.reactivo_codigo === '1.99');
      expect(reactivo).toBeDefined();
      expect(reactivo.enunciado).toBe('Enunciado nuevo 1.99');
      expect(reactivo.pista).toBe('Pista nueva 1.99');
    }
  });

  it('CP-12: Debe rechazar reactivo con código duplicado', async () => {
    const dimensionId = await obtenerPrimeraDimensionId(servidorApollo);

    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation AgregarReactivo($dimensionId: ID!, $input: CrearReactivoInput!) {
            agregarReactivo(dimensionId: $dimensionId, input: $input) { id }
          }
        `,
        variables: {
          dimensionId,
          input: {
            reactivo_codigo: '1.1',
            enunciado: 'Duplicado',
            pista: 'Duplicado'
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain(
        'Ya existe un reactivo con el código 1.1'
      );
    }
  });

  it('CP-13: Debe rechazar agregar reactivo a dimensión inexistente', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation AgregarReactivo($dimensionId: ID!, $input: CrearReactivoInput!) {
            agregarReactivo(dimensionId: $dimensionId, input: $input) { id }
          }
        `,
        variables: {
          dimensionId: '507f1f77bcf86cd799439011',
          input: {
            reactivo_codigo: '99.1',
            enunciado: 'Test',
            pista: 'Test'
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain(
        'Dimensión no encontrada'
      );
    }
  });
});

// ─── CP-14 a CP-17: Queries ────────────────────────────────────────

describe('Dimension Resolver - Consultas (CP-14 a CP-17)', () => {
  let servidorApollo: ApolloServer;

  beforeAll(async () => {
    const schema = crearSchema();
    servidorApollo = new ApolloServer({ schema });
    await seedDimensiones();
  });

  beforeEach(async () => {
    await reseedDimensiones();
  });

  it('CP-14: Debe obtener todas las dimensiones', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          query ObtenerDimensiones {
            obtenerDimensiones {
              id
              orden
              nombre
              reactivos {
                reactivo_codigo
                enunciado
                pista
              }
            }
          }
        `
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const dimensiones = resultado.body.singleResult.data?.obtenerDimensiones as any[];
      expect(dimensiones).toHaveLength(3);
      expect(dimensiones[0].orden).toBe(1);
      expect(dimensiones[1].orden).toBe(2);
      expect(dimensiones[2].orden).toBe(3);
      for (const d of dimensiones) {
        expect(d.reactivos.length).toBeGreaterThan(0);
        for (const r of d.reactivos) {
          expect(r.reactivo_codigo).toBeDefined();
          expect(r.enunciado).toBeDefined();
        }
      }
    }
  });

  it('CP-15: Debe obtener dimensión por ID', async () => {
    const dimensionId = await obtenerPrimeraDimensionId(servidorApollo);

    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          query ObtenerDimension($id: ID!) {
            obtenerDimension(id: $id) {
              id
              orden
              nombre
              descripcion
              fundamento
              reactivos {
                reactivo_codigo
                enunciado
                pista
              }
            }
          }
        `,
        variables: { id: dimensionId }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const dimension = resultado.body.singleResult.data?.obtenerDimension as any;
      expect(dimension).toBeDefined();
      expect(dimension.orden).toBe(1);
      expect(dimension.nombre).toBe('Dimensión 1');
      expect(dimension.reactivos).toHaveLength(5);
    }
  });

  it('CP-16: Debe obtener dimensión por orden', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          query ObtenerDimensionPorOrden($orden: Int!) {
            obtenerDimensionPorOrden(orden: $orden) {
              id
              orden
              nombre
            }
          }
        `,
        variables: { orden: 2 }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const dimension = resultado.body.singleResult.data?.obtenerDimensionPorOrden as any;
      expect(dimension).toBeDefined();
      expect(dimension.orden).toBe(2);
      expect(dimension.nombre).toBe('Dimensión 2');
    }
  });

  it('CP-17: Debe retornar null al buscar dimensión inexistente por ID', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          query ObtenerDimension($id: ID!) {
            obtenerDimension(id: $id) { id }
          }
        `,
        variables: { id: '507f1f77bcf86cd799439011' }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      expect(resultado.body.singleResult.data?.obtenerDimension).toBeNull();
    }
  });
});

// ─── CP-18 a CP-21: Actualizar y eliminar ──────────────────────────

describe('Dimension Resolver - Actualizar y eliminar (CP-18 a CP-21)', () => {
  let servidorApollo: ApolloServer;

  beforeAll(async () => {
    const schema = crearSchema();
    servidorApollo = new ApolloServer({ schema });
    await seedDimensiones();
  });

  beforeEach(async () => {
    await reseedDimensiones();
  });

  it('CP-18: Debe actualizar nombre y descripción de una dimensión', async () => {
    const dimensionId = await obtenerPrimeraDimensionId(servidorApollo);

    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation ActualizarDimension($id: ID!, $input: ActualizarDimensionInput!) {
            actualizarDimension(id: $id, input: $input) {
              id
              nombre
              descripcion
            }
          }
        `,
        variables: {
          id: dimensionId,
          input: {
            nombre: 'Dimensión 1 Actualizada',
            descripcion: 'Nueva descripción'
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const dimension = resultado.body.singleResult.data?.actualizarDimension as any;
      expect(dimension.nombre).toBe('Dimensión 1 Actualizada');
      expect(dimension.descripcion).toBe('Nueva descripción');
    }
  });

  it('CP-19: Debe rechazar actualización de dimensión inexistente', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation ActualizarDimension($id: ID!, $input: ActualizarDimensionInput!) {
            actualizarDimension(id: $id, input: $input) { id }
          }
        `,
        variables: {
          id: '507f1f77bcf86cd799439011',
          input: { nombre: 'No existe' }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain(
        'Dimensión no encontrada'
      );
    }
  });

  it('CP-20: Debe eliminar dimensión sin reactivos respondidos', async () => {
    const dimensionId = await obtenerPrimeraDimensionId(servidorApollo);

    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation EliminarDimension($id: ID!) {
            eliminarDimension(id: $id)
          }
        `,
        variables: { id: dimensionId }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      expect(resultado.body.singleResult.data?.eliminarDimension).toBe(true);
    }
  });

  it('CP-21: Debe retornar false al eliminar dimensión inexistente', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation EliminarDimension($id: ID!) {
            eliminarDimension(id: $id)
          }
        `,
        variables: { id: '507f1f77bcf86cd799439011' }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      expect(resultado.body.singleResult.data?.eliminarDimension).toBe(false);
    }
  });
});

// ─── Helper ────────────────────────────────────────────────────────

async function obtenerPrimeraDimensionId(servidor: ApolloServer): Promise<string> {
  const resultado = await servidor.executeOperation(
    {
      query: `
        query ObtenerDimensiones {
          obtenerDimensiones { id }
        }
      `
    },
    { contextValue: {} }
  );

  if (resultado.body.kind === 'single' && !resultado.body.singleResult.errors) {
    const dimensiones = resultado.body.singleResult.data?.obtenerDimensiones as any[];
    return dimensiones[0].id;
  }
  throw new Error('Error al obtener dimensión de prueba');
}
