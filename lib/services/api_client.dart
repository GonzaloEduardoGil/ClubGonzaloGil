import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/sede.dart';

import 'package:firebase_auth/firebase_auth.dart';

class ApiClient {
  static Future<void> crearPerfil({
  required String nombre,
  required String apellido,
  required String email,
  required String fechaNacimiento,
  required String dni,
}) async {
  final token = await FirebaseAuth.instance.currentUser?.getIdToken();

  if (token == null) {
    throw Exception('No hay un usuario autenticado.');
  }

  final partesFecha = fechaNacimiento.split('/');

  if (partesFecha.length != 3) {
    throw Exception('La fecha de nacimiento no es válida.');
  }

  final fechaParaApi =
      '${partesFecha[2]}-${partesFecha[1]}-${partesFecha[0]}';

  final response = await http.post(
    Uri.parse('$_baseUrl/users/me'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'fecha_nacimiento': fechaParaApi,
      'dni': dni,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('No se pudo guardar el perfil del usuario.');
  }
}
  ApiClient._();

  // 10.0.2.2 significa "la computadora anfitriona" para Android Emulator.
  static const _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static Future<List<Sede>> obtenerSedes() async {
    final response = await http.get(Uri.parse('$_baseUrl/sedes'));

    if (response.statusCode != 200) {
      throw Exception('No se pudieron obtener las sedes.');
    }

    final datos = jsonDecode(response.body) as List<dynamic>;

    return datos
        .map((dato) => Sede.fromJson(dato as Map<String, dynamic>))
        .toList();
  }
  static Future<Sede> obtenerSede(int sedeId) async {
  final response = await http.get(
    Uri.parse('$_baseUrl/sedes/$sedeId'),
  );

  if (response.statusCode != 200) {
    throw Exception('No se pudo obtener la sede.');
  }

  final datos = jsonDecode(response.body) as Map<String, dynamic>;

  return Sede.fromJson(datos);
}
}