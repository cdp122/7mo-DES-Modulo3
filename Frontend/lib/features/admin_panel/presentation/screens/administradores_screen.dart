import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/auth/presentation/controller/auth_controller.dart';
import '../../domain/entities/administrador.dart';
import '../controller/administradores_cubit.dart';
import '../controller/administradores_state.dart';

// ── Paleta ───────────────────────────────────────────────────────
class _P {
  static const navy      = Color(0xFF16305B);
  static const teal      = Color(0xFF2C86A0);
  static const sage      = Color(0xFF4E9A6B);
  static const amber     = Color(0xFFDFA235);
  static const terracotta= Color(0xFFD2693E);
}

TextStyle _outfit(double size,
    {FontWeight weight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    double? height}) =>
    GoogleFonts.outfit(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height);

// ── Colores por rol ───────────────────────────────────────────────
Color _rolColor(String rol) => rol == 'admin' ? _P.teal : _P.amber;
IconData _rolIcon(String rol) =>
    rol == 'admin' ? Icons.admin_panel_settings_rounded : Icons.person_rounded;
String _rolLabel(String rol) => rol == 'admin' ? 'Administrador' : 'Docente';

// ════════════════════════════════════════════════════════════════
class AdministradoresScreen extends StatefulWidget {
  const AdministradoresScreen({super.key});

  @override
  State<AdministradoresScreen> createState() => _AdministradoresScreenState();
}

class _AdministradoresScreenState extends State<AdministradoresScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AdministradoresCubit>().cargar();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Obtiene la cedula del admin actualmente logueado para bloquear auto-cambio de rol
  String? get _adminActualCedula {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticatedAdmin) return authState.usuario.cedula;
    return null;
  }

  // ── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width  = MediaQuery.of(context).size.width;
    final isWide = width > 700;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      floatingActionButton: _Fab(isDark: isDark, onTap: () => _dlgCrear(context, isDark)),
      body: CustomScrollView(
        slivers: [
          // ── AppBar hero ──────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 148,
            backgroundColor: _P.navy,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.go('/admin-panel'),
            ),
            title: Text('Administradores',
                style: _outfit(20,
                    weight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3)),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_P.navy, _P.terracotta],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25)),
                          ),
                          child: const Icon(Icons.manage_accounts_rounded,
                              size: 28, color: Colors.white),
                        ),
                        const SizedBox(width: 14),
                        Text('Gestión de Usuarios',
                            style: _outfit(22,
                                weight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5)),
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
                horizontal: isWide ? 32 : 16, vertical: 20),
            sliver: BlocConsumer<AdministradoresCubit, AdministradoresState>(
              listener: (context, state) {
                if (state is AdministradoresActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Row(children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 10),
                      Text(state.mensaje,
                          style: _outfit(13, color: Colors.white)),
                    ]),
                    backgroundColor: _P.sage,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(16),
                  ));
                } else if (state is AdministradoresError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Row(children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(state.mensaje,
                              style: _outfit(13, color: Colors.white))),
                    ]),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(16),
                  ));
                }
              },
              builder: (context, state) {
                if (state is AdministradoresLoading) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: _P.terracotta),
                        const SizedBox(height: 14),
                        Text('Cargando usuarios…',
                            style: _outfit(13,
                                color: isDark
                                    ? Colors.white54
                                    : AppColors.textSecondaryLight)),
                      ],
                    )),
                  );
                }

                if (state is AdministradoresLoaded) {
                  return SliverList(
                    delegate: SliverChildListDelegate(
                        _buildBody(context, state, isDark, isWide)),
                  );
                }

                if (state is AdministradoresError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ErrorView(
                        mensaje: state.mensaje,
                        onRetry: () =>
                            context.read<AdministradoresCubit>().cargar()),
                  );
                }

                return const SliverFillRemaining(child: SizedBox.shrink());
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Cuerpo principal ──────────────────────────────────────────
  List<Widget> _buildBody(BuildContext ctx, AdministradoresLoaded state,
      bool isDark, bool isWide) {
    return [
      // Stats row
      _StatsRow(total: state.todos.length, admins: state.todos.where((a) => a.esAdmin).length, isDark: isDark),
      const SizedBox(height: 20),

      // Barra búsqueda + ordenamiento
      _buildToolbar(ctx, state, isDark),
      const SizedBox(height: 16),

      // Lista
      if (state.filtrados.isEmpty)
        _EmptySearch(isDark: isDark)
      else
        ...state.filtrados.map((admin) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AdminCard(
                admin: admin,
                isDark: isDark,
                esPropioAdmin: admin.cedula == _adminActualCedula,
                onEditar: () => _dlgEditar(ctx, admin, isDark),
                onCambiarRol: () => _dlgCambiarRol(ctx, admin, isDark),
              ),
            )),

      const SizedBox(height: 80), // Espacio para el FAB
    ];
  }

  // ── Toolbar ───────────────────────────────────────────────────
  Widget _buildToolbar(
      BuildContext ctx, AdministradoresLoaded state, bool isDark) {
    return Row(
      children: [
        // Búsqueda
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.09)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2))
              ],
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.search_rounded,
                    size: 18,
                    color: isDark
                        ? Colors.white38
                        : Colors.black26),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: _outfit(13.5,
                        color: isDark ? Colors.white : _P.navy),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre, cédula o email…',
                      hintStyle: _outfit(13,
                          color: isDark
                              ? Colors.white30
                              : Colors.black26),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (v) =>
                        ctx.read<AdministradoresCubit>().buscar(v),
                  ),
                ),
                if (_searchCtrl.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      ctx.read<AdministradoresCubit>().buscar('');
                    },
                    child: Icon(Icons.close_rounded,
                        size: 16,
                        color: isDark ? Colors.white38 : Colors.black26),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Ordenamiento
        _OrdenDropdown(
            current: state.ordenamiento,
            isDark: isDark,
            onChanged: (v) => ctx.read<AdministradoresCubit>().ordenar(v)),
      ],
    );
  }

  // ── Diálogos ──────────────────────────────────────────────────
  void _dlgCrear(BuildContext ctx, bool isDark) {
    showDialog(
      context: ctx,
      builder: (_) => _FormAdminDialog(
        titulo: 'Nuevo Administrador',
        isDark: isDark,
        onGuardar: (cedula, nombre, email, pass) {
          ctx.read<AdministradoresCubit>().crear(
                cedula: cedula,
                nombre: nombre,
                email: email,
                password: pass!,
              );
        },
      ),
    );
  }

  void _dlgEditar(BuildContext ctx, AdministradorEntity admin, bool isDark) {
    showDialog(
      context: ctx,
      builder: (_) => _FormAdminDialog(
        titulo: 'Editar Administrador',
        isDark: isDark,
        admin: admin,
        onGuardar: (cedula, nombre, email, pass) {
          ctx.read<AdministradoresCubit>().actualizar(
                id: admin.id,
                nombre: nombre != admin.nombre ? nombre : null,
                email: email != admin.email ? email : null,
                password: pass,
              );
        },
      ),
    );
  }

  void _dlgCambiarRol(BuildContext ctx, AdministradorEntity admin, bool isDark) {
    final nuevoRol = admin.esAdmin ? 'docente' : 'admin';
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(Icons.swap_horiz_rounded, color: _P.amber, size: 22),
          const SizedBox(width: 10),
          Expanded(
              child: Text('Cambiar Rol',
                  style: _outfit(16, weight: FontWeight.w700))),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            '¿Cambiar el rol de ${admin.nombre} de "${_rolLabel(admin.rol)}" a "${_rolLabel(nuevoRol)}"?',
            style: _outfit(14,
                height: 1.5, color: AppColors.textSecondaryLight),
          ),
          if (nuevoRol == 'docente') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _P.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: _P.amber.withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                Icon(Icons.warning_amber_rounded,
                    size: 16, color: _P.amber),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                  'Este usuario perderá acceso al panel de administración.',
                  style: _outfit(11.5,
                      color: _P.amber, weight: FontWeight.w600),
                )),
              ]),
            ),
          ],
        ]),
        actionsPadding:
            const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar', style: _outfit(13))),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ctx.read<AdministradoresCubit>().cambiarRol(
                    id: admin.id,
                    nuevoRol: nuevoRol,
                  );
            },
            icon: const Icon(Icons.swap_horiz_rounded, size: 16),
            label: Text('Confirmar',
                style: _outfit(13, weight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
                backgroundColor: _P.amber,
                foregroundColor: Colors.white,
                elevation: 0),
          ),
        ],
      ),
    );
  }
}

// ── FAB ──────────────────────────────────────────────────────────
class _Fab extends StatefulWidget {
  final bool isDark;
  final VoidCallback onTap;
  const _Fab({required this.isDark, required this.onTap});

  @override
  State<_Fab> createState() => _FabState();
}

class _FabState extends State<_Fab> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [_P.terracotta, Color(0xFFC4562B)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: _P.terracotta.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6))
            ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.person_add_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Nuevo Admin',
                style: _outfit(13,
                    weight: FontWeight.w700, color: Colors.white)),
          ]),
        ),
      ),
    );
  }
}

// ── Stats row ────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final int total;
  final int admins;
  final bool isDark;
  const _StatsRow(
      {required this.total, required this.admins, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _StatChip(
          icon: Icons.people_rounded,
          label: 'Total usuarios',
          value: '$total',
          color: _P.navy,
          isDark: isDark),
      const SizedBox(width: 10),
      _StatChip(
          icon: Icons.admin_panel_settings_rounded,
          label: 'Admins activos',
          value: '$admins',
          color: _P.teal,
          isDark: isDark),
      const SizedBox(width: 10),
      _StatChip(
          icon: Icons.person_rounded,
          label: 'Docentes',
          value: '${total - admins}',
          color: _P.amber,
          isDark: isDark),
    ]);
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  const _StatChip(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: color.withValues(alpha: isDark ? 0.28 : 0.18)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(height: 8),
          Text(value,
              style: _outfit(20,
                  weight: FontWeight.w800,
                  color: isDark ? Colors.white : _P.navy,
                  height: 1)),
          Text(label,
              style: _outfit(9.5,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.45)
                      : Colors.black.withValues(alpha: 0.4))),
        ]),
      ),
    );
  }
}

// ── Orden dropdown ────────────────────────────────────────────────
class _OrdenDropdown extends StatelessWidget {
  final String current;
  final bool isDark;
  final ValueChanged<String> onChanged;
  const _OrdenDropdown(
      {required this.current,
      required this.isDark,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.09)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          isDense: true,
          style: _outfit(12.5, color: isDark ? Colors.white70 : _P.navy),
          dropdownColor: isDark ? const Color(0xFF1A2535) : Colors.white,
          icon: Icon(Icons.sort_rounded,
              size: 16,
              color: isDark ? Colors.white38 : Colors.black26),
          items: const [
            DropdownMenuItem(value: 'nombre_asc', child: Text('Nombre A-Z')),
            DropdownMenuItem(value: 'nombre_desc', child: Text('Nombre Z-A')),
            DropdownMenuItem(value: 'cedula_asc', child: Text('Cédula ↑')),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

// ── Admin Card ────────────────────────────────────────────────────
class _AdminCard extends StatefulWidget {
  final AdministradorEntity admin;
  final bool isDark;
  final bool esPropioAdmin;
  final VoidCallback onEditar;
  final VoidCallback onCambiarRol;

  const _AdminCard({
    required this.admin,
    required this.isDark,
    required this.esPropioAdmin,
    required this.onEditar,
    required this.onCambiarRol,
  });

  @override
  State<_AdminCard> createState() => _AdminCardState();
}

class _AdminCardState extends State<_AdminCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween(begin: 1.0, end: 0.975)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.admin;
    final rolColor = _rolColor(a.rol);
    final bg = widget.isDark ? const Color(0xFF1A2535) : Colors.white;
    final borderColor = _hovered
        ? rolColor.withValues(alpha: 0.45)
        : (widget.isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.08));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.4),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                        color: rolColor.withValues(alpha: 0.16),
                        blurRadius: 18,
                        offset: const Offset(0, 5))
                  ]
                : [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 7,
                        offset: const Offset(0, 2))
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              // ── Avatar ─────────────────────────────────────
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: rolColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                      color: rolColor.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    a.nombre.isNotEmpty
                        ? a.nombre[0].toUpperCase()
                        : '?',
                    style: _outfit(18,
                        weight: FontWeight.w800, color: rolColor),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // ── Info ────────────────────────────────────────
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Expanded(
                      child: Text(a.nombre,
                          style: _outfit(14,
                              weight: FontWeight.w700,
                              color: widget.isDark
                                  ? Colors.white
                                  : _P.navy),
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (widget.esPropioAdmin)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _P.sage.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: _P.sage.withValues(alpha: 0.35)),
                        ),
                        child: Text('Tú',
                            style: _outfit(9.5,
                                weight: FontWeight.w700,
                                color: _P.sage)),
                      ),
                  ]),
                  const SizedBox(height: 3),
                  Text('CI: ${a.cedula}',
                      style: _outfit(11.5,
                          color: widget.isDark
                              ? Colors.white.withValues(alpha: 0.45)
                              : Colors.black.withValues(alpha: 0.4))),
                  if (a.email.isNotEmpty) ...[
                    Text(a.email,
                        style: _outfit(11.5,
                            color: widget.isDark
                                ? Colors.white.withValues(alpha: 0.35)
                                : Colors.black.withValues(alpha: 0.32)),
                        overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 8),
                  // Chip de rol
                  _RolChip(rol: a.rol),
                ]),
              ),

              // ── Acciones ────────────────────────────────────
              Column(mainAxisSize: MainAxisSize.min, children: [
                _ActionBtn(
                  icon: Icons.edit_rounded,
                  color: _P.teal,
                  tooltip: 'Editar',
                  isDark: widget.isDark,
                  onTap: widget.onEditar,
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Rol Chip ──────────────────────────────────────────────────────
class _RolChip extends StatelessWidget {
  final String rol;
  const _RolChip({required this.rol});

  @override
  Widget build(BuildContext context) {
    final color = _rolColor(rol);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_rolIcon(rol), size: 11, color: color),
        const SizedBox(width: 4),
        Text(_rolLabel(rol),
            style:
                _outfit(10, weight: FontWeight.w700, color: color)),
      ]),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionBtn(
      {required this.icon,
      required this.color,
      required this.tooltip,
      required this.isDark,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.14 : 0.09),
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

// ── Formulario Crear / Editar ─────────────────────────────────────
class _FormAdminDialog extends StatefulWidget {
  final String titulo;
  final bool isDark;
  final AdministradorEntity? admin; // null → crear
  final void Function(String cedula, String nombre, String email, String? pass)
      onGuardar;

  const _FormAdminDialog({
    required this.titulo,
    required this.isDark,
    required this.onGuardar,
    this.admin,
  });

  @override
  State<_FormAdminDialog> createState() => _FormAdminDialogState();
}

class _FormAdminDialogState extends State<_FormAdminDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _cedulaCtrl;
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passCtrl;
  bool _obscure = true;
  bool _modoCrear = true;

  @override
  void initState() {
    super.initState();
    _modoCrear = widget.admin == null;
    _cedulaCtrl =
        TextEditingController(text: widget.admin?.cedula ?? '');
    _nombreCtrl =
        TextEditingController(text: widget.admin?.nombre ?? '');
    _emailCtrl =
        TextEditingController(text: widget.admin?.email ?? '');
    _passCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onGuardar(
        _cedulaCtrl.text.trim(),
        _nombreCtrl.text.trim(),
        "",
        _passCtrl.text.trim().isNotEmpty ? _passCtrl.text.trim() : null,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding:
          const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _P.terracotta.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _modoCrear
                ? Icons.person_add_rounded
                : Icons.edit_rounded,
            color: _P.terracotta,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Text(widget.titulo,
                style: _outfit(15, weight: FontWeight.w700))),
      ]),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cédula (solo en creación)
              if (_modoCrear) ...[
                _Campo(
                  ctrl: _cedulaCtrl,
                  label: 'Cédula',
                  icon: Icons.badge_rounded,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'La cédula es obligatoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
              ],

              // Nombre
              _Campo(
                ctrl: _nombreCtrl,
                label: 'Nombre completo',
                icon: Icons.person_outline_rounded,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),



              // Contraseña
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                style: _outfit(13.5,
                    color: widget.isDark ? Colors.white : _P.navy),
                decoration: InputDecoration(
                  labelText: _modoCrear
                      ? 'Contraseña'
                      : 'Nueva contraseña (opcional)',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () =>
                        setState(() => _obscure = !_obscure),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  helperText: _modoCrear
                      ? null
                      : 'Dejar vacío para conservar la contraseña actual',
                  helperStyle: _outfit(11,
                      color: AppColors.textSecondaryLight),
                ),
                validator: (v) {
                  if (_modoCrear &&
                      (v == null || v.trim().isEmpty)) {
                    return 'La contraseña es obligatoria';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: _outfit(13))),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _submit,
          icon: Icon(
              _modoCrear ? Icons.person_add_rounded : Icons.save_rounded,
              size: 16),
          label: Text(_modoCrear ? 'Crear' : 'Guardar',
              style: _outfit(13, weight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
              backgroundColor: _P.terracotta,
              foregroundColor: Colors.white,
              elevation: 0),
        ),
      ],
    );
  }
}

// ── Campo de texto reutilizable ───────────────────────────────────
class _Campo extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Campo({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
    );
  }
}

// ── Empty search ──────────────────────────────────────────────────
class _EmptySearch extends StatelessWidget {
  final bool isDark;
  const _EmptySearch({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.search_off_rounded,
              size: 42,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.14)),
          const SizedBox(height: 10),
          Text('No se encontraron usuarios con ese criterio.',
              style: _outfit(13,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.38)
                      : Colors.black.withValues(alpha: 0.32))),
        ]),
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String mensaje;
  final VoidCallback onRetry;
  const _ErrorView({required this.mensaje, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.error_outline_rounded,
            size: 48,
            color: AppColors.error.withValues(alpha: 0.7)),
        const SizedBox(height: 12),
        Text(mensaje,
            textAlign: TextAlign.center,
            style:
                _outfit(13, color: AppColors.textSecondaryLight)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label:
              Text('Reintentar', style: _outfit(13, weight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
              backgroundColor: _P.terracotta,
              foregroundColor: Colors.white,
              elevation: 0),
        ),
      ]),
    );
  }
}
