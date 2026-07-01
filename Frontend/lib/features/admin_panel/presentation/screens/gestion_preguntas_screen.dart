import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/dimension.dart';
import '../../domain/entities/reactivo.dart';
import '../controller/preguntas_cubit.dart';
import '../controller/preguntas_state.dart';

// ── Helper tipográfico local ─────────────────────────────────────
TextStyle _outfit(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? height,
  double? letterSpacing,
}) =>
    GoogleFonts.outfit(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );


class GestionPreguntasScreen extends StatefulWidget {
  const GestionPreguntasScreen({super.key});

  @override
  State<GestionPreguntasScreen> createState() => _GestionPreguntasScreenState();
}

class _GestionPreguntasScreenState extends State<GestionPreguntasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Color _currentTabColor = const Color(0xFF4E9A6B); // Default: Sage Green for D1

  int _tabCount = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
    _tabController.addListener(_handleTabSelection);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PreguntasCubit>().cargarPreguntas();
    });
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _currentTabColor = _getDimensionColor(_tabController.index + 1);
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  Color _getDimensionColor(int orden) {
    switch (orden) {
      case 1:
        return const Color(0xFF3F51B5); // Indigo
      case 2:
        return const Color(0xFF009688); // Teal
      case 3:
        return const Color(0xFFFF9800); // Orange
      default:
        return AppColors.primary;
    }
  }

  void _mostrarExplicacionConexion() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cloud_done_rounded, color: AppColors.success),
              SizedBox(width: 10),
              Text('Estado de la Conexión'),
            ],
          ),
          content: const Text(
            'Conexión activa con el servidor Backend. Todos los cambios realizados se guardan en tiempo real en la base de datos MongoDB.',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<PreguntasCubit, PreguntasState>(
      listener: (context, state) {
        if (state is PreguntasError) {
          _showErrorSnackBar(state.mensaje);
        } else if (state is PreguntasActionSuccess) {
          _showSuccessSnackBar(state.mensaje);
        } else if (state is PreguntasLoaded) {
          final newLength = state.dimensiones.length;
          if (newLength > 0 && newLength != _tabCount) {
            _tabController.removeListener(_handleTabSelection);
            _tabController.dispose();
            _tabController = TabController(length: newLength, vsync: this);
            _tabController.addListener(_handleTabSelection);
            _tabCount = newLength;
            setState(() {
              _currentTabColor = _getDimensionColor(_tabController.index + 1);
            });
          }
        }
      },
      builder: (context, state) {
        List<DimensionEntity> dimensiones = [];
        bool isLoading = state is PreguntasLoading;

        if (state is PreguntasLoaded) {
          dimensiones = state.dimensiones;
        }

        final listDimensiones = List<DimensionEntity>.from(dimensiones)
          ..sort((a, b) => a.orden.compareTo(b.orden));

        if (listDimensiones.isEmpty) {
          listDimensiones.addAll([
            _emptyDimension(1),
            _emptyDimension(2),
            _emptyDimension(3),
          ]);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Gestión de Reactivos'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/admin-panel'),
            ),
            actions: [
              // Connected / Offline status indicator badge
              GestureDetector(
                onTap: () => _mostrarExplicacionConexion(),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.success,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 4,
                          backgroundColor: AppColors.success,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Servidor Online',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.green.shade200 : Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<PreguntasCubit>().cargarPreguntas(),
                tooltip: 'Sincronizar con el Servidor',
              ),
              const SizedBox(width: 8),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: _currentTabColor,
              indicatorWeight: 4.0,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
              tabs: listDimensiones.map((d) {
                final idx = listDimensiones.indexOf(d);
                IconData icon;
                if (idx == 0) icon = Icons.looks_one;
                else if (idx == 1) icon = Icons.looks_two;
                else if (idx == 2) icon = Icons.looks_3;
                else icon = Icons.looks;

                return Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon, 
                        color: _tabController.index == idx ? _getDimensionColor(d.orden) : Colors.white70
                      ),
                      const SizedBox(width: 8),
                      Text('D${d.orden}: ${d.nombre}'),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          body: isLoading && listDimensiones.every((d) => d.reactivos.isEmpty)
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: listDimensiones.map((d) => _buildDimensionQuestionsList(d, isDark, theme)).toList(),
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _mostrarDialogoCrearPregunta(dimensiones),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar Pregunta'),
            backgroundColor: _currentTabColor,
            foregroundColor: Colors.white,
            elevation: 4,
          ),
        );
      },
    );
  }

  Widget _buildDimensionQuestionsList(DimensionEntity dimension, bool isDark, ThemeData theme) {
    final dimColor = _getDimensionColor(dimension.orden);

    if (dimension.reactivos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            const SizedBox(height: 16),
            const Text(
              'No hay preguntas registradas en esta dimensión.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    final reactivos = List<ReactivoEntity>.from(dimension.reactivos);
    reactivos.sort((a, b) => a.codigo.compareTo(b.codigo));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Dimension Header description colored with dimension theme accent
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: dimColor.withOpacity(0.06),
            border: Border(
              bottom: BorderSide(
                color: dimColor.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dimension.nombre,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: isDark ? Colors.white : dimColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                dimension.descripcion,
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
            itemCount: reactivos.length,
            itemBuilder: (context, index) {
              final r = reactivos[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                clipBehavior: Clip.antiAlias,
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1,
                  ),
                ),
                child: Container(
                  // Decorative color accent border on the left side to distinguish dimensions visually
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: dimColor,
                        width: 5,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question Code Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: dimColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: dimColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            r.codigo,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : dimColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.enunciado,
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                ),
                              ),
                              if (r.pista != null && r.pista!.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.info),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          r.pista!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Actions with subtle spacing
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent, size: 20),
                              onPressed: () => _mostrarDialogoEditarPregunta(dimension.id, r),
                              tooltip: 'Editar Pregunta',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_rounded, color: AppColors.error, size: 20),
                              onPressed: () => _mostrarConfirmacionEliminar(dimension.id, r),
                              tooltip: 'Eliminar Pregunta',
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _mostrarDialogoCrearPregunta(List<DimensionEntity> dimensiones) {
    if (dimensiones.isEmpty) return;

    final formKey = GlobalKey<FormState>();
    String selectedDimensionId = dimensiones.first.id;
    final codigoController = TextEditingController();
    final enunciadoController = TextEditingController();
    final pistaController = TextEditingController();

    // Auto-generate code handler based on chosen dimension
    void updateCodigoHint(String dimId) {
      final dim = dimensiones.firstWhere((d) => d.id == dimId);
      final count = dim.reactivos.length + 1;
      codigoController.text = '${dim.orden}.$count';
    }

    updateCodigoHint(selectedDimensionId);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stContext, setState) {
            final activeDim = dimensiones.firstWhere((d) => d.id == selectedDimensionId);
            final dimColor = _getDimensionColor(activeDim.orden);

            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.add_circle_outline_rounded, color: dimColor),
                  const SizedBox(width: 10),
                  const Text('Nueva Pregunta'),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Dimisión Selector Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedDimensionId,
                        decoration: const InputDecoration(
                          labelText: 'Dimensión',
                          prefixIcon: Icon(Icons.category_rounded),
                        ),
                        items: dimensiones.map((d) {
                          return DropdownMenuItem<String>(
                            value: d.id,
                            child: Text('Dimensión ${d.orden} - D${d.orden}'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedDimensionId = val;
                              updateCodigoHint(val);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Código del reactivo (ej: 1.6)
                      TextFormField(
                        controller: codigoController,
                        decoration: const InputDecoration(
                          labelText: 'Código de Pregunta',
                          prefixIcon: Icon(Icons.pin_rounded),
                          hintText: 'Ej. 1.6',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingrese el código';
                          }
                          // Enforce code pattern matches dimension number
                          final expectedPrefix = '${activeDim.orden}.';
                          if (!value.startsWith(expectedPrefix)) {
                            return 'El código debe comenzar con "$expectedPrefix"';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Enunciado
                      TextFormField(
                        controller: enunciadoController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Enunciado de la Pregunta',
                          prefixIcon: Icon(Icons.quiz_rounded),
                          hintText: 'Escriba la pregunta aquí...',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingrese el enunciado';
                          }
                          if (value.trim().length < 10) {
                            return 'El enunciado debe ser más descriptivo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Pista
                      TextFormField(
                        controller: pistaController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Pista / Aclaración (Opcional)',
                          prefixIcon: Icon(Icons.lightbulb_outline_rounded),
                          hintText: 'Ej. Evalúe si los alumnos proponen...',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final nuevoReactivo = ReactivoEntity(
                        codigo: codigoController.text.trim(),
                        enunciado: enunciadoController.text.trim(),
                        pista: pistaController.text.trim().isEmpty ? null : pistaController.text.trim(),
                      );
                      context.read<PreguntasCubit>().crearPregunta(selectedDimensionId, nuevoReactivo);
                      Navigator.pop(dialogContext);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dimColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarDialogoEditarPregunta(String dimensionId, ReactivoEntity r) {
    final formKey = GlobalKey<FormState>();
    final enunciadoController = TextEditingController(text: r.enunciado);
    final pistaController = TextEditingController(text: r.pista ?? '');

    // Get color for specific dimension
    final activeTabNumber = _tabController.index + 1;
    final dimColor = _getDimensionColor(activeTabNumber);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit_note_rounded, color: dimColor),
              const SizedBox(width: 10),
              Text('Editar Pregunta ${r.codigo}'),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: enunciadoController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Enunciado de la Pregunta',
                      prefixIcon: Icon(Icons.quiz_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El enunciado no puede estar vacío';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: pistaController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Pista / Aclaración (Opcional)',
                      prefixIcon: Icon(Icons.lightbulb_outline_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final reactivoEditado = ReactivoEntity(
                    codigo: r.codigo,
                    enunciado: enunciadoController.text.trim(),
                    pista: pistaController.text.trim().isEmpty ? null : pistaController.text.trim(),
                  );
                  context.read<PreguntasCubit>().editarPregunta(dimensionId, r.codigo, reactivoEditado);
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: dimColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarConfirmacionEliminar(String dimensionId, ReactivoEntity r) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error),
              const SizedBox(width: 10),
              Text('¿Eliminar Pregunta?'),
            ],
          ),
          content: Text(
            '¿Está seguro de que desea eliminar la pregunta "${r.codigo}"? Esta acción no se puede deshacer.',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<PreguntasCubit>().eliminarPregunta(dimensionId, r.codigo);
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  DimensionEntity _emptyDimension(int orden) {
    return DimensionEntity(
      id: 'mock_empty_$orden',
      orden: orden,
      nombre: 'Dimensión $orden',
      descripcion: 'Cargando datos...',
      fundamento: '',
      reactivos: [],
    );
  }
}
