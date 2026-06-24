export interface Administrador {
  id: string;
  nombre: string;
  email: string;
  password: string;
  version: string;
}

export interface CrearAdministradorDTO {
  nombre: string;
  email: string;
  password: string;
}

export interface LoginDTO {
  email: string;
  password: string;
}