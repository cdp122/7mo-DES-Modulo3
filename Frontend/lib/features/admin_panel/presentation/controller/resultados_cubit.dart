import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/resultados_repository.dart';
import 'resultados_state.dart';

class ResultadosCubit extends Cubit<ResultadosState> {
  final ResultadosRepository _repository;

  ResultadosCubit(this._repository) : super(const ResultadosInitial());

  Future<void> cargarResumenGeneral() async {
    emit(const ResultadosLoading());
    try {
      final resumen = await _repository.obtenerResumenGeneral();
      emit(ResultadosLoaded(resumen: resumen));
    } catch (e) {
      emit(ResultadosError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> buscarPorDocente(String cedula) async {
    final currentState = state;
    // Mantener el resumen general mientras carga la búsqueda
    if (currentState is ResultadosLoaded) {
      emit(ResultadosLoaded(
        resumen: currentState.resumen,
        resultadosDocente: const [],
      ));
    }

    try {
      final resultados = await _repository.obtenerResultadosPorDocente(cedula);

      if (currentState is ResultadosLoaded) {
        emit(currentState.copyWith(resultadosDocente: resultados));
      } else {
        // Si por alguna razón no se tenía el resumen, recargarlo
        final resumen = await _repository.obtenerResumenGeneral();
        emit(ResultadosLoaded(
          resumen: resumen,
          resultadosDocente: resultados,
        ));
      }
    } catch (e) {
      emit(ResultadosError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<List<int>> exportarExcel({String? cedula}) {
    return _repository.exportarEvaluacionesExcel(cedula: cedula);
  }

  void limpiarBusqueda() {
    final currentState = state;
    if (currentState is ResultadosLoaded) {
      emit(currentState.copyWith(resultadosDocente: const []));
    }
  }
}
