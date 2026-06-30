import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/screens/ingreso_cedula_screen.dart';
import '../../features/auth/presentation/screens/contrasena_admin_screen.dart';

import '../../features/encuesta/presentation/screens/portada_screen.dart';
import '../../features/encuesta/presentation/screens/dimension_1_screen.dart';
import '../../features/encuesta/presentation/screens/dimension_2_screen.dart';
import '../../features/encuesta/presentation/screens/dimension_3_screen.dart';
import '../../features/encuesta/presentation/screens/resultados_screen.dart';

import '../../features/admin_panel/presentation/screens/panel_principal_screen.dart';
import '../../features/admin_panel/presentation/screens/gestion_preguntas_screen.dart';
import '../../features/admin_panel/presentation/screens/dimensiones_list_screen.dart';
import '../../features/admin_panel/presentation/screens/dimension_detail_screen.dart';
import '../../features/admin_panel/presentation/controller/preguntas_cubit.dart';
import '../../features/admin_panel/presentation/controller/dimensiones_cubit.dart';
import '../../features/admin_panel/presentation/controller/resultados_cubit.dart';
import '../../features/admin_panel/presentation/screens/resultados_admin_screen.dart';
import '../../features/admin_panel/presentation/controller/administradores_cubit.dart';
import '../../features/admin_panel/presentation/screens/administradores_screen.dart';
import '../../features/admin_panel/domain/entities/dimension.dart';
import '../../features/auth/domain/entities/usuario.dart';
import '../../injection.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const IngresoCedulaScreen(),
      ),
      GoRoute(
        path: '/admin-contrasena',
        builder: (context, state) {
          final usuario = state.extra as Usuario?;
          if (usuario == null) return const IngresoCedulaScreen();
          return ContrasenaAdminScreen(usuario: usuario);
        },
      ),
      GoRoute(
        path: '/portada',
        builder: (context, state) {
          final cedula = state.extra as String?;
          if (cedula == null || cedula.isEmpty) return const IngresoCedulaScreen();
          return PortadaScreen(cedulaDocente: cedula);
        },
      ),
      GoRoute(
        path: '/encuesta/d1',
        builder: (context, state) {
          String? cedula;
          Map<String, int>? respuestasAcumuladas;

          // Hacemos el chequeo genérico de 'Map' sin forzar la firma genérica estricta en web
          if (state.extra is String) {
            cedula = state.extra as String;
          } else if (state.extra is Map) {
            final datos = state.extra as Map;
            cedula = datos['cedula'] as String?;
            respuestasAcumuladas = Map<String, int>.from(datos['respuestas'] as Map);
          }

          if (cedula == null || cedula.isEmpty) return const IngresoCedulaScreen();
          
          return BlocProvider<PreguntasCubit>(
            create: (context) => sl<PreguntasCubit>()..cargarPreguntas(),
            child: Dimension1Screen(
              cedulaDocente: cedula,
              respuestasAcumuladas: respuestasAcumuladas,
            ),
          );
        },
      ),
      GoRoute(
        path: '/encuesta/d2',
        builder: (context, state) {
          String? cedula;
          Map<String, int>? respuestasAcumuladas;

          if (state.extra is Map) {
            final datos = state.extra as Map;
            cedula = datos['cedula'] as String?;
            respuestasAcumuladas = Map<String, int>.from(datos['respuestas'] as Map);
          }

          if (cedula == null || cedula.isEmpty) return const IngresoCedulaScreen();
          
          return BlocProvider<PreguntasCubit>(
            create: (context) => sl<PreguntasCubit>()..cargarPreguntas(),
            child: Dimension2Screen(
              cedulaDocente: cedula,
              respuestasAcumuladas: respuestasAcumuladas ?? const {},
            ),
          );
        },
      ),
      GoRoute(
        path: '/encuesta/d3',
        builder: (context, state) {
          String? cedula;
          Map<String, int>? respuestasAcumuladas;

          if (state.extra is Map) {
            final datos = state.extra as Map;
            cedula = datos['cedula'] as String?;
            respuestasAcumuladas = Map<String, int>.from(datos['respuestas'] as Map);
          }

          if (cedula == null || cedula.isEmpty) return const IngresoCedulaScreen();
          
          return BlocProvider<PreguntasCubit>(
            create: (context) => sl<PreguntasCubit>()..cargarPreguntas(),
            child: Dimension3Screen(
              cedulaDocente: cedula,
              respuestasAcumuladas: respuestasAcumuladas ?? const {},
            ),
          );
        },
      ),
      GoRoute(
        path: '/encuesta-resultados',
        builder: (context, state) {
          if (state.extra is Map) {
            final datos = state.extra as Map;
            return ResultadosScreen(resultadoscompletos: Map<String, dynamic>.from(datos));
          }
          return const IngresoCedulaScreen();
        },
      ),
      GoRoute(
        path: '/admin-panel',
        builder: (context, state) => const PanelPrincipalScreen(),
      ),
      GoRoute(
        path: '/gestion-preguntas',
        builder: (context, state) => BlocProvider<PreguntasCubit>(
          create: (context) => sl<PreguntasCubit>(),
          child: const GestionPreguntasScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/dimensiones',
        builder: (context, state) => BlocProvider<DimensionesCubit>(
          create: (context) => sl<DimensionesCubit>(),
          child: const DimensionesListScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/resultados',
        builder: (context, state) => BlocProvider<ResultadosCubit>(
          create: (context) => sl<ResultadosCubit>(),
          child: const ResultadosAdminScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/administradores',
        builder: (context, state) => BlocProvider<AdministradoresCubit>(
          create: (context) => sl<AdministradoresCubit>(),
          child: const AdministradoresScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/dimensiones/:id',
        builder: (context, state) {
          final dimension = state.extra as DimensionEntity?;
          if (dimension == null) return const DimensionesListScreen();
          return DimensionDetailScreen(dimension: dimension);
        },
      ),
    ],
  );
}