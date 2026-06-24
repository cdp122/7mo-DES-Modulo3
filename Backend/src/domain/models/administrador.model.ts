export interface Administrador {
  id: string;
  cedula: string;
  nombre: string;
  email: string;
  password: string;
  version: string;
}

export interface CrearAdministradorDTO {
  cedula: string;
  nombre: string;
  email: string;
  password: string;
}

export interface LoginDTO {
  email: string;
  password: string;
}