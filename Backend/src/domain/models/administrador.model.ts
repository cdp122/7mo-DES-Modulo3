export interface Administrador {
  id: string;
  cedula: string;
  nombre: string;
  password: string;
  version: string;
}

export interface CrearAdministradorDTO {
  cedula: string;
  nombre: string;
  password: string;
}

export interface ActualizarAdministradorDTO {
  nombre?: string;
  password?: string; // pre-hashed by the resolver if provided
}

export interface LoginDTO {
  cedula: string;
  password: string;
}