import { Administrador } from '../models/administrador.model';

export interface IAdministradorRepository {
  buscarPorEmail(email: string): Promise<Administrador | null>;
  crear(administrador: Omit<Administrador, 'id'>): Promise<Administrador>;
  obtenerPorId(id: string): Promise<Administrador | null>;
}