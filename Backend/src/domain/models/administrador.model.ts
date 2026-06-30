export interface Administrador {
  id: string;
  cedula: string;
  nombre: string;
  email: string;
  password: string;
  rol: string; // 'admin' | 'docente'
  version: string;
}

export interface CrearAdministradorDTO {
  cedula: string;
  nombre: string;
  email: string;
  password: string;
}

export interface ActualizarAdministradorDTO {
  nombre?: string;
  email?: string;
  password?: string; // pre-hashed by the resolver if provided
}

export interface LoginDTO {
  email: string;
  password: string;
}