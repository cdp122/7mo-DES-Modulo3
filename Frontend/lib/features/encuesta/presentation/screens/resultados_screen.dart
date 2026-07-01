import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:confetti/confetti.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/audio_service.dart';
import '../../../../core/network/graphql_service.dart';
import '../../../../injection.dart';

class ResultadosScreen extends StatefulWidget {
  final Map<String, dynamic> resultadoscompletos;

  const ResultadosScreen({
    super.key,
    required this.resultadoscompletos,
  });

  @override
  State<ResultadosScreen> createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  bool _estaGuardando = true;
  String? _error;
  String? _evaluacionId;
  final TextEditingController _compromisoCtrl = TextEditingController();
  final TextEditingController _opinionesCtrl = TextEditingController();
  
  late ConfettiController _confettiController;
  
  double id1 = 0, id2 = 0, id3 = 0, igpp = 0;
  int sum1 = 0, sum2 = 0, sum3 = 0, sumTotal = 0;

  @override
  void initState() {
    super.initState();
    AudioService().stopMusic(); // Detiene el audio
    
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    
    _calcularResultados();
    _guardarEnBaseDeDatos();
  }
  
  @override
  void dispose() {
    _confettiController.dispose();
    _compromisoCtrl.dispose();
    _opinionesCtrl.dispose();
    super.dispose();
  }

  void _calcularResultados() {
    final mapRespuestas = widget.resultadoscompletos['respuestas'] as Map<String, int>;
    mapRespuestas.forEach((key, value) {
      if (key.startsWith('1.')) {
        sum1 += value;
      } else if (key.startsWith('2.')) {
        sum2 += value;
      } else if (key.startsWith('3.')) {
        sum3 += value;
      }
      sumTotal += value;
    });
    
    id1 = (sum1 / 20) * 100;
    id2 = (sum2 / 20) * 100;
    id3 = (sum3 / 20) * 100;
    igpp = (sumTotal / 60) * 100;
  }

  Future<void> _guardarEnBaseDeDatos() async {
    try {
      final cedula = widget.resultadoscompletos['cedula'] as String;
      final mapRespuestas = widget.resultadoscompletos['respuestas'] as Map<String, int>;

      // 1. Formateamos las respuestas como lo pide GraphQL
      final respuestasList = mapRespuestas.entries.map((e) => {
        'reactivo_codigo': e.key,
        'valor': e.value
      }).toList();

      // 2. Definimos la Mutación
      const String mutation = r'''
        mutation CrearEvaluacion($input: CrearEvaluacionInput!) {
          crearEvaluacion(input: $input) {
            id
            resultados {
              IGPP
              dimension_prioritaria
            }
          }
        }
      ''';

      // 3. Empaquetamos las variables de acuerdo al esquema V6.6.30
      final Map<String, dynamic> variables = {
        'input': {
          'cedula_docente': cedula,
          'respuestas': respuestasList
        }
      };

      // 4. Enviamos al servidor Backend usando el servicio global
      final graphqlService = sl<GraphQLService>();
      final data = await graphqlService.execute(
        mutation,
        variables: variables,
      );

      if (data['crearEvaluacion'] != null) {
        _evaluacionId = data['crearEvaluacion']['id'] as String?;
      }

      setState(() {
        _estaGuardando = false;
      });
      
      // Lanzar confeti al mostrar los resultados
      _confettiController.play();

    } catch (e) {
      setState(() {
        _estaGuardando = false;
        _error = e.toString();
      });
      debugPrint('Error al guardar evaluación: $e');
    }
  }

  Future<void> _guardarComentario() async {
    if (_evaluacionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay una evaluación activa para guardar comentarios.')),
      );
      return;
    }

    const String mutation = r'''
      mutation AgregarComentarios($evaluacionId: ID!, $input: ComentariosInput!) {
        agregarComentarios(evaluacionId: $evaluacionId, input: $input) {
          id
        }
      }
    ''';

    final Map<String, dynamic> variables = {
      'evaluacionId': _evaluacionId,
      'input': {
        'compromiso_personal': _compromisoCtrl.text.trim().isNotEmpty ? _compromisoCtrl.text.trim() : null,
        'opiniones_programa': _opinionesCtrl.text.trim().isNotEmpty ? _opinionesCtrl.text.trim() : null,
      }
    };

    try {
      final graphqlService = sl<GraphQLService>();
      await graphqlService.execute(
        mutation,
        variables: variables,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comentarios guardados exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar comentarios: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool esPantallaAncha = MediaQuery.of(context).size.width > 950;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: esPantallaAncha ? 1100 : 600),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: _estaGuardando 
            ? _buildCargando() 
            : _error != null 
                ? _buildError() 
                : _buildExito(),
        ),
      ),
    );
  }

  Widget _buildCargando() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: AppColors.primary),
        const SizedBox(height: 24),
        const Text(
          'Guardando respuestas en la base de datos...\nPor favor, espera.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: AppColors.textSecondaryLight),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 90, color: AppColors.error),
        const SizedBox(height: 24),
        const Text(
          'Ocurrió un error al guardar',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.error),
        ),
        const SizedBox(height: 16),
        Text(
          _error ?? 'Error desconocido',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondaryLight),
        ),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _estaGuardando = true;
              _error = null;
            });
            _guardarEnBaseDeDatos();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
        ),
      ],
    );
  }

  Color _getBaremoColor() {
    if (igpp <= 25) return AppColors.error;
    if (igpp <= 50) return AppColors.secondary;
    if (igpp <= 75) return AppColors.amber;
    return AppColors.success;
  }

  String _obtenerBaremoText() {
    if (igpp <= 25) return "🛑 Planificación adultocéntrica";
    if (igpp <= 50) return "⚠️ Participación incipiente";
    if (igpp <= 75) return "🚀 Participación en desarrollo";
    return "🌟 Participación auténtica";
  }

  Widget _buildScoreCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.borderLight, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          children: [
            Text(
              '${igpp.round()}%',
              style: const TextStyle(
                fontSize: 76,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'PUNTAJE GLOBAL DE PARTICIPACIÓN',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondaryLight,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _getBaremoColor().withOpacity(0.12),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: _getBaremoColor().withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Text(
                _obtenerBaremoText(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: _getBaremoColor(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionsCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.borderLight, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resultados por Dimensión:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            _buildDimRow('1. Participación Infantil', id1, const Color(0xFF3F51B5)),
            _buildDimRow('2. Voz del Niño', id2, const Color(0xFF009688)),
            _buildDimRow('3. Relación Simétrica', id3, const Color(0xFFFF9800)),
          ],
        ),
      ),
    );
  }

  Widget _buildRestartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.go('/'),
        icon: const Icon(Icons.keyboard_return_rounded),
        label: const Text('Empezar una nueva evaluación', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildExito() {
    final bool esPantallaAncha = MediaQuery.of(context).size.width > 950;

    Widget mainContent;
    if (esPantallaAncha) {
      mainContent = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna Izquierda: Score, Recomendaciones y Botón
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildScoreCard(),
                const SizedBox(height: 8),
                _buildDiagnosticCard(),
                const SizedBox(height: 24),
                _buildRestartButton(),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Columna Derecha: Detalles por Dimensión y Comentarios
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDimensionsCard(),
                _buildCommentSection(
                  emoji: '📝',
                  title: 'Mi compromiso personal de mejora',
                  description: 'Escribe aquí qué cambios harás en tu próxima planificación escrita basándote en estos resultados.',
                  placeholder: 'Ejemplo: A partir de hoy intentaré dejar más espacios libres para que los niños decidan cómo jugar...',
                  controller: _compromisoCtrl,
                  onGuardar: () => _guardarComentario(),
                ),
                _buildCommentSection(
                  emoji: '💬',
                  title: '¿Qué opino acerca del programa en general?',
                  description: 'Comparte tu opinión sobre la herramienta de evaluación, sugerencias de mejora o comentarios generales. Tu feedback nos ayuda a mejorar.',
                  placeholder: 'Ejemplo: El programa es muy intuitivo, pero me gustaría que... o Muy útil para reflexionar sobre mi planificación...',
                  controller: _opinionesCtrl,
                  onGuardar: () => _guardarComentario(),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Mobile Single Column Layout
      mainContent = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildScoreCard(),
          const SizedBox(height: 24),
          _buildDimensionsCard(),
          _buildDiagnosticCard(),
          _buildCommentSection(
            emoji: '📝',
            title: 'Mi compromiso personal de mejora',
            description: 'Escribe aquí qué cambios harás en tu próxima planificación escrita basándote en estos resultados.',
            placeholder: 'Ejemplo: A partir de hoy intentaré dejar más espacios libres para que los niños decidan cómo jugar...',
            controller: _compromisoCtrl,
            onGuardar: () => _guardarComentario(),
          ),
          _buildCommentSection(
            emoji: '💬',
            title: '¿Qué opino acerca del programa en general?',
            description: 'Comparte tu opinión sobre la herramienta de evaluación, sugerencias de mejora o comentarios generales. Tu feedback nos ayuda a mejorar.',
            placeholder: 'Ejemplo: El programa es muy intuitivo, pero me gustaría que... o Muy útil para reflexionar sobre mi planificación...',
            controller: _opinionesCtrl,
            onGuardar: () => _guardarComentario(),
          ),
          const SizedBox(height: 35),
          _buildRestartButton(),
        ],
      );
    }

    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40.0, top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header Titles
                const Text(
                  'Diagnóstico de Planificación',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Análisis automático de participación infantil',
                  style: TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 25),
                mainContent,
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: 0.05,
            numberOfParticles: 25,
            maxBlastForce: 100,
            minBlastForce: 80,
            gravity: 0.15,
            colors: const [Colors.pink, Colors.red, Colors.orange, Colors.blue, Colors.green, Colors.purple],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentSection({
    required String emoji,
    required String title,
    required String description,
    required String placeholder,
    required TextEditingController controller,
    required VoidCallback onGuardar,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 25),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: controller,
            maxLines: 4,
            style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 15),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(color: Color(0xFF99A3A4), fontSize: 14),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              contentPadding: const EdgeInsets.all(15),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E8E8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryAccent),
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onGuardar,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Guardar comentario', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimRow(String title, double score, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
              Text(
                '${score.round()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: score / 100.0,
              minHeight: 10,
              backgroundColor: AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticCard() {
    double minID = id1;
    if (id2 < minID) minID = id2;
    if (id3 < minID) minID = id3;

    String dimCritica = minID == id1 ? "Área 1 (Participación Infantil)" : 
                        minID == id2 ? "Área 2 (Voz del Niño)" : 
                                       "Área 3 (Relación Simétrica)";

    Color bgColor;
    Color borderColor;
    Color textColor;
    String titulo;
    List<TextSpan> spans = [];

    if (igpp <= 25) {
      bgColor = const Color(0xFFFFF0F0);
      borderColor = const Color(0xFFFEA3A2);
      textColor = const Color(0xFFD84A49);
      titulo = "🛑 Alerta: Rediseño Urgente Requerido";
      spans = [
        const TextSpan(text: "El documento está pensado casi totalmente desde el punto de vista del adulto. Tu área más baja es la "),
        TextSpan(text: dimCritica, style: const TextStyle(fontWeight: FontWeight.bold)),
        const TextSpan(text: " con un "),
        TextSpan(text: "${minID.round()}%", style: const TextStyle(fontWeight: FontWeight.bold)),
        const TextSpan(text: ". ¡No te preocupes! Toma nota para empezar a incluir más a los niños en tus próximas actividades."),
      ];
    } else if (igpp > 25 && igpp <= 75) {
      bgColor = const Color(0xFFFFF9ED);
      borderColor = const Color(0xFFFFDD9E);
      textColor = const Color(0xFFD68A00);
      titulo = "⚠️ Oportunidad de Mejora";
      spans = [
        const TextSpan(text: "Vas por muy buen camino, pero hay detalles que mejorar. El área en la que debes enfocarte más es la "),
        TextSpan(text: dimCritica, style: const TextStyle(fontWeight: FontWeight.bold)),
        const TextSpan(text: " con un "),
        TextSpan(text: "${minID.round()}%", style: const TextStyle(fontWeight: FontWeight.bold)),
        const TextSpan(text: ". Piensa en pequeños cambios que puedes hacer la próxima semana."),
      ];
    } else {
      bgColor = const Color(0xFFF0FFF4);
      borderColor = const Color(0xFFC0FFD0);
      textColor = const Color(0xFF229954);
      titulo = "🌟 ¡Excelente Trabajo!";
      spans = [
        const TextSpan(text: "Tu planificación es fantástica y toma muy en serio los derechos y opiniones de los niños. Para ser perfecta, podrías darle un último toque a la "),
        TextSpan(text: dimCritica, style: const TextStyle(fontWeight: FontWeight.bold)),
        const TextSpan(text: " (que obtuvo "),
        TextSpan(text: "${minID.round()}%", style: const TextStyle(fontWeight: FontWeight.bold)),
        const TextSpan(text: "). ¡Sigue así!"),
      ];
    }

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: borderColor, width: 6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 15, color: Color(0xFF566573), height: 1.5),
              children: spans,
            ),
          )
        ],
      ),
    );
  }
}