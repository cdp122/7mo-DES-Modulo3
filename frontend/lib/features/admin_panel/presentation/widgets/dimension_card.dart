import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/dimension.dart';

class DimensionCard extends StatelessWidget {
  final DimensionEntity dimension;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DimensionCard({
    super.key,
    required this.dimension,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  Color _getColorByOrden(int orden) {
    switch (orden) {
      case 1:
        return const Color(0xFF4E9A6B); // Sage
      case 2:
        return const Color(0xFF2C86A0); // Teal
      case 3:
        return const Color(0xFFDFA235); // Amber
      default:
        return const Color(0xFF16305B); // Navy
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = _getColorByOrden(dimension.orden);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.2),
              width: 2,
            ),
            color: isDark
                ? const Color(0xFF1A1A1A)
                : Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Badge y número
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'D${dimension.orden}',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Nombre
                Text(
                  dimension.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),

                // Descripción breve
                Text(
                  dimension.descripcion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    height: 1.25,
                    color: isDark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),

                // Footer con cantidad de reactivos y acciones
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.quiz_outlined,
                              size: 14,
                              color: accentColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${dimension.reactivos.length} reactivos',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (onEdit != null)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        splashRadius: 20,
                        icon: Icon(Icons.edit, color: accentColor, size: 18),
                        onPressed: onEdit,
                        tooltip: 'Editar dimensión',
                      ),
                    if (onDelete != null)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        splashRadius: 20,
                        icon: Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                        onPressed: onDelete,
                        tooltip: 'Eliminar dimensión',
                      ),
                  ],
                ),

                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: accentColor.withValues(alpha: 0.5),
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
