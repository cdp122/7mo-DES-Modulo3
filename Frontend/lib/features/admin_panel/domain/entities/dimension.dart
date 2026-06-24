import 'reactivo.dart';

class DimensionEntity {
  final String id;
  final int orden;
  final String nombre;
  final String descripcion;
  final String fundamento;
  final List<ReactivoEntity> reactivos;

  const DimensionEntity({
    required this.id,
    required this.orden,
    required this.nombre,
    required this.descripcion,
    required this.fundamento,
    required this.reactivos,
  });

  DimensionEntity copyWith({
    String? id,
    int? orden,
    String? nombre,
    String? descripcion,
    String? fundamento,
    List<ReactivoEntity>? reactivos,
  }) {
    return DimensionEntity(
      id: id ?? this.id,
      orden: orden ?? this.orden,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      fundamento: fundamento ?? this.fundamento,
      reactivos: reactivos ?? this.reactivos,
    );
  }

  factory DimensionEntity.fromJson(Map<String, dynamic> json) {
    return DimensionEntity(
      id: json['id'] as String,
      orden: json['orden'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      fundamento: json['fundamento'] as String,
      reactivos: (json['reactivos'] as List<dynamic>?)
              ?.map((r) => ReactivoEntity.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DimensionEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          orden == other.orden &&
          nombre == other.nombre &&
          descripcion == other.descripcion &&
          fundamento == other.fundamento &&
          reactivos == other.reactivos;

  @override
  int get hashCode =>
      id.hashCode ^
      orden.hashCode ^
      nombre.hashCode ^
      descripcion.hashCode ^
      fundamento.hashCode ^
      reactivos.hashCode;
}
