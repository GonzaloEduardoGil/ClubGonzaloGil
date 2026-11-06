class Cancha {
  const Cancha({
    required this.id,
    required this.nombre,
    required this.deporte,
    this.tipo,
    required this.precioPorHora,
    required this.caracteristicas,
  });

  final int id;
  final String nombre;
  final String deporte;
  final String? tipo;
  final int precioPorHora;
  final List<String> caracteristicas;

  factory Cancha.fromJson(Map<String, dynamic> json) {
    return Cancha(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      deporte: json['deporte'] as String,
      tipo: json['tipo'] as String?,
      precioPorHora: (json['precio_por_hora'] as num).round(),
      // Esta columna la agregaremos más adelante a la base.
      caracteristicas: const [],
    );
  }
}