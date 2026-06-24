import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/screens/ingreso_cedula_screen.dart';
import '../../features/auth/presentation/screens/contrasena_admin_screen.dart';
import '../../features/encuesta/presentation/screens/responder_encuesta_screen.dart';
import '../../features/encuesta/presentation/screens/resultados_screen.dart';
import '../../features/admin_panel/presentation/screens/panel_principal_screen.dart';
import '../../features/admin_panel/presentation/screens/gestion_preguntas_screen.dart';
import '../../features/admin_panel/presentation/controller/preguntas_cubit.dart';
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
          if (usuario == null) {
            return const IngresoCedulaScreen();
          }
          return ContrasenaAdminScreen(usuario: usuario);
        },
      ),
      GoRoute(
        path: '/encuesta',
        builder: (context, state) => const ResponderEncuestaScreen(),
      ),
      GoRoute(
        path: '/encuesta-resultados',
        builder: (context, state) => const ResultadosScreen(),
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
    ],
  );
}
