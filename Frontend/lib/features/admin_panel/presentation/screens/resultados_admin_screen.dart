import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/resultados_evaluacion.dart';
import '../controller/resultados_cubit.dart';
import '../controller/resultados_state.dart';

// ── Paleta local ────────────────────────────────────────────────
class _P {
  static const navy = Color(0xFF16305B);
  static const teal = Color(0xFF009688); // Matching Survey D2 (Teal)
  static const sage = Color(0xFF3F51B5); // Matching Survey D1 (Indigo)
  static const amber = Color(0xFFFF9800); // Matching Survey D3 (Orange)
  static const terracotta = Color(0xFFD2693E);
}

TextStyle _outfit(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? letterSpacing,
  double? height,
}) =>
    GoogleFonts.outfit(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );

// ── Helpers de color por nivel ──────────────────────────────────
Color _colorPorNivel(String nivel) {
  switch (nivel) {
    case 'Participación auténtica':
      return _P.sage;
    case 'Participación en desarrollo':
      return _P.teal;
    case 'Participación incipiente':
      return _P.amber;
    case 'Planificación adultocéntrica':
      return _P.terracotta;
    default:
      return _P.teal;
  }
}

IconData _iconPorNivel(String nivel) {
  switch (nivel) {
    case 'Participación auténtica':
      return Icons.verified_rounded;
    case 'Participación en desarrollo':
      return Icons.trending_up_rounded;
    case 'Participación incipiente':
      return Icons.info_outline_rounded;
    case 'Planificación adultocéntrica':
      return Icons.warning_amber_rounded;
    default:
      return Icons.analytics_rounded;
  }
}

Color _colorPorDimension(int index) {
  switch (index) {
    case 0:
      return _P.sage;
    case 1:
      return _P.teal;
    case 2:
      return _P.amber;
    default:
      return _P.teal;
  }
}

// ────────────────────────────────────────────────────────────────
class ResultadosAdminScreen extends StatefulWidget {
  const ResultadosAdminScreen({super.key});

  @override
  State<ResultadosAdminScreen> createState() => _ResultadosAdminScreenState();
}

class _ResultadosAdminScreenState extends State<ResultadosAdminScreen> {
  final _cedulaController = TextEditingController();
  bool _buscando = false;

  @override
  void initState() {
    super.initState();
    context.read<ResultadosCubit>().cargarResumenGeneral();
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    super.dispose();
  }

  void _buscar() {
    final cedula = _cedulaController.text.trim();
    if (cedula.isEmpty) return;
    setState(() => _buscando = true);
    context.read<ResultadosCubit>().buscarPorDocente(cedula);
  }

  void _limpiar() {
    _cedulaController.clear();
    setState(() => _buscando = false);
    context.read<ResultadosCubit>().limpiarBusqueda();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 780;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // ── Hero header ────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 148,
            backgroundColor: _P.navy,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.go('/admin-panel'),
            ),
            title: Text(
              'Resultados',
              style: _outfit(20,
                  weight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_P.navy, _P.teal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.bar_chart_rounded,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Métricas y Resultados',
                          style: _outfit(
                            22,
                            weight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 32 : 20,
              vertical: 24,
            ),
            sliver: BlocBuilder<ResultadosCubit, ResultadosState>(
              builder: (context, state) {
                if (state is ResultadosLoading) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: _P.teal),
                          const SizedBox(height: 16),
                          Text(
                            'Calculando métricas…',
                            style: _outfit(14,
                                color: isDark
                                    ? Colors.white70
                                    : AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is ResultadosError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline_rounded,
                              size: 48,
                              color: AppColors.error.withValues(alpha: 0.7)),
                          const SizedBox(height: 12),
                          Text(
                            state.mensaje,
                            textAlign: TextAlign.center,
                            style: _outfit(14,
                                color: isDark
                                    ? Colors.white70
                                    : AppColors.textSecondaryLight),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => context
                                .read<ResultadosCubit>()
                                .cargarResumenGeneral(),
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: Text('Reintentar',
                                style: _outfit(13, weight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _P.teal,
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is ResultadosLoaded) {
                  return SliverList(
                    delegate: SliverChildListDelegate(
                      _buildBody(state, isDark, isWide),
                    ),
                  );
                }

                return const SliverFillRemaining(
                  child: SizedBox.shrink(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBody(
      ResultadosLoaded state, bool isDark, bool isWide) {
    final resumen = state.resumen;

    return [
      // ── Tarjetas de resumen ──────────────────────────────────
      _buildResumenCards(resumen, isDark),
      const SizedBox(height: 28),

      // ── Encabezado dimensiones ───────────────────────────────
      _buildSectionHeader(
        'Índices dimensionales (promedio)',
        _P.teal,
        isDark,
      ),
      const SizedBox(height: 16),

      // ── Barras de progreso ───────────────────────────────────
      ...resumen.dimensiones.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _DimensionProgressBar(
                dimension: e.value,
                color: _colorPorDimension(e.key),
                isDark: isDark,
              ),
            ),
          ),

      const SizedBox(height: 28),

      // ── Búsqueda por docente ─────────────────────────────────
      _buildSectionHeader('Buscar por docente', _P.amber, isDark),
      const SizedBox(height: 14),
      _buildSearchBar(isDark),
      const SizedBox(height: 16),

      // ── Resultados individuales ──────────────────────────────
      if (_buscando && state.resultadosDocente.isEmpty)
        _buildEmptySearch(isDark),

      ...state.resultadosDocente.map(
        (r) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _DocenteResultCard(resultado: r, isDark: isDark),
        ),
      ),

      const SizedBox(height: 32),
    ];
  }

  // ── Tarjetas de resumen ────────────────────────────────────────
  Widget _buildResumenCards(ResumenGeneralEntity resumen, bool isDark) {
    final nivelColor = _colorPorNivel(resumen.nivelGeneral);

    return Row(
      children: [
        // IGPP General
        Expanded(
          flex: 2,
          child: _GlassCard(
            isDark: isDark,
            gradient: LinearGradient(
              colors: [
                nivelColor.withValues(alpha: isDark ? 0.22 : 0.10),
                nivelColor.withValues(alpha: isDark ? 0.08 : 0.03),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderColor: nivelColor.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: nivelColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _iconPorNivel(resumen.nivelGeneral),
                        size: 20,
                        color: nivelColor,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: nivelColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: nivelColor.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        resumen.nivelGeneral,
                        style: _outfit(9.5,
                            weight: FontWeight.w700, color: nivelColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  '${resumen.promedioIGPP.toStringAsFixed(1)}%',
                  style: _outfit(
                    32,
                    weight: FontWeight.w800,
                    color: isDark ? Colors.white : _P.navy,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'IGPP General',
                  style: _outfit(
                    11,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Total evaluaciones
        Expanded(
          child: _GlassCard(
            isDark: isDark,
            gradient: LinearGradient(
              colors: [
                _P.teal.withValues(alpha: isDark ? 0.18 : 0.08),
                _P.teal.withValues(alpha: isDark ? 0.06 : 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderColor: _P.teal.withValues(alpha: 0.25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.assignment_rounded,
                    size: 18,
                    color: _P.teal.withValues(alpha: 0.7)),
                const SizedBox(height: 14),
                Text(
                  '${resumen.totalEvaluaciones}',
                  style: _outfit(
                    28,
                    weight: FontWeight.w800,
                    color: isDark ? Colors.white : _P.navy,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Evaluaciones',
                  style: _outfit(
                    10,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Máximo posible
        Expanded(
          child: _GlassCard(
            isDark: isDark,
            gradient: LinearGradient(
              colors: [
                _P.amber.withValues(alpha: isDark ? 0.18 : 0.08),
                _P.amber.withValues(alpha: isDark ? 0.06 : 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderColor: _P.amber.withValues(alpha: 0.25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.star_rounded,
                    size: 18,
                    color: _P.amber.withValues(alpha: 0.7)),
                const SizedBox(height: 14),
                Text(
                  '60',
                  style: _outfit(
                    28,
                    weight: FontWeight.w800,
                    color: isDark ? Colors.white : _P.navy,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Puntaje máx.',
                  style: _outfit(
                    10,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Section header ─────────────────────────────────────────────
  Widget _buildSectionHeader(String title, Color accent, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: _outfit(
            15,
            weight: FontWeight.w800,
            color: isDark ? Colors.white : _P.navy,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // ── Search bar ─────────────────────────────────────────────────
  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.09),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 20,
            color: isDark
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _cedulaController,
              style: _outfit(14,
                  color: isDark ? Colors.white : _P.navy),
              decoration: InputDecoration(
                hintText: 'Ingrese la cédula del docente…',
                hintStyle: _outfit(13,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.3)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onSubmitted: (_) => _buscar(),
            ),
          ),
          if (_buscando)
            GestureDetector(
              onTap: _limpiar,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _P.terracotta.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.close_rounded,
                    size: 14, color: _P.terracotta),
              ),
            ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _buscar,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _P.teal,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Buscar',
                style: _outfit(12.5,
                    weight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state for search ─────────────────────────────────────
  Widget _buildEmptySearch(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.person_search_rounded,
            size: 40,
            color: isDark
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 10),
          Text(
            'No se encontraron evaluaciones para esta cédula.',
            style: _outfit(13,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.35)),
          ),
        ],
      ),
    );
  }
}

// ── Glass Card ──────────────────────────────────────────────────
class _GlassCard extends StatelessWidget {
  final bool isDark;
  final Gradient gradient;
  final Color borderColor;
  final Widget child;

  const _GlassCard({
    required this.isDark,
    required this.gradient,
    required this.borderColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Barra de progreso animada por dimensión ─────────────────────
class _DimensionProgressBar extends StatefulWidget {
  final InterpretacionDimensionEntity dimension;
  final Color color;
  final bool isDark;

  const _DimensionProgressBar({
    required this.dimension,
    required this.color,
    required this.isDark,
  });

  @override
  State<_DimensionProgressBar> createState() => _DimensionProgressBarState();
}

class _DimensionProgressBarState extends State<_DimensionProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progress = Tween<double>(
      begin: 0,
      end: (widget.dimension.porcentaje / 100).clamp(0.0, 1.0),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Iniciar animación después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.forward());
  }

  @override
  void didUpdateWidget(covariant _DimensionProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dimension.porcentaje != widget.dimension.porcentaje) {
      _progress = Tween<double>(
        begin: _progress.value,
        end: (widget.dimension.porcentaje / 100).clamp(0.0, 1.0),
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dimension;
    final nivelColor = _colorPorNivel(d.nivel);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1A2535) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.09)
              : Colors.black.withValues(alpha: 0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header de dimensión
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.layers_rounded,
                  size: 16,
                  color: widget.color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.nombre,
                      style: _outfit(
                        13.5,
                        weight: FontWeight.w700,
                        color: widget.isDark ? Colors.white : _P.navy,
                      ),
                    ),
                    Text(
                      '${d.puntaje.toStringAsFixed(1)} / ${d.maximo.toInt()} pts',
                      style: _outfit(
                        11,
                        color: widget.isDark
                            ? Colors.white.withValues(alpha: 0.45)
                            : Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              // Porcentaje
              Text(
                '${d.porcentaje.toStringAsFixed(1)}%',
                style: _outfit(
                  18,
                  weight: FontWeight.w800,
                  color: widget.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Barra de progreso animada
          AnimatedBuilder(
            animation: _progress,
            builder: (context, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 10,
                  child: Stack(
                    children: [
                      // Fondo
                      Container(
                        decoration: BoxDecoration(
                          color: widget.color.withValues(
                            alpha: widget.isDark ? 0.12 : 0.08,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      // Progreso
                      FractionallySizedBox(
                        widthFactor: _progress.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.color,
                                widget.color.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // ── Chip de nivel cualitativo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: nivelColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: nivelColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _iconPorNivel(d.nivel),
                  size: 11,
                  color: nivelColor,
                ),
                const SizedBox(width: 5),
                Text(
                  d.nivel,
                  style: _outfit(10,
                      weight: FontWeight.w700, color: nivelColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta de resultado individual por docente ─────────────────
class _DocenteResultCard extends StatefulWidget {
  final ResultadosInterpretadosEntity resultado;
  final bool isDark;

  const _DocenteResultCard({
    required this.resultado,
    required this.isDark,
  });

  @override
  State<_DocenteResultCard> createState() => _DocenteResultCardState();
}

class _DocenteResultCardState extends State<_DocenteResultCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeSlide;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeSlide = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.resultado;
    final nivelColor = _colorPorNivel(r.nivelGeneral);

    return FadeTransition(
      opacity: _fadeSlide,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(_fadeSlide),
        child: Container(
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1A2535) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.09)
                  : Colors.black.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Header
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                borderRadius:
                    BorderRadius.vertical(top: const Radius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _P.teal.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _P.teal.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            r.docenteNombre.isNotEmpty
                                ? r.docenteNombre[0].toUpperCase()
                                : '?',
                            style: _outfit(16,
                                weight: FontWeight.w800, color: _P.teal),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.docenteNombre,
                              style: _outfit(14,
                                  weight: FontWeight.w700,
                                  color: widget.isDark
                                      ? Colors.white
                                      : _P.navy),
                            ),
                            Text(
                              'CI: ${r.docenteCedula}',
                              style: _outfit(11,
                                  color: widget.isDark
                                      ? Colors.white.withValues(alpha: 0.45)
                                      : Colors.black.withValues(alpha: 0.4)),
                            ),
                          ],
                        ),
                      ),
                      // IGPP badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: nivelColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: nivelColor.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${r.igpp.toStringAsFixed(1)}%',
                              style: _outfit(14,
                                  weight: FontWeight.w800,
                                  color: nivelColor),
                            ),
                            Text(
                              'IGPP',
                              style: _outfit(8,
                                  weight: FontWeight.w600,
                                  color:
                                      nivelColor.withValues(alpha: 0.7)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: widget.isDark
                              ? Colors.white.withValues(alpha: 0.35)
                              : Colors.black.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Expanded detail
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      Divider(
                        color: widget.isDark
                            ? Colors.white.withValues(alpha: 0.07)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                      const SizedBox(height: 8),
                      // Nivel general + dimensión prioritaria
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: nivelColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: nivelColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_iconPorNivel(r.nivelGeneral),
                                    size: 11, color: nivelColor),
                                const SizedBox(width: 4),
                                Text(r.nivelGeneral,
                                    style: _outfit(10,
                                        weight: FontWeight.w700,
                                        color: nivelColor)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.priority_high_rounded,
                              size: 13,
                              color: _P.terracotta.withValues(alpha: 0.7)),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              'Prioridad: ${r.dimensionPrioritaria}',
                              style: _outfit(10.5,
                                  weight: FontWeight.w600,
                                  color: _P.terracotta),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Mini barras por dimensión
                      ...r.dimensiones.asMap().entries.map(
                            (e) => _MiniDimensionRow(
                              dimension: e.value,
                              color: _colorPorDimension(e.key),
                              isDark: widget.isDark,
                            ),
                          ),
                      const SizedBox(height: 6),
                      // Puntaje total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Total: ${r.puntajeTotal.toStringAsFixed(0)} / ${r.maximoTotal.toStringAsFixed(0)}',
                            style: _outfit(11,
                                weight: FontWeight.w700,
                                color: widget.isDark
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : Colors.black.withValues(alpha: 0.4)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mini row para dimensión dentro de un card de docente ─────────
class _MiniDimensionRow extends StatelessWidget {
  final InterpretacionDimensionEntity dimension;
  final Color color;
  final bool isDark;

  const _MiniDimensionRow({
    required this.dimension,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final d = dimension;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              d.nombre,
              style: _outfit(11,
                  weight: FontWeight.w600,
                  color: isDark ? Colors.white.withValues(alpha: 0.7) : _P.navy),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 7,
                child: LinearProgressIndicator(
                  value: (d.porcentaje / 100).clamp(0.0, 1.0),
                  backgroundColor:
                      color.withValues(alpha: isDark ? 0.12 : 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 45,
            child: Text(
              '${d.porcentaje.toStringAsFixed(0)}%',
              textAlign: TextAlign.right,
              style: _outfit(11,
                  weight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
