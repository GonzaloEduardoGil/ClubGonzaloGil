import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/sede.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';

import '../models/slot.dart';

import '../models/reserva.dart';

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
static Future<UserProfile> obtenerMiPerfil() async {
  final token = await FirebaseAuth.instance.currentUser?.getIdToken();

  if (token == null) {
    throw Exception('No hay un usuario autenticado.');
  }

  final response = await http.get(
    Uri.parse('$_baseUrl/users/me'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('No se pudo cargar el perfil.');
  }

  final datos = jsonDecode(response.body) as Map<String, dynamic>;

  return UserProfile.fromJson(datos);
}
static Future<List<Slot>> obtenerDisponibilidad({
  required int canchaId,
  required DateTime fecha,
}) async {
  final uri = Uri.parse(
    '$_baseUrl/canchas/$canchaId/disponibilidad',
  ).replace(
    queryParameters: {
      'fecha': _fechaParaApi(fecha),
    },
  );

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw Exception('No se pudo consultar la disponibilidad.');
  }

  final datos = jsonDecode(response.body) as List<dynamic>;

  return datos
      .map((dato) => Slot.fromJson(dato as Map<String, dynamic>))
      .toList();
}

static Future<void> crearReserva({
  required int canchaId,
  required DateTime fecha,
  required String horaInicio,
  required String horaFin,
}) async {
  final token = await FirebaseAuth.instance.currentUser?.getIdToken();

  if (token == null) {
    throw Exception('No hay un usuario autenticado.');
  }

  final response = await http.post(
    Uri.parse('$_baseUrl/reservas'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'cancha_id': canchaId,
      'fecha': _fechaParaApi(fecha),
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
    }),
  );

  if (response.statusCode == 201) {
    return;
  }

  String mensaje = 'No se pudo crear la reserva.';

  try {
    final datos = jsonDecode(response.body) as Map<String, dynamic>;
    mensaje = datos['detail'] as String? ?? mensaje;
  } catch (_) {
    // Conserva el mensaje general si la respuesta no contiene JSON válido.
  }

  throw Exception(mensaje);
}

static String _fechaParaApi(DateTime fecha) {
  final mes = fecha.month.toString().padLeft(2, '0');
  final dia = fecha.day.toString().padLeft(2, '0');

  return '${fecha.year}-$mes-$dia';
}
static Future<List<Reserva>> obtenerReservas() async {
  final token = await FirebaseAuth.instance.currentUser?.getIdToken();

  if (token == null) {
    throw Exception('No hay un usuario autenticado.');
  }

  final response = await http.get(
    Uri.parse('$_baseUrl/reservas'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('No se pudieron cargar las reservas.');
  }

  final datos = jsonDecode(response.body) as List<dynamic>;

  return datos
      .map((dato) => Reserva.fromJson(dato as Map<String, dynamic>))
      .toList();
}

static Future<void> cancelarReserva(int reservaId) async {
  final token = await FirebaseAuth.instance.currentUser?.getIdToken();

  if (token == null) {
    throw Exception('No hay un usuario autenticado.');
  }

  final response = await http.patch(
    Uri.parse('$_baseUrl/reservas/$reservaId/cancelar'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return;
  }

  String mensaje = 'No se pudo cancelar la reserva.';

  try {
    final datos = jsonDecode(response.body) as Map<String, dynamic>;
    mensaje = datos['detail'] as String? ?? mensaje;
  } catch (_) {
    // Conserva el mensaje general si el backend no devolvió JSON.
  }

  throw Exception(mensaje);
}
}