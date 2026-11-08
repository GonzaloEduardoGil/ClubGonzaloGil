import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/sede.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';

import '../models/slot.dart';

import '../models/reserva.dart';

import '../models/cancha_con_sede.dart';

import 'dart:async';

import 'dart:io';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

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

    final response = await _ejecutar(
      http.post(
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
      ),
    );

    _verificarRespuesta(
      response,
      codigosCorrectos: [200],
      mensajePorDefecto: 'No se pudo crear tu perfil de usuario.',
    );
  }

  ApiClient._();

  // 10.0.2.2 significa "la computadora anfitriona" para Android Emulator.
  static const _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static Future<List<Sede>> obtenerSedes() async {
    final response = await _ejecutar(http.get(Uri.parse('$_baseUrl/sedes')));

    _verificarRespuesta(
      response,
      codigosCorrectos: [200],
      mensajePorDefecto: 'No se pudieron obtener las sedes.',
    );

    final datos = jsonDecode(response.body) as List<dynamic>;

    return datos
        .map((dato) => Sede.fromJson(dato as Map<String, dynamic>))
        .toList();
  }

  static Future<Sede> obtenerSede(int sedeId) async {
    final response = await _ejecutar(
      http.get(Uri.parse('$_baseUrl/sedes/$sedeId')),
    );

    _verificarRespuesta(
      response,
      codigosCorrectos: [200],
      mensajePorDefecto: 'No se pudieron obtener los detalles de la sede.',
    );

    final datos = jsonDecode(response.body) as Map<String, dynamic>;

    return Sede.fromJson(datos);
  }

  static Future<UserProfile> obtenerMiPerfil() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();

    if (token == null) {
      throw Exception('No hay un usuario autenticado.');
    }

    final response = await _ejecutar(
      http.get(
        Uri.parse('$_baseUrl/users/me'),
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    _verificarRespuesta(
      response,
      codigosCorrectos: [200],
      mensajePorDefecto: 'No se pudo obtener tu información de perfil.',
    );

    final datos = jsonDecode(response.body) as Map<String, dynamic>;

    return UserProfile.fromJson(datos);
  }

  static Future<List<Slot>> obtenerDisponibilidad({
    required int canchaId,
    required DateTime fecha,
  }) async {
    final uri = Uri.parse('$_baseUrl/canchas/$canchaId/disponibilidad')
        .replace(queryParameters: {'fecha': _fechaParaApi(fecha)});

    final response = await _ejecutar(http.get(uri));

    _verificarRespuesta(
      response,
      codigosCorrectos: [200],
      mensajePorDefecto: 'No se pudo obtener la disponibilidad de la cancha.',
    );

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
      throw const ApiException('No hay un usuario autenticado.');
    }

    final response = await _ejecutar(
      http.post(
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
      ),
    );

    _verificarRespuesta(
      response,
      codigosCorrectos: [201],
      mensajePorDefecto: 'No se pudo crear la reserva.',
    );
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

    final response = await _ejecutar(
      http.get(
        Uri.parse('$_baseUrl/reservas'),
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    _verificarRespuesta(
      response,
      codigosCorrectos: [200],
      mensajePorDefecto: 'No se pudieron cargar tus reservas.',
    );

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

    final response = await _ejecutar(
      http.patch(
        Uri.parse('$_baseUrl/reservas/$reservaId/cancelar'),
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    _verificarRespuesta(
      response,
      codigosCorrectos: [200],
      mensajePorDefecto: 'No se pudo cancelar la reserva.',
    );
  }

  static Future<UserProfile> actualizarMiPerfil({
    required String nombre,
    required String apellido,
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

    final response = await _ejecutar(
      http.patch(
        Uri.parse('$_baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nombre': nombre,
          'apellido': apellido,
          'fecha_nacimiento':
              '${partesFecha[2]}-${partesFecha[1]}-${partesFecha[0]}',
          'dni': dni,
        }),
      ),
    );

    _verificarRespuesta(
      response,
      codigosCorrectos: [200],
      mensajePorDefecto: 'No se pudo actualizar la información de tu perfil.',
    );

    final datos = jsonDecode(response.body) as Map<String, dynamic>;

    return UserProfile.fromJson(datos);
  }

  static Future<List<CanchaConSede>> obtenerCanchas() async {
    final response = await _ejecutar(http.get(Uri.parse('$_baseUrl/canchas')));

    _verificarRespuesta(
      response,
      codigosCorrectos: [200],
      mensajePorDefecto: 'No se pudo cargar la lista de canchas.',
    );

    final datos = jsonDecode(response.body) as List<dynamic>;

    return datos
        .map((dato) => CanchaConSede.fromJson(dato as Map<String, dynamic>))
        .toList();
  }

  static Future<http.Response> _ejecutar(
    Future<http.Response> solicitud,
  ) async {
    try {
      final response = await solicitud.timeout(const Duration(seconds: 10));

      if (response.statusCode >= 500) {
        throw const ApiException(
          'El servidor no está disponible. Intentá nuevamente más tarde.',
        );
      }

      return response;
    } on SocketException {
      throw const ApiException(
        'No hay conexión a Internet. Revisá tu red e intentá nuevamente.',
      );
    } on http.ClientException {
      throw const ApiException('No se pudo conectar con el servidor.');
    } on TimeoutException {
      throw const ApiException(
        'El servidor tardó demasiado en responder. Intentá nuevamente.',
      );
    }
  }

  static String _mensajeDeRespuesta(
    http.Response response,
    String mensajePorDefecto,
  ) {
    try {
      final datos = jsonDecode(response.body) as Map<String, dynamic>;

      return datos['detail'] as String? ?? mensajePorDefecto;
    } catch (_) {
      return mensajePorDefecto;
    }
  }

  static void _verificarRespuesta(
    http.Response response, {
    required List<int> codigosCorrectos,
    required String mensajePorDefecto,
  }) {
    if (codigosCorrectos.contains(response.statusCode)) return;

    throw ApiException(_mensajeDeRespuesta(response, mensajePorDefecto));
  }

  static Future<void> registrarTokenDispositivo(String token) async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();

    if (idToken == null) {
      throw const ApiException('No hay un usuario autenticado.');
    }

    final response = await _ejecutar(
      http.post(
        Uri.parse('$_baseUrl/device-tokens'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'token': token}),
      ),
    );

    _verificarRespuesta(
      response,
      codigosCorrectos: [204],
      mensajePorDefecto: 'No se pudo registrar el dispositivo.',
    );
  }
}
