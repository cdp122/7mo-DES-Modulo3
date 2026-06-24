import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/preguntas_repository.dart';
import '../../domain/entities/reactivo.dart';
import 'preguntas_state.dart';

class PreguntasCubit extends Cubit<PreguntasState> {
  final PreguntasRepository _repository;

  PreguntasCubit(this._repository) : super(const PreguntasInitial());

  Future<void> cargarPreguntas() async {
    emit(const PreguntasLoading());
    try {
      final dims = await _repository.obtenerDimensiones();
      emit(PreguntasLoaded(
        dimensiones: dims,
        isUsingMock: _repository.isUsingMock,
      ));
    } catch (e) {
      emit(PreguntasError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> crearPregunta(String dimensionId, ReactivoEntity reactivo) async {
    final currentState = state;
    if (currentState is PreguntasLoaded) {
      emit(const PreguntasLoading());
      try {
        await _repository.agregarReactivo(dimensionId, reactivo);
        emit(const PreguntasActionSuccess('Pregunta creada exitosamente'));
        
        // Reload questions
        final dims = await _repository.obtenerDimensiones();
        emit(PreguntasLoaded(
          dimensiones: dims,
          isUsingMock: _repository.isUsingMock,
        ));
      } catch (e) {
        emit(PreguntasError(e.toString().replaceAll('Exception: ', '')));
        // Re-emit loaded with previous state data
        emit(currentState);
      }
    }
  }

  Future<void> editarPregunta(String dimensionId, String codigoOriginal, ReactivoEntity reactivoEditado) async {
    final currentState = state;
    if (currentState is PreguntasLoaded) {
      emit(const PreguntasLoading());
      try {
        await _repository.editarReactivo(dimensionId, codigoOriginal, reactivoEditado);
        emit(const PreguntasActionSuccess('Pregunta actualizada exitosamente'));
        
        // Reload questions
        final dims = await _repository.obtenerDimensiones();
        emit(PreguntasLoaded(
          dimensiones: dims,
          isUsingMock: _repository.isUsingMock,
        ));
      } catch (e) {
        emit(PreguntasError(e.toString().replaceAll('Exception: ', '')));
        emit(currentState);
      }
    }
  }

  Future<void> eliminarPregunta(String dimensionId, String codigo) async {
    final currentState = state;
    if (currentState is PreguntasLoaded) {
      emit(const PreguntasLoading());
      try {
        await _repository.eliminarReactivo(dimensionId, codigo);
        emit(const PreguntasActionSuccess('Pregunta eliminada exitosamente'));
        
        // Reload questions
        final dims = await _repository.obtenerDimensiones();
        emit(PreguntasLoaded(
          dimensiones: dims,
          isUsingMock: _repository.isUsingMock,
        ));
      } catch (e) {
        emit(PreguntasError(e.toString().replaceAll('Exception: ', '')));
        emit(currentState);
      }
    }
  }
}
