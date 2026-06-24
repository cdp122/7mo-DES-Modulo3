import mongoose, { Document, Schema } from 'mongoose';

export interface IDimensionDocument extends Document {
  orden: number;
  nombre: string;
  descripcion: string;
  fundamento: string;
  reactivos: {
    reactivo_codigo: string;
    enunciado: string;
    pista?: string;
  }[];
  version: string;
}

const ReactivoSchema = new Schema({
  reactivo_codigo: { type: String, required: true },
  enunciado: { type: String, required: true },
  pista: { type: String }
}, { _id: false });

const DimensionSchema = new Schema<IDimensionDocument>({
  orden: { type: Number, required: true, unique: true },
  nombre: { type: String, required: true },
  descripcion: { type: String, required: true },
  fundamento: { type: String, required: true },
  reactivos: [ReactivoSchema],
  version: { type: String, default: 'V6.6.22' }
}, {
  timestamps: true,
  collection: 'dimensiones'
});

export const DimensionModel = mongoose.model<IDimensionDocument>('Dimension', DimensionSchema);