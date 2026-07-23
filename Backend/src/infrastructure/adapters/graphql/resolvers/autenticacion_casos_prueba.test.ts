import { describe, it, expect, beforeAll, beforeEach } from 'vitest';
import { ApolloServer } from '@apollo/server';
import { makeExecutableSchema } from '@graphql-tools/schema';
import { readFileSync } from 'fs';
import { join } from 'path';
import bcrypt from 'bcryptjs';
import { administradorResolvers } from './administrador.resolver';
import { evaluacionResolvers } from './evaluacion.resolver';
import { AdministradorModel } from '../../database/mongodb/models/administrador.schema';

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
      },
      Mutation: {
        ...administradorResolvers.Mutation,
      }
    }
  });
};

describe('Casos de Prueba Unitarios - Login y Autenticación (CP1 a CP5)', () => {
  let servidorApollo: ApolloServer;

  beforeAll(async () => {
    const schema = crearSchema();
    servidorApollo = new ApolloServer({ schema });
  });

  beforeEach(async () => {
    // Seed del administrador de pruebas (CP3, CP4, CP5)
    // Cédula válida: "1718056490", Contraseña correcta: "admin2026*"
    const passwordHash = await bcrypt.hash('admin2026*', 10);
    await AdministradorModel.create({
      cedula: '1718056490',
      nombre: 'Administrador Test',
      password: passwordHash,
      version: 'V6.6.30'
    });
  });


  // CP1: Cédula inválida (falla de longitud o formato alfanumérico)
  it('CP1: Debe rechazar la verificación de una cédula inválida por longitud', async () => {
    const resultado = await servidorApollo.executeOperation({
      query: `
        query BuscarAdminPorCedula($cedula: CedulaEcuatoriana!) {
          buscarAdminPorCedula(cedula: $cedula) {
            id
            cedula
          }
        }
      `,
      variables: {
        cedula: '17180564' // Longitud de 8 dígitos (CENV<01>)
      }
    });

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain('Cédula ecuatoriana inválida');
    }
  });

  // CP1b: Cédula con dígito verificador incorrecto
  it('CP1b: Debe rechazar la verificación de una cédula con dígito verificador incorrecto', async () => {
    const resultado = await servidorApollo.executeOperation({
      query: `
        query BuscarAdminPorCedula($cedula: CedulaEcuatoriana!) {
          buscarAdminPorCedula(cedula: $cedula) {
            id
            cedula
          }
        }
      `,
      variables: {
        cedula: '1718056491' // Dígito verificador 1 incorrecto (debería ser 0) (CENV<04>)
      }
    });

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain('Cédula ecuatoriana inválida');
    }
  });

  // CP2: Cédula regular/docente (no existe en Administradores, pero es cédula válida)
  it('CP2: Debe retornar null indicando rol de docente regular al buscar un admin por cédula', async () => {
    const resultado = await servidorApollo.executeOperation({
      query: `
        query BuscarAdminPorCedula($cedula: CedulaEcuatoriana!) {
          buscarAdminPorCedula(cedula: $cedula) {
            id
            cedula
            nombre
          }
        }
      `,
      variables: {
        cedula: '1002003000' // Cédula ecuatoriana válida pero no registrada como admin (CEV<01> + CEV<02>)
      }
    });

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      expect(resultado.body.singleResult.data?.buscarAdminPorCedula).toBeNull();
    }
  });

  // CP3: Cédula de Administrador válida
  it('CP3: Debe retornar los datos del administrador al buscar una cédula registrada como admin', async () => {
    const resultado = await servidorApollo.executeOperation({
      query: `
        query BuscarAdminPorCedula($cedula: CedulaEcuatoriana!) {
          buscarAdminPorCedula(cedula: $cedula) {
            id
            cedula
            nombre
          }
        }
      `,
      variables: {
        cedula: '1718056490' // Administrador registrado (CEV<01> + CEV<03>)
      }
    });

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const admin = resultado.body.singleResult.data?.buscarAdminPorCedula;
      expect(admin).toBeDefined();
      expect(admin.cedula).toBe('1718056490');
      expect(admin.nombre).toBe('Administrador Test');
    }
  });

  // CP4: Login fallido (contraseña incorrecta para Administrador)
  it('CP4: Debe denegar el login de administrador si la contraseña es incorrecta', async () => {
    const resultado = await servidorApollo.executeOperation({
      query: `
        mutation Login($input: LoginInput!) {
          login(input: $input) {
            token
            administrador {
              id
              cedula
            }
          }
        }
      `,
      variables: {
        input: {
          cedula: '1718056490',
          password: 'passwordErroneo12' // Contraseña inválida (CENV<08>)
        }
      }
    });

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeDefined();
      expect(resultado.body.singleResult.errors?.[0]?.message).toContain('Credenciales inválidas');
    }
  });

  // CP5: Login exitoso (contraseña correcta para Administrador)
  it('CP5: Debe otorgar el Token JWT si la contraseña de administrador es correcta', async () => {
    const resultado = await servidorApollo.executeOperation({
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
          password: 'admin2026*' // Contraseña válida (CEV<06>)
        }
      }
    });

    expect(resultado.body.kind).toBe('single');
    if (resultado.body.kind === 'single') {
      expect(resultado.body.singleResult.errors).toBeUndefined();
      const loginPayload = resultado.body.singleResult.data?.login as any;
      expect(loginPayload).toBeDefined();
      expect(loginPayload.token).toBeDefined();
      expect(loginPayload.token.length).toBeGreaterThan(0);
      expect(loginPayload.administrador.cedula).toBe('1718056490');
      expect(loginPayload.administrador.nombre).toBe('Administrador Test');
    }
  });
});
