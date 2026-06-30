import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/audio_service.dart';

class PortadaScreen extends StatefulWidget {
  final String cedulaDocente;
  
  const PortadaScreen({
    super.key, 
    required this.cedulaDocente,
  });

  @override
  State<PortadaScreen> createState() => _PortadaScreenState();
}

class _PortadaScreenState extends State<PortadaScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _reproducirMusica();
  }

  Future<void> _reproducirMusica() async {
    try {
      await AudioService().playBackgroundMusic();
    } catch (e) {
      debugPrint('Error iniciando música global: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool esPantallaAncha = MediaQuery.of(context).size.width > 750;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 1000),
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 25, offset: const Offset(0, 10))
                ],
              ),
              // Aquí reemplazamos ScrollView por una Columna con Expanded y Flexible
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo Superior
                  Flexible(
                    flex: 1,
                    child: Image.asset(
                      'assets/images/Inicio1.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Análisis de Planificación',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimaryLight, letterSpacing: -0.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Contenido Central (Oso y Texto)
                  Expanded(
                    flex: 4,
                    child: Flex(
                      direction: esPantallaAncha ? Axis.horizontal : Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 2,
                          child: AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _animation.value),
                                child: child,
                              );
                            },
                            child: Image.asset(
                              'assets/images/Inicio2.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        if (esPantallaAncha) const SizedBox(width: 40) else const SizedBox(height: 16),
                        
                        Flexible(
                          flex: 2,
                          child: SingleChildScrollView(
                            child: const Text(
                              'A continuación, iniciaremos un proceso de revisión y reflexión pedagógica obligatoria sobre la propuesta didáctica que acabas de observar.\n\nAnalizaremos de manera honesta el protagonismo del estudiante, el impacto de las estrategias de mediación docente y el respeto integral hacia los derechos de la infancia.',
                              style: TextStyle(fontSize: 16, color: AppColors.textSecondaryLight, height: 1.5, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Botón Fijo Abajo
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () => context.go('/encuesta/d1', extra: widget.cedulaDocente),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surfaceLight,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('Iniciar Cuestionario', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}