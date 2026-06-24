import 'package:flutter/material.dart';
import '../../domain/entities/usuario.dart';

class AvisoRolDialog extends StatelessWidget {
  final Usuario usuario;
  final VoidCallback onResponderEncuesta;
  final VoidCallback onPanelAdministracion;

  const AvisoRolDialog({
    super.key,
    required this.usuario,
    required this.onResponderEncuesta,
    required this.onPanelAdministracion,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.admin_panel_settings_rounded,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Rol Detectado: Admin',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hola, ${usuario.nombre ?? 'Administrador'}.',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tu cuenta cuenta con privilegios de administrador. ¿Qué deseas hacer a continuación?',
            style: TextStyle(height: 1.4),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      actions: [
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            onResponderEncuesta();
          },
          icon: const Icon(Icons.quiz_outlined),
          label: const Text('Responder Encuesta'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            onPanelAdministracion();
          },
          icon: const Icon(Icons.dashboard_rounded),
          label: const Text('Panel Admin'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
