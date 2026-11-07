import 'package:flutter/material.dart';

import 'screens/auth_gate.dart';
import 'theme/app_colors.dart';

import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const ClubGonzaloGilApp());
}

// Configuración general de la aplicación.
class ClubGonzaloGilApp extends StatelessWidget {
  const ClubGonzaloGilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Club Gonzalo Gil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
