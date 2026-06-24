import 'package:get_it/get_it.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/verificar_cedula.dart';
import 'features/auth/domain/usecases/login_administrador.dart';
import 'features/auth/presentation/controller/auth_controller.dart';

final sl = GetIt.instance; // sl stands for Service Locator

Future<void> init() async {
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
    () => AuthRemoteDataSourceImpl(),
  );
}
