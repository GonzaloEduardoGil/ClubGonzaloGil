import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api_client.dart';

class PushService {
  PushService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static StreamSubscription<String>? _tokenRefreshSubscription;
  static StreamSubscription<RemoteMessage>? _foregroundSubscription;

  static const _channel = AndroidNotificationChannel(
    'reservas',
    'Reservas',
    description: 'Confirmaciones y recordatorios de reservas.',
    importance: Importance.high,
  );

  static Future<void> inicializar() async {
    const configuracionAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: configuracionAndroid),
    );

    final android = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await android?.createNotificationChannel(_channel);

    final permisos = await _messaging.requestPermission();

    if (permisos.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    final token = await _messaging.getToken();

    if (token != null) {
      await ApiClient.registrarTokenDispositivo(token);
    }

    _tokenRefreshSubscription ??= _messaging.onTokenRefresh.listen((
      nuevoToken,
    ) async {
      try {
        await ApiClient.registrarTokenDispositivo(nuevoToken);
      } catch (_) {
        // No interrumpe la app si falla el registro del token.
      }
    });

    _foregroundSubscription ??= FirebaseMessaging.onMessage.listen(
      _mostrarNotificacionEnPrimerPlano,
    );
  }

  static Future<void> _mostrarNotificacionEnPrimerPlano(
    RemoteMessage mensaje,
  ) async {
    final notificacion = mensaje.notification;

    if (notificacion == null) return;

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      notificacion.title ?? 'Club Gonzalo Gil',
      notificacion.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reservas',
          'Reservas',
          channelDescription: 'Confirmaciones y recordatorios de reservas.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
