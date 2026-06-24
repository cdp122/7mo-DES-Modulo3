import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/dimension.dart';

class DimensionFormDialog extends StatefulWidget {
  final DimensionEntity? initialDimension;
  final String title;

  const DimensionFormDialog({
    super.key,
    this.initialDimension,
    required this.title,
  });

  @override
  State<DimensionFormDialog> createState() => _DimensionFormDialogState();
}

class _DimensionFormDialogState extends State<DimensionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ordenController;
  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _fundamentoController;

  @override
  void initState() {
    super.initState();
    _ordenController = TextEditingController(
      text: widget.initialDimension?.orden.toString() ?? '',
    );
    _nombreController = TextEditingController(
      text: widget.initialDimension?.nombre ?? '',
    );
    _descripcionController = TextEditingController(
      text: widget.initialDimension?.descripcion ?? '',
    );
    _fundamentoController = TextEditingController(
      text: widget.initialDimension?.fundamento ?? '',
    );
  }

  @override
  void dispose() {
    _ordenController.dispose();
    _nombreController.dispose();
    _descripcionController.dispose();
    _fundamentoController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final orden = int.tryParse(_ordenController.text.trim());
    if (orden == null || orden < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El orden debe ser un número positivo.')),
      );
      return;
    }

    final dimension = DimensionEntity(
      id: widget.initialDimension?.id ?? '',
      orden: orden,
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      fundamento: _fundamentoController.text.trim(),
      reactivos: widget.initialDimension?.reactivos ?? const [],
    );

    Navigator.of(context).pop(dimension);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialDimension != null;

    return AlertDialog(
      title: Text(widget.title, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _ordenController,
                enabled: !isEditing,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Orden (número positivo)',
                  helperText: isEditing ? 'El orden no se puede modificar al editar.' : null,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el orden de la dimensión.';
                  }
                  final orden = int.tryParse(value.trim());
                  if (orden == null || orden < 1) {
                    return 'El orden debe ser un número positivo.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la dimensión',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el nombre de la dimensión.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese la descripción.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fundamentoController,
                decoration: const InputDecoration(
                  labelText: 'Fundamento teórico',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el fundamento teórico.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
