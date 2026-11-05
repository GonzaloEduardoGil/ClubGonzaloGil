import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
import 'theme/app_colors.dart';

void main() {
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
      home: const WelcomeScreen(),
    );
  }
}
