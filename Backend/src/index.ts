import dotenv from 'dotenv';
import cors from 'cors'; //[cite: 44]
dotenv.config(); //[cite: 44]

import express from 'express'; //[cite: 44]
import { connectDatabase } from './infrastructure/adapters/database/mongodb/connection'; //[cite: 44]
import { crearServidorGraphQL } from './infrastructure/adapters/graphql/server/server'; //[cite: 44]

const PORT = process.env.PORT || 4000; //[cite: 44]

const iniciarServidor = async () => {
  try {
    await connectDatabase(); //[cite: 44]

    // Creamos la instancia base del servidor GraphQL
    const app = await crearServidorGraphQL(); //[cite: 44]

    // HABILITACIÓN DE CORS GLOBAL ANTES DE ENRUTAR GRAPHQL
    // Esto evita que Chrome bloquee las peticiones con códigos 400 o 405
    app.use(cors({
      origin: '*', 
      credentials: true
    }));

    app.get('/health', (_req, res) => {
      res.json({ status: 'OK', timestamp: new Date().toISOString() }); //[cite: 44]
    });

    app.listen(PORT, () => {
      console.log(`Servidor ejecutándose en http://localhost:${PORT}`); //[cite: 44]
      console.log(`GraphQL disponible en http://localhost:${PORT}/graphql`); //[cite: 44]
    });
  } catch (error) {
    console.error('Error al iniciar el servidor:', error); //[cite: 44]
    process.exit(1); //[cite: 44]
  }
};

iniciarServidor(); //[cite: 44]