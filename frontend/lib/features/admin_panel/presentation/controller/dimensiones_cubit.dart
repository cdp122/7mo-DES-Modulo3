import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/preguntas_repository.dart';
import '../../domain/entities/dimension.dart';
import 'dimensiones_state.dart';

class DimensionesCubit extends Cubit<DimensionesState> {
  final PreguntasRepository _repository;

  DimensionesCubit(this._repository) : super(const DimensionesInitial());

  Future<void> cargarDimensiones() async {
    emit(const DimensionesLoading());
    try {
      final dims = await _repository.obtenerDimensiones();
      emit(DimensionesLoaded(
        dimensiones: dims,
      ));
    } catch (e) {
      emit(DimensionesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> crearDimension({
    required int orden,
    required String nombre,
    required String descripcion,
    required String fundamento,
  }) async {
    emit(const DimensionesLoading());
    try {
      await _repository.crearDimension(
        DimensionEntity(
          id: '',
          orden: orden,
          nombre: nombre,
          descripcion: descripcion,
          fundamento: fundamento,
          reactivos: const [],
        ),
      );
      final dims = await _repository.obtenerDimensiones();
      emit(const DimensionActionSuccess('Dimensión creada correctamente.'));
      emit(DimensionesLoaded(
        dimensiones: dims,
      ));
    } catch (e) {
      emit(DimensionesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> editarDimension({
    required String id,
    required String nombre,
    required String descripcion,
    required String fundamento,
  }) async {
    emit(const DimensionesLoading());
    try {
      await _repository.actualizarDimension(
        id,
        nombre: nombre,
        descripcion: descripcion,
        fundamento: fundamento,
      );
      final dims = await _repository.obtenerDimensiones();
      emit(const DimensionActionSuccess('Dimensión actualizada correctamente.'));
      emit(DimensionesLoaded(
        dimensiones: dims,
      ));
    } catch (e) {
      emit(DimensionesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> eliminarDimension(String id) async {
    emit(const DimensionesLoading());
    try {
      await _repository.eliminarDimension(id);
      final dims = await _repository.obtenerDimensiones();
      emit(const DimensionActionSuccess('Dimensión eliminada correctamente.'));
      emit(DimensionesLoaded(
        dimensiones: dims,
      ));
    } catch (e) {
      emit(DimensionesError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
