import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'core/network/graphql_service.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/verificar_cedula.dart';
import 'features/auth/domain/usecases/login_administrador.dart';
import 'features/auth/presentation/controller/auth_controller.dart';
import 'features/admin_panel/data/repositories/preguntas_repository.dart';
import 'features/admin_panel/presentation/controller/preguntas_cubit.dart';
import 'features/admin_panel/presentation/controller/dimensiones_cubit.dart';

final sl = GetIt.instance; // sl stands for Service Locator

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => GraphQLService(dio: sl()));

  // Features - Auth

  // Bloc / Cubit
  sl.registerFactory(() => AuthCubit(
        verificarCedulaUseCase: sl(),
        loginAdministradorUseCase: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton(() => VerificarCedula(sl()));
  sl.registerLazySingleton(() => LoginAdministrador(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // Features - Admin Panel (Preguntas CRUD)
  sl.registerLazySingleton(() => PreguntasRepository(sl()));
  sl.registerFactory(() => PreguntasCubit(sl()));

  // Features - Admin Panel (Dimensiones)
  sl.registerFactory(() => DimensionesCubit(sl()));
}
