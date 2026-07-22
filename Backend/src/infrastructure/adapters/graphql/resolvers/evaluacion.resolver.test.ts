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
        { reactivo_codigo: '1.1', enunciado: 'Reactivo 1.1' },
        { reactivo_codigo: '1.2', enunciado: 'Reactivo 1.2' },
        { reactivo_codigo: '1.3', enunciado: 'Reactivo 1.3' },
        { reactivo_codigo: '1.4', enunciado: 'Reactivo 1.4' },
        { reactivo_codigo: '1.5', enunciado: 'Reactivo 1.5' }
      ],
      version: 'V6.6.30'
    },
    {
      orden: 2,
      nombre: 'Dimensión 2',
      descripcion: 'Descripción D2',
      fundamento: 'Fundamento D2',
      reactivos: [
        { reactivo_codigo: '2.1', enunciado: 'Reactivo 2.1' },
        { reactivo_codigo: '2.2', enunciado: 'Reactivo 2.2' },
        { reactivo_codigo: '2.3', enunciado: 'Reactivo 2.3' },
        { reactivo_codigo: '2.4', enunciado: 'Reactivo 2.4' },
        { reactivo_codigo: '2.5', enunciado: 'Reactivo 2.5' }
      ],
      version: 'V6.6.30'
    },
    {
      orden: 3,
      nombre: 'Dimensión 3',
      descripcion: 'Descripción D3',
      fundamento: 'Fundamento D3',
      reactivos: [
        { reactivo_codigo: '3.1', enunciado: 'Reactivo 3.1' },
        { reactivo_codigo: '3.2', enunciado: 'Reactivo 3.2' },
        { reactivo_codigo: '3.3', enunciado: 'Reactivo 3.3' },
        { reactivo_codigo: '3.4', enunciado: 'Reactivo 3.4' },
        { reactivo_codigo: '3.5', enunciado: 'Reactivo 3.5' }
      ],
      version: 'V6.6.30'
    }
  ];

  await DimensionModel.insertMany(dimensiones);
};

const crearEvaluacion = async (servidor: ApolloServer): Promise<string> => {
  const respuestas = [];
  for (let dim = 1; dim <= 3; dim++) {
    for (let req = 1; req <= 5; req++) {
      respuestas.push({ reactivo_codigo: `${dim}.${req}`, valor: 3 });
    }
  }

  const resultado = await servidor.executeOperation(
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
          cedula_docente: '1718056490',
          respuestas
        }
      }
    },
    { contextValue: {} }
  );

  if (resultado.body.kind === 'single' && !resultado.body.singleResult.errors) {
    return resultado.body.singleResult.data?.crearEvaluacion?.id;
  }
  throw new Error('Error al crear evaluación de prueba');
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
    for (let dim = 1; dim <= 3; dim++) {
      for (let req = 1; req <= 5; req++) {
        respuestas.push({ reactivo_codigo: `${dim}.${req}`, valor: 3 });
      }
    }

    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation CrearEvaluacion($input: CrearEvaluacionInput!) {
            crearEvaluacion(input: $input) {
              id
              cedula_docente
              respuestas {
                reactivo_codigo
                valor
              }
              comentarios {
                compromiso_personal
                opiniones_programa
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
            cedula_docente: '1718056490',
            respuestas
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const evaluacion = resultado.body.singleResult.data?.crearEvaluacion as any;
      expect(evaluacion).toBeDefined();
      expect(evaluacion.cedula_docente).toBe('1718056490');
      expect(evaluacion.respuestas).toHaveLength(15);
      expect(evaluacion.comentarios).toEqual({ compromiso_personal: null, opiniones_programa: null });
      expect(evaluacion.resultados.subtotales.D1).toBe(15);
      expect(evaluacion.resultados.subtotales.D2).toBe(15);
      expect(evaluacion.resultados.subtotales.D3).toBe(15);
      expect(evaluacion.resultados.IGPP).toBe(75);
      expect(evaluacion.resultados.dimension_prioritaria).toMatch(/^D[1-3]$/);
    }
  });

  it('CP-02: Debe rechazar evaluación con menos de 15 respuestas', async () => {
    const respuestas = [];
    for (let dim = 1; dim <= 2; dim++) {
      for (let req = 1; req <= 5; req++) {
        respuestas.push({ reactivo_codigo: `${dim}.${req}`, valor: 2 });
      }
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
            cedula_docente: '1718056490',
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

  it('CP-03: Debe rechazar cédula ecuatoriana inválida (dígito verificador incorrecto)', async () => {
    const respuestas = [];
    for (let dim = 1; dim <= 3; dim++) {
      for (let req = 1; req <= 5; req++) {
        respuestas.push({ reactivo_codigo: `${dim}.${req}`, valor: 3 });
      }
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
            cedula_docente: '1718056491',
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
        'Cédula ecuatoriana inválida'
      );
    }
  });

  it('CP-04: Debe rechazar cédula con letras', async () => {
    const respuestas = [];
    for (let dim = 1; dim <= 3; dim++) {
      for (let req = 1; req <= 5; req++) {
        respuestas.push({ reactivo_codigo: `${dim}.${req}`, valor: 3 });
      }
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
            cedula_docente: 'abc1234567',
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
        'Cédula ecuatoriana inválida'
      );
    }
  });

  it('CP-05: Debe rechazar cédula con provincia inválida (>= 25)', async () => {
    const respuestas = [];
    for (let dim = 1; dim <= 3; dim++) {
      for (let req = 1; req <= 5; req++) {
        respuestas.push({ reactivo_codigo: `${dim}.${req}`, valor: 3 });
      }
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
            cedula_docente: '3012345678',
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
        'Cédula ecuatoriana inválida'
      );
    }
  });

  it('CP-06: Debe rechazar cédula con longitud incorrecta', async () => {
    const respuestas = [];
    for (let dim = 1; dim <= 3; dim++) {
      for (let req = 1; req <= 5; req++) {
        respuestas.push({ reactivo_codigo: `${dim}.${req}`, valor: 3 });
      }
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
            cedula_docente: '171805649',
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
        'Cédula ecuatoriana inválida'
      );
    }
  });

  it('CP-07: Debe rechazar valores de respuestas fuera de rango', async () => {
    const respuestas = [];
    for (let dim = 1; dim <= 3; dim++) {
      for (let req = 1; req <= 5; req++) {
        respuestas.push({ reactivo_codigo: `${dim}.${req}`, valor: dim === 3 && req === 5 ? 5 : 3 });
      }
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
            cedula_docente: '1718056490',
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
        'Los valores deben estar entre 0 y 4'
      );
    }
  });
});

describe('Evaluacion Resolver - Comentarios (CP-08 a CP-12)', () => {
  let servidorApollo: ApolloServer;

  beforeAll(async () => {
    const schema = crearSchema();
    servidorApollo = new ApolloServer({ schema });
    await seedDimensiones();
  });

  it('CP-08: Debe guardar ambos comentarios con contenido', async () => {
    const evaluacionId = await crearEvaluacion(servidorApollo);

    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation AgregarComentarios($evaluacionId: ID!, $input: ComentariosInput!) {
            agregarComentarios(evaluacionId: $evaluacionId, input: $input) {
              id
              comentarios {
                compromiso_personal
                opiniones_programa
              }
            }
          }
        `,
        variables: {
          evaluacionId,
          input: {
            compromiso_personal: 'Me comprometo a mejorar mi participación en clase.',
            opiniones_programa: 'El programa es muy útil, pero podría incluir más ejemplos'
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const evaluacion = resultado.body.singleResult.data?.agregarComentarios as any;
      expect(evaluacion).toBeDefined();
      expect(evaluacion.comentarios.compromiso_personal).toBe(
        'Me comprometo a mejorar mi participación en clase.'
      );
      expect(evaluacion.comentarios.opiniones_programa).toBe(
        'El programa es muy útil, pero podría incluir más ejemplos'
      );
    }
  });

  it('CP-09: Debe guardar null en ambos campos cuando ambos están vacíos', async () => {
    const evaluacionId = await crearEvaluacion(servidorApollo);

    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation AgregarComentarios($evaluacionId: ID!, $input: ComentariosInput!) {
            agregarComentarios(evaluacionId: $evaluacionId, input: $input) {
              id
              comentarios {
                compromiso_personal
                opiniones_programa
              }
            }
          }
        `,
        variables: {
          evaluacionId,
          input: {
            compromiso_personal: '',
            opiniones_programa: ''
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const evaluacion = resultado.body.singleResult.data?.agregarComentarios as any;
      expect(evaluacion).toBeDefined();
      expect(evaluacion.comentarios.compromiso_personal).toBeNull();
      expect(evaluacion.comentarios.opiniones_programa).toBeNull();
    }
  });

  it('CP-10: Debe guardar null en un campo cuando solo uno está vacío', async () => {
    const evaluacionId = await crearEvaluacion(servidorApollo);

    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation AgregarComentarios($evaluacionId: ID!, $input: ComentariosInput!) {
            agregarComentarios(evaluacionId: $evaluacionId, input: $input) {
              id
              comentarios {
                compromiso_personal
                opiniones_programa
              }
            }
          }
        `,
        variables: {
          evaluacionId,
          input: {
            compromiso_personal: 'Me comprometo a mejorar.',
            opiniones_programa: ''
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const evaluacion = resultado.body.singleResult.data?.agregarComentarios as any;
      expect(evaluacion).toBeDefined();
      expect(evaluacion.comentarios.compromiso_personal).toBe('Me comprometo a mejorar.');
      expect(evaluacion.comentarios.opiniones_programa).toBeNull();
    }
  });

  it('CP-11: Debe rechazar comentarios que excedan 500 caracteres', async () => {
    const evaluacionId = await crearEvaluacion(servidorApollo);
    const textoLargo = 'A'.repeat(501);

    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation AgregarComentarios($evaluacionId: ID!, $input: ComentariosInput!) {
            agregarComentarios(evaluacionId: $evaluacionId, input: $input) {
              id
              comentarios {
                compromiso_personal
                opiniones_programa
              }
            }
          }
        `,
        variables: {
          evaluacionId,
          input: {
            compromiso_personal: textoLargo,
            opiniones_programa: 'Opinión válida'
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain(
        'no puede exceder 500 caracteres'
      );
    }
  });

  it('CP-12: Debe rechazar evaluación no encontrada', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation AgregarComentarios($evaluacionId: ID!, $input: ComentariosInput!) {
            agregarComentarios(evaluacionId: $evaluacionId, input: $input) {
              id
            }
          }
        `,
        variables: {
          evaluacionId: '507f1f77bcf86cd799439011',
          input: {
            compromiso_personal: 'Test',
            opiniones_programa: 'Test'
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain(
        'Evaluación no encontrada'
      );
    }
  });
});

// ─── CP-13 a CP-16: Queries de Resultados Interpretados ────────────────────

describe('Evaluacion Resolver - Resultados Interpretados (CP-13 a CP-16)', () => {
  let servidorApollo: ApolloServer;

  beforeAll(async () => {
    const schema = crearSchema();
    servidorApollo = new ApolloServer({ schema });
    await seedDimensiones();
  });

  it('CP-13: obtenerResultadosEvaluacion retorna resultado interpretado con dimensiones, IGPP y nivel', async () => {
    const evaluacionId = await crearEvaluacion(servidorApollo);

    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          query ObtenerResultados($id: ID!) {
            obtenerResultadosEvaluacion(id: $id) {
              evaluacion_id
              docente_cedula
              dimensiones {
                nombre
                clave
                puntaje
                maximo
                porcentaje
                nivel
              }
              puntaje_total
              maximo_total
              IGPP
              nivel_general
              dimension_prioritaria
            }
          }
        `,
        variables: { id: evaluacionId }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const res = resultado.body.singleResult.data?.obtenerResultadosEvaluacion as any;
      expect(res).toBeDefined();
      expect(res.evaluacion_id).toBe(evaluacionId);
      expect(res.docente_cedula).toBe('1718056490');
      expect(res.dimensiones).toHaveLength(3);
      expect(res.puntaje_total).toBeGreaterThan(0);
      expect(res.maximo_total).toBeGreaterThan(0);
      expect(res.IGPP).toBeGreaterThan(0);
      expect(res.nivel_general).toBeDefined();
      expect(res.dimension_prioritaria).toBeDefined();
    }
  });

  it('CP-14: obtenerResultadosEvaluacion con ID inexistente retorna null', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          query ObtenerResultados($id: ID!) {
            obtenerResultadosEvaluacion(id: $id) {
              evaluacion_id
            }
          }
        `,
        variables: { id: '507f1f77bcf86cd799439011' }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      expect(resultado.body.singleResult.data?.obtenerResultadosEvaluacion).toBeNull();
    }
  });

  it('CP-15: obtenerResultadosPorDocente retorna lista de resultados interpretados', async () => {
    await crearEvaluacion(servidorApollo);

    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          query ObtenerResultadosDocente($cedula: CedulaEcuatoriana!) {
            obtenerResultadosPorDocente(cedula: $cedula) {
              evaluacion_id
              docente_cedula
              dimensiones {
                nombre
                clave
                puntaje
                maximo
                porcentaje
                nivel
              }
              puntaje_total
              maximo_total
              IGPP
              nivel_general
              dimension_prioritaria
            }
          }
        `,
        variables: { cedula: '1718056490' }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const resultados = resultado.body.singleResult.data?.obtenerResultadosPorDocente as any[];
      expect(resultados).toBeDefined();
      expect(resultados.length).toBeGreaterThanOrEqual(1);
      expect(resultados[0].dimensiones).toHaveLength(3);
      expect(resultados[0].IGPP).toBeGreaterThan(0);
    }
  });

  it('CP-16: obtenerResultadosPorDocente con cédula sin evaluaciones retorna lista vacía', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          query ObtenerResultadosDocente($cedula: CedulaEcuatoriana!) {
            obtenerResultadosPorDocente(cedula: $cedula) {
              evaluacion_id
            }
          }
        `,
        variables: { cedula: '1722250295' }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const resultados = resultado.body.singleResult.data?.obtenerResultadosPorDocente as any[];
      expect(resultados).toEqual([]);
    }
  });
});

// ─── CP-17 a CP-18: Resumen General ────────────────────────────────────────

describe('Evaluacion Resolver - Resumen General (CP-17 y CP-18)', () => {
  let servidorApollo: ApolloServer;

  beforeAll(async () => {
    const schema = crearSchema();
    servidorApollo = new ApolloServer({ schema });
    await seedDimensiones();
  });

  it('CP-17: obtenerResumenGeneral sin evaluaciones retorna promedios en 0', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          query {
            obtenerResumenGeneral {
              total_evaluaciones
              promedio_D1
              promedio_D2
              promedio_D3
              promedio_IGPP
              nivel_general
              dimensiones {
                nombre
                clave
                puntaje
                maximo
                porcentaje
                nivel
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
      const resumen = resultado.body.singleResult.data?.obtenerResumenGeneral as any;
      expect(resumen).toBeDefined();
      expect(resumen.total_evaluaciones).toBe(0);
      expect(resumen.promedio_D1).toBe(0);
      expect(resumen.promedio_IGPP).toBe(0);
      expect(resumen.dimensiones).toHaveLength(3);
    }
  });

  it('CP-18: obtenerResumenGeneral con evaluaciones retorna promedios correctos', async () => {
    await crearEvaluacion(servidorApollo);

    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          query {
            obtenerResumenGeneral {
              total_evaluaciones
              promedio_D1
              promedio_D2
              promedio_D3
              promedio_IGPP
              nivel_general
              dimensiones {
                nombre
                clave
                puntaje
                maximo
                porcentaje
                nivel
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
      const resumen = resultado.body.singleResult.data?.obtenerResumenGeneral as any;
      expect(resumen).toBeDefined();
      expect(resumen.total_evaluaciones).toBeGreaterThanOrEqual(1);
      expect(resumen.promedio_D1).toBeGreaterThan(0);
      expect(resumen.promedio_IGPP).toBeGreaterThan(0);
      expect(resumen.nivel_general).toBeDefined();
    }
  });
});

// ─── CP-19 a CP-21: Queries básicos de evaluaciones ────────────────────────

describe('Evaluacion Resolver - Queries básicos (CP-19 a CP-21)', () => {
  let servidorApollo: ApolloServer;

  beforeAll(async () => {
    const schema = crearSchema();
    servidorApollo = new ApolloServer({ schema });
    await seedDimensiones();
  });

  it('CP-19: obtenerEvaluaciones retorna todas las evaluaciones', async () => {
    await crearEvaluacion(servidorApollo);

    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          query {
            obtenerEvaluaciones {
              id
              cedula_docente
              resultados {
                IGPP
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
      const evaluaciones = resultado.body.singleResult.data?.obtenerEvaluaciones as any[];
      expect(evaluaciones).toBeDefined();
      expect(evaluaciones.length).toBeGreaterThanOrEqual(1);
    }
  });

  it('CP-20: obtenerEvaluacion por ID retorna evaluación correcta', async () => {
    const evaluacionId = await crearEvaluacion(servidorApollo);

    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          query ObtenerEvaluacion($id: ID!) {
            obtenerEvaluacion(id: $id) {
              id
              cedula_docente
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
                IGPP
                dimension_prioritaria
              }
            }
          }
        `,
        variables: { id: evaluacionId }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const evaluacion = resultado.body.singleResult.data?.obtenerEvaluacion as any;
      expect(evaluacion).toBeDefined();
      expect(evaluacion.id).toBe(evaluacionId);
      expect(evaluacion.cedula_docente).toBe('1718056490');
      expect(evaluacion.respuestas).toHaveLength(15);
      expect(evaluacion.resultados.IGPP).toBe(75); // todos valor=3 → 15/20 = 75%
    }
  });

  it('CP-21: obtenerEvaluacionesPorDocente retorna evaluaciones del docente', async () => {
    await crearEvaluacion(servidorApollo);

    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          query ObtenerEvaluacionesDocente($cedula: CedulaEcuatoriana!) {
            obtenerEvaluacionesPorDocente(cedula: $cedula) {
              id
              cedula_docente
              resultados {
                IGPP
              }
            }
          }
        `,
        variables: { cedula: '1718056490' }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const evaluaciones = resultado.body.singleResult.data?.obtenerEvaluacionesPorDocente as any[];
      expect(evaluaciones).toBeDefined();
      expect(evaluaciones.length).toBeGreaterThanOrEqual(1);
      evaluaciones.forEach((ev: any) => {
        expect(ev.cedula_docente).toBe('1718056490');
      });
    }
  });
});
