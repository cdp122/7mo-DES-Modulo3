import { ApolloServer } from '@apollo/server';
import { expressMiddleware } from '@apollo/server/express4';
import { makeExecutableSchema } from '@graphql-tools/schema';
import cors from 'cors';
import express from 'express';
import { readFileSync } from 'fs';
import { join } from 'path';
import { administradorResolvers } from '../resolvers/administrador.resolver';
import { dimensionResolvers } from '../resolvers/dimension.resolver';
import { evaluacionResolvers } from '../resolvers/evaluacion.resolver';
import { extraerToken } from './jwt.middleware';

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

export const crearServidorGraphQL = async () => {
  const app = express();
  const schema = crearSchema();

  const servidorApollo = new ApolloServer({
    schema
  });

  await servidorApollo.start();

  app.use(
    '/graphql',
    // Temporal: permitir cualquier origen
    // La wea de google me anda cambiando el puerto por lo q al mandar la solicitud desde el front no me cogia el backend.
    cors<cors.CorsRequest>({
      origin: true,
      credentials: true
    }),
    express.json(),
    expressMiddleware(servidorApollo, {
      context: async ({ req }) => {
        return extraerToken(req);
      }
    })
  );

  return app;
};