import { describe, it, expect, beforeAll } from 'vitest';
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
        { reactivo_codigo: '1.1', enunciado: 'Reactivo 1.1' },
        { reactivo_codigo: '2.1', enunciado: 'Reactivo 2.1' },
        { reactivo_codigo: '3.1', enunciado: 'Reactivo 3.1' },
        { reactivo_codigo: '4.1', enunciado: 'Reactivo 4.1' },
        { reactivo_codigo: '5.1', enunciado: 'Reactivo 5.1' }
      ],
      version: 'V6.6.22'
    },
    {
      orden: 2,
      nombre: 'Dimensión 2',
      descripcion: 'Descripción D2',
      fundamento: 'Fundamento D2',
      reactivos: [
        { reactivo_codigo: '6.1', enunciado: 'Reactivo 6.1' },
        { reactivo_codigo: '7.1', enunciado: 'Reactivo 7.1' },
        { reactivo_codigo: '8.1', enunciado: 'Reactivo 8.1' },
        { reactivo_codigo: '9.1', enunciado: 'Reactivo 9.1' },
        { reactivo_codigo: '10.1', enunciado: 'Reactivo 10.1' }
      ],
      version: 'V6.6.22'
    },
    {
      orden: 3,
      nombre: 'Dimensión 3',
      descripcion: 'Descripción D3',
      fundamento: 'Fundamento D3',
      reactivos: [
        { reactivo_codigo: '11.1', enunciado: 'Reactivo 11.1' },
        { reactivo_codigo: '12.1', enunciado: 'Reactivo 12.1' },
        { reactivo_codigo: '13.1', enunciado: 'Reactivo 13.1' },
        { reactivo_codigo: '14.1', enunciado: 'Reactivo 14.1' },
        { reactivo_codigo: '15.1', enunciado: 'Reactivo 15.1' }
      ],
      version: 'V6.6.22'
    }
  ];

  await DimensionModel.insertMany(dimensiones);
};

describe('Evaluacion Resolver - CP-01 y CP-02', () => {
  let servidorApollo: ApolloServer;

  beforeAll(async () => {
    const schema = crearSchema();
    servidorApollo = new ApolloServer({ schema });
    await seedDimensiones();
  });

  it('CP-01: Debe crear evaluación con 15 respuestas válidas', async () => {
    const respuestas = [];
    for (let i = 1; i <= 15; i++) {
      respuestas.push({ reactivo_codigo: `${i}.1`, valor: 3 });
    }

    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation CrearEvaluacion($input: CrearEvaluacionInput!) {
            crearEvaluacion(input: $input) {
              id
              datos_docente {
                cedula
                nombre
              }
              respuestas {
                reactivo_codigo
                valor
              }
              resultados {
                subtotales {
                  D1
                  D2
                  D3
                }
                indices_dimensionales {
                  ID1
                  ID2
                  ID3
                }
                IGPP
                dimension_prioritaria
              }
            }
          }
        `,
        variables: {
          input: {
            datos_docente: { cedula: '1234567890', nombre: 'Docente Test' },
            respuestas
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const evaluacion = resultado.body.singleResult.data?.crearEvaluacion;
      expect(evaluacion).toBeDefined();
      expect(evaluacion.datos_docente.cedula).toBe('1234567890');
      expect(evaluacion.respuestas).toHaveLength(15);
      expect(evaluacion.resultados.subtotales.D1).toBe(15);
      expect(evaluacion.resultados.subtotales.D2).toBe(15);
      expect(evaluacion.resultados.subtotales.D3).toBe(15);
      expect(evaluacion.resultados.IGPP).toBe(75);
      expect(evaluacion.resultados.dimension_prioritaria).toMatch(/^D[1-3]$/);
    }
  });

  it('CP-02: Debe rechazar evaluación con menos de 15 respuestas', async () => {
    const respuestas = [];
    for (let i = 1; i <= 10; i++) {
      respuestas.push({ reactivo_codigo: `${i}.1`, valor: 2 });
    }

    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation CrearEvaluacion($input: CrearEvaluacionInput!) {
            crearEvaluacion(input: $input) {
              id
            }
          }
        `,
        variables: {
          input: {
            datos_docente: { cedula: '0987654321', nombre: 'Docente Incompleto' },
            respuestas
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain(
        'Se deben responder exactamente 15 reactivos'
      );
    }
  });
});
