import mongoose, { Document, Schema } from 'mongoose';

export interface IEvaluacionDocument extends Document {
  datos_docente: {
    cedula: string;
    nombre: string;
  };
  respuestas: {
    reactivo_codigo: string;
    valor: number;
  }[];
  resultados: {
    subtotales: {
      D1: number;
      D2: number;
      D3: number;
    };
    indices_dimensionales: {
      ID1: number;
      ID2: number;
      ID3: number;
    };
    IGPP: number;
    dimension_prioritaria: string;
  };
  version: string;
}

const DatosDocenteSchema = new Schema({
  cedula: { type: String, required: true },
  nombre: { type: String, required: true }
}, { _id: false });

const RespuestaSchema = new Schema({
  reactivo_codigo: { type: String, required: true },
  valor: { type: Number, required: true, min: 0, max: 4 }
}, { _id: false });

const SubtotalesSchema = new Schema({
  D1: { type: Number, required: true },
  D2: { type: Number, required: true },
  D3: { type: Number, required: true }
}, { _id: false });

const IndicesDimensionalesSchema = new Schema({
  ID1: { type: Number, required: true },
  ID2: { type: Number, required: true },
  ID3: { type: Number, required: true }
}, { _id: false });

const ResultadosSchema = new Schema({
  subtotales: { type: SubtotalesSchema, required: true },
  indices_dimensionales: { type: IndicesDimensionalesSchema, required: true },
  IGPP: { type: Number, required: true },
  dimension_prioritaria: { type: String, required: true }
}, { _id: false });

const EvaluacionSchema = new Schema<IEvaluacionDocument>({
  datos_docente: { type: DatosDocenteSchema, required: true },
  respuestas: [RespuestaSchema],
  resultados: { type: ResultadosSchema, required: true },
  version: { type: String, default: 'V6.6.22' }
}, {
  timestamps: true
});

export const EvaluacionModel = mongoose.model<IEvaluacionDocument>('Evaluacion', EvaluacionSchema);