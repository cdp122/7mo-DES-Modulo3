import { describe, it, expect } from 'vitest';
import { CedulaEcuatorianaScalar, esCedulaEcuatorianaValida } from './cedulaEcuatoriana';

// ─── CP-CE01 a CP-CE08: Función de validación directa ────────────────────

describe('esCedulaEcuatorianaValida - Validación directa (CP-CE01 a CP-CE08)', () => {
  it('CP-CE01: Cédula válida "1718056490" retorna true', () => {
    expect(esCedulaEcuatorianaValida('1718056490')).toBe(true);
  });

  it('CP-CE02: Cédula con letras retorna false', () => {
    expect(esCedulaEcuatorianaValida('abc1234567')).toBe(false);
  });

  it('CP-CE03: Cédula con provincia > 24 retorna false', () => {
    expect(esCedulaEcuatorianaValida('3012345678')).toBe(false);
  });

  it('CP-CE04: Cédula con longitud < 10 retorna false', () => {
    expect(esCedulaEcuatorianaValida('171805649')).toBe(false);
  });

  it('CP-CE05: Cédula con longitud > 10 retorna false', () => {
    expect(esCedulaEcuatorianaValida('17180564901')).toBe(false);
  });

  it('CP-CE06: Cédula con dígito verificador incorrecto retorna false', () => {
    expect(esCedulaEcuatorianaValida('1718056491')).toBe(false);
  });

  it('CP-CE07: Cédula con provincia 00 retorna false', () => {
    expect(esCedulaEcuatorianaValida('0012345678')).toBe(false);
  });

  it('CP-CE08: Cédula vacía retorna false', () => {
    expect(esCedulaEcuatorianaValida('')).toBe(false);
  });
});

// ─── CP-CE09 y CP-CE10: Scalar GraphQL ───────────────────────────────────

describe('CedulaEcuatorianaScalar - Scalar GraphQL (CP-CE09 y CP-CE10)', () => {
  it('CP-CE09: serialize con cédula válida retorna el string sin modificar', () => {
    const resultado = CedulaEcuatorianaScalar.serialize('1718056490');
    expect(resultado).toBe('1718056490');
  });

  it('CP-CE10: parseValue con cédula inválida lanza Error', () => {
    expect(() => CedulaEcuatorianaScalar.parseValue('1718056491')).toThrow('Cédula ecuatoriana inválida');
  });
});
