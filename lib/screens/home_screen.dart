import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'sedes_screen.dart';
import '../models/user_profile.dart';
import 'profile_screen.dart';
import 'reservas_screen.dart';
import 'canchas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.usuario,
  });

  final UserProfile usuario;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  int _selectedIndex = 0;

  void _goToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  late UserProfile _usuario;

  @override
  void initState() {
  super.initState();
  _usuario = widget.usuario;
}

void _actualizarPerfil(UserProfile usuarioActualizado) {
  setState(() {
    _usuario = usuarioActualizado;
  });
  }
  Widget build(BuildContext context) {
    final pages = [
      _HomeContent(nombre: _usuario.nombre),
      const SedesScreen(),
      const CanchasScreen(),
      const ReservasScreen(),
      ProfileScreen(
        usuario: _usuario,
        onProfileUpdated: _actualizarPerfil,
        ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[700]!, width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: AppColors.indigo[700],
          unselectedItemColor: Colors.grey[500],
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _goToTab,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: 'Sedes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_soccer),
              label: 'Canchas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Reservas',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.nombre,
  });

  final String nombre;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 250,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.indigo[400],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Hola, $nombre',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 48),
                  Text(
                    'CLUB GONZALO GIL',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'ZONA DEPORTIVA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.indigo[400],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.event_available,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Próxima reserva',
                            style: TextStyle(
                              color: AppColors.indigo[900],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sin reservas próximas',
                            style: TextStyle(
                              color: Colors.grey[850],
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Elegí una sede para reservar',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction, size: 52, color: AppColors.indigo[700]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(message),
          ],
        ),
      ),
    );
  }
}
