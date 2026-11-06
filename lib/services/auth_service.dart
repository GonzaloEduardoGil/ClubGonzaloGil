import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<String?> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null;
    } on FirebaseAuthException catch (error) {
      return _mensajeDeError(error);
    }
  }

  static Future<String?> registrar({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // La consigna indica que, luego de registrarse,
      // el usuario vuelve al inicio de sesión.
      await _auth.signOut();

      return null;
    } on FirebaseAuthException catch (error) {
      return _mensajeDeError(error);
    }
  }

  static String _mensajeDeError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo.';
      case 'invalid-email':
        return 'El correo no tiene un formato válido.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'network-request-failed':
        return 'No hay conexión a Internet.';
      default:
        return 'No se pudo completar la operación. Intentá nuevamente.';
    }
  }
}