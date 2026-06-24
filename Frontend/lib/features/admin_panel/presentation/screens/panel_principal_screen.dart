import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

// ── Alias locales de la paleta para este archivo ────────────────
class _P {
  static const navy       = Color(0xFF16305B);
  static const teal       = Color(0xFF2C86A0);
  static const sage       = Color(0xFF4E9A6B);
  static const amber      = Color(0xFFDFA235);
  static const terracotta = Color(0xFFD2693E);
}

// ── Helpers de texto con Outfit ──────────────────────────────────
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

// ────────────────────────────────────────────────────────────────
class PanelPrincipalScreen extends StatelessWidget {
  const PanelPrincipalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width  = MediaQuery.of(context).size.width;

    // Breakpoints
    final isWide   = width > 780;
    final isMedium = width > 480;

    // Tarjetas de módulo
    final modules = [
      _CardData(
        icon:        Icons.quiz_rounded,
        title:       'Reactivos',
        subtitle:    'Crear, editar y eliminar preguntas por dimensión.',
        accent:      _P.sage,
        badge:       'D1 · D2 · D3',
        status:      'Activo',
        isActive:    true,
        onTap:       () => context.go('/gestion-preguntas'),
      ),
      _CardData(
        icon:     Icons.bar_chart_rounded,
        title:    'Resultados',
        subtitle: 'Promedios dimensionales e índices de docentes.',
        accent:   _P.teal,
        badge:    'Próximamente',
        status:   'En desarrollo',
        isActive: false,
        onTap:    () => _dlgProximamente(context, 'Resultados y Reportes'),
      ),
      _CardData(
        icon:     Icons.manage_accounts_rounded,
        title:    'Administradores',
        subtitle: 'Registrar cuentas y gestionar credenciales de acceso.',
        accent:   _P.terracotta,
        badge:    'Próximamente',
        status:   'En desarrollo',
        isActive: false,
        onTap:    () => _dlgProximamente(context, 'Gestión de Administradores'),
      ),
    ];

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // ── Hero expandible ─────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 148,
            backgroundColor: _P.navy,
            elevation: 0,
            actions: [
              TextButton.icon(
                onPressed: () => _dlgLogout(context),
                icon: const Icon(Icons.logout_rounded,
                    color: Colors.white70, size: 16),
                label: Text('Salir',
                    style: _outfit(13, color: Colors.white70)),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 56, bottom: 13),
              collapseMode: CollapseMode.pin,
              title: Text('Panel de Administración',
                  style: _outfit(15,
                      weight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2)),
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
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar icono
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25)),
                          ),
                          child: const Icon(
                              Icons.admin_panel_settings_rounded,
                              size: 28,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Administración del Sistema',
                                  style: _outfit(17,
                                      weight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.3)),
                              const SizedBox(height: 4),
                              // Badge del proyecto con color amber
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color:
                                      _P.amber.withValues(alpha: 0.28),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: _P.amber
                                          .withValues(alpha: 0.45)),
                                ),
                                child: Text('Módulo 3 — Águilas',
                                    style: _outfit(11,
                                        weight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 0.3)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Cuerpo ──────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 32 : 20,
              vertical: 24,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Fila de estadísticas ─────────────────────
                _StatsRow(isDark: isDark),
                const SizedBox(height: 28),

                // ── Encabezado sección módulos ───────────────
                Row(children: [
                  Container(
                    width: 4, height: 18,
                    decoration: BoxDecoration(
                      color: _P.teal,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Módulos del sistema',
                      style: _outfit(15,
                          weight: FontWeight.w800,
                          color: isDark ? Colors.white : _P.navy,
                          letterSpacing: 0.2)),
                  const Spacer(),
                  Text('3 módulos',
                      style: _outfit(12,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.35))),
                ]),
                const SizedBox(height: 16),

                // ── Grid de módulos (sin aspect ratio rígido) ─
                _buildModulesSection(
                  modules: modules,
                  isWide: isWide,
                  isMedium: isMedium,
                  isDark: isDark,
                ),

                const SizedBox(height: 32),

                // ── Accesos rápidos ──────────────────────────
                _QuickAccessSection(isDark: isDark),
                const SizedBox(height: 40),

                // ── Footer ───────────────────────────────────
                _FooterSection(
                  isDark: isDark,
                  onLogout: () => _dlgLogout(context),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Grid adaptativo sin aspect-ratio fijo ──────────────────────
  Widget _buildModulesSection({
    required List<_CardData> modules,
    required bool isWide,
    required bool isMedium,
    required bool isDark,
  }) {
    if (isWide) {
      // 3 columnas en pantalla ancha
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: modules.asMap().entries.map((e) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    left: e.key == 0 ? 0 : 8,
                    right: e.key == modules.length - 1 ? 0 : 8),
                child: _ModuleCard(data: e.value, isDark: isDark),
              ),
            );
          }).toList(),
        ),
      );
    }

    if (isMedium) {
      // 2 columnas en tablet
      return Column(children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                  child: _ModuleCard(data: modules[0], isDark: isDark)),
              const SizedBox(width: 12),
              Expanded(
                  child: _ModuleCard(data: modules[1], isDark: isDark)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ModuleCard(data: modules[2], isDark: isDark),
      ]);
    }

    // 1 columna en móvil
    return Column(
      children: modules
          .map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ModuleCard(data: m, isDark: isDark),
              ))
          .toList(),
    );
  }

  // ── Diálogos ──────────────────────────────────────────────────
  void _dlgLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.logout_rounded,
              color: AppColors.error, size: 22),
          const SizedBox(width: 10),
          Text('¿Cerrar sesión?',
              style: _outfit(17, weight: FontWeight.w700)),
        ]),
        content: Text(
          'Su sesión como Administrador será terminada.',
          style: _outfit(14, height: 1.6,
              color: AppColors.textSecondaryLight),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: _outfit(14)),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.go('/');
            },
            icon: const Icon(Icons.logout_rounded, size: 16),
            label: Text('Cerrar sesión', style: _outfit(14,
                weight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  void _dlgProximamente(BuildContext context, String nombre) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _P.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.construction_rounded,
                color: _P.amber, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(nombre,
                style: _outfit(15, weight: FontWeight.w700)),
          ),
        ]),
        content: Text(
          'Este módulo está en desarrollo y estará disponible próximamente.',
          style: _outfit(14, height: 1.6,
              color: AppColors.textSecondaryLight),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _P.navy,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text('Entendido', style: _outfit(14,
                weight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Modelo de datos de tarjeta ───────────────────────────────────
class _CardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final String badge;
  final String status;
  final bool isActive;
  final VoidCallback onTap;

  const _CardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.badge,
    required this.status,
    required this.isActive,
    required this.onTap,
  });
}

// ── Tarjeta de módulo ────────────────────────────────────────────
class _ModuleCard extends StatefulWidget {
  final _CardData data;
  final bool isDark;

  const _ModuleCard({required this.data, required this.isDark});

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final bg = widget.isDark ? const Color(0xFF1A2535) : Colors.white;
    final border = _hovered
        ? d.accent.withValues(alpha: 0.55)
        : (widget.isDark
            ? Colors.white.withValues(alpha: 0.09)
            : Colors.black.withValues(alpha: 0.09));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown:  (_) => _ctrl.forward(),
        onTapUp:    (_) { _ctrl.reverse(); d.onTap(); },
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border, width: 1.5),
              boxShadow: _hovered
                  ? [BoxShadow(
                      color: d.accent.withValues(alpha: 0.18),
                      blurRadius: 20, offset: const Offset(0, 6))]
                  : [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,   // ← clave: sin Expanded
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Cabecera coloreada ─────────────────────
                Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: d.accent.withValues(
                        alpha: widget.isDark ? 0.20 : 0.09),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(17)),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icono
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: d.accent.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                              color: d.accent.withValues(alpha: 0.3)),
                        ),
                        child: Icon(d.icon, size: 22, color: d.accent),
                      ),
                      const Spacer(),
                      // Badge de estado
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: d.isActive
                              ? _P.sage.withValues(alpha: 0.14)
                              : d.accent.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: d.isActive
                                ? _P.sage.withValues(alpha: 0.4)
                                : d.accent.withValues(alpha: 0.28),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6, height: 6,
                              decoration: BoxDecoration(
                                color: d.isActive
                                    ? _P.sage
                                    : d.accent.withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(d.status,
                                style: _outfit(10,
                                    weight: FontWeight.w700,
                                    color: d.isActive
                                        ? _P.sage
                                        : d.accent)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Cuerpo textual ─────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.title,
                          style: _outfit(16,
                              weight: FontWeight.w800,
                              color: widget.isDark
                                  ? Colors.white
                                  : _P.navy,
                              letterSpacing: -0.2)),
                      const SizedBox(height: 5),
                      Text(d.subtitle,
                          style: _outfit(12.5,
                              height: 1.45,
                              color: widget.isDark
                                  ? Colors.white.withValues(alpha: 0.52)
                                  : Colors.black.withValues(alpha: 0.45))),
                      const SizedBox(height: 12),
                      // CTA chip
                      Row(children: [
                        Text(
                            d.isActive ? 'Ir al módulo' : d.badge,
                            style: _outfit(11.5,
                                weight: FontWeight.w700,
                                color: d.accent)),
                        if (d.isActive) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded,
                              size: 12, color: d.accent),
                        ],
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Fila de estadísticas ─────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final bool isDark;
  const _StatsRow({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _StatTile(
          icon: Icons.quiz_outlined,
          label: 'Reactivos',
          value: '—',
          color: _P.sage,
          isDark: isDark),
      const SizedBox(width: 10),
      _StatTile(
          icon: Icons.people_outline_rounded,
          label: 'Docentes',
          value: '—',
          color: _P.teal,
          isDark: isDark),
      const SizedBox(width: 10),
      _StatTile(
          icon: Icons.layers_outlined,
          label: 'Dimensiones',
          value: '3',
          color: _P.amber,
          isDark: isDark),
    ]);
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: color.withValues(alpha: isDark ? 0.28 : 0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 8),
          Text(value,
              style: _outfit(20,
                  weight: FontWeight.w800,
                  color: isDark ? Colors.white : _P.navy,
                  height: 1)),
          const SizedBox(height: 2),
          Text(label,
              style: _outfit(10,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.45)
                      : Colors.black.withValues(alpha: 0.4))),
        ]),
      ),
    );
  }
}

// ── Accesos rápidos ──────────────────────────────────────────────
class _QuickAccessSection extends StatelessWidget {
  final bool isDark;
  const _QuickAccessSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Encabezado
      Row(children: [
        Container(
          width: 4, height: 18,
          decoration: BoxDecoration(
              color: _P.amber, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        Text('Accesos rápidos',
            style: _outfit(15,
                weight: FontWeight.w800,
                color: isDark ? Colors.white : _P.navy,
                letterSpacing: 0.2)),
      ]),
      const SizedBox(height: 14),
      Wrap(spacing: 10, runSpacing: 10, children: [
        _QChip(
            icon: Icons.add_circle_outline_rounded,
            label: 'Nuevo reactivo',
            color: _P.sage,
            isDark: isDark,
            onTap: () => context.go('/gestion-preguntas')),
        _QChip(
            icon: Icons.filter_list_rounded,
            label: 'Filtrar por dimensión',
            color: _P.teal,
            isDark: isDark,
            onTap: () => context.go('/gestion-preguntas')),
        _QChip(
            icon: Icons.help_outline_rounded,
            label: 'Ayuda del sistema',
            color: _P.amber,
            isDark: isDark,
            onTap: () {}),
      ]),
    ]);
  }
}

class _QChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _QChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: color.withValues(alpha: isDark ? 0.28 : 0.2)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 7),
          Text(label,
              style: _outfit(12.5,
                  weight: FontWeight.w600,
                  color: isDark ? Colors.white.withValues(alpha: 0.85) : _P.navy)),
        ]),
      ),
    );
  }
}

// ── Footer ───────────────────────────────────────────────────────
class _FooterSection extends StatelessWidget {
  final bool isDark;
  final VoidCallback onLogout;
  const _FooterSection({required this.isDark, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Divider(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.07)),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Sistema de Evaluación Docente v1.0',
              style: _outfit(11,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.28)
                      : Colors.black.withValues(alpha: 0.28))),
          TextButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.exit_to_app_rounded,
                color: AppColors.error, size: 14),
            label: Text('Cerrar sesión',
                style: _outfit(12.5,
                    weight: FontWeight.w600, color: AppColors.error)),
            style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
          ),
        ],
      ),
    ]);
  }
}
