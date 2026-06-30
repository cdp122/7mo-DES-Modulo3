import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:confetti/confetti.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/audio_service.dart';

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

      // 3. Empaquetamos las variables
      final Map<String, dynamic> variables = {
        'input': {
          'datos_docente': {
            'cedula': cedula,
            'nombre': 'Docente' // El nombre por defecto si no lo tenemos
          },
          'respuestas': respuestasList
        }
      };

      // 4. Enviamos al servidor Backend
      final dio = Dio();
      final response = await dio.post(
        'http://localhost:4000/graphql',
        data: {
          'query': mutation,
          'variables': variables,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.data != null && response.data['errors'] != null) {
        throw Exception(response.data['errors'][0]['message']);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 600),
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

  String _obtenerBaremoText() {
    if(igpp <= 25) return "🛑 Muy Adultocéntrica";
    if(igpp <= 50) return "⚠️ Participación Básica";
    if(igpp <= 75) return "🚀 Va por buen camino";
    return "🌟 Participación Auténtica";
  }

  Widget _buildExito() {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Diagnóstico Final del Documento', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
                const Text('Resumen automático de tu evaluación', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 14)),
                
                const SizedBox(height: 25),
                
                Text('${igpp.round()}%', style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight, height: 1.0)),
                const Text('PUNTAJE GLOBAL DE PARTICIPACIÓN', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, fontWeight: FontWeight.bold)),
                
                const SizedBox(height: 15),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1BDFF),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [BoxShadow(color: const Color(0xFFF1BDFF).withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))]
                  ),
                  child: Text(_obtenerBaremoText(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimaryLight)),
                ),
                
                const SizedBox(height: 40),
                
                Container(
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFF4F6F7), width: 2))
                  ),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: const Text('Tus resultados por cada área:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
                ),
                
                const SizedBox(height: 10),
                
                _buildDimRow('1. Participación Infantil', id1),
                _buildDimRow('2. Voz del Niño', id2),
                _buildDimRow('3. Relación Guiada', id3),
                
                _buildDiagnosticCard(),
                
                _buildCommentSection(
                  emoji: '📝',
                  title: 'Mi compromiso personal de mejora',
                  description: 'Escribe aquí qué cambios harás en tu próxima planificación escrita basándote en estos resultados.',
                  placeholder: 'Ejemplo: A partir de hoy intentaré dejar más espacios libres para que los niños decidan cómo jugar...',
                ),

                _buildCommentSection(
                  emoji: '💬',
                  title: '¿Qué opino acerca del programa en general?',
                  description: 'Comparte tu opinión sobre la herramienta de evaluación, sugerencias de mejora o comentarios generales. Tu feedback nos ayuda a mejorar.',
                  placeholder: 'Ejemplo: El programa es muy intuitivo, pero me gustaría que... o Muy útil para reflexionar sobre mi planificación...',
                ),
                
                const SizedBox(height: 40),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.refresh, color: Color(0xFF5D6D7E)),
                    label: const Text('Empezar una nueva evaluación'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEAECEE),
                      foregroundColor: const Color(0xFF5D6D7E),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
                    ),
                  ),
                ),
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
            numberOfParticles: 20,
            maxBlastForce: 100,
            minBlastForce: 80,
            gravity: 0.1,
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
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 35),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF9DBCFF), width: 2, style: BorderStyle.solid), // Flutter doesn't have dashed border by default without a package, using solid for now or dotted
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, color: Color(0xFF7A9FE6), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Color(0xFF5D6D7E), height: 1.4),
          ),
          const SizedBox(height: 15),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(15),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD5D8DC)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF7A9FE6)),
              ),
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC0FFD0),
              foregroundColor: const Color(0xFF229954),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 4,
              shadowColor: const Color(0xFFC0FFD0).withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Guardar comentario', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDimRow(String title, double score) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7E9)))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, color: AppColors.textPrimaryLight)),
          Text('${score.round()}%', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
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
                                       "Área 3 (Relación Guiada)";

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
      margin: const EdgeInsets.only(top: 25),
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 6)),
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