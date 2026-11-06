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

  String get horario => '$horaApertura a $horaCierre';
}
