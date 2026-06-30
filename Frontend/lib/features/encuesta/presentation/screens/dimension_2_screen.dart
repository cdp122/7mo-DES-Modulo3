import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/audio_service.dart';
import '../../../admin_panel/presentation/controller/preguntas_cubit.dart';
import '../../../admin_panel/presentation/controller/preguntas_state.dart';
import '../../../admin_panel/domain/entities/dimension.dart';
import '../widgets/likert_button_widget.dart';

class Dimension2Screen extends StatefulWidget {
  final String cedulaDocente;
  final Map<String, int> respuestasAcumuladas;

  const Dimension2Screen({
    super.key,
    required this.cedulaDocente,
    required this.respuestasAcumuladas,
  });

  @override
  State<Dimension2Screen> createState() => _Dimension2ScreenState();
}

class _Dimension2ScreenState extends State<Dimension2Screen>
    with SingleTickerProviderStateMixin {
  int _preguntaActualIndex = 0;
  bool _mostrarPista = false;
  late Map<String, int> _respuestas;

  late final AnimationController _animationController;
  late final Animation<double> _floatingAnimation;

  final Color colorTema = const Color(0xFF009688);

  @override
  void initState() {
    super.initState();
    _respuestas = Map<String, int>.from(widget.respuestasAcumuladas);

    // Si regresamos desde D3 y el mapa contiene la última respuesta de esta sección
    if (_respuestas.containsKey('2.5')) {
      _preguntaActualIndex = 4; // Abre instantáneamente en la pregunta 5
    }

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _floatingAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _continuar(DimensionEntity dimensionActual) {
    final String codigoReal =
        dimensionActual.reactivos[_preguntaActualIndex].codigo;

    if (!_respuestas.containsKey(codigoReal)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Por favor, selecciona una respuesta antes de continuar',
          ),
          backgroundColor: colorTema,
        ),
      );
      return;
    }

    setState(() {
      _mostrarPista = false;
      if (_preguntaActualIndex < dimensionActual.reactivos.length - 1) {
        _preguntaActualIndex++;
      } else {
        context.go(
          '/encuesta/d3',
          extra: {'cedula': widget.cedulaDocente, 'respuestas': _respuestas},
        );
      }
    });
  }

  void _regresar() {
    setState(() {
      if (_preguntaActualIndex > 0) {
        _preguntaActualIndex--;
        _mostrarPista = false;
      } else {
        // ACTUALIZADO: Regresamos a D1 enviando toda la memoria
        context.go(
          '/encuesta/d1',
          extra: {'cedula': widget.cedulaDocente, 'respuestas': _respuestas},
        );
      }
    });
  }

  String _obtenerImagenOsoPregunta(int index) =>
      'assets/images/Oso${[1, 2, 4][index % 3]}.png';

  @override
  Widget build(BuildContext context) {
    final bool esPantallaAncha = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(
                AudioService().isMuted
                    ? Icons.volume_off_rounded
                    : Icons.volume_up_rounded,
                color: colorTema,
                size: 32,
              ),
              onPressed: () => setState(() => AudioService().toggleMute()),
            ),
          ),
        ],
      ),
      body: BlocBuilder<PreguntasCubit, PreguntasState>(
        builder: (context, state) {
          if (state is PreguntasLoading || state is PreguntasInitial)
            return Center(child: CircularProgressIndicator(color: colorTema));

          if (state is PreguntasLoaded) {
            final dimensionBD = state.dimensiones.firstWhere(
              (d) => d.orden == 2,
              orElse: () => state.dimensiones.first,
            );
            if (dimensionBD.reactivos.isEmpty)
              return const Center(
                child: Text('No hay preguntas para esta área.'),
              );

            final reactivoActual = dimensionBD.reactivos[_preguntaActualIndex];
            final progresoGlobal =
                (_preguntaActualIndex + 1) / dimensionBD.reactivos.length;
            final imagenActual = _mostrarPista
                ? 'assets/images/Oso3.png'
                : _obtenerImagenOsoPregunta(_preguntaActualIndex);

            return SafeArea(
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: progresoGlobal,
                    backgroundColor: AppColors.borderLight,
                    color: colorTema,
                    minHeight: 8,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 1100),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 24,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: colorTema.withOpacity(0.04),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorTema.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    dimensionBD.nombre.toUpperCase(),
                                    style: TextStyle(
                                      color: colorTema,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Pregunta ${_preguntaActualIndex + 1}/${dimensionBD.reactivos.length}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondaryLight,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),

                            Expanded(
                              flex: 5,
                              child: Flex(
                                direction: esPantallaAncha
                                    ? Axis.horizontal
                                    : Axis.vertical,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    flex: 2,
                                    child: AnimatedBuilder(
                                      animation: _floatingAnimation,
                                      builder: (context, child) =>
                                          Transform.translate(
                                            offset: Offset(
                                              0,
                                              _floatingAnimation.value,
                                            ),
                                            child: child,
                                          ),
                                      child: Image.asset(
                                        imagenActual,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  if (esPantallaAncha)
                                    const SizedBox(width: 48)
                                  else
                                    const SizedBox(height: 16),

                                  Expanded(
                                    flex: 3,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          RichText(
                                            textAlign: TextAlign.left,
                                            text: TextSpan(
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w800,
                                                color:
                                                    AppColors.textPrimaryLight,
                                                height: 1.4,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text:
                                                      reactivoActual.enunciado +
                                                      ' ',
                                                ),
                                                if (reactivoActual.pista !=
                                                        null &&
                                                    reactivoActual
                                                        .pista!
                                                        .isNotEmpty)
                                                  WidgetSpan(
                                                    alignment:
                                                        PlaceholderAlignment
                                                            .middle,
                                                    child: IconButton(
                                                      padding: EdgeInsets.zero,
                                                      constraints:
                                                          const BoxConstraints(),
                                                      icon: Icon(
                                                        _mostrarPista
                                                            ? Icons.lightbulb
                                                            : Icons
                                                                  .lightbulb_outline,
                                                        color: Colors.amber,
                                                        size: 34,
                                                      ),
                                                      onPressed: () => setState(
                                                        () => _mostrarPista =
                                                            !_mostrarPista,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          if (_mostrarPista &&
                                              reactivoActual.pista != null) ...[
                                            const SizedBox(height: 16),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.amber.withOpacity(
                                                  0.08,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: Colors.amber
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                              child: Text(
                                                reactivoActual.pista!,
                                                style: const TextStyle(
                                                  color: AppColors
                                                      .textPrimaryLight,
                                                  fontSize: 15,
                                                  height: 1.4,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              children: [
                                const SizedBox(height: 16),
                                LikertOptionsGroup(
                                  valorSeleccionado:
                                      _respuestas[reactivoActual.codigo],
                                  onSelected: (valor) {
                                    setState(
                                      () => _respuestas[reactivoActual.codigo] =
                                          valor,
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton.icon(
                                      onPressed: _regresar,
                                      icon: const Icon(
                                        Icons.arrow_back_rounded,
                                        size: 22,
                                      ),
                                      label: const Text(
                                        'Regresar',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => _continuar(dimensionBD),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorTema,
                                        foregroundColor: AppColors.surfaceLight,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 36,
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Siguiente',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
