class UserProfile {
  const UserProfile({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.dni,
  });

  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final String dni;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      email: json['email'] as String,
      dni: json['dni'] as String,
    );
  }
}