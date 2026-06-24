export interface Reactivo {
  reactivo_codigo: string;
  enunciado: string;
  pista?: string;
}

export interface Dimension {
  id: string;
  orden: number;
  nombre: string;
  descripcion: string;
  fundamento: string;
  reactivos: Reactivo[];
  version: string;
}

export interface CrearDimensionDTO {
  orden: number;
  nombre: string;
  descripcion: string;
  fundamento: string;
  reactivos: Reactivo[];
}

export interface ActualizarDimensionDTO {
  nombre?: string;
  descripcion?: string;
  fundamento?: string;
  reactivos?: Reactivo[];
}

export interface CrearReactivoDTO {
  reactivo_codigo: string;
  enunciado: string;
  pista?: string;
}