import '../../domain/entities/usuario.dart';

class UsuarioModel extends Usuario {
  const UsuarioModel({
    required super.id,
    required super.cedula,
    required super.rol,
    super.nombre,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] as String,
      cedula: json['cedula'] as String,
      rol: json['rol'] as String,
      nombre: json['nombre'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cedula': cedula,
      'rol': rol,
      'nombre': nombre,
    };
  }
}
