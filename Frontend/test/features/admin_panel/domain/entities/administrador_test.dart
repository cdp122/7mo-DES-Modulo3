import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/admin_panel/domain/entities/administrador.dart';

void main() {
  // ─── CP-FE-A01 y CP-FE-A02: fromJson ─────────────────────────────
  group('AdministradorEntity.fromJson', () {
    test('CP-FE-A01: Parsea JSON con todos los campos', () {
      final json = {
        'id': 'admin-001',
        'cedula': '1718056490',
        'nombre': 'Admin Test',
        'email': 'admin@test.com',
        'rol': 'admin',
      };

      final entity = AdministradorEntity.fromJson(json);

      expect(entity.id, 'admin-001');
      expect(entity.cedula, '1718056490');
      expect(entity.nombre, 'Admin Test');
      expect(entity.email, 'admin@test.com');
      expect(entity.rol, 'admin');
    });

    test('CP-FE-A02: Usa valor por defecto para email y rol cuando son null', () {
      final json = {
        'id': 'admin-002',
        'cedula': '1718056490',
        'nombre': 'Admin Sin Email',
      };

      final entity = AdministradorEntity.fromJson(json);

      expect(entity.email, '');
      expect(entity.rol, 'admin');
    });
  });

  // ─── CP-FE-A03 y CP-FE-A04: esAdmin ──────────────────────────────
  group('AdministradorEntity.esAdmin', () {
    test('CP-FE-A03: Retorna true cuando rol es "admin"', () {
      const entity = AdministradorEntity(
        id: '1',
        cedula: '1718056490',
        nombre: 'Admin',
        email: '',
        rol: 'admin',
      );

      expect(entity.esAdmin, isTrue);
    });

    test('CP-FE-A04: Retorna false cuando rol no es "admin"', () {
      const entity = AdministradorEntity(
        id: '1',
        cedula: '1718056490',
        nombre: 'Docente',
        email: '',
        rol: 'docente',
      );

      expect(entity.esAdmin, isFalse);
    });
  });

  // ─── CP-FE-A05: copyWith ──────────────────────────────────────────
  group('AdministradorEntity.copyWith', () {
    test('CP-FE-A05: Crea copia con valores modificados manteniendo el resto', () {
      const original = AdministradorEntity(
        id: '1',
        cedula: '1718056490',
        nombre: 'Original',
        email: 'original@test.com',
        rol: 'admin',
      );

      final copia = original.copyWith(nombre: 'Modificado', email: 'nuevo@test.com');

      expect(copia.id, '1'); // sin cambios
      expect(copia.cedula, '1718056490'); // sin cambios
      expect(copia.nombre, 'Modificado');
      expect(copia.email, 'nuevo@test.com');
      expect(copia.rol, 'admin'); // sin cambios
    });
  });

  // ─── CP-FE-A06 y CP-FE-A07: operator == ───────────────────────────
  group('AdministradorEntity equality', () {
    test('CP-FE-A06: Dos entidades con mismos valores son iguales', () {
      const a = AdministradorEntity(
        id: '1',
        cedula: '1718056490',
        nombre: 'Admin',
        email: 'a@b.com',
        rol: 'admin',
      );
      const b = AdministradorEntity(
        id: '1',
        cedula: '1718056490',
        nombre: 'Admin',
        email: 'a@b.com',
        rol: 'admin',
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('CP-FE-A07: Dos entidades con valores diferentes no son iguales', () {
      const a = AdministradorEntity(
        id: '1',
        cedula: '1718056490',
        nombre: 'Admin A',
        email: 'a@b.com',
        rol: 'admin',
      );
      const b = AdministradorEntity(
        id: '2',
        cedula: '1722250295',
        nombre: 'Admin B',
        email: 'b@c.com',
        rol: 'admin',
      );

      expect(a, isNot(equals(b)));
    });
  });
}
