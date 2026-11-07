import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'api_client.dart';

class PushService {
  PushService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static StreamSubscription<String>? _tokenRefreshSubscription;

  static Future<void> inicializar() async {
    final permisos = await _messaging.requestPermission();

    if (permisos.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    final token = await _messaging.getToken();

    if (token != null) {
      await ApiClient.registrarTokenDispositivo(token);
    }

    _tokenRefreshSubscription ??= _messaging.onTokenRefresh.listen(
      (nuevoToken) async {
        try {
          await ApiClient.registrarTokenDispositivo(nuevoToken);
        } catch (_) {
          // No interrumpe la app si falla el registro del token.
        }
      },
    );
  }
}