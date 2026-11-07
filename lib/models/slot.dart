class Slot {
  const Slot({required this.hora, required this.disponible});

  final String hora;
  final bool disponible;

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      hora: json['hora'] as String,
      disponible: json['disponible'] as bool,
    );
  }
}
