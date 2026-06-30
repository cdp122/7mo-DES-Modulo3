import { GraphQLScalarType, Kind } from 'graphql';

function validarCedulaEcuatoriana(cedula: string): boolean {
  if (!/^\d{10}$/.test(cedula)) return false;

  const provincia = parseInt(cedula.substring(0, 2), 10);
  if (provincia < 1 || provincia > 24) return false;

  const digitos = cedula.split('').map(Number);
  const verificador = digitos.pop()!;

  let suma = 0;
  for (let i = 0; i < digitos.length; i++) {
    let resultado = digitos[i] * ((i % 2 === 0) ? 2 : 1);
    if (resultado >= 10) resultado -= 9;
    suma += resultado;
  }

  const digitoVerificador = (10 - (suma % 10)) % 10;
  return digitoVerificador === verificador;
}

export const CedulaEcuatorianaScalar = new GraphQLScalarType({
  name: 'CedulaEcuatoriana',
  description: 'Cédula de identidad ecuatoriana de 10 dígitos con dígito verificador válido',
  serialize(value: unknown): string {
    if (typeof value !== 'string') {
      throw new TypeError('La cédula debe ser un string');
    }
    if (!validarCedulaEcuatoriana(value)) {
      throw new Error('Cédula ecuatoriana inválida');
    }
    return value;
  },
  parseValue(value: unknown): string {
    if (typeof value !== 'string') {
      throw new TypeError('La cédula debe ser un string');
    }
    if (!validarCedulaEcuatoriana(value)) {
      throw new Error('Cédula ecuatoriana inválida');
    }
    return value;
  },
  parseLiteral(ast): string {
    if (ast.kind !== Kind.STRING) {
      throw new TypeError('La cédula debe ser un string');
    }
    if (!validarCedulaEcuatoriana(ast.value)) {
      throw new Error('Cédula ecuatoriana inválida');
    }
    return ast.value;
  }
});

export function esCedulaEcuatorianaValida(cedula: string): boolean {
  return validarCedulaEcuatoriana(cedula);
}
