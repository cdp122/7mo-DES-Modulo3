// lib/features/encuesta/presentation/widgets/likert_button_widget.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class LikertOptionsGroup extends StatelessWidget {
  final Function(int) onSelected;
  final int? valorSeleccionado;

  const LikertOptionsGroup({
    super.key,
    required this.onSelected,
    this.valorSeleccionado,
  });

  @override
  Widget build(BuildContext context) {
    final opciones = [
      {'valor': 0, 'texto': 'Ausente', 'icono': Icons.close_rounded, 'color': AppColors.error},
      {'valor': 1, 'texto': 'Incipiente', 'icono': Icons.trending_up_rounded, 'color': AppColors.secondary},
      {'valor': 2, 'texto': 'En desarrollo', 'icono': Icons.loop_rounded, 'color': AppColors.amber},
      {'valor': 3, 'texto': 'Logrado', 'icono': Icons.check_circle_outline_rounded, 'color': AppColors.info},
      {'valor': 4, 'texto': 'Consolidado', 'icono': Icons.star_rounded, 'color': AppColors.sage},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // DETECCIÓN DE PANTALLA: Si es menor a 600px cambiamos a lista vertical
        final bool esMovil = constraints.maxWidth < 600;

        if (esMovil) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: opciones.map((opcion) {
              final color = opcion['color'] as Color;
              final int valorActual = opcion['valor'] as int;
              final bool estaSeleccionado = valorSeleccionado == valorActual;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Material(
                  color: estaSeleccionado ? color.withOpacity(0.08) : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => onSelected(valorActual),
                    borderRadius: BorderRadius.circular(12),
                    splashColor: color.withOpacity(0.15),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: estaSeleccionado ? color : AppColors.borderLight, 
                          width: estaSeleccionado ? 2.0 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(opcion['icono'] as IconData, size: 26, color: color),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              opcion['texto'] as String,
                              style: TextStyle(
                                fontSize: 15, // Más grande y legible en celular
                                fontWeight: estaSeleccionado ? FontWeight.bold : FontWeight.w600,
                                color: AppColors.textPrimaryLight.withOpacity(estaSeleccionado ? 1.0 : 0.8),
                              ),
                            ),
                          ),
                          if (estaSeleccionado)
                            Icon(Icons.check_circle, color: color, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }

        // VISTA WEB / TABLET: Mantiene exactamente el diseño horizontal original
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: opciones.map((opcion) {
            final color = opcion['color'] as Color;
            final int valorActual = opcion['valor'] as int;
            final bool estaSeleccionado = valorSeleccionado == valorActual;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Material(
                  color: estaSeleccionado ? color.withOpacity(0.08) : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => onSelected(valorActual),
                    borderRadius: BorderRadius.circular(12),
                    splashColor: color.withOpacity(0.15),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: estaSeleccionado ? color : AppColors.borderLight, 
                          width: estaSeleccionado ? 2.0 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(opcion['icono'] as IconData, size: 24, color: color),
                          const SizedBox(height: 6),
                          Text(
                            opcion['texto'] as String,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: estaSeleccionado ? FontWeight.bold : FontWeight.w600,
                              color: AppColors.textPrimaryLight.withOpacity(estaSeleccionado ? 1.0 : 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}