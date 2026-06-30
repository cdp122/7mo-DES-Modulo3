import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { AdministradorRepository } from '../../database/mongodb/repositories/administrador.repository';
import { CrearAdministradorDTO, ActualizarAdministradorDTO, LoginDTO } from '../../../../domain/models/administrador.model';

const administradorRepo = new AdministradorRepository();
const JWT_SECRET = process.env.JWT_SECRET || 'utn_fecyt_secret';

export const administradorResolvers = {
  Query: {
    obtenerAdministradores: async () => {
      return administradorRepo.obtenerTodos();
    },
    obtenerAdministrador: async (_: any, { id }: { id: string }) => {
      return administradorRepo.obtenerPorId(id);
    },
    administradorActual: async (_: any, __: any, context: any) => {
      if (!context.administrador) return null;
      return administradorRepo.obtenerPorId(context.administrador.id);
    },
    buscarAdminPorCedula: async (_: any, { cedula }: { cedula: string }) => {
      return administradorRepo.buscarPorCedula(cedula);
    },
  },
  Mutation: {
    login: async (_: any, { input }: { input: LoginDTO }) => {
      const administrador = await administradorRepo.buscarPorEmail(input.email);
      if (!administrador) {
        throw new Error('Credenciales inválidas');
      }

      const passwordValido = await bcrypt.compare(input.password, administrador.password);
      if (!passwordValido) {
        throw new Error('Credenciales inválidas');
      }

      const token = jwt.sign(
        { id: administrador.id, email: administrador.email },
        JWT_SECRET,
        { expiresIn: '24h' }
      );

      return { token, administrador };
    },

    crearAdministrador: async (_: any, { input }: { input: CrearAdministradorDTO }) => {
      const existe = await administradorRepo.buscarPorEmail(input.email);
      if (existe) {
        throw new Error('Ya existe un administrador con ese email');
      }
      const passwordHash = await bcrypt.hash(input.password, 10);
      return administradorRepo.crear({
        ...input,
        password: passwordHash,
        rol: 'admin',
        version: 'V6.6.24b'
      });
    },

    actualizarAdministrador: async (
      _: any,
      { id, input }: { id: string; input: ActualizarAdministradorDTO }
    ) => {
      const datos: ActualizarAdministradorDTO = {};
      if (input.nombre !== undefined && input.nombre !== null) datos.nombre = input.nombre;
      if (input.email !== undefined && input.email !== null) datos.email = input.email;
      // Solo re-hashea si se envió una contraseña nueva (no vacía)
      if (input.password && input.password.trim().length > 0) {
        datos.password = await bcrypt.hash(input.password, 10);
      }

      const actualizado = await administradorRepo.actualizar(id, datos);
      if (!actualizado) throw new Error('Administrador no encontrado');
      return actualizado;
    },

    cambiarRolAdministrador: async (
      _: any,
      { id, nuevoRol }: { id: string; nuevoRol: string },
      context: any
    ) => {
      // Un admin no puede cambiar su propio rol
      if (context.administrador && context.administrador.id === id) {
        throw new Error('No puedes cambiar tu propio rol');
      }
      if (!['admin', 'docente'].includes(nuevoRol)) {
        throw new Error('Rol inválido. Los valores permitidos son: admin, docente');
      }
      const actualizado = await administradorRepo.cambiarRol(id, nuevoRol);
      if (!actualizado) throw new Error('Administrador no encontrado');
      return actualizado;
    },
  }
};