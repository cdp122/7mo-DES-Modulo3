// Pruebas unitarias/widget de Dimension2Screen (Encuesta - Dimensión 2: "Voz del niño")
//
// Cubre los casos de prueba concretos documentados en:
// Frontend/docs/V6.7.15 Pruebas Encuesta Dimension 2 - Pablo Jimenez.md
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/core/network/graphql_service.dart';
import 'package:frontend/features/admin_panel/data/repositories/preguntas_repository.dart';
import 'package:frontend/features/admin_panel/domain/entities/dimension.dart';
import 'package:frontend/features/admin_panel/domain/entities/reactivo.dart';
import 'package:frontend/features/admin_panel/presentation/controller/preguntas_cubit.dart';
import 'package:frontend/features/encuesta/presentation/screens/dimension_2_screen.dart';

/// Repositorio en memoria: evita llamadas GraphQL reales y entrega
/// determinísticamente las 3 dimensiones (5 reactivos cada una).
class _FakePreguntasRepository extends PreguntasRepository {
  _FakePreguntasRepository() : super(GraphQLService(dio: Dio()));

  @override
  Future<List<DimensionEntity>> obtenerDimensiones() async {
    return [_dimension(1), _dimension(2), _dimension(3)];
  }

  DimensionEntity _dimension(int orden) {
    return DimensionEntity(
      id: 'dim-$orden',
      orden: orden,
      nombre: 'Dimensión $orden',
      descripcion: 'Descripción $orden',
      fundamento: 'Fundamento $orden',
      reactivos: List.generate(
        5,
        (i) => ReactivoEntity(
          codigo: '$orden.${i + 1}',
          enunciado: 'Enunciado ${i + 1} de la dimensión $orden',
          pista: i == 0 ? 'Pista de ejemplo' : null,
        ),
      ),
    );
  }
}

/// Arma un GoRouter mínimo y aislado con las 3 rutas relevantes para el
/// flujo de encuesta (d1/d2/d3), sin depender del router completo de la app.
Widget _buildApp({required Map<String, int> respuestasAcumuladas}) {
  final cubit = PreguntasCubit(_FakePreguntasRepository())..cargarPreguntas();

  final router = GoRouter(
    initialLocation: '/encuesta/d2',
    routes: [
      GoRoute(
        path: '/encuesta/d1',
        builder: (context, state) => const Scaffold(body: Text('PANTALLA_D1')),
      ),
      GoRoute(
        path: '/encuesta/d2',
        builder: (context, state) => BlocProvider<PreguntasCubit>.value(
          value: cubit,
          child: Dimension2Screen(
            cedulaDocente: '1710034065',
            respuestasAcumuladas: respuestasAcumuladas,
          ),
        ),
      ),
      GoRoute(
        path: '/encuesta/d3',
        builder: (context, state) => const Scaffold(body: Text('PANTALLA_D3')),
      ),
    ],
  );

  return MaterialApp.router(routerConfig: router);
}

/// Monta la app fijando un viewport móvil (< 600 de ancho lógico), que es el
/// layout objetivo principal de la app (Flutter mobile-first, ver README).
/// Con el viewport por defecto de las pruebas (800px) el widget cambia a un
/// layout de tablet/escritorio con una presentación distinta de las opciones.
Future<void> _pumpApp(WidgetTester tester, {required Map<String, int> respuestasAcumuladas}) async {
  // 599 de ancho lógico: justo por debajo del umbral "esMovil" (600) para que
  // se use el layout móvil (con indicador de check), pero con suficiente
  // ancho para que la fila de botones "Regresar"/"Siguiente" no desborde.
  tester.view.physicalSize = const Size(599, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(_buildApp(respuestasAcumuladas: respuestasAcumuladas));
}

/// Sustituye a `pumpAndSettle()`: Dimension2Screen tiene un AnimationController
/// en bucle infinito (flotación del oso), por lo que nunca deja de "solicitar"
/// frames y pumpAndSettle jamás termina. Bombeamos un número fijo de frames.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  group('Dimension2Screen — Responder reactivos de la Dimensión 2', () {
    testWidgets(
      'CP-01: sin seleccionar respuesta, "Siguiente" muestra advertencia y no avanza',
      (tester) async {
        await _pumpApp(tester, respuestasAcumuladas: {});
        await _settle(tester);

        expect(find.text('Pregunta 1/5'), findsOneWidget);

        await tester.tap(find.text('Siguiente'));
        await tester.pump();

        expect(
          find.text('Por favor, selecciona una respuesta antes de continuar'),
          findsOneWidget,
        );
        expect(find.text('Pregunta 1/5'), findsOneWidget);
      },
    );

    testWidgets(
      'CP-02: seleccionar un valor válido (2 - "En desarrollo") habilita avanzar a la pregunta 2',
      (tester) async {
        await _pumpApp(tester, respuestasAcumuladas: {});
        await _settle(tester);

        await tester.tap(find.text('En desarrollo'));
        await tester.pump();
        await tester.tap(find.text('Siguiente'));
        await _settle(tester);

        expect(find.text('Pregunta 2/5'), findsOneWidget);
      },
    );

    testWidgets(
      'CP-03: valor límite inferior (0 - "Ausente") es válido y permite avanzar',
      (tester) async {
        await _pumpApp(tester, respuestasAcumuladas: {});
        await _settle(tester);

        await tester.tap(find.text('Ausente'));
        await tester.pump();
        await tester.tap(find.text('Siguiente'));
        await _settle(tester);

        expect(find.text('Pregunta 2/5'), findsOneWidget);
      },
    );

    testWidgets(
      'CP-04: valor límite superior (4 - "Consolidado") es válido y permite avanzar',
      (tester) async {
        await _pumpApp(tester, respuestasAcumuladas: {});
        await _settle(tester);

        await tester.tap(find.text('Consolidado'));
        await tester.pump();
        await tester.tap(find.text('Siguiente'));
        await _settle(tester);

        expect(find.text('Pregunta 2/5'), findsOneWidget);
      },
    );

    testWidgets(
      'CP-05: al responder las 5 preguntas de la dimensión, navega a Dimensión 3',
      (tester) async {
        await _pumpApp(tester, respuestasAcumuladas: {});
        await _settle(tester);

        const opciones = ['Ausente', 'Incipiente', 'En desarrollo', 'Logrado', 'Consolidado'];
        for (var i = 0; i < 5; i++) {
          await tester.tap(find.text(opciones[i]));
          await tester.pump();
          await tester.tap(find.text('Siguiente'));
          await _settle(tester);
        }

        expect(find.text('PANTALLA_D3'), findsOneWidget);
      },
    );

    testWidgets(
      'CP-06: "Regresar" en una pregunta intermedia retrocede sin perder la respuesta ya dada',
      (tester) async {
        await _pumpApp(tester, respuestasAcumuladas: {});
        await _settle(tester);

        // Responde la pregunta 1 y avanza a la 2
        await tester.tap(find.text('Logrado')); // valor 3
        await tester.pump();
        await tester.tap(find.text('Siguiente'));
        await _settle(tester);
        expect(find.text('Pregunta 2/5'), findsOneWidget);

        // Regresa a la pregunta 1
        await tester.tap(find.text('Regresar'));
        await _settle(tester);
        expect(find.text('Pregunta 1/5'), findsOneWidget);

        // Debe seguir habiendo exactamente una opción marcada como seleccionada
        // (el ícono de check solo se pinta sobre la opción elegida: "Logrado").
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      },
    );

    testWidgets(
      'CP-07: "Regresar" en la primera pregunta de D2 navega hacia atrás a Dimensión 1',
      (tester) async {
        await _pumpApp(tester, respuestasAcumuladas: {});
        await _settle(tester);

        expect(find.text('Pregunta 1/5'), findsOneWidget);
        await tester.tap(find.text('Regresar'));
        await _settle(tester);

        expect(find.text('PANTALLA_D1'), findsOneWidget);
      },
    );

    testWidgets(
      'CP-08: reanudación con "2.5" ya respondida en respuestasAcumuladas inicia en la pregunta 5/5',
      (tester) async {
        await _pumpApp(tester, respuestasAcumuladas: {
          '2.1': 4,
          '2.2': 4,
          '2.3': 3,
          '2.4': 2,
          '2.5': 1,
        });
        await _settle(tester);

        expect(find.text('Pregunta 5/5'), findsOneWidget);
      },
    );

    testWidgets(
      'CP-09: respuestas previas SIN la clave "2.5" NO activan la reanudación (inicia en pregunta 1/5)',
      (tester) async {
        await _pumpApp(tester, respuestasAcumuladas: {
          '2.1': 4,
          '2.2': 4,
          '2.3': 3,
          '2.4': 2,
        });
        await _settle(tester);

        expect(find.text('Pregunta 1/5'), findsOneWidget);
      },
    );
  });
}
