import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
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

  @override
  void initState() {
    super.initState();
    AudioService().stopMusic(); // Detiene el audio
    _guardarEnBaseDeDatos();
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
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Resultados de la Encuesta'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
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
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: AppColors.primary),
        SizedBox(height: 24),
        Text(
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
          onPressed: _guardarEnBaseDeDatos, // Reintentar
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
        ),
      ],
    );
  }

  Widget _buildExito() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_outline, size: 100, color: Color(0xFF10B981)),
        const SizedBox(height: 24),
        Text('¡Encuesta Guardada con Éxito!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Tus respuestas han sido procesadas y enviadas al sistema.\nGracias por tu participación.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: AppColors.textSecondaryLight),
        ),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.home),
          label: const Text('Volver al Inicio'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)
          ),
        ),
      ],
    );
  }
}