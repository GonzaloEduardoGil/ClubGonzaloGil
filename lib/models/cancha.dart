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

  String get nombreMostrado {
    final coincidencia = RegExp(r'(\d+)\s*$').firstMatch(nombre);
    final numero = coincidencia?.group(1);

    if (numero == null) {
      return 'Cancha de $deporte';
    }

    return 'Cancha de $deporte $numero';
  }

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
