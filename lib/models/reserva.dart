class Reserva {
  const Reserva({
    required this.id,
    required this.sede,
    required this.cancha,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.estado,
  });

  final int id;
  final String sede;
  final String cancha;
  final String fecha;
  final String horaInicio;
  final String horaFin;
  final String estado;

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'] as int,
      sede: json['sede'] as String,
      cancha: json['cancha'] as String,
      fecha: json['fecha'] as String,
      horaInicio: json['hora_inicio'] as String,
      horaFin: json['hora_fin'] as String,
      estado: json['estado'] as String,
    );
  }
  String get canchaMostrada {
    return cancha
        .replaceAll('_', ' ')
        .split(' ')
        .map((parte) {
          if (parte.isEmpty) return parte;
          return '${parte[0].toUpperCase()}${parte.substring(1)}';
        })
        .join(' ');
  }

  String get fechaFormateada {
    final partes = fecha.split('-');

    if (partes.length != 3) return fecha;

    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  String get horario {
    return '${horaInicio.substring(0, 5)} - ${horaFin.substring(0, 5)}';
  }

  bool get esProxima {
    if (estado != 'confirmada') return false;

    final finalizaEn = DateTime.parse('$fecha $horaFin');

    return finalizaEn.isAfter(DateTime.now());
  }
}
