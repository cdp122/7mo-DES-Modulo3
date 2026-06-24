class ReactivoEntity {
  final String codigo;
  final String enunciado;
  final String? pista;

  const ReactivoEntity({
    required this.codigo,
    required this.enunciado,
    this.pista,
  });

  ReactivoEntity copyWith({
    String? codigo,
    String? enunciado,
    String? pista,
  }) {
    return ReactivoEntity(
      codigo: codigo ?? this.codigo,
      enunciado: enunciado ?? this.enunciado,
      pista: pista ?? this.pista,
    );
  }

  factory ReactivoEntity.fromJson(Map<String, dynamic> json) {
    return ReactivoEntity(
      codigo: json['reactivo_codigo'] as String,
      enunciado: json['enunciado'] as String,
      pista: json['pista'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reactivo_codigo': codigo,
      'enunciado': enunciado,
      if (pista != null) 'pista': pista,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReactivoEntity &&
          runtimeType == other.runtimeType &&
          codigo == other.codigo &&
          enunciado == other.enunciado &&
          pista == other.pista;

  @override
  int get hashCode => codigo.hashCode ^ enunciado.hashCode ^ pista.hashCode;
}
