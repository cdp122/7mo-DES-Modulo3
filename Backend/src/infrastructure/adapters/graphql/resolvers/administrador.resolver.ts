import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { AdministradorRepository } from '../../database/mongodb/repositories/administrador.repository';
import { CrearAdministradorDTO, LoginDTO } from '../../../../domain/models/administrador.model';

const administradorRepo = new AdministradorRepository();
const JWT_SECRET = process.env.JWT_SECRET || 'utn_fecyt_secret';

export const administradorResolvers = {
  Query: {
    obtenerAdministrador: async (_: any, { id }: { id: string }) => {
      return administradorRepo.obtenerPorId(id);
    },
    administradorActual: async (_: any, __: any, context: any) => {
      if (!context.administrador) return null;
      return administradorRepo.obtenerPorId(context.administrador.id);
    }
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

      return {
        token,
        administrador
      };
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
        version: 'V6.6.22'
      });
    }
  }
};