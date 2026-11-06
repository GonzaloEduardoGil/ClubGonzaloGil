class Sede {
  const Sede({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.horaApertura,
    required this.horaCierre,
    required this.deportes,
  });

  final int id;
  final String nombre;
  final String direccion;
  final String horaApertura;
  final String horaCierre;
  final List<String> deportes;

  factory Sede.fromJson(Map<String, dynamic> json) {
    return Sede(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String,
      horaApertura: json['hora_apertura'] as String,
      horaCierre: json['hora_cierre'] as String,
      deportes: (json['deportes'] as List<dynamic>)
          .map((deporte) => deporte as String)
          .toList(),
    );
  }

  String get horario {
    // PostgreSQL devuelve, por ejemplo, 08:00:00.
    // Para la app mostramos solo 08:00.
    return '${horaApertura.substring(0, 5)} a '
        '${horaCierre.substring(0, 5)}';
  }
}