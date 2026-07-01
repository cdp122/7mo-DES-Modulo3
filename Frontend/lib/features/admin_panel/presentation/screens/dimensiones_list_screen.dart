import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../controller/dimensiones_cubit.dart';
import '../controller/dimensiones_state.dart';
import '../widgets/dimension_card.dart';
import '../widgets/dimension_form_dialog.dart';
import '../../domain/entities/dimension.dart';

class DimensionesListScreen extends StatefulWidget {
  const DimensionesListScreen({super.key});

  @override
  State<DimensionesListScreen> createState() => _DimensionesListScreenState();
}

class _DimensionesListScreenState extends State<DimensionesListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DimensionesCubit>().cargarDimensiones();
  }

  Future<void> _showDimensionForm({
    DimensionEntity? initialDimension,
  }) async {
    final currentContext = context;
    final cubit = currentContext.read<DimensionesCubit>();

    final dimension = await showDialog<DimensionEntity>(
      context: currentContext,
      builder: (dialogContext) {
        return DimensionFormDialog(
          title: initialDimension == null ? 'Crear dimensión' : 'Editar dimensión',
          initialDimension: initialDimension,
        );
      },
    );

    if (!mounted || dimension == null) return;

    if (initialDimension == null) {
      await cubit.crearDimension(
        orden: dimension.orden,
        nombre: dimension.nombre,
        descripcion: dimension.descripcion,
        fundamento: dimension.fundamento,
      );
    } else {
      await cubit.editarDimension(
        id: initialDimension.id,
        nombre: dimension.nombre,
        descripcion: dimension.descripcion,
        fundamento: dimension.fundamento,
      );
    }
  }

  Future<void> _confirmDelete(DimensionEntity dimension) async {
    final currentContext = context;
    final cubit = currentContext.read<DimensionesCubit>();

    final confirmed = await showDialog<bool>(
      context: currentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar dimensión'),
          content: Text('¿Seguro que deseas eliminar la dimensión "${dimension.nombre}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    await cubit.eliminarDimension(dimension.id);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin-panel'),
          tooltip: 'Volver',
        ),
        title: Text(
          'Gestión de Dimensiones',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.primary,
      ),
      body: BlocBuilder<DimensionesCubit, DimensionesState>(
        builder: (context, state) {
          if (state is DimensionesLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is DimensionesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar dimensiones',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.mensaje,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DimensionesCubit>().cargarDimensiones();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is DimensionesLoaded) {
            if (state.dimensiones.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay dimensiones disponibles',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(width > 600 ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner de info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C86A0).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF2C86A0).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF2C86A0),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Conectado al servidor',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: const Color(0xFF2C86A0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Barra superior de acciones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Dimensiones',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showDimensionForm(),
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar dimensión'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Grid de dimensiones
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: width > 900 ? 3 : (width > 600 ? 2 : 1),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.25,
                    ),
                    itemCount: state.dimensiones.length,
                    itemBuilder: (context, index) {
                      final dimension = state.dimensiones[index];
                      return DimensionCard(
                        dimension: dimension,
                        onTap: () {
                          context.push(
                            '/admin/dimensiones/${dimension.id}',
                            extra: dimension,
                          );
                        },
                        onEdit: () => _showDimensionForm(initialDimension: dimension),
                        onDelete: () => _confirmDelete(dimension),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: Text('Estado desconocido'),
          );
        },
      ),
    );
  }
}
