import 'cancha.dart';

class Sede {
  const Sede({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.horaApertura,
    required this.horaCierre,
    required this.deportes,
    this.canchas = const [],
  });

  final int id;
  final String nombre;
  final String direccion;
  final String horaApertura;
  final String horaCierre;
  final List<String> deportes;
  final List<Cancha> canchas;

  factory Sede.fromJson(Map<String, dynamic> json) {
    final canchasJson = json['canchas'] as List<dynamic>? ?? [];

    return Sede(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String,
      horaApertura: json['hora_apertura'] as String,
      horaCierre: json['hora_cierre'] as String,
      deportes: (json['deportes'] as List<dynamic>)
          .map((deporte) => deporte as String)
          .toList(),
      canchas: canchasJson
          .map((cancha) => Cancha.fromJson(cancha as Map<String, dynamic>))
          .toList(),
    );
  }

  String get horario {
    return '${horaApertura.substring(0, 5)} a '
        '${horaCierre.substring(0, 5)}';
  }
}