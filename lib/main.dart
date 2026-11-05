import 'package:flutter/material.dart';

// main es el punto de inicio de toda aplicación Flutter.
void main() {
  runApp(const ClubGonzaloGilApp());
}

// Esta clase configura la aplicación completa: nombre, colores y pantalla inicial.
class ClubGonzaloGilApp extends StatelessWidget {
  const ClubGonzaloGilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Club Gonzalo Gil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A6E4F),
        ),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

// Primera pantalla que verá la persona al abrir la aplicación.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.sports_soccer,
                  size: 96,
                  color: Color(0xFF0A6E4F),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Club Gonzalo Gil',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF12372A),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Reservá tu espacio deportivo de forma simple y rápida.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Color(0xFF4F6359),
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Próximamente: inicio de sesión'),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('COMENZAR'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}