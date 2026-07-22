import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/admin_panel/domain/entities/resultados_evaluacion.dart';

void main() {
  // ─── CP-FE-R01: InterpretacionDimensionEntity.fromJson ────────────
  group('InterpretacionDimensionEntity.fromJson', () {
    test('CP-FE-R01: Parsea JSON correctamente con todos los campos', () {
      final json = {
        'nombre': 'Participación infantil',
        'clave': 'D1',
        'puntaje': 16,
        'maximo': 20,
        'porcentaje': 80.0,
        'nivel': 'Participación auténtica',
      };

      final entity = InterpretacionDimensionEntity.fromJson(json);

      expect(entity.nombre, 'Participación infantil');
      expect(entity.clave, 'D1');
      expect(entity.puntaje, 16.0);
      expect(entity.maximo, 20.0);
      expect(entity.porcentaje, 80.0);
      expect(entity.nivel, 'Participación auténtica');
    });
  });

  // ─── CP-FE-R02 y CP-FE-R03: ResultadosInterpretadosEntity.fromJson ──
  group('ResultadosInterpretadosEntity.fromJson', () {
    test('CP-FE-R02: Parsea JSON completo con dimensiones', () {
      final json = {
        'evaluacion_id': 'eval-001',
        'docente_cedula': '1718056490',
        'docente_nombre': 'Juan Pérez',
        'dimensiones': [
          {
            'nombre': 'Dimensión 1',
            'clave': 'D1',
            'puntaje': 16,
            'maximo': 20,
            'porcentaje': 80.0,
            'nivel': 'Participación auténtica',
          },
          {
            'nombre': 'Dimensión 2',
            'clave': 'D2',
            'puntaje': 12,
            'maximo': 20,
            'porcentaje': 60.0,
            'nivel': 'Participación en desarrollo',
          },
          {
            'nombre': 'Dimensión 3',
            'clave': 'D3',
            'puntaje': 19,
            'maximo': 20,
            'porcentaje': 95.0,
            'nivel': 'Participación auténtica',
          },
        ],
        'puntaje_total': 47,
        'maximo_total': 60,
        'IGPP': 78.33,
        'nivel_general': 'Participación auténtica',
        'dimension_prioritaria': 'Voz del niño',
      };

      final entity = ResultadosInterpretadosEntity.fromJson(json);

      expect(entity.evaluacionId, 'eval-001');
      expect(entity.docenteCedula, '1718056490');
      expect(entity.docenteNombre, 'Juan Pérez');
      expect(entity.dimensiones.length, 3);
      expect(entity.puntajeTotal, 47.0);
      expect(entity.maximoTotal, 60.0);
      expect(entity.igpp, 78.33);
      expect(entity.nivelGeneral, 'Participación auténtica');
      expect(entity.dimensionPrioritaria, 'Voz del niño');
    });

    test('CP-FE-R03: Usa valor por defecto "Docente" cuando docente_nombre es null', () {
      final json = {
        'evaluacion_id': 'eval-002',
        'docente_cedula': '1718056490',
        'dimensiones': [],
        'puntaje_total': 0,
        'maximo_total': 0,
        'IGPP': 0,
        'nivel_general': 'Planificación adultocéntrica',
        'dimension_prioritaria': 'D1',
      };

      final entity = ResultadosInterpretadosEntity.fromJson(json);

      expect(entity.docenteNombre, 'Docente');
    });
  });

  // ─── CP-FE-R04 y CP-FE-R05: ResumenGeneralEntity.fromJson ──────────
  group('ResumenGeneralEntity.fromJson', () {
    test('CP-FE-R04: Parsea JSON correctamente', () {
      final json = {
        'total_evaluaciones': 10,
        'promedio_D1': 15.5,
        'promedio_D2': 12.3,
        'promedio_D3': 18.7,
        'promedio_IGPP': 77.5,
        'nivel_general': 'Participación auténtica',
        'dimensiones': [],
      };

      final entity = ResumenGeneralEntity.fromJson(json);

      expect(entity.totalEvaluaciones, 10);
      expect(entity.promedioD1, 15.5);
      expect(entity.promedioD2, 12.3);
      expect(entity.promedioD3, 18.7);
      expect(entity.promedioIGPP, 77.5);
      expect(entity.nivelGeneral, 'Participación auténtica');
    });

    test('CP-FE-R05: Parsea lista de dimensiones correctamente', () {
      final json = {
        'total_evaluaciones': 5,
        'promedio_D1': 14.0,
        'promedio_D2': 11.0,
        'promedio_D3': 17.0,
        'promedio_IGPP': 70.0,
        'nivel_general': 'Participación en desarrollo',
        'dimensiones': [
          {
            'nombre': 'Participación infantil',
            'clave': 'D1',
            'puntaje': 14.0,
            'maximo': 20,
            'porcentaje': 70.0,
            'nivel': 'Participación en desarrollo',
          },
          {
            'nombre': 'Voz del niño',
            'clave': 'D2',
            'puntaje': 11.0,
            'maximo': 20,
            'porcentaje': 55.0,
            'nivel': 'Participación en desarrollo',
          },
        ],
      };

      final entity = ResumenGeneralEntity.fromJson(json);

      expect(entity.dimensiones.length, 2);
      expect(entity.dimensiones[0].nombre, 'Participación infantil');
      expect(entity.dimensiones[0].porcentaje, 70.0);
      expect(entity.dimensiones[1].clave, 'D2');
    });
  });
}
