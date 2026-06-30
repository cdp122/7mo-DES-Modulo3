import { describe, it, expect, beforeAll, beforeEach } from 'vitest';
import { ApolloServer } from '@apollo/server';
import { makeExecutableSchema } from '@graphql-tools/schema';
import { readFileSync } from 'fs';
import { join } from 'path';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { administradorResolvers } from './administrador.resolver';
import { dimensionResolvers } from './dimension.resolver';
import { evaluacionResolvers } from './evaluacion.resolver';
import { AdministradorModel } from '../../database/mongodb/models/administrador.schema';

const JWT_SECRET = process.env.JWT_SECRET || 'test_secret_key_para_pruebas_2026';

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

const crearAdminTest = async (cedula = '1718056490') => {
  const passwordHash = await bcrypt.hash('Admin123!', 10);
  const admin = await AdministradorModel.create({
    cedula,
    nombre: 'Admin Test',
    password: passwordHash,
    version: 'V6.6.30'
  });
  return admin;
};

const generarToken = (admin: any): string => {
  return jwt.sign(
    { id: admin._id.toString(), cedula: admin.cedula },
    JWT_SECRET,
    { expiresIn: '1h' }
  );
};

describe('Administrador Resolver - Autenticación JWT (CP-A01 a CP-A05)', () => {
  let servidorApollo: ApolloServer;

  beforeAll(async () => {
    const schema = crearSchema();
    servidorApollo = new ApolloServer({ schema });
  });

  it('CP-A01: Login exitoso con cédula y contraseña válidos', async () => {
    const admin = await crearAdminTest();

    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation Login($input: LoginInput!) {
            login(input: $input) {
              token
              administrador {
                id
                cedula
                nombre
              }
            }
          }
        `,
        variables: {
          input: {
            cedula: '1718056490',
            password: 'Admin123!'
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const auth = resultado.body.singleResult.data?.login as any;
      expect(auth).toBeDefined();
      expect(auth.token).toBeDefined();
      expect(auth.administrador.cedula).toBe('1718056490');
      expect(auth.administrador.nombre).toBe('Admin Test');
    }
  });

  it('CP-A02: Login fallido con contraseña incorrecta', async () => {
    await crearAdminTest();

    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation Login($input: LoginInput!) {
            login(input: $input) {
              token
              administrador {
                id
              }
            }
          }
        `,
        variables: {
          input: {
            cedula: '1718056490',
            password: 'WrongPassword'
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain('Credenciales inválidas');
    }
  });

  it('CP-A03: Login fallido con cédula inexistente', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation Login($input: LoginInput!) {
            login(input: $input) {
              token
              administrador {
                id
              }
            }
          }
        `,
        variables: {
          input: {
            cedula: '1710034065',
            password: 'Admin123!'
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain('Credenciales inválidas');
    }
  });

  it('CP-A04: Debe rechazar obtenerAdministradores sin JWT', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          query ObtenerAdministradores {
            obtenerAdministradores {
              id
              cedula
              nombre
            }
          }
        `
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain('No autenticado');
    }
  });

  it('CP-A05: Debe rechazar buscarAdminPorCedula sin JWT', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          query BuscarAdmin($cedula: CedulaEcuatoriana!) {
            buscarAdminPorCedula(cedula: $cedula) {
              id
              cedula
            }
          }
        `,
        variables: { cedula: '1718056490' }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain('No autenticado');
    }
  });

  it('CP-A06: Debe rechazar crearAdministrador sin JWT', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation CrearAdmin($input: CrearAdministradorInput!) {
            crearAdministrador(input: $input) {
              id
              cedula
            }
          }
        `,
        variables: {
          input: {
            cedula: '1718056490',
            nombre: 'Nuevo Admin',
            password: 'Admin123!'
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain('No autenticado');
    }
  });

  it('CP-A07: Debe rechazar actualizarAdministrador sin JWT', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation ActualizarAdmin($id: ID!, $input: ActualizarAdministradorInput!) {
            actualizarAdministrador(id: $id, input: $input) {
              id
              nombre
            }
          }
        `,
        variables: {
          id: '507f1f77bcf86cd799439011',
          input: { nombre: 'Actualizado' }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain('No autenticado');
    }
  });
});

describe('Administrador Resolver - Validación Cédula Ecuatoriana (CP-A09 a CP-A13)', () => {
  let servidorApollo: ApolloServer;
  let tokenAdmin: string;

  beforeAll(async () => {
    const schema = crearSchema();
    servidorApollo = new ApolloServer({ schema });
    const admin = await crearAdminTest();
    tokenAdmin = generarToken(admin);
  });

  it('CP-A09: Debe rechazar crearAdministrador con cédula con letras', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation CrearAdmin($input: CrearAdministradorInput!) {
            crearAdministrador(input: $input) {
              id
            }
          }
        `,
        variables: {
          input: {
            cedula: 'abc1234567',
            nombre: 'Admin Letras',
            password: 'Admin123!'
          }
        }
      },
      { contextValue: { administrador: { id: 'fake-id', cedula: '1718056490' } } }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain('Cédula ecuatoriana inválida');
    }
  });

  it('CP-A10: Debe rechazar crearAdministrador con cédula con provincia inválida (>= 25)', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation CrearAdmin($input: CrearAdministradorInput!) {
            crearAdministrador(input: $input) {
              id
            }
          }
        `,
        variables: {
          input: {
            cedula: '3012345678',
            nombre: 'Admin Provincia',
            password: 'Admin123!'
          }
        }
      },
      { contextValue: { administrador: { id: 'fake-id', cedula: '1718056490' } } }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain('Cédula ecuatoriana inválida');
    }
  });

  it('CP-A11: Debe rechazar crearAdministrador con cédula con dígito verificador incorrecto', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation CrearAdmin($input: CrearAdministradorInput!) {
            crearAdministrador(input: $input) {
              id
            }
          }
        `,
        variables: {
          input: {
            cedula: '1718056491',
            nombre: 'Admin Dígito',
            password: 'Admin123!'
          }
        }
      },
      { contextValue: { administrador: { id: 'fake-id', cedula: '1718056490' } } }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain('Cédula ecuatoriana inválida');
    }
  });

  it('CP-A12: Debe rechazar crearAdministrador con cédula con longitud incorrecta', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation CrearAdmin($input: CrearAdministradorInput!) {
            crearAdministrador(input: $input) {
              id
            }
          }
        `,
        variables: {
          input: {
            cedula: '171805649',
            nombre: 'Admin Corta',
            password: 'Admin123!'
          }
        }
      },
      { contextValue: { administrador: { id: 'fake-id', cedula: '1718056490' } } }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain('Cédula ecuatoriana inválida');
    }
  });

  it('CP-A13: Debe rechazar login con cédula inválida', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation Login($input: LoginInput!) {
            login(input: $input) {
              token
            }
          }
        `,
        variables: {
          input: {
            cedula: 'abc1234567',
            password: 'Admin123!'
          }
        }
      },
      { contextValue: {} }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain('Cédula ecuatoriana inválida');
    }
  });
});

describe('Administrador Resolver - CRUD Completo (CP-A14 a CP-A19)', () => {
  let servidorApollo: ApolloServer;
  let tokenAdmin: string;
  let adminId: string;

  beforeAll(async () => {
    const schema = crearSchema();
    servidorApollo = new ApolloServer({ schema });
  });

  beforeEach(async () => {
    const admin = await crearAdminTest();
    tokenAdmin = generarToken(admin);
    adminId = admin._id.toString();
  });

  it('CP-A14: Debe crear administrador con cédula válida teniendo JWT', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation CrearAdmin($input: CrearAdministradorInput!) {
            crearAdministrador(input: $input) {
              id
              cedula
              nombre
            }
          }
        `,
        variables: {
          input: {
            cedula: '1722250295',
            nombre: 'Admin Nuevo',
            password: 'Admin123!'
          }
        }
      },
      { contextValue: { administrador: { id: adminId, cedula: '1718056490' } } }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const admin = resultado.body.singleResult.data?.crearAdministrador as any;
      expect(admin).toBeDefined();
      expect(admin.cedula).toBe('1722250295');
      expect(admin.nombre).toBe('Admin Nuevo');
    }
  });

  it('CP-A15: Debe rechazar crear administrador con cédula duplicada', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation CrearAdmin($input: CrearAdministradorInput!) {
            crearAdministrador(input: $input) {
              id
            }
          }
        `,
        variables: {
          input: {
            cedula: '1718056490',
            nombre: 'Admin Duplicado',
            password: 'Admin123!'
          }
        }
      },
      { contextValue: { administrador: { id: adminId, cedula: '1718056490' } } }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain('Ya existe un administrador con esa cédula');
    }
  });

  it('CP-A16: Debe obtener todos los administradores con JWT', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          query ObtenerAdministradores {
            obtenerAdministradores {
              id
              cedula
              nombre
            }
          }
        `
      },
      { contextValue: { administrador: { id: adminId, cedula: '1718056490' } } }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const admins = resultado.body.singleResult.data?.obtenerAdministradores as any[];
      expect(admins).toBeDefined();
      expect(admins.length).toBeGreaterThanOrEqual(1);
    }
  });

  it('CP-A17: Debe obtener administrador por ID con JWT', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          query ObtenerAdmin($id: ID!) {
            obtenerAdministrador(id: $id) {
              id
              cedula
              nombre
            }
          }
        `,
        variables: { id: adminId }
      },
      { contextValue: { administrador: { id: adminId, cedula: '1718056490' } } }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const admin = resultado.body.singleResult.data?.obtenerAdministrador as any;
      expect(admin).toBeDefined();
      expect(admin.id).toBe(adminId);
      expect(admin.cedula).toBe('1718056490');
    }
  });

  it('CP-A18: Debe actualizar nombre de administrador con JWT', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation ActualizarAdmin($id: ID!, $input: ActualizarAdministradorInput!) {
            actualizarAdministrador(id: $id, input: $input) {
              id
              nombre
            }
          }
        `,
        variables: {
          id: adminId,
          input: { nombre: 'Admin Actualizado' }
        }
      },
      { contextValue: { administrador: { id: adminId, cedula: '1718056490' } } }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const admin = resultado.body.singleResult.data?.actualizarAdministrador as any;
      expect(admin).toBeDefined();
      expect(admin.nombre).toBe('Admin Actualizado');
    }
  });

  it('CP-A19: Debe rechazar actualizar administrador inexistente', async () => {
    const resultado = await servidorApollo.executeOperation(
      {
        query: `
          mutation ActualizarAdmin($id: ID!, $input: ActualizarAdministradorInput!) {
            actualizarAdministrador(id: $id, input: $input) {
              id
            }
          }
        `,
        variables: {
          id: '507f1f77bcf86cd799439011',
          input: { nombre: 'No Existe' }
        }
      },
      { contextValue: { administrador: { id: adminId, cedula: '1718056490' } } }
    );

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain('Administrador no encontrado');
    }
  });

});
