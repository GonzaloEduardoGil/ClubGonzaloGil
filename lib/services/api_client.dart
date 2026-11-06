import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/sede.dart';

class ApiClient {
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
}