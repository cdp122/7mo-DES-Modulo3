import mongoose from 'mongoose';

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/7mo_des_modulo3';

export const connectDatabase = async (): Promise<void> => {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log('Conectado a MongoDB exitosamente');
  } catch (error) {
    console.error('Error al conectar a MongoDB:', error);
    process.exit(1);
  }
};

mongoose.connection.on('error', (error) => {
  console.error('Error en la conexión de MongoDB:', error);
});

mongoose.connection.on('disconnected', () => {
  console.log('Desconectado de MongoDB');
});