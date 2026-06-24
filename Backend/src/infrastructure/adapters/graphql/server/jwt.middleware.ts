import jwt from 'jsonwebtoken';
import { IncomingMessage } from 'http';

const JWT_SECRET = process.env.JWT_SECRET || 'utn_fecyt_secret';

export interface ContextoGraphQL {
  administrador?: {
    id: string;
    email: string;
  };
}

export const extraerToken = (req: IncomingMessage): ContextoGraphQL => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return {};
  }

  const token = authHeader.split(' ')[1];
  try {
    const payload = jwt.verify(token, JWT_SECRET) as { id: string; email: string };
    return { administrador: payload };
  } catch (error) {
    return {};
  }
};