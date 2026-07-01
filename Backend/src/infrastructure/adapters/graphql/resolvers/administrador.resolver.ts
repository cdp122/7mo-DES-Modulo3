import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { AdministradorRepository } from '../../database/mongodb/repositories/administrador.repository';
import { CrearAdministradorDTO, ActualizarAdministradorDTO, LoginDTO } from '../../../../domain/models/administrador.model';

const administradorRepo = new AdministradorRepository();
const JWT_SECRET = process.env.JWT_SECRET || 'utn_fecyt_secret';

export const administradorResolvers = {
  Query: {
    obtenerAdministradores: async (_: any, __: any, context: any) => {
      if (!context.administrador) {
        throw new Error('No autenticado. Se requiere token JWT.');
      }
      return administradorRepo.obtenerTodos();
    },
    obtenerAdministrador: async (_: any, { id }: { id: string }, context: any) => {
      if (!context.administrador) {
        throw new Error('No autenticado. Se requiere token JWT.');
      }
      return administradorRepo.obtenerPorId(id);
    },
    administradorActual: async (_: any, __: any, context: any) => {
      if (!context.administrador) return null;
      return administradorRepo.obtenerPorId(context.administrador.id);
    },
    buscarAdminPorCedula: async (_: any, { cedula }: { cedula: string }, context: any) => {
      return administradorRepo.buscarPorCedula(cedula);
    },
  },
  Mutation: {
    login: async (_: any, { input }: { input: LoginDTO }) => {
      const administrador = await administradorRepo.buscarPorCedula(input.cedula);
      if (!administrador) {
        throw new Error('Credenciales inválidas');
      }

      const passwordValido = await bcrypt.compare(input.password, administrador.password);
      if (!passwordValido) {
        throw new Error('Credenciales inválidas');
      }

      const token = jwt.sign(
        { id: administrador.id, cedula: administrador.cedula },
        JWT_SECRET,
        { expiresIn: '24h' }
      );

      return { token, administrador };
    },

    crearAdministrador: async (_: any, { input }: { input: CrearAdministradorDTO }, context: any) => {
      if (!context.administrador) {
        throw new Error('No autenticado. Se requiere token JWT.');
      }
      const existe = await administradorRepo.buscarPorCedula(input.cedula);
      if (existe) {
        throw new Error('Ya existe un administrador con esa cédula');
      }
      const passwordHash = await bcrypt.hash(input.password, 10);
      return administradorRepo.crear({
        ...input,
        password: passwordHash,
        version: 'V6.6.24b'
      });
    },

    actualizarAdministrador: async (
      _: any,
      { id, input }: { id: string; input: ActualizarAdministradorDTO },
      context: any
    ) => {
      if (!context.administrador) {
        throw new Error('No autenticado. Se requiere token JWT.');
      }
      const datos: ActualizarAdministradorDTO = {};
      if (input.nombre !== undefined && input.nombre !== null) datos.nombre = input.nombre;
      if (input.password && input.password.trim().length > 0) {
        datos.password = await bcrypt.hash(input.password, 10);
      }

      const actualizado = await administradorRepo.actualizar(id, datos);
      if (!actualizado) throw new Error('Administrador no encontrado');
      return actualizado;
    },
  }
};