import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../controller/auth_controller.dart';
import '../widgets/aviso_rol_dialog.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/assets_constants.dart';

class IngresoCedulaScreen extends StatefulWidget {
  const IngresoCedulaScreen({super.key});

  @override
  State<IngresoCedulaScreen> createState() => _IngresoCedulaScreenState();
}

class _IngresoCedulaScreenState extends State<IngresoCedulaScreen> {
  final TextEditingController _cedulaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _cedulaController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().verificarCedula(_cedulaController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.mensaje)),
                  ],
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          } else if (state is AuthAdminPrompt) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => AvisoRolDialog(
                usuario: state.usuario,
                onResponderEncuesta: () {
                  context.read<AuthCubit>().elegirResponderEncuesta(state.usuario);
                },
                onPanelAdministracion: () {
                  context.read<AuthCubit>().elegirAccederPanelAdmin(state.usuario);
                },
              ),
            );
          } else if (state is AuthAuthenticatedUser) {
            context.go('/encuesta');
          } else if (state is AuthAdminPasswordPrompt) {
            context.go('/admin-contrasena', extra: state.usuario);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.backgroundDark,
                      AppColors.surfaceDark,
                      AppColors.backgroundDark,
                    ]
                  : [
                      const Color(0xFFF5F0E8), // warm ivory
                      const Color(0xFFE8F1F2), // light teal tint
                      AppColors.backgroundLight,
                    ],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  // Vista Web / Tablet (Diseño Split Screen)
                  return Row(
                    children: [
                      // Lado Izquierdo (Fondo diferenciado y logo grande)
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [
                                      const Color(0xFF1E293B),
                                      const Color(0xFF0F172A),
                                    ]
                                  : [
                                      const Color(0xFFE2E8F0),
                                      const Color(0xFFCBD5E1),
                                    ],
                            ),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(32.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                AssetsConstants.logo,
                                height: 220,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Lado Derecho (Formulario centrado sin logo repetido)
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(32.0),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 450),
                              child: _buildCard(context, theme, isDark, false),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Vista Móvil (Tarjeta centrada con logo de tamaño controlado)
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: _buildCard(context, theme, isDark, true),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  // Componente de Tarjeta de Formulario reutilizable
  Widget _buildCard(BuildContext context, ThemeData theme, bool isDark, bool mostrarLogo) {
    return Card(
      elevation: isDark ? 8 : 4,
      shadowColor: AppColors.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (mostrarLogo) ...[
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      AssetsConstants.logo,
                      height: 90,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Text(
                '¡Hola!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Ingrese su cédula de identidad para comenzar la encuesta.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _cedulaController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: 'Cédula de Identidad',
                  prefixIcon: Icon(Icons.credit_card_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingrese su cédula';
                  }
                  if (value.trim().length < 3) {
                    return 'Ingrese una cédula válida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  return ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Ingresar'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
