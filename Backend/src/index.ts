import dotenv from 'dotenv';
dotenv.config();

import express from 'express';
import { connectDatabase } from './infrastructure/adapters/database/mongodb/connection';
import { crearServidorGraphQL } from './infrastructure/adapters/graphql/server/server';

const PORT = process.env.PORT || 4000;

const iniciarServidor = async () => {
  try {
    await connectDatabase();

    const app = await crearServidorGraphQL();

    app.get('/health', (_req, res) => {
      res.json({ status: 'OK', timestamp: new Date().toISOString() });
    });

    app.listen(PORT, () => {
      console.log(`Servidor ejecutándose en http://localhost:${PORT}`);
      console.log(`GraphQL disponible en http://localhost:${PORT}/graphql`);
    });
  } catch (error) {
    console.error('Error al iniciar el servidor:', error);
    process.exit(1);
  }
};

iniciarServidor();