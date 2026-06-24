import mongoose, { Document, Schema } from 'mongoose';

export interface IAdministradorDocument extends Document {
  cedula: string;
  nombre: string;
  email: string;
  password: string;
  version: string;
}

const AdministradorSchema = new Schema<IAdministradorDocument>({
  cedula: { type: String, required: true, unique: true },
  nombre: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  version: { type: String, default: 'V6.6.24b' }
}, {
  timestamps: true,
  collection: 'administradores'
});

export const AdministradorModel = mongoose.model<IAdministradorDocument>('Administrador', AdministradorSchema);