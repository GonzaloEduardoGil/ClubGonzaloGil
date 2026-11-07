import 'cancha.dart';
import 'sede.dart';

class CanchaConSede {
  const CanchaConSede({required this.cancha, required this.sede});

  final Cancha cancha;
  final Sede sede;

  factory CanchaConSede.fromJson(Map<String, dynamic> json) {
    final deporte = json['deporte'] as String;

    return CanchaConSede(
      cancha: Cancha(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        deporte: deporte,
        tipo: json['tipo'] as String?,
        precioPorHora: (json['precio_por_hora'] as num).round(),
        caracteristicas: const [],
      ),
      sede: Sede(
        id: json['sede_id'] as int,
        nombre: json['sede_nombre'] as String,
        direccion: json['sede_direccion'] as String,
        horaApertura: json['hora_apertura'] as String,
        horaCierre: json['hora_cierre'] as String,
        deportes: [deporte],
      ),
    );
  }
}
