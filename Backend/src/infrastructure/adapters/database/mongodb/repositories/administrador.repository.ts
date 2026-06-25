import { IAdministradorRepository } from '../../../../../domain/repositories/administrador.repository.port';
import { Administrador } from '../../../../../domain/models/administrador.model';
import { AdministradorModel, IAdministradorDocument } from '../models/administrador.schema';

export class AdministradorRepository implements IAdministradorRepository {
  async buscarPorEmail(email: string): Promise<Administrador | null> {
    const doc = await AdministradorModel.findOne({ email });
    return this.mapearADominio(doc);
  }

  async buscarPorCedula(cedula: string): Promise<Administrador | null> {
    const doc = await AdministradorModel.findOne({ cedula });
    return this.mapearADominio(doc);
  }

  async crear(administrador: Omit<Administrador, 'id'>): Promise<Administrador> {
    const doc = new AdministradorModel(administrador);
    const guardado = await doc.save();
    return this.mapearADominio(guardado)!;
  }

  async obtenerPorId(id: string): Promise<Administrador | null> {
    const doc = await AdministradorModel.findById(id);
    return this.mapearADominio(doc);
  }

  private mapearADominio(doc: IAdministradorDocument | null): Administrador | null {
    if (!doc) return null;
    return {
      id: doc._id.toString(),
      cedula: doc.cedula,
      nombre: doc.nombre,
      email: doc.email,
      password: doc.password,
      version: doc.version
    };
  }
}