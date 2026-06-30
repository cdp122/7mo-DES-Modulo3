import { Administrador, ActualizarAdministradorDTO } from '../models/administrador.model';

export interface IAdministradorRepository {
  buscarPorCedula(cedula: string): Promise<Administrador | null>;
  crear(administrador: Omit<Administrador, 'id'>): Promise<Administrador>;
  obtenerPorId(id: string): Promise<Administrador | null>;
  obtenerTodos(): Promise<Administrador[]>;
  actualizar(id: string, datos: ActualizarAdministradorDTO): Promise<Administrador | null>;
}