class Usuario {
  final String id;
  final String cedula;
  final String rol; // 'admin' or 'regular'
  final String? nombre;

  const Usuario({
    required this.id,
    required this.cedula,
    required this.rol,
    this.nombre,
  });

  bool get isAdmin => rol == 'admin';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Usuario &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          cedula == other.cedula &&
          rol == other.rol &&
          nombre == other.nombre;

  @override
  int get hashCode => id.hashCode ^ cedula.hashCode ^ rol.hashCode ^ nombre.hashCode;
}
