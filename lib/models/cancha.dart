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
}
