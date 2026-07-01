import dotenv from 'dotenv';
import cors from 'cors';
dotenv.config();

import express from 'express'; 
import { connectDatabase } from './infrastructure/adapters/database/mongodb/connection'; 
import { crearServidorGraphQL } from './infrastructure/adapters/graphql/server/server'; 

const PORT = process.env.PORT || 4000;

const iniciarServidor = async () => {
  try {
    await connectDatabase(); 

    // Creamos la instancia base del servidor GraphQL
    const app = await crearServidorGraphQL(); 

    // HABILITACIÓN DE CORS GLOBAL ANTES DE ENRUTAR GRAPHQL
    // Esto evita que Chrome bloquee las peticiones con códigos 400 o 405
    app.use(cors({
      origin: '*', 
      credentials: true
    }));

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