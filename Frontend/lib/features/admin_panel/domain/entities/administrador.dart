class AdministradorEntity {
  final String id;
  final String cedula;
  final String nombre;
  final String email;
  final String rol;

  const AdministradorEntity({
    required this.id,
    required this.cedula,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  bool get esAdmin => rol == 'admin';

  AdministradorEntity copyWith({
    String? id,
    String? cedula,
    String? nombre,
    String? email,
    String? rol,
  }) {
    return AdministradorEntity(
      id: id ?? this.id,
      cedula: cedula ?? this.cedula,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      rol: rol ?? this.rol,
    );
  }

  factory AdministradorEntity.fromJson(Map<String, dynamic> json) {
    return AdministradorEntity(
      id: json['id'] as String,
      cedula: json['cedula'] as String,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      rol: json['rol'] as String? ?? 'admin',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdministradorEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          cedula == other.cedula &&
          nombre == other.nombre &&
          email == other.email &&
          rol == other.rol;

  @override
  int get hashCode =>
      id.hashCode ^ cedula.hashCode ^ nombre.hashCode ^ email.hashCode ^ rol.hashCode;
}
